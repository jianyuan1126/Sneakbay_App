import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user_model.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<UserModel> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('users').get();
      var usersList =
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      setState(() {
        users = usersList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUserStatus(String userId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'status': newStatus,
      });
      setState(() {
        users.firstWhere((user) => user.uid == userId).status = newStatus;
      });
    } catch (e) {
      print('Error updating user status: $e');
    }
  }

  Future<void> updateUserPoints(String userId, int newPoints) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'points': newPoints,
      });
      setState(() {
        users.firstWhere((user) => user.uid == userId).points = newPoints;
      });
    } catch (e) {
      print('Error updating user points: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildUserTable(),
    );
  }

  Widget buildUserTable() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Table(
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('Name',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('Email',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('Status',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('Points',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('Actions',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                ...users.map((user) => TableRow(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Center(
                            child: Text(user.name),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Center(child: Text(user.email)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: user.status,
                                  items: <String>['active', 'banned']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      updateUserStatus(user.uid, newValue);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: TextField(
                              controller: TextEditingController()
                                ..text = user.points.toString(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onSubmitted: (newValue) {
                                int newPoints =
                                    int.tryParse(newValue) ?? user.points;
                                updateUserPoints(user.uid, newPoints);
                              },
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () {
                                  _showUserDetailsDialog(context, user);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  bool confirmed = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this user?'),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Delete'),
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirmed) {
                                    await deleteUser(user.uid);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      setState(() {
        users.removeWhere((user) => user.uid == userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  void _showUserDetailsDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(' Details Of ${user.name}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildDetailField('Full Legal Name', user.name),
                _buildDetailField('Email', user.email),
                _buildDetailField('Phone', user.phoneNumber.toString()),
                if (user.address != null)
                  _buildDetailField('Address',
                      '${user.address!.streetAddress1}, ${user.address!.city}, ${user.address!.state}, ${user.address!.postalCode}'),
                if (user.bankAccountDetails != null)
                  _buildDetailField('Bank Account',
                      '${user.bankAccountDetails!.bankName}, ${user.bankAccountDetails!.accountNumber}'),
                _buildDetailField(
                    'Available Currency', user.availableCurrency.toString()),
                _buildDetailField(
                    'Lifetime Sales', user.lifetimeSales.toString()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          border: OutlineInputBorder(),
        ),
        controller: TextEditingController()..text = value,
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../../models/user_model.dart';
import '../../../service/user_service.dart';
import '../../../widget/main_app_bar.dart';
import '../auth/banned_user_page.dart';
import '../cashout/otp_verification_page.dart';
import '../profile/bank_acc_page.dart';
import '../setting/setting_page.dart';
import '../cashout/cash_out_success.dart';
import 'component/transaction_list_widget.dart';
import 'transaction_history_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'component/sale_details.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLoading = false;

  Future<double> _fetchPendingCredits(String userId) async {
    double totalPendingCredits = 0;
    final closedOrderIds = <String>{};

    // Fetch earnings from the 'sold' collection
    final soldCollection = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('sold')
        .where('status', isEqualTo: 'Pending')
        .get();

    for (var doc in soldCollection.docs) {
      if (!closedOrderIds.contains(doc.id)) {
        totalPendingCredits += (doc['earnings'] as num? ?? 0).toDouble();
      }
    }

    // Fetch earnings from the 'confirmedOrders' collection
    final confirmedCollection = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('confirmedOrders')
        .get();

    for (var doc in confirmedCollection.docs) {
      closedOrderIds.add(doc.id);
      totalPendingCredits += (doc['earnings'] as num? ?? 0).toDouble();
    }

    return totalPendingCredits;
  }

  Future<List<Map<String, dynamic>>> _fetchTransactions(
      String userId, int limit) async {
    // Fetch recent transactions from 'transactions' collection
    final transactionSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    // Fetch closed orders from 'closedOrders' collection
    final closedOrdersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('closedOrders')
        .orderBy('orderConfirmedTimestamp', descending: true)
        .limit(limit)
        .get();

    // Combine both lists, ensuring no duplicates
    final allDocuments = transactionSnapshot.docs
        .map((doc) => doc.data()..['id'] = doc.id)
        .toList();
    closedOrdersSnapshot.docs.forEach((doc) {
      final data = doc.data()..['id'] = doc.id;
      if (!allDocuments.any((d) => d['id'] == data['id'])) {
        data['date'] = data['orderConfirmedTimestamp'];
        data['amount'] = data['earnings'];
        data['type'] = 'Sale';
        allDocuments.add(data);
      }
    });

    // Sort transactions by date
    allDocuments.sort((a, b) {
      return (b['date'] as Timestamp).compareTo(a['date'] as Timestamp);
    });

    return allDocuments;
  }

  void _handleCashOut(BuildContext context, UserModel userModel) async {
    setState(() {
      _isLoading = true;
    });

    final user = Provider.of<User?>(context, listen: false);
    final userService = UserService();

    if (user != null) {
      final userDoc = await userService.getUser(user.uid);
      if (userDoc.bankAccountDetails == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BankAccPage()),
        ).then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        // Fetch phone number from Firebase
        final phoneNumber = userDoc.phoneNumber;
        final fullPhoneNumber = '+60$phoneNumber';

        // Store the amount to be cashed out
        final amountCashedOut = userModel.availableCurrency;

        // Send OTP
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: fullPhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            _navigateToSuccessPage(context, amountCashedOut);
          },
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification failed. Try again later.')),
            );
            setState(() {
              _isLoading = false;
            });
          },
          codeSent: (String verificationId, int? resendToken) async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationPage(
                  verificationId: verificationId,
                  phoneNumber: fullPhoneNumber,
                ),
              ),
            );

            if (result != null && result is User) {
              await _handleCashOutSuccess(
                  userModel, userService, amountCashedOut);
              _navigateToSuccessPage(context, amountCashedOut);
            } else {
              setState(() {
                _isLoading = false;
              });
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          forceResendingToken: 1,
          timeout: const Duration(seconds: 60),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCashOutSuccess(
      UserModel userModel, UserService userService, double amount) async {
    await userService.updateUserCurrency(userModel.uid, 0);
    await userService.logTransaction(userModel.uid, 'Cash Out', amount);
  }

  void _navigateToSuccessPage(BuildContext context, double amountCashedOut) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CashOutSuccessPage(amountCashedOut: amountCashedOut),
      ),
    ).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Profile Page',
          backgroundColor: Colors.white,
          iconThemeColor: Colors.black,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final UserService userService = UserService();
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile Page',
        backgroundColor: Colors.white,
        iconThemeColor: Colors.black,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: userService.userStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found'));
          } else {
            final userModel = snapshot.data!;
            if (userModel.status == 'banned') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const BannedUserPage(),
                  ),
                );
              });
            }
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${userModel.points} PTS',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: screenWidth,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Card(
                        color: Colors.white,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  '\RM${userModel.lifetimeSales.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text('Lifetime Sales'),
                                const SizedBox(height: 16.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: screenWidth,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Card(
                        color: Colors.white,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  '\RM${userModel.availableCurrency.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8.0),
                                const Text('Available Currency'),
                                const SizedBox(height: 16.0),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed:
                                          userModel.availableCurrency > 0 &&
                                                  !_isLoading
                                              ? () {
                                                  _handleCashOut(
                                                      context, userModel);
                                                }
                                              : null,
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.black,
                                        minimumSize: const Size.fromHeight(40),
                                      ),
                                      child: const Text('Cash Out Now'),
                                    ),
                                    if (_isLoading)
                                      const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  '1.3% Cash Out Fee per cash out',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FutureBuilder<double>(
                    future: _fetchPendingCredits(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading pending credits'));
                      }
                      final pendingCredits = snapshot.data ?? 0;
                      return Column(
                        children: [
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _fetchTransactions(user.uid, 5),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Error loading transactions'));
                              }

                              final transactionsAvailable =
                                  snapshot.hasData && snapshot.data!.isNotEmpty;

                              List<Map<String, dynamic>> combinedTransactions =
                                  [];
                              if (pendingCredits > 0) {
                                combinedTransactions.add({
                                  'id': 'pendingCredits',
                                  'amount': pendingCredits,
                                  'type': 'Pending Credits',
                                  'date': DateTime.now(),
                                });
                              }
                              if (transactionsAvailable) {
                                combinedTransactions.addAll(snapshot.data!);
                              }

                              if (combinedTransactions.length > 6) {
                                combinedTransactions =
                                    combinedTransactions.sublist(0, 6);
                              }

                              combinedTransactions.sort((a, b) {
                                if (a['id'] == 'pendingCredits') return -1;
                                if (b['id'] == 'pendingCredits') return 1;
                                return (b['date'] as Timestamp)
                                    .compareTo(a['date'] as Timestamp);
                              });

                              return Column(
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Recent Transaction History',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TransactionList(
                                    transactions: combinedTransactions,
                                    onSaleTap: (orderId) {
                                      showSaleDetails(
                                          context, user.uid, orderId);
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TransactionHistoryPage(
                                                      userId: user.uid),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'VIEW ALL',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}

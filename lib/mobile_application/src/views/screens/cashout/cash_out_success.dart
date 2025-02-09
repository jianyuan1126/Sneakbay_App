import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../models/user_model.dart';
import '../../../service/user_service.dart';
import '../../../widget/main_app_bar.dart';

class CashOutSuccessPage extends StatelessWidget {
  final double amountCashedOut;

  const CashOutSuccessPage({super.key, required this.amountCashedOut});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final UserService userService = UserService();

    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Cash Out Success',
        backgroundColor: Colors.white,
        iconThemeColor: Colors.black,
        showBackButton: false,
      ),
      body: FutureBuilder<UserModel>(
        future: userService.getUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No user data found'));
          }

          final userModel = snapshot.data!;
          final bankAccountLast4Digits =
              userModel.bankAccountDetails?.accountNumber.substring(
                  userModel.bankAccountDetails!.accountNumber.length - 4);
          final bankName =
              userModel.bankAccountDetails?.bankName ?? 'your bank';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(), // Pushes the content down
                Column(
                  children: [
                    Text(
                      'MYR ${amountCashedOut.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black text
                      ),
                      textAlign: TextAlign.center, // Center the text horizontally
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'This amount will be transferred to $bankName into the account ending in $bankAccountLast4Digits in 1 to 2 business days',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black), // Black text
                      textAlign: TextAlign.center, // Center the text horizontally
                    ),
                  ],
                ),
                Spacer(), // Pushes the content up and the button down
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.white, // White background
    );
  }
}

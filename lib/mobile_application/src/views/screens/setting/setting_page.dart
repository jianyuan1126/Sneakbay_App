import 'package:flutter/material.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/auth/login_page.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/profile/address_page.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/profile/bank_acc_page.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/profile/faq_page.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/profile/payment_method_page.dart';
import 'package:flutter_application_1/mobile_application/src/widget/custom_list_item.dart';
import 'package:flutter_application_1/mobile_application/src/widget/section.dart';
import 'package:flutter_application_1/mobile_application/src/widget/section_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widget/main_app_bar.dart';
import '../profile/change_password_page.dart';
import '../profile/profile_page.dart';
import '../profile/seller_policy_page.dart';
import '../profile/terms_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        backgroundColor: Colors.white,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SectionTitle(text: 'ACCOUNT'),
            Section(
              children: [
                CustomListItem(
                  title: 'Profile',
                  value: '',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const ProfilePage(),
                      ),
                    );
                  },
                ),
                CustomListItem(
                  title: 'Change Password',
                  value: '',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                CustomListItem(
                  title: 'Return Address',
                  value: '',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const ReturnAddressPage(),
                      ),
                    );
                  },
                ),
                CustomListItem(
                  title: 'Payment Method',
                  value: '',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const PaymentMethodPage(),
                      ),
                    );
                  },
                ),
                CustomListItem(
                  title: 'Bank Details',
                  value: '',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const BankAccPage(),
                      ),
                    );
                  },
                  isLastItem: true,
                ),
              ],
            ),
            const SectionTitle(text: 'SUPPORT'),
            Section(
              children: [
                CustomListItem(
                  title: 'FAQ',
                  value: '',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const FAQPage(),
                      ),
                    );
                  },
                  isLastItem: true,
                ),
              ],
            ),
            const SectionTitle(text: 'ABOUT'),
            Section(
              children: [
                CustomListItem(
                  title: 'Terms',
                  value: '',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const TermsPage(),
                      ),
                    );
                  },
                  isLastItem: true,
                ),
                CustomListItem(
                  title: 'Seller Policy',
                  value: '',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const SellerPolicyPage(),
                      ),
                    );
                  },
                  isLastItem: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: () async {
          await _logout(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: const Text('Log Out'),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isRememberMe');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}

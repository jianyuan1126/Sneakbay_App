import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../service/mode_provider.dart';
import '../../buy/components/cart_page.dart';
import '../../profile/address_page.dart';

class BuySellPage extends StatefulWidget {
  final VoidCallback onBuyPressed;
  final Future<void> Function(String shoeId) onSellPressed;
  final String selectedShoeId;

  const BuySellPage({
    super.key,
    required this.onBuyPressed,
    required this.onSellPressed,
    required this.selectedShoeId,
  });

  @override
  _BuySellPageState createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    final modeProvider = Provider.of<ModeProvider>(context, listen: false);
    if (modeProvider.isBuyMode) {
      if (index == 0) {
        widget.onBuyPressed();
      } else if (index == 1) {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const CartPage(),
          ),
        );
      }
    } else {
      if (index == 0) {
        await _checkAndNavigateToSellPage();
      }
    }
  }

  Future<void> _checkAndNavigateToSellPage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null &&
          userData.containsKey('address') &&
          userData['address']['streetAddress1'] != '') {
        await widget.onSellPressed(widget.selectedShoeId);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReturnAddressPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeProvider = Provider.of<ModeProvider>(context);

    return modeProvider.isBuyMode
        ? Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money),
                  label: 'Buy',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
            ),
          )
        : Container(
            height: 59,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            child: BottomAppBar(
              color: Colors.white,
              child: InkWell(
                onTap: () => _onItemTapped(0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.sell, color: Colors.black, size: 18),
                      SizedBox(height: 1),
                      Text(
                        'Start Listing',
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

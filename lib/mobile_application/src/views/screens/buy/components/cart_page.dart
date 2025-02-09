import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../models/address_model.dart';
import '../../../../widget/main_app_bar.dart';
import '../../main_page.dart';
import '../../profile/address_page.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  User? user;
  late StreamSubscription cartSubscription;
  late StreamSubscription listingsSubscription;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _listenToCartItems();
      _listenToListings();
    }
  }

  @override
  void dispose() {
    cartSubscription.cancel();
    listingsSubscription.cancel();
    super.dispose();
  }

  void _listenToCartItems() {
    cartSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
      // Trigger a rebuild when cart items change
      setState(() {});
    });
  }

  void _listenToListings() {
    listingsSubscription = FirebaseFirestore.instance
        .collection('all_listings')
        .snapshots()
        .listen((snapshot) {
      _checkCartItemsAvailability(snapshot.docs);
    });
  }

  void _checkCartItemsAvailability(List<DocumentSnapshot> listings) async {
    var cartItemsSnapshot = await _getCartItems();
    var cartItems = cartItemsSnapshot.docs;

    for (var cartItem in cartItems) {
      var itemData = cartItem.data() as Map<String, dynamic>;
      var listingId = itemData['listingId'];
      var shoeId = itemData['shoeId'];
      print(
          'Checking cart item with listingId: $listingId and shoeId: $shoeId');

      DocumentSnapshot? listing;

      try {
        listing = await FirebaseFirestore.instance
            .collection('all_listings')
            .doc(shoeId)
            .collection('listings')
            .doc(listingId)
            .get();

        if (!listing.exists) {
          listing = null;
        }
      } catch (e) {
        listing = null;
      }

      if (listing == null) {
        print('Listing not found for listingId: $listingId in all_listings');
      } else {
        print(
            'Listing found for listingId: $listingId with status: ${(listing.data() as Map<String, dynamic>)['status']}');
      }

      if (listing == null ||
          (listing.data() as Map<String, dynamic>)['status'] == 'sold') {
        _removeItemFromCart(cartItem.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'An item in your cart has been purchased by another user and removed from your cart.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<QuerySnapshot> _getCartItems() async {
    if (user == null) {
      throw Exception("User not logged in");
    }
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .get();
  }

  Future<Address?> _getUserAddress() async {
    if (user == null) {
      return null;
    }
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    var userData = userDoc.data() as Map<String, dynamic>?;
    if (userData != null && userData.containsKey('address')) {
      return Address.fromMap(userData['address']);
    }
    return null;
  }

  void _removeItemFromCart(String itemId) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('cart')
          .doc(itemId)
          .delete();
      setState(() {});
    }
  }

  Future<void> _checkAddressAndNavigate() async {
    Address? address = await _getUserAddress();
    if (address == null) {
      bool? addressAdded = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ReturnAddressPage(),
        ),
      );

      if (addressAdded == true) {
        setState(() {});
      }
    } else {
      var cartItems = await _getCartItems();
      if (cartItems.docs.isNotEmpty) {
        var items = cartItems.docs.map((doc) {
          var itemData = doc.data() as Map<String, dynamic>;
          print('Cart item data: $itemData');
          return {
            'cartId': doc.id,
            'shoeId': itemData['shoeId'],
            'shoeName': itemData['shoeName'],
            'size': itemData['size'],
            'condition': itemData['condition'],
            'packaging': itemData['packaging'],
            'price': (itemData['price'] as num).toDouble(),
            'imgAddress': itemData['imgAddress'],
            'listingId': itemData['listingId'],
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'sku': itemData['sku'] ?? 'N/A',
          };
        }).toList();

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return CheckoutBottomSheet(
              items: items,
              onPaymentSuccess: _handlePaymentSuccess,
            );
          },
        );
      }
    }
  }

  void _handlePaymentSuccess() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainScreen(initialIndex: 3),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Cart',
        backgroundColor: Colors.white,
        iconThemeColor: Colors.black,
        showBackButton: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          var cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              var cartItem = cartItems[index];
              var itemData = cartItem.data() as Map<String, dynamic>;

              String imgAddress = itemData['imgAddress'] ?? '';
              if (!Uri.tryParse(imgAddress)!.hasAbsolutePath) {
                imgAddress = '';
              }
              String shoeName = itemData['shoeName'] ?? 'Unknown Shoe';
              String size = itemData['size'] ?? 'Unknown Size';
              String condition = itemData['condition'] ?? 'Unknown Condition';
              String packaging = itemData['packaging'] ?? 'Unknown Packaging';
              String price = itemData['price']?.toString() ?? '0';

              return ListTile(
                leading: Container(
                  width: 120,
                  height: 100,
                  child: imgAddress.isNotEmpty
                      ? Image.network(
                          imgAddress,
                          fit: BoxFit.contain,
                        )
                      : Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                ),
                title: Text(shoeName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Size: $size'),
                    Text('Condition: $condition'),
                    Text('Box: $packaging'),
                    Text('Price: \RM $price'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _removeItemFromCart(cartItem.id);
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Address?>(
        future: _getUserAddress(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          bool hasAddress = snapshot.data != null;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _checkAddressAndNavigate,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Text color
                backgroundColor: Colors.black, // Background color
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Rounded border
                ),
              ),
              child: Text(
                hasAddress ? 'CONTINUE TO CHECKOUT' : 'ADD SHIPPING ADDRESS',
              ),
            ),
          );
        },
      ),
    );
  }
}

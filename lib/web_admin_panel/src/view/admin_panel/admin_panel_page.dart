import 'package:flutter/material.dart';
import 'package:flutter_application_1/web_admin_panel/src/view/admin_panel/component/navigation_bar.dart';
import 'package:flutter_application_1/web_admin_panel/src/view/content_upload/content_upload_page.dart';
import '../box_condition/box_condition_management.dart';
import '../check_in/check_in_page.dart';
import '../faq/faq_page_upload.dart';
import '../inventory/product_inventory_page.dart';
import '../item_condition/item_condition_management.dart';
import '../rating_review/rating_review_page.dart';
import '../seller_policy/seller_policy_upload_page.dart';
import '../terms/terms_upload_page.dart';
import '../user_management/user_management_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    UserManagementPage(),
    const ProductInventoryPage(),
    CheckInPage(),
    RatingReviewPage(),
    ItemConditionManagement(),
    BoxConditionManagement(),
    ContentUploadPage(),
    FAQUploadPage(),
    TermsUploadPage(),
    SellerPolicyUploadPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigationBar(
            selectedIndex: _selectedIndex,
            onSelect: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

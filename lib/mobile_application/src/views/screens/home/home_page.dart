import 'package:flutter/material.dart';
import 'package:flutter_application_1/mobile_application/src/widget/mode_toggle_button.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/home/components/image_slider.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/home/components/sneaker_body.dart';
import '../../../widget/main_app_bar.dart';
import 'components/chat_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  void _showChatBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ChatBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'SneakBay',
        showBackButton: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ModeToggleButton(),
          ),
        ],
        isTitleLeftAligned: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const ImageSlider(),
              const SizedBox(height: 16),
              const Body(),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Container(
          height: 40,
          child: ElevatedButton(
            onPressed: _showChatBottomSheet,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat, color: Colors.white),
                SizedBox(width: 8),
                Text('Chat with SneakBot',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.white,
    );
  }
}

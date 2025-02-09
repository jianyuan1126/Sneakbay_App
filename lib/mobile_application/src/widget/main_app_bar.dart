import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? iconThemeColor;
  final bool showBackButton;
  final bool isTitleLeftAligned;
  final Widget? leading; 

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.iconThemeColor,
    this.showBackButton = false,
    this.isTitleLeftAligned = false,
    this.leading, 
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: !isTitleLeftAligned,
      title: isTitleLeftAligned
          ? Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 21.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 21.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(
          color: iconThemeColor ?? Theme.of(context).primaryColor),
      automaticallyImplyLeading: false, 
      leading: showBackButton
          ? leading ??
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: iconThemeColor ?? Theme.of(context).primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

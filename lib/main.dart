import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/mobile_application/src/service/mode_provider.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/auth/landing_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mobile_application/src/service/user_service.dart';
import 'models/user_model.dart';
import 'mobile_application/src/views/screens/main_page.dart';
import 'web_admin_panel/admin_panel_main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBvykPkIydMkG7631Hv6T1xAv06wErUIPk',
      appId: '1:93864875177:android:7558b36a556867113a85b8',
      messagingSenderId: '93864875177',
      projectId: 'sneakbay-e09d8',
      storageBucket: 'sneakbay-e09d8.appspot.com',
    ),
  );

  if (!kIsWeb) {
    Stripe.publishableKey =
        'pk_test_51PJTeIDpKg8wlVpqvceLbNnPkbkDNcBMIk452uAvIviPJpkpTrsPc03fwYsZ4n8TS1p9eaxJlzqPGhIznEFxw5ba00IkHC1bkY';
    await Stripe.instance.applySettings();
  }

  if (kIsWeb) {
    runApp(const WebAdminApp());
  } else {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ModeProvider()),
          StreamProvider<User?>.value(
            value: FirebaseAuth.instance.authStateChanges(),
            initialData: FirebaseAuth.instance.currentUser,
          ),
        ],
        child: const MobileApp(),
      ),
    );
  }
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return MaterialApp(
      title: 'SneakBay Mobile',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: user == null
          ? const LandingPage()
          : MultiProvider(
              providers: [
                StreamProvider<UserModel?>.value(
                  value: UserService().userStream(user.uid),
                  initialData: null,
                ),
              ],
              child: const MainScreen(),
            ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebAdminApp extends StatelessWidget {
  const WebAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SneakBay Web Admin',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const AdminDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

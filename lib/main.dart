import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
   await dotenv.load(fileName: '.env');
  runApp(const SafeRuasApp());
}

class SafeRuasApp extends StatelessWidget {
  const SafeRuasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SafeRuas',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}

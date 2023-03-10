import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'home/home_screen.dart';
import 'util/recipe_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const YumApp());
}

class YumApp extends StatefulWidget {
  const YumApp({Key? key}) : super(key: key);

  @override
  State<YumApp> createState() => _YumAppState();
}

class _YumAppState extends State<YumApp> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChangeNotifierProvider(
          create: (_) => RecipeStore(),
          child: const HomeScreen(),
        ),
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}

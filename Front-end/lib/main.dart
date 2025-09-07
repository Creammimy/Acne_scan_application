import 'package:flutter/material.dart';
import 'package:project_acne_scan/screens/result_screen.dart';
import 'package:project_acne_scan/screens/scan_screen.dart';
import 'package:project_acne_scan/screens/settings_screen.dart';
import 'package:project_acne_scan/screens/signup_screen.dart';
import 'package:project_acne_scan/screens/welcome_screen.dart';
import 'package:project_acne_scan/screens/login_screen.dart';
import 'package:project_acne_scan/screens/home_screen.dart';
import 'package:project_acne_scan/screens/history_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: 'https://bjchkbeqhtdmbekxnpkv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJqY2hrYmVxaHRkbWJla3hucGt2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU3MTUzNDIsImV4cCI6MjA2MTI5MTM0Mn0.-tkelWkGSqgdSG5VGm8dZko7uxwqkrKjh24j0VI9ycQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Acne Scanner',
      theme: ThemeData(
        fontFamily: 'FCMinimal',
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/scan': (context) =>  ScanScreen(imagePaths: ['path_to_your_image_file']),
        '/analysis': (context) =>  Placeholder(), 
        '/history': (context) => HistoryScreen(),
        '/settings': (context) => SettingsScreen(),
      },
     
      onGenerateRoute: (settings) {
        if (settings.name == '/analysis') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ResultScreen(
              imagePaths: args['imagePaths'],
              detectionResultsPerImage: args['detectionResultsPerImage'],
              pimpleTypes: args['pimpleTypes'],
              careInstructions: args['careInstructions'],
            ),
          );
        }
        return null;
      },
    );
  }
}

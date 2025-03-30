import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import 'package:horeb_registration/screens/welcome_screen.dart';
import 'package:horeb_registration/theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("Env file loaded successfully");
    print("PROJECT_ID: ${dotenv.env["PROJECT_ID"]}");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  Client client = Client()
      .setEndpoint(dotenv.env["ENDPOINT"]!)
      .setProject(dotenv.env["PROJECT_ID"]);
  Account account = Account(client);

  runApp(MaterialApp(home: MyApp(account: account, client: client)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.account, required this.client});

  final Account account;
  final Client client;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Horeb',
      theme: lightMode,
      home: WelcomeScreen(account: account, client: client),
    );
  }
}

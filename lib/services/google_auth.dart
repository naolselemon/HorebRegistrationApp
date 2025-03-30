import 'package:appwrite/enums.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:horeb_registration/screens/home_screen.dart';
import 'package:icons_plus/icons_plus.dart';

class GoogleAuthButton extends StatelessWidget {
  final Account account;
  final BuildContext parentContext;
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;

  const GoogleAuthButton({
    super.key,
    required this.account,
    required this.parentContext,
    this.onSuccess,
    this.onFailure,
  });

  Future<void> _signInWithGoogle() async {
    // Remove context parameter
    try {
      // Show loading dialog using parentContext
      showDialog(
        context: parentContext,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Perform Google OAuth2 authentication
      await account.createOAuth2Session(provider: OAuthProvider.google);

      // Dismiss the loading dialog
      if (Navigator.canPop(parentContext)) {
        Navigator.pop(parentContext);
      }

      // Call onSuccess
      onSuccess?.call();

      // Navigate to HomeScreen
      Navigator.pushReplacement(
        parentContext,
        MaterialPageRoute(builder: (ctx) => HomeScreen(account: account)),
      );
    } catch (e) {
      // Dismiss the loading dialog on failure
      if (Navigator.canPop(parentContext)) {
        Navigator.pop(parentContext);
      }

      print("Failed to authenticate with Google: $e");
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text("Google authentication failed: $e")),
      );

      onFailure?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _signInWithGoogle,
      child: Icon(BoxIcons.bxl_google, size: 40),
    );
  }
}

import 'package:flutter/material.dart';
import "package:appwrite/appwrite.dart";

import "package:horeb_registration/screens/signin_screen.dart";
import "package:horeb_registration/screens/signup_screen.dart";
import "package:horeb_registration/theme/theme.dart";
import "package:horeb_registration/widgets/custom_scuffold.dart";
import "package:horeb_registration/widgets/custom_welcome.dart";

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome Horebawians!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '\nEnter personal details to ',
                        style: TextStyle(
                          fontSize: 20,
                          // height: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTap: SignInScreen(account: account),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: SignUpScreen(account: account),
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

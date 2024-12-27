import 'package:flutter/material.dart';
import '/core/utils/extension/context_ext.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(
            context.theme.primaryColor,
          ),
        ),
      ),
    );
  }
}

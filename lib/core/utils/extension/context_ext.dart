import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  Size get size => MediaQuery.of(this).size;

  double get height => size.height;

  double get width => size.width;

  EdgeInsets get padding => MediaQuery.of(this).padding;

  double get topPadding => padding.top;

  double get bottomPadding => padding.bottom;

  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  dismissKeyboard() {
    FocusScope.of(this).requestFocus(FocusNode());
  }

  void navigateTo(Widget widget, {Bloc? bloc}) {
    if (bloc != null) {
      _navigateToWithBloc(widget, bloc);
      return;
    }
    Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  }

  void _navigateToWithBloc(Widget widget, Bloc bloc) {
    Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: widget,
        ),
      ),
    );
  }

  void navigateBack() {
    Navigator.pop(this);
  }

  void navigateToAndRemoveUntil(Widget widget) {
    Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      (route) => false,
    );
  }

  void navigateToAndReplace(Widget widget) {
    Navigator.pushReplacement(
      this,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  }

  showErrorToast(String message) {
    return showToast(
      message,
      context: this,
      backgroundColor: theme.colorScheme.errorContainer,
      textStyle: textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onErrorContainer,
      ),
    );
  }

  showInfoToast(String message) {
    return showToast(
      message,
      context: this,
      textStyle: textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onTertiaryContainer,
      ),
      backgroundColor: theme.colorScheme.tertiaryContainer,
    );
  }
}

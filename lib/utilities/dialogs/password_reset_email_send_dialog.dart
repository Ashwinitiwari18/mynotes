import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content:
        'we have now sent you password reset link. Plese check your Email for more information.',
    optionBuilder: () => {
      'OK': null,
    },
  );
}

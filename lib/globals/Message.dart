import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showSuccessSnackBar(BuildContext context, String text) {
  final snackbar = SnackBar(
    content: Text(
      text,
      style: GoogleFonts.poppins(color: Colors.white),
    ),
    backgroundColor: Colors.green,
    showCloseIcon: true,
    closeIconColor: Colors.white,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

void showFailureSnackBar(BuildContext context, String text) {
  final snackbar = SnackBar(
    content: Text(
      text,
      style: GoogleFonts.poppins(color: Colors.white),
    ),
    backgroundColor: Colors.red,
    showCloseIcon: true,
    closeIconColor: Colors.white,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

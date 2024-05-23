import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget customTextfield({
  required TextEditingController controller,
  TextInputType type = TextInputType.name,
  Function? onChanged,
  Color borderColor = Colors.black,
  String label = "Enter Text",
  bool enabled = true,
  Widget leading = const SizedBox(),
  Widget trailing = const SizedBox(),
}) {
  return TextFormField(
    keyboardType: type,
    controller: controller,
    maxLines: null,
    onChanged: (value) {
      if (onChanged != null) {
        onChanged(value);
      }
    },
    style: GoogleFonts.poppins(),
    enabled: enabled,
    decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        focusColor: Colors.blue,
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: leading,
        suffixIcon: trailing,
        border: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(10))),
  );
}

Widget customButton(
    {required String text,
    required Function onTap,
    Color bgColor = Colors.blue,
    Color fgColor = Colors.white,
    FontWeight fontWeight = FontWeight.bold,
    double fontSize = 15,
    double height = 50,
    double width = 600,
    bool loader = false,
    double borderRadius = 100}) {
  return SizedBox(
    width: width,
    child: ElevatedButton(
      onPressed: () => onTap(),
      style: ElevatedButton.styleFrom(
        foregroundColor: fgColor,
        backgroundColor: bgColor,
        shadowColor: Colors.grey.shade800,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size.fromHeight(height),
      ),
      child: loader
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : Text(
              text,
              style: GoogleFonts.poppins(
                  fontSize: fontSize, fontWeight: fontWeight),
            ),
    ),
  );
}

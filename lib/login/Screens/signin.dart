import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stream_share/Widget/widgets.dart';
import 'package:stream_share/globals/globals.dart';
import 'package:stream_share/login/Auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  static String varId = "";

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool loading = false;
  @override
  void initState() {
    super.initState();
    requestPermission();
    configureLocationServices(context);
  }

  void setData(String varId) {
    setState(() {
      SignIn.varId = varId;
    });
  }

  void loader(bool load) {
    setState(() {
      loading = load;
    });
  }

  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign In"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("Assets/Images/icon.png"),
                  Text(
                    "Stream Share",
                    style: GoogleFonts.styleScript(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
              customTextfield(
                  controller: phoneController,
                  leading: const Icon(Icons.phone),
                  type: TextInputType.phone,
                  label: "+91 00000000000"),
              const SizedBox(height: 30.0),
              customButton(
                  onTap: () => Auth.verifyPhoneNumber(
                      "+91${phoneController.text.trim()}",
                      context,
                      setData,
                      loader),
                  height: 60,
                  loader: loading,
                  text: 'Send Otp',
                  bgColor: Colors.black,
                  borderRadius: 10),
            ],
          ),
        ));
    //
  }
}

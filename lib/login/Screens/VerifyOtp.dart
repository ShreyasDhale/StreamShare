import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:stream_share/Widget/widgets.dart';
import 'package:stream_share/login/Auth.dart';
import 'package:stream_share/login/Screens/signin.dart';

class VerifyOtp extends StatefulWidget {
  final String phoneNumber;
  const VerifyOtp({super.key, required this.phoneNumber});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final pinController = TextEditingController();
  String smsCode = "";
  final focusNode = FocusNode();
  late Timer timer;
  bool wait = false;
  bool isLoading = false;
  int start = 29;

  @override
  void initState() {
    super.initState();
    init();
    startTimer();
  }

  @override
  void dispose() {
    if (timer.isActive) {
      timer.cancel();
    }
    super.dispose();
  }

  void startTimer() {
    const onsec = Duration(seconds: 1);
    timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        timer.cancel();
        wait = false;
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  void setData(String varId) {
    setState(() {
      SignIn.varId = varId;
    });
  }

  void load(bool loader) {
    setState(() {
      isLoading = loader;
    });
  }

  void init() {
    timer = Timer(Duration.zero, () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Otp"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(child: Image.asset("Assets/Images/icon.png")),
            otpField(),
            Row(
              children: [
                Text(
                  "Didn't Recieve an OTP ?",
                  style: GoogleFonts.poppins(),
                ),
                (start == 0)
                    ? TextButton(
                        onPressed: () async {
                          await Auth.resendOtp(
                              widget.phoneNumber, context, setData, load);
                          setState(() {
                            start = 20;
                          });
                          startTimer();
                        },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ))
                            : Text(
                                "Resend",
                                style: GoogleFonts.poppins(),
                              ))
                    : TextButton(
                        onPressed: null,
                        child: Text("Resend in $start",
                            style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            customButton(
                text: "Verify Otp",
                onTap: () => Auth.signInWithPhoneNo(
                    SignIn.varId, smsCode, context, widget.phoneNumber),
                bgColor: Colors.black,
                borderRadius: 10,
                height: 60),
            Row(
              children: [
                TextButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const SignIn()),
                        (route) => false),
                    child: Text(
                      "Change Phone Number ?",
                      style: GoogleFonts.poppins(color: Colors.black),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget otpField() {
    return Pinput(
      length: 6,
      controller: pinController,
      focusNode: focusNode,
      androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
      listenForMultipleSmsOnAndroid: true,

      // onClipboardFound: (value) {
      //   debugPrint('onClipboardFound: $value');
      //   pinController.setText(value);
      // },
      onCompleted: (pin) {
        debugPrint('onCompleted: $pin');
        setState(() {
          smsCode = pin;
        });
      },
      onChanged: (value) {
        debugPrint('onChanged: $value');
      },
      validator: (value) {
        return value == smsCode ? null : 'Pin is incorrect';
      },
      cursor: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 9),
            width: 22,
            height: 1,
          ),
        ],
      ),
    );
  }
}

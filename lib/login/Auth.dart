import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stream_share/Screens/Home.dart';
import 'package:stream_share/globals/Constants.dart';
import 'package:stream_share/globals/Message.dart';
import 'package:stream_share/login/Screens/VerifyOtp.dart';

class Auth {
  Auth();
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");

  Future<bool> userExists(String phoneNumber) async {
    QuerySnapshot snapshot =
        await users.where("Phone", isEqualTo: phoneNumber).get();
    if (snapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> verifyPhoneNumber(String phoneNumber,
      BuildContext context, Function setData, Function loader) async {
    loader(true);
    verificationCompleted(phoneAuthCredential) {
      showSuccessSnackBar(context, "Verification Compleated");
      loader(false);
    }

    verificationFailed(error) {
      showFailureSnackBar(
          context, "Verification Faild with error : ${error.code}");
      print("******************************************** ${error.toString()}");
      loader(false);
    }

    codeSent(verificationId, forceResendingToken) {
      showSuccessSnackBar(context, "Code Sent");
      setData(verificationId);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => VerifyOtp(
                    phoneNumber: phoneNumber,
                  )),
          (route) => false);
      loader(false);
    }

    codeAutoRetrievalTimeout(verificationId) {
      // showFailureSnackBar(context, "Code Auto Retrival Timeout");
    }

    try {
      FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(e.message);
      debugPrint(stackTrace.toString());
      showFailureSnackBar(context, e.message.toString());
      loader(false);
    }
  }

  static Future<void> resendOtp(String phoneNumber, BuildContext context,
      Function setData, Function loader) async {
    loader(true);
    verificationCompleted(phoneAuthCredential) {
      showSuccessSnackBar(context, "Verification Compleated");
      loader(false);
    }

    verificationFailed(error) {
      showFailureSnackBar(
          context, "Verification Faild with error : ${error.code}");
      print("******************************************** ${error.toString()}");
      loader(false);
    }

    codeSent(verificationId, forceResendingToken) {
      showSuccessSnackBar(context, "Code Sent");
      setData(verificationId);
      loader(false);
    }

    codeAutoRetrievalTimeout(verificationId) {
      // showFailureSnackBar(context, "Code Auto Retrival Timeout");
    }

    try {
      FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(e.message);
      debugPrint(stackTrace.toString());
      showFailureSnackBar(context, e.message.toString());
      loader(false);
    }
  }

  static void signInWithPhoneNo(String verificationId, String smsCode,
      BuildContext context, String phoneNumber) async {
    try {
      Auth auth = Auth();
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      String? token = await FirebaseMessaging.instance.getToken();
      await auth.auth.signInWithCredential(credential);
      await auth.userExists(phoneNumber)
          ? null
          : auth.users.add({
              "Bio": "",
              "UserId": "",
              "Phone": phoneNumber,
              "profilePicUrl": "",
              "Name": "",
              "Token": (token != null) ? token : "",
            }).then(
              (value) => auth.users.doc(value.id).update({"UserId": value.id}));
      currentUser = FirebaseAuth.instance.currentUser;
      showSuccessSnackBar(context, "User Logedin SuccessFully");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    } on FirebaseAuthException catch (e, stackTrace) {
      showFailureSnackBar(context, e.code);
      debugPrint(stackTrace.toString());
    }
  }
}

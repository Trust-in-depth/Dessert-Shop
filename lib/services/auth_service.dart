import 'package:ders7flutterproject/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => MyApp()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == "email-already-in-use") {
        message = "The account already exists for that email.";
      } else if (e.code == "weak-password") {
        message = "The password provided is too weak.";
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // Handle errors
    } catch (e) {
      print(e);
    }
    // Implement signup logic with Firebase Authentication
  }
}

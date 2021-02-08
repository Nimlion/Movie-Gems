import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import 'colors.dart';

class FirebaseAuthentication {
  FirebaseAuth auth = FirebaseAuth.instance;
  UserCredential _userCredential;

  UserCredential get userCredential => _userCredential;

  FirebaseAuthentication() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  Future<bool> emailSignIn(String email, String password) async {
    try {
      this._userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print("succesful");
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return false;
    }
  }

  Future<void> anonymouslySignIn() async {
    this._userCredential = await FirebaseAuth.instance.signInAnonymously();

    User user = FirebaseAuth.instance.currentUser;
    print(user);
  }

  Future<bool> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      showSimpleNotification(Text("No account found for given email address."),
          background: Colours.error);
      return false;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      this._userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = FirebaseAuth.instance.currentUser;
      print(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSimpleNotification(Text("The password provided is too weak."),
            background: Colours.error);
      } else if (e.code == 'email-already-in-use') {
        showSimpleNotification(
            Text("The account already exists for that email."),
            background: Colours.error);
      }
    } catch (e) {
      print(e);
      showSimpleNotification(
          Text("Something went wrong while trying to register."),
          background: Colours.error);
    }
  }

  Future<bool> checkForUser() async {
    if (await FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> emailVerifiedCheck() async {
    User user = FirebaseAuth.instance.currentUser;

    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    User user = FirebaseAuth.instance.currentUser;
    print(user);
  }
}

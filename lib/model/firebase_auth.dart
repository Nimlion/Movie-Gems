import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/model/repository.dart';
import 'package:overlay_support/overlay_support.dart';

import 'colours.dart';

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
      Repo.watchlistDoc = FirebaseFirestore.instance
          .collection('watchlist')
          .doc(FirebaseAuthentication().auth.currentUser.uid);
      Repo.seriesDoc = FirebaseFirestore.instance
          .collection("series")
          .doc(FirebaseAuthentication().auth.currentUser.uid);
      Repo.moviesDoc = FirebaseFirestore.instance
          .collection("movies")
          .doc(FirebaseAuthentication().auth.currentUser.uid);
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

  Future updateEmail(String newEmail) async {
    try {
      if (newEmail == FirebaseAuth.instance.currentUser.email ||
          newEmail == null) {
        showSimpleNotification(Text("Email is your current email."),
            background: Colours.error);
        return null;
      }
      User firebaseUser = FirebaseAuth.instance.currentUser;
      await firebaseUser
          .updateEmail(newEmail)
          .catchError((onError) => print(onError));
      showSimpleNotification(Text("Email has been updated."),
          background: Colours.primaryColor);
    } catch (e) {
      showSimpleNotification(
          Text("Something went wrong, please try again later"),
          background: Colours.error);
    }
  }

  Future<void> anonymouslySignIn() async {
    this._userCredential = await FirebaseAuth.instance.signInAnonymously();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      this._userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      Repo.watchlistDoc = FirebaseFirestore.instance
          .collection('watchlist')
          .doc(FirebaseAuthentication().auth.currentUser.uid);
      Repo.seriesDoc = FirebaseFirestore.instance
          .collection("series")
          .doc(FirebaseAuthentication().auth.currentUser.uid);
      Repo.moviesDoc = FirebaseFirestore.instance
          .collection("movies")
          .doc(FirebaseAuthentication().auth.currentUser.uid);
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
    // ignore: await_only_futures
    if (await FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> emailVerifiedCheck() async {
    User user = FirebaseAuth.instance.currentUser;

    try {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Repo.movieList.clear();
    Repo.movieListenable.value.clear();
  }

  Future<void> deleteAccount() async {
    try {
      // ignore: await_only_futures
      User user = await FirebaseAuth.instance.currentUser;
      // Delete all data from the user
      await Repo.moviesDoc
          .set({"status": "account deleted"})
          .then((value) => print("movies deleted"))
          .catchError((e) => print(e));
      await Repo.seriesDoc
          .set({"status": "account deleted"})
          .then((value) => print("series deleted"))
          .catchError((e) => print(e));
      await Repo.watchlistDoc
          .set({"status": "account deleted"})
          .then((value) => print("watchlist deleted"))
          .catchError((e) => print(e));
      await user.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> deleteAnonymousAccount() async {
    await Repo.moviesDoc
        .set({"status": "account deleted"})
        .then((value) => print("movies deleted"))
        .catchError((e) => print(e));
    await Repo.seriesDoc
        .set({"status": "account deleted"})
        .then((value) => print("series deleted"))
        .catchError((e) => print(e));
    await Repo.watchlistDoc
        .set({"status": "account deleted"})
        .then((value) => print("watchlist deleted"))
        .catchError((e) => print(e));
    await FirebaseAuth.instance.currentUser.delete();
  }
}

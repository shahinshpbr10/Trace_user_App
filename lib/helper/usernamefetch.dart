import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService with ChangeNotifier {
  String _userName = "Guest"; // Default name if not found
  String get userName => _userName;

  // Function to fetch the user name
  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("bus_passenger")
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          _userName = userDoc["name"] ?? "Guest";
          notifyListeners(); // Update UI if using Provider
        }
      } catch (e) {
        print("Error fetching user name: $e");
      }
    }
  }
}

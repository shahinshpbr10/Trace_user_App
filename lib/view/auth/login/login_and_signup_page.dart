import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tracebusapp/view/bottomnavbar/bottomnavbar.dart';

class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  bool referralcode = false;
  String ccode = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController1 = TextEditingController();
  TextEditingController passwordController1 = TextEditingController();

  List<String> lottie12 = [
    "assets/lottie/slider1.json",
    "assets/lottie/slider2.json",
    "assets/lottie/slider3.json",
    "assets/lottie/slider4.json",
  ];

  List<String> title = [
    "Your Journey, Your Way",
    "Seamless Travel Simplified",
    "Book, Ride, Enjoy",
    "Explore, One Bus at a Time"
  ];

  List<String> description = [
    'Customize your travel effortlessly.',
    'Easy booking and boarding for a stress-free journey.',
    'Swift booking and delightful bus rides.',
    'Discover new places, one bus ride after another.',
  ];

  // **LOGIN WITH FIREBASE**
  Future<void> loginWithFirebase(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(
          msg: "Email and Password cannot be empty.",
          backgroundColor: Colors.red,
        );
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      Fluttertoast.showToast(
        msg: "Login successful!",
        backgroundColor: Colors.green,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Bottom_Navigation()), // Replace with your actual home screen
            (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed";

      print("Firebase Login Error Code: ${e.code}");

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found for this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password. Please try again.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format.";
          break;
        case 'user-disabled':
          errorMessage = "This user account has been disabled.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many failed attempts. Try again later.";
          break;
        default:
          errorMessage = e.message ?? "An unknown error occurred.";
      }

      Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.red);
    } catch (e) {
      print("Unexpected Login Error: $e");
      Fluttertoast.showToast(msg: "An unexpected error occurred", backgroundColor: Colors.red);
    }
  }

  // **SIGNUP WITH FIREBASE & SAVE TO FIRESTORE COLLECTION**
  Future<void> signUpWithFirebase(String name, String email, String phone, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection("bus_passengers").doc(userCredential.user!.uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "created_at": DateTime.now(),
      });

      Fluttertoast.showToast(msg: "Signup successful!", backgroundColor: Colors.green);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Bottom_Navigation()), // Replace with your actual home screen
            (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? "Signup failed", backgroundColor: Colors.red);
    }
  }

  // **RESET PASSWORD WITH FIREBASE**
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(msg: "Password reset email sent!", backgroundColor: Colors.green);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}", backgroundColor: Colors.red);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.4)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome To Trace',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text('Signin with your E-mail.'),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Your Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Enter Your Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          loginWithFirebase(emailController.text, passwordController.text);
                        },
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: InkWell(
                        onTap: () {
                          resetPassword(emailController.text);
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text("Create your Account",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Enter Your Name',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Enter Your Email',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    IntlPhoneField(
                                      controller: mobileController1,
                                      decoration: InputDecoration(
                                        hintText: 'Phone Number',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.grey.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blue),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: passwordController1,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Enter Your Password',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        signUpWithFirebase(
                                          nameController.text,
                                          emailController.text,
                                          mobileController1.text,
                                          passwordController1.text,
                                        );
                                      },
                                      child: const Text('SIGN UP'),
                                    ),

                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const Text(
                          "Don't Have an Account? Sign Up",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Image(
              image: AssetImage('assets/logo.png'),
              height: 70,
              width: 70,
            ),
            const Text(
              'Trace',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            CarouselSlider(
              items: [
                for (int i = 0; i < lottie12.length; i++)
                  Column(
                    children: [
                      Lottie.asset(lottie12[i], height: 200),
                      const SizedBox(height: 30),
                      Text(
                        title[i],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 2,
                        width: 70,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        description[i],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
              ],
              options: CarouselOptions(
                height: 345,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

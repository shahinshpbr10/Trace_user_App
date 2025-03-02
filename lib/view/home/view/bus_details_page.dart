import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot bus;

  const BusDetailsPage({super.key, required this.bus});

  @override
  State<BusDetailsPage> createState() => _BusDetailsPageState();
}

class _BusDetailsPageState extends State<BusDetailsPage> {
  String? selectedStop;
  int selectedFare = 0;
  int passengerCount = 1; // Default to 1 passenger
  String userPhone = "N/A";
  String userEmail = "N/A";
  String userName = "N/A";
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    _fetchUserDetails();
  }

  // ✅ Initialize Razorpay
  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ✅ Fetch User Phone, Email, Name from Firestore
  Future<void> _fetchUserDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("bus_passengers")
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc["name"] ?? "N/A";
            userPhone = userDoc["phone"] ?? "N/A";
            userEmail = userDoc["email"] ?? "N/A";
          });
        }
      } catch (e) {
        print("🔥 Error fetching user details: $e");
      }
    }
  }

  // ✅ Handle Successful Payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    int totalAmountPaid = selectedFare * passengerCount;
    String userId = FirebaseAuth.instance.currentUser!.uid; // ✅ Fetch User UID

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Payment Successful: ${response.paymentId}"), backgroundColor: Colors.green),
    );

    // 🔹 Update Firestore Passenger Count and Revenue
    FirebaseFirestore.instance
        .collection("admins")
        .doc(widget.bus["ownerId"])
        .collection("buses")
        .doc(widget.bus["busId"])
        .update({
      "passengerCount": FieldValue.increment(passengerCount),
      "revenue": FieldValue.increment(totalAmountPaid),
    });

    // 🔹 Store Payment Record in Bus Passenger's Subcollection
    FirebaseFirestore.instance
        .collection("bus_passengers")
        .doc(userId) // ✅ Store under current user's UID
        .collection("payments")
        .add({
      "uid": userId, // ✅ Save UID of the user
      "name": userName,
      "phone": userPhone,
      "email": userEmail,
      "busId": widget.bus["busId"],
      "busName": widget.bus["name"],
      "routeSelected": selectedStop,
      "farePerPassenger": selectedFare,
      "passengerCount": passengerCount,
      "totalAmountPaid": totalAmountPaid,
      "paymentId": response.paymentId,
      "status": "Success",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }


  // ✅ Handle Payment Failure
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Payment Failed: ${response.message}"), backgroundColor: Colors.red),
    );
  }

  // ✅ Handle External Wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("💳 External Wallet Used: ${response.walletName}"), backgroundColor: Colors.orange),
    );
  }

  // ✅ Initiate Razorpay Payment
  void _makePayment() {
    int totalAmount = selectedFare * passengerCount;

    var options = {
      'key': 'rzp_live_zLLfH4BtsbMiht', // 🔴 Replace with your Razorpay API Key
      'amount': totalAmount * 100, // Razorpay accepts amount in paise (INR * 100)
      'name': 'Bus Ticket Payment',
      'description': 'Payment for ${widget.bus["name"]} - $passengerCount Passenger(s)',
      'prefill': {
        'contact': userPhone, // Fetching from Firestore
        'email': userEmail, // Fetching from Firestore
      },
      'theme': {'color': '#FF4081'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("🔥 Error in Razorpay: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Fix: Ensure "routes" exists before using it
    List<dynamic> routes = (widget.bus.data() as Map<String, dynamic>?)?.containsKey("routes") == true
        ? widget.bus["routes"]
        : [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(widget.bus["name"] ?? "Bus Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚍 Bus Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.bus["imageUrl"].toString().isNotEmpty
                      ? widget.bus["imageUrl"]
                      : 'https://via.placeholder.com/150',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🚌 Bus Details
            Text("Bus Name: ${widget.bus["name"] ?? "Unknown"}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Number Plate: ${widget.bus["numberPlate"] ?? "N/A"}",
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 10),

            // 🔹 Route Selection Dropdown
            Text("Select Your Stop:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            routes.isEmpty
                ? Text("No routes available", style: TextStyle(color: Colors.red, fontSize: 16))
                : DropdownButtonFormField<String>(
              value: selectedStop,
              onChanged: (newValue) {
                setState(() {
                  selectedStop = newValue;
                  selectedFare = routes.firstWhere(
                          (route) => route["stop"] == newValue,
                      orElse: () => {"fare": 0})["fare"];
                });
              },
              items: routes.map<DropdownMenuItem<String>>((route) {
                return DropdownMenuItem<String>(
                  value: route["stop"],
                  child: Text("${route["stop"]} - ₹${route["fare"]}"),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),

            // Passenger Count Selector
            Text("Number of Passengers:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              value: passengerCount.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: "$passengerCount",
              onChanged: (value) {
                setState(() {
                  passengerCount = value.toInt();
                });
              },
            ),
            const SizedBox(height: 20),

            // ✅ Pay Button
            Center(
              child: ElevatedButton(
                onPressed: selectedStop == null || selectedFare == 0 ? null : _makePayment,
                child: const Text("Pay Now", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

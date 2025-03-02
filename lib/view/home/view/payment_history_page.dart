import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  // ✅ Fetch Logged-in User ID
  Future<void> _fetchUserId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userId = currentUser.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
        backgroundColor: Colors.pink,
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator()) // Loading state
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bus_passengers")
            .doc(userId)
            .collection("payments")
            .orderBy("timestamp", descending: true) // Latest transactions first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No payment history found."));
          }

          var payments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              var payment = payments[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.payment, color: Colors.white),
                  ),
                  title: Text(
                    "Bus: ${payment['busName'] ?? 'Unknown'}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Route: ${payment['routeSelected'] ?? 'N/A'}"),
                      Text("Passengers: ${payment['passengerCount']}"),
                      Text("Fare per Passenger: ₹${payment['farePerPassenger']}"),
                      Text("Total Paid: ₹${payment['totalAmountPaid']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      Text("Payment ID: ${payment['paymentId'] ?? 'N/A'}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text("Status: ${payment['status']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: payment['status'] == "Success" ? Colors.green : Colors.red,
                          )),
                    ],
                  ),
                  trailing: Text(
                    _formatDate(payment['timestamp']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Helper function to format date
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}";
  }
}

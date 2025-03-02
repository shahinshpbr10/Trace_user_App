import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bus_details_page.dart'; // Import the new details page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Guest";
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  // ✅ Fetch Logged-in User Name
  Future<void> getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("bus_passenger")
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc["name"] ?? "Guest";
          });
        }
      } catch (e) {
        print("Error fetching user name: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Image(image: AssetImage('assets/logo.png'), height: 60, width: 60),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                userName,
                style: const TextStyle(
                  color: Colors.pink,
                  fontSize: 20,
                  fontFamily: 'SofiaProBold',
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search buses by name or route...",
                prefixIcon: const Icon(Icons.search, color: Colors.pink),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // 🚍 Bus List (Fetched from All Admins' Sub-collections)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("admins").snapshots(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!adminSnapshot.hasData || adminSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No buses available"));
                }

                List<QueryDocumentSnapshot> admins = adminSnapshot.data!.docs;
                List<Stream<QuerySnapshot>> busStreams = [];

                for (var admin in admins) {
                  busStreams.add(FirebaseFirestore.instance
                      .collection("admins")
                      .doc(admin.id)
                      .collection("buses")
                      .snapshots());
                }

                return StreamBuilder<List<QuerySnapshot>>(
                  stream: combineStreams(busStreams),
                  builder: (context, busSnapshot) {
                    if (busSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<QueryDocumentSnapshot> busDocs = [];
                    for (var busData in busSnapshot.data ?? []) {
                      busDocs.addAll(busData.docs);
                    }

                    if (busDocs.isEmpty) {
                      return const Center(child: Text("No buses available"));
                    }

                    var filteredBuses = busDocs.where((bus) {
                      String busName = bus["name"].toString().toLowerCase();
                      String busRoute = _getFormattedRoutes(bus["routes"]);
                      return busName.contains(searchQuery) || busRoute.contains(searchQuery);
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredBuses.length,
                      itemBuilder: (context, index) {
                        var bus = filteredBuses[index];
                        return _buildBusCard(bus);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Function to Merge Multiple Firestore Streams
  Stream<List<QuerySnapshot>> combineStreams(List<Stream<QuerySnapshot>> streams) {
    return Stream.fromIterable(streams).asyncMap((stream) => stream.first).toList().asStream();
  }

  // ✅ Helper to Format Routes
  String _getFormattedRoutes(dynamic routes) {
    if (routes is List) {
      return routes.map((route) => route["stop"] ?? "").join(" → ");
    }
    return "Unknown Route";
  }

  // ✅ Bus Card UI
  Widget _buildBusCard(QueryDocumentSnapshot bus) {
    String busImageUrl = bus["imageUrl"].toString().isNotEmpty
        ? bus["imageUrl"]
        : 'https://via.placeholder.com/150';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            busImageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          bus["name"] ?? "Unknown Bus",
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Number Plate: ${bus["numberPlate"] ?? "N/A"}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 3),
              Text(
                "Route: ${_getFormattedRoutes(bus["routes"])}",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.directions_bus, color: Colors.pink),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusDetailsPage(bus: bus),
            ),
          );
        },
      ),
    );
  }
}

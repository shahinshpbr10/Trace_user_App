// ignore_for_file: unnecessary_import, prefer_collection_literals

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:syncfusion_flutter_maps/maps.dart';

class HomeController extends GetxController implements GetxService {
  int selectpage = 0;
  int selectpage1 = 0;

  List<MapMarker> markers = [];

  setselectpage(int value) {
    selectpage = value;
    update();
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  getmarkers({required double lat, required double long}) async {
    final Uint8List markIcon = await getImages("assets/Group 427320330.png", 80);

    markers.add(MapMarker(
      latitude: lat,
      longitude: long,
      child: Image.memory(markIcon, width: 40, height: 40), // Marker Icon
    ));

    update();
  }
}

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(
        builder: (controller) {
          return SfMaps(
            layers: [
              MapTileLayer(
                initialFocalLatLng: MapLatLng(37.7749, -122.4194), // Default location
                initialZoomLevel: 10,
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                markerBuilder: (BuildContext context, int index) {
                  return controller.markers[index];
                },

              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.getmarkers(lat: 37.7749, long: -122.4194);
        },
        child: Icon(Icons.add_location),
      ),
    );
  }
}

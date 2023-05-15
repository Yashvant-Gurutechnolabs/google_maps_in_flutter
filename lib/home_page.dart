import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_in_flutter/custom_marker.dart';
import 'src/locations.dart' as locations;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double _intialZoom = 2.0;
  final LatLng _intialCenter = const LatLng(0, 0);

  bool _isLoading = false;

  final Completer<GoogleMapController> mapController = Completer();
  final Map<String, Marker> _markers = {};
  locations.Locations? googleOffices;

  void _onMapCreated(GoogleMapController controller) => mapController.complete(controller);

  Future<void> _focusTo({required LatLng center, double zoom = 16.0}) async {
    final controller = await mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: center, zoom: zoom)),
    );
  }

  void _progressStart([bool notifie = true]) {
    if (notifie) {
      setState(() => _isLoading = true);
    } else {
      _isLoading = true;
    }
  }

  void _progressEnd([bool notifie = true]) {
    if (notifie) {
      setState(() => _isLoading = false);
    } else {
      _isLoading = false;
    }
  }

  Future<void> _onFindFriendInMap() async {
    var customMarkerIcon = await CustomMarker().loadCustomMarker();

    //  await BitmapDescriptor.fromAssetImage(
    //   const ImageConfiguration(
    //     size: Size(100, 100),
    //   ),
    //   'assets/your_marker_image.png',
    // );
    _progressStart();

    googleOffices ??= await locations.getGoogleOffices();

    if (googleOffices == null || googleOffices!.offices.isEmpty) {
      _progressEnd();
      return;
    }

    _markers.clear();
    for (var i = 0; i < googleOffices!.offices.length; i++) {
      var office = googleOffices!.offices[i];
      final marker = Marker(
        markerId: MarkerId(office.name),
        position: LatLng(office.lat, office.lng),
        infoWindow: InfoWindow(title: office.name, snippet: office.address),
        icon: customMarkerIcon,
        anchor: const Offset(0.5, 0.5),
      );
      _markers[office.name] = marker;
    }

    if (googleOffices!.offices.isNotEmpty) {
      int randomOfficeIndex = Random().nextInt(googleOffices!.offices.length - 1);
      await _focusTo(
        center: LatLng(googleOffices!.offices[randomOfficeIndex].lat, googleOffices!.offices[randomOfficeIndex].lng),
        zoom: 16,
      );
      _progressEnd();
    } else {
      _progressEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Center(
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _intialCenter, zoom: _intialZoom),
          markers: _markers.values.toSet(),
          mapType: MapType.normal,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _onFindFriendInMap,
        label: Row(
          children: [
            const Text('Find Friends'),
            if (_isLoading) ...[
              const SizedBox(width: 15),
              const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ],
        ),
      ),
    );
  }
}

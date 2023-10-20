import 'package:manager_res/export.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(19.0274, 99.9246),
    zoom: 19,
  );
  Location location = Location();
  final Completer<GoogleMapController> _controller = Completer();

  Future<void> getLocationFromFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final document =
          await firestore.collection("RestaurantApp").doc('location').get();

      if (document.exists) {
        final data = document.data() as Map<String, dynamic>;
        final latitude = data['latitude'] as double;
        final longitude = data['longitude'] as double;

        final newPosition = CameraPosition(
          bearing: 180.8334901395799,
          target: LatLng(latitude, longitude),
          tilt: 20.440717697143555,
          zoom: 19,
        );

        setState(() {
          initialCameraPosition = newPosition;
        });
      }
    } catch (e) {
      print("Error getting location from Firestore: $e");
    }
  }

  @override
  void initState() {
    getLocationFromFirestore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 250,
          child: GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.hybrid,
            initialCameraPosition: initialCameraPosition,
            markers: {
              Marker(
                markerId: const MarkerId('source'),
                position: initialCameraPosition.target,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            cameraTargetBounds: CameraTargetBounds(LatLngBounds(
              northeast: initialCameraPosition.target,
              southwest: initialCameraPosition.target,
            )),
          ),
        ),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    Location location = Location();
    var locationData = await location.getLocation();
    print(locationData);
    final GoogleMapController controller = await _controller.future;
    final newPosition = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(locationData.latitude!, locationData.longitude!),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }
}

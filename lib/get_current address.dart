import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CurrentAddressPage extends StatefulWidget {
  const CurrentAddressPage({Key? key}) : super(key: key);

  @override
  State<CurrentAddressPage> createState() => _CurrentAddressPageState();
}

class _CurrentAddressPageState extends State<CurrentAddressPage> {

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  var initPos = CameraPosition(target: LatLng(19.228825, 72.854118),zoom: 15);

  @override
  void initState() {
    super.initState();
    checkBeforeGettingLocation();
  }

  LatLng? myLoc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maps"),
      ),
      body: GoogleMap(
        initialCameraPosition: initPos,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          Marker(
              infoWindow: InfoWindow(
                  title: "My Location"
              ),
              markerId: MarkerId('3'),
              position: myLoc ?? LatLng(28.6563, 77.2321),
              onTap: (){
                print('Tapped on Marker3...');
              }
          ),
        },
        circles: {
          Circle(
            circleId: CircleId("Home Circle"),
            center: myLoc ?? LatLng(28.6563, 77.2321),
            fillColor: Colors.blue.withOpacity(0.3),
            strokeWidth: 1,
            radius: 50
          )
        },
        mapType: MapType.hybrid,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onTap: (location){
          print("location : ${location.latitude} , ${location.longitude}");
        },
      ),
    );
  }

  void checkBeforeGettingLocation()async{
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
      Text("please enale Location Services")));
    }else{
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
          Text('please allow app to request your current location')));
        }else if(permission == LocationPermission.deniedForever){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
          Text('please allow app to request your current location,therefore '
              'you want e able to access this particular features')));
        }else{
          //permission granted
          getContinuousLocation();
        }
      }else{
        /// permission already given
        getContinuousLocation();
      }
    }
  }

  void getCurrentLocation()async{
    var pos = await Geolocator.getCurrentPosition();
    print("Location: ${pos.latitude}, ${pos.longitude}");
  }

  void getContinuousLocation(){
    final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10)
    );
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) async {
          print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
          if(position!=null){
            myLoc = LatLng(position.latitude, position.longitude);
            final GoogleMapController controller = await _controller.future;
            setState(() {});
            await controller.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: myLoc!,
                    tilt: 59, // te thodav3D jaisa effect deta hai
                    zoom: 18
                )));
          }

        });
  }

}

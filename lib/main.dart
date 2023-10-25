import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var pos;
  var latitude;
  var longitude;

  @override
  void initState() {
    super.initState();
    checkBeforeGettingLocation();
  }

  @override
  Widget build(BuildContext context) {
    if(pos==null){
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    var initPos = CameraPosition(target: LatLng(latitude, longitude),zoom: 15);
    return Scaffold(
      appBar: AppBar(
        title: Text("Maps"),
      ),
      body: GoogleMap(
          initialCameraPosition: initPos,
          markers: {
            Marker(
                infoWindow: InfoWindow(
                  title: "Market"
                ),
                markerId: MarkerId('1'),
                position: LatLng(26.194739, 78.141850),
                onTap: (){
                  print('Tapped on Marker1...');
                }
            ),
            Marker(
                infoWindow: InfoWindow(
                    title: "Delhi"
                ),
                markerId: MarkerId('2'),
                position: LatLng(28.6563, 77.2321),
                onTap: (){
                  print('Tapped on Marker2...');
                }
            ),
            Marker(
                infoWindow: InfoWindow(
                    title: "My Location"
                ),
                markerId: MarkerId('3'),
                position: LatLng(latitude , longitude),
                onTap: (){
                  print('Tapped on Marker3...');
                }
            ),
          },
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
          getCurrentLocation();
        }
      }else{
        /// permission already given
        getCurrentLocation();
      }
    }
  }

  void getCurrentLocation()async{
    pos = await Geolocator.getCurrentPosition();
    print("Location: ${pos.latitude}, ${pos.longitude}");
    latitude = pos.latitude;
    longitude = pos.longitude;
    setState(() {

    });
  }

  void getContinuousLocation(){
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10)
    );
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) {
          print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
        });
  }

}



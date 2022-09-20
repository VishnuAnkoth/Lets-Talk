

import 'package:flutter/material.dart';
import 'package:p_lets_talk/service/auth_service.dart';
import 'dart:async';
import 'auth/login_page.dart';
import 'home_page.dart';



import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:p_lets_talk/pages/search_page.dart';

import '../widgets/widgets.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({Key? key}) : super(key: key);

  @override
  _MyLocationState createState() => _MyLocationState();
}


class _MyLocationState extends State<ConnectPage> {
  late LocationData  _currentPosition;
  late String _address,_dateTime;
  late GoogleMapController mapController;
  late Marker marker;
  Location location = Location();
 late String? uid =FirebaseAuth.instance.currentUser!.uid;

  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  late GoogleMapController _controller;
  LatLng _initialcameraposition = LatLng(10.55404, 76.22198);

  AuthService authService = AuthService();
  String userName = "";
  Future savingUserData( double latitude,double longitude ) async {
    return await userCollection.doc(uid).set({

      "latitude":latitude,
      "longitude":longitude
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();

  }

  void _onMapCreated(GoogleMapController _cntlr)
  {
    _controller = _controller;
    location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!),zoom: 25),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, const SearchPage());
              },
              icon: const Icon(Icons.search))
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Let's Talk",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () async {
                authService.signOut().whenComplete(() {
                  nextScreenReplace(context, const HomePage());
                });
              },
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            /////////////////////////////////////////////////////////////////////////////////////////////////////////
            ListTile(
              onTap: () async {
                authService.signOut().whenComplete(() {
                  nextScreenReplace(context, const ConnectPage());
                });
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.location_pin),
              title: const Text(
                "Locate Friends",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////
            ListTile(
              onTap: () async {
                authService.signOut().whenComplete(() {
                  nextScreenReplace(context, const LoginPage());
                });
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: Container(
          decoration: const BoxDecoration(
          image:  DecorationImage(
          image: AssetImage(
            'assets/bg.jpg'),
            fit: BoxFit.fill,
          ),
          ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Container(
            color: Colors.blueGrey.withOpacity(.8),
            child: Center(
              child: Column(
                children: [
                  Container(
                    height:  MediaQuery.of(context).size.height/2.5,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: _initialcameraposition,
                          zoom: 25),
                      mapType: MapType.normal,
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  if (_dateTime != null)
                    Text(
                      "Date/Time: $_dateTime",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),

                  SizedBox(
                    height: 3,
                  ),
                  if (_currentPosition != null)
                    Text(
                      "Latitude: ${_currentPosition.latitude}, Longitude: ${_currentPosition.longitude}",
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  SizedBox(
                    height: 3,
                  ),
                  if (_address != null)
                    Text(
                      "Address: $_address",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  SizedBox(
                    height: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }


  getLoc() async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    _initialcameraposition = LatLng(_currentPosition.latitude!,_currentPosition.longitude!);
    // await savingUserData(_currentPosition.latitude!,_currentPosition.longitude! );
    location.onLocationChanged.listen((LocationData currentLocation) {
      print("${currentLocation.longitude} : ${currentLocation.longitude}");
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition = LatLng(_currentPosition.latitude!,_currentPosition.longitude!);

        DateTime now = DateTime.now();
        _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);
        _getAddress(_currentPosition.latitude!, _currentPosition.longitude!)
            .then((value) {
          setState(() {
            _address = "${value.first.addressLine}";
          });
        });
      });
    });
  }


  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }

}
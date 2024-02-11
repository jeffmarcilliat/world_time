import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:world_time/services/world_time.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ChooseLocation extends StatefulWidget {

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {

  String? _currentAddress;
  Position? _currentPosition;
  bool currentPositionAddedToList = false;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.lowest)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      print('We have an error in _getCurrentPosition: $e');
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        '${place.locality}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  int counter = 0;

  List<WorldTime> locations = [
    WorldTime(url: 'Europe/Berlin', location: 'Berlin', flag: 'germany.png'),
    WorldTime(url: 'Europe/London', location: 'London', flag: 'uk.png'),
    WorldTime(url: 'Europe/Berlin', location: 'Athens', flag: 'greece.png'),
    WorldTime(url: 'Africa/Cairo', location: 'Cairo', flag: 'egypt.png'),
    WorldTime(url: 'Africa/Nairobi', location: 'Nairobi', flag: 'kenya.png'),
    WorldTime(url: 'America/Chicago', location: 'Chicago', flag: 'usa.png'),
    WorldTime(url: 'America/New_York', location: 'New York', flag: 'usa.png'),
    WorldTime(url: 'Asia/Seoul', location: 'Seoul', flag: 'south_korea.png'),
    WorldTime(url: 'Asia/Jakarta', location: 'Jakarta', flag: 'indonesia.png'),
    WorldTime(url: 'America/Louisville', location: 'Shepherdsville', flag: 'usa.png'),
    WorldTime(url: 'America/Los_Angeles', location: 'Mission Viejo', flag: 'usa.png')
  ];

  List<WorldTime> alphabetizeCities(List<WorldTime> locations) {
    locations.sort((a, b) => a.location.compareTo(b.location));
    return locations;
  }

  void updateTime(index) async {
    WorldTime instance = locations[index];
    await instance.getTime();
    // navigate to home screen
    Navigator.pop(context, {
      'location': instance.location,
      'flag': instance.flag,
      'time': instance.time,
      'isDaytime': instance.isDaytime,
    });
  }

  @override
  void initState() {
    super.initState();
    print('init state function ran');
    alphabetizeCities(locations);
    // addCurrentLocationToList();
  }

  void addCurrentLocationToList() async {
    await _getCurrentPosition();
    await _getAddressFromLatLng(_currentPosition!);
    WorldTime hereWeAre = WorldTime(
        location: _currentAddress.toString() ?? "NULL",
        flag: 'usa.png',
        url: 'America/Los_Angeles');

    locations = [hereWeAre] + locations;
    currentPositionAddedToList = true;
  }

  @override
  Widget build(BuildContext context) {
    print('build function ran');
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('Choose a Location',
        style: TextStyle(
          color: Colors.white
        ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
        child: ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                onTap: () {
                  print('User selected ${locations[index].location}');
                  updateTime(index);
                },
                title: Text(locations[index].location),
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/${locations[index].flag}'),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}

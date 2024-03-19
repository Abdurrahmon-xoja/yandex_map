


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map/features/data/models/address_detail_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../models/app_lat_long.dart';
import '../repository/addres_detail_repo.dart';
import '../service/app_location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapControllerCompleter = Completer<YandexMapController>();
  String addressDetail = "Map Page";
  final AddressDetailRepository repository = AddressDetailRepository();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPermission().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(addressDetail),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchCurrentLocation();
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.data_saver_on),
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) {
              mapControllerCompleter.complete(controller);
            },
            onCameraPositionChanged: (cameraPosition, reason, finished){
              if(finished){
                updateAddressDetail(AppLatLong(lat: cameraPosition.target.latitude, long: cameraPosition.target.longitude));
              }
            },
          ),
          const Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Icon(Icons.location_on, color: Colors.red,size: 40,),),
        ],
      ),
    );
  }

  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    AppLatLong location;
    const defLocation = MoscowLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    updateAddressDetail(location);
    _moveToCurrentLocation(location);
  }

  Future<void> _moveToCurrentLocation(AppLatLong appLatLong,) async {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: appLatLong.lat,
            longitude: appLatLong.long,
          ),
          zoom: 12,
        ),
      ),
    );
  }

  Future<void> updateAddressDetail(AppLatLong latLong) async {
    addressDetail = "...loading";
    setState(() {});
    AddressDetailModel? data = await repository.getAddressDetail(latLong);
    print("------------");
    print(data);
    addressDetail = data!.response!.geoObjectCollection!.featureMember!.isEmpty
        ? "unknowen_place"
        : data.response!.geoObjectCollection!.featureMember![0].geoObject!
        .metaDataProperty!.geocoderMetaData!.address!.formatted.toString();
    setState (() {});
    print (addressDetail);
  }
}

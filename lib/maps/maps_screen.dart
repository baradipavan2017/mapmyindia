import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/maps/search_screen.dart';
import 'package:location/location.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location location = Location();
  late MapmyIndiaMap mapmyIndiaMap;
  late LocationData currentPosition;
  late String _address;
  late MapmyIndiaMapController mapController, _indiaMapController;
  late LatLng latLng_current;
  TextEditingController searchController = TextEditingController();
  bool showWidget = false;
  List<ELocation> _eLocation = [];

  static const String MAP_SDK_KEY = "5a1426de8ae68549ff927927415e15c1";
  static const String REST_API_KEY = "5a1426de8ae68549ff927927415e15c1";
  static const String ATLAS_CLIENT_ID =
      "33OkryzDZsLDMzdrbpcfBSNXLn5XlRr-Hdyk2H3W-UOvYpYQLvfSs1XevQAHGDWZUTLmjRm0mi-alBzXqTS4Ad5_Rkcxr0bq";
  static const String ATLAS_CLIENT_SECRET =
      "lrFxI-iSEg_uWVTVjo8aUhHLqeaWkwbm_0oJGApmGajHooAywQhtBe4i-7aH-SDcI9JKW0aBmS-UrHPiaw2D9lEu4-xP2lkRlVqtcHfulmE=";

  @override
  void initState() {
    MapmyIndiaAccountManager.setMapSDKKey(MAP_SDK_KEY);
    MapmyIndiaAccountManager.setRestAPIKey(REST_API_KEY);
    MapmyIndiaAccountManager.setAtlasClientId(ATLAS_CLIENT_ID);
    MapmyIndiaAccountManager.setAtlasClientSecret(ATLAS_CLIENT_SECRET);
    getloc();
    super.initState();
  }

  getloc() async {
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
      if (_permissionGranted == PermissionStatus.granted) {
        return;
      }
    }

    LocationData position = await location.getLocation();
    currentPosition = position;
    latLng_current = LatLng(position.latitude!, position.longitude!);
  }

  void onMapCreated(controller) async {
    Symbol symbol = await controller.addSymbol(SymbolOptions(
      geometry: latLng_current,
      draggable: false,
    ));
    CameraPosition cameraPosition =
        new CameraPosition(target: latLng_current, zoom: 14);
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {
      _indiaMapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(children: [
        Container(
          height: height,
          width: width,
          child: MapmyIndiaMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(20.5937, 78.9629),
              zoom: 15,
            ),
            onStyleLoadedCallback: () {
              autoSuggestWidget();
            },
            compassEnabled: false,
            onMapCreated: (map){
              mapController =  map;
            },

            zoomGesturesEnabled: true,
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.Tracking,
          ),
        ),
        autoSuggestWidget(),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
              width: MediaQuery.of(context).size.width / 11,
              height: MediaQuery.of(context).size.width / 11,
              margin: EdgeInsets.fromLTRB(0, 0, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      blurRadius: 6,
                      offset: Offset.zero,
                      color: Colors.grey.withOpacity(0.5))
                ],
              ),
              child: FittedBox(
                fit: BoxFit.fill,
                child: Center(
                  child: IconButton(
                      icon: Icon(
                        Icons.gps_fixed_rounded,
                        size: MediaQuery.of(context).size.width / 16,
                      ),
                      onPressed: () {
                        CameraPosition cameraPosition = new CameraPosition(
                            target: latLng_current, zoom: 17);
                        mapController.moveCamera(
                            CameraUpdate.newCameraPosition(cameraPosition));
                      }),
                ),
              )),
        ),
      ]),
    );
  }

  Widget autoSuggestWidget(){
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white),
          margin: EdgeInsets.fromLTRB(30, 50, 10, 20),
          // padding: EdgeInsets.all(10.0),
          height: MediaQuery.of(context).size.height / 17,
          width: MediaQuery.of(context).size.width,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
                hintText: 'Search Place',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                )),
            onChanged: (val) {
              setState(() {
                autoSuggest(val);
              });
            },
            onTap: () {},
          ),
        ),
        _eLocation.length > 0
            ? Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white),
          margin: EdgeInsets.fromLTRB(30, 0, 10, 20),
          height: MediaQuery.of(context).size.height / 3,
          child: ListView.separated(
            padding: EdgeInsets.all(0.0),
            itemCount: _eLocation.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0, horizontal: 15.0),
                title: Text(_eLocation[index].placeName ?? ''),
                subtitle: Text(
                  _eLocation[index].placeAddress ?? "",
                  maxLines: 2,
                ),
                onTap: () {
                  addMarker(_eLocation[index]);
                  print("_______________");
                  print(_eLocation[index].latitude);
                  print(_eLocation[index].longitude);
                  print(_eLocation[index].placeAddress);
                  print("_______________");
                  setState(() {
                    _eLocation = [];
                  });

                },
              );
            },
            separatorBuilder: (context, index) => Divider(),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
          ),
        )
            : Container(),
      ],
    );
  }

  Future<void> addImageIcon(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return mapController.addImage(name, list);
  }

  void addMarker(ELocation eLocation) async {
    await addImageIcon('icon', 'lib/assets/custom-icon.png');
    LatLng latLng = LatLng(
        double.parse(eLocation.latitude!), double.parse(eLocation.longitude!));
    mapController.addSymbol(SymbolOptions(geometry: latLng));

    CameraPosition cameraPosition =
    new CameraPosition(target: latLng, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

  }


  void autoSuggest(String text) async {
    if (text.length > 1) {
      try {
        AutoSuggestResponse? response =
            await MapmyIndiaAutoSuggest(query: text).callAutoSuggest();
        if (response != null) {
          setState(() {
            _eLocation = response.suggestedLocations!;
          });
        }
      } catch (e) {
        print(e.toString());
      }
    } else {
      _eLocation = [];
    }
  }
}

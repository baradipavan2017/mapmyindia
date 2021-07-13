import 'package:flutter/material.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  static const pageName = '/search';
  late MapmyIndiaMapController controller;
  TextEditingController searchController = TextEditingController();
  bool showWidget = false;
  List<ELocation> _eLocation = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
              child: TextField(
                controller: searchController,
                autofocus: true,
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
            SizedBox(height: 5,),
            _eLocation.length > 0
                ? Expanded(child: Container(
                    child: ListView.builder(
                        itemCount: _eLocation.length,
                        itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_eLocation[index].placeName ?? ''),
                        subtitle: Text(_eLocation[index].placeAddress ?? "",
                        maxLines: 2,),
                        onTap: (){
                          addMarker(_eLocation[index]);
                          setState(() {
                            _eLocation=[];
                          });
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ))
                : Container()
          ],
        ),
      ),
    );
  }
  void addMarker(ELocation eLocation) async{
    LatLng latLng = LatLng(double.parse(eLocation.latitude!), double.parse(eLocation.longitude!));
    controller.addSymbol(SymbolOptions(geometry: latLng));
    controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 17));
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

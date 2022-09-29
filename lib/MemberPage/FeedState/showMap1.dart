import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_progress.dart';

class ShowMap1 extends StatefulWidget {
  final InsectModel insectModel;
  const ShowMap1({Key? key, required this.insectModel}) : super(key: key);

  @override
  State<ShowMap1> createState() => _ShowMap1State();
}

class _ShowMap1State extends State<ShowMap1> {
  InsectModel? insectModel;
  List<InsectModel> insectModels = [];
  final Set<Marker> markers = new Set();
  double? lat;
  double? lng;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    insectModel = widget.insectModel;
    convertLatLng();
    loadValueFromAPI();
  }

  void convertLatLng() {
    lat = double.parse(insectModel!.lat);
    lng = double.parse(insectModel!.lng);
  }

  Future<Null> loadValueFromAPI() async {
    String name = "'${insectModel!.name}'";
    String apiGetValues =
        '${MyConstant.domain}/insectFile/getInsectDataWhereName.php?isAdd=true&name=$name';

    await Dio().get(apiGetValues).then((value) {
      //print('value ==> $value');
      if (value.toString() == 'null') {
        // No Data
        print('No Data');
      } else {
        // Have Data
        print('Have Data');
        for (var item in json.decode(value.data)) {
          InsectModel model = InsectModel.fromMap(item);
          setState(() {
            insectModels.add(model);
          });
        }
      }
    });

    print('list = ${insectModels.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(FontAwesomeIcons.arrowLeftLong),
        label: Text(
          "ย้อนกลับ",
          style: GoogleFonts.prompt(),
        ),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(child: buildMap()),
    );
  }


  Set<Marker> getmarkers() {
    for (var item in insectModels) {
      setState(() {
        markers.add(Marker(
            //add first marker
            markerId: MarkerId(item.id),
            position: LatLng(double.parse(item.lat),
                double.parse(item.lng)), //position of marker
            infoWindow: InfoWindow(
              //popup info
              title: item.name,
              snippet: item.date,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), //Icon for Marker
            ));
        //add more markers here
      });
    } //markers to place on map

    return markers;
  }

  /*Set<Marker> setMarker() => <Marker>[
        Marker(
          markerId: MarkerId('id'),
          position: LatLng(lat!, lng!),
          infoWindow: InfoWindow(
              title: 'คุณอยู่ที่นี่', snippet: 'Lat = $lat, lng = $lng'),
        ),
      ].toSet();*/

  String createUrl(String string) {
    /// เอาภาพเดียว
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    String url = '${MyConstant.domain}/insectFile${strings[0]}';

    return url;
  }

  Widget buildMap() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        width: double.infinity,
        height: double.infinity,
        child: lat == null
            ? ShowProgress()
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat!, lng!),
                  zoom: 6,
                ),
                onMapCreated: (controller) {},
                markers: getmarkers(),
              ),
      );

  AppBar buildAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Google Map',
        style: TextStyle(
          color: Colors.black87,
          fontFamily: 'kanit',
          //fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    );
  }
}

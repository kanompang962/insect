import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project001/model/epidemic_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_progress.dart';

class ShowMap2 extends StatefulWidget {
  final EpidemicModel epidemicModel;
  const ShowMap2({Key? key, required this.epidemicModel}) : super(key: key);

  @override
  State<ShowMap2> createState() => _ShowMap2State();
}

class _ShowMap2State extends State<ShowMap2> {
  EpidemicModel? epidemicModel;
  List<EpidemicModel> epidemicModels = [];
  final Set<Marker> markers = new Set();
  double? lat;
  double? lng;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    epidemicModel = widget.epidemicModel;
    convertLatLng();
    loadValueFromAPI();
  }

  void convertLatLng() {
    lat = double.parse(epidemicModel!.lat);
    lng = double.parse(epidemicModel!.long);
  }

  Future<Null> loadValueFromAPI() async {
    String name = "'${epidemicModel!.name}'";
    String apiGetValues =
        '${MyConstant.domain}/insectFile/getInsectLiteWhereName.php?isAdd=true&name=$name';

    await Dio().get(apiGetValues).then((value) {
      //print('value ==> $value');
      if (value.toString() == 'null') {
        // No Data
        print('No Data');
      } else {
        // Have Data
        print('Have Data');
        for (var item in json.decode(value.data)) {
          EpidemicModel model = EpidemicModel.fromMap(item);
          setState(() {
            epidemicModels.add(model);
          });
        }
      }
    });
  
      print('list = ${epidemicModels.length}');
  
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
    for (var item in epidemicModels) {
      setState(() {
        markers.add(Marker(
          //add first marker
          markerId: MarkerId(item.id),
          position: LatLng(double.parse(item.lat),
              double.parse(item.long)), //position of marker
          infoWindow: InfoWindow(
            //popup info
            title: 'Marker Title First ',
            snippet: 'My Custom Subtitle',
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
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
}

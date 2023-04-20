import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_progress.dart';

class ShowMap1 extends StatefulWidget {
  final String id;
  const ShowMap1({Key? key, required this.id}) : super(key: key);

  @override
  State<ShowMap1> createState() => _ShowMap1State();
}

class _ShowMap1State extends State<ShowMap1> {
  String? id;
  InsectModel? insectModel;
  List<InsectModel> insectModels = [];
  final Set<Marker> markers = new Set();
  double? lat;
  double? lng;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadValueFromAPI();
  }

  Future<Null> loadValueFromAPI() async {
    id = widget.id;
    // โหลดข้อมูลแมลงที่เลือก
    print('### id = $id');
    String apiValue =
        '${MyConstant.domain}/insectFile/getInsectDataWhereIDInsect.php?isAdd=true&id=$id';
    try {
      await Dio().get(apiValue).then((value) async {
        if (value.toString() == 'null') {
          // No Value
        } else {
          // Have Value
          for (var item in json.decode(value.data)) {
            insectModel = InsectModel.fromMap(item);
          }
          lat = double.parse(insectModel!.lat);
          lng = double.parse(insectModel!.lng);
          // โหลดข้อมูลที่อยู่แมลงตัวอื่นๆประเภทเดียวกัน
          String apiType =
              '${MyConstant.domain}/insectFile/getInsectDataWhereType.php?isAdd=true&type=${insectModel!.type}';
          await Dio().get(apiType).then((value) {
            if (value.toString() == 'null') {
              // No Data
              print('### No Data');
            } else {
              // Have Data
              for (var item in json.decode(value.data)) {
                InsectModel model = InsectModel.fromMap(item);
                setState(() {
                  insectModels.add(model);
                });
              }

              print('### insectData length ==> ${insectModels.length}');
            }
          });
        }
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(FontAwesomeIcons.chevronLeft),
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

  Widget buildMap() {
    return Container(
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
}

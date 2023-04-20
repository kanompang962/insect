import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project001/model/insectLite_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_progress.dart';

class ShowMap2 extends StatefulWidget {
  final String id;
  const ShowMap2({Key? key, required this.id}) : super(key: key);

  @override
  State<ShowMap2> createState() => _ShowMap2State();
}

class _ShowMap2State extends State<ShowMap2> {
  String? id;
  InsectLiteModel? insectLiteModel;
  final Set<Marker> markers = new Set();
  double? lat;
  double? lng;
  @override
  void initState() {
    super.initState();
    loadValueFromAPI();
  }

  Future<Null> loadValueFromAPI() async {
    id = widget.id;
    String apiGet =
        '${MyConstant.domain}/insectFile/getInsectLiteWhereIDInsect.php?isAdd=true&id=$id';
    try {
      await Dio().get(apiGet).then((value) {
        if (value.toString() == 'null') {
          // No Data
          print('### No Data');
        } else {
          // Have Data
          for (var item in json.decode(value.data)) {
            setState(() {
              insectLiteModel = InsectLiteModel.fromMap(item);
            });
          }
          lat = double.parse(insectLiteModel!.lat);
          lng = double.parse(insectLiteModel!.lng);
          print('### InsectLiteAPI ID  ==> ${insectLiteModel!.id}');
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

  // Future<Marker?> getmarkers() async {
  //   setState(() {
  //     Marker(
  //       //add first marker
  //       markerId: MarkerId(insectLiteModel!.inID),
  //       position: LatLng(double.parse(insectLiteModel!.inLat),
  //           double.parse(insectLiteModel!.inLng)), //position of marker
  //       infoWindow: InfoWindow(
  //         //popup info
  //         title:
  //             'ผู้ให้ข้อมูล: ${insectLiteModel!.usName}\nแมลง: ${insectLiteModel!.inName}',
  //         snippet:
  //             'พบที่ ต.${insectLiteModel!.inCounty} อ.${insectLiteModel!.inDistrict} จ.${insectLiteModel!.inProvince}',
  //       ),
  //       icon: BitmapDescriptor.defaultMarker, //Icon for Marker
  //     );
  //     //add more markers here
  //   });
  // }

  Set<Marker> setMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId(insectLiteModel!.id),
        position: LatLng(lat!, lng!),
        infoWindow: InfoWindow(
          title: 'แมลง: ${insectLiteModel!.name}',
          snippet:
              'พบที่ ต.${insectLiteModel!.county} อ.${insectLiteModel!.district} จ.${insectLiteModel!.province}',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ),
    ].toSet();
  }

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
              markers: setMarker(),
            ),
    );
  }
}

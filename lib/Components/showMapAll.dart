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

class ShowMapAll extends StatefulWidget {
  const ShowMapAll({Key? key}) : super(key: key);

  @override
  State<ShowMapAll> createState() => _ShowMapAllState();
}

class _ShowMapAllState extends State<ShowMapAll> {
  InsectModel? insectModel;
  List<InsectModel> insectModels = [];
  final Set<Marker> markers = new Set();
  double lat = 15.8700;
  double lng = 100.9925;
  @override
  void initState() {
    super.initState();
    loadValueFromAPI();
  }

  Future<Null> loadValueFromAPI() async {
    try {
      // โหลดข้อมูลที่อยู่แมลงตัวอื่นๆ
      String apiType =
          '${MyConstant.domain}/insectFile/getInsectData.php?isAdd=true';
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
      setState(
        () {
          markers.add(
            Marker(
              markerId: MarkerId(item.id),
              position: LatLng(
                double.parse(item.lat),
                double.parse(item.lng),
              ),
              infoWindow: InfoWindow(
                title: item.name,
                snippet: item.date,
              ),
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        },
      );
    }
    return markers;
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
                target: LatLng(lat, lng),
                zoom: 6,
              ),
              onMapCreated: (controller) {},
              markers: getmarkers(),
            ),
    );
  }

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

  // Set<Marker> setMarker() => <Marker>[
  //       Marker(
  //         markerId: MarkerId('id'),
  //         position: LatLng(lat!, lng!),
  //         infoWindow: InfoWindow(
  //             title: 'คุณอยู่ที่นี่', snippet: 'Lat = $lat, lng = $lng'),
  //       ),
  //     ].toSet();

}

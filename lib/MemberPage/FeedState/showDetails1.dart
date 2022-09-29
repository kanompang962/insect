import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';


class ShowDetails1 extends StatefulWidget {
  final InsectModel insectModel;
  const ShowDetails1({Key? key, required this.insectModel}) : super(key: key);

  @override
  State<ShowDetails1> createState() => _ShowDetails1State();
}

class _ShowDetails1State extends State<ShowDetails1> {
  bool? haveData;
  bool load = true;
  InsectModel? insectModel;
  InsectModel? insectModelAPI;
  int currentIndex = 0;
  final PageController controller = PageController();
  List<String> images = [];
  //////////////////////////// map
  List<InsectModel> insectModels = [];
  final Set<Marker> markers = new Set();
  double? lat;
  double? lng;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadValueFromAPI();
    loadLocationInsectAll();
    convertLatLng();
  }

  Future<Null> loadLocationInsectAll() async {
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

  void convertLatLng() {
    lat = double.parse(insectModel!.lat);
    lng = double.parse(insectModel!.lng);
  }

  Future<Null> loadValueFromAPI() async {
    insectModel = widget.insectModel;
    String apiGetInsectWhereId =
        '${MyConstant.domain}/insectFile/getInsectDataWhereIDInsect.php?isAdd=true&id=${insectModel!.id}';

    await Dio().get(apiGetInsectWhereId).then((value) {
      //print('value ==> $value');
      if (value.toString() == 'null') {
        // No Data
        setState(() {
          load = false;
          haveData = false;
        });
      } else {
        load = false;
        haveData = true;
        // Have Data
        for (var item in json.decode(value.data)) {
          insectModelAPI = InsectModel.fromMap(item);
          print(
              '### From API ==>> ${insectModelAPI!.id} ${insectModelAPI!.name}');
          createUrl(insectModelAPI!.img);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppbar(),
      body: load
          ? ShowProgress()
          : haveData!
              ? Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 280,
                            width: double.infinity,
                            child: PageView.builder(
                              controller: controller,
                              onPageChanged: (index) {
                                setState(() {
                                  currentIndex = index % images.length;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  child: SizedBox(
                                    height: 300,
                                    width: double.infinity,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: images[index % images.length],
                                      placeholder: (context, url) =>
                                          ShowProgress(),
                                      errorWidget: (context, url, error) =>
                                          ShowImage(path: MyConstant.image1),
                                    ), /*Image.network(
                            images[index % images.length],
                            fit: BoxFit.cover,
                          ),*/
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < images.length; i++)
                                buildIndicator(currentIndex == i)
                            ],
                          ),
                          buildDetails(size),
                          SizedBox(
                            height: 100,
                          )
                        ],
                      ),
                    ),
                    buildShowMap(size),
                  ],
                )
              : showNoData(),
    );
  }

  

  SlidingUpPanel buildShowMap(double size) {
    return SlidingUpPanel(
      borderRadius: BorderRadius.circular(10),
      panel: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[300],
              ),
              width: size * 0.1,
              height: 5),
          Padding(
            padding:
                const EdgeInsets.only(left: 30, right: 30, bottom: 40, top: 15),
            child: Text(
              'ดูแผนที่',
              style: GoogleFonts.prompt(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          buildMap(size),
        ],
      ),
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

  Widget buildMap(double size) {
    return Container(
      width: size * 1,
      height: size * 0.97,
      child: lat == null
          ? ShowProgress()
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat!, lng!),
                zoom: 8,
              ),
              onMapCreated: (controller) {},
              markers: getmarkers(),
            ),
    );
  }

  Center showNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShowTitle(
              title: 'No Data ', textStyle: MyConstant().h1Style(Colors.black)),
          ShowTitle(
              title: 'Please Add Data',
              textStyle: MyConstant().h2Style(Colors.black)),
        ],
      ),
    );
  }

  Container buildDetails(double size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${insectModelAPI!.name}',
                style: GoogleFonts.prompt(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Text(
            'รายละเอียด:',
            style: GoogleFonts.prompt(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: MyConstant.primary,
            ),
          ),
          //Divider(color: MyConstant.primary, thickness: 3, height: 10),
          Container(
            width: size * 1,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${insectModelAPI!.details}',
              style: GoogleFonts.prompt(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Divider(color: Colors.white, thickness: 0, height: 12),
          Text(
            'วิธีการป้องกันและกำจัด:',
            style: GoogleFonts.prompt(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: Colors.red,
            ),
          ),
          //Divider(color: Colors.red, thickness: 3, height: 10),
          Container(
            width: size * 1,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${insectModelAPI!.protect}',
              style: GoogleFonts.prompt(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Divider(color: Colors.white, thickness: 0, height: 12),
        ],
      ),
    );
  }

  Widget buildIndicator(bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Container(
        height: isSelected ? 12 : 10,
        width: isSelected ? 12 : 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? MyConstant.dark : MyConstant.light,
        ),
      ),
    );
  }

  createUrl(String string) {
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    String url;
    int i = 0;

    for (var item in strings) {
      url = '${MyConstant.domain}/insectFile${strings[i]}';
      //EpidemicModel model = EpidemicModel.fromMap(item)
      setState(() {
        images.add(url);
        //print('### url ==>> ${images[i]}');
        i++;
      });
    }
  }

  AppBar buildAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    );
  }
}

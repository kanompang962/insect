import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project001/model/epidemic_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ShowInsectLite extends StatefulWidget {
  final EpidemicModel epidemicModel;
  const ShowInsectLite({Key? key, required this.epidemicModel})
      : super(key: key);

  @override
  State<ShowInsectLite> createState() => _ShowInsectLiteState();
}

class _ShowInsectLiteState extends State<ShowInsectLite> {
  bool? haveData;
  bool load = true;
  EpidemicModel? epidemicModel;
  EpidemicModel? epidemicModelAPI;
  int currentIndex = 0;
  String? typeUser;
  final PageController controller = PageController();
  List<String> images = [];
  //////////////////////////// map
  List<EpidemicModel> epidemicModels = [];
  final Set<Marker> markers = new Set();
  double? lat;
  double? lng;
  /////////////////////////// edit

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadValueFromAPI();
    loadLocationInsectAll();
    convertLatLng();
  }

  void convertLatLng() {
    lat = double.parse(epidemicModel!.lat);
    lng = double.parse(epidemicModel!.long);
  }

  Future<Null> loadLocationInsectAll() async {
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

  Future<Null> checkTypeUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    typeUser = preferences.getString('type')!;
  }

  Future<Null> loadValueFromAPI() async {
    epidemicModel = widget.epidemicModel;
    String apiGetInsectWhereId =
        '${MyConstant.domain}/insectFile/getInsectLiteWhereIDInsect.php?isAdd=true&id=${epidemicModel!.id}';

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
          epidemicModelAPI = EpidemicModel.fromMap(item);
          print(
              '### From API ==>> ${epidemicModelAPI!.id} ${epidemicModelAPI!.name}');
          createUrl(epidemicModelAPI!.img);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppbar(size),
      //floatingActionButton: buildFloatButtonMap(context),
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
                            child:  PageView.builder(
                              controller: controller,
                              onPageChanged: (index) {
                                setState(() {
                                  currentIndex = index % images.length;
                                });
                              },
                              itemBuilder: (context, index) {
                                return  Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: SizedBox(
                                    height: 300,
                                    width: double.infinity,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: images[index % images.length],
                                      placeholder: (context, url) =>
                                          ShowProgress(),
                                      errorWidget: (context, url, error) =>
                                          ShowImage(path: MyConstant.image),
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
                        ],
                      ),
                    ),
                    buildShowMap(size),
                  ],
                )
              : showNoData(),
    );
  }

  /////////////////Details/////////////////////////////

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

  Widget buildMap(double size) {
    return Container(
      width: size * 0.95,
      height: size * 0.95,
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
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${epidemicModelAPI!.name}',
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
            overflow: TextOverflow.ellipsis,
          ),
          // Divider(color: MyConstant.primary, thickness: 1, height: 10),
          Container(
            width: size * 1,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              '${epidemicModelAPI!.id}',
              style: GoogleFonts.prompt(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              //maxLines: 10,
              //overflow: TextOverflow.ellipsis,
            ),
          ),

          Divider(color: Colors.white, thickness: 0, height: 12),
        ],
      ),
    );
  }

  IconButton buildButtonEdit() {
    return IconButton(
      onPressed: () {
        /* images.clear();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EditInsectLiteMember(epidemicModel: epidemicModel!),
          ),
        ).then((value) {
          loadValueFromAPI();
        });
        //showInsectLiteFormIndex(context);*/
        print('edit');
      },
      icon: Icon(
        Icons.edit,
        color: Colors.white,
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

  AppBar buildAppbar(double size) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      actions: [
        /*IconButton(
          onPressed: () {
            confirmDialogDelete(context);
          },
          icon: Icon(Icons.delete),
        ),*/
        IconButton(
          onPressed: () {
            showBottomSheet(size);
          },
          icon: Icon(FontAwesomeIcons.alignJustify),
        ),
      ],
    );
  }

  Future<void> showBottomSheet(double size) {
    return showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: size * 0.3,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildButtonEditSheet(size),
                buildButtonDeleteSheet(size),
              ],
            ),
          ),
        );
      },
    );
  }

  OutlineButton buildButtonDeleteSheet(double size) {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () async {
        print('## Confirm Delete at id ==> ${epidemicModel!.id}');
        String apiDeleteProductWhereId =
            '${MyConstant.domain}/insectFile/deleteInsectDataWhereID .php?isAdd=true&id=${epidemicModel!.id}';
        await Dio().get(apiDeleteProductWhereId).then((value) {
          Navigator.pop(context);
          loadValueFromAPI();
        });
      },
      child: Container(
        width: size * 0.6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ลบข้อมูล",
              style: GoogleFonts.prompt(
                fontSize: 14,
                //fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineButton buildButtonEditSheet(double size) {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () {
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditInsectData(insectModel: insectModel!),
          ),
        ).then((value) {
          loadValueFromAPI();
          images.clear();
        });*/
      },
      child: Container(
        width: size * 0.6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "แก้ไข",
              style: GoogleFonts.prompt(
                fontSize: 14,
                //fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* void confirmDialogDelete(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (BuildContext bc) {
          return Container(
              //color: Colors.grey[300],
              height: MediaQuery.of(context).size.height * 0.3,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      child: buildImageBin(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      child: buildButtonDelete(),
                    ),
                    Container(
                      width: double.infinity,
                      child: buildButtonCancel(),
                    ),
                  ],
                ),
              ));
        });
  }

  OutlineButton buildButtonCancel() {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("CANCEL",
          style:
              TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.black)),
    );
  }

  OutlineButton buildButtonDelete() {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Text("DELETE",
          style:
              TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.black)),
      onPressed: () async {
        print('## Confirm Delete at id ==> ${insectModel!.id}');
        String apiDeleteProductWhereId =
            '${MyConstant.domain}/insectFile/deleteInsectDataWhereID .php?isAdd=true&id=${insectModel!.id}';
        await Dio().get(apiDeleteProductWhereId).then((value) {
          Navigator.pop(context);
          loadValueFromAPI();
        });
      },
    );
  }

  OutlineButton buildImageBin() {
    return OutlineButton(
        highlightedBorderColor: Colors.grey[300],
        padding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () {},
        child: Image.asset(
          MyConstant.remove,
          scale: 10,
          //color: Colors.lightBlue[300],
        ));
  }*/
}

import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostMember extends StatefulWidget {
  const PostMember({Key? key}) : super(key: key);

  @override
  _PostMemberState createState() => _PostMemberState();
}

class _PostMemberState extends State<PostMember> {
  final formKey = GlobalKey<FormState>();
  List<File?> files = [];
  File? file;
  TextEditingController nameController = TextEditingController();
  //TextEditingController dateController = TextEditingController();
  //TextEditingController timeController = TextEditingController();
  TextEditingController countyController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();
  String? time;
  String? date;

  TextEditingController detailsController = TextEditingController();
  TextEditingController protectController = TextEditingController();
  List<String> paths = [];
  bool load = true;
  double? lat, lng;
  bool flagColor = true;
  String? typeUser;
  String? typeValue;
  //EpidemicModel? epidemicModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialFile();
    checkPermission();
    checkTypeUser();
  }

  void initialFile() {
    for (var i = 0; i < 4; i++) {
      files.add(null);
    }
  }

  Future<Null> checkTypeUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    typeUser = preferences.getString('type')!;
  }

  Future<Null> checkPermission() async {
    bool locationService;
    LocationPermission locationPermission;

    locationService = await Geolocator.isLocationServiceEnabled();
    if (locationService) {
      print('Service Location Open');

      locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.deniedForever) {
          MyDialog().alertLocationService(
              context, 'ไม่อนุญาติแชร์ Location', 'โปรดแชร์ Location');
        } else {
          // Find LatLang
          findLatLng();
        }
      } else {
        if (locationPermission == LocationPermission.deniedForever) {
          MyDialog().alertLocationService(
              context, 'ไม่อนุญาติแชร์ Location', 'โปรดแชร์ Location');
        } else {
          // Find LatLng
          findLatLng();
        }
      }
    } else {
      print('Service Location Close');
      MyDialog().alertLocationService(context, 'Location Service ปิดอยู่ ?',
          'กรุณาเปิด Location Service ด้วยคะ');
    }
  }

  Future<Null> findLatLng() async {
    print('findLatLan ==> Work');
    Position? position = await findPostion();
    setState(() {
      lat = position!.latitude;
      lng = position.longitude;
      print('lat = $lat, lng = $lng');
    });
  }

  Future<Position?> findPostion() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: lat == null
                      ? ShowProgress()
                      : !flagColor
                          ? uiTypeExpert(constraints, size)
                          : uiTypeMember(constraints, size),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container uiTypeMember(BoxConstraints constraints, double size) {
    return Container(
      width: (constraints.maxWidth > 412)
          ? (constraints.maxWidth * 0.6)
          : constraints.maxWidth,
      padding: EdgeInsets.only(
        bottom: 16,
      ),
      child: Column(
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
          ),
          buildIconSelect(size),
          //SizedBox(height: 10,),
          buildImage(constraints),
          Container(
            width: size * 0.7,
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                buildTextName(),

                //buildTextTime(),
                //buildTextDate(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildTextCounty(size),
                    buildButtonDate(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildTextDistrict(size),
                    buildButtonTime(),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildTextProvince(size),
                  ],
                ),

                buildMap(),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.9,
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildButtonCancel(),
                buildButtonSave(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container uiTypeExpert(BoxConstraints constraints, double size) {
    return Container(
      width: (constraints.maxWidth > 412)
          ? (constraints.maxWidth * 0.6)
          : constraints.maxWidth,
      padding: EdgeInsets.only(
        bottom: 16,
      ),
      child: typeUser == "Expert"
          ? Column(
              children: [
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                ),
                buildIconSelect(size),
                //SizedBox(height: 10,),
                buildImage(constraints),
                Container(
                  width: size * 0.7,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      buildTextName(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildButtonTime(),
                            buildButtonDate(),
                          ],
                        ),
                      ),
                      //buildTextTime(),
                      //buildTextDate(),
                      buildTextDetails(),
                      buildTextProtect(),
                      buildRadioJuiceSucker(size),
                      buildRadioLeafFeeder(size),
                      buildRadioStemBorer(size),
                      buildRadioRootFeeder(size),
                      buildMap(),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: size * 0.9,
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildButtonCancel(),
                      buildButtonSave(),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "สำหรับผู้เชี่ยวชาญเท่านั้น (Expert)",
                  style: TextStyle(fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 120, right: 120, bottom: 120, top: 40),
                  child: buildButtonBack(),
                ),
              ],
            ),
    );
  }

  Row buildRadioRootFeeder(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.6,
          child: RadioListTile(
            value: 'root_feeder',
            groupValue: typeValue,
            onChanged: (value) {
              setState(() {
                typeValue = value as String?;
                print('type => $typeValue');
              });
            },
            title: ShowTitle(
              title: 'แมลงศัตรูพืชจำพวกกัดกินราก (root feeder)',
              textStyle: MyConstant().h3Style(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Row buildRadioStemBorer(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.6,
          child: RadioListTile(
            value: 'stem_borer',
            groupValue: typeValue,
            onChanged: (value) {
              setState(() {
                typeValue = value as String?;
                print('type => $typeValue');
              });
            },
            title: ShowTitle(
              title: 'แมลงศัตรูพืชจำพวกกัดกินลำต้น (stem borer)',
              textStyle: MyConstant().h3Style(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Row buildRadioJuiceSucker(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.6,
          child: RadioListTile(
            value: 'juice_sucker',
            groupValue: typeValue,
            onChanged: (value) {
              setState(() {
                typeValue = value as String?;
                print('type => $typeValue');
              });
            },
            title: ShowTitle(
              title:
                  'แมลงศัตรูพืชจำพวกดูดกินน้ำเลี้ยงดอกและยอดอ่อน (juice sucker)',
              textStyle: MyConstant().h3Style(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Row buildRadioLeafFeeder(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.6,
          child: RadioListTile(
            value: 'leaf_feeder',
            groupValue: typeValue,
            onChanged: (value) {
              setState(() {
                typeValue = value as String?;
                print('type => $typeValue');
              });
            },
            title: ShowTitle(
              title: 'แมลงศัตรูพืชจำพวกกัดกินใบ (leaf feeder)',
              textStyle: MyConstant().h3Style(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Padding buildTextProtect() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        maxLines: 6, //or null
        decoration: InputDecoration.collapsed(
          hintText: "วิธีป้องกันและกำจัด",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              new Radius.circular(10),
            ),
          ),
        ),
        controller: protectController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Padding buildTextDetails() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        maxLines: 6, //or null
        decoration: InputDecoration.collapsed(
          hintText: "รายละเอียดของแมลง",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              new Radius.circular(10),
            ),
          ),
        ),
        controller: detailsController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
      ),
    );
  }

  OutlineButton buildButtonTime() {
    return OutlineButton(
      //padding: EdgeInsets.symmetric(horizontal: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () async {
        TimeOfDay? times = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (times == null) return;
        setState(() {
          time = times.format(context).toString();
        });
      },
      child: Container(
        width: 90,
        child: Center(
          child: Text(
            time == null ? "เวลา" : '$time',
            style: GoogleFonts.prompt(
              color: MyConstant.dark,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  OutlineButton buildButtonDate() {
    return OutlineButton(
      //padding: EdgeInsets.symmetric(horizontal: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () async {
        DateTime? dates = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (dates == null) return;
        setState(() {
          date = dates.year.toString() +
              '/' +
              dates.month.toString() +
              '/' +
              dates.day.toString();
        });
      },
      child: Container(
        width: 90,
        child: Center(
          child: Text(
            date == null ? "วันที่" : '$date',
            style: GoogleFonts.prompt(
              color: MyConstant.dark,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  OutlineButton buildButtonBack() {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: () {
        setState(() {
          flagColor = true;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.arrow_back_ios),
          Text("ย้อนกลับ", style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  /* OutlineButton buildButtonSave() {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 110),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Text(
        "SAVE",
        style: GoogleFonts.prompt(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.2,
        ),
      ),
      onPressed: () {
        if (flagColor) {
          processAddProduct();
        } else {
          if (formKey.currentState!.validate()) {
            if (typeValue == null) {
              print('Non Choose Type Value');
              MyDialog().normalDialog(context, 'ยังไม่ได้เลือก ชนิดของ Value',
                  'กรุณา Tap ที่ ชนิดของ Value ที่ต้องการ');
            } else {
              print('Process Insert to Database');
              processAddProduct();
            }
          }
        }
      },
    );
  }*/

  RaisedButton buildButtonSave() {
    return RaisedButton(
      onPressed: () {
        if (flagColor) {
          if (time != null) {
            if (date != null) {
              processAddProduct();
            } else {
              MyDialog().normalDialog(context, 'ยังไม่ได้เลือกวันที่',
                  'กรุณา Tap ที่ ชนิดของ Value ที่ต้องการ');
            }
          } else {
            MyDialog().normalDialog(context, 'ยังไม่ได้เลือกเวลา',
                'กรุณา Tap ที่ ชนิดของ Value ที่ต้องการ');
          }
        } else {
          if (formKey.currentState!.validate()) {
            if (typeValue == null) {
              print('Non Choose Type Value');
              MyDialog().normalDialog(context, 'ยังไม่ได้เลือก ชนิดของ Value',
                  'กรุณา Tap ที่ ชนิดของ Value ที่ต้องการ');
            } else {
              if (time != null) {
                if (date != null) {
                  print('Process Insert to Database');
                  processAddProduct();
                } else {
                  MyDialog().normalDialog(context, 'ยังไม่ได้เลือกวันที่',
                      'กรุณา Tap ที่ ชนิดของ Value ที่ต้องการ');
                }
              } else {
                MyDialog().normalDialog(context, 'ยังไม่ได้เลือกเวลา',
                    'กรุณา Tap ที่ ชนิดของ Value ที่ต้องการ');
              }
            }
          }
        }
      },
      color: MyConstant.dark,
      padding: EdgeInsets.symmetric(horizontal: 50),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Text(
        "SAVE",
        style: GoogleFonts.jost(
          color: MyConstant.light,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.2,
        ),
      ),
    );
  }

  OutlineButton buildButtonCancel() {
    return OutlineButton(
      padding: EdgeInsets.symmetric(horizontal: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        "CANCEL",
        style: GoogleFonts.jost(
          fontWeight: FontWeight.w500,
          color: MyConstant.dark,
          letterSpacing: 2.2,
        ),
      ),
    );
  }

  SizedBox buildIconSelect(double size) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: flagColor ? Colors.white : MyConstant.dark2,
            ),
            width: size * 0.5,
            child: IconButton(
              onPressed: () {
                setState(() {
                  flagColor = true;
                });
                print(flagColor);
              },
              icon: Text(
                'เพิ่มข้อมูลการพบแมลง',
                style: GoogleFonts.prompt(
                  color: flagColor ? MyConstant.dark2 : MyConstant.light,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: flagColor ? MyConstant.dark2 : Colors.white,
            ),
            width: size * 0.5,
            child: IconButton(
              onPressed: () {
                setState(() {
                  flagColor = false;
                });
                print(flagColor);
              },
              icon: Text(
                'เพิ่มข้อมูลการแมลง',
                style: GoogleFonts.prompt(
                  color: flagColor ? MyConstant.light : MyConstant.dark2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* RaisedButton buildButtonSaves() {
    return RaisedButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          if (typeValue == null) {
            print('Non Choose Type Value');
            MyDialog().normalDialog(context, 'ยังไม่ได้เลือก ชนิดของ Value',
                'กรุณา Tap ที่ ชนิดของ Value ที่ต้องการ');
          } else {
            print('Process Insert to Database');
            processAddProduct();
          }
        }
      },
      color: MyConstant.primary,
      padding: EdgeInsets.symmetric(horizontal: 120),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Text(
        "SAVE",
        style: TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.white),
      ),
    );
  }*/

  Set<Marker> setMarker() => <Marker>[
        Marker(
          markerId: MarkerId('id'),
          position: LatLng(lat!, lng!),
          infoWindow: InfoWindow(
              title: 'คุณอยู่ที่นี่', snippet: 'Lat = $lat, lng = $lng'),
        ),
      ].toSet();

  Widget buildMap() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        width: double.infinity,
        height: 250,
        child: lat == null
            ? ShowProgress()
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat!, lng!),
                  zoom: 16,
                ),
                onMapCreated: (controller) {},
                markers: setMarker(),
              ),
      );

  /*Widget buildTextTime() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: timeController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'เวลา',
          icon: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyConstant.primary,
            ),
            child: Icon(
              FontAwesomeIcons.clock,
              color: MyConstant.light,
            ),
          ),
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        onTap: () async {
          TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time == null) return;
          setState(() {
            timeController.text = time.format(context).toString();
          });
        },
      ),
    );
  }*/

  /*Widget buildTextDate() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: dateController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'วันที่',
          icon: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyConstant.dark,
            ),
            child: Icon(
              FontAwesomeIcons.calendar,
              color: MyConstant.light,
            ),
          ),
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        onTap: () async {
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (date == null) return;
          setState(() => {
                dateController.text = date.year.toString() +
                    '/' +
                    date.month.toString() +
                    '/' +
                    date.day.toString()
              });
        },
      ),
    );
  }*/

  Container buildTextProvince(double size) {
    return Container(
      width: size * 0.25,
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: TextFormField(
        controller: provinceController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'จังหวัด',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          /*icon: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyConstant.primary,
            ),
            child: Icon(
              FontAwesomeIcons.mapMarker,
              color: MyConstant.light,
            ),
          ),*/
        ),
      ),
    );
  }

  Container buildTextDistrict(double size) {
    return Container(
      width: size * 0.25,
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: TextFormField(
        controller: districtController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'อำเภอ',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          /*icon: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyConstant.dark,
            ),
            child: Icon(
              FontAwesomeIcons.road,
              color: MyConstant.light,
            ),
          ),*/
        ),
      ),
    );
  }

  Container buildTextCounty(double size) {
    return Container(
      width: size * 0.25,
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: TextFormField(
        controller: countyController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'ตำบล',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          /* icon: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyConstant.primary,
            ),
            child: Icon(
              FontAwesomeIcons.streetView,
              color: MyConstant.light,
            ),
          ),*/
        ),
      ),
    );
  }

  Future<Null> processAddProduct() async {
    if (formKey.currentState!.validate()) {
      bool checkFile = true;
      for (var item in files) {
        if (item == null) {
          checkFile = false;
        }
      }
      if (checkFile) {
        // print('## choose 4 image success');
        MyDialog().showProgressDialog(context);
        String apiSaveFile = '${MyConstant.domain}/insectFile/saveFile.php';
        // print('### apiSaveProduct == $apiSaveProduct');
        int loop = 0;
        for (var item in files) {
          int i = Random().nextInt(1000000);
          String nameFile = 'file$i.jpg';
          paths.add('/file/$nameFile');
          Map<String, dynamic> map = {};
          map['file'] =
              await MultipartFile.fromFile(item!.path, filename: nameFile);
          FormData data = FormData.fromMap(map);
          await Dio().post(apiSaveFile, data: data).then((value) async {
            print('Upload Success');
            loop++;
            if (loop >= files.length) {
              SharedPreferences preference =
                  await SharedPreferences.getInstance();
              String img = paths.toString();
              String name = nameController.text;
              //String date = dateController.text;
              //String time = timeController.text;

              String county = countyController.text;
              String district = districtController.text;
              String province = provinceController.text;
              String details = detailsController.text;
              String protect = protectController.text;
              //String lat = latController.text;
              //String long = longController.text;
              String user = preference.getString('username')!;
              String id = preference.getString('id')!;
              print('###  idUser = $id');
              print('###  nameUser = $user');
              print('### images ==> $img');
              String path;
              if (flagColor) {
                path =
                    '${MyConstant.domain}/insectFile/insertInsectLite.php?isAdd=true&img=$img&name=$name&date=$date&time=$time&county=$county&district=$district&province=$province&lat=$lat&long=$lng&id_user=$id';
              } else {
                path =
                    '${MyConstant.domain}/insectFile/insertInsectData.php?isAdd=true&img=$img&name=$name&details=$details&protect=$protect&date=$date&time=$time&type=$typeValue&lat=$lat&lng=$lng&id_user=$id';
              }

              await Dio().get(path).then((value) => false);
              Navigator.pop(context);
              MyDialog().normalDialog(context, 'Success !!!',
                  'Insert Data in Database Success !!!!!');
            }
          });
        }
      } else {
        MyDialog()
            .normalDialog(context, 'More Image', 'Please Choose More Image');
      }
    }
  }

  AppBar buidAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'เพิ่มข้อมูลการแพร่ระบาดของแมลง',
        style: TextStyle(
          color: Colors.black87,
          fontFamily: 'kanit',
          //fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    );
  }

  Future<Null> processImagePicker(ImageSource source, int index) async {
    try {
      var result = await ImagePicker().getImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );

      setState(() {
        file = File(result!.path);
        files[index] = file;
      });
    } catch (e) {}
  }

  Future<Null> chooseSourceImageDialog(int index) async {
    print('Click From index ==>> $index');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.image4),
          title: ShowTitle(
              title: 'Source Image ${index + 1} ?',
              textStyle: MyConstant().h2Style(Colors.black)),
          subtitle: ShowTitle(
              title: 'Please Tab on Camera or Gallery',
              textStyle: MyConstant().h3Style(Colors.black)),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  processImagePicker(ImageSource.camera, index);
                },
                child: Text('Camera'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  processImagePicker(ImageSource.gallery, index);
                },
                child: Text('Gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column buildImage(BoxConstraints constraints) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          width: constraints.maxWidth,
          height: constraints.maxWidth * 0.6,
          child: files[0] == null
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    MyConstant.image,
                    color: MyConstant.primary,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Image.file(
                    file!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          width: constraints.maxWidth * 0.54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  child: InkWell(
                    onTap: () => chooseSourceImageDialog(0),
                    child: files[0] == null
                        ? Image.asset(MyConstant.add, color: MyConstant.dark)
                        : Image.file(
                            files[0]!,
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                          ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  child: InkWell(
                    onTap: () => chooseSourceImageDialog(1),
                    child: files[1] == null
                        ? Image.asset(MyConstant.add, color: MyConstant.dark)
                        : Image.file(
                            files[1]!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  child: InkWell(
                    onTap: () => chooseSourceImageDialog(2),
                    child: files[2] == null
                        ? Image.asset(MyConstant.add, color: MyConstant.dark)
                        : Image.file(
                            files[2]!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  child: InkWell(
                    onTap: () => chooseSourceImageDialog(3),
                    child: files[3] == null
                        ? Image.asset(MyConstant.add, color: MyConstant.dark)
                        : Image.file(
                            files[3]!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTextName() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: TextFormField(
        controller: nameController,
        validator: (value) {
          if (value!.isEmpty) {
            if (flagColor) {
              nameController.text = 'ไม่ทราบชื่อ';
            } else {
              return 'Please Fill in Blank';
            }
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          focusColor: MyConstant.dark,
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'ชื่อแมลง',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          /* icon: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyConstant.dark,
            ),
            child: Icon(
              FontAwesomeIcons.bug,
              color: MyConstant.light,
            ),
          ),*/
        ),
      ),
    );
  }

  Widget buidLat(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.3,
      margin: EdgeInsets.only(top: 16),
      child: TextFormField(
        controller: latController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill Lat in Blank';
          } else {
            return null;
          }
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelStyle: MyConstant().h3Style(Colors.black),
          labelText: 'ละติจูด :',
          prefixIcon: Icon(
            Icons.location_on,
            color: MyConstant.dark,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.dark),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.light),
            borderRadius: BorderRadius.circular(30),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget buidLong(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.3,
      margin: EdgeInsets.only(top: 16),
      child: TextFormField(
        controller: longController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill Long in Blank';
          } else {
            return null;
          }
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelStyle: MyConstant().h3Style(Colors.black),
          labelText: 'ลองจิจูด :',
          prefixIcon: Icon(
            Icons.location_on,
            color: MyConstant.dark,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.dark),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.light),
            borderRadius: BorderRadius.circular(30),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

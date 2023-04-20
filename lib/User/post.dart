import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonCancel.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Post extends StatefulWidget {
  const Post({Key? key}) : super(key: key);

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
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
  bool status = false;
  double? lat, lng;
  bool flagColor = true;
  String? typeUser;
  String? typeValue;

  @override
  void initState() {
    super.initState();
    checkTypeUser();
  }

  void initialFile() {
    for (var i = 0; i < 4; i++) {
      files.add(null);
    }
  }

  Future<Null> checkTypeUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (preferences.getString('type').toString() != 'null') {
      typeUser = preferences.getString('type')!;
      initialFile();
      checkPermission();
    } else {
      MyDialog().warningDialog(context, 'กรุณาเข้าสู่ระบบ หรือลงทะเบียน',
          'Please login or register');
    }
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
    try {
      print('findLatLan ==> Work');
      Position? position = await findPostion();
      setState(() {
        lat = position!.latitude;
        lng = position.longitude;
        print('lat = $lat, lng = $lng');
      });
    } catch (e) {
      setState(() {
        lat = 0;
        lng = 0;
      });
    }
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
      body: typeUser == null
          ? ShowProgress()
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  behavior: HitTestBehavior.opaque,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildMenu(constraints),
                        flagColor
                            ? Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    buildImage(constraints),
                                    Container(
                                      width: size * 0.8,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 24),
                                      child: uiTypeMember(constraints, size),
                                    ),
                                    buildFooter(size),
                                  ],
                                ),
                              )
                            : typeUser != 'Member'
                                ? Form(
                                    key: formKey,
                                    child: Column(
                                      children: [
                                        buildImage(constraints),
                                        Container(
                                          width: size * 0.8,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 24),
                                          child:
                                              uiTypeExpert(constraints, size),
                                        ),
                                        buildFooter(size),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: constraints.maxHeight / 2.5),
                                      child: Text(
                                        'สำหรับผู้เชียวชาญและแอดมิน',
                                        style: GoogleFonts.prompt(
                                          color: MyConstant.dark2,
                                        ),
                                      ),
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

// ข้อมูลแมลง
  Container uiTypeExpert(BoxConstraints constraints, double size) {
    return Container(
      width: (constraints.maxWidth > 412)
          ? (constraints.maxWidth * 0.6)
          : constraints.maxWidth,
      padding: EdgeInsets.only(
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextName(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'รายละเอียด: ',
              style: GoogleFonts.prompt(color: MyConstant.primary),
            ),
          ),
          buildTextDetails(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'วิธีป้องกันและกำจัด: ',
              style: GoogleFonts.prompt(
                color: Colors.red[700],
              ),
            ),
          ),
          buildTextProtect(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildButtonDate(),
              buildButtonTime(),
            ],
          ),
          buildRadioJuiceSucker(size),
          buildRadioStemBorer(size),
          buildRadioRootFeeder(size),
          buildRadioLeafFeeder(size),
        ],
      ),
    );
  }

// ข้อมูลพบการแพร่ระบาด
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
            width: size * 0.7,
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                buildTextName(),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildTextProvince(size),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Select Images
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: ListTile(
          leading: Image.asset(
            MyConstant.image,
            color: MyConstant.dark,
          ),
          title: Text(
            'เลือกภาพแมลง ${index + 1}',
            style: GoogleFonts.prompt(
              color: MyConstant.dark,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            'Please Tab on Camera or Gallery',
            style: GoogleFonts.prompt(
              color: MyConstant.dark2,
              fontSize: 10,
            ),
          ),
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
                child: Container(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: MyConstant.dark2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Camera',
                    style: GoogleFonts.prompt(
                      color: MyConstant.dark2,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  processImagePicker(ImageSource.gallery, index);
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: MyConstant.dark2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Gallery',
                    style: GoogleFonts.prompt(
                      color: MyConstant.dark2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// function
  Future<Null> processAddProduct() async {
    if (formKey.currentState!.validate()) {
      bool checkFile = true;
      for (var item in files) {
        if (item == null) {
          checkFile = false;
        }
      }
      if (checkFile) {
        MyDialog().showProgressDialog(context);
        String apiSaveFile = '${MyConstant.domain}/insectFile/saveFile.php';
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
              print('### flagColor ==> $flagColor');
              print(
                  '### data ==> $name $county $district $province $date $time $lat:$lng');
              String path;
              if (flagColor) {
                path =
                    '${MyConstant.domain}/insectFile/insertInsectLite.php?isAdd=true&img=$img&name=$name&date=$date&time=$time&county=$county&district=$district&province=$province&lat=$lat&lng=$lng&id_user=$id';
              } else {
                path =
                    '${MyConstant.domain}/insectFile/insertInsectData.php?isAdd=true&img=$img&name=$name&details=$details&protect=$protect&date=$date&time=$time&type=$typeValue&lat=$lat&lng=$lng&id_user=$id';
              }
              await Dio().get(path).then((value) {
                status = true;
                Navigator.pop(context);
              });
            }
          });
        }
        if (status) {
          MyDialog().successDialog(
              context, 'สำเร็จ', 'successfully added information');
          await Future.delayed(Duration(seconds: 1)).then(
            (value) {
              if (typeUser != 'Admin') {
                return Navigator.pushNamedAndRemoveUntil(
                    context, MyConstant.routeMember, (route) => false);
                // return Navigator.pushNamed(context, MyConstant.routeMember);
              }
              return Navigator.pushNamedAndRemoveUntil(
                  context, MyConstant.routeAdmin, (route) => false);
              // return Navigator.pushNamed(context, MyConstant.routeAdmin);
            },
          );
        } else {
          MyDialog().warningDialog(context, 'ผิดพลาด', 'somting wrong');
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context);
        }
      } else {
        MyDialog().warningDialog(context, 'กรุณากรอกข้อมูลให้ครบ',
            'Please complete the information.');
      }
    }
  }

// Widget
  Widget buildImage(BoxConstraints constraints) {
    return Column(
      children: [
        SizedBox(
          height: 1,
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
              return 'กรุณากรอกข้อมูลให้ครบ';
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

  Widget buildTextProvince(double size) {
    return Container(
      width: size * 0.25,
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: TextFormField(
        controller: provinceController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
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

  Widget buildTextDistrict(double size) {
    return Container(
      width: size * 0.25,
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: TextFormField(
        controller: districtController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
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

  Widget buildTextCounty(double size) {
    return Container(
      width: size * 0.25,
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: TextFormField(
        controller: countyController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
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

  Widget buildButtonTime() {
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

  Widget buildButtonDate() {
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

  Widget buildTextProtect() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        maxLines: 6, //or null
        decoration: InputDecoration.collapsed(
          hintText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              new Radius.circular(10),
            ),
          ),
        ),
        controller: protectController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget buildTextDetails() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        maxLines: 6, //or null
        decoration: InputDecoration.collapsed(
          hintText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              new Radius.circular(10),
            ),
          ),
        ),
        controller: detailsController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
          } else {
            return null;
          }
        },
      ),
    );
  }

  RadioListTile buildRadioRootFeeder(double size) {
    return RadioListTile(
      value: '3',
      groupValue: typeValue,
      onChanged: (value) {
        setState(() {
          typeValue = value;
          print('type => $typeValue');
        });
      },
      title: Text(
        'พวกกัดกินราก',
        style: GoogleFonts.prompt(),
      ),
      // ShowTitle(
      //   title: 'แมลงศัตรูพืชจำพวกกัดกินราก (root feeder)',
      //   textStyle: MyConstant().h3Style(Colors.black),
      // ),
    );
  }

  RadioListTile buildRadioStemBorer(double size) {
    return RadioListTile(
      value: '2',
      groupValue: typeValue,
      onChanged: (value) {
        setState(() {
          typeValue = value;
          print('type => $typeValue');
        });
      },
      title: Text(
        'พวกกัดกินลำต้น',
        style: GoogleFonts.prompt(),
      ),
    );
  }

  RadioListTile buildRadioJuiceSucker(double size) {
    return RadioListTile(
      value: '1',
      groupValue: typeValue,
      onChanged: (value) {
        setState(() {
          typeValue = value;
          print('type => $typeValue');
        });
      },
      title: Text(
        'พวกดูดกินน้ำเลี้ยงดอก',
        style: GoogleFonts.prompt(),
      ),
    );
  }

  RadioListTile buildRadioLeafFeeder(double size) {
    return RadioListTile(
      value: '4',
      groupValue: typeValue,
      onChanged: (value) {
        setState(() {
          typeValue = value;
          print('type => $typeValue');
        });
      },
      title: Text(
        'พวกกัดกินใบ',
        style: GoogleFonts.prompt(),
      ),
    );
  }

  Widget buildFooter(double size) {
    return Container(
      width: size * 0.9,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ShowButtonCancel(),
          buildButtonSave(),
        ],
      ),
    );
  }

  Widget buildMenu(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                flagColor = true;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'เพิ่มข้อมูลการพบแมลง',
                  style: GoogleFonts.prompt(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Container(
                  color: flagColor ? Colors.grey[500] : Colors.white,
                  width: (constraints.maxWidth > 412)
                      ? (constraints.maxWidth * 0.8) / 2
                      : (constraints.maxWidth) / 2,

                  // (constraints.maxWidth) / 2,
                  height: 1,
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                flagColor = false;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'เพิ่มข้อมูลแมลง',
                  style: GoogleFonts.prompt(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Container(
                  color: flagColor ? Colors.white : Colors.grey[500],
                  width: (constraints.maxWidth > 412)
                      ? (constraints.maxWidth * 0.8) / 2
                      : (constraints.maxWidth) / 2,
                  height: 1,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtonSave() {
    return RaisedButton(
      onPressed: () {
        if (flagColor) {
          // CHK Member
          if (time != null) {
            if (date != null) {
              processAddProduct();
            } else {
              MyDialog().warningDialog(context, 'กรุณากรอกข้อมูลให้ครบ',
                  'Please complete the information.');
            }
          } else {
            MyDialog().warningDialog(context, 'กรุณากรอกข้อมูลให้ครบ',
                'Please complete the information.');
          }
        } else {
          // CHK Expert
          if (formKey.currentState!.validate()) {
            if (typeValue == null) {
              print('Non Choose Type Value');
              MyDialog().warningDialog(context, 'กรุณากรอกข้อมูลให้ครบ',
                  'Please complete the information.');
            } else {
              if (time != null) {
                if (date != null) {
                  print('Process Insert to Database');
                  processAddProduct();
                } else {
                  MyDialog().warningDialog(context, 'กรุณากรอกข้อมูลให้ครบ',
                      'Please complete the information.');
                }
              } else {
                MyDialog().warningDialog(context, 'กรุณากรอกข้อมูลให้ครบ',
                    'Please complete the information.');
              }
            }
          }
        }
      },
      color: MyConstant.primary,
      padding: EdgeInsets.symmetric(horizontal: 50),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "บันทึก",
        style: GoogleFonts.prompt(
          color: Colors.white,
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

  // Widget buildMap() => Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(30),
  //       ),
  //       width: double.infinity,
  //       height: 250,
  //       child: lat == null
  //           ? ShowProgress()
  //           : GoogleMap(
  //               initialCameraPosition: CameraPosition(
  //                 target: LatLng(lat!, lng!),
  //                 zoom: 16,
  //               ),
  //               onMapCreated: (controller) {},
  //               markers: setMarker(),
  //             ),
  //     );

  // /*Widget buildTextTime() {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 35.0),
  //     child: TextFormField(
  //       controller: timeController,
  //       validator: (value) {
  //         if (value!.isEmpty) {
  //           return 'Please Fill in Blank';
  //         } else {
  //           return null;
  //         }
  //       },
  //       decoration: InputDecoration(
  //         contentPadding: EdgeInsets.only(bottom: 3),
  //         labelText: 'เวลา',
  //         icon: Container(
  //           width: 35,
  //           height: 35,
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(10),
  //             color: MyConstant.primary,
  //           ),
  //           child: Icon(
  //             FontAwesomeIcons.clock,
  //             color: MyConstant.light,
  //           ),
  //         ),
  //         //labelStyle: MyConstant().h3Style(Colors.lightGreen),
  //         floatingLabelBehavior: FloatingLabelBehavior.always,
  //       ),
  //       onTap: () async {
  //         TimeOfDay? time = await showTimePicker(
  //           context: context,
  //           initialTime: TimeOfDay.now(),
  //         );
  //         if (time == null) return;
  //         setState(() {
  //           timeController.text = time.format(context).toString();
  //         });
  //       },
  //     ),
  //   );
  // }*/

  // Widget buildTextDate() {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 35.0),
  //     child: TextFormField(
  //       controller: dateController,
  //       validator: (value) {
  //         if (value!.isEmpty) {
  //           return 'Please Fill in Blank';
  //         } else {
  //           return null;
  //         }
  //       },
  //       decoration: InputDecoration(
  //         contentPadding: EdgeInsets.only(bottom: 3),
  //         labelText: 'วันที่',
  //         icon: Container(
  //           width: 35,
  //           height: 35,
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(10),
  //             color: MyConstant.dark,
  //           ),
  //           child: Icon(
  //             FontAwesomeIcons.calendar,
  //             color: MyConstant.light,
  //           ),
  //         ),
  //         //labelStyle: MyConstant().h3Style(Colors.lightGreen),
  //         floatingLabelBehavior: FloatingLabelBehavior.always,
  //       ),
  //       onTap: () async {
  //         DateTime? date = await showDatePicker(
  //           context: context,
  //           initialDate: DateTime.now(),
  //           firstDate: DateTime(1900),
  //           lastDate: DateTime(2100),
  //         );
  //         if (date == null) return;
  //         setState(() => {
  //               dateController.text = date.year.toString() +
  //                   '/' +
  //                   date.month.toString() +
  //                   '/' +
  //                   date.day.toString()
  //             });
  //       },
  //     ),
  //   );
  // }

  // Widget buidLat(BoxConstraints constraints) {
  //   return Container(
  //     width: constraints.maxWidth * 0.3,
  //     margin: EdgeInsets.only(top: 16),
  //     child: TextFormField(
  //       controller: latController,
  //       validator: (value) {
  //         if (value!.isEmpty) {
  //           return 'Please Fill Lat in Blank';
  //         } else {
  //           return null;
  //         }
  //       },
  //       keyboardType: TextInputType.number,
  //       decoration: InputDecoration(
  //         labelStyle: MyConstant().h3Style(Colors.black),
  //         labelText: 'ละติจูด :',
  //         prefixIcon: Icon(
  //           Icons.location_on,
  //           color: MyConstant.dark,
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: MyConstant.dark),
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: MyConstant.light),
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //         errorBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.red),
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget buidLong(BoxConstraints constraints) {
  //   return Container(
  //     width: constraints.maxWidth * 0.3,
  //     margin: EdgeInsets.only(top: 16),
  //     child: TextFormField(
  //       controller: longController,
  //       validator: (value) {
  //         if (value!.isEmpty) {
  //           return 'Please Fill Long in Blank';
  //         } else {
  //           return null;
  //         }
  //       },
  //       keyboardType: TextInputType.number,
  //       decoration: InputDecoration(
  //         labelStyle: MyConstant().h3Style(Colors.black),
  //         labelText: 'ลองจิจูด :',
  //         prefixIcon: Icon(
  //           Icons.location_on,
  //           color: MyConstant.dark,
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: MyConstant.dark),
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: MyConstant.light),
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //         errorBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.red),
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/model/insectLite_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonCancel.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class Approve extends StatefulWidget {
  final String id;
  const Approve({Key? key, required this.id}) : super(key: key);

  @override
  State<Approve> createState() => _ApproveState();
}

class _ApproveState extends State<Approve> {
  final formKey = GlobalKey<FormState>();
  bool? haveData;
  bool load = true;
  String? id;
  int currentIndex = 0;
  final PageController controller = PageController();
  TextEditingController nameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController protectController = TextEditingController();
  List<String> images = [];
  String? typeValue;
  InsectLiteModel? insectLiteModelAPI;

  @override
  void initState() {
    super.initState();
    loadFromAPI();
  }

  Future<Null> loadFromAPI() async {
    id = widget.id;
    String apiGet =
        '${MyConstant.domain}/insectFile/getInsectLiteWhereIDInsect.php?isAdd=true&id=$id';
    try {
      await Dio().get(apiGet).then((value) {
        for (var item in json.decode(value.data)) {
          insectLiteModelAPI = InsectLiteModel.fromMap(item);
          subImageX(insectLiteModelAPI!.img);
          setState(() {
            load = false;
            haveData = true;
            print('### value ==> $insectLiteModelAPI');
          });
        }
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  void subImageX(String string) {
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    String url;
    for (var item in strings) {
      item = item.replaceAll(' ', '');
      url = '${MyConstant.domain}/insectFile$item';
      setState(() {
        images.add(url);
      });
    }
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
              ? LayoutBuilder(
                  builder: (context, constraints) => GestureDetector(
                    onTap: () =>
                        FocusScope.of(context).requestFocus(FocusNode()),
                    behavior: HitTestBehavior.opaque,
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
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
                                      ),
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
                            Container(
                              width: size * 0.8,
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Container(
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
                                        style: GoogleFonts.prompt(
                                            color: MyConstant.primary),
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
                                    buildRadioJuiceSucker(size),
                                    buildRadioStemBorer(size),
                                    buildRadioRootFeeder(size),
                                    buildRadioLeafFeeder(size),
                                    buildFooter(size),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : showNoData(),
    );
  }

// Dialog
  void showDialogValueEmpty(context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      context: context,
      builder: (BuildContext bc) {
        return Container(
          //color: Colors.grey[300],
          height: MediaQuery.of(context).size.height * 0.15,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.backspace_outlined),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    'กรุณากรอกข้อมูล',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// function
  Future<Null> processApprove() async {
    if (formKey.currentState!.validate()) {
      if (typeValue != null) {
        MyDialog().showProgressDialog(context);
        String img = insectLiteModelAPI!.img;
        String date = insectLiteModelAPI!.date;
        String time = insectLiteModelAPI!.time;
        String county = insectLiteModelAPI!.county;
        String district = insectLiteModelAPI!.district;
        String province = insectLiteModelAPI!.province;
        String lat = insectLiteModelAPI!.lat;
        String lng = insectLiteModelAPI!.lng;
        String user_id = insectLiteModelAPI!.id_user;
        String name = nameController.text;
        String protect = protectController.text;
        String inType = typeValue!;
        String details = detailsController.text +
            ' พบในพื้นที่ ต.$county อ.$district จ.$province เวลา $time วันที่ $date';
        print('### Images ==> $img');
        print(
            '### Data ==> id:${insectLiteModelAPI!.id} $name $details $protect $inType $lat:$lng user:$user_id');
        String pathInsert =
            '${MyConstant.domain}/insectFile/insertInsectData.php?isAdd=true&img=$img&name=$name&details=$details&protect=$protect&date=$date&time=$time&type=$typeValue&lat=$lat&lng=$lng&id_user=$user_id';
        String pathDelete =
            '${MyConstant.domain}/insectFile/deleteInsectLiteWhereID.php?isAdd=true&id=${insectLiteModelAPI!.id}';

        try {
          await Dio().get(pathInsert).then(
                (value) => Navigator.pop(context),
              );
          await Dio().get(pathDelete).then((value) => false);
          MyDialog().successDialog(
              context, 'สำเร็จ', 'successfully added information');
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context);
        } catch (e) {
          return MyDialog()
              .warningDialog(context, 'ผิดพลาด', 'Failed to add data');
        }

        Navigator.pop(context);
        // End Process Insert
      } else {
        return MyDialog().warningDialog(
            context, 'กรุณาเลือกประเภท', 'Please complete the information.');
      }
    } else {
      return MyDialog().warningDialog(
          context, 'กรุณากรอกข้อมูลให้ครบ', 'Please complete the information.');
    }
  }

// Widget
  Widget buildFooter(double size) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ShowButtonCancel(),
          buildButtonSave(),
        ],
      ),
    );
  }

  Widget buildDetails(double size) {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildTextName(),
              Text(
                '${insectLiteModelAPI!.name}',
                style: GoogleFonts.prompt(
                  fontSize: 20,
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
          Divider(color: MyConstant.primary, thickness: 1, height: 10),
          buildTextDetails(),
          Divider(color: Colors.white, thickness: 0, height: 12),
          Text(
            'วิธีการป้องกันและกำจัด:',
            style: GoogleFonts.prompt(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.red,
            ),
          ),
          Divider(color: Colors.red, thickness: 1, height: 10),
          buildTextProtect(),
        ],
      ),
    );
  }

  Widget buildButtonSave() {
    return RaisedButton(
      onPressed: () {
        processApprove();
      },
      color: MyConstant.primary,
      padding: EdgeInsets.symmetric(horizontal: 45),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Text(
        "บันทึก",
        style: GoogleFonts.prompt(color: Colors.white),
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

  Widget buildTextName() {
    return Padding(
      padding: const EdgeInsets.only(),
      child: TextFormField(
        controller: nameController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          hintText: insectLiteModelAPI!.name,
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

  Widget showNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "เรียบร้อย!",
            style: GoogleFonts.prompt(
              fontSize: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 110, right: 110, bottom: 120, top: 40),
            child: buildButtonBack(),
          ),
        ],
      ),
    );
  }

  Widget buildButtonBack() {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: () {
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.arrow_back_ios),
          Text(
            "ย้อนกลับ",
            style: GoogleFonts.prompt(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /*statusAvatar != true
              ? CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: '${MyConstant.domain}${userModel!.img}',
                  placeholder: (context, url) => CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('images/avatar.png'),
                    backgroundColor: Colors.grey,
                  ),
                  errorWidget: (context, url, error) =>
                      ShowImage(path: MyConstant.image),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      //NetworkImage('${MyConstant.domain}${userModel!.img}'),
                      AssetImage(MyConstant.avatar),
                ),*/
          /*Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: MyConstant.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: statusAvatar != true
                ? Container(
                    child: Image.asset(
                      MyConstant.avatar,
                      scale: 9,
                      //color: Colors.grey[400],
                    ),
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        NetworkImage('${MyConstant.domain}${userModel!.img}'),
                    //AssetImage(MyConstant.avatar),
                  ),
          ),*/
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*Text(
                      '${userModel!.name}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'kanit',
                        color: Colors.black87,
                      ),
                    ),*/
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.userCheck,
                      size: 16,
                      color: MyConstant.dark,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '{insectLiteModelAPI!.usEmail}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'kanit',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.phone,
                      size: 16,
                      color: MyConstant.dark,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '{insectLiteAllModelAPI!.usType}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'kanit',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        'แมลงศัตรูพืชจำพวกกัดกินราก',
        style: GoogleFonts.prompt(
          fontSize: 14,
        ),
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
        'แมลงศัตรูพืชจำพวกกัดกินลำต้น',
        style: GoogleFonts.prompt(
          fontSize: 14,
        ),
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
        'แมลงศัตรูพืชจำพวกดูดกินน้ำเลี้ยงดอกและยอดอ่อน',
        style: GoogleFonts.prompt(
          fontSize: 14,
        ),
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
        'แมลงศัตรูพืชจำพวกกัดกินใบ',
        style: GoogleFonts.prompt(
          fontSize: 14,
        ),
      ),
    );
  }

  AppBar buildAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      title: Text(
        'เพิ่มข้อมูลและยืนยัน',
        style: GoogleFonts.prompt(
          fontSize: 20,
        ),
      ),
    );
  }
}

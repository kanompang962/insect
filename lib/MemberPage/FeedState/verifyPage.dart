import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/model/epidemic_model.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';

class VerifyPage extends StatefulWidget {
  final EpidemicModel epidemicModel;
  const VerifyPage({Key? key, required this.epidemicModel}) : super(key: key);

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final formKey = GlobalKey<FormState>();
  bool? haveData;
  bool load = true;
  bool typeEdit = false;
  EpidemicModel? epidemicModel;
  EpidemicModel? epidemicModelAPI;
  int currentIndex = 0;
  final PageController controller = PageController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController protectController = TextEditingController();

  List<String> images = [];
  bool statusAvatar = true;
  UserModel? userModel;
  String? typeValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadValueFromAPI();
    //loadUserFromAPI();
  }

  Future<Null> loadValueFromAPI() async {
    epidemicModel = widget.epidemicModel;
    if (epidemicModel == null) {
      print('sendValue => Not Value');
      haveData = false;
    } else {
      print('sendValue => Have');
      String apiGetUserWhereId =
          '${MyConstant.domain}/insectFile/getUserWhereID.php?isAdd=true&id=${epidemicModel!.id_user}';
      String apiGetInsectWhereId =
          '${MyConstant.domain}/insectFile/getInsectLiteWhereIDInsect.php?isAdd=true&id=${epidemicModel!.id}';

      await Dio().get(apiGetUserWhereId).then((value) {
        //print('## value ==> $value');
        for (var item in json.decode(value.data)) {
          setState(() {
            //load = false;
            //haveData = true;

            userModel = UserModel.fromMap(item);
            if (userModel!.img.isNotEmpty) {
              statusAvatar = true;
            } else {}
            if (userModel!.img.isEmpty) statusAvatar = false;
            print("User ID ==> ${userModel!.id}");
            print("User Img ==> ${userModel!.img}");
            print("User ==> ${userModel!.name}");
          });
        }
      });
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
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppbar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        behavior: HitTestBehavior.opaque,
        child: load
            ? ShowProgress()
            : haveData!
                ? SingleChildScrollView(
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < images.length; i++)
                                buildIndicator(currentIndex == i)
                            ],
                          ),
                        ),
                        buildDetails(),
                        buildTextDetails(),
                        buildTextProtect(),
                        buildRadioJuiceSucker(size),
                        buildRadioLeafFeeder(size),
                        buildRadioStemBorer(size),
                        buildRadioRootFeeder(size),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildButtonCancel(),
                              buildButtonSave(),
                            ],
                          ),
                        ),
                        //buidlWarning(size),
                      ],
                    ),
                  )
                : showNoData(),
      ),
    );
  }

  Future<Null> processAddProduct() async {
    MyDialog().showProgressDialog(context);
    String img = epidemicModelAPI!.img;
    String name = epidemicModelAPI!.name;
    String date = epidemicModelAPI!.date;
    String time = epidemicModelAPI!.time;
    String county = epidemicModelAPI!.county;
    String district = epidemicModelAPI!.district;
    String province = epidemicModelAPI!.province;
    String details = detailsController.text +
        '\nพบในพื้นที่ ต.$county อ.$district จ.$province\nเวลา $time วันที่ $date';
    String protect = protectController.text;
    String lat = epidemicModelAPI!.lat;
    String lng = epidemicModelAPI!.long;
    String user_id = epidemicModelAPI!.id_user;

    String path =
        '${MyConstant.domain}/insectFile/insertInsectData.php?isAdd=true&img=$img&name=$name&details=$details&protect=$protect&date=$date&time=$time&type=$typeValue&lat=$lat&lng=$lng&id_user=$user_id';
    await Dio().get(path).then((value) => false);

    print('## Confirm Delete at id ==> ${epidemicModel!.id}');
    String apiDeleteProductWhereId =
        '${MyConstant.domain}/insectFile/deleteInsectLiteWhereID.php?isAdd=true&id=${epidemicModel!.id}';
    await Dio().get(apiDeleteProductWhereId).then((value) {
      loadValueFromAPI();
      Navigator.pop(context);
      MyDialog().normalDialog(
          context, 'Success !!!', 'Insert Data in Database Success !!!!!');
    });
  }

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
                  )));
        });
  }

  RaisedButton buildButtonSave() {
    return RaisedButton(
      onPressed: () {
        if (detailsController.text.isNotEmpty &&
            protectController.text.isNotEmpty) {
          processAddProduct();
        } else {
          showDialogValueEmpty(context);
        }

        //if (formKey.currentState!.validate()) {}
      },
      color: MyConstant.primary,
      padding: EdgeInsets.symmetric(horizontal: 50),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Text(
        "SAVE",
        style: TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.white),
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
      child: Text("CANCEL",
          style:
              TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.black)),
    );
  }

  Padding buildTextProtect() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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

  /*Widget buildMap() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        width: double.infinity,
        height: 150,
        child: epidemicModelAPI!.lat == null
            ? ShowProgress()
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(double.parse(epidemicModelAPI!.lat),
                      double.parse(epidemicModelAPI!.long)),
                  zoom: 12,
                ),
                onMapCreated: (controller) {},
                markers: setMarker(),
              ),
      );*/

  /* Set<Marker> setMarker() => <Marker>[
        Marker(
          markerId: MarkerId('id'),
          position: LatLng(double.parse(epidemicModelAPI!.lat),
              double.parse(epidemicModelAPI!.long)),
          infoWindow: InfoWindow(
              title: 'คุณอยู่ที่นี่',
              snippet:
                  'Lat = $epidemicModelAPI!.lat, lng = $epidemicModelAPI!.long'),
        ),
      ].toSet();*/

  Center showNoData() {
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

  OutlineButton buildButtonBack() {
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

  Container buildDetails() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildProfile(),
          Divider(color: Colors.grey.shade100, thickness: 1, height: 1),
          Text(
            '${epidemicModelAPI!.name}',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'kanit',
              color: Colors.black87,
            ),
          ),
          Text(
            'สถานที่พบแมลง:  ตำบล:${epidemicModelAPI!.county} อำเภอ:${epidemicModelAPI!.district} จังหวัด:${epidemicModelAPI!.province}',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'kanit',
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'วันที่:  ${epidemicModelAPI!.date}',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'kanit',
              color: Colors.black87,
            ),
          ),
          Text(
            'เวลา:  ${epidemicModelAPI!.time}',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'kanit',
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Padding buildProfile() {
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
                      '${userModel!.email}',
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
                      '${userModel!.phone}',
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

  Row buildRadioRootFeeder(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 1,
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
          width: size * 1,
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
          width: size * 1,
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
          width: size * 1,
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

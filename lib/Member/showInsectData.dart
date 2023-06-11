import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/showMap1.dart';
import 'package:project001/Member/editInsectData.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowInsectData extends StatefulWidget {
  final InsectModel insectModel;
  const ShowInsectData({Key? key, required this.insectModel}) : super(key: key);

  @override
  State<ShowInsectData> createState() => _ShowInsectDataState();
}

class _ShowInsectDataState extends State<ShowInsectData> {
  bool? haveData;
  bool load = true;
  InsectModel? insectModel;
  InsectModel? insectModelAPI;
  int currentIndex = 0;
  String? typeUser;
  final PageController controller = PageController();
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    loadValueFromAPI();
    checkTypeUser();
  }

  Future<Null> checkTypeUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    typeUser = preferences.getString('type')!;
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
          Navigator.pop(context);
        });
      } else {
        load = false;
        haveData = true;
        // Have Data
        for (var item in json.decode(value.data)) {
          insectModelAPI = InsectModel.fromMap(item);
          print(
              '### From API ==>> ${insectModelAPI!.id} ${insectModelAPI!.name}');
          _subImageX(insectModelAPI!.img);
        }
      }
    });
  }

  String checkType(String type) {
    if (type == '1') {
      return 'ดูดกินน้ำเลี้ยงดอก';
    } else if (type == '2') {
      return 'กัดกินลำต้น';
    } else if (type == '3') {
      return 'กัดกินราก';
    } else {
      return 'กัดกินใบ';
    }
  }

  void _subImageX(String string) {
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
      floatingActionButton: buildFloatButtonMap(context),
      backgroundColor: Colors.white,
      appBar: buildAppbar(size),
      body: load
          ? ShowProgress()
          : haveData!
              ? LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: Center(
                      child: Container(
                        width: (constraints.maxWidth > 412)
                            ? (constraints.maxWidth * 0.8)
                            : constraints.maxWidth,
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
                            buildDetails(size),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : showNoData(),
    );
  }

// Widget
  Widget buildFloatButtonMap(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowMap1(id: insectModelAPI!.id),
          ),
        );
      },
      label: Text(
        'ดูแผนที่',
        style: GoogleFonts.prompt(
          fontWeight: FontWeight.w400,
          color: MyConstant.light,
        ),
      ),
      icon: Icon(
        FontAwesomeIcons.locationDot,
        color: MyConstant.light,
      ),
      backgroundColor: MyConstant.dark,
    );
  }

  Widget showNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShowTitle(
              title: 'No Data ', textStyle: MyConstant().h1Style(Colors.black)),
          ShowTitle(
            title: 'Please Add Data',
            textStyle: MyConstant().h2Style(Colors.black),
          ),
        ],
      ),
    );
  }

  Widget buildDetails(double size) {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${insectModelAPI!.name}',
            style: GoogleFonts.prompt(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            'ประเภท: ${checkType(insectModelAPI!.type)}',
            style: GoogleFonts.prompt(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'รายละเอียด:',
            style: GoogleFonts.prompt(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: MyConstant.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Divider(color: MyConstant.primary, thickness: 1, height: 10),
          Container(
            width: size * 1,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              '${insectModelAPI!.details}',
              style: GoogleFonts.prompt(
                fontSize: 12,
              ),
              //maxLines: 10,
              //overflow: TextOverflow.ellipsis,
            ),
          ),
          Divider(color: Colors.white, thickness: 0, height: 12),
          Text(
            'วิธีการป้องกันและกำจัด:',
            style: GoogleFonts.prompt(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.red,
            ),
          ),
          Divider(color: Colors.red, thickness: 1, height: 10),
          Container(
            width: size * 1,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              '${insectModelAPI!.protect}',
              style: GoogleFonts.prompt(
                fontSize: 12,
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

  AppBar buildAppbar(double size) {
    return AppBar(
      title: Text(
        'ข้อมูลแมลง',
        style: GoogleFonts.prompt(
          fontSize: 14,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      actions: [
        IconButton(
          onPressed: () {
            showBottomSheet(size);
          },
          icon: Icon(FontAwesomeIcons.alignJustify),
        ),
      ],
    );
  }

// function
  Future<Null> _functionDel(BuildContext context) async {
    String apiDeleteProductWhereId =
        '${MyConstant.domain}/insectFile/deleteInsectDataWhereID.php?isAdd=true&id=${insectModel!.id}';
    await Dio().get(apiDeleteProductWhereId).then(
      (value) {
        Navigator.pop(context);
        loadValueFromAPI().then((value) => Navigator.pop(context));
      },
    );
  }

// Dialog
  _myDialogDel() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.del),
          title: Text(
            'ลบข้อมูล',
            style: GoogleFonts.prompt(fontSize: 16),
          ),
          subtitle: Text(
            'ต้องการที่จะลบข้อมูลนี้ หรือไม่',
            style: GoogleFonts.prompt(fontSize: 14),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: RaisedButton(
              onPressed: () async {
                await _functionDel(context);
              },
              color: Color(0xFFB22222),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "ยืนยัน",
                style: GoogleFonts.prompt(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: OutlineButton(
              highlightedBorderColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ยกเลิก",
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Show Bottom Sheet
  Future<Null> showBottomSheet(double size) {
    return showModalBottomSheet<Null>(
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

  Widget buildButtonDeleteSheet(double size) {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () async {
        print('## Confirm Delete at id ==> ${insectModel!.id}');
        _myDialogDel();
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

  Widget buildButtonEditSheet(double size) {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        if (typeUser != 'Member') {
          print('## type => $typeUser');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditInsectData(id: insectModelAPI!.id),
            ),
          ).then((value) {
            loadValueFromAPI();
            images.clear();
          });
        } else {
          MyDialog().normalDialog(context, 'ไม่สามารถแก้ไขได้',
              'สิทธิ์การแก้ไขได้เฉพาะ ผู้เชี่ยวชาญและแอดมินเท่านั้น');
        }
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
}

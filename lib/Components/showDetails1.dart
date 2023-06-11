import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/showMap1.dart';
import 'package:project001/model/insectAll_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';

class ShowDetails1 extends StatefulWidget {
  final String id;
  const ShowDetails1({Key? key, required this.id}) : super(key: key);

  @override
  State<ShowDetails1> createState() => _ShowDetails1State();
}

class _ShowDetails1State extends State<ShowDetails1> {
  bool haveData = false;
  bool load = true;
  String? id;
  InsectAllModel? insectAllModelAPI;
  int currentIndex = 0;
  final PageController controller = PageController();
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    loadValueFromAPI();
  }

  Future<Null> loadValueFromAPI() async {
    id = widget.id;
    String apiGetInsectWhereId =
        '${MyConstant.domain}/insectFile/getAllInsectDataWhereID.php?isAdd=true&id=$id';
    try {
      await Dio().get(apiGetInsectWhereId).then((value) {
        if (value.toString() == 'null') {
          // No Value
        } else {
          // Have Value
          for (var item in json.decode(value.data)) {
            insectAllModelAPI = InsectAllModel.fromMap(item);
            subImageX(insectAllModelAPI!.inImg);
          }
          setState(() {
            load = false;
            haveData = true;
          });
        }
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
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
      floatingActionButton: buildFloatButtonMap(context),
      backgroundColor: Colors.white,
      appBar: buildAppbar(size),
      body: load
          ? ShowProgress()
          : haveData
              ? Stack(
                  children: [
                    LayoutBuilder(
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
                                            imageUrl:
                                                images[index % images.length],
                                            placeholder: (context, url) =>
                                                ShowImage(
                                                    path: MyConstant.image),
                                            errorWidget:
                                                (context, url, error) =>
                                                    ShowImage(
                                                        path: MyConstant.image),
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
                    ),
                  ],
                )
              : showNoData(),
    );
  }

  Widget buildFloatButtonMap(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowMap1(id: insectAllModelAPI!.inID),
          ),
        );
      },
      label: Text(
        'ดูแผนที่',
        style: GoogleFonts.prompt(
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
              textStyle: MyConstant().h2Style(Colors.black)),
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
            '${insectAllModelAPI!.inName}',
            style: GoogleFonts.prompt(
              fontSize: 16,
            ),
          ),
          Text(
            'ประเภท: ${checkType(insectAllModelAPI!.inType)}',
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
              '${insectAllModelAPI!.inDetails}',
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
              '${insectAllModelAPI!.inProtect}',
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
    );
  }
}

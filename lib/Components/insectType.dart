import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/model/insectAll_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonDetail.dart';
import 'package:project001/widgets/show_ButtonMap.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class InsectType extends StatefulWidget {
  final String type;
  const InsectType({Key? key, required this.type}) : super(key: key);

  @override
  State<InsectType> createState() => _InsectTypeState();
}

class _InsectTypeState extends State<InsectType> {
  List<InsectAllModel> insectAllModels = [];
  List<InsectAllModel> _foundInsect = [];
  bool haveData = false;
  bool load = true;
  String? type;
  bool btnSearch = false;
  bool status = false;

  @override
  void initState() {
    super.initState();
    loadInsectDataFromAPI();
    print('----------Refresh----------');
  }

  Future<Null> loadInsectDataFromAPI() async {
    type = widget.type;
    if (insectAllModels.length != 0) {
      insectAllModels.clear();
    } else {}
    String apiGet =
        '${MyConstant.domain}/insectFile/getInsectDataWhereType.php?isAdd=true&type=$type';
    try {
      await Dio().get(apiGet).then(
        (value) {
          if (json.decode(value.data) == null) {
            // print('value = empty');
          } else {
            // print('value = $value');
            for (var item in json.decode(value.data)) {
              InsectAllModel model = InsectAllModel.fromMap(item);
              setState(() {
                print('### model ==> $model');
                insectAllModels.add(model);
              });
            }
            setState(() {
              _foundInsect = insectAllModels;
              load = false;
              haveData = true;
            });
            print('### value length ==> $insectAllModels');
          }
        },
      );
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  void _runFilter(String enteredKeyword) {
    List<InsectAllModel> results1 = [];
    if (enteredKeyword.isEmpty) {
      // ไม่มีการค้นหา
      print('### ไม่มีการค้นหา');
      results1 = insectAllModels;
    } else {
      // ค้นหาชื่อ
      print('### ค้นหาชื่อ');
      results1 = insectAllModels
          .where((item) =>
              item.inName.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundInsect = results1;
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: buildAppbar(size),
      backgroundColor: Colors.grey[300],
      body: load
          ? ShowProgress()
          : LayoutBuilder(
              builder: (context, constraints) => Center(
                child: Container(
                  width: (constraints.maxWidth > 412)
                      ? (constraints.maxWidth * 0.8)
                      : constraints.maxWidth,
                  child: Column(
                    children: [
                      buildSearchTextField(size),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _foundInsect.length,
                          itemBuilder: (context, index) {
                            return LayoutBuilder(
                              builder: (context, constraints) => Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // buildHeader(index),
                                        // buildCenter(index, constraints),
                                        buildDetails(index),
                                        buildFooter(index)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

// Widget

  Widget buildDetails(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_foundInsect[index].inName}',
          style: GoogleFonts.prompt(
            fontSize: 14,
            color: MyConstant.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${_foundInsect[index].inDetails}',
          style: GoogleFonts.prompt(
            fontSize: 12,
            color: MyConstant.dark2,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget buildCenter(int index, BoxConstraints constraints) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: MyConstant().subImage(_foundInsect[index].inImg),
      placeholder: (context, url) => ShowImage(path: MyConstant.image),
      errorWidget: (context, url, error) => ShowImage(path: MyConstant.image),
      imageBuilder: (context, imageProvider) => Container(
        width: constraints.maxWidth,
        height: constraints.maxWidth / 4,
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget buildFooter(int index) {
    return Row(
      children: [
        ShowButtonDetail(id: _foundInsect[index].inID),
        SizedBox(width: 2.0),
        ShowButtonMap(id: _foundInsect[index].inID),
      ],
    );
  }

  Widget buildHeader(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: '${MyConstant.domain}${_foundInsect[index].usImg}',
          errorWidget: (context, url, error) =>
              ShowImage(path: MyConstant.avatar),
          imageBuilder: (context, imageProvider) => Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_foundInsect[index].usName}",
                style: GoogleFonts.prompt(
                  fontSize: 12,
                  color: MyConstant.dark2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${_foundInsect[index].usEmail}",
                style: GoogleFonts.prompt(
                  fontSize: 12,
                  color: MyConstant.dark2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSearchTextField(double size) {
    return Container(
      padding: EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              width: status ? size * 0.8 : size * 0.96,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                onTap: () {
                  status = true;
                  print(status);
                },
                onChanged: (value) {
                  //print(val);
                  _runFilter(value);
                  print('### _runFilter ==> $value');
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(
                    FontAwesomeIcons.search,
                    size: 16,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  status = false;
                  print(status);
                },
                child: status
                    ? Text(
                        'ยกเลิก',
                        style: GoogleFonts.prompt(
                          color: Colors.black,
                        ),
                      )
                    : Container())
          ],
        ),
      ),
    );
  }

  AppBar buildAppbar(double size) {
    return AppBar(
      backgroundColor: Colors.grey[300],
      elevation: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                'Insect',
                style: GoogleFonts.lobster(
                  fontSize: 30,
                ),
              ),
              Text(
                ' | จัดการข้อมูลแมลง',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/showMap2.dart';
import 'package:project001/Member/editInsectLite.dart';
import 'package:project001/User/post.dart';
import 'package:project001/model/insectLiteAll_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonDetail.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class ListInsectLite extends StatefulWidget {
  const ListInsectLite({Key? key}) : super(key: key);

  @override
  State<ListInsectLite> createState() => _ListInsectLiteState();
}

class _ListInsectLiteState extends State<ListInsectLite> {
  List<InsectLiteAllModel> insectLiteAllModels = [];
  bool haveData = false;
  bool load = true;
  bool btnSearch = false;
  bool status = false;
  String? btnType;
  List<InsectLiteAllModel> _foundInsect = [];

  @override
  void initState() {
    super.initState();
    loadInsectLiteFromAPI();
    _foundInsect = insectLiteAllModels;
    print('----------Refresh----------');
  }

  Future<Null> loadInsectLiteFromAPI() async {
    if (insectLiteAllModels.length != 0) {
      insectLiteAllModels.clear();
    } else {}
    String apiGet =
        '${MyConstant.domain}/insectFile/getAllInsectLite.php?isAdd=true';
    try {
      await Dio().get(apiGet).then(
        (value) {
          if (json.decode(value.data) == null) {
            // print('value = empty');
          } else {
            // print('value = $value');
            for (var item in json.decode(value.data)) {
              InsectLiteAllModel model = InsectLiteAllModel.fromMap(item);
              setState(() {
                insectLiteAllModels.add(model);
              });
            }
            setState(() {
              load = false;
              haveData = true;
            });
            print('### value length ==> ${insectLiteAllModels.length}');
          }
        },
      );
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  void _runFilter(String enteredKeyword) {
    List<InsectLiteAllModel> results1 = [];
    if (enteredKeyword.isEmpty) {
      // ไม่มีการค้นหา
      print('### ไม่มีการค้นหา');
      results1 = insectLiteAllModels;
    } else {
      // ค้นหาชื่อ
      print('### ค้นหาชื่อ');
      results1 = insectLiteAllModels
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
      floatingActionButton: buildFloatButton(context),
      body: load
          ? ShowProgress()
          : LayoutBuilder(
              builder: (context, constraints) => Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSearchTextField(size),
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: Container(
                          width: (constraints.maxWidth > 412)
                              ? (constraints.maxWidth * 0.8)
                              : constraints.maxWidth,
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
                                          buildHeader(index),
                                          buildCenter(index, constraints),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

// Dialog
  _myDialogDel(int index) async {
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
                await _functionDel(index, context);
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

// function
  Future<void> _functionDel(int index, BuildContext context) async {
    print('### id => ${insectLiteAllModels[index].inID}');
    String api =
        '${MyConstant.domain}/insectFile/deleteInsectLiteWhereID.php?isAdd=true&id=${insectLiteAllModels[index].inID}';
    await Dio().get(api).then(
      (value) {
        Navigator.pop(context);
        loadInsectLiteFromAPI();
      },
    );
  }

// Widget
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

  Widget buildDetails(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_foundInsect[index].inName}',
          style: GoogleFonts.prompt(
            fontSize: 16,
            color: MyConstant.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'พบในพื้นที่: '
          'ต.${_foundInsect[index].inCounty}'
          'อ.${_foundInsect[index].inDistrict}'
          'จ.${_foundInsect[index].inProvince}',
          style: GoogleFonts.prompt(
            fontSize: 14,
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
        OutlineButton(
          highlightedBorderColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 30),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onPressed: () {
            print('### PASS ID ==> ${insectLiteAllModels[index].inID}');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ShowMap2(id: insectLiteAllModels[index].inID)));
          },
          child: Text(
            "แผนที่",
            style: GoogleFonts.prompt(
              color: MyConstant.dark,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeader(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
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
                      fontSize: 14,
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
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditInsectLite(id: _foundInsect[index].inID),
                  ),
                ).then(
                  (value) => loadInsectLiteFromAPI(),
                );
              },
              icon: Icon(
                FontAwesomeIcons.penToSquare,
                color: MyConstant.dark2,
                size: 20,
              ),
            ),
            IconButton(
              onPressed: () async {
                await _myDialogDel(index);
                // MyDialog(funcAction: functionDelete)
                //     .deleteDialog(context, insectAllModels[index].inID);
              },
              icon: Icon(
                FontAwesomeIcons.xmark,
                color: MyConstant.dark2,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFloatButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Post(),
          ),
        ).then((value) => loadInsectLiteFromAPI());
      },
      label: Text(
        'เพิ่มข้อมูล',
        style: GoogleFonts.prompt(
          fontWeight: FontWeight.w400,
          color: MyConstant.light,
        ),
      ),
      icon: Icon(
        FontAwesomeIcons.add,
        color: MyConstant.light,
      ),
      backgroundColor: MyConstant.dark,
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

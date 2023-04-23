import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/approve.dart';
import 'package:project001/model/insectLiteAll_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonDetail2.dart';
import 'package:project001/widgets/show_ButtonMap2.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InsectLite extends StatefulWidget {
  const InsectLite({Key? key}) : super(key: key);

  @override
  State<InsectLite> createState() => _InsectLiteState();
}

class _InsectLiteState extends State<InsectLite> {
  List<InsectLiteAllModel> insectLiteAllModels = [];
  bool haveData = false;
  bool load = true;
  bool btnSearch = false;
  String? typeUser;
  bool status = false;
  String? btnType;
  List<InsectLiteAllModel> _foundInsect = [];

  @override
  void initState() {
    super.initState();
    checkTypeUser();
    loadInsectLiteFromAPI();
    _foundInsect = insectLiteAllModels;
    print('----------Refresh----------');
  }

  Future<Null> checkTypeUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    typeUser = preferences.getString('type');
  }

  Future<Null> loadInsectLiteFromAPI() async {
    if (insectLiteAllModels.length != 0) {
      insectLiteAllModels.clear();
    }
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
      body: load
          ? ShowProgress()
          : LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                behavior: HitTestBehavior.opaque,
                child: Center(
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildBtnApprove(BuildContext context, int index) {
    return RaisedButton(
      onPressed: () async {
        print('### PASS ID ==> ${insectLiteAllModels[index].inID}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Approve(id: insectLiteAllModels[index].inID),
          ),
        ).then((value) => loadInsectLiteFromAPI());
      },
      color: Colors.yellow[700],
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "ยืนยัน",
        style: GoogleFonts.prompt(
          color: MyConstant.dark2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildSearchTextField(double size) {
    return Container(
      padding: EdgeInsets.only(right: 8, left: 8, bottom: 8),
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
            fontSize: 14,
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
        typeUser != null
            ? typeUser != 'Member'
                ? buildBtnApprove(context, index)
                : ShowButtonDetail2(id: _foundInsect[index].inID)
            : ShowButtonDetail2(id: _foundInsect[index].inID),
        SizedBox(width: 2.0),
        ShowButtonMap2(id: _foundInsect[index].inID),
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
        ),
        // typeUser != null
        //     ? typeUser != 'Member'
        //         ? Row(
        //             children: [
        //               IconButton(
        //                 onPressed: () {
        //                   Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                       builder: (context) =>
        //                           Approve(id: insectLiteAllModels[index].inID),
        //                     ),
        //                   );
        //                 },
        //                 icon: Icon(FontAwesomeIcons.penToSquare),
        //               ),
        //             ],
        //           )
        //         : Container()
        //     : Container()
      ],
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
                ' | ข้อมูลการพบแมลงแพร่ระบาด',
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

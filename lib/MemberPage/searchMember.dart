import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/MemberPage/Edit/showInsectData.dart';
import 'package:project001/MemberPage/FeedState/showDetails1.dart';
import 'package:project001/model/epidemic_model.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class SearchMember extends StatefulWidget {
  SearchMember({Key? key}) : super(key: key);

  @override
  _SearchMemberState createState() => _SearchMemberState();
}

class _SearchMemberState extends State<SearchMember> {
  bool status = false;
  bool load1 = true;
  bool load2 = true;
  bool? haveData1;
  bool? haveData2;
  List<EpidemicModel> epidemicModels = [];
  List<InsectModel> insectModels = [];
  bool flagColor = true;

  List<InsectModel> _foundInsect = [];
  List<EpidemicModel> _foundEpidemic = [];

  @override
  initState() {
    _foundInsect = insectModels;
    _foundEpidemic = epidemicModels;
    loadInsectFromAPI();
    loadEpidemicFromAPI();
    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<InsectModel> results1 = [];
    List<EpidemicModel> results2 = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results1 = insectModels;
      results2 = epidemicModels;
    } else {
      results1 = insectModels
          .where((item) =>
              item.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      results2 = epidemicModels
          .where((item) =>
              item.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    setState(() {
      _foundInsect = results1;
      _foundEpidemic = results2;
    });
  }

  Future<Null> loadInsectFromAPI() async {
    if (insectModels.length != 0) {
      insectModels.clear();
    } else {}

    String apiGetValues =
        '${MyConstant.domain}/insectFile/getInsectData.php?isAdd=true';

    await Dio().get(apiGetValues).then((value) {
      //print('value ==> $value');
      if (value.toString() == 'null') {
        // No Data
        print('No Data1');
        setState(() {
          //load1 = false;
          //haveData1 = true;
        });
      } else {
        // Have Data
        setState(() {
          load1 = false;
          haveData1 = true;
        });
        print('Have Data 1');
        for (var item in json.decode(value.data)) {
          //EpidemicModel model = EpidemicModel.fromMap(item);
          InsectModel model = InsectModel.fromMap(item);
          setState(() {
            insectModels.add(model);
          });
        }
      }
    });
  }

  Future<Null> loadEpidemicFromAPI() async {
    if (epidemicModels.length != 0) {
      epidemicModels.clear();
    } else {}

    String apiGetValues =
        '${MyConstant.domain}/insectFile/getInsectlite.php?isAdd=true';

    await Dio().get(apiGetValues).then((value) {
      //print('value ==> $value');
      if (value.toString() == 'null') {
        // No Data
        print('No Data');
        setState(() {
          //load2 = false;
          //haveData2 = true;
        });
      } else {
        // Have Data
        print('Have Data');
        setState(() {
          load1 = false;
          haveData1 = true;
        });
        for (var item in json.decode(value.data)) {
          EpidemicModel model = EpidemicModel.fromMap(item);
          setState(() {
            epidemicModels.add(model);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        status = false;
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        /* appBar: AppBar(
          title: Text("ค้นหา", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),*/
        body: load1
            ? ShowProgress()
            : haveData1!
                ? SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) => Column(
                        children: [
                          buildSearchTextField(size),
                          Container(
                            padding:
                                EdgeInsets.only(left: 5, right: 5, bottom: 5),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //provide all the things u want to horizontally scroll here
                                    buildMenu1(),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    buildMenu2(),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    buildMenu3(),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    buildMenu4(),
                                  ]),
                            ),
                          ),
                          buidIconSelect(size),
                          flagColor
                              ? buildInsectData(context, size, constraints)
                              : buildInsectLite(context, size)
                        ],
                      ),
                    ),
                  )
                : Container(
                    child: Center(
                      child: Text('No Data'),
                    ),
                  ),
      ),
    );
  }

  Expanded buildInsectData(
      BuildContext context, double size, BoxConstraints constraints) {
    return haveData1!
        ? Expanded(
            child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Container(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (constraints.maxWidth > 412) ? 4 : 3,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                ),
                itemCount: _foundInsect.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    key: ValueKey(_foundInsect[index].id),
                    builder: (context, constraints) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ShowDetails1(insectModel: insectModels[index]),
                          ),
                        ).then((value) => loadInsectFromAPI());
                        //showInsectLiteFormIndex(context);
                      },
                      child: Container(
                        width: constraints.maxWidth * 0.5,
                        height: constraints.maxWidth * 0.4,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: createUrl(_foundInsect[index].img),
                          placeholder: (context, url) => ShowProgress(),
                          errorWidget: (context, url, error) =>
                              ShowImage(path: MyConstant.image1),
                        ),
                      ),
                    ),
                  ); //Image.asset(MyConstant.image, fit: BoxFit.cover),
                },
              ),
            ),
          ))
        : Expanded(
            child: Container(
            child: Center(
              child: Text('No Data'),
            ),
          ));
  }

  Expanded buildInsectLite(BuildContext context, double size) {
    return Expanded(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          itemCount: _foundEpidemic.length,
          itemBuilder: (context, index) {
            return LayoutBuilder(
              key: ValueKey(_foundEpidemic[index].id),
              builder: (context, constraints) => Container(
                padding: EdgeInsets.only(bottom: 4),
                child: Column(
                  children: [
                    Divider(
                      color: Colors.grey.shade100,
                      thickness: 1,
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: constraints.maxWidth - 160,
                              child: Text(
                                '${_foundEpidemic[index].name}',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              width: size * 0.6,
                              child: Text(
                                '${_foundEpidemic[index].date}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: createUrl(_foundEpidemic[index].img),
                              placeholder: (context, url) => ShowProgress(),
                              errorWidget: (context, url, error) =>
                                  ShowImage(path: MyConstant.image1),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    width: size * 0.3,
                                    height: size * 0.3,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  SizedBox buidIconSelect(double size) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: flagColor ? Colors.white : Colors.grey[300],
            ),
            width: size * 0.5,
            child: IconButton(
              onPressed: () {
                setState(() {
                  flagColor = true;
                });
              },
              icon: Text(
                'ข้อมูลแมลง',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: flagColor ? Colors.grey[300] : Colors.white,
            ),
            width: size * 0.5,
            child: IconButton(
              onPressed: () {
                setState(() {
                  flagColor = false;
                });
              },
              icon: Text(
                'ข้อมูลการพบแมลง',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String createUrl(String string) {
    /// เอาภาพเดียว
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    String url = '${MyConstant.domain}/insectFile${strings[0]}';

    return url;
  }

  RaisedButton buildMenu4() {
    return RaisedButton(
      onPressed: () async {},
      color: MyConstant.light,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "ราก",
        style: GoogleFonts.prompt(
          color: Colors.black,
        ),
      ),
    );
  }

  RaisedButton buildMenu3() {
    return RaisedButton(
      onPressed: () async {},
      color: MyConstant.primary,
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "ลำต้น",
        style: GoogleFonts.prompt(
          color: Colors.white,
        ),
      ),
    );
  }

  RaisedButton buildMenu2() {
    return RaisedButton(
      onPressed: () async {},
      color: MyConstant.dark,
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "ยอดอ่อน",
        style: GoogleFonts.prompt(
          color: Colors.white,
        ),
      ),
    );
  }

  RaisedButton buildMenu1() {
    return RaisedButton(
      onPressed: () async {},
      color: MyConstant.dark2,
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "ใบ",
        style: GoogleFonts.prompt(
          color: Colors.white,
        ),
      ),
    );
  }

  Container buildSearchTextField(double size) {
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
                color: Colors.grey[200],
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
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(FontAwesomeIcons.search),
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
}

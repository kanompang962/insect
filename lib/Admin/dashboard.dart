import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:project001/Admin/listInsectData.dart';
import 'package:project001/Admin/listInsectLite.dart';
import 'package:project001/Admin/listUser.dart';
import 'package:project001/Components/showMapAll.dart';
import 'package:project001/model/insectLite_model.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, double> dataMap = {};
  Map<String, double> itemMap = {};
  double total = 0;

  bool pie = false;

  final gradientList = <List<Color>>[
    [
      Color.fromRGBO(223, 250, 92, 1),
      Color.fromRGBO(129, 250, 112, 1),
    ],
    [
      Color.fromRGBO(129, 182, 205, 1),
      Color.fromRGBO(91, 253, 199, 1),
    ],
    [
      Color.fromRGBO(175, 63, 62, 1.0),
      Color.fromRGBO(254, 154, 92, 1),
    ],
    [
      Color.fromRGBO(229, 110, 250, 1.0),
      Color.fromRGBO(141, 82, 179, 1),
    ]
  ];

  List<InsectLiteModel> insectLiteModels = [];
  List<InsectModel> insectModels = [];
  List<UserModel> userModels = [];

  bool load1 = true;
  bool load2 = true;
  bool load3 = true;
  bool haveData1 = true;
  bool haveData2 = true;
  bool haveData3 = true;

  final Set<Marker> markers = new Set();
  double lat = 15.8700;
  double lng = 100.9925;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setPieChar();
    loadUserFromAPI();
    loadInsectFromAPI();
    loadInsectLiteFromAPI();
  }

  Future<Null> setPieChar() async {
    if (dataMap.length != 0) {
      dataMap.clear();
    } else {}
    String apiGet =
        '${MyConstant.domain}/insectFile/getInsectCountType.php?isAdd=true';
    try {
      await Dio().get(apiGet).then(
        (value) {
          if (json.decode(value.data) == null) {
            // print('value = empty');
          } else {
            // print('value = $value');
            for (var item in json.decode(value.data)) {
              setState(() {
                int count = int.parse(item['count']);
                String name = item['nameTH'].toString();
                print('### name:$name count:$count');
                dataMap[name] = count.toDouble();
                total += count;
              });
            }
            setState(() {
              pie = true;
            });
            print('### dataMap length ==> ${dataMap.length}');
            print('### dataMap ==> $dataMap');
          }
        },
      );
    } catch (e) {
      return MyDialog().warningDialog(
          context,
          'เกิดข้อผิดพลาด ข้อมูลประเภทแมลง',
          'something went wrong cause the program to be inoperable');
    }
  }

  Future<Null> loadInsectFromAPI() async {
    if (insectModels.length != 0) {
      insectModels.clear();
    } else {}
    String apiGet =
        '${MyConstant.domain}/insectFile/getInsectData.php?isAdd=true';
    try {
      await Dio().get(apiGet).then(
        (value) {
          if (json.decode(value.data) == null) {
            // print('value = empty');
          } else {
            // print('value = $value');
            for (var item in json.decode(value.data)) {
              InsectModel model = InsectModel.fromMap(item);
              setState(() {
                insectModels.add(model);
              });
            }
            print('### InsectModels length ==> ${insectModels.length}');
          }
        },
      );
    } catch (e) {
      return MyDialog().warningDialog(
          context,
          'เกิดข้อผิดพลาด ข้อมูลแมลงทั้งหมด',
          'something went wrong cause the program to be inoperable');
    }
  }

  Future<Null> loadInsectLiteFromAPI() async {
    if (insectLiteModels.length != 0) {
      insectLiteModels.clear();
    } else {}
    String apiGet =
        '${MyConstant.domain}/insectFile/getInsectLite.php?isAdd=true';
    try {
      await Dio().get(apiGet).then(
        (value) {
          if (json.decode(value.data) == null) {
            // print('value = empty');
            setState(() {
              load2 = false;
              haveData2 = true;
            });
          } else {
            // print('value = $value');
            for (var item in json.decode(value.data)) {
              InsectLiteModel model = InsectLiteModel.fromMap(item);
              setState(() {
                insectLiteModels.add(model);
              });
            }
            print('### insectLiteModels length ==> ${insectLiteModels.length}');
          }
        },
      );
    } catch (e) {
      return MyDialog().warningDialog(
          context,
          'เกิดข้อผิดพลาด ข้อมูลพบการแพร่ระบาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  Future<Null> loadUserFromAPI() async {
    if (userModels.length != 0) {
      userModels.clear();
    } else {}
    String apiGet = '${MyConstant.domain}/insectFile/getUser.php?isAdd=true';
    try {
      await Dio().get(apiGet).then(
        (value) {
          if (json.decode(value.data) == null) {
            // print('value = empty');
            setState(() {
              load3 = false;
              haveData3 = true;
            });
          } else {
            // print('value = $value');
            for (var item in json.decode(value.data)) {
              UserModel model = UserModel.fromMap(item);
              setState(() {
                userModels.add(model);
              });
            }
            print('### userModels length ==> ${userModels.length}');
          }
        },
      );
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด ข้อมูลผู้ใช้',
          'something went wrong cause the program to be inoperable');
    }
  }

  @override
  Widget build(BuildContext context) {
    double sizeWidth = MediaQuery.of(context).size.width;
    double sizeHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: buildAppbar(),
      backgroundColor: Colors.grey[300],
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: Container(
            padding: EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 14),
            width: (constraints.maxWidth > 412)
                ? (constraints.maxWidth * 0.8)
                : constraints.maxWidth,
            child: Column(
              children: [
                buildHeader(constraints), //Flexible
                SizedBox(
                  height: 8,
                ),
                buildPieChart(),
                SizedBox(
                  height: 8,
                ),
                buildMap(constraints),
                SizedBox(
                  height: 8,
                ),
                buildFooter(constraints, sizeWidth, sizeHeight),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          ),
        ),
      ),
    );
  }

  Flexible buildMap(BoxConstraints constraints) {
    return Flexible(
      flex: 4,
      fit: FlexFit.tight,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowMapAll(),
            ),
          );
        },
        child: Container(
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Image.asset(
            MyConstant.map,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Flexible buildPieChart() {
    return Flexible(
      flex: 4,
      fit: FlexFit.tight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: pie
            ? PieChart(
                dataMap: dataMap,
                chartType: ChartType.disc,
                baseChartColor: Colors.grey[50]!.withOpacity(0.15),
                gradientList: gradientList,
                emptyColorGradient: [
                  Color(0xff6c5ce7),
                  Colors.blue,
                ],
                chartValuesOptions: ChartValuesOptions(
                  showChartValuesInPercentage: true,
                ),
                totalValue: total,
              )
            : ShowProgress(),
      ),
    );
  }

  Flexible buildFooter(
      BoxConstraints constraints, double sizeWidth, double sizeHeight) {
    return Flexible(
      flex: 2,
      fit: FlexFit.tight,
      child: Row(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListUser(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Container(
                          child: Text(
                            'ข้อมูลผู้ใช้',
                            style: GoogleFonts.prompt(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: userModels.length,
                          itemBuilder: (context, index) {
                            return LayoutBuilder(
                              key: ValueKey(userModels[index].id),
                              builder: (context, constraints) =>
                                  CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          '${MyConstant.domain}${userModels[index].img}',
                                      placeholder: (context, url) =>
                                          ShowImage(path: MyConstant.avatar),
                                      errorWidget: (context, url, error) =>
                                          ShowImage(path: MyConstant.avatar),
                                      imageBuilder: (context, imageProvider) =>
                                          CircleAvatar(
                                            backgroundImage: imageProvider,
                                          )),
                            );
                          },
                        ),
                      ),
                      // Flexible(
                      //   flex: 2,
                      //   fit: FlexFit.tight,
                      //   child: Container(),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromRGBO(0, 0, 0, 0),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 8),
                child: Column(
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Row(
                        children: [
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color.fromRGBO(150, 150, 150, 0.5),
                              ),
                              child: Center(
                                child: Icon(
                                  FontAwesomeIcons.seedling,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color.fromRGBO(150, 150, 150, 1),
                              ),
                              child: Center(
                                child: Icon(
                                  FontAwesomeIcons.virus,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Row(
                        children: [
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color.fromRGBO(150, 150, 150, 1),
                              ),
                              child: Center(
                                child: Icon(
                                  FontAwesomeIcons.tree,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color.fromRGBO(150, 150, 150, 0.5),
                              ),
                              child: Center(
                                child: Icon(
                                  FontAwesomeIcons.bacteria,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Flexible buildHeader(BoxConstraints constraints) {
    return Flexible(
      flex: 2,
      fit: FlexFit.tight,
      child: Row(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListInsectData(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${insectModels.length}',
                        style: GoogleFonts.prompt(
                          color: MyConstant.dark2,
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        'ข้อมูลแมลงทั้งหมด',
                        style: GoogleFonts.prompt(
                          color: MyConstant.dark2,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListInsectLite(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${insectLiteModels.length}',
                        style: GoogleFonts.prompt(
                          color: MyConstant.dark2,
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        'ข้อมูลพบการแพร่ระบาด',
                        style: GoogleFonts.prompt(
                          color: MyConstant.dark2,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ), //Row
    );
  }

  AppBar buildAppbar() {
    return AppBar(
      backgroundColor: Colors.grey[300],
      elevation: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                'Dashboard',
                style: GoogleFonts.lobster(
                  fontSize: 30,
                ),
              ),
              Text(
                ' | จัดการข้อมูล',
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

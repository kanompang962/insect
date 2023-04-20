import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/User/post.dart';
import 'package:project001/model/insectAll_model.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonDetail.dart';
import 'package:project001/widgets/show_ButtonMap.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool load1 = true;
  bool load2 = true;
  bool? haveData1;
  bool? haveData2;
  List<InsectModel> insectModels = [];
  List<InsectAllModel> insectAllModels = [];
  String? typeUser;

  @override
  void initState() {
    super.initState();
    loadAllFromAPI();
    checkTypeUser();
    print('----------Refresh----------');
  }

  Future<Null> checkTypeUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    typeUser = preferences.getString('type');
  }

  Future<Null> loadAllFromAPI() async {
    if (insectAllModels.length != 0) {
      insectAllModels.clear();
    } else {}
    String apiGetAllInsectData =
        '${MyConstant.domain}/insectFile/getAllInsectData.php?isAdd=true';
    try {
      await Dio().get(apiGetAllInsectData).then(
        (value) {
          if (json.decode(value.data) == null) {
            // print('value = empty');
          } else {
            // print('value = $value');
            for (var item in json.decode(value.data)) {
              InsectAllModel model = InsectAllModel.fromMap(item);
              setState(() {
                insectAllModels.add(model);
              });
            }
            setState(() {
              load1 = false;
              haveData1 = true;
            });
            print('### value length ==> ${insectAllModels.length}');
          }
        },
      );
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: buildAppbar(),
      body: load1
          ? ShowProgress()
          : LayoutBuilder(
              builder: (context, constraints) => Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            itemCount: insectAllModels.length,
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
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child:
                                                buildCenter(index, constraints),
                                          ),
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

  Widget buildDetails(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${insectAllModels[index].inName}',
          style: GoogleFonts.prompt(
            fontSize: 16,
            color: MyConstant.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${insectAllModels[index].inDetails}',
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
      imageUrl: MyConstant().subImage(insectAllModels[index].inImg),
      placeholder: (context, url) => ShowImage(path: MyConstant.image),
      errorWidget: (context, url, error) => ShowImage(path: MyConstant.image),
      imageBuilder: (context, imageProvider) => Container(
        height: constraints.maxWidth / 1.2,
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
        ShowButtonDetail(id: insectAllModels[index].inID),
        SizedBox(width: 2.0),
        ShowButtonMap(id: insectAllModels[index].inID),
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
              imageUrl: '${MyConstant.domain}${insectAllModels[index].usImg}',
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
                    "${insectAllModels[index].usName}",
                    style: GoogleFonts.prompt(
                      fontSize: 14,
                      color: MyConstant.dark2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${insectAllModels[index].usEmail}",
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
      ],
    );
  }

  AppBar buildAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Text(
            'Insect',
            style: GoogleFonts.lobster(
              fontSize: 30,
            ),
          ),
          Text(
            ' | ข้อมูลแมลง',
            style: GoogleFonts.prompt(
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        typeUser != null
            ? IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Post(),
                    ),
                  ).then((value) => loadAllFromAPI());
                },
                icon: Icon(FontAwesomeIcons.plusSquare),
              )
            : Container()
      ],
    );
  }
}

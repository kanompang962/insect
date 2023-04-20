import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/showMap2.dart';
import 'package:project001/Member/editInsectLite.dart';
import 'package:project001/model/insectLite_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class ShowInsectLite extends StatefulWidget {
  final InsectLiteModel insectLiteModel;
  const ShowInsectLite({Key? key, required this.insectLiteModel})
      : super(key: key);

  @override
  State<ShowInsectLite> createState() => _ShowInsectLiteState();
}

class _ShowInsectLiteState extends State<ShowInsectLite> {
  bool? haveData;
  bool load = true;
  InsectLiteModel? insectLiteModel;
  InsectLiteModel? insectLiteModelAPI;
  int currentIndex = 0;
  String? typeUser;
  final PageController controller = PageController();
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    loadValueFromAPI();
  }

  Future<Null> loadValueFromAPI() async {
    insectLiteModel = widget.insectLiteModel;
    String apiGetInsectWhereId =
        '${MyConstant.domain}/insectFile/getInsectLiteWhereIDInsect.php?isAdd=true&id=${insectLiteModel!.id}';

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
          insectLiteModelAPI = InsectLiteModel.fromMap(item);
          subImageX(insectLiteModelAPI!.img);
        }
      }
    });
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
              ? Stack(
                  children: [
                    SingleChildScrollView(
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
                                  padding: EdgeInsets.symmetric(horizontal: 0),
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
                  ],
                )
              : ShowProgress(),
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

// Widget
  Widget buildFloatButtonMap(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowMap2(id: insectLiteModelAPI!.id),
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

  Widget buildDetails(double size) {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${insectLiteModelAPI!.name}',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Text(
            'รายละเอียด:',
            style: GoogleFonts.prompt(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: MyConstant.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Divider(color: MyConstant.primary, thickness: 1, height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'พบในพื้นที่ ต.${insectLiteModelAPI!.county} '
                'อ.${insectLiteModelAPI!.district} '
                'จ.${insectLiteModelAPI!.province} ',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
                //maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'วันที่ ${insectLiteModelAPI!.date}',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
              Text(
                'เวลา ${insectLiteModelAPI!.time}',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 14),
                width: size * 1,
                height: size * 0.2,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'สถานะรอยืนยันจากผู้เชี่ยวชาญ',
                      style: GoogleFonts.prompt(
                        fontSize: 16,
                        color: Colors.red[700],
                      ),
                    ),
                    Text(
                      '(Expert confirmation pending status)',
                      style: GoogleFonts.prompt(
                        fontSize: 16,
                        color: Colors.red[700],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          // Divider(color: Colors.white, thickness: 0, height: 12),
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

  subImageX(String string) {
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

  AppBar buildAppbar(double size) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      title: Text(
        'ข้อมูลแมลงที่พบ',
        style: GoogleFonts.prompt(
          fontSize: 16,
        ),
      ),
      actions: [
        /*IconButton(
          onPressed: () {
            confirmDialogDelete(context);
          },
          icon: Icon(Icons.delete),
        ),*/
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
  Future<void> _functionDel(BuildContext context) async {
    String apiDeleteProductWhereId =
        '${MyConstant.domain}/insectFile/deleteInsectLiteWhereID.php?isAdd=true&id=${insectLiteModelAPI!.id}';
    await Dio().get(apiDeleteProductWhereId).then(
      (value) {
        Navigator.pop(context);
        loadValueFromAPI().then(
          (value) => Navigator.pop(context),
        );
      },
    );
  }

// Show Bottom Sheet
  Future<void> showBottomSheet(double size) {
    return showModalBottomSheet<void>(
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
        print('## Confirm Delete at id ==> ${insectLiteModelAPI!.id}');
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditInsectLite(id: insectLiteModel!.id),
          ),
        ).then((value) {
          images.clear();
          loadValueFromAPI();
          Navigator.pop(context);
        });
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

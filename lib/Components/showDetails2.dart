import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/showMap2.dart';
import 'package:project001/model/insectLiteAll_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';

class ShowDetails2 extends StatefulWidget {
  final String id;
  const ShowDetails2({Key? key, required this.id}) : super(key: key);

  @override
  State<ShowDetails2> createState() => _ShowDetails2State();
}

class _ShowDetails2State extends State<ShowDetails2> {
  bool haveData = false;
  bool load = true;
  String? id;
  InsectLiteAllModel? insectLiteAllModelAPI;
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
    String getAllInsectLite =
        '${MyConstant.domain}/insectFile/getAllInsectLiteWhereID.php?isAdd=true&id=$id';
    try {
      await Dio().get(getAllInsectLite).then((value) {
        if (value.toString() == 'null') {
          // No Value
        } else {
          // Have Value
          for (var item in json.decode(value.data)) {
            insectLiteAllModelAPI = InsectLiteAllModel.fromMap(item);
            subImageX(insectLiteAllModelAPI!.inImg);
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
      backgroundColor: Colors.white,
      appBar: buildAppbar(),
      floatingActionButton: buildFloatButtonMap(context),
      body: load
          ? ShowProgress()
          : haveData
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
                                            ShowImage(path: MyConstant.image),
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

  Widget buildFloatButtonMap(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowMap2(id: insectLiteAllModelAPI!.inID),
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
              textStyle: MyConstant().h2Style(Colors.black)),
        ],
      ),
    );
  }

  Widget buildDetails(double size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${insectLiteAllModelAPI!.inName}',
                style: GoogleFonts.prompt(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'พบในพื้นที่ ต.${insectLiteAllModelAPI!.inCounty} '
                  'อ.${insectLiteAllModelAPI!.inDistrict} '
                  'จ.${insectLiteAllModelAPI!.inProvince} ',
                  style: GoogleFonts.prompt(
                    fontSize: 12,
                  ),
                  //maxLines: 10,
                  //overflow: TextOverflow.ellipsis,
                ),
                Text('วันที่ ${insectLiteAllModelAPI!.inDate}'),
                Text('เวลา ${insectLiteAllModelAPI!.inTime}'),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          // Text(
          //   'พบโดย: ',
          //   style: GoogleFonts.prompt(
          //     fontWeight: FontWeight.w400,
          //   ),
          //   overflow: TextOverflow.ellipsis,
          // ),
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

  AppBar buildAppbar() {
    return AppBar(
      title: Text(
        'ข้อมูลพบการแพร่ระบาดของแมลง',
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

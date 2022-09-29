import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/MemberPage/FeedState/showMap2.dart';
import 'package:project001/model/epidemic_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';

class ShowDetails2 extends StatefulWidget {
  final EpidemicModel epidemicModel;
  const ShowDetails2({Key? key, required this.epidemicModel}) : super(key: key);

  @override
  State<ShowDetails2> createState() => _ShowDetails2State();
}

class _ShowDetails2State extends State<ShowDetails2> {
  bool? haveData;
  bool load = true;
  EpidemicModel? epidemicModel;
  EpidemicModel? epidemicModelAPI;
  int currentIndex = 0;
  final PageController controller = PageController();

  List<String> images = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    epidemicModel = widget.epidemicModel;
    load = false;
    haveData = true;
    createUrl(epidemicModel!.img);
    //loadValueFromAPI();
  }

  /*Future<Null> loadValueFromAPI() async {
    epidemicModel = widget.epidemicModel;
    String apiGetInsectWhereId =
        '${MyConstant.domain}/insectFile/getInsectLiteWhereIDInsect.php?isAdd=true&id=${epidemicModel!.id}';

    await Dio().get(apiGetInsectWhereId).then((value) {
      //print('value ==> $value');
      if (value.toString() == 'null') {
        // No Data
        setState(() {
          load = false;
          haveData = false;
        });
      } else {
        load = false;
        haveData = true;
        // Have Data
        for (var item in json.decode(value.data)) {
          epidemicModelAPI = EpidemicModel.fromMap(item);
          print(
              '### From API ==>> ${epidemicModelAPI!.id} ${epidemicModelAPI!.name}');
          createUrl(epidemicModelAPI!.img);
        }
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppbar(),
      floatingActionButton: buildFloatButtonMap(context),
      body: load
          ? ShowProgress()
          : haveData!
              ? SingleChildScrollView(
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              child: SizedBox(
                                height: 300,
                                width: double.infinity,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: images[index % images.length],
                                  placeholder: (context, url) => ShowProgress(),
                                  errorWidget: (context, url, error) =>
                                      ShowImage(path: MyConstant.image1),
                                ), /*Image.network(
                        images[index % images.length],
                        fit: BoxFit.cover,
                      ),*/
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
                )
              : showNoData(),
    );
  }

  FloatingActionButton buildFloatButtonMap(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowMap2(epidemicModel: epidemicModelAPI!),
          ),
        );
      },
      label: Text(
        'ดูแผนที่',
        style: GoogleFonts.prompt(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      icon: const Icon(Icons.map_outlined),
      backgroundColor: MyConstant.primary,
    );
  }

  Center showNoData() {
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

  Container buildDetails(double size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${epidemicModel!.name}',
                style: GoogleFonts.prompt(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          //Divider(color: MyConstant.primary, thickness: 3, height: 10),
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
                  'สถานที่พบแมลง:  ตำบล:${epidemicModel!.county} อำเภอ:${epidemicModel!.district} จังหวัด:${epidemicModel!.province}',
                  style: GoogleFonts.prompt(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  //overflow: TextOverflow.ellipsis,
                ),
                Text(
            'วันที่:  ${epidemicModel!.date}',
            style: GoogleFonts.prompt(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            'เวลา:  ${epidemicModel!.time}',
            style: GoogleFonts.prompt(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
              ],
            ),
          ),
          
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

  createUrl(String string) {
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    String url;
    int i = 0;

    for (var item in strings) {
      url = '${MyConstant.domain}/insectFile$item';
      //EpidemicModel model = EpidemicModel.fromMap(item)
      setState(() {
        images.add(url);
        //print('### url ==>> ${images[i]}');
        i++;
      });
    }
  }

  AppBar buildAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project001/model/insectLite_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonCancel.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class EditInsectLite extends StatefulWidget {
  final String id;
  const EditInsectLite({Key? key, required this.id}) : super(key: key);

  @override
  State<EditInsectLite> createState() => _EditInsectLiteState();
}

class _EditInsectLiteState extends State<EditInsectLite> {
  bool load = true;
  String? id;
  InsectLiteModel? insectLiteModelAPI;
  int currentIndex = 0;
  final PageController controller = PageController();
  List<String> images = [];

  final formKey = GlobalKey<FormState>();
  List<File?> files = [];
  bool statusImg = false;
  int selectIndex = 0;

  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController countyController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadValueFromAPI();
    initialFile();
  }

  Future<Null> loadValueFromAPI() async {
    id = widget.id;
    String apiGetInsectWhereId =
        '${MyConstant.domain}/insectFile/getInsectLiteWhereIDInsect.php?isAdd=true&id=$id';
    try {
      await Dio().get(apiGetInsectWhereId).then((value) {
        //print('value ==> $value');
        if (value.toString() == 'null') {
          // No Data
          print('### GET API InsectLite ==> null');
        } else {
          // Have Data
          print('### GET API InsectLite ==> true');
          for (var item in json.decode(value.data)) {
            insectLiteModelAPI = InsectLiteModel.fromMap(item);
          }
          subImageX(insectLiteModelAPI!.img);
          nameController.text = insectLiteModelAPI!.name;
          dateController.text = insectLiteModelAPI!.date;
          timeController.text = insectLiteModelAPI!.time;
          countyController.text = insectLiteModelAPI!.county;
          districtController.text = insectLiteModelAPI!.district;
          provinceController.text = insectLiteModelAPI!.province;
          latController.text = insectLiteModelAPI!.lat;
          longController.text = insectLiteModelAPI!.lng;
          setState(() {
            load = false;
          });
        }
      });
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  void subImageX(String image) {
    String result = image.substring(1, image.length - 1);
    List<String> strings = result.split(',');
    for (var item in strings) {
      images.add(item.trim());
    }
  }

  void initialFile() {
    for (var i = 0; i < 4; i++) {
      files.add(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buidAppbar(),
      body: load
          ? ShowProgress()
          : LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          buildImage(constraints),
                          Container(
                            width: size * 0.7,
                            padding: EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: [
                                buildTextName(),
                                buildTextTime(),
                                buildTextDate(),
                                buildTextCounty(),
                                buildTextDistrict(),
                                buildTextProvince(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildTextLat(constraints),
                                    buildTextLng(constraints),
                                  ],
                                )
                              ],
                            ),
                          ),
                          buildFooter(size),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

// Select Images

  Future<Null> processImagePicker(ImageSource source, int index) async {
    try {
      var result = await ImagePicker().getImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );

      setState(() {
        files[index] = File(result!.path);
        selectIndex = index;
        statusImg = true;
      });
    } catch (e) {}
  }

  Future<Null> chooseSourceImageDialog(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: ListTile(
          leading: Image.asset(
            MyConstant.image,
            color: MyConstant.dark,
          ),
          title: Text(
            'เลือกภาพแมลง ${index + 1}',
            style: GoogleFonts.prompt(
              color: MyConstant.dark,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            'Please Tab on Camera or Gallery',
            style: GoogleFonts.prompt(
              color: MyConstant.dark2,
              fontSize: 10,
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  processImagePicker(ImageSource.camera, index);
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: MyConstant.dark2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Camera',
                    style: GoogleFonts.prompt(
                      color: MyConstant.dark2,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  processImagePicker(ImageSource.gallery, index);
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: MyConstant.dark2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Gallery',
                    style: GoogleFonts.prompt(
                      color: MyConstant.dark2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Function

  Future<Null> processSaveValue() async {
    if (formKey.currentState!.validate()) {
      MyDialog().showProgressDialog(context);
      String name = nameController.text;
      String date = dateController.text;
      String time = timeController.text;
      String county = countyController.text;
      String district = districtController.text;
      String province = provinceController.text;
      String lat = latController.text;
      String lng = longController.text;
      String imagePath;

      if (statusImg) {
        // แก้ไขภาพ เอา url ภาพใหม่
        int index = 0;
        for (var item in files) {
          if (item != null) {
            int i = Random().nextInt(1000000);
            String nameImage = 'fileEdit$i.jpg';
            String apiSaveFile = '${MyConstant.domain}/insectFile/saveFile.php';
            Map<String, dynamic> map = {};
            map['file'] =
                await MultipartFile.fromFile(item.path, filename: nameImage);
            FormData formData = FormData.fromMap(map);
            await Dio().post(apiSaveFile, data: formData).then((value) {
              print('Upload Success');
              images[index] = '/file/$nameImage';
            });
          } else {}
          index++;
        }
        imagePath = images.toString();
      } else {
        // ไม่ได้แก้ไขภาพ เอา url ภาพเดิม
        imagePath = images.toString();
      }
      print(
          '## SaveID ==> $id $name $date $time $county $district $province $lat $lng');
      print('## Images ==> $imagePath');
      print('## StatusImage ==> $statusImg');

      String path =
          '${MyConstant.domain}/insectFile/editInsectLiteWhereID.php?isAdd=true&id=$id&img=$imagePath&name=$name&date=$date&time=$time&county=$county&district=$district&province=$province&lat=$lat&lng=$lng';

      await Dio().get(path).then((value) => Navigator.pop(context));
      MyDialog().successDialog(context, 'เรียบรอย', 'Data has been edited.');
    }
  }

// Widget

  AppBar buidAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'แก้ไขแมลงที่พบ',
        style: GoogleFonts.prompt(
          fontSize: 16,
          //fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget buildImage(BoxConstraints constraints) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          width: constraints.maxWidth,
          height: constraints.maxWidth * 0.6,
          child: images == null
              ? Image.asset(
                  MyConstant.image,
                  color: Colors.grey,
                  scale: 3,
                )
              : images == null
                  ? Image.asset(MyConstant.image, color: Colors.grey)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: files[0] == null
                          ? CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  '${MyConstant.domain}/insectFile/${images[0]}',
                              placeholder: (context, url) => ShowProgress(),
                              errorWidget: (context, url, error) =>
                                  ShowImage(path: MyConstant.image),
                            )
                          : Image.file(
                              files[selectIndex]!,
                              fit: BoxFit.cover,
                            ),
                    ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          width: constraints.maxWidth * 0.54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  child: InkWell(
                    onTap: () => chooseSourceImageDialog(
                        0), //chooseSourceImageDialog(0),
                    child: images[0] == null
                        ? Image.asset(MyConstant.add, color: Colors.grey)
                        : files[0] == null
                            ? CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    '${MyConstant.domain}/insectFile/${images[0]}',
                                placeholder: (context, url) => ShowProgress(),
                                errorWidget: (context, url, error) =>
                                    ShowImage(path: MyConstant.image),
                              )
                            : Image.file(
                                files[0]!,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  child: InkWell(
                    onTap: () => chooseSourceImageDialog(
                        1), //chooseSourceImageDialog(1),
                    child: images[1] == null
                        ? Image.asset(MyConstant.add, color: Colors.grey)
                        : files[1] == null
                            ? CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    '${MyConstant.domain}/insectFile/${images[1]}',
                                placeholder: (context, url) => ShowProgress(),
                                errorWidget: (context, url, error) =>
                                    ShowImage(path: MyConstant.image),
                              )
                            : Image.file(
                                files[1]!,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  child: InkWell(
                    onTap: () => chooseSourceImageDialog(
                        2), //chooseSourceImageDialog(2),
                    child: images[2] == null
                        ? Image.asset(MyConstant.add, color: Colors.grey)
                        : files[2] == null
                            ? CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    '${MyConstant.domain}/insectFile/${images[2]}',
                                placeholder: (context, url) => ShowProgress(),
                                errorWidget: (context, url, error) =>
                                    ShowImage(path: MyConstant.image),
                              )
                            : Image.file(
                                files[2]!,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  child: InkWell(
                    onTap: () => chooseSourceImageDialog(
                        3), //chooseSourceImageDialog(3),
                    child: images[3] == null
                        ? Image.asset(MyConstant.add, color: Colors.grey)
                        : files[3] == null
                            ? CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    '${MyConstant.domain}/insectFile/${images[3]}',
                                placeholder: (context, url) => ShowProgress(),
                                errorWidget: (context, url, error) =>
                                    ShowImage(path: MyConstant.image),
                              )
                            : Image.file(
                                files[3]!,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTextName() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: nameController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'ชื่อแมลง',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget buildTextTime() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: timeController,
        onTap: () async {
          TimeOfDay? times = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (times == null) return;
          setState(() {
            timeController.text = times.format(context).toString();
          });
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'เวลาที่พบแมลง',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget buildTextDate() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: dateController,
        onTap: () async {
          DateTime? dates = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (dates == null) return;
          setState(() {
            dateController.text = dates.year.toString() +
                '/' +
                dates.month.toString() +
                '/' +
                dates.day.toString();
          });
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'วันที่พบแมลง',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget buildTextCounty() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: countyController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'ตำบลที่พบแมลง',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget buildTextDistrict() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: districtController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'อำเภอที่พบแมลง',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget buildTextProvince() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: provinceController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'จังหวัดที่พบแมลง',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget buildTextLat(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.3,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 35),
        child: TextFormField(
          keyboardType: TextInputType.number,
          controller: latController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please Fill in Blank';
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: 'ละติจูด',
            //labelStyle: MyConstant().h3Style(Colors.lightGreen),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        ),
      ),
    );
  }

  Widget buildTextLng(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.3,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 35),
        child: TextFormField(
          keyboardType: TextInputType.number,
          controller: longController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please Fill in Blank';
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: 'ลองจิจูด',
            //labelStyle: MyConstant().h3Style(Colors.lightGreen),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        ),
      ),
    );
  }

  Widget buidLat(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.3,
      child: TextFormField(
        controller: latController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill Lat in Blank';
          } else {
            return null;
          }
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelStyle: MyConstant().h3Style(Colors.black),
          labelText: 'ละติจูด :',
          prefixIcon: Icon(
            Icons.location_on,
            color: MyConstant.dark,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.dark),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.light),
            borderRadius: BorderRadius.circular(20),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget buidLng(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.3,
      child: TextFormField(
        controller: longController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill Long in Blank';
          } else {
            return null;
          }
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelStyle: MyConstant().h3Style(Colors.black),
          labelText: 'ลองจิจูด :',
          prefixIcon: Icon(
            Icons.location_on,
            color: MyConstant.dark,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.dark),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.light),
            borderRadius: BorderRadius.circular(20),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget buidButtonSave() {
    return RaisedButton(
      onPressed: () {
        processSaveValue();
      },
      color: MyConstant.primary,
      padding: EdgeInsets.symmetric(horizontal: 50),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Text(
        "บันทึก",
        style: GoogleFonts.prompt(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildFooter(double size) {
    return Container(
      width: size * 0.9,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ShowButtonCancel(),
          buidButtonSave(),
        ],
      ),
    );
  }
}

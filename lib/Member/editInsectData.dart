import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonCancel.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class EditInsectData extends StatefulWidget {
  final String id;
  const EditInsectData({Key? key, required this.id}) : super(key: key);

  @override
  State<EditInsectData> createState() => _EditInsectDataState();
}

class _EditInsectDataState extends State<EditInsectData> {
  bool load = true;
  bool loadType = true;
  String? id;
  InsectModel? insectModelAPI;
  int currentIndex = 0;
  final PageController controller = PageController();
  List<String> images = [];

  final formKey = GlobalKey<FormState>();
  List<File?> files = [];
  bool statusImg = false;
  int selectIndex = 0;
  List<String> itemList = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController protectController = TextEditingController();
  // String? date;
  String? typeValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadValueFromAPI();
    initialFile();
  }

  Future<Null> loadValueFromAPI() async {
    id = widget.id;
    String apiGetInsectWhereId =
        '${MyConstant.domain}/insectFile/getInsectDataWhereIDInsect.php?isAdd=true&id=$id';

    await Dio().get(apiGetInsectWhereId).then((value) {
      //print('value ==> $value');
      if (value.toString() == 'null') {
        // No Data
        print('### GET API InsectData ==> null');
      } else {
        // Have Data
        print('### GET API InsectData ==> true');
        for (var item in json.decode(value.data)) {
          insectModelAPI = InsectModel.fromMap(item);
        }
        nameController.text = insectModelAPI!.name;
        detailsController.text = insectModelAPI!.details;
        protectController.text = insectModelAPI!.protect;
        latController.text = insectModelAPI!.lat;
        lngController.text = insectModelAPI!.lng;
        typeValue = insectModelAPI!.type;
        timeController.text = insectModelAPI!.time;
        dateController.text = insectModelAPI!.date;
        subImageX(insectModelAPI!.img);
        setState(() {
          load = false;
        });
        print('### typeValue ==> $typeValue');
      }
    });
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
                      child: Container(
                        width: (constraints.maxWidth > 412)
                            ? (constraints.maxWidth * 0.8)
                            : constraints.maxWidth,
                        child: Column(
                          children: [
                            buildImage(constraints),
                            Container(
                              width: size * 0.8,
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildTextName(),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'รายละเอียด: ',
                                      style: GoogleFonts.prompt(
                                          color: MyConstant.primary),
                                    ),
                                  ),
                                  buildTextDetails(),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'วิธีป้องกันและกำจัด: ',
                                      style: GoogleFonts.prompt(
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ),
                                  buildTextProtect(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildTextDate(constraints),
                                      buildTextTime(constraints),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildTextLat(constraints),
                                      buildTextLng(constraints),
                                      //buildButtonDate(size),
                                    ],
                                  ),
                                  buildRadioJuiceSucker(size),
                                  buildRadioStemBorer(size),
                                  buildRadioRootFeeder(size),
                                  buildRadioLeafFeeder(size),
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
            ),
    );
  }

// Select Images
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

// Function
  Future<Null> processSaveValue() async {
    if (formKey.currentState!.validate()) {
      MyDialog().showProgressDialog(context);
      String name = nameController.text;
      String details = detailsController.text;
      String protect = protectController.text;
      String lat = latController.text;
      String date = dateController.text;
      String time = timeController.text;
      String lng = lngController.text;
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
      print('## SaveID ==> $id $name $date $time $typeValue $lat $lng');
      print('## Images ==> $imagePath');
      print('## StatusImage ==> $statusImg');

      String path =
          '${MyConstant.domain}/insectFile/editInsectDataWhereID.php?isAdd=true&id=${insectModelAPI!.id}&img=$imagePath&name=$name&details=$details&protect=$protect&date=$date&time=$time&type=${typeValue.toString()}&lat=$lat&lng=$lng';
      try {
        await Dio().get(path).then((value) => Navigator.pop(context));
        MyDialog().successDialog(context, 'เรียบร้อย', 'Data has been edited.');
      } catch (e) {
        Navigator.pop(context);
        return MyDialog().warningDialog(
            context,
            'เกิดข้อผิดพลาด แก้ไขไม่สำเร็จ',
            'something went wrong cause the program to be inoperable');
      }
    }
  }

// Widget
  AppBar buidAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'แก้ไขข้อมูลแมลง',
        style: GoogleFonts.prompt(
          fontSize: 14,
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
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: GoogleFonts.prompt(),
        controller: nameController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
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

  Widget buidLat(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: constraints.maxWidth * 0.35,
        child: TextFormField(
          style: GoogleFonts.prompt(),
          controller: latController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'กรุณากรอกข้อมูลให้ครบ';
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
      ),
    );
  }

  Widget buidLng(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: constraints.maxWidth * 0.35,
        child: TextFormField(
          style: GoogleFonts.prompt(),
          controller: lngController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'กรุณากรอกข้อมูลให้ครบ';
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
              return 'กรุณากรอกข้อมูลให้ครบ';
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
          controller: lngController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'กรุณากรอกข้อมูลให้ครบ';
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

  Widget buildTextTime(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.3,
      child: Padding(
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
              return 'กรุณากรอกข้อมูลให้ครบ';
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
      ),
    );
  }

  Widget buildTextDate(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.3,
      child: Padding(
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
              return 'กรุณากรอกข้อมูลให้ครบ';
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
      ),
    );
  }

  Widget buildTextProtect() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: GoogleFonts.prompt(
          fontSize: 14,
        ),
        maxLines: 6, //or null
        decoration: InputDecoration.collapsed(
          hintText: "วิธีป้องกันและกำจัด",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              new Radius.circular(10),
            ),
          ),
        ),
        controller: protectController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget buildTextDetails() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: GoogleFonts.prompt(
          fontSize: 14,
        ),
        maxLines: 6, //or null
        decoration: InputDecoration.collapsed(
          hintText: "รายละเอียดของแมลง",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              new Radius.circular(10),
            ),
          ),
        ),
        controller: detailsController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
          } else {
            return null;
          }
        },
      ),
    );
  }

  RadioListTile buildRadioRootFeeder(double size) {
    return RadioListTile(
      value: '3',
      groupValue: typeValue,
      onChanged: (value) {
        setState(() {
          typeValue = value;
          print('type => $typeValue');
        });
      },
      title: Text(
        'พวกกัดกินราก',
        style: GoogleFonts.prompt(),
      ),
      // ShowTitle(
      //   title: 'แมลงศัตรูพืชจำพวกกัดกินราก (root feeder)',
      //   textStyle: MyConstant().h3Style(Colors.black),
      // ),
    );
  }

  RadioListTile buildRadioStemBorer(double size) {
    return RadioListTile(
      value: '2',
      groupValue: typeValue,
      onChanged: (value) {
        setState(() {
          typeValue = value;
          print('type => $typeValue');
        });
      },
      title: Text(
        'พวกกัดกินลำต้น',
        style: GoogleFonts.prompt(),
      ),
    );
  }

  RadioListTile buildRadioJuiceSucker(double size) {
    return RadioListTile(
      value: '1',
      groupValue: typeValue,
      onChanged: (value) {
        setState(() {
          typeValue = value;
          print('type => $typeValue');
        });
      },
      title: Text(
        'พวกดูดกินน้ำเลี้ยงดอก',
        style: GoogleFonts.prompt(),
      ),
    );
  }

  RadioListTile buildRadioLeafFeeder(double size) {
    return RadioListTile(
      value: '4',
      groupValue: typeValue,
      onChanged: (value) {
        setState(() {
          typeValue = value;
          print('type => $typeValue');
        });
      },
      title: Text(
        'พวกกัดกินใบ',
        style: GoogleFonts.prompt(),
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

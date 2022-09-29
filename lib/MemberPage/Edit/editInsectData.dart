import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInsectData extends StatefulWidget {
  final InsectModel insectModel;
  const EditInsectData({Key? key, required this.insectModel}) : super(key: key);

  @override
  State<EditInsectData> createState() => _EditInsectDataState();
}

class _EditInsectDataState extends State<EditInsectData> {
  bool load = true;
  InsectModel? insectModel;
  //InsectModel? insectModelAPI;
  int currentIndex = 0;
  final PageController controller = PageController();
  List<String> images = [];

  final formKey = GlobalKey<FormState>();
  List<File?> files = [];
  bool statusImg = false;
  int selectIndex = 0;

  TextEditingController nameController = TextEditingController();
  //TextEditingController dateController = TextEditingController();
  //TextEditingController timeController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController protectController = TextEditingController();
  String? time;
  String? date;
  String? typeValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    insectModel = widget.insectModel;
    createUrl();
    initialFile();
    insertValueInController();
    nameController.text = insectModel!.name;
    detailsController.text = insectModel!.details;
    protectController.text = insectModel!.protect;
    latController.text = insectModel!.lat;
    lngController.text = insectModel!.lng;
    typeValue = insectModel!.type;
    time = insectModel!.time;
    date = insectModel!.date;
    //findInsectData();
  }

  Future<Null> insertValueInController() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String name = preferences.getString('name')!;
    String id = preferences.getString('id')!;
    print('### User $id : $name');
    print('### Product ${insectModel!.id} : ${insectModel!.name}');
  }

  void createUrl() {
    String string = insectModel!.img;
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    for (var item in strings) {
      //url = '${MyConstant.domain}/insectFile$item';
      //EpidemicModel model = EpidemicModel.fromMap(item)
      images.add(item.trim());
    }
  }

  void initialFile() {
    for (var i = 0; i < 4; i++) {
      files.add(null);
    }
  }

  /*Future<Null> findInsectData() async {
    //SharedPreferences preferences = await SharedPreferences.getInstance();
    //String name = preferences.getString('name')!;
    //String id_user = preferences.getString('id')!;
    String id = insectModel!.id;

    String apiInsectData =
        '${MyConstant.domain}/insectFile/getInsectDataWhereIDInsect.php?isAdd=true&id=$id';
    await Dio().get(apiInsectData).then((value) {
      print('value ==>> $value');
      for (var item in json.decode(value.data)) {
        setState(() {
          insectModelAPI = InsectModel.fromMap(item);
          nameController.text = insectModelAPI!.name;
          detailsController.text = insectModelAPI!.details;
          protectController.text = insectModelAPI!.protect;
          latController.text = insectModelAPI!.lat;
          lngController.text = insectModelAPI!.lng;
          typeValue = insectModelAPI!.type;
          time = insectModelAPI!.time;
          date = insectModelAPI!.date;
        });
      }
      setState(() {
        load = false;
      });
      
      createUrl();
      print('## InsectData => $insectModelAPI');
    });
  }*/

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buidAppbar(),
      body: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                            style:
                                GoogleFonts.prompt(color: MyConstant.primary),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildButtonTime(size),
                            buildButtonDate(size),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buidLat(constraints),
                            buidLng(constraints),
                            //buildButtonDate(size),
                          ],
                        ),
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
    );
  }

///////////////Edit///////////////////////////////////
///////////////Detale///////////////////////////////////
  Padding buildTextProtect() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: GoogleFonts.prompt(),
        maxLines: 10, //or null
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
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Padding buildTextDetails() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: GoogleFonts.prompt(),
        maxLines: 10, //or null
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
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Row buildRadioRootFeeder(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.6,
          child: RadioListTile(
            value: 'root_feeder',
            groupValue: typeValue,
            onChanged: (value) {
              setState(() {
                typeValue = value as String?;
                print('type => $typeValue');
              });
            },
            title: ShowTitle(
              title: 'แมลงศัตรูพืชจำพวกกัดกินราก (root feeder)',
              textStyle: MyConstant().h3Style(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Row buildRadioStemBorer(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.6,
          child: RadioListTile(
            value: 'stem_borer',
            groupValue: typeValue,
            onChanged: (value) {
              setState(() {
                typeValue = value as String?;
                print('type => $typeValue');
              });
            },
            title: ShowTitle(
              title: 'แมลงศัตรูพืชจำพวกกัดกินลำต้น (stem borer)',
              textStyle: MyConstant().h3Style(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Row buildRadioJuiceSucker(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.6,
          child: RadioListTile(
            value: 'juice_sucker',
            groupValue: typeValue,
            onChanged: (value) {
              setState(() {
                typeValue = value as String?;
                print('type => $typeValue');
              });
            },
            title: ShowTitle(
              title:
                  'แมลงศัตรูพืชจำพวกดูดกินน้ำเลี้ยงดอกและยอดอ่อน (juice sucker)',
              textStyle: MyConstant().h3Style(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Row buildRadioLeafFeeder(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.6,
          child: RadioListTile(
            value: 'leaf_feeder',
            groupValue: typeValue,
            onChanged: (value) {
              setState(() {
                typeValue = value as String?;
                print('type => $typeValue');
              });
            },
            title: ShowTitle(
              title: 'แมลงศัตรูพืชจำพวกกัดกินใบ (leaf feeder)',
              textStyle: MyConstant().h3Style(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Container buildFooter(double size) {
    return Container(
      width: size * 0.9,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildButtonCancel(),
          buidButtonSave(),
        ],
      ),
    );
  }

  Future<Null> confirmDialogChooseImage(int index) async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (context) => Container(
            //color: Colors.grey[300],
            height: MediaQuery.of(context).size.height * 0.3,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    child: buildImageShow(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    child: buildButtonGallery(context, index),
                  ),
                  Container(
                    width: double.infinity,
                    child: buildButtonCamera(context, index),
                  ),
                ],
              ),
            )));
  }

  OutlineButton buildButtonGallery(BuildContext context, int index) {
    return OutlineButton(
      onPressed: () {
        Navigator.pop(context);
        processImagePicker(ImageSource.gallery, index);
      },
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Text("GALLERY",
          style:
              TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.black)),
    );
  }

  OutlineButton buildButtonCamera(BuildContext context, int index) {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Text("CAMERA",
          style:
              TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.black)),
      onPressed: () {
        Navigator.pop(context);
        processImagePicker(ImageSource.camera, index);
      },
    );
  }

  OutlineButton buildImageShow() {
    return OutlineButton(
      highlightedBorderColor: Colors.grey[300],
      padding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: () {},
      child: Image.asset(
        MyConstant.addImage,
        scale: 10,
        color: Colors.lightBlue[300],
      ),
    );
  }

  RaisedButton buidButtonSave() {
    return RaisedButton(
      onPressed: () {
        processSaveValue();
      },
      color: MyConstant.primary,
      padding: EdgeInsets.symmetric(horizontal: 50),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Text(
        "SAVE",
        style: TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.white),
      ),
    );
  }

  OutlineButton buildButtonCancel() {
    return OutlineButton(
      padding: EdgeInsets.symmetric(horizontal: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text("CANCEL",
          style:
              TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.black)),
    );
  }

  Future<Null> processSaveValue() async {
    if (formKey.currentState!.validate()) {
      MyDialog().showProgressDialog(context);
      String name = nameController.text;
      String details = detailsController.text;
      String protect = protectController.text;
      String lat = latController.text;
      String lng = lngController.text;
      String id = insectModel!.id;
      String imagePath;

      if (statusImg) {
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

        Navigator.pop(context);
      } else {
        imagePath = images.toString();
        Navigator.pop(context);
      }
      print('## SaveID ==> $id $name $date $time $typeValue $lat $lng');
      print('## Images ==> $imagePath');
      print('## StatusImage ==> $statusImg');

      String path =
          '${MyConstant.domain}/insectFile/editInsectDataWhereID.php?isAdd=true&id=${insectModel!.id}&img=$imagePath&name=$name&details=$details&protect=$protect&date=$date&time=$time&type=$typeValue&lat=$lat&lng=$lng';

      await Dio().get(path).then((value) => Navigator.pop(context));
      MyDialog().normalDialog(
          context, 'Success !!!', 'Insert Data in Database Success !!!!!');
    }
  }

  /*Future<Null> editValueToMySQL(
    String imagePath, {
      String? name,
      String? details,
      String? protect,
      String? date,
      String? time,
      String? typeValue,
      String? lat,
      String? lng,
      String? id,
      
  }) async {
   String path =
          '${MyConstant.domain}/insectFile/editInsectDataWhereID.php?isAdd=true&id=${insectModelAPI!.id}&img=$imagePath&name=${insectModelAPI!.name}&details=${insectModelAPI!.details}&protect=${insectModelAPI!.protect}&date=${insectModelAPI!.date}&time=${insectModelAPI!.time}&type=${insectModelAPI!.type}&lat=${insectModelAPI!.lat}&lng=${insectModelAPI!.lng}';

      await Dio().get(path).then((value) {
        print('## update => $path');
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }*/

  String createUrlInsertImages(String string) {
    String result = string.substring(1, string.length);
    List<String> strings = result.split('/');
    String value = '/${strings[4]}/${strings[5]}';
    return value;
  }

  AppBar buidAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'แก้ไข',
        style: TextStyle(
          color: Colors.black87,
          fontFamily: 'kanit',
          //fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
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

  Column buildImage(BoxConstraints constraints) {
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
                                  ShowImage(path: MyConstant.image1),
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
                    onTap: () => confirmDialogChooseImage(
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
                                    ShowImage(path: MyConstant.image1),
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
                    onTap: () => confirmDialogChooseImage(
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
                                    ShowImage(path: MyConstant.image1),
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
                    onTap: () => confirmDialogChooseImage(
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
                                    ShowImage(path: MyConstant.image1),
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
                    onTap: () => confirmDialogChooseImage(
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
                                    ShowImage(path: MyConstant.image1),
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
      ),
    );
  }

  OutlineButton buildButtonTime(double size) {
    return OutlineButton(
      //padding: EdgeInsets.symmetric(horizontal: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () async {
        TimeOfDay? times = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (times == null) return;
        setState(() {
          time = times.format(context).toString();
        });
      },
      child: Container(
        width: size * 0.25,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                time == null ? "เวลา" : '$time',
                style: GoogleFonts.prompt(
                  color: MyConstant.dark,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineButton buildButtonDate(double size) {
    return OutlineButton(
      //padding: EdgeInsets.symmetric(horizontal: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () async {
        DateTime? dates = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (dates == null) return;
        setState(() {
          date = dates.year.toString() +
              '/' +
              dates.month.toString() +
              '/' +
              dates.day.toString();
        });
      },
      child: Container(
        width: size * 0.25,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                date == null ? "วันที่" : '$date',
                style: GoogleFonts.prompt(
                  color: MyConstant.dark,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project001/model/epidemic_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInsectLiteMember extends StatefulWidget {
  final EpidemicModel epidemicModel;
  const EditInsectLiteMember({Key? key, required this.epidemicModel})
      : super(key: key);

  @override
  State<EditInsectLiteMember> createState() => _EditInsectLiteMemberState();
}

class _EditInsectLiteMemberState extends State<EditInsectLiteMember> {
  bool load = true;
  EpidemicModel? epidemicModel;
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
    // TODO: implement initState
    super.initState();
    epidemicModel = widget.epidemicModel;
    createUrl();
    initialFile();
    insertValueInController();
    nameController.text = epidemicModel!.name;
    dateController.text = epidemicModel!.date;
    timeController.text = epidemicModel!.time;
    countyController.text = epidemicModel!.county;
    districtController.text = epidemicModel!.district;
    provinceController.text = epidemicModel!.province;
    latController.text = epidemicModel!.lat;
    longController.text = epidemicModel!.long;
  }

  void createUrl() {
    String string = epidemicModel!.img;
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

  Future<Null> insertValueInController() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String name = preferences.getString('name')!;
    String id = preferences.getString('id')!;
    print('### User $id : $name');
    print('### Product ${epidemicModel!.id} : ${epidemicModel!.name}');
  }

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
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    buildImage(constraints),
                    Container(
                      width: size * 0.7,
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          buildTextName(),
                          buildTextTime(),
                          buildTextDate(),
                          buildTextCounty(),
                          buildTextDistrict(),
                          buildTextProvince(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buidLat(constraints),
                              buidLong(constraints),
                            ],
                          ),
                          SizedBox(
                            height: 16,
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
      ),
    );
  }

  Container buildFooter(double size) {
    return Container(
      width: size * 0.9,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        ));
  }

  Widget buildTextTime() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: timeController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'เวลา',
          icon: Icon(
            Icons.timer,
            color: MyConstant.primary,
          ),
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        onTap: () async {
          TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time == null) return;
          setState(() {
            timeController.text = time.format(context).toString();
          });
        },
      ),
    );
  }

  Widget buildTextDate() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: dateController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'วันที่',
          icon: Icon(
            Icons.calendar_today,
            color: MyConstant.primary,
          ),
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        onTap: () async {
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (date == null) return;
          setState(() => {
                dateController.text = date.year.toString() +
                    '/' +
                    date.month.toString() +
                    '/' +
                    date.day.toString()
              });
        },
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
          labelText: 'จังหวัด',
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
          labelText: 'อำเภอ',
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
          labelText: 'ตำบล',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
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
      String date = dateController.text;
      String time = timeController.text;
      String county = countyController.text;
      String district = districtController.text;
      String province = provinceController.text;
      String lat = latController.text;
      String long = longController.text;
      String id = epidemicModel!.id;
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
      print(
          '## SaveID ==> $id $name $date $time $county $district $province $lat $long');
      print('## Images ==> $imagePath');
      print('## StatusImage ==> $statusImg');

      String path =
          '${MyConstant.domain}/insectFile/editInsectLiteWhereID.php?isAdd=true&id=${epidemicModel!.id}&img=$imagePath&name=$name&date=$date&time=$time&county=$county&district=$district&province=$province&lat=$lat&long=$long';

      await Dio().get(path).then((value) => Navigator.pop(context));
      MyDialog().normalDialog(
          context, 'Success !!!', 'Insert Data in Database Success !!!!!');
    }
  }

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

  /* Future<Null> chooseSourceImageDialog(int index) async {
    print('Click From index ==>> $index');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.image4),
          title: ShowTitle(
              title: 'Source Image ${index + 1} ?',
              textStyle: MyConstant().h2Style(Colors.black)),
          subtitle: ShowTitle(
              title: 'Please Tab on Camera or Gallery',
              textStyle: MyConstant().h3Style(Colors.black)),
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
                child: Text('Camera'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  processImagePicker(ImageSource.gallery, index);
                },
                child: Text('Gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }*/

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

  Widget buidLong(BoxConstraints constraints) {
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
}

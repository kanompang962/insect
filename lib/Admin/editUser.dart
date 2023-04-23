import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonCancel.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class EditUser extends StatefulWidget {
  final String id;
  const EditUser({Key? key, required this.id}) : super(key: key);

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  String? id;
  File? file;
  UserModel? userModel;
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController countyController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController provinceController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadValueUser();
  }

  Future<Null> loadValueUser() async {
    id = widget.id;
    print("### ID User ==> $id");
    String apiGetUser =
        '${MyConstant.domain}/insectFile/getUserWhereID.php?isAdd=true&id=$id';
    await Dio().get(apiGetUser).then((value) {
      if (value.toString() == 'null') {
        print('### API GET User ==> null');
      } else {
        for (var item in json.decode(value.data)) {
          setState(() {
            userModel = UserModel.fromMap(item);
            nameController.text = userModel!.name;
            emailController.text = userModel!.email;
            phoneController.text = userModel!.phone;
            countyController.text = userModel!.county;
            districtController.text = userModel!.district;
            provinceController.text = userModel!.province;
          });
        }
      }
    });
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
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Container(
                        width: size * 0.7,
                        child: Column(
                          children: [
                            buidHeader(),
                            buildAvatar(constraints),
                            buildTextName(),
                            buildTextEmail(),
                            buildTextPhone(),
                            buildTextCounty(),
                            buildTextDistrict(),
                            buildTextProvince(),
                          ],
                        ),
                      ),
                      buildFooter(size)
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
  Future<Null> chooseSourceImageDialog() async {
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
            'เลือกภาพโปรไฟล์',
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
                  chooseImage(ImageSource.camera);
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
                  chooseImage(ImageSource.gallery);
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

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var result = await ImagePicker()
          .getImage(source: source, maxWidth: 800, maxHeight: 800);
      setState(() {
        file = File(result!.path);
      });
    } catch (e) {}
  }

// function
  Future<Null> processEditProfile() async {
    MyDialog().showProgressDialog(context);

    if (formKey.currentState!.validate()) {
      if (file == null) {
        print('####### Avatar old${userModel!.img} #######');
        editValueToMySQL(userModel!.img);
      } else {
        print('####### Avatar new #######');
        String apiSaveAvatar = '${MyConstant.domain}/insectFile/saveAvatar.php';
        List<String> nameAvatars = userModel!.img.split('/');
        String nameFile = nameAvatars[nameAvatars.length - 1];
        nameFile = 'edit${Random().nextInt(100)}$nameFile';
        print('####### $nameFile #######');

        Map<String, dynamic> map = Map();
        map['file'] =
            await MultipartFile.fromFile(file!.path, filename: nameFile);
        FormData data = FormData.fromMap(map);
        await Dio().post(apiSaveAvatar, data: data).then((value) {
          print('####### upload $nameFile success #######');

          String pathAvatar = '/insectFile/avatar/$nameFile';
          editValueToMySQL(pathAvatar);
        });
      }
    }
  }

  Future<Null> editValueToMySQL(
    String pathAvatar, {
    String? name,
    String? phone,
    String? email,
    String? county,
    String? district,
    String? province,
  }) async {
    String apiEditProfile =
        '${MyConstant.domain}/insectFile/editUserWhereId.php?isAdd=true&id=${userModel!.id}&name=${nameController.text}&img=$pathAvatar&email=${emailController.text}&phone=${phoneController.text}&county=${countyController.text}&district=${districtController.text}&province=${provinceController.text}';
    await Dio().get(apiEditProfile).then((value) {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

// Widget
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

  Widget buidButtonSave() {
    return RaisedButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          processEditProfile();
        }
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

  Widget buildTextPhone() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: phoneController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'Phone',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget buildTextEmail() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: emailController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'E-mail',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
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
          labelText: 'Name',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Container buidHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'แก้ไขข้อมูลผู้ใช้',
            style: GoogleFonts.prompt(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvatar(BoxConstraints constraints) {
    return Container(
      //margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                child: Container(
                  width: constraints.maxWidth * 0.48,
                  height: constraints.maxWidth * 0.48,
                  child: userModel == null
                      ? ShowProgress()
                      : Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: userModel!.img.isEmpty
                              ? InkWell(
                                  onTap: () => chooseSourceImageDialog(),
                                  child: file == null
                                      ? ShowImage(path: MyConstant.avatar)
                                      : ClipOval(
                                          child: InkWell(
                                            onTap: () {
                                              chooseSourceImageDialog(); //bottomSheet();
                                            },
                                            child: Image.file(
                                              file!,
                                              width: 160,
                                              height: 160,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                )
                              : file == null
                                  ? CircleAvatar(
                                      child: InkWell(
                                        onTap: () {
                                          chooseSourceImageDialog(); //bottomSheet();
                                        },
                                      ),
                                      radius: 40,
                                      backgroundImage: NetworkImage(
                                          '${MyConstant.domain}${userModel!.img}'),
                                      //AssetImage(MyConstant.avatar),
                                    ) //buildShowImageNetwork()
                                  : ClipOval(
                                      child: InkWell(
                                        onTap: () {
                                          chooseSourceImageDialog(); //bottomSheet();
                                        },
                                        child: Image.file(
                                          file!,
                                          width: 160,
                                          height: 160,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ), //Image.file(file!),
                        ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 30,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: MyConstant.primary,
                      shape: BoxShape.circle,
                      border: Border.all(width: 4, color: Colors.white)),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => chooseImage(ImageSource.camera),
                icon: Icon(
                  Icons.add_a_photo,
                  color: MyConstant.dark,
                ),
              ),
              IconButton(
                onPressed: () => chooseImage(ImageSource.gallery),
                icon: Icon(
                  Icons.add_photo_alternate,
                  color: MyConstant.dark,
                ),
              ),
            ],
          ),*/
        ],
      ),
    );
  }

  AppBar buidAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      /*title: Text(
        'EditProfile',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'iannnnn-DUCK',
          fontWeight: FontWeight.w900,
          fontSize: 25,
        ),
      ),*/
    );
  }
}

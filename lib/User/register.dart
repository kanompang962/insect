import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonCancel.dart';
import 'package:project001/widgets/show_title.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  File? file;
  String? typeUser;
  String avatar = '';

  final formKey = GlobalKey<FormState>();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController countyController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController provinceController = TextEditingController();

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
                    Container(
                      width: size * 0.7,
                      child: Column(
                        children: [
                          buidHeader(),
                          buildAvatar(constraints),
                          buildTextUsername(),
                          buildTextPassword(),
                          buildTextName(),
                          buildTextEmail(),
                          buildTextPhone(),
                          buildTextCounty(),
                          buildTextDistrict(),
                          buildTextProvince(),
                          buildRadioMember(size),
                          buildRadioExpert(size),
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
  Future<Null> chooseImage(ImageSource source) async {
    try {
      var result = await ImagePicker()
          .getImage(source: source, maxWidth: 800, maxHeight: 800);
      setState(() {
        file = File(result!.path);
      });
    } catch (e) {}
  }

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

// function
  Future<Null> processUploadImage() async {
    if (file == null) {
      return MyDialog()
          .warningDialog(context, 'เลือกภาพโปรไฟล์', 'Choose Image Profile');
    } else {
      if (formKey.currentState!.validate()) {
        if (typeUser == null) {
          return MyDialog()
              .warningDialog(context, 'เลือกสถานะผู้ใช้', 'Select user status');
        } else {
          String user = userController.text;
          String password = passwordController.text;
          String name = nameController.text;
          String email = emailController.text;
          String phone = phoneController.text;
          String county = countyController.text;
          String district = districtController.text;
          String province = provinceController.text;
          print('## Username = $user');
          String path =
              '${MyConstant.domain}/insectFile/getUserWhereUser.php?isAdd=true&username=$user';
          // Check Username
          await Dio().get(path).then((value) async {
            if (value.toString() == 'null') {
              // Upload Image Profile
              MyDialog().showProgressDialog(context);
              String apiSaveAvatar =
                  '${MyConstant.domain}/insectFile/saveAvatar.php';
              int i = Random().nextInt(100000);
              String nameAvatar = 'avatar$i.jpg';
              Map<String, dynamic> map = Map();
              map['file'] = await MultipartFile.fromFile(file!.path,
                  filename: nameAvatar);
              FormData data = FormData.fromMap(map);
              await Dio().post(apiSaveAvatar, data: data).then((value) async {
                avatar = '/insectFile/avatar/$nameAvatar';
                String apiInsertUser =
                    '${MyConstant.domain}/insectFile/insertUser.php?isAdd=true&username=$user&password=$password&name=$name&img=$avatar&email=$email&phone=$phone&county=$county&district=$district&province=$province&type=$typeUser';
                try {
                  // Insert SQL
                  await Dio()
                      .get(apiInsertUser)
                      .then((value) => Navigator.pop(context));
                } catch (e) {
                  return MyDialog().normalDialog(
                      context, 'Create New User False !!!', 'Please Try Again');
                }
              });
              Navigator.pop(context);
              MyDialog().successDialog(
                  context, 'สำเร็จ', 'successfully added information');
              Future.delayed(Duration(seconds: 1));
              Navigator.pop(context);
            } else {
              return MyDialog().normalDialog(
                  context, 'ชื่อผู้ใช้ซ้ำ', 'Please Change Username');
            }
          });
        }
      }
    }
  }

  bool isEmailValid() {
    RegExp regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return regex.hasMatch(emailController.text);
  }

  bool isPhoneNumberValid() {
    RegExp regex = RegExp(r'^(08|02|09|06)\d{8}$');
    return regex.hasMatch(phoneController.text);
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

  Widget buildRadioExpert(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.6,
          child: RadioListTile(
            value: 'Expert',
            groupValue: typeUser,
            onChanged: (value) {
              setState(() {
                typeUser = value as String?;
                print('type => $typeUser');
              });
            },
            title: ShowTitle(
              title: 'ผู้เชี่ยวชาญ (Expert)',
              textStyle: MyConstant().h3Style(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRadioMember(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size * 0.6,
          child: RadioListTile(
            value: 'Member',
            groupValue: typeUser,
            onChanged: (value) {
              setState(() {
                typeUser = value as String?;
                print('type => $typeUser');
              });
            },
            title: ShowTitle(
              title: 'สมาชิก (Member)',
              textStyle: MyConstant().h3Style(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget buidButtonSave() {
    return RaisedButton(
      onPressed: () {
        processUploadImage();
      },
      color: MyConstant.primary,
      padding: EdgeInsets.symmetric(horizontal: 50),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Text(
        "บันทึก",
        style: GoogleFonts.prompt(
          color: Colors.white,
          fontSize: 16,
        ),
        // style: TextStyle(
        //   fontSize: 14,
        //   letterSpacing: 2.2,
        //   color: Colors.white,
        // ),
      ),
    );
  }

  Widget buildTextUsername() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: userController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'ชื่อผู้ใช้',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget buildTextPassword() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: passwordController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'รหัสผ่าน',
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
            return 'กรุณากรอกข้อมูลให้ครบ';
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
            return 'กรุณากรอกข้อมูลให้ครบ';
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
            return 'กรุณากรอกข้อมูลให้ครบ';
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
        keyboardType: TextInputType.phone,
        controller: phoneController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกข้อมูลให้ครบ';
          } else {
            if (!isPhoneNumberValid()) {
              return 'กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง';
            }
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'เบอร์โทรศัพท์',
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
            return 'กรุณากรอกข้อมูลให้ครบ';
          } else {
            if (!isEmailValid()) {
              return 'กรุณากรอกอีเมลให้ถูกต้อง';
            }
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'อีเมล',
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
            return 'กรุณากรอกข้อมูลให้ครบ';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'ชื่อ-นามสกุล',
          //labelStyle: MyConstant().h3Style(Colors.lightGreen),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget buidHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'สร้างโปรไฟล์',
            style: GoogleFonts.prompt(
              fontSize: 20,
              color: MyConstant.dark2,
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
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: file == null
                        ? InkWell(
                            onTap: () => chooseSourceImageDialog(),
                            child: Image.asset(
                              MyConstant.avatar,
                              color: MyConstant.dark,
                            ),
                          )
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

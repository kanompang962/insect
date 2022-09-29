import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_title.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
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
                    Container(
                      width: size * 0.9,
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildButtonCancel(),
                          buidButtonSave(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row buildRadioExpert(double size) {
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

  Row buildRadioMember(double size) {
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

  Future<Null> uploadPictureAndInsertData() async {
    String user = userController.text;
    String password = passwordController.text;
    String name = nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String county = countyController.text;
    String district = districtController.text;
    String province = provinceController.text;
    print(
        '## user = $user, password = $password, name = $name, email = $email, phone = $phone');
    String path =
        '${MyConstant.domain}/insectFile/getUserWhereUser.php?isAdd=true&user=$user';
    await Dio().get(path).then((value) async {
      print('## value ==>> $value');
      if (value.toString() == 'null') {
        print('## user OK');

        if (file == null) {
          // No Avatar
          processInsertMySQL(
              user: user,
              password: password,
              name: name,
              email: email,
              phone: phone,
              county: county,
              district: district,
              province: province);
        } else {
          // Have Avatar
          print('### process Upload Avatar');
          String apiSaveAvatar =
              '${MyConstant.domain}/insectFile/saveAvatar.php';
          int i = Random().nextInt(100000);
          String nameAvatar = 'avatar$i.jpg';
          Map<String, dynamic> map = Map();
          map['file'] =
              await MultipartFile.fromFile(file!.path, filename: nameAvatar);
          FormData data = FormData.fromMap(map);
          await Dio().post(apiSaveAvatar, data: data).then((value) {
            avatar = '/insectFile/avatar/$nameAvatar';
            processInsertMySQL(
              user: user,
              password: password,
              name: name,
              email: email,
              phone: phone,
              county: county,
              district: district,
              province: province,
            );
          });
        }
      } else {
        MyDialog().normalDialog(context, 'User False ?', 'Please Change User');
      }
    });
  }

  Future<Null> processInsertMySQL({
    String? user,
    String? password,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? county,
    String? district,
    String? province,
    //String? type,
  }) async {
    print('### processInsertMySQL Work and avatar ==>> $avatar');
    String apiInsertUser =
        '${MyConstant.domain}/insectFile/insertUser.php?isAdd=true&username=$user&password=$password&name=$name&img=$avatar&email=$email&phone=$phone&county=$county&district=$district&province=$province&type=$typeUser';
    await Dio().get(apiInsertUser).then((value) {
      if (value.toString() == 'true') {
        Navigator.pop(context);
      } else {
        MyDialog().normalDialog(
            context, 'Create New User False !!!', 'Please Try Again');
      }
    });
  }

  RaisedButton buidButtonSave() {
    return RaisedButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          if (file == null) {
            print('เลือกรูปภาพ');
            showDialogImageEmpty(context);
          } else {
            if (typeUser == null) {
              print('Non Choose Type User');
              MyDialog().normalDialog(context, 'ยังไม่ได้เลือก ชนิดของ User',
                  'กรุณา Tap ที่ ชนิดของ User ที่ต้องการ');
            } else {
              print('Process Insert to Database');
              uploadPictureAndInsertData();
            }
          }
        }
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

  void showDialogImageEmpty(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (BuildContext bc) {
          return Container(
              //color: Colors.grey[300],
              height: MediaQuery.of(context).size.height * 0.15,
              child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.backspace_outlined),
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          'เลือกรูปภาพ',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  )));
        });
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

  Widget buildTextUsername() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: userController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'username',
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
            return 'Please Fill in Blank';
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'password',
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
            'EditProfile',
            style: TextStyle(
                fontSize: 24,
                letterSpacing: 2.2,
                color: Colors
                    .black), /*TextStyle(
              color: Colors.black,
              fontFamily: 'iannnnn-DUCK',
              fontWeight: FontWeight.w900,
              fontSize: 25,
            ),*/
          ),
        ],
      ),
    );
  }

  showDialogChooseImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ListTile(
          title: Text('Choose a Photo'),
          subtitle: Text('How to set up a new profile profile picture?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              chooseImage(ImageSource.gallery).then(
                (value) => Navigator.pop(context),
              );
            },
            child: Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              chooseImage(ImageSource.camera).then(
                (value) => Navigator.pop(context),
              );
            },
            child: Text('Camera'),
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

  Container buildAvatar(BoxConstraints constraints) {
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
                            onTap: () => showDialogChooseImage(),
                            child: ShowImage(path: MyConstant.avatar),
                          )
                        : ClipOval(
                            child: InkWell(
                              onTap: () {
                                showDialogChooseImage(); //bottomSheet();
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

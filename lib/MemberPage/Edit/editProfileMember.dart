import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileMember extends StatefulWidget {
  const EditProfileMember({Key? key}) : super(key: key);

  @override
  State<EditProfileMember> createState() => _EditProfileMemberState();
}

class _EditProfileMemberState extends State<EditProfileMember> {
  File? file;
  final formKey = GlobalKey<FormState>();
  UserModel? userModel;

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
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String username = preferences.getString('username')!;

    String apiGetUser =
        '${MyConstant.domain}/insectFile/getUserWhereUser.php?isAdd=true&username=$username';
    await Dio().get(apiGetUser).then((value) {
      print('value ==>> $value');
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
                    )
                    /*addProductButton(constraints),
                      Container(
                        height: constraints.maxWidth * 0.15,
                      )*/
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  RaisedButton buidButtonSave() {
    return RaisedButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          processEditProfile();
        }else{
          print('object');
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
              chooseImage(ImageSource.gallery);
              Navigator.pop(context);
            },
            child: Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              chooseImage(ImageSource.camera);
              Navigator.pop(context);
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
                  child: userModel == null
                      ? ShowProgress()
                      : Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: userModel!.img.isEmpty
                              ? InkWell(
                                  onTap: () => showDialogChooseImage(),
                                  child: file == null
                                      ? ShowImage(path: MyConstant.avatar)
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
                                        ),
                                )
                              : file == null
                                  ? CircleAvatar(
                                      child: InkWell(
                                        onTap: () {
                                          showDialogChooseImage(); //bottomSheet();
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

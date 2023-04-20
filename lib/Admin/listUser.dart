import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Admin/addUser.dart';
import 'package:project001/Admin/editUser.dart';
import 'package:project001/Admin/userDetail.dart';
import 'package:project001/model/user_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/my_dialog.dart';
import 'package:project001/widgets/show_ButtonCancel.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';

class ListUser extends StatefulWidget {
  const ListUser({Key? key}) : super(key: key);

  @override
  State<ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  List<UserModel> userModels = [];
  UserModel? userModel;
  bool haveData = false;
  bool load = true;

  @override
  void initState() {
    super.initState();
    loadUserFromAPI();
    print('----------Refresh----------');
  }

  Future<Null> loadUserFromAPI() async {
    if (userModels.length != 0) {
      userModels.clear();
    } else {}
    String apiGetAllInsectData =
        '${MyConstant.domain}/insectFile/getUser.php?isAdd=true';
    try {
      await Dio().get(apiGetAllInsectData).then(
        (value) {
          if (json.decode(value.data) == null) {
            // print('value = empty');
          } else {
            // print('value = $value');
            for (var item in json.decode(value.data)) {
              UserModel model = UserModel.fromMap(item);
              setState(() {
                userModels.add(model);
              });
            }
            setState(() {
              load = false;
              haveData = true;
            });
            print('### value length ==> ${userModels.length}');
          }
        },
      );
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppbar(),
      backgroundColor: Colors.grey[200],
      floatingActionButton: buildFloatButton(context),
      body: load
          ? ShowProgress()
          : LayoutBuilder(
              builder: (context, constraints) => Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: Container(
                          width: (constraints.maxWidth > 412)
                              ? (constraints.maxWidth * 0.8)
                              : constraints.maxWidth,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: userModels.length,
                            itemBuilder: (context, index) {
                              return LayoutBuilder(
                                builder: (context, constraints) => Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 4),
                                  child: InkWell(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserDetail(
                                            id: userModels[index].id),
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(14),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl:
                                                      '${MyConstant.domain}${userModels[index].img}',
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          ShowImage(
                                                              path: MyConstant
                                                                  .avatar),
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              60),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${userModels[index].name}",
                                                        style:
                                                            GoogleFonts.prompt(
                                                          fontSize: 14,
                                                          color:
                                                              MyConstant.dark2,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${userModels[index].email}",
                                                        style:
                                                            GoogleFonts.prompt(
                                                          fontSize: 12,
                                                          color:
                                                              MyConstant.dark2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditUser(
                                                                id: userModels[
                                                                        index]
                                                                    .id),
                                                      ),
                                                    ).then(
                                                      (value) =>
                                                          loadUserFromAPI(),
                                                    );
                                                  },
                                                  icon: Icon(
                                                    FontAwesomeIcons
                                                        .penToSquare,
                                                    color: MyConstant.dark2,
                                                    size: 20,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    _showDelDialog(context,
                                                        userModels[index].id);
                                                  },
                                                  icon: Icon(
                                                    FontAwesomeIcons.xmark,
                                                    color: MyConstant.dark2,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

// function
  Future<Null> functionDel(String id) async {
    // select
    String apiGet =
        '${MyConstant.domain}/insectFile/getUserWhereID.php?isAdd=true&id=$id';
    try {
      await Dio().get(apiGet).then((value) {
        if (json.decode(value.data) == null) {
          // print('value = empty');
        } else {
          // print('value = $value');
          for (var item in json.decode(value.data)) {
            setState(() {
              userModel = UserModel.fromMap(item);
            });
          }
          setState(() {
            load = false;
            haveData = true;
          });
          print('### User Type ==> ${userModel!.type}');
        }
      });
      // check type user
      if (userModel!.type == 'Admin') {
        return MyDialog().warningDialog(context, 'ไม่สามารถลบแอดมินได้',
            'something went wrong cause the program to be inoperable');
      } else {
        // delete
        String apiDelete =
            '${MyConstant.domain}/insectFile/deleteUserWhereID.php?isAdd=true&id=$id';
        String apiDeleteIn =
            '${MyConstant.domain}/insectFile/deleteInsectDataWhereIDUser.php?isAdd=true&id_user=$id';
        String apiDeleteInl =
            '${MyConstant.domain}/insectFile/deleteInsectLiteWhereIDUser.php?isAdd=true&id_user=$id';
        await Dio().get(apiDelete).then((value) async {
          await Dio().get(apiDeleteIn);
          await Dio().get(apiDeleteInl);
          Navigator.pop(context);
          loadUserFromAPI();
        });
      }
    } catch (e) {
      return MyDialog().warningDialog(context, 'เกิดข้อผิดพลาด',
          'something went wrong cause the program to be inoperable');
    }
  }

// Dialog
  void _showDelDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.del),
          title: Text(
            'ลบข้อมูล',
            style: GoogleFonts.prompt(fontSize: 16),
          ),
          subtitle: Text(
            'ต้องการที่จะลบข้อมูลนี้ หรือไม่',
            style: GoogleFonts.prompt(fontSize: 14),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: buildButtonConfirm(id),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: ShowButtonCancel(),
          ),
        ],
      ),
    );
  }

// Widget
  Widget buildButtonConfirm(String id) {
    return RaisedButton(
      onPressed: () async {
        functionDel(id);
      },
      color: Color(0xFFB22222),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "ยืนยัน",
        style: GoogleFonts.prompt(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget buildFloatButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // _showAddDialog();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddUser(),
          ),
        ).then((value) => loadUserFromAPI());
      },
      label: Text(
        'เพิ่มข้อมูล',
        style: GoogleFonts.prompt(
          fontWeight: FontWeight.w400,
          color: MyConstant.light,
        ),
      ),
      icon: Icon(
        FontAwesomeIcons.add,
        color: MyConstant.light,
      ),
      backgroundColor: MyConstant.dark,
    );
  }

  AppBar buildAppbar() {
    return AppBar(
      backgroundColor: Colors.grey[200],
      elevation: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                'User',
                style: GoogleFonts.lobster(
                  fontSize: 30,
                ),
              ),
              Text(
                ' | จัดการข้อมูลผู้ใช้',
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

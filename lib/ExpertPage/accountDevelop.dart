import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project001/model/epidemic_model.dart';
import 'package:project001/model/insect_model.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_progress.dart';
import 'package:project001/widgets/show_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountExpert extends StatefulWidget {
  const AccountExpert({Key? key}) : super(key: key);

  @override
  _AccountExpertState createState() => _AccountExpertState();
}

class _AccountExpertState extends State<AccountExpert> {
  bool load = true;
  bool? haveData;
  List<InsectModel> insectModels = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Scaffold(drawer: Drawer(),
      appBar: AppBar(
        actions: [
          ElevatedButton(
            style: MyConstant()
                .myButtonStyle(MyConstant.primary, MyConstant.primary),
            onPressed: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.clear().then(
                    (value) => Navigator.pushNamedAndRemoveUntil(
                        context, MyConstant.routeUser, (route) => false),
                  );
            },
            child: Text('Singout'),
          ),
        ],
      ),
      body: Center(child: Text('Account Expert'),),
    );
  }

  String createUrl(String string) {
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    String url = '${MyConstant.domain}/tes${strings[0]}';
    return url;
  }

  ListView buildListView(BoxConstraints constraints) {
    return ListView.builder(
      itemCount: insectModels.length,
      itemBuilder: (context, index) => Card(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4),
              width: constraints.maxWidth * 0.5 - 4,
              height: constraints.maxWidth * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ShowTitle(
                      title: insectModels[index].name,
                      textStyle: MyConstant().h2Style(Colors.black)),
                  Container(
                    width: constraints.maxWidth * 0.5,
                    height: constraints.maxWidth * 0.4,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: createUrl(insectModels[index].img),
                      placeholder: (context, url) => ShowProgress(),
                      errorWidget: (context, url, error) =>
                          ShowImage(path: MyConstant.image1),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(4),
              width: constraints.maxWidth * 0.5 - 4,
              height: constraints.maxWidth * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*ShowTitle(
                      title: '${insectModels[index].details}',
                      textStyle: MyConstant().h2Style(Colors.black)),
                  ShowTitle(
                      title: '${insectModels[index].protect}',
                      textStyle: MyConstant().h3Style(Colors.black)),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          onPressed: () {
                            print('## You Click Edit');
                            /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProduct(
                                    productModel: epidemicModel[index],
                                  ),
                                )).then((value) => loadValueFromAPI());*/
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 36,
                            color: MyConstant.dark,
                          )),
                      IconButton(
                          onPressed: () {
                            print('## You Click Delete from index = $index');
                            //confirmDialogDelete(insectModels[index]);
                          },
                          icon: Icon(
                            Icons.delete_outline,
                            size: 36,
                            color: MyConstant.dark,
                          )),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 /* Future<Null> confirmDialogDelete(InsectModel insectModels) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ListTile(
          leading: CachedNetworkImage(
            imageUrl: createUrl(insectModels.img),
            placeholder: (context, url) => ShowProgress(),
          ),
          title: ShowTitle(
            title: 'Delete ${insectModels.name} ?',
            textStyle: MyConstant().h2Style(Colors.black),
          ),
          subtitle: ShowTitle(
            title: insectModels.details,
            textStyle: MyConstant().h3Style(Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              //print('## Confirm Delete at id ==> ${insectModels.is_id}');
              String apiDeleteProductWhereId =
                  '${MyConstant.domain}/shoppingmall/deleteProductWhereId.php?isAdd=true&id=${insectModels.is_id}';
              await Dio().get(apiDeleteProductWhereId).then((value) {
                Navigator.pop(context);
                //loadValueFromAPI();
              });
            },
            child: Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }*/

  Row buidSingOut(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 16),
          width: size * 0.6,
          child: ElevatedButton(
            style: MyConstant()
                .myButtonStyle(MyConstant.primary, MyConstant.primary),
            onPressed: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.clear().then(
                    (value) => Navigator.pushNamedAndRemoveUntil(
                        context, MyConstant.routeUser, (route) => false),
                  );
            },
            child: Text('Singout'),
          ),
        ),
      ],
    );
  }
}

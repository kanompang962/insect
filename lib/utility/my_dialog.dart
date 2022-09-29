import 'package:flutter/material.dart';
import 'dart:io';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/widgets/show_image.dart';
import 'package:project001/widgets/show_title.dart';

class MyDialog {
  final Function()? funcAction;

  MyDialog({this.funcAction});

  Future<Null> showProgressDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        child: Center(
            child: CircularProgressIndicator(
          color: Colors.white,
        )),
        onWillPop: () async {
          return false;
        },
      ),
    );
  }

  Future<Null> alertLocationService(
      BuildContext context, String title, String message) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.image4),
          title: ShowTitle(
            title: title,
            textStyle: MyConstant().h2Style(Colors.black),
          ),
          subtitle:
              ShowTitle(title: message, textStyle: MyConstant().h3Style(Colors.black)),
        ),
        
      ),
    );
  }

  Future<Null> normalDialog(
      BuildContext context, String title, String message) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.image1),
          title: ShowTitle(title: title, textStyle: MyConstant().h2Style(Colors.black)),
          subtitle:
              ShowTitle(title: message, textStyle: MyConstant().h3Style(Colors.black)),
        ),
        children: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
        ],
      ),
    );
  }

  Future<Null> actionDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.image1),
          title: ShowTitle(title: title, textStyle: MyConstant().h2Style(Colors.black)),
          subtitle:
              ShowTitle(title: message, textStyle: MyConstant().h3Style(Colors.black)),
        ),
        children: [
          TextButton(
              onPressed: funcAction,
              child: Text('OK'))
        ],
      ),
    );
  }
}
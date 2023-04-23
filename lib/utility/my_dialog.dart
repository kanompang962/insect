import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<Null> deleteDialog(
    BuildContext context,
  ) async {
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
            child: RaisedButton(
              onPressed: funcAction,
              color: Color(0xFFB22222),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "ยืนยัน",
                style: GoogleFonts.prompt(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: OutlineButton(
              highlightedBorderColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ยกเลิก",
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> alertLocationService(
      BuildContext context, String title, String message) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.image),
          title: ShowTitle(
            title: title,
            textStyle: MyConstant().h2Style(Colors.black),
          ),
          subtitle: ShowTitle(
              title: message, textStyle: MyConstant().h3Style(Colors.black)),
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
          leading: ShowImage(path: MyConstant.warning),
          title: ShowTitle(
              title: title, textStyle: MyConstant().h2Style(Colors.black)),
          subtitle: ShowTitle(
              title: message, textStyle: MyConstant().h3Style(Colors.black)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: OutlineButton(
              highlightedBorderColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ตกลง",
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Future<Null> actionDialog(
  //   BuildContext context,
  //   String title,
  //   String message,
  // ) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) => SimpleDialog(
  //       title: ListTile(
  //         leading: ShowImage(path: MyConstant.warning),
  //         title: ShowTitle(
  //             title: title, textStyle: MyConstant().h2Style(Colors.black)),
  //         subtitle: ShowTitle(
  //             title: message, textStyle: MyConstant().h3Style(Colors.black)),
  //       ),
  //       children: [TextButton(onPressed: funcAction, child: Text('OK'))],
  //     ),
  //   );
  // }

  Future<Null> warningDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.warning),
          title: ShowTitle(
              title: title, textStyle: MyConstant().h2Style(Colors.black)),
          subtitle: ShowTitle(
              title: message, textStyle: MyConstant().h3Style(Colors.black)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: OutlineButton(
              highlightedBorderColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ตกลง",
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Future<Null> successDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.confirm),
          title: ShowTitle(
              title: title, textStyle: MyConstant().h2Style(Colors.black)),
          subtitle: ShowTitle(
              title: message, textStyle: MyConstant().h3Style(Colors.black)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: OutlineButton(
              highlightedBorderColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ตกลง",
                style: GoogleFonts.prompt(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

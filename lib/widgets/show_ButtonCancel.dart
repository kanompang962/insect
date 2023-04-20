import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/utility/my_constant.dart';

class ShowButtonCancel extends StatelessWidget {
  const ShowButtonCancel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      padding: EdgeInsets.symmetric(horizontal: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        "ยกเลิก",
        style: GoogleFonts.prompt(color: MyConstant.dark2),
      ),
    );
  }
}

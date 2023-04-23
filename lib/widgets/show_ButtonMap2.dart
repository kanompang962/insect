import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/showMap2.dart';
import 'package:project001/utility/my_constant.dart';

class ShowButtonMap2 extends StatelessWidget {
  final String id;
  const ShowButtonMap2({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () {
        print('### PASS ID ==> $id');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ShowMap2(id: id)));
      },
      child: Text(
        "แผนที่",
        style: GoogleFonts.prompt(
          color: MyConstant.dark,
          fontSize: 12,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/showMap1.dart';
import 'package:project001/utility/my_constant.dart';

class ShowButtonMap extends StatelessWidget {
  final String id;
  const ShowButtonMap({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      highlightedBorderColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () {
        print('### PASS ID ==> $id');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ShowMap1(id: id)));
      },
      child: Text(
        "แผนที่",
        style: GoogleFonts.prompt(
          color: MyConstant.dark,
        ),
      ),
    );
  }
}

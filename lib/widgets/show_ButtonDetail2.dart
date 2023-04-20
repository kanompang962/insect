import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project001/Components/showDetails2.dart';
import 'package:project001/utility/my_constant.dart';

class ShowButtonDetail2 extends StatelessWidget {
  final String id;
  const ShowButtonDetail2({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () async {
        print('### PASS ID ==> $id');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowDetails2(id: id),
          ),
        );
      },
      color: MyConstant.dark,
      padding: EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        "รายละเอียด",
        style: GoogleFonts.prompt(
          color: Colors.white,
        ),
      ),
    );
  }
}

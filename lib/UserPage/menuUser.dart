import 'package:flutter/material.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/size_helper.dart';


class MenuUser extends StatefulWidget {
  const MenuUser({Key? key}) : super(key: key);

  @override
  _MenuUserState createState() => _MenuUserState();
}

class _MenuUserState extends State<MenuUser> {
  @override
  Widget build(BuildContext context) {
    double w = displayWidth(context);
    double h = displayHeight(context) -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buidAppbar(),
      body: ListView(
        children: [
          buidMenu1(w),
          buidMenu2(w),
          buidMenu3(w),
          buidMenu4(w),
        ],
      ),
    );
  }

  Container buidMenu4(double w) {
    return Container(
      margin: EdgeInsets.only(top: 7,left: 20,right: 20),
      width: w,
      child: ElevatedButton(
        onPressed: () {},
        child: Row(
          children: [
            Container(
              width: w * 0.1,
              child: Image.asset(
                MyConstant.apple,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'ความเสียหายที่เกิดกับผล',
                style: TextStyle(
                  fontSize: w * 0.04,
                ),
              ),
            ),
          ],
        ),
        style: MyConstant().myButtonStyle(MyConstant.colorMenu4,MyConstant.colorMenu4),
      ),
    );
  }

  Container buidMenu3(double w) {
    return Container(
      margin: EdgeInsets.only(top: 7,left: 20,right: 20),
      width: w,
      child: ElevatedButton(
        onPressed: () {},
        child: Row(
          children: [
            Container(
              width: w * 0.1,
              child: Image.asset(
                MyConstant.trunk,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'ความเสียหายที่เกิดกับลำต้น หัว ราก',
                style: TextStyle(
                  fontSize: w * 0.04,
                ),
              ),
            ),
          ],
        ),
        style: MyConstant().myButtonStyle(MyConstant.colorMenu3,MyConstant.colorMenu3),
      ),
    );
  }

  Container buidMenu2(double w) {
    return Container(
      margin: EdgeInsets.only(top: 7,left: 20,right: 20),
      width: w,
      child: ElevatedButton(
        onPressed: () {},
        child: Row(
          children: [
            Container(
              width: w * 0.1,
              child: Image.asset(
                MyConstant.leaves,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'ความเสียหายที่เกิดกับดอก ยอดอ่อน',
                style: TextStyle(
                  fontSize: w * 0.04,
                ),
              ),
            ),
          ],
        ),
        style: MyConstant().myButtonStyle(MyConstant.colorMenu2, MyConstant.colorMenu2),
      ),
    );
  }

  Container buidMenu1(double w) {
    return Container(
      margin: EdgeInsets.only(top: 20,left: 20,right: 20),
      width: w,
      child: ElevatedButton(
        onPressed: () {},
        child: Row(
          children: [
            Container(
              width: w * 0.1,
              child: Image.asset(
                MyConstant.coca,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'ความเสียหายที่เกิดกับใบ',
                style: TextStyle(
                  fontSize: w * 0.04,
                ),
              ),
            ),
          ],
        ),
        style: MyConstant().myButtonStyle(Colors.green, Colors.green),
      ),
    );
  }

  AppBar buidAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Menu Page',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'iannnnn-DUCK',
          fontWeight: FontWeight.w900,
          fontSize: 25,
        ),
      ),
    );
  }
}

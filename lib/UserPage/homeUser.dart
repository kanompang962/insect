import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project001/utility/my_constant.dart';
import 'package:project001/utility/size_helper.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({Key? key}) : super(key: key);

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  @override
  Widget build(BuildContext context) {
    double w = displayWidth(context);
    double h = displayHeight(context) -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buidAppbar(w),
      body: buidBody(w, h),
    );
  }

  SingleChildScrollView buidBody(double w, double h) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Divider(
            color: Colors.white,
          ),
          Column(
            children: List.generate(MyConstant().posts.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buidHeader(index, w, h),
                    SizedBox(
                      height: h * 0.012,
                    ),
                    buidCenter(index, w, h),
                    SizedBox(
                      height: h * 0.012,
                    ),
                    buidFooter(w),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Row buidFooter(double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          child: ElevatedButton(
            style: MyConstant().myButtonStyle(Colors.white, MyConstant.primary),
            onPressed: () {},
            child: Text(
              'รายละเอียด',
              style: TextStyle(
                  color: MyConstant.primary,
                  fontSize: w * 0.034,
                  fontFamily: 'Kanit'),
            ),
          ),
        ),
        Container(
          child: ElevatedButton(
            style: MyConstant().myButtonStyle(Colors.white, Colors.red),
            onPressed: () {},
            child: Text(
              'วิธีการป้อกัน',
              style: TextStyle(
                  color: Colors.red, fontSize: w * 0.034, fontFamily: 'Kanit'),
            ),
          ),
        ),
      ],
    );
  }

  Container buidCenter(int index, double w, double h) {
    return Container(
      width: w,
      height: h * 1,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(MyConstant().posts[index]['postImg']),
            scale: 1.0,
            
            ),
      ),
    );
  }

  Padding buidHeader(int index, double w, double h) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: w * 0.08,
                height: h * 0.08,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(
                            MyConstant().posts[index]['profileImg']),
                        fit: BoxFit.cover)),
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                MyConstant().posts[index]['name'],
                style: TextStyle(
                    color: Colors.black26,
                    fontSize: w * 0.034,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ],
      ),
    );
  }

  AppBar buidAppbar(double w) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Home Page',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'iannnnn-DUCK',
          fontWeight: FontWeight.w900,
          fontSize: w * 0.040,
        ),
      ),
    );
  }
}

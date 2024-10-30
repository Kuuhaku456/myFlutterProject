import 'dart:io';

import 'package:fashionapp/controller/model_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MyMobileHomePage extends StatelessWidget {
  const MyMobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ColorRecommendationProvider>(context);
    Color containerBackgroundColor;
    if (provider.colorRecommendation != null) {
      String status = provider.colorRecommendation!['outfit_match']['status'];
      if (status == 'cocok') {
        containerBackgroundColor = Colors.greenAccent;
      } else if (status == 'cukup cocok') {
        containerBackgroundColor = Colors.yellowAccent;
      } else {
        containerBackgroundColor = Colors.redAccent;
      }
    } else {
      containerBackgroundColor = Colors.redAccent;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fashion Matching App',
          style: TextStyle(fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () {
              provider.resetData();
            },
            icon: Icon(
              Icons.refresh,
              size: 30.sp,
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Center(
              child: Text(
                'Upload Your Image',
                style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          provider.isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(), // Circular loading indicator
                    SizedBox(height: 16),
                    Text(
                      'Analyzing...',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                )
              : provider.image != null
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.file(
                        File(provider.image!.path),
                        height: 300.h,
                        width: 300.w,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        height: 350.h,
                        width: 300.w,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text('No image selected.')),
                      ),
                    ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    provider.optionPickImage(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  ),
                  child: Text('Pick Image'),
                ),
                SizedBox(width: 40.w),
                ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          await provider.submitImage();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  ),
                  child: Text('Submit Image'),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              "Hasil Anda",
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          provider.colorRecommendation != null
              ? Center(
                  child: Container(
                    width: 300.w,
                    height: 210.h,
                    padding:
                        EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Warna Kulit       : ",
                              style: TextStyle(
                                  fontSize: 20.sp, color: Colors.black),
                            ),
                            Text(
                              provider.colorRecommendation!['face_skin_tone'] ??
                                  " Unknown ",
                              style: TextStyle(
                                  fontSize: 20.sp, color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "Warna Baju       : ",
                              style: TextStyle(
                                  fontSize: 20.sp, color: Colors.black),
                            ),
                            Text(
                              provider.colorRecommendation!['shirt_color'] ??
                                  " Unknown ",
                              style: TextStyle(
                                  fontSize: 20.sp, color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "Warna Celana   : ",
                              style: TextStyle(
                                  fontSize: 20.sp, color: Colors.black),
                            ),
                            Text(
                              provider.colorRecommendation!['pants_color'] ??
                                  " Unknown ",
                              style: TextStyle(
                                  fontSize: 20.sp, color: Colors.black),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: containerBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: const Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  provider.colorRecommendation?['outfit_match']
                                          ['status'] ??
                                      " Unknown ",
                                  style: TextStyle(
                                      fontSize: 25.sp, color: Colors.black),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  provider.colorRecommendation?['outfit_match']
                                          ['persen'] ??
                                      " Unknnown ",
                                  style: TextStyle(
                                      fontSize: 25.sp, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    width: 300.w,
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "Error dalam Response gambar (404)",
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          provider.colorRecommendation != null 
            ? Container(

            ) : Container(
              
            )
        ],
      )),
    );
  }
}

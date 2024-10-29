import 'dart:io';
import 'package:fashionapp/controller/model_controller.dart';
import 'package:fashionapp/widget/recommend_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
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
        title: Text('Fashion Color Matching App'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () {
              provider.resetData();
            },
            icon: const Icon(
              Icons.refresh,
              size: 40,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 140),
              child: Text(
                'Upload Your Image',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Row(
                children: [
                  Column(
                    children: [
                      provider.isLoading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(), // Circular loading indicator
                                SizedBox(height: 16),
                                Text(
                                  'Analyzing...',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            )
                          : provider.image != null
                              ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.file(File(provider.image!.path),
                                      height: 300),
                                )
                              : Container(
                                  height: 400,
                                  width: 350,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child:
                                      Center(child: Text('No image selected.')),
                                ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await provider.pickImage();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.black,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                              ),
                              child: Text('Pick Image'),
                            ),
                            SizedBox(width: 50),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                              ),
                              child: Text('Submit Image'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  provider.colorRecommendation != null
                          ? Padding(
                              padding: EdgeInsets.only(left: 50),
                              child: Center(
                                child: Container(
                                  width: 600,
                                  height: 350,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Warna Kulit       : ",
                                            style: TextStyle(
                                                fontSize: 40,
                                                color: Colors.black),
                                          ),
                                          Text(
                                            provider.colorRecommendation![
                                                    'face_skin_tone'] ??
                                                " Unknown ",
                                            style: TextStyle(
                                                fontSize: 40,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Text(
                                            "Warna Baju       : ",
                                            style: TextStyle(
                                                fontSize: 40,
                                                color: Colors.black),
                                          ),
                                          Text(
                                            provider.colorRecommendation![
                                                    'shirt_color'] ??
                                                " Unknown ",
                                            style: TextStyle(
                                                fontSize: 40,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Text(
                                            "Warna Celana   : ",
                                            style: TextStyle(
                                                fontSize: 40,
                                                color: Colors.black),
                                          ),
                                          Text(
                                            provider.colorRecommendation![
                                                    'pants_color'] ??
                                                " Unknown ",
                                            style: TextStyle(
                                                fontSize: 40,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 10),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: containerBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                spreadRadius: 3,
                                                blurRadius: 10,
                                                offset: const Offset(4, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                provider.colorRecommendation?[
                                                            'outfit_match']
                                                        ['status'] ??
                                                    " Unknown ",
                                                style: TextStyle(
                                                    fontSize: 40,
                                                    color: Colors.black),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                provider.colorRecommendation?[
                                                            'outfit_match']
                                                        ['persen'] ??
                                                    " Unknnown ",
                                                style: TextStyle(
                                                    fontSize: 40,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                ],
              ),
            ),
            SizedBox(height: 40),
            if (provider.colorRecommendation != null) ...[
              Center(
                child: Text(
                  ' REKOMENDASI WARNA ',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    provider.colorRecommendation!['recommend_color'].length,
                itemBuilder: (context, index) {
                  var recommendation =
                      provider.colorRecommendation!['recommend_color'][index];
                  return RecommendationCard(
                    nuansa: recommendation['nuansa'],
                    baju: recommendation['baju'],
                    celana: recommendation['celana'],
                    hexabaju: recommendation['hexabaju'],
                    hexacelana: recommendation['hexacelana'],
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}

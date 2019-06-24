import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zimageviewer/zimageviewer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  // result of ImageShowView
  String _imageViewerResult = '';

  Future<void> displayImageviewer() async {

    List<String> photos = [
        'https://list25.com/wp-content/uploads/2019/01/powerful-marvel-characters.jpg',
        'https://ultimatecomics.com/wp-content/uploads/2017/11/11-1-2017-23.jpg',
        'https://cdn.gamerant.com/wp-content/uploads/marvel-characters-games.jpg.optimal.jpg',
        'https://cdn3.whatculture.com/images/2018/07/05790009d77f36ba-600x338.jpg'
        ];

    List<String> captions = [
          'Powerful marvel characters',
          'Captain america',
          'Marvel characters games',
          '10 Marvel Characters Who Became Venom'
        ];

    int startIndex = 1;
    String textMsg = '';
    try {
      bool result = await Zimageviewer.displayImageviewer(photos, captions, startIndex);
      if (result == true) textMsg = 'Successed';
      else textMsg = 'Failed';
    } on PlatformException {
      textMsg = 'Failed';
    }

    setState(() {
      _imageViewerResult = textMsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ZImageViewer Plugin'),
        ),
        body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RaisedButton(
              child: Text('Display Image Viewer'),
              onPressed: displayImageviewer,
            ),
            Text(_imageViewerResult),
          ],
          ),
        ),
      ),
    );
  }
}

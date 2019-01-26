import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;
import 'dart:math' as Math;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CompressImage{
  Future <File> takePicture(BuildContext context) async {
    var _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(_imageFile == null){
      return null;
    }

    //You can have a loading dialog here but don't forget to pop before return file;

    final tempDir = await getTemporaryDirectory();
    int rand = new Math.Random().nextInt(10000);
    CompressObject compressObject = new CompressObject(_imageFile, tempDir.path,     rand);
    String filePath = await _compressImage(compressObject);
    print('new path: ' + filePath);
    File file = new File(filePath);
    //pop loading
    return file;
  }

  Future<String> _compressImage(CompressObject object) async {
    return compute(decodeImage, object);
  }

  static String decodeImage(CompressObject object) {
    Im.Image image = Im.decodeImage(object.imageFile.readAsBytesSync());
    Im.Image smallerImage = Im.copyResize(
        image, 800); // choose the size here, it will maintain aspect ratio
    var decodedImageFile = new File(object.path + '/img_${object.rand}.jpg');
    decodedImageFile.writeAsBytesSync(Im.encodeJpg(smallerImage, quality: 90));
    return decodedImageFile.path;
  }
}

class CompressObject{
  File imageFile;
  String path;
  int rand;

  CompressObject(this.imageFile, this.path, this.rand);
}
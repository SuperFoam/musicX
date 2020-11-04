import 'package:flutter/cupertino.dart';

class FaceListProvider with ChangeNotifier {
  void updateFace() {
    notifyListeners();
  }
}

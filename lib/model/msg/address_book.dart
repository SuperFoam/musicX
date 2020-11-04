import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

enum ContactTypeEnum {
  NEW_FRIEND,
  ONLY_CHAT,
  GROUP_CHAT,
  LABEL,
  OFFICIAL_ACCOUNT,
  PERSON,
  LETTER,
  OWNER,
  ADMIN,
}

class AddressBookModel {
  ContactTypeEnum type;
  String id;
  String name;
  Color color;
  IconData icon;
  String pinyin;
  bool isLast;
  bool isBlack;
  bool isMute;

  AddressBookModel.fromJson(Map<String, dynamic> data)
      : type = data['type'],
        id = data['id'],
        color = data['color'],
        icon = data['icon'],
        pinyin = data['pinyin'],
        isLast = data['isLast'],
        isBlack = data['isBlack'],
        isMute = data['isMute'],
        name = data['name'];

  @override
  String toString() => "AddressBookModel instance $name";
}

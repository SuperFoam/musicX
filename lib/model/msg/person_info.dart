import 'dart:math';
enum PersonSex { MAN, WOMAN, UNKNOWN }
enum FriendPermission { ALL, CHAT }

const defaultMoments = ['assets/img/yuan.jpg', 'assets/img/newsong.jpg', 'assets/img/hotsong.jpg', 'assets/img/biaosheng.jpg'];

class PersonInfoModel {
  PersonSex sex;

  String remark;
  String nickname;
  String userId;
  String location;
  FriendPermission friendPermission;
  bool hideMyPosts;
  bool hideHisPosts;
  List moments;
  bool isStar;
  bool isBlacklist;
  bool  muteNotice;
  bool topChat;
  bool chatAlert;


  PersonInfoModel.fromJson(Map<String, dynamic> data)
      : remark = data['remark']??'随机备注-${randomNum()}',
        nickname = data['nickname']??'随机昵称-${randomNum()}',
        userId = data['userId'],
        location = data['location']??'随机位置${randomNum()}',
        hideMyPosts = data['hideMyPosts'] ?? false,
        hideHisPosts = data['hideHisPosts'] ?? false,
        isStar = data['isStar'] ?? false,
        isBlacklist = data['isBlacklist'] ?? false,
        muteNotice = data['muteNotice'] ?? false,
        topChat = data['topChat'] ?? false,
        chatAlert = data['chatAlert'] ?? false,
        moments = data['moments'] ?? defaultMoments {
    sex = setSex(data['sex']);
    friendPermission = setFriendPermission(data['friendPermission']);
  }
  static String randomNum(){
    int num = Random().nextInt(99);
    return num.toString();
  }
Map toDataMap(){
    Map t={};
    t['sex']=getSex(this.sex);
    t['remark']=this.remark;
    t['nickname']=this.nickname;
    t['userId']=this.userId;
    t['location']=this.location;
    t['friendPermission']=getFriendPermission(this.friendPermission);
    t['hideMyPosts']=this.hideMyPosts;
    t['hideHisPosts']=this.hideHisPosts;
    t['moments']=this.moments;
    t['isStar']=this.isStar;
    t['isBlacklist']=this.isBlacklist;
    return t;
}
  PersonSex setSex(int sex) {
    switch (sex) {
      case 1:
        return PersonSex.MAN;
      case 2:
        return PersonSex.WOMAN;
      default:
        return PersonSex.UNKNOWN;
    }
  }
  int getSex(PersonSex sex) {
    switch (sex) {
      case PersonSex.MAN:
        return 1;
      case PersonSex.WOMAN:
        return 2;
      default:
        return 3;
    }
  }

  FriendPermission setFriendPermission(int permission) {
    switch (permission) {
      case 1:
        return FriendPermission.ALL;
      case 2:
        return FriendPermission.CHAT;
      default:
        return FriendPermission.ALL;
    }
  }
  int getFriendPermission(FriendPermission permission) {
    switch (permission) {
      case FriendPermission.ALL:
        return 1;
      case FriendPermission.CHAT:
        return 2;
      default:
        return 1;
    }
  }
  String getFriendPermissionString() {
    switch (this.friendPermission) {
      case FriendPermission.ALL:
        return '聊天、朋友圈、访客记录等';
      case FriendPermission.CHAT:
        return '仅聊天';
      default:
        return '聊天、朋友圈、访客记录等';
    }
  }
}

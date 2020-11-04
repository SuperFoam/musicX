import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ConversionModel {
  EMMessage lastMsg;
  int unRead;
  int lastMsgTime;
  String conversationId;
  int conversationType;
  bool isTop = false;
  String name ;

  ConversionModel.fromData(Map<String, dynamic> data)
      :lastMsg=data['lastMsg'],
        unRead=data['unRead'],
        lastMsgTime=int.parse(data['lastMsgTime']),
        isTop=data['isTop'],
        name=data['name'],
        conversationId=data['conversationId'],
        conversationType=data['conversationType'];


  @override
  String toString() =>'$conversationId-$lastMsgTime';

  int get isTopNum => isTop==true ? 1 : 0;

}

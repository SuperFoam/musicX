import 'dart:io';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class CustomEMMessage extends EMMessage {
  int a = 0;

  CustomEMMessage.createImageSendMessage(File file, bool sendOriginalImage, String userName)
      : a = 1,
        super(direction: Direction.SEND, type: EMMessageType.IMAGE, body: EMImageMessageBody(file, sendOriginalImage), to: userName);
}


class EMCustomTextMessageBody extends EMMessageBody {
  /// 初始化方法，[message]: 消息内容
  EMCustomTextMessageBody(List message) : this.message = message;
  final List message;

  @override

  /// @nodoc
  String toString() => '[EMCustomTextMessageBody], {message: $message}';

  @override

  /// @nodoc
  Map<String, dynamic> toDataMap() {
    var result = Map<String, dynamic>();
    result['message'] = message;
    return result;
  }

  /// @nodoc
  static EMMessageBody fromData(Map data) {
    print('fromData is $data');
    return EMTextMessageBody(data['message']);
  }
}
class EMCustomLocationMessageBody extends EMFileMessageBody {
  EMCustomLocationMessageBody(File file,String title,String address, double latitude, double longitude,
      [EMCustomLocationMessageBody body])
      :this._file=file,
        this.title=title,
        this.address = address,
        this.latitude = latitude,
        this.longitude = longitude,
        this._body = body,
        super(file.path);


  EMCustomLocationMessageBody _body;
  final File _file;
  final String title;
  /// 地址
  final String address;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  @override
  /// @nodoc
  String toString() =>
      '[EMCustomLocationMessageBody], {address: $address, latitude: $latitude, longitude: $longitude, body: $_body}';

  @override
  /// @nodoc
  Map toDataMap() {
    Map<String, dynamic> result = Map.of(super.toDataMap());
    result['title'] = title;
    result['address'] = address;
    result['latitude'] = latitude;
    result['longitude'] = longitude;
    return result;
  }
  EMCustomLocationMessageBody._internal(Map data)
      : this._file = null,
        this.title=data['title'],
        this.address = data['address'],
        this.latitude = data['latitude'],
        this.longitude = data['longitude'],
        super.ofData(data);

  static EMMessageBody fromData(Map data) {
    print('收到数据$data');
    return EMCustomLocationMessageBody._internal(data);
  }
}


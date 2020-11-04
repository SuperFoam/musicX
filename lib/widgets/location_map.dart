import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocationMapPage extends StatefulWidget {
  final String locationInfo;

  LocationMapPage({this.locationInfo});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LocationMapPageState();
  }
}

class _LocationMapPageState extends State<LocationMapPage> with AmapSearchDisposeMixin {
  RefreshController _controllerR = RefreshController(initialRefresh: false);
  AmapController _controller;
  MyLocationOption locationOption;
  LatLng _currentCenterLocation;
  Location myLocation;
  int _page = 1;
  double _fabHeight = 16;
  List<Poi> roundPoi = [];
  int selectPoi = 0;
  bool _moveByUser = true;
  ScrollController _listScroller;
  Map locationInfo;
  LatLng targetLatLng;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationOption = MyLocationOption(
      show: true,
      fillColor: Colors.transparent,
      strokeColor: Colors.transparent,
      // iconProvider:xImage()
    );
    if (widget.locationInfo != null) {
      locationInfo = FluroConvertUtils.string2map(widget.locationInfo);
      print('类型是${locationInfo['latitude'].runtimeType}');
      targetLatLng = LatLng(double.parse(locationInfo['latitude']), double.parse(locationInfo['longitude']));
    }
  }

  @override
  void dispose() {
    //_controller.dispose();
    _controller?.dispose();
    _listScroller?.dispose();
    _controllerR?.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return locationInfo == null ? buildSendLocation : buildShowLocationMessage;
  }

  Widget get buildSendLocation {
    return Scaffold(
        appBar: AppBar(
          actions: [
            FlatButton(
              child: Text('发送'),
              textColor: Colors.white,
              onPressed: () {

                sendLocation();
              },
            )
          ],
        ),
        body: buildSlide
        //buildSliver
        );
  }

  Widget get buildShowLocationMessage {
    return Scaffold(
      appBar: AppBar(
        title: Text('位置信息'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                AmapView(
                  // maskDelay :const Duration(seconds: 2),
                  showZoomControl: false,
                  zoomLevel: 15,
                centerCoordinate:targetLatLng,

                  onMapCreated: (controller) async {
                    _controller = controller;
                   // await _controller?.showMyLocation(locationOption);
                    await _controller.addMarker(MarkerOption(
                        latLng: targetLatLng,
                        widget: Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 30,
                        )));
//                    await _controller.setCenterCoordinate(
//                      targetLatLng,
//                      zoomLevel: 15,
//                    );

                  },
                ),
                Positioned(
                    right: 5,
                    bottom: _fabHeight,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      mini: true,
                      onPressed: () async {
                        await _controller?.showMyLocation(locationOption);
                      },
                      child: Icon(
                        Icons.my_location,
                        color: Theme.of(context).primaryColor,
                      ),
                    ))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              title: Text(locationInfo['title']),
              subtitle: Text(locationInfo['address']),
              isThreeLine: true,
              trailing: Icon(
                Icons.navigation,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                showNavigateAction();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget get buildSlide {
    final minPanelHeight = MediaQuery.of(context).size.height * 0.4;
    final maxPanelHeight = MediaQuery.of(context).size.height * 0.6;
    return SlidingUpPanel(
      color:Theme.of(context).scaffoldBackgroundColor,
        panelSnapping: false,
        parallaxEnabled: true,
        parallaxOffset: 0.5,
        minHeight: minPanelHeight,
        maxHeight: maxPanelHeight,
        borderRadius: BorderRadius.circular(10),
        onPanelSlide: (pos) {
          setState(() {
            _fabHeight = pos * (maxPanelHeight - minPanelHeight) * .5 + 16;
          });
        },
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  AmapView(
                    // maskDelay :const Duration(seconds: 2),
                    showZoomControl: false,
                    zoomLevel: 15,

                    onMapCreated: (controller) async {
                      _controller = controller;
                      await _controller?.showMyLocation(locationOption);
                      myLocation = await AmapLocation.instance.fetchLocation();
                    },
                    onMapMoveEnd: (move) async {
                      print('onMapMoveEnd--------');
                      if (_moveByUser) _search(move.latLng);
                      _moveByUser = true;
                      _currentCenterLocation = move.latLng;
                    },
                  ),
                  Center(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  Positioned(
                      right: 5,
                      bottom: _fabHeight,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white, // Theme.of(context).scaffoldBackgroundColor,
                        mini: true,
                        onPressed: () async {
                          await applyStoragePermanent();
                          await _controller?.showMyLocation(locationOption);
                        },
                        child: Icon(
                          Icons.my_location,
                          color: Theme.of(context).primaryColor,
                        ),
                      ))
                ],
              ),
            ),
            SizedBox(height: minPanelHeight + kToolbarHeight + 20),
          ],
        ),
        boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(-5, -5), blurRadius: 5)],
        panelBuilder: (_controller2) {
          _listScroller = _controller2;
          return SmartRefresher(
            controller: _controllerR,
            enablePullDown: false,
            enablePullUp: true,
            footer: ClassicFooter(
              loadStyle: LoadStyle.ShowAlways,
              //completeDuration: Duration(microseconds: 50),
              idleText: '',
              loadingIcon: CupertinoActivityIndicator(),
              canLoadingIcon: CupertinoActivityIndicator(),
              canLoadingText: '',
            ),
            onLoading: () async {
              _handleLoadMore();
            },
            child: ListView.builder(
                controller: _controller2,
                itemCount: roundPoi.length,
                itemBuilder: (context, int index) {
                  return ListTile(
                    title: Text(roundPoi[index].title),
                    subtitle: Text('${formatDistance(roundPoi[index].distance)} | ' + (roundPoi[index].address.isNotEmpty ? roundPoi[index].address : '暂无地址')),
                    trailing: index == selectPoi
                        ? Icon(
                            Icons.done,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: () {
                      selectPoi = index;
                      _setCenterCoordinate(roundPoi[index].latLng);
                      setState(() {});
                    },
                  );
                }),
          );
        });
  }

  String formatDistance(int distance) {
    if (distance >= 1000)
      return (distance / 1000).toStringAsFixed(1) + 'km';
    else
      return distance.toString() + 'm';
  }

  Future<void> _setCenterCoordinate(LatLng coordinate) async {
    _moveByUser = false;
    await _controller.setCenterCoordinate(coordinate);
  }

  Future<void> _search(LatLng location) async {
    List<Poi> poiList = await AmapSearch.instance.searchAround(location);
    if (myLocation != null) {
      await Future.forEach(poiList, (element) async {
        double distance = await AmapService.instance.calculateDistance(myLocation.latLng, element.latLng);
        element.distance = distance.toInt();
      });
    }

    roundPoi.clear();
    roundPoi = poiList;

    // 重置页数
    _page = 1;
    selectPoi = 0;
    _listScroller.jumpTo(0.0);
    setState(() {});
  }

  Future<void> _handleLoadMore() async {
    List<Poi> poiList = await AmapSearch.instance.searchAround(
      _currentCenterLocation,
      page: ++_page,
    );
    if (poiList == null || poiList.length == 0) {
      _controllerR.loadNoData();
      return;
    }
    if (myLocation != null) {
      await Future.forEach(poiList, (element) async {
        double distance = await AmapService.instance.calculateDistance(myLocation.latLng, element.latLng);
        element.distance = distance.toInt();
      });
    }
    roundPoi.addAll(poiList);
    _controllerR.loadComplete();
    setState(() {});
  }

  Widget get buildSliver {
    final minHeight = MediaQuery.of(context).size.height * 0.25;
    final maxHeight = MediaQuery.of(context).size.height * 0.6;
    return CustomScrollView(
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          delegate: MySliverPersistentHeaderDelegate(child: buildChild(), maxHeight: maxHeight, minHeight: minHeight),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: MySliverPersistentHeaderDelegate(
              child: Divider(
                thickness: 1,
                color: Colors.black54,
              ),
              maxHeight: 5,
              minHeight: 5),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((content, index) {
            return ListTile(
              title: Text('index$index'),
            );
          }, childCount: 20),
        )
      ],
    );
  }

  Widget buildChild() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              AmapView(
                // maskDelay :const Duration(seconds: 2),
                showZoomControl: false,
                zoomLevel: 15,

                onMapCreated: (controller) async {
                  _controller = controller;
                  await _controller?.showMyLocation(locationOption);
                },
                onMapMoveEnd: (move) async {
                  //_search(move.latLng);
                  _currentCenterLocation = move.latLng;
                },
              ),
              Center(
                child: Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  mini: true,
                  onPressed: () async {
                    await applyStoragePermanent();
                    await _controller?.showMyLocation(locationOption);
                  },
                  child: Icon(
                    Icons.my_location,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Positioned(
                  right: 5,
                  bottom: _fabHeight,
                  child: FloatingActionButton(
                    heroTag: 'qq',
                    backgroundColor: Colors.white,
                    mini: true,
                    onPressed: () async {
                      await applyStoragePermanent();
                      await _controller?.showMyLocation(locationOption);
                    },
                    child: Icon(
                      Icons.my_location,
                      color: Theme.of(context).primaryColor,
                    ),
                  ))
            ],
          ),
        ),
      ],
    );
  }
  Future _saveImage(Uint8List uint8List, String dir, String fileName, {Function success, Function fail}) async {
    String tempPath = '$dir$fileName';
    File image = File(tempPath);
    bool isExist = await image.exists();
    if (isExist) await image.delete();
    //await File(tempPath).writeAsBytes(uint8List);
    File(tempPath).writeAsBytesSync(
      uint8List,
    );
  }

  void sendLocation() async {
    String dir;
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory()).path + '/screenshots/';
      Directory music = Directory(dir);
      if (!music.existsSync()) {
        music.createSync(recursive: true);
      }
    } else {
      dir = (await getApplicationDocumentsDirectory()).path;
    }
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
    await _controller.addMarker(MarkerOption(
        latLng: roundPoi[selectPoi].latLng,
        widget: Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 30,
        )));
//    _controller.screenShot((imageData) async {
//      await _saveImage(imageData, dir, fileName);
//      Map t = {
//        "title": roundPoi[selectPoi].title,
//        'address': roundPoi[selectPoi].address.isNotEmpty?roundPoi[selectPoi].address:'暂无地址',
//        'path': dir + fileName,
//        'latitude': roundPoi[selectPoi].latLng.latitude.toString(),
//        'longitude': roundPoi[selectPoi].latLng.longitude.toString(),
//      };
//      Navigator.pop(context, t);
//    });
    Uint8List imageData= await _controller.screenShot();
    await _saveImage(imageData, dir, fileName);
    Map t = {
      "title": roundPoi[selectPoi].title,
      'address': roundPoi[selectPoi].address.isNotEmpty?roundPoi[selectPoi].address:'暂无地址',
      'path': dir + fileName,
      'latitude': roundPoi[selectPoi].latLng.latitude.toString(),
      'longitude': roundPoi[selectPoi].latLng.longitude.toString(),
    };
    Navigator.pop(context, t);
  }
  showNavigateAction() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
              title: Text('打开外部地图'),
              cancelButton: CupertinoActionSheetAction(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(
                      '高德地图',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                    onPressed: () {
                      AmapService.instance.navigateDrive(targetLatLng);
                    }),
                CupertinoActionSheetAction(
                    child: Text(
                      '百度地图',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                    onPressed: () {}),
              ]);
        });
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  final double maxHeight;
  final double minHeight;

  MySliverPersistentHeaderDelegate({@required this.child, @required this.maxHeight, @required this.minHeight});

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false; //

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }
}

class MySliverPersistentHeaderDelegate2 extends SliverPersistentHeaderDelegate {
  AmapController _controller;
  MyLocationOption locationOption = MyLocationOption(
    show: true,
    fillColor: Colors.transparent,
    strokeColor: Colors.transparent,
    // iconProvider:xImage()
  );
  LatLng _currentCenterLocation;
  int _page;
  double _fabHeight = 0;

  @override
  double get maxExtent => 400.0;

  @override
  double get minExtent => 250.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false; //

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              AmapView(
                // maskDelay :const Duration(seconds: 2),
                showZoomControl: false,
                centerCoordinate: LatLng(31.245105, 121.506377),
                zoomLevel: 15,

                onMapCreated: (controller) async {
                  _controller = controller;
                  await _controller?.showMyLocation(locationOption);
                },
                onMapMoveEnd: (move) async {
                  //_search(move.latLng);
                  _currentCenterLocation = move.latLng;
                },
              ),
              Center(
                child: Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  mini: true,
                  onPressed: () async {
                    await applyStoragePermanent();
                    await _controller?.showMyLocation(locationOption);
                  },
                  child: Icon(
                    Icons.my_location,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Positioned(
                  right: 5,
                  bottom: _fabHeight,
                  child: FloatingActionButton(
                    heroTag: 'qq',
                    backgroundColor: Colors.white,
                    mini: true,
                    onPressed: () async {
                      await applyStoragePermanent();
                      await _controller?.showMyLocation(locationOption);
                    },
                    child: Icon(
                      Icons.my_location,
                      color: Theme.of(context).primaryColor,
                    ),
                  ))
            ],
          ),
        ),
      ],
    );
  }
}

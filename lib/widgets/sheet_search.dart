import 'package:music_x/provider/player.dart';
import 'package:music_x/provider/song_sheet_detail.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/song_more_info.dart';
import 'package:provider/provider.dart';

import 'custom_search.dart';
import 'package:flutter/material.dart';

import 'local_or_network_image.dart';
class SearchBarDelegate extends MySearchDelegate<String> {
  final List songList;
  List resList=[];
  String curSongID;
  String type='sheet';
  SearchBarDelegate({@required this.songList,@required this.curSongID,this.type='sheet'});
  @override
  String get searchFieldLabel => '搜索歌单内歌曲';
  int id=0;
  List recentSuggest =  List.from(MySheetSearch.getData().reversed.toList());


  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      InkWell(
        onTap: (){
          showResults(context);
        },
        child: Container(width: 40,margin: EdgeInsets.symmetric(horizontal: 5),
          child: Center(child:  Text('搜索'),),),
      ),
      IconButton(
        icon: Icon(Icons.clear,color: Colors.grey),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),

    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = "";
          showSuggestions(context);
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    MySheetSearch.add(query);
    recentSuggest=List.from(MySheetSearch.getData().reversed.toList());
    if(resList.length==0) return Center(child:Text('无相关结果'),);
    return ListView.builder(
        itemCount: resList.length,
        itemBuilder: (context,index){
          return   ListTile(
            leading: Container(
                height: 40,
                width: 40,
                child: curSongID == resList[index]['baseInfo']['id']
                    ? Icon(Icons.volume_up,
                    color: Theme.of(context).primaryColor)
                    : xImgRoundRadius(
                    urlOrPath: resList[index]['baseInfo']['picUrl'])),
            title: Text(
              resList[index]['baseInfo']['name'],
              style: TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(children: <Widget>[
              if(resList[index]['isDownload']==true)  Icon(Icons.cloud_done,size: 15,color: Theme.of(context).primaryColor,)
              else if (resList[index]['isLocal']==true)  Icon(Icons.phone_android,size: 15,color: Theme.of(context).primaryColor,),
              if(resList[index]['isDownload']==true || resList[index]['isLocal']==true) SizedBox(width: 5,),
              Expanded(flex: 1,child:  Text(resList[index]['baseInfo']['author'],
                style: TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis,),),
            ],),
            trailing: InkWell(
                child: Container(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.more_vert),
                ),
                onTap: () {
                  showMusicMoreInfo(context, songList[index],type: type);
                }),
            onTap: () {
              if (curSongID ==
                  resList[index]['baseInfo']['id']) {
                NavigatorUtil.goPlaySong(context);
              } else {
                List newPlayList=List.from(resList);
                Provider.of<PlayerModel>(context,listen: false).playSong(resList[index], songIndex:index,newPlayList: newPlayList).then((value){
                  if(value==404){
                    Provider.of<SongSheetModel>(context,listen: false).refresh();
                  }
                  curSongID= resList[index]['baseInfo']['id'];
                  id+=1;
                  historyIndex=id;
                });
              }
            },
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentSuggest
        :songList.where((input) => input['baseInfo']['name'].contains(query)).toList();
    if(query.isNotEmpty) resList=suggestionList;
    if(query.isEmpty) return  Padding(padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 15),child: Text('历史记录',style: TextStyles.textDialogTitle,),),
              IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: (){
                  if(recentSuggest.length==0) return;
                  Funs.showCustomDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('确定要删除${recentSuggest.length}条历史记录',style: TextStyles.textDialogTitle,),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("取消"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text("删除"),
                            onPressed: () {
                              MySheetSearch.clean();
                              recentSuggest.clear();
                              historyIndex=recentSuggest.length+1;
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );

                },
              )
            ],),
          Flexible(child: Wrap(
            spacing: 10,
            //runSpacing: 1,
            children:
            List.generate(recentSuggest.length, (index){
              return   GestureDetector(
                onTap: (){
                  query=recentSuggest[index];
                  //showResults(context);
                },
                child: Chip(label: Text(recentSuggest[index]),
                  onDeleted: (){
                    MySheetSearch.delete(recentSuggest[index]);
                    recentSuggest.removeAt(index);
                    id+=1;
                    historyIndex=id;
                    // showSuggestions(context);

                  },
                  deleteIcon: Icon(Icons.delete_forever),
                  deleteIconColor: Colors.grey,),
              );
            }),


          ),),

        ],),);
    else if(suggestionList.length==0)  return Center(child:Text('无相关结果'),);
    else
      return ListView.builder(
          itemCount: suggestionList.length,
          itemBuilder: (context,index){
            String songName = suggestionList[index]['baseInfo']['name'];
            int location = songName.indexOf(query);
            return  ListTile(
              title: RichText(
                  text: TextSpan(
                    // 获取搜索框内输入的字符串，设置它的颜色并让让加粗
                      text: songName.substring(0, location),
                      style: TextStyle(
                          color: Colors.grey),
                      children: [
                        TextSpan(
                          text: songName.substring(location, location+query.length),
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          //获取剩下的字符串，并让它变成灰色
                            text: songName.substring(location+query.length),
                            style: TextStyle(color: Colors.grey))
                      ]
                  )
              ),
              onTap: (){
                query=songName;
                resList=[suggestionList[index]];
                showResults(context);

              },
            );
          }
      );
  }


  @override
  ThemeData appBarTheme(BuildContext context) {
    // return super.appBarTheme(context);
    ThemeData t= Theme.of(context);
    ThemeData tt=t.copyWith(
        backgroundColor: Funs.isDarkMode(context) ? Colours.dark_page_color : Colors.white,
        primaryIconTheme: t.primaryIconTheme.copyWith(color: Colors.grey),
        primaryTextTheme:t.textTheme
    );
    return tt;
  }
}

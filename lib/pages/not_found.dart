import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('404页面'),
        ),
        body: Center(
            child: Text('页面走丢了', style: TextStyle(fontSize: 30))
        ),

    );
  }
}



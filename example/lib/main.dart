import 'dart:math';

import 'package:fetch_more/bloc.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FetchMoreBuilder(
        itemBuilder: (BuildContext context, List list, int index) {
          return Card(
            child: Container(
              height: 50,
              child: Center(
                child: Text(
                  list.elementAt(index).toString(),
                ),
              ),
            ),
          );
        },
        dataFetcher: _dataFetcher,
        limit: 20,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<dynamic>> _dataFetcher(int index, int limit,
      [String searchTerm]) async {
    await Future.delayed(Duration(milliseconds: 1000));
    List list = [];
    for (int i = 0; i < limit; i++) {
      Random rdm = Random();
      list.add(rdm.nextInt(100));
    }
    return list;
  }
}

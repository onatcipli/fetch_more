# example

```dart
import 'dart:math';

import 'package:fetch_more/fetch_more.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final GlobalKey<FetchMoreBuilderState> _fetchMoreController =
      GlobalKey<FetchMoreBuilderState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch More Builder'),
        ),
        body: FetchMoreBuilder(
          fetchMoreController: _fetchMoreController,
          itemBuilder: _itemBuilder,
          dataFetcher: _dataFetcher,
          limit: 10,
        ),
        floatingActionButton: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(Icons.refresh),
              onPressed: () {
                _fetchMoreController.currentState.refresh();
              },
            ),
            SizedBox(width: 15,),
            FloatingActionButton(
              child: Icon(Icons.get_app),
              onPressed: () {
                _fetchMoreController.currentState.fetch();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// You can get your data from the server in this function
  Future<List<dynamic>> _dataFetcher(int index, int limit,
      [String searchTerm]) async {
    await Future.delayed(Duration(milliseconds: 1000));
    List list = [];
    if (index == 60) {
      // returning empty List tells to the FetchMoreBuilder data finished.
      return list;
    }
    for (int i = 0; i < limit; i++) {
      Random rdm = Random();
      list.add(rdm.nextInt(100));
    }
    return list;
  }

  Widget _itemBuilder(BuildContext context, List list, int index) {
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
  }
}

```
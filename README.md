# fetch_more

I inspired from [Felix Angelov](https://twitter.com/felangelov)'s [flutter bloc examples](https://felangel.github.io/bloc/#/flutterinfinitelisttutorial)

A Flutter package that helps to collect and show data inside a ListView with a limit and fetch more when user needs more data.
Also has a RefreshIndicator that sends request with index zero.

## Latest Stable Version

    fetch_more: 2.0.0

### FetchMoreBuilder with specify the LoaderWidgets

  You don't need to specify LoaderWidgets.

````dart
  Widget buildFetchMoreWidget(BuildContext context) {
    return FetchMoreBuilder(
      errorWidget: Center(child: Text('Error Widget')),
      bottomLoaderWidget: Center(child: Text('Bottom Loader')),
      refreshLoaderWidget: Center(child: Text('Refresh Loader')),
      itemBuilder: _itemBuilder,
      dataFetcher: _dataFetcher,
      limit: 20,
     );
  }
````

## FetchMoreBuilder

````dart
  Widget buildFetchMoreWidget(BuildContext context) {
    return FetchMoreBuilder(
      itemBuilder: _itemBuilder,
      dataFetcher: _dataFetcher,
      limit: 20,
     );
  }
````


## DataFetcher:

````dart
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

````

## ItemBuilder 

````dart
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
````

## FetchMoreController Usage 

````dart
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
````

[screenshot](screenshots/screenshot_00.png)


## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

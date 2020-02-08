import 'dart:async';

import 'package:fetch_more/default_bottom_loader.dart';
import 'package:fetch_more/default_error_builder.dart';
import 'package:fetch_more/default_refresh_loader.dart';
import 'package:fetch_more/fetch_more.dart';
import 'package:fetch_more/fetch_more_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef Future<List<dynamic>> DataFetcher(
  int index,
  int limit,
);

typedef ItemBuilder = Widget Function(
  BuildContext context,
  List<dynamic> list,
  int index,
);

class FetchMoreBuilder extends StatefulWidget {
  /// To be able to control [FetchMoreBuilder]
  /// such as fetch new data, refresh
  final GlobalKey<FetchMoreBuilderState> fetchMoreController;

  final DataFetcher dataFetcher;
  final ItemBuilder itemBuilder;

  /// This widgets appear in the bottom of your list
  /// when you scroll down to the bottom of your list and
  /// it will disappear when the data fetched
  final Widget bottomLoaderWidget;

  /// When the page is refreshed with [RefreshIndicator],
  /// this widgets will be showing to you until the data fetched
  final Widget refreshLoaderWidget;
  final Widget errorWidget;

  final int limit;
  final double scrollThreshold;

  FetchMoreBuilder({
    this.fetchMoreController,
    @required this.dataFetcher,
    @required this.itemBuilder,
    @required this.limit,
    this.scrollThreshold = 200.0,
    this.bottomLoaderWidget = const DefaultBottomLoader(),
    this.errorWidget = const DefaultErrorBuilder(),
    this.refreshLoaderWidget = const DefaultRefreshLoader(),
  }) : super(key: fetchMoreController);

  @override
  FetchMoreBuilderState createState() => FetchMoreBuilderState();
}

class FetchMoreBuilderState extends State<FetchMoreBuilder> {
  FetchMoreBloc fetchMoreBloc;
  ScrollController _scrollController;

  GlobalKey<ScrollableState> _listViewKey;

  DataFetcher get _dataFetcher => widget.dataFetcher;

  ItemBuilder get _itemBuilder => widget.itemBuilder;

  @override
  void initState() {
    _handleInitState();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FetchMoreBloc>(
      create: (context) => fetchMoreBloc,
      child: _buildFetchMore(),
    );
  }

  /// This function for refreshing the list,
  /// it recalls the [DataFetcher] with index equals to zero
  Future<void> refresh() async {
    fetchMoreBloc.add(Refresh());
    await Future<dynamic>.delayed(Duration(seconds: 1));
    _handleEmptyList();
  }

  /// This function for fetching more data,
  /// it recalls the [DataFetcher] with increasing the index
  Future<void> fetch() async {
    fetchMoreBloc.add(Fetch());
    await Future<dynamic>.delayed(Duration(seconds: 1));
    _handleEmptyList();
  }

  void _handleInitState() {
    _listViewKey = GlobalKey<ScrollableState>();
    fetchMoreBloc =
        FetchMoreBloc(dataFetcher: _dataFetcher, limit: widget.limit);
    _scrollController = ScrollController();
    _handleEmptyList();
    _scrollController.addListener(_handleOnScroll);
  }

  BlocBuilder<FetchMoreBloc, FetchMoreState> _buildFetchMore() {
    return BlocBuilder<FetchMoreBloc, FetchMoreState>(
      builder: (context, state) {
        if (state is FetchError) {
          return widget.errorWidget;
        }
        if (state is Fetched) {
          if (state.list == null) {
            return Center(
              child: Text('No data available now!'),
            );
          }
          if (state.list.isEmpty) {
            return Center(
              child: Text('No data available now!'),
            );
          }
          return RefreshIndicator(
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              key: _listViewKey,
              itemBuilder: (BuildContext context, int index) {
                return index >= state.list.length
                    ? widget.bottomLoaderWidget
                    : _itemBuilder(context, state.list, index);
              },
              itemCount: state.hasReachedMax
                  ? state.list.length
                  : state.list.length + 1,
              controller: _scrollController,
            ),
            onRefresh: refresh,
          );
        }
        return widget.refreshLoaderWidget;
      },
    );
  }

  void _handleOnScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= widget.scrollThreshold) {
      fetchMoreBloc.add(Fetch());
    }
  }

  void _handleRefreshTiming(Duration _totalTime) {
    Timer.periodic(
      Duration(milliseconds: 1000),
      (t) {
        // ignore: invalid_use_of_protected_member
        if (_scrollController.positions.isEmpty) {
          return;
        } else {
          if (_scrollController.position.minScrollExtent == 0.0 &&
              _scrollController.position.maxScrollExtent == 0.0) {
            fetchMoreBloc.add(Fetch());
            t.cancel();
          } else {
            _totalTime += Duration(milliseconds: 1000);
            if (_totalTime > Duration(seconds: 20)) {
              t.cancel();
            }
          }
        }
      },
    );
  }

  void _handleEmptyList() {
    WidgetsBinding.instance.addPostFrameCallback(
      (Duration duration) async {
        Duration _totalTime = Duration();
        if (_listViewKey.currentContext == null) {
          _handleRefreshTiming(_totalTime);
        } else {
          if (fetchMoreBloc.initialState is Fetched) {
            if (_scrollController.position.minScrollExtent == 0.0 &&
                _scrollController.position.maxScrollExtent == 0.0) {
              fetchMoreBloc.add(Fetch());
            }
          } else {
            _handleRefreshTiming(_totalTime);
          }
        }
      },
    );
  }
}

import 'dart:async';

import 'package:fetch_more/fetch_more.dart';
import 'package:fetch_more/fetch_more_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef Future<List<dynamic>> DataFetcher(
  int index,
  int limit, [
  String searchTerm,
]);

typedef ItemBuilder = Widget Function(
  BuildContext context,
  List<dynamic> list,
  int index,
);

class FetchMoreBuilder extends StatefulWidget {
  /// If you need to control FetchMoreBuilder outside the widget you can provide the BLoC from outside.
  final FetchMoreBloc fetchMoreBloc;

  final DataFetcher dataFetcher;
  final ItemBuilder itemBuilder;
  final Widget bottomLoaderBuilder;
  final Widget errorBuilder;

  final int limit;
  final double scrollThreshold;

  FetchMoreBuilder({
    @required this.dataFetcher,
    @required this.itemBuilder,
    @required this.limit,
    this.fetchMoreBloc,
    this.scrollThreshold = 200.0,
    this.bottomLoaderBuilder = const DefaultBottomLoader(),
    this.errorBuilder = const DefaultErrorBuilder(),
  });

  @override
  _FetchMoreBuilderState createState() => _FetchMoreBuilderState();
}

class _FetchMoreBuilderState extends State<FetchMoreBuilder> {
  FetchMoreBloc fetchMoreBloc;
  ScrollController _scrollController;

  GlobalKey<ScrollableState> _listViewKey;

  DataFetcher get _dataFetcher => widget.dataFetcher;

  ItemBuilder get _itemBuilder => widget.itemBuilder;

  @override
  void initState() {
    handleInitState();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fetchMoreBloc != null) {
      return _buildFetchMore();
    } else {
      return BlocProvider<FetchMoreBloc>(
        builder: (context) => fetchMoreBloc,
        child: _buildFetchMore(),
      );
    }
  }

  BlocBuilder<FetchMoreBloc, FetchMoreState> _buildFetchMore() {
    return BlocBuilder<FetchMoreBloc, FetchMoreState>(
      builder: (context, state) {
        if (state is FetchError) {
          return widget.errorBuilder;
        }
        if (state is Fetched) {
          if (state.list.isEmpty) {
            return Center(
              child: Text('No data available now!'),
            );
          }
          return RefreshIndicator(
            child: ListView.builder(
              key: _listViewKey,
              itemBuilder: (BuildContext context, int index) {
                return index >= state.list.length
                    ? widget.bottomLoaderBuilder
                    : _itemBuilder(context, state.list, index);
              },
              itemCount: state.hasReachedMax
                  ? state.list.length
                  : state.list.length + 1,
              controller: _scrollController,
            ),
            onRefresh: _handleOnRefresh,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void handleInitState() {
    _listViewKey = GlobalKey<ScrollableState>();
    if (widget.fetchMoreBloc == null) {
      fetchMoreBloc =
          FetchMoreBloc(dataFetcher: _dataFetcher, limit: widget.limit);
    } else {
      fetchMoreBloc = widget.fetchMoreBloc;
      fetchMoreBloc.dataFetcher = _dataFetcher;
      fetchMoreBloc.limit = widget.limit;
    }
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (Duration duration) async {
        if (_listViewKey.currentContext == null) {
          Timer.periodic(
            Duration(milliseconds: 1000),
            (t) {
              if (_scrollController.positions.isEmpty) {
                return;
              } else {
                if (_scrollController.position.minScrollExtent == 0.0 &&
                    _scrollController.position.maxScrollExtent == 0.0) {
                  fetchMoreBloc.dispatch(ListViewIsNotScrollable());
                  t.cancel();
                }
              }
            },
          );
        } else {
          if (_scrollController.position.minScrollExtent == 0.0 &&
              _scrollController.position.maxScrollExtent == 0.0) {
            fetchMoreBloc.dispatch(ListViewIsNotScrollable());
          }
        }
      },
    );
    _scrollController.addListener(_handleOnScroll);
  }

  void _handleOnScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= widget.scrollThreshold) {
      fetchMoreBloc.dispatch(Fetch());
    }
  }

  Future<void> _handleOnRefresh() async {
    fetchMoreBloc.dispatch(Refresh());
    await Future<dynamic>.delayed(Duration(seconds: 2));
  }
}

class DefaultBottomLoader extends StatelessWidget {
  const DefaultBottomLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 33,
            height: 33,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class DefaultErrorBuilder extends StatelessWidget {
  const DefaultErrorBuilder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Failed to fetch posts'),
    );
  }
}

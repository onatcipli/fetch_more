import 'package:fetch_more/fetch_more_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc.dart';

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
  final int limit;
  final double scrollThreshold;

  FetchMoreBuilder({
    @required this.dataFetcher,
    @required this.itemBuilder,
    @required this.limit,
    this.fetchMoreBloc,
    this.scrollThreshold = 200.0,
  });

  @override
  _FetchMoreBuilderState createState() => _FetchMoreBuilderState();
}

class _FetchMoreBuilderState extends State<FetchMoreBuilder> {
  FetchMoreBloc fetchMoreBloc;
  ScrollController _scrollController;

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
          return Center(
            child: Text('Failed to fetch posts'),
          );
        }
        if (state is Fetched) {
          if (state.list.isEmpty) {
            return Center(
              child: Text('No data available now!'),
            );
          }
          return RefreshIndicator(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.list.length
                    ? BottomLoader()
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
    if (widget.fetchMoreBloc == null) {
      fetchMoreBloc =
          FetchMoreBloc(dataFetcher: _dataFetcher, limit: widget.limit);
    } else {
      fetchMoreBloc = widget.fetchMoreBloc;
      fetchMoreBloc.dataFetcher = _dataFetcher;
      fetchMoreBloc.limit = widget.limit;
    }
    _scrollController = ScrollController();
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

class BottomLoader extends StatelessWidget {
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

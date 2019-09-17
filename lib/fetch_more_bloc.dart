import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import './bloc.dart';

class FetchMoreBloc extends Bloc<FetchMoreEvent, FetchMoreState> {
  DataFetcher dataFetcher;
  String _searchTerm = "";
  int limit;
  int index;

  FetchMoreBloc({this.dataFetcher, this.limit}) {
    index = 0;
    dispatch(Fetch());
  }

  @override
  FetchMoreState get initialState => InitialFetchMoreState();

  @override
  Stream<FetchMoreState> transformEvents(
    Stream<FetchMoreEvent> events,
    Stream<FetchMoreState> Function(FetchMoreEvent event) next,
  ) {
    return super.transformEvents(
      (events as Observable<FetchMoreEvent>).debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  Stream<FetchMoreState> mapEventToState(
    FetchMoreEvent event,
  ) async* {
    if (event is Fetch && !_hasReachedMax(currentState)) {
      try {
        if (currentState is InitialFetchMoreState) {
          List<dynamic> list;
          try {
            _searchTerm != ""
                ? list = await dataFetcher(0, limit, _searchTerm)
                : list = await dataFetcher(index, limit);
          } catch (e) {
            list = <dynamic>[];
            print(e);
          }
          yield Fetched(list: list, hasReachedMax: false);
          return;
        }
        if (currentState is Fetched) {
          List<dynamic> list;
          try {
            index = (currentState as Fetched).list.length;
            _searchTerm != ""
                ? list = await dataFetcher(index, limit, _searchTerm)
                : list = await dataFetcher(index, limit);
            print(list);
          } catch (e) {
            list = <dynamic>[];
            print(list);
            print(e);
          }
          yield list.isEmpty
              ? (currentState as Fetched).copyWith(hasReachedMax: true)
              : Fetched(
                  list: (currentState as Fetched).list + list,
                  hasReachedMax: false,
                );
        }
      } catch (_) {
        yield FetchError();
      }
    } else if (event is Refresh) {
      index = 0;
      yield InitialFetchMoreState();
      dispatch(Fetch());
      return;
    } else if (event is Search) {
      index = 0;
      _searchTerm = event.searchTerm;
      yield InitialFetchMoreState();
      dispatch(Fetch());
      return;
    }
  }

  bool _hasReachedMax(FetchMoreState state) =>
      state is Fetched && state.hasReachedMax;
}

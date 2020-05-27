import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fetch_more/fetch_more.dart';
import 'package:rxdart/rxdart.dart';

class FetchMoreBloc extends Bloc<FetchMoreEvent, FetchMoreState> {
  DataFetcher dataFetcher;
  int limit;
  int index;

  FetchMoreBloc({this.dataFetcher, this.limit}) {
    index = 0;
    add(Fetch());
  }

  @override
  FetchMoreState get initialState => InitialFetchMoreState();

  @override
  Stream<Transition<FetchMoreEvent, FetchMoreState>> transformEvents(
      Stream<FetchMoreEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(
          Duration(milliseconds: 500),
        ),
        transitionFn);
  }

  @override
  Stream<FetchMoreState> mapEventToState(
    FetchMoreEvent event,
  ) async* {
    if (event is Fetch && !_hasReachedMax(state)) {
      try {
        if (state is InitialFetchMoreState) {
          List<dynamic> list;
          try {
            list = await dataFetcher(index, limit);
          } catch (e) {
            list = <dynamic>[];
            print(e);
          }
          yield Fetched(list: list, hasReachedMax: false);
          return;
        }
        if (state is Fetched) {
          List<dynamic> list;
          try {
            index = (state as Fetched).list.length;
            list = await dataFetcher(index, limit);
          } catch (e) {
            list = <dynamic>[];
            print(e);
          }
          yield list.isEmpty
              ? (state as Fetched).copyWith(hasReachedMax: true)
              : Fetched(
                  list: (state as Fetched).list + list,
                  hasReachedMax: false,
                );
        }
      } catch (_) {
        yield FetchError();
      }
    } else if (event is Refresh) {
      index = 0;
      yield InitialFetchMoreState();
      add(Fetch());
      return;
    } else if (event is ListViewIsNotScrollable) {
      if (state is Fetched) {
        yield (state as Fetched).copyWith(hasReachedMax: true);
      }
    } else if (event is AddItems) {
      List<dynamic> list = [];
      if (event.items != null && event.items.isNotEmpty) {
        if (state is Fetched) {
          list.addAll((state as Fetched).list);
          index = list.length;
        }
        list.addAll(event.items);
        index = list.length;
        yield Fetched(
          list: list,
          hasReachedMax: false,
        );
      }
    }
  }

  bool _hasReachedMax(FetchMoreState state) =>
      state is Fetched && state.hasReachedMax;
}

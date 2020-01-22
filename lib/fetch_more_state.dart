import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class FetchMoreState extends Equatable {
  FetchMoreState([List props = const <dynamic>[]]) : super();
}

class InitialFetchMoreState extends FetchMoreState {
  @override
  // TODO: implement props
  List<Object> get props => null;
}

class FetchError extends FetchMoreState {
  @override
  // TODO: implement props
  List<Object> get props => null;
}

class Fetched extends FetchMoreState {
  final List<dynamic> list;
  final bool hasReachedMax;

  Fetched({@required this.list, @required this.hasReachedMax})
      : super(<dynamic>[list, hasReachedMax]);

  Fetched copyWith({List<dynamic> list, bool hasReachedMax}) {
    return Fetched(
        list: list ?? this.list,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  // TODO: implement props
  List<Object> get props => [list, hasReachedMax];
}

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class FetchMoreEvent extends Equatable {
  FetchMoreEvent([List props = const <dynamic>[]]) : super();
}

class Fetch extends FetchMoreEvent {
  @override
  // TODO: implement props
  List<Object> get props => null;
}

class Refresh extends FetchMoreEvent {
  @override
  // TODO: implement props
  List<Object> get props => null;
}

class ListViewIsNotScrollable extends FetchMoreEvent {
  @override
  // TODO: implement props
  List<Object> get props => null;
}

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class FetchMoreEvent extends Equatable {
  FetchMoreEvent([List props = const <dynamic>[]]) : super(props);
}

class Fetch extends FetchMoreEvent {}

class Refresh extends FetchMoreEvent {}

class ListViewIsNotScrollable extends FetchMoreEvent {}

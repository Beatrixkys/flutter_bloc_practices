part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  @override
  List<Object> get props => [];
}

//only has one event which is post fetched
class PostFetched extends PostEvent {}

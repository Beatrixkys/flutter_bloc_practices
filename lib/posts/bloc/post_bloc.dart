import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_infinitelist/posts/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';
part 'post_state.dart';

const _postLimit = 20;
const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(
      _onPostFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final http.Client httpClient;

//handle the event of Post Fetched
  Future<void> _onPostFetched(
      PostFetched event, Emitter<PostState> emit) async {
    //if the posts have reached maximum amount return it
    if (state.hasReachedMax) return;
    try {
      //if the state of the posts is the initial one, then await for fetching posts
      if (state.status == PostStatus.initial) {
        final posts = await _fetchPosts();
        //then return the list of posts while awaiting for it
        //then return the post status of success with the list of [psts]
        return emit(state.copyWith(
          status: PostStatus.success,
          posts: posts,
          hasReachedMax: false,
        ));
      }
      final posts = await _fetchPosts(state.posts.length);

      //if the lists of posts isEmpty, then
      emit(posts.isEmpty
          //set the state as the maximum posts is true
          ? state.copyWith(hasReachedMax: true)
          //set the state as sucessful, and add the posts on
          : state.copyWith(
              status: PostStatus.success,
              posts: List.of(state.posts)..addAll(posts),
              hasReachedMax: false,
            ));
    } catch (_) {
      //else if it is not successful, then show the post status as failure
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

//fetch the posts frpom the httpclient
//can put into a service file in the future if needed

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final response = await httpClient.get(
      Uri.https(
        'jsonplaceholder.typicode.com',
        '/posts',
        <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'},
      ),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body.map((dynamic json) {
        final map = json as Map<String, dynamic>;
        return Post(
          id: map['id'] as int,
          title: map['title'] as String,
          body: map['body'] as String,
        );
      }).toList();
    }
    throw Exception('error fetching posts');
  }
}

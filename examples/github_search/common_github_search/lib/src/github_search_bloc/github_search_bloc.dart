import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import 'package:common_github_search/common_github_search.dart';

class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  final GithubRepository githubRepository;

  GithubSearchBloc(this.githubRepository);

  @override
  Stream<GithubSearchEvent> transform(Stream<GithubSearchEvent> events) {
    return (events as Observable<GithubSearchEvent>)
        .debounce(Duration(milliseconds: 300));
  }

  @override
  void onTransition(
      Transition<GithubSearchEvent, GithubSearchState> transition) {
    print(transition.toString());
  }

  @override
  GithubSearchState get initialState => SearchStateEmpty();

  @override
  Stream<GithubSearchState> mapEventToState(
    GithubSearchState currentState,
    GithubSearchEvent event,
  ) async* {
    if (event is TextChanged) {
      final String searchTerm = event.text;
      yield searchTerm.isEmpty ? SearchStateEmpty() : SearchStateLoading();

      try {
        final results = await githubRepository.search(searchTerm);
        yield SearchStateSuccess(results.items);
      } catch (_) {
        yield SearchStateError();
      }
    }
  }
}

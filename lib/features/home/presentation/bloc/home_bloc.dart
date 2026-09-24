import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_home_content.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required GetHomeContent getHomeContent})
    : _getHomeContent = getHomeContent,
      super(const HomeInitial()) {
    on<LoadHomeContent>(_onLoadHomeContent);
  }

  final GetHomeContent _getHomeContent;

  Future<void> _onLoadHomeContent(
    LoadHomeContent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      final content = await _getHomeContent();

      if (content == null) {
        emit(const HomeEmpty());
        return;
      }

      emit(HomeLoaded(content));
    } catch (error) {
      emit(HomeError(error.toString()));
    }
  }
}

import 'package:equatable/equatable.dart';

import '../../domain/entities/home_content.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => const [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.content);

  final HomeContent content;

  @override
  List<Object?> get props => [content];
}

final class HomeEmpty extends HomeState {
  const HomeEmpty();
}

final class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

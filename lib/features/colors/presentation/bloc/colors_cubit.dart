import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_color_settings.dart';
import '../../domain/repositories/colors_repository.dart';

class ColorsCubit extends Cubit<ColorsState> {
  ColorsCubit({required ColorsRepository repository})
      : _repository = repository,
        super(const ColorsState.initial());

  final ColorsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: ColorsStatus.loading));
    try {
      final colors = await _repository.getColors();
      emit(ColorsState.loaded(colors));
    } catch (error) {
      emit(ColorsState.failure(
        colors: state.colors,
        message: error.toString(),
      ));
    }
  }

  Future<bool> save(AppColorSettings colors) async {
    emit(state.copyWith(status: ColorsStatus.saving, colors: colors));
    try {
      await _repository.saveColors(colors);
      emit(ColorsState.loaded(colors));
      return true;
    } catch (error) {
      emit(ColorsState.failure(colors: colors, message: error.toString()));
      return false;
    }
  }

  void resetLocal() {
    emit(ColorsState.loaded(AppColorSettings.defaults));
  }
}

enum ColorsStatus { initial, loading, loaded, saving, failure }

class ColorsState {
  const ColorsState({
    required this.status,
    required this.colors,
    this.message,
  });

  const ColorsState.initial()
      : status = ColorsStatus.initial,
        colors = AppColorSettings.defaults,
        message = null;

  const ColorsState.loaded(this.colors)
      : status = ColorsStatus.loaded,
        message = null;

  const ColorsState.failure({
    required this.colors,
    required this.message,
  }) : status = ColorsStatus.failure;

  final ColorsStatus status;
  final AppColorSettings colors;
  final String? message;

  ColorsState copyWith({
    ColorsStatus? status,
    AppColorSettings? colors,
    String? message,
  }) {
    return ColorsState(
      status: status ?? this.status,
      colors: colors ?? this.colors,
      message: message,
    );
  }
}

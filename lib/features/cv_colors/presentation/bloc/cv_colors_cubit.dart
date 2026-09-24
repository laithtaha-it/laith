import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cv_color_settings.dart';
import '../../domain/repositories/cv_colors_repository.dart';

class CvColorsCubit extends Cubit<CvColorsState> {
  CvColorsCubit({required CvColorsRepository repository})
      : _repository = repository,
        super(const CvColorsState.initial());

  final CvColorsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: CvColorsStatus.loading));
    try {
      emit(CvColorsState.loaded(await _repository.getColors()));
    } catch (error) {
      emit(CvColorsState.failure(colors: state.colors, message: error.toString()));
    }
  }

  Future<bool> save(CvColorSettings colors) async {
    emit(state.copyWith(status: CvColorsStatus.saving, colors: colors));
    try {
      await _repository.saveColors(colors);
      emit(CvColorsState.loaded(colors));
      return true;
    } catch (error) {
      emit(CvColorsState.failure(colors: colors, message: error.toString()));
      return false;
    }
  }
}

enum CvColorsStatus { initial, loading, loaded, saving, failure }

class CvColorsState {
  const CvColorsState({required this.status, required this.colors, this.message});

  const CvColorsState.initial()
      : status = CvColorsStatus.initial,
        colors = CvColorSettings.defaults,
        message = null;

  const CvColorsState.loaded(this.colors)
      : status = CvColorsStatus.loaded,
        message = null;

  const CvColorsState.failure({required this.colors, required this.message})
      : status = CvColorsStatus.failure;

  final CvColorsStatus status;
  final CvColorSettings colors;
  final String? message;

  CvColorsState copyWith({
    CvColorsStatus? status,
    CvColorSettings? colors,
    String? message,
  }) => CvColorsState(
        status: status ?? this.status,
        colors: colors ?? this.colors,
        message: message,
      );
}

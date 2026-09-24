import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/contact_repository.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc({required ContactRepository repository})
    : _repository = repository,
      super(const ContactInitial()) {
    on<LoadContactContent>(_onLoadContactContent);
  }

  final ContactRepository _repository;

  Future<void> _onLoadContactContent(
    LoadContactContent event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());

    try {
      final content = await _repository.getContactContent();

      if (content == null) {
        emit(const ContactEmpty());
        return;
      }

      emit(ContactLoaded(content));
    } catch (error) {
      emit(ContactError(error.toString()));
    }
  }
}

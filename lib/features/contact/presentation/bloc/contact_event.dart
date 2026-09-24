import 'package:equatable/equatable.dart';

sealed class ContactEvent extends Equatable {
  const ContactEvent();

  @override
  List<Object?> get props => [];
}

class LoadContactContent extends ContactEvent {
  const LoadContactContent();
}

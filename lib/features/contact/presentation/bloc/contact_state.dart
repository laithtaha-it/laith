import 'package:equatable/equatable.dart';

import '../../domain/entities/contact_content.dart';

sealed class ContactState extends Equatable {
  const ContactState();

  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {
  const ContactInitial();
}

class ContactLoading extends ContactState {
  const ContactLoading();
}

class ContactLoaded extends ContactState {
  const ContactLoaded(this.content);

  final ContactContent content;

  @override
  List<Object?> get props => [content];
}

class ContactEmpty extends ContactState {
  const ContactEmpty();
}

class ContactError extends ContactState {
  const ContactError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

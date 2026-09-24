import '../entities/contact_content.dart';

abstract interface class ContactRepository {
  Future<ContactContent?> getContactContent();
}

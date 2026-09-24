import '../../domain/entities/contact_content.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_remote_data_source.dart';
import '../models/contact_content_model.dart';

class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl({required ContactRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ContactRemoteDataSource _remoteDataSource;

  @override
  Future<ContactContent?> getContactContent() async {
    final data = await _remoteDataSource.getContactContent();

    if (data == null) {
      return null;
    }

    return ContactContentModel.fromMap(data);
  }
}

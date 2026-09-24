import '../entities/home_content.dart';

abstract interface class HomeRepository {
  Future<HomeContent?> getHomeContent();
}

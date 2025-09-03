import '../../domain/repositories/offers_repository.dart';
import '../datasources/offers_remote_datasource.dart';
import '../models/paginated_offers_response.dart';

class OffersRepositoryImpl implements OffersRepository {
  final OffersRemoteDataSource _remoteDataSource;

  OffersRepositoryImpl({OffersRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? OffersRemoteDataSource();

  @override
  Future<PaginatedOffersResponse> getActiveOffers({
    int page = 1,
    int limit = 10,
    String? search,
    String? sort,
    String? order,
  }) async {
    try {
      return await _remoteDataSource.getActiveOffers(
        page: page,
        limit: limit,
        search: search,
        sort: sort,
        order: order,
      );
    } catch (e) {
      print('❌ Repository error fetching active offers: $e');
      rethrow;
    }
  }
}

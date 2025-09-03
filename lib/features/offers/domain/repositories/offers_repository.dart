import '../../data/models/paginated_offers_response.dart';

abstract class OffersRepository {
  Future<PaginatedOffersResponse> getActiveOffers({
    int page = 1,
    int limit = 10,
    String? search,
    String? sort,
    String? order,
  });
}

import '../../data/models/paginated_offers_response.dart';
import '../repositories/offers_repository.dart';

class GetActiveOffersUseCase {
  final OffersRepository _repository;

  GetActiveOffersUseCase(this._repository);

  Future<PaginatedOffersResponse> call({
    int page = 1,
    int limit = 10,
    String? search,
    String? sort,
    String? order,
  }) async {
    return await _repository.getActiveOffers(
      page: page,
      limit: limit,
      search: search,
      sort: sort,
      order: order,
    );
  }
}

import '../../../../core/network/api_client.dart';
import '../models/paginated_offers_response.dart';

class OffersRemoteDataSource {
  final ApiClient _apiClient;

  OffersRemoteDataSource({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient();

  Future<PaginatedOffersResponse> getActiveOffers({
    int page = 1,
    int limit = 10,
    String? search,
    String? sort,
    String? order,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (sort != null && sort.isNotEmpty) {
        queryParameters['sort'] = sort;
      }

      if (order != null && order.isNotEmpty) {
        queryParameters['order'] = order;
      }

      final response = await _apiClient.get(
        '/api/offers/public/active',
        queryParameters: queryParameters,
      );

      return PaginatedOffersResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Error fetching active offers: $e');
      rethrow;
    }
  }
}

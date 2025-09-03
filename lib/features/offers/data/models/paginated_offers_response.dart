import 'offer_model.dart';

class PaginatedOffersResponse {
  final bool success;
  final String message;
  final List<OfferModel> data;
  final PaginationModel pagination;

  PaginatedOffersResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory PaginatedOffersResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedOffersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => OfferModel.fromJson(item))
          .toList() ?? [],
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class PaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNext;
  final bool hasPrev;

  PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 0,
      totalItems: json['total_items'] ?? 0,
      itemsPerPage: json['items_per_page'] ?? 10,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
      'has_next': hasNext,
      'has_prev': hasPrev,
    };
  }
}

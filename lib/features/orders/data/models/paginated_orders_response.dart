import 'order_model.dart';

class PaginatedOrdersResponse {
  final List<OrderModel> orders;
  final PaginationInfo pagination;

  const PaginatedOrdersResponse({
    required this.orders,
    required this.pagination,
  });

  factory PaginatedOrdersResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ordersData = json['data'] ?? [];
    final List<OrderModel> orders = ordersData
        .map((orderJson) => OrderModel.fromJson(orderJson))
        .toList();

    final pagination = PaginationInfo.fromJson(json['pagination'] ?? {});

    return PaginatedOrdersResponse(
      orders: orders,
      pagination: pagination,
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNext;
  final bool hasPrev;

  const PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      totalItems: json['total_items'] as int? ?? 0,
      itemsPerPage: json['items_per_page'] as int? ?? 10,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrev: json['has_prev'] as bool? ?? false,
    );
  }
}

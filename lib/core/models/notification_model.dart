import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final Map<String, dynamic> data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Handle data field which can be either a Map or a JSON string
    Map<String, dynamic> data = {};
    final dataField = json['data'];
    
    if (dataField is Map<String, dynamic>) {
      data = dataField;
    } else if (dataField is String) {
      try {
        data = jsonDecode(dataField) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ Failed to parse data field as JSON: $e');
        data = {};
      }
    } else if (dataField != null) {
      print('⚠️ Unexpected data field type: ${dataField.runtimeType}');
      data = {};
    }
    
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      data: data,
    );
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  // Helper methods
  DateTime get createdAtDateTime => DateTime.parse(createdAt);
  
  bool get isOrderStatusChange => type == 'order_status_change';
  bool get isAdminMessage => type == 'admin_message';
  bool get isPriceUpdate => type == 'price_update';
  bool get isSystemUpdate => type == 'system_update';
  
  String? get orderId => data['order_id'];
  String? get status => data['status'];
  double? get newPrice => data['new_price']?.toDouble();
}

@JsonSerializable()
class NotificationListResponse {
  final List<NotificationModel> notifications;
  final PaginationInfo pagination;

  const NotificationListResponse({
    required this.notifications,
    required this.pagination,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => _$NotificationListResponseToJson(this);
}

@JsonSerializable()
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  @JsonKey(name: 'has_prev')
  final bool hasPrev;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrev: json['has_prev'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$PaginationInfoToJson(this);
}

@JsonSerializable()
class UnreadCountResponse {
  final int count;

  const UnreadCountResponse({
    required this.count,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$UnreadCountResponseToJson(this);
}

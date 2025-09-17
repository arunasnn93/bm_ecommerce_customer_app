import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase implements UseCase<List<Notification>, GetNotificationsParams> {
  final NotificationRepository _repository;
  
  GetNotificationsUseCase({required NotificationRepository repository})
      : _repository = repository;
  
  @override
  Future<List<Notification>> call(GetNotificationsParams params) async {
    return await _repository.getNotifications(
      page: params.page,
      limit: params.limit,
      unreadOnly: params.unreadOnly,
    );
  }
}

class GetNotificationsParams {
  final int page;
  final int limit;
  final bool unreadOnly;
  
  const GetNotificationsParams({
    this.page = 1,
    this.limit = 20,
    this.unreadOnly = false,
  });
}

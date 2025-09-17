import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase implements UseCase<void, String> {
  final NotificationRepository _repository;
  
  MarkNotificationReadUseCase({required NotificationRepository repository})
      : _repository = repository;
  
  @override
  Future<void> call(String notificationId) async {
    return await _repository.markNotificationAsRead(notificationId);
  }
}

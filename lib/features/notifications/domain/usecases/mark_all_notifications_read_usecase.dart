import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase implements UseCase<void, NoParams> {
  final NotificationRepository _repository;
  
  MarkAllNotificationsReadUseCase({required NotificationRepository repository})
      : _repository = repository;
  
  @override
  Future<void> call(NoParams params) async {
    return await _repository.markAllNotificationsAsRead();
  }
}

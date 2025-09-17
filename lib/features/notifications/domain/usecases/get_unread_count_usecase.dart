import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class GetUnreadCountUseCase implements UseCase<int, NoParams> {
  final NotificationRepository _repository;
  
  GetUnreadCountUseCase({required NotificationRepository repository})
      : _repository = repository;
  
  @override
  Future<int> call(NoParams params) async {
    return await _repository.getUnreadCount();
  }
}

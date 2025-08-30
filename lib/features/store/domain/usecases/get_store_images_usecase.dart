import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/store_repository.dart';
import '../entities/store_image.dart';

class GetStoreImagesUseCase {
  final StoreRepository repository;

  GetStoreImagesUseCase(this.repository);

  Future<Either<Failure, List<StoreImage>>> call() async {
    return await repository.getStoreImages();
  }
}

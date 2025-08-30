import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/store_image.dart';

abstract class StoreRepository {
  Future<Either<Failure, List<StoreImage>>> getStoreImages();
}

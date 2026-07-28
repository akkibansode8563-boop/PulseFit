import '../../../../core/error/result.dart';
import '../entities/user_profile.dart';

abstract class IProfileRepository {
  Future<Result<UserProfile>> getUserProfile();
  Future<Result<UserProfile>> updateUserProfile(UserProfile profile);
}

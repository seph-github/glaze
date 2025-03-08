import 'package:firebase_auth/firebase_auth.dart';
import 'package:glaze/data/remote/firebase_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(ref) {
  final database = ref.watch(firebaseDatabaseProvider);
  return AuthRepository(database: database);
}

class AuthRepository {
  AuthRepository({
    required this.database,
  });

  final FirebaseDatabase database;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login({required String email, required String password}) async {
    print('AuthRepository: login called');
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> register(
      {required String email, required String password}) async {
    print('AuthRepository: register called');
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    print('AuthRepository: logout called');
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  User? getCurrentUser() {
    print('AuthRepository: getCurrentUser called');
    try {
      return _auth.currentUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword({required String email}) async {
    print('AuthRepository: resetPassword called');
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}

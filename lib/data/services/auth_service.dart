import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'shared_prefs_service.dart';
import 'package:group_project/core/constants/app_constants.dart';

/// Authentication service that handles all Firebase Auth operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPrefsService _prefs = SharedPrefsService();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<Map<String, dynamic>> signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
      // First sign out any existing user to prevent PigeonUserDetails error
      if (_auth.currentUser != null) {
        await _auth.signOut();
        // Brief delay to ensure Firebase state is cleared
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Create the user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore
      final UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Add user to Firestore
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(newUser.uid)
          .set(newUser.toMap());

      // Sign out again to prevent PigeonUserDetails error when logging in later
      // This is the key to avoiding the error we encountered before
      await _auth.signOut();
      await Future.delayed(const Duration(milliseconds: 500));

      return {
        'success': true,
        'message': 'Account created successfully!',
        'user': newUser,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during sign up';

      // Provide user-friendly error messages
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Account creation is not enabled';
          break;
        case 'pigeon-user-details':
          errorMessage = 'PigeonUserDetails error occurred';
          break;
        default:
          errorMessage = e.message ?? 'Unknown error occurred';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
        'error': 'unknown_error',
      };
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn(
      {required String email, required String password}) async {
    try {
      // First sign out to ensure clean state
      if (_auth.currentUser != null) {
        await _auth.signOut();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      try {
        // Sign in the user
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Get user data from Firestore
        final docSnapshot = await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        UserModel userModel;

        // If user document exists, use it, otherwise create from auth
        if (docSnapshot.exists) {
          userModel = UserModel.fromMap({
            ...docSnapshot.data()!,
            'uid': userCredential.user!.uid,
          });
        } else {
          userModel = UserModel(
            uid: userCredential.user!.uid,
            name: userCredential.user!.displayName ?? 'User',
            email: email,
          );
        }

        // Save login state to shared preferences
        await _prefs.saveUserLoginState(
          uid: userModel.uid,
          name: userModel.name,
          email: userModel.email,
        );

        return {
          'success': true,
          'message': 'Signed in successfully',
          'user': userModel,
        };
      } catch (e) {
        // If we get the PigeonUserDetails error, try one more time after a delay
        if (e.toString().contains('PigeonUserDetails')) {
          await Future.delayed(const Duration(milliseconds: 1000));

          // Try again
          final userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Get user data from Firestore
          final docSnapshot = await _firestore
              .collection(FirebaseConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .get();

          UserModel userModel;

          // If user document exists, use it, otherwise create from auth
          if (docSnapshot.exists) {
            userModel = UserModel.fromMap({
              ...docSnapshot.data()!,
              'uid': userCredential.user!.uid,
            });
          } else {
            userModel = UserModel(
              uid: userCredential.user!.uid,
              name: userCredential.user!.displayName ?? 'User',
              email: email,
            );
          }

          // Save login state to shared preferences
          await _prefs.saveUserLoginState(
            uid: userModel.uid,
            name: userModel.name,
            email: userModel.email,
          );

          return {
            'success': true,
            'message': 'Signed in successfully',
            'user': userModel,
          };
        } else {
          // Re-throw the error if it's not the PigeonUserDetails error
          rethrow;
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during sign in';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid';
          break;
        case 'pigeon-user-details':
          errorMessage = 'PigeonUserDetails error occurred';
          break;
        default:
          errorMessage = e.message ?? 'Unknown error occurred';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
        'error': 'unknown_error',
      };
    }
  }

  /// Sign out user
  Future<Map<String, dynamic>> signOut() async {
    try {
      await _auth.signOut();
      await _prefs.clearUserData();

      return {
        'success': true,
        'message': 'Signed out successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error signing out: $e',
        'error': 'sign_out_error',
      };
    }
  }

  /// Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();

      if (docSnapshot.exists) {
        return UserModel.fromMap({
          ...docSnapshot.data()!,
          'uid': uid,
        });
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}

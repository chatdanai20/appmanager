// import 'package:manager_res/export.dart';

// class AuthwithEmail {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   Future<UserCredential> signUpWithEmail(Profile profile) async {
//     try {
//       return await _auth.createUserWithEmailAndPassword(
//           email: profile.email, password: profile.password);
//     } catch (error) {
//       print('เกิดข้อผิดพลาดในการสมัครสมาชิก: $error');
//       rethrow;
//     }
//   }

//   Future<UserCredential> signInWithEmail(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return userCredential;
//     } catch (error) {
//       print('Error signing in with email and password: $error');
//       throw 'เกิดข้อผิดพลาดในการลงชื่อเข้าใช้ด้วยอีเมลและรหัสผ่าน';
//     }
//   }

//   Future<void> signOut() async {
//     try {
//       await _auth.signOut();
//     } catch (error) {
//       print('เกิดข้อผิดพลาดในการออกจากระบบ: $error');
//       rethrow;
//     }
//   }
// }

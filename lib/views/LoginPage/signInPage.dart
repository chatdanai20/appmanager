// ignore_for_file: use_build_context_synchronously

import 'package:form_field_validator/form_field_validator.dart';
import 'package:manager_res/export.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final formKey = GlobalKey<FormState>();
  profilelogin profile = profilelogin(email: '', password: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error);
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildLoginForm();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Error"),
      ),
      body: Center(
        child: Text(
          "$error",
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE7E2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                _buildLogo(),
                const SizedBox(height: 30),
                _buildTitlesignIn(),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 30),
                _buildPasswordField(),
                const SizedBox(height: 50),
                _buildLoginButton(),
                const SizedBox(height: 20),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const Center(
      child: Image(
        image: AssetImage(
          'assets/images/manager.png',
        ),
        height: 200,
        width: 200,
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: "อีเมล",
        ),
        validator: MultiValidator(
          [
            RequiredValidator(
              errorText: "กรุณาใส่อีเมล",
            ),
            EmailValidator(
              errorText: "กรุณาใส่อีเมลให้ถูกต้อง",
            ),
          ],
        ),
        keyboardType: TextInputType.emailAddress,
        onSaved: (email) {
          profile.email = email!;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: "รหัสผ่าน",
        ),
        validator: RequiredValidator(
          errorText: "กรุณาใส่รหัสผ่าน",
        ),
        obscureText: true,
        onSaved: (password) {
          profile.password = password!;
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.redAccent,
          ),
          child: const Text(
            "เข้าสู่ระบบ",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            showDialog(
              context: context,
              builder: (context) {
                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              try {
                await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                  email: profile.email,
                  password: profile.password,
                )
                    .then((value) {
                  formKey.currentState!.reset();
                  ToastSuccessful();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const BottomNav();
                      },
                    ),
                  );
                });
              } on FirebaseAuthException catch (e) {
                String message;
                double height = e.code == 'weak-password' ? 75 : 100;
                if (e.code == 'weak-password') {
                  message = "รหัสผ่านหรืออีเมลไม่ถูกต้อง";
                } else if (e.code == 'email-already-in-use') {
                  message = "อีเมลนี้ถูกใช้งานแล้ว โปรดใช้อีเมลอื่น";
                } else {
                  message = "เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง";
                }
                notitoast(message, height);
                print(e.code);
                print(e.message);
              } finally {
                setState(() {
                  isLoading = false;
                  const Duration(seconds: 2);
                });
              }
            }
          },
        ),
      ),
    );
  }

  void ToastSuccessful() {
    // CherryToast(
    //   icon: Icons.check_circle_outline,
    //   title: const Text(
    //     'เข้าสู่ระบบสำเร็จ',
    //     style: TextStyle(
    //       color: Colors.black,
    //       fontSize: 25,
    //     ),
    //   ),
    //   displayCloseButton: false,
    //   toastDuration: const Duration(seconds: 2),
    //   animationDuration: const Duration(milliseconds: 1000),
    //   animationType: AnimationType.fromTop,
    //   themeColor: Colors.pink,
    //   autoDismiss: true,
    //   width: 400,
    //   height: 75,
    //   iconSize: 40,
    //   iconColor: Colors.green,
    // ).show(context);
  }

  void notitoast(String message, double height) {
    // CherryToast(
    //   icon: Icons.cancel_outlined,
    //   title: Text(
    //     message,
    //     style: const TextStyle(
    //       color: Colors.black,
    //       fontSize: 22,
    //     ),
    //   ),
    //   displayCloseButton: false,
    //   toastDuration: const Duration(seconds: 3),
    //   animationDuration: const Duration(milliseconds: 1000),
    //   animationType: AnimationType.fromTop,
    //   themeColor: Colors.pink,
    //   autoDismiss: true,
    //   width: 400,
    //   height: height,
    //   iconSize: 40,
    //   iconColor: Colors.red,
    // ).show(context);
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Text(
            'ยังไม่มีบัญชีผู้ใช้งาน? ',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
        ),
        GestureDetector(
          child: const Text(
            'สมัครสมาชิก',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, AppRoute.register);
          },
        ),
      ],
    );
  }
}

Widget _buildTitlesignIn() {
  return const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "เข้าสู่ระบบ",
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

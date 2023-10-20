import 'package:manager_res/export.dart';

class AppRoute {
  static const String signIn = 'sign-in';
  static const String register = 'register';
  static const String home = 'home';
  static const String setting = 'setting';
  static const String account = 'account';
  static const String user = 'user';
  static const String listmenu = 'listmenu';
  static const String promotion = 'promotion';

  static get routes => {
        signIn: (context) => const SignInPage(),
        register: (context) => const RegisterPage(),
        home: (context) => const HomePage(),
        setting: (context) => const SettingPage(),
        user: (context) => UserPage(),
        account: (context) => const AccountPage(),
        listmenu: (context) => const ListmenuPage(),
        promotion: (context) => const PromotionPage(),
      };
}

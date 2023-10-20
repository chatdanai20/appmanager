import 'package:manager_res/export.dart';
import 'package:manager_res/views/Notificationspage/notifications.dart';
import 'package:manager_res/views/Pickithpme/PickHome.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomePage(),
    const NotificationPage(),
    const PcikitPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 14,
        currentIndex: _selectedIndex,
        backgroundColor: Colors.redAccent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 35, color: Colors.black),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 35, color: Colors.black),
            label: 'แจ้งเตือนจอง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 35, color: Colors.black),
            label: 'แจ้งเตือนรับกลับ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, size: 35, color: Colors.black),
            label: 'บัญชีผู้ใช้',
          ),
        ],
      ),
    );
  }
}

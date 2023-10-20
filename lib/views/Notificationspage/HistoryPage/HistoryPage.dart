import 'package:manager_res/export.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการแจ้งเตือน'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          child: const Center(
            child: Text('ยังไม่มีประวัติการแจ้งเตือน'),
          ),
        ),
      ),
    );
  }
}

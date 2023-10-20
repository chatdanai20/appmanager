import 'package:manager_res/export.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({Key? key}) : super(key: key);

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  final firestoreInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("โต๊ะที่จอง"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: firestoreInstance.collection('order').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var orderData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                int numberOfPeople = int.parse(orderData['number_of_people']);
                String user = orderData['user'];
                String date = orderData['date'] ?? '';
                String time = orderData['time'] ?? '';
                String table = orderData['number_table'] ?? '';

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailPage(orderData: orderData),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ผู้ใช้งาน: $user',
                              style: const TextStyle(fontSize: 18)),
                          Text('จำนวนคน : $numberOfPeople',
                              style: const TextStyle(fontSize: 18)),
                          Text('โต๊ะที่จอง: $table',
                              style: const TextStyle(fontSize: 18)),
                          Text('วันที่จอง: $date',
                              style: const TextStyle(fontSize: 18)),
                          Text('เวลาที่จอง: $time',
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('ไม่มีการจองโต๊ะ'),
            );
          }
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final firestoreInstance = FirebaseFirestore.instance;

  DetailPage({Key? key, required this.orderData}) : super(key: key);

  void endOrder(BuildContext context) async {
    String orderId = orderData['id'] ?? '';
    String userEmail = orderData['email'] ?? '';

    try {
      await firestoreInstance.runTransaction((transaction) async {
        await firestoreInstance.collection('order').doc(orderId).delete();

        QuerySnapshot restaurantQuery = await firestoreInstance
            .collection("restaurant")
            .where("email", isEqualTo: userEmail)
            .get();

        if (restaurantQuery.docs.isNotEmpty) {}
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("การจองได้สิ้นสุดแล้ว"),
        duration: Duration(seconds: 2),
      ));
    } catch (error) {
      print('Failed to end order: $error');

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("เกิดข้อผิดพลาดในการสิ้นสุดการจอง"),
        duration: Duration(seconds: 2),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    int numberOfPeople = int.parse(orderData['number_of_people']);
    double totalPrice = orderData['total_price'].toDouble();
    double finalPrice = orderData['final_price'].toDouble();
    double discount = orderData['discount'].toDouble();
    List<dynamic> items = orderData['items'];
    String user = orderData['user'];
    String status = orderData['status'];
    String date = orderData['date'] ?? '';
    String time = orderData['time'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียด"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User: $user',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('จำนวนคน: $numberOfPeople' ' คน',
                        style: const TextStyle(fontSize: 18)),
                    Text('ราคาทั้งหมด: $totalPrice' ' บาท',
                        style: const TextStyle(fontSize: 18)),
                    Text('ส่วนลด: $discount' ' บาท',
                        style: const TextStyle(fontSize: 18)),
                    Text('ราคาสุทธิ: $finalPrice' ' บาท',
                        style: const TextStyle(fontSize: 18)),
                    Text('Status: $status',
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('รายการอาหารที่สั่ง',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...items.map((item) {
              var itemMap = Map<String, dynamic>.from(item);
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                      '${itemMap['name']} จำนวน : ${itemMap['quantity']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(
                      'Price: ${itemMap['price']} Option: ${itemMap['option']}',
                      style: const TextStyle(fontSize: 16)),
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    updateStatus(context, 'กำลังทำอาหาร');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: const Text('กำลังทำ', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateStatus(context, 'ทำอาหารเสร็จแล้ว');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child:
                      const Text('ทำเสร็จแล้ว', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () {
                    endOrder(context);
                    // print(orderData);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: const Text('สิ้นสุดการจอง',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateStatus(BuildContext context, String newStatus) async {
    String orderId = orderData['id'] ?? '';

    try {
      await firestoreInstance
          .collection('order')
          .doc(orderId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("สถานะได้ถูกอัพเดทเป็น: $newStatus"),
        duration: const Duration(seconds: 2),
      ));
    } catch (error) {
      print('Failed to update status: $error');

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("เกิดข้อผิดพลาดในการอัพเดทสถานะ"),
        duration: Duration(seconds: 2),
      ));
    }
  }
}

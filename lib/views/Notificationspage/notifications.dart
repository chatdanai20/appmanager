import 'package:manager_res/export.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การแจ้งเตือน'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Waiting').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

              String user = FirebaseAuth.instance.currentUser!.email!;

              List<Map<String, dynamic>> userNotifications = docs
                  .map((doc) {
                    return {
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>
                    };
                  })
                  .where(
                      (notification) => (notification['email'] ?? "") == user)
                  .toList();

              if (userNotifications.isNotEmpty) {
                return ListView.builder(
                  itemCount: userNotifications.length,
                  itemBuilder: (context, index) {
                    String userName = userNotifications[index]['user'] ?? "";
                    String numberOfPeople = userNotifications[index]
                                ['number_of_people']
                            .toString() ??
                        "ไม่มีจำนวนคน";
                    List<dynamic> items =
                        userNotifications[index]['items'] ?? [];
                    String status =
                        userNotifications[index]['status'] ?? "ไม่มีสถานะ";
                    String date = userNotifications[index]['date'] ?? "";
                    String time = userNotifications[index]['time'] ?? "";
                    String table =
                        userNotifications[index]['number_table'] ?? "";

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: ListTile(
                        leading: const Icon(
                          Icons.notifications,
                          color: Colors.redAccent,
                        ),
                        title: Text(userName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'วันที่จองโต๊ะ: $date',
                            ),
                            Text('ช่วงเวลาที่จอง : $time'),
                            Text('จำนวนคน: $numberOfPeople'),
                            Text('โต๊ะที่จอง: $table'),
                            Text('จำนวนรายการอาหาร: ${items.length}'),
                            Text('สถานะ: $status'),
                          ],
                        ),
                        onTap: () {},
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                _confirmNotification(userNotifications[index]);
                              },
                              icon: const Icon(Icons.check),
                              color: Colors.green,
                            ),
                            IconButton(
                              onPressed: () {
                                _cancelNotification(userNotifications[index]);
                              },
                              icon: const Icon(Icons.clear),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('ไม่มีรายการ'),
                );
              }
            } else if (snapshot.hasError) {
              return Center(
                child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _cancelNotification(Map<String, dynamic> notification) async {
    String? id = notification['id'];
    if (id == null || id.isEmpty) {
      print("Error: Notification id is invalid");
      return;
    }

    await FirebaseFirestore.instance.collection('Waiting').doc(id).delete();

    print(notification);
  }

  Future<void> _confirmNotification(Map<String, dynamic> notification) async {
    String? id = notification['id'];
    if (id == null || id.isEmpty) {
      print("Error: Notification id is invalid");
      return;
    }

    notification['status'] = 'ยืนยันแล้ว';

    final docRef = FirebaseFirestore.instance.collection('order').doc();

    await docRef.set(notification).then((_) async {
      await FirebaseFirestore.instance.collection('Waiting').doc(id).delete();

      String userEmail = FirebaseAuth.instance.currentUser!.email!;

      var restaurantQuery = FirebaseFirestore.instance
          .collection('restaurant')
          .where('email', isEqualTo: userEmail);

      restaurantQuery.get().then((querySnapshot) {});
      await docRef.update({'id': docRef.id});
    }).catchError((error) {
      print("Error getting document: $error");
    });

    print(notification);
  }
}

import 'package:manager_res/export.dart';

class PcikitPage extends StatefulWidget {
  const PcikitPage({Key? key}) : super(key: key);

  @override
  State<PcikitPage> createState() => _PcikitPageState();
}

class _PcikitPageState extends State<PcikitPage> {
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
          stream:
              FirebaseFirestore.instance.collection('PickWaiting').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

              String user = FirebaseAuth.instance.currentUser!.email!;

              List<Map<String, dynamic>> userpcikits = docs
                  .map((doc) {
                    return {
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>
                    };
                  })
                  .where((pcikit) => (pcikit['email'] ?? "") == user)
                  .toList();

              if (userpcikits.isNotEmpty) {
                return ListView.builder(
                  itemCount: userpcikits.length,
                  itemBuilder: (context, index) {
                    String userName = userpcikits[index]['user'] ?? "";
                    List<dynamic> items = userpcikits[index]['items'] ?? [];
                    String status =
                        userpcikits[index]['status'] ?? "ไม่มีสถานะ";

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
                                _confirmpcikit(userpcikits[index]);
                              },
                              icon: const Icon(Icons.check),
                              color: Colors.green,
                            ),
                            IconButton(
                              onPressed: () {
                                _cancelpcikit(userpcikits[index]);
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

  Future<void> _cancelpcikit(Map<String, dynamic> pcikit) async {
    String? id = pcikit['id'];
    if (id == null || id.isEmpty) {
      print("Error: pcikit id is invalid");
      return;
    }

    await FirebaseFirestore.instance.collection('PickWaiting').doc(id).delete();

    print(pcikit);
  }

  Future<void> _confirmpcikit(Map<String, dynamic> pcikit) async {
    String? id = pcikit['id'];
    if (id == null || id.isEmpty) {
      print("Error: pcikit id is invalid");
      return;
    }

    pcikit['status'] = 'ยืนยันแล้ว';

    final docRef = FirebaseFirestore.instance.collection('PickHome').doc();

    await docRef.set(pcikit).then((_) async {
      await FirebaseFirestore.instance
          .collection('PickWaiting')
          .doc(id)
          .delete();

      await docRef.update({'id': docRef.id});
    }).catchError((error) {
      print("Error getting document: $error");
    });

    print(pcikit);
  }
}

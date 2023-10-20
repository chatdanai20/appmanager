import 'package:manager_res/export.dart';
import 'package:manager_res/views/Addmenu/addmenu.dart';

class ListmenuPage extends StatelessWidget {
  const ListmenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!.email;
    if (user == null) {
      return const Center(
        child: Text('กรุณาเข้าสู่ระบบก่อน'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการอาหารของร้าน'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMenuPage(
                    isEditing: false,
                    appBarTitle: 'เพิ่มรายการอาหาร',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Menu')
            .where('email', isEqualTo: user)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('ไม่มีรายการอาหาร'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];

              final data = doc.data() as Map<String, dynamic>;
              final imageUrl = data['image'] as String;

              return _buildMenu(
                data['name'] ?? '',
                data['price'],
                imageUrl,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMenuPage(
                        selectedItemId: doc.id,
                        initialName: data['name'] ?? '',
                        initialPrice: data['price']?.toString() ?? '',
                        initialImage: data['image'] ?? '',
                        selectedOption: data['options']?.toString() ?? '',
                        selectedNameEx: data['nameExs']?.toString() ?? '',
                        selectedPriceEx: data['priceExs']?.toString() ?? '',
                        isEditing: true,
                        appBarTitle: ' แก้ไขรายการอาหาร',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMenu(
      String name, dynamic price, String imageUrl, Function() onTap) {
    int convertedPrice = int.tryParse(price.toString()) ?? 0;

    // print('ชื่อ : $name ราคา: $convertedPrice รูป: $imageUrl');

    return ListTile(
      leading: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            )
          : Image.asset(
              'assets/images/image.jpg',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
      title: Text(name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      subtitle: Text(
        'ราคา $convertedPrice บาท',
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}

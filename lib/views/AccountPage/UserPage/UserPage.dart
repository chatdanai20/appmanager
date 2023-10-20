import 'package:manager_res/export.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UserPage extends StatefulWidget {
  final String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<QuerySnapshot<Map<String, dynamic>>> userData;

  @override
  void initState() {
    super.initState();
    userData = fetchUserData();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('RestaurantApp')
          .where('email', isEqualTo: user.email)
          .get();
    }

    throw Exception('User not found');
  }

  Future<String> fetchImage() async {
    final String imageName = "${DateTime.now()}.jpg";
    final ref =
        firebase_storage.FirebaseStorage.instance.ref('imageres/$imageName');
    return ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildImageRestaurant(),
              const SizedBox(height: 20),
              _buildRestaurant(),
              const SizedBox(height: 20),
              _buildEmail(),
              const SizedBox(height: 20),
              _buildPhone(),
              const SizedBox(height: 20),
              _buildMapRestaurant(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('ข้อมูลร้าน'),
      backgroundColor: Colors.redAccent,
      centerTitle: true,
      actions: [
        FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData &&
                snapshot.data!.docs.isNotEmpty) {
              // final docData = snapshot.data!.docs[0].data();
              return IconButton(
                onPressed: () {
                  final doc = snapshot.data!.docs[0];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserpage(
                        id: doc.id,
                        name: doc.data()['name'],
                        phone: doc.data()['phone'],
                        email: doc.data()['email'],
                        image: doc.data()['image'],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildImageRestaurant() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: userData,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
        } else {
          if ((snapshot.data?.docs ?? []).isEmpty) {
            return const Text('ไม่พบข้อมูลร้าน');
          }
          final imageUrl = snapshot.data!.docs[0].data()['image'];
          if (imageUrl != null) {
            return CircleAvatar(
              radius: 90,
              backgroundImage: NetworkImage(imageUrl),
            );
          } else {
            return const Text('ไม่พบ URL ของรูปภาพ');
          }
        }
      },
    );
  }

  Widget _buildRestaurant() => _fetchDataWidget(
        future: userData,
        builder: (data) => Text(
          'ชื่อร้าน: ${data['name']}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        errorText: 'ไม่พบข้อมูลร้าน',
      );

  Widget _buildPhone() => _fetchDataWidget(
        future: userData,
        builder: (data) => Text(
          'เบอร์โทร: ${data['phone']}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        errorText: 'ไม่พบข้อมูลเบอร์โทรศัพท์',
      );

  Widget _buildEmail() {
    final email = FirebaseAuth.instance.currentUser!.email.toString();

    return Text(
      'อีเมล : $email',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMapRestaurant() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        height: 250,
        color: Colors.redAccent,
        child: const MapSample(),
      ),
    );
  }

  Widget _fetchDataWidget({
    required Future<QuerySnapshot<Map<String, dynamic>>> future,
    required Widget Function(Map<String, dynamic>) builder,
    required String errorText,
  }) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
        } else {
          final docs = snapshot.data?.docs;
          if (docs != null && docs.isNotEmpty) {
            final data = docs[0].data();
            print(data);
            return builder(data);
          } else {
            return Text(errorText);
          }
        }
      },
    );
  }
}

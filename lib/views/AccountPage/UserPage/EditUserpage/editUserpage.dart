// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously, avoid_print
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

import 'package:manager_res/export.dart';

class EditUserpage extends StatefulWidget {
  final String id;
  final String email;
  final String phone;
  final String name;
  final String image;

  const EditUserpage({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    required this.image,
    Key? key,
  }) : super(key: key);

  @override
  _EditUserpageState createState() => _EditUserpageState();
}

class _EditUserpageState extends State<EditUserpage> {
  String? id;
  String? imageUrl;
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  TextEditingController restaurantController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    imageUrl = widget.image;
    fetchData();
  }

  Future<void> fetchData() async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('RestaurantApp')
        .doc(widget.id)
        .get();

    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;

      setState(() {
        imageUrl = data['image'];
        restaurantController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';
      });
    }
  }

  Future<void> updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef =
          FirebaseFirestore.instance.collection('RestaurantApp').doc(widget.id);

      final currentData = await userRef.get();

      final Map<String, dynamic> newData = {};
      if (restaurantController.text != currentData.data()?['name']) {
        newData['name'] = restaurantController.text;
      }
      if (phoneController.text != currentData.data()?['phone']) {
        newData['phone'] = phoneController.text;
      }
      if (addressController.text != currentData.data()?['address']) {
        newData['address'] = addressController.text;
      }

      if (newData.isNotEmpty) {
        await userRef.set(newData, SetOptions(merge: true));
        print('อัปเดตข้อมูลเรียบร้อยแล้ว.');
      } else {
        print('ข้อมูลไม่เปลี่ยนแปลง ไม่มีการอัปเดตที่จำเป็น.');
      }

      if (selectedImage != null) {
        final String imageName = "${DateTime.now()}.jpg";
        final storageRef =
            FirebaseStorage.instance.ref().child('imageres/$imageName');

        if (imageUrl != null && imageUrl!.isNotEmpty) {
          final oldImageRef = FirebaseStorage.instance.refFromURL(imageUrl!);
          await oldImageRef.delete().catchError((error) {
            if (error is FirebaseException &&
                error.code == 'object-not-found') {
              print('ไม่พบรูปภาพเดิมที่ต้องการลบ.');
            } else {
              print('ลบรูปภาพเก่าไม่สำเร็จ: $error');
            }
          });
        }

        final uploadTask = storageRef.putFile(selectedImage!);
        await uploadTask.whenComplete(() => null);

        final imageURL = await storageRef.getDownloadURL();
        await userRef.set({'image': imageURL}, SetOptions(merge: true));
        print('อัปโหลดรูปภาพเรียบร้อยแล้ว  URL: $imageURL');

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลร้าน'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                _buildImageField('เลือกรูปภาพ', context),
                _buildRestaurant(),
                const SizedBox(height: 20),
                _buildAddress(),
                const SizedBox(height: 20),
                _buildPhone(),
                const SizedBox(height: 20),
                _buildMapRestaurant(),
                const SizedBox(height: 20),
                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageField(String text, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildImage(),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            Map<permission_handler.Permission,
                permission_handler.PermissionStatus> statuses = await [
              permission_handler.Permission.storage,
              permission_handler.Permission.camera,
            ].request();

            if (statuses[permission_handler.Permission.storage]!.isGranted &&
                statuses[permission_handler.Permission.camera]!.isGranted) {
              showImagePicker(context);
            } else {
              print('ไม่ได้ให้สิทธิ์');
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
            onPrimary: Colors.white,
          ),
          child: const Text('เลือกรูปภาพ'),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Card(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5.2,
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    child: const Column(
                      children: [
                        Icon(
                          Icons.image,
                          size: 60.0,
                        ),
                        SizedBox(height: 12.0),
                        Text(
                          "แกลเลอรี่",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        )
                      ],
                    ),
                    onTap: () {
                      _imgFromGallery().then((value) {
                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: const SizedBox(
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 60.0,
                          ),
                          SizedBox(height: 12.0),
                          Text(
                            "กล้อง",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      _imgFromCamera().then((value) {
                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _imgFromGallery() async {
    final image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> _imgFromCamera() async {
    final image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Widget _buildImage() {
    if (selectedImage != null) {
      return Image.file(
        selectedImage!,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/images/image.jpg',
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildRestaurant() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextField(
        controller: restaurantController,
        decoration: InputDecoration(
          labelText: 'ชื่อร้านอาหาร',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[300],
          labelStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAddress() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: TextField(
        controller: addressController,
        decoration: InputDecoration(
          labelText: 'ที่อยู่',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[300],
          labelStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPhone() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextField(
        controller: phoneController,
        decoration: InputDecoration(
          labelText: 'เบอร์โทรศัพท์',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[300],
          labelStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  Widget _buildButton() {
    return ElevatedButton(
      onPressed: () async {
        await updateUserData();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text('บันทึก'),
    );
  }
}

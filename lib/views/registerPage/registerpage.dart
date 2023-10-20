// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, unused_local_variable
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:manager_res/export.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final TextEditingController nameResController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  File? selectedImage;
  final picker = ImagePicker();

  late Future<FirebaseApp> firebase;

  Future<geolocator.Position?> getCurrentLocation() async {
    try {
      geolocator.Position position =
          await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.best,
      );
      return position;
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงตำแหน่ง: $e');
      return null;
    }
  }

  Future<void> _getLocationAndRegister() async {
    Map<permission_handler.Permission, permission_handler.PermissionStatus>
        statuses = await [
      permission_handler.Permission.location,
      permission_handler.Permission.camera,
      permission_handler.Permission.storage,
    ].request();

    if (!statuses[permission_handler.Permission.location]!.isGranted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ต้องการการเข้าถึงตำแหน่ง'),
            content: const Text(
                'เราต้องการข้อมูลตำแหน่งของคุณเพื่อเสนอบริการที่ดีที่สุด'),
            actions: <Widget>[
              TextButton(
                child: const Text('ปิด'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('ตั้งค่า'),
                onPressed: () async {
                  await permission_handler.openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    firebase = Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error);
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: const Color(0xFFFCE7E2),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 20),
                            _buildTitlesignUp(),
                            const SizedBox(height: 10),
                            _buildEmailField(),
                            const SizedBox(height: 10),
                            _buildPasswordField(),
                            const SizedBox(height: 10),
                            _buildconfirmPasswordField(),
                            const SizedBox(height: 10),
                            _buildNameResField(),
                            const SizedBox(height: 10),
                            _buildNumberField(),
                            const SizedBox(height: 10),
                            _buildAddressField(),
                            const SizedBox(height: 10),
                            _buildImageField('เลือกรูปภาพ', context),
                            const SizedBox(height: 50),
                            _buildRegisterButton(),
                            const SizedBox(height: 20),
                            _buildRegisterLink(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
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

  Widget _buildLogo() {
    return const Center(
      child: Image(
        image: AssetImage('assets/images/manager.png'),
        height: 200,
        width: 200,
      ),
    );
  }

  InputDecoration _customDecoration({String? hint, String? label}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: TextStyle(color: Colors.grey[500]),
      labelStyle: TextStyle(color: Colors.grey[800], fontSize: 16),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(5.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(5.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red[700]!),
        borderRadius: BorderRadius.circular(5.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red[700]!),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: emailController,
          decoration: _customDecoration(hint: 'กรุณาอีเมล'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "กรุณาใส่อีเมล";
            }
            if (!value.contains('@')) {
              return "กรุณาใส่อีเมลที่ถูกต้อง";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: passwordController,
          decoration: _customDecoration(hint: 'กรุณารหัสผ่าน'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "กรุณาใส่รหัสผ่าน";
            }
            if (value.length < 6) {
              return "กรุณาใส่รหัสผ่านมากกว่า 6 ตัวอักษร";
            }
            return null;
          },
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildconfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: confirmPassController,
          decoration: _customDecoration(hint: 'กรุณายืนยันรหัสผ่าน'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "กรุณายืนยันรหัสผ่าน";
            }
            if (value != passwordController.text) {
              return "กรุณาใส่รหัสผ่านให้ตรงกัน";
            }
            return null;
          },
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildNameResField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameResController,
          decoration: _customDecoration(hint: 'กรุณาใส่ชื่อร้านอาหาร'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "กรุณาใส่ชื่อร้านอาหาร";
            }
            if (value.length < 6) {
              return "กรุณาใส่ชื่อร้านอาหารมากกว่า 6 ตัวอักษร";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: phoneController,
          decoration: _customDecoration(hint: 'กรุณาเบอร์โทร'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "กรุณาใส่เบอร์โทร";
            }
            if (value.length < 10) {
              return "กรุณาใส่เบอร์โทรมากกว่า 10 ตัวอักษร";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: addressController,
          decoration: _customDecoration(hint: 'กรุณาใส่ที่อยู่'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "กรุณาใส่ที่อยู่";
            }
            if (value.length < 6) {
              return "กรุณาใส่ที่อยู่มากกว่า 6 ตัวอักษร";
            }
            return null;
          },
        ),
      ],
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
      return Center(
        child: Image.file(
          selectedImage!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Center(
        child: Image.asset(
          'assets/images/image.jpg',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Widget _buildRegisterButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.redAccent,
          ),
          child: const Text(
            "ลงทะเบียน",
            style: TextStyle(fontSize: 20),
          ),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              geolocator.Position? currentLocation = await getCurrentLocation();
              if (currentLocation != null) {
                double latitude = currentLocation.latitude;
                double longitude = currentLocation.longitude;

                try {
                  if (selectedImage != null) {
                    String imageUrl =
                        await uploadImageToStorage(selectedImage!);
                    addData(
                      nameResController.text,
                      emailController.text,
                      passwordController.text,
                      confirmPassController.text,
                      phoneController.text,
                      addressController.text,
                      latitude,
                      longitude,
                      imageUrl,
                      'manager',
                      'รอดำเนินการ',
                    );
                  } else {
                    print('ไม่ได้เลือกรูปภาพ');
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInPage(),
                    ),
                  );
                  resetFields();
                } catch (e) {
                  print('เกิดข้อผิดพลาดในการลงทะเบียน: $e');
                }
              } else {
                print('ไม่สามารถดึงตำแหน่งปัจจุบันได้');
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildTitlesignUp() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "ลงทะเบียน",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      final String imageName = "${DateTime.now()}.jpg";
      final FirebaseStorage storage = FirebaseStorage.instance;

      final Reference Ref = storage.ref().child('imageres/$imageName');
      final UploadTask uploadTask = Ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: $e');
      return '';
    }
  }

  void addData(
    String name,
    String email,
    String password,
    String confirmPassword,
    String phone,
    String address,
    double latitude,
    double longitude,
    String imageUrl,
    String role,
    String status,
  ) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference docRef = firestore.collection('serviceRequests').doc();

    Map<String, dynamic> data = {
      'id': docRef.id,
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'image': imageUrl,
      'role': 'manager',
      'status': 'รออนุมัติ',
    };

    docRef.set(data).then((value) {
      print('เพิ่มเอกสารเรียบร้อย: $data');
      print('เพิ่มข้อมูลเรียบร้อย: $data');
    }).catchError((error) {
      print('เกิดข้อผิดพลาดในการเพิ่มเอกสาร: $error');
    });
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Text(
            'มีบัญชีอยู่แล้ว? ',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
        ),
        GestureDetector(
          child: const Text(
            'เข้าสู่ระบบ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          onTap: () {
            resetFields();
            Navigator.pushNamed(context, AppRoute.signIn);
          },
        ),
      ],
    );
  }

  void resetFields() {
    emailController.clear();
    passwordController.clear();
    confirmPassController.clear();
    nameResController.clear();
    phoneController.clear();
    addressController.clear();
    setState(() {
      selectedImage = null;
    });
  }
}

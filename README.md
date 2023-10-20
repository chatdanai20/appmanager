// ignore_for_file: must_be_immutable, unnecessary_null_comparison, unused_local_variable

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:manager_res/export.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class AddMenuPage extends StatefulWidget {
  final String? selectedItemId;
  final String initialName;
  final String initialPrice;
  final String initialImage;
  final File? selectedImage;
  final String? selectedOption;
  final String? selectedNameEx;
  final String? selectedPriceEx;
  final bool isEditing;
  final String appBarTitle;
  const AddMenuPage({
    Key? key,
    this.selectedItemId,
    this.initialName = '',
    this.initialPrice = '',
    this.initialImage = '',
    this.selectedImage,
    this.isEditing = false,
    required this.appBarTitle,
    this.selectedOption = '',
    this.selectedNameEx = '',
    this.selectedPriceEx = '',
  }) : super(key: key);

  @override
  _AddMenuPageState createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController optionController = TextEditingController();
  final TextEditingController nameExController = TextEditingController();
  final TextEditingController priceExController = TextEditingController();
  String? _userEmail;
  List<String> optionList = [];
  List<String> nameEXList = [];
  List<String> priceExList = [];

  late Future<FirebaseApp> firebase;
  File? selectedImage;
  final picker = ImagePicker();
  final firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance.ref();

  // String? _originalName;
  // String? _originalPrice;
  // String? _originalImage;
  // String? _originalOption;
  // String? _originalNameEx;
  // String? _originalPriceEx;
  // String? _originalImage;

  @override
  void initState() {
    super.initState();
    firebase = Firebase.initializeApp();
    _userEmail = FirebaseAuth.instance.currentUser?.email;
    if (widget.selectedItemId != null) {
      nameController.text = widget.initialName;
      priceController.text = widget.initialPrice;
      imageController.text = widget.initialImage;
      selectedImage = widget.selectedImage;
      optionList =
          widget.selectedOption != null ? [widget.selectedOption!] : [];
      nameEXList =
          widget.selectedNameEx != null ? [widget.selectedNameEx!] : [];
      priceExList =
          widget.selectedPriceEx != null ? [widget.selectedPriceEx!] : [];
    }
  }

  final CollectionReference menuCollection =
      FirebaseFirestore.instance.collection('Menu');

  Future<void> addFirestore() async {
    int lastId = await getLastId();

    int newId = lastId + 1;

    String customDocumentId = 'Menu $newId';

    await menuCollection.doc(customDocumentId).set({
      'id': customDocumentId,
      'email': _userEmail,
      'name': nameController.text,
      'price': priceController.text,
      'image': imageController.text,
      'options': optionList,
      'nameExs': nameEXList,
      'priceExs': priceExList,
      'extras': List.generate(nameEXList.length,
          (index) => "${nameEXList[index]} - ${priceExList[index]}")
    });
  }

  Future<int> getLastId() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collection = firestore.collection('Menu');

    QuerySnapshot querySnapshot = await collection.get();
    List<DocumentSnapshot> documents = querySnapshot.docs;

    int lastId = 0;

    for (var document in documents) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      String idString = data['id'];
      int id = int.parse(idString.split(' ')[1]);

      if (id != null) {
        if (id > lastId) {
          lastId = id;
        }
      } else {
        lastId = id;
      }
    }
    return lastId;
  }

  Future<void> updateFirestore(DocumentReference docRef) async {
    Map<String, dynamic> updatedData = {};

    if (nameController.text != widget.initialName) {
      updatedData['name'] = nameController.text;
    }

    if (priceController.text != widget.initialPrice) {
      updatedData['price'] = priceController.text;
    }

    if (selectedImage != null && imageController.text != widget.initialImage) {
      await FirebaseStorage.instance.refFromURL(widget.initialImage).delete();

      String? newImageUrl = await uploadImageToStorage(selectedImage!);
      if (newImageUrl != null) {
        updatedData['image'] = newImageUrl;
        imageController.text = newImageUrl;
      }
    }

    if (optionController.text != widget.selectedOption) {
      updatedData['options'] = optionList;
    }

    if (nameExController.text != widget.selectedNameEx) {
      updatedData['nameExs'] = nameEXList;
    }

    if (priceExController.text != widget.selectedPriceEx) {
      updatedData['priceExs'] = priceExList;
    }

    if (updatedData.isNotEmpty) {
      await docRef.update(updatedData);
    }
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
            appBar: AppBar(
              title: Text(widget.appBarTitle),
              centerTitle: true,
              backgroundColor: Colors.redAccent,
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('ยืนยันการลบ'),
                          content:
                              const Text('คุณต้องการลบรายการนี้ใช่หรือไม่?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('ยกเลิก'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('ลบ'),
                              onPressed: () async {
                                if (widget.initialImage != null &&
                                    widget.initialImage.isNotEmpty) {
                                  await FirebaseStorage.instance
                                      .refFromURL(widget.initialImage)
                                      .delete();
                                }

                                if (widget.selectedItemId != null &&
                                    widget.selectedItemId!.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('Menu')
                                      .doc(widget.selectedItemId)
                                      .delete();
                                }

                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
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
                            _buildtitle('รายการอาหาร'),
                            const SizedBox(height: 10),
                            _buildNameField(),
                            const SizedBox(height: 20),
                            _buildPriceField(),
                            _buildImageField('รูปภาพ', context),
                            const SizedBox(height: 10),
                            _buildtitle('ตัวเลือก'),
                            const SizedBox(height: 10),
                            _buildOptionList(),
                            _buildOptionField(),
                            const SizedBox(height: 20),
                            _buildOptionButtom(),
                            const SizedBox(height: 20),
                            _buildtitle('ท็อปปิ้ง'),
                            _buildExtraList(),
                            const SizedBox(height: 10),
                            _buildNameExtraField(),
                            const SizedBox(height: 20),
                            _buildPriceExtraField(),
                            const SizedBox(height: 20),
                            _buildExtraButtom(),
                            const SizedBox(height: 40),
                            _buildButtom(),
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

//! line
  Widget _buildDivider(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey[400],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

//! error
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

//! title
  Widget _buildtitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

//! textfield
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: _customInputDecoration('ชื่ออาหาร', Icons.list_alt),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: priceController,
          decoration: _customInputDecoration('ราคา', Icons.money),
        ),
      ],
    );
  }

  InputDecoration _customInputDecoration(String hintText, IconData iconData) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(iconData, color: Colors.redAccent),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
    );
  }

  Widget _buildOptionField() {
    return Column(
      children: [
        TextFormField(
          controller: optionController,
          decoration: _customInputDecoration(
            "ใส่ตัวเลือก...",
            Icons.add_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildNameExtraField() {
    return Column(
      children: [
        TextFormField(
          controller: nameExController,
          decoration: _customInputDecoration(
            "ใส่ท็อปปิ้ง...",
            Icons.add_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceExtraField() {
    return Column(
      children: [
        TextFormField(
          controller: priceExController,
          decoration: _customInputDecoration(
            "ใส่ราคาท็อปปิ้ง...",
            Icons.attach_money_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: optionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${index + 1}. ${optionList[index]}',
              style: const TextStyle(fontSize: 20)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                optionList.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildExtraList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: nameEXList.length,
      itemBuilder: (context, index) {
        String item = "${nameEXList[index]} - ${priceExList[index]}";
        return ListTile(
          title: Text(item, style: const TextStyle(fontSize: 20)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                nameEXList.removeAt(index);
                priceExList.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildImageField(String text, BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
              ),
              onPressed: () async {
                Map<permission_handler.Permission,
                    permission_handler.PermissionStatus> statuses = await [
                  permission_handler.Permission.storage,
                  permission_handler.Permission.camera,
                ].request();

                if (statuses[permission_handler.Permission.storage]!
                        .isGranted &&
                    statuses[permission_handler.Permission.camera]!.isGranted) {
                  showImagePicker(context);
                } else {
                  print('ไม่ได้ให้สิทธิ์');
                }
              },
              child: const Text('เลือกรูปภาพ'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildImage(),
      ],
    );
  }

  Widget _buildImage() {
    final imageUrl = imageController.text;
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (selectedImage != null) {
      return Image.file(
        selectedImage!,
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

//! เลือกimage
  Widget _buildImagePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                final XFile? image = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() {
                    selectedImage = File(image.path);
                  });
                }
              },
              child: const Text('เลือกรูปภาพ'),
            ),
            ElevatedButton(
              onPressed: () async {
                final XFile? image = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  setState(() {
                    selectedImage = File(image.path);
                  });
                }
              },
              child: const Text('ถ่ายรูป'),
            ),
          ],
        ),
        if (selectedImage != null)
          Image.file(
            selectedImage!,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
      ],
    );
  }

//! แสดงรูปภาพ
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
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
      if (value != null) {
        setState(() {
          selectedImage = File(value.path);
        });
      }
    });
  }

  Future<void> _imgFromCamera() async {
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 50)
        .then((value) {
      if (value != null) {
        setState(() {
          selectedImage = File(value.path);
        });
      }
    });
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      final String imageName = "${DateTime.now()}.jpg";
      final FirebaseStorage storage = FirebaseStorage.instance;

      final Reference Ref = storage.ref().child('menufoods/$imageName');
      final UploadTask uploadTask = Ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: $e');
      return '';
    }
  }

//! Button
  Widget _buildButtom() {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            primary: Colors.redAccent,
          ),
          onPressed: () async {
            if (widget.isEditing && widget.selectedItemId != null) {
              await updateFirestore(menuCollection.doc(widget.selectedItemId));
            } else {
              await addFirestore();
            }

            Navigator.pop(context);
          },
          child: Text(
            widget.isEditing ? 'แก้ไขรายการอาหาร' : 'เพิ่มรายการอาหาร',
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButtom() {
    return SizedBox(
      // padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            primary: Colors.redAccent,
          ),
          onPressed: () {
            if (optionController.text.isNotEmpty) {
              setState(() {
                optionList.add(optionController.text);
                optionController.clear();
              });
            }
          },
          child: const Text('เพิ่มตัวเลือก', style: TextStyle(fontSize: 22)),
        ),
      ),
    );
  }

  Widget _buildExtraButtom() {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            primary: Colors.redAccent,
          ),
          onPressed: () {
            if (nameExController.text.isNotEmpty &&
                priceExController.text.isNotEmpty) {
              setState(() {
                nameEXList.add(nameExController.text);
                priceExList.add(priceExController.text);
                nameExController.clear();
                priceExController.clear();
              });
            }
          },
          child: const Text('เพิ่มท็อปปิ้ง', style: TextStyle(fontSize: 22)),
        ),
      ),
    );
  }
}


import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({Key? key}) : super(key: key);

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการอาหารที่สั่ง"),
      ),
      body: StreamBuilder(
        stream: databaseReference.child('order').onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            var orderData =
                Map<String, dynamic>.from(snapshot.data!.snapshot.value);

            int numberOfPeople = orderData['number_of_people'];
            double totalPrice = orderData['total_price'].toDouble();
            double finalPrice = orderData['final_price'].toDouble();
            double discount = orderData['discount'].toDouble();
            List<dynamic> items = orderData['items'];
            String user = orderData['user'];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ผู้ใช้งาน: $user',
                            style: const TextStyle(fontSize: 18)),
                        Text('จำนวนคน : $numberOfPeople',
                            style: const TextStyle(fontSize: 18)),
                        Text('รายจ่ายทั้งหมด: $totalPrice',
                            style: const TextStyle(fontSize: 18)),
                        Text('ส่วนลด: $discount',
                            style: const TextStyle(fontSize: 18)),
                        Text('รายจ่ายสุทธิ: $finalPrice',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        const Text('Items:',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        ...items.map((item) {
                          var itemMap = Map<String, dynamic>.from(item);
                          return ListTile(
                            title: Text(itemMap['name']),
                            subtitle: Text('Option: ${itemMap['option']}'),
                            trailing: Text('${itemMap['price']}'),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text('No data available'),
            );
          }
        },
      ),
    );
  }
}

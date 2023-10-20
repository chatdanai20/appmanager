// // ignore_for_file: must_be_immutable

// import 'package:manager_res/export.dart';
// import 'package:permission_handler/permission_handler.dart'
//     as permission_handler;

// class AddMenuPage extends StatefulWidget {
//   AddMenuPage({super.key});
//   List<Map<String, dynamic>> extraItems = [];
//   static const id = 'setPhoto';

//   @override
//   _AddMenuPageState createState() => _AddMenuPageState();
// }

// class _AddMenuPageState extends State<AddMenuPage> {
//   TextEditingController itemNameController = TextEditingController();
//   TextEditingController itemPriceController = TextEditingController();
//   TextEditingController selectedImageNameController = TextEditingController();
//   TextEditingController extraNameController = TextEditingController();
//   TextEditingController priceextraController = TextEditingController();
//   File? selectedImage;
//   final picker = ImagePicker();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('เพิ่มรายการอาหาร'),
//         centerTitle: true,
//         backgroundColor: Colors.redAccent,
//       ),
//       body: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildTitle('เพิ่มรายการอาหาร'),
//                 const SizedBox(height: 20),
//                 _buildTextField('ชื่ออาหาร', context),
//                 const SizedBox(height: 20),
//                 _buildTextField('ราคา', context),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () async {
//                     Map<permission_handler.Permission,
//                         permission_handler.PermissionStatus> statuses = await [
//                       permission_handler.Permission.storage,
//                       permission_handler.Permission.camera,
//                     ].request();

//                     if (statuses[permission_handler.Permission.storage]!
//                             .isGranted &&
//                         statuses[permission_handler.Permission.camera]!
//                             .isGranted) {
//                       showImagePicker(context);
//                     } else {
//                       print('ไม่ได้ให้สิทธิ์');
//                     }
//                   },
//                   child: const Text('เลือกรูปภาพ'),
//                 ),
//                 _buildsizeboximage(),
//                 selectedImage == null
//                     ? Center(
//                         child: Image.asset(
//                           'assets/images/image.jpg',
//                           height: 300.0,
//                           width: double.infinity,
//                         ),
//                       )
//                     : ClipRRect(
//                         child: Center(
//                           child: Image.file(
//                             selectedImage!,
//                             width: double.infinity,
//                             height: 300.0,
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                       ),
//                 const SizedBox(height: 30),
//                 _buildTitleadd('เพิ่มเติม'),
//                 const SizedBox(height: 20),
//                 _buildExtraList(),
//                 const SizedBox(height: 20),
//                 _buildTextField('ชื่อรายการเพิ่มเติม', context,
//                     controller: itemNameController),
//                 const SizedBox(height: 20),
//                 _buildTextField('ราคา', context,
//                     controller: itemPriceController),
//                 const SizedBox(height: 20),
//                 _buildBottomadd(),
//                 const SizedBox(height: 20),
//                 // const SizedBox(height: 70),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomAppBar(),
//     );
//   }

//   Widget _buildTitle(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         color: Colors.black,
//         fontSize: 18,
//         fontWeight: FontWeight.w600,
//         decoration: TextDecoration.none,
//         letterSpacing: 1,
//       ),
//     );
//   }

//   Widget _buildTitleadd(String text) {
//     return Row(
//       children: [
//         Text(
//           text,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             decoration: TextDecoration.none,
//             letterSpacing: 1,
//           ),
//         ),
//       ],
//     );
//   }

//   void _uploadDataToFirestore() async {
//     String itemName = itemNameController.text;
//     String itemPrice = itemPriceController.text;
//     String imageUrl = '';

//     if (itemName.isNotEmpty && itemPrice.isNotEmpty && selectedImage != null) {
//       try {
//         final ref = FirebaseStorage.instance
//             .ref()
//             .child('menu_images')
//             .child('$itemName.jpg');
//         await ref.putFile(selectedImage!);
//         imageUrl = await ref.getDownloadURL();

//         await FirebaseFirestore.instance.collection('menu').add({
//           'name': itemName,
//           'price': itemPrice,
//           'imageUrl': imageUrl,
//           'extraItems': widget.extraItems,
//         });
//         print('Data uploaded to Firestore successfully.');
//         Navigator.pop(context);
//       } catch (error) {
//         print('Error uploading data: $error');
//       }
//     } else {
//       print('Please fill in all fields and select an image.');
//     }
//   }

//   Widget _buildBottomadd() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.redAccent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         onPressed: () {
//           String itemName = itemNameController.text.trim();
//           String itemPrice = itemPriceController.text.trim();
//           if (itemName.isNotEmpty && itemPrice.isNotEmpty) {
//             setState(() {
//               widget.extraItems.add({
//                 'name': itemName,
//                 'price': itemPrice,
//               });
//               itemNameController.clear();
//               itemPriceController.clear();
//             });
//           }
//         },
//         child: const Text(
//           'เพิ่มรายการเพิ่มเติม',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             decoration: TextDecoration.none,
//             letterSpacing: 1,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String text, BuildContext context,
//       {TextEditingController? controller}) {
//     return Container(
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: text,
//           labelStyle: const TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             decoration: TextDecoration.none,
//             letterSpacing: 1,
//           ),
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }

//   Widget _buildImagePicker(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildTitle('รูปภาพ'),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 final XFile? image = await ImagePicker().pickImage(
//                   source: ImageSource.gallery,
//                 );
//                 if (image != null) {
//                   setState(() {
//                     selectedImage = File(image.path);
//                   });
//                 }
//               },
//               child: const Text('เลือกรูปภาพ'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final XFile? image = await ImagePicker().pickImage(
//                   source: ImageSource.camera,
//                 );
//                 if (image != null) {
//                   setState(() {
//                     selectedImage = File(image.path);
//                   });
//                 }
//               },
//               child: const Text('ถ่ายรูป'),
//             ),
//           ],
//         ),
//         if (selectedImage != null)
//           Image.file(
//             selectedImage!,
//             height: 100,
//             width: 100,
//             fit: BoxFit.cover,
//           ),
//       ],
//     );
//   }

//   Widget _buildExtraList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildTextExtra(),
//         const SizedBox(height: 10),
//         _buildExtraItemList(),
//       ],
//     );
//   }

//   Widget _buildTextExtra() {
//     int itemCount = widget.extraItems.length;
//     return Row(
//       children: [
//         Text(
//           '$itemCount' ' รายการเพิ่มเติม',
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             decoration: TextDecoration.none,
//             letterSpacing: 1,
//           ),
//         ),
//         const Spacer(),
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               widget.extraItems.clear();
//             });
//           },
//           child: const Icon(
//             Icons.delete,
//             color: Colors.redAccent,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildExtraItemList() {
//     return ListView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: widget.extraItems.length,
//       itemBuilder: (context, index) {
//         return Row(
//           children: [
//             Expanded(
//               child: ListTile(
//                 title: Text(
//                     '${widget.extraItems[index]['name']} - ${widget.extraItems[index]['price']}'),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   widget.extraItems.removeAt(index);
//                 });
//               },
//               child: const Icon(
//                 Icons.delete,
//                 color: Colors.redAccent,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   BottomAppBar _buildBottomAppBar() {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double bottomAppBarHeight = screenHeight * 0.10;
//     return BottomAppBar(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         height: bottomAppBarHeight,
//         decoration: BoxDecoration(
//           color: Colors.redAccent[100],
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20.0),
//             topRight: Radius.circular(20.0),
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildButtonaddmenu(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildButtonaddmenu() {
//     return GestureDetector(
//       onTap: () {
//         String itemName = itemNameController.text.trim();
//         String itemPrice = itemPriceController.text.trim();

//         print('itemName: $itemName');
//         print('itemPrice: $itemPrice');
//         print('selectedImage: $selectedImage');
//         if (itemName.isNotEmpty &&
//             itemPrice.isNotEmpty &&
//             selectedImage != null) {
//           _uploadDataToFirestore();
//         } else {
//           print('Please fill in all fields and select an image.');
//         }
//       },
//       child: Container(
//         alignment: Alignment.center,
//         height: 50,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.redAccent,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: const Text(
//           'เพิ่มรายการอาหาร',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildsizeboximage() {
//     return const SizedBox(
//       height: 20.0,
//     );
//   }

//   void showImagePicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (builder) {
//         return Card(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height / 5.2,
//             margin: const EdgeInsets.only(top: 8.0),
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     child: const Column(
//                       children: [
//                         Icon(
//                           Icons.image,
//                           size: 60.0,
//                         ),
//                         SizedBox(height: 12.0),
//                         Text(
//                           "แกลเลอรี่",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 16, color: Colors.black),
//                         )
//                       ],
//                     ),
//                     onTap: () {
//                       _imgFromGallery().then((value) {
//                         Navigator.pop(context);
//                       });
//                     },
//                   ),
//                 ),
//                 Expanded(
//                   child: InkWell(
//                     child: const SizedBox(
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.camera_alt,
//                             size: 60.0,
//                           ),
//                           SizedBox(height: 12.0),
//                           Text(
//                             "กล้อง",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(fontSize: 16, color: Colors.black),
//                           )
//                         ],
//                       ),
//                     ),
//                     onTap: () {
//                       _imgFromCamera().then((value) {
//                         Navigator.pop(context);
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _imgFromGallery() async {
//     await picker
//         .pickImage(source: ImageSource.gallery, imageQuality: 50)
//         .then((value) {
//       if (value != null) {
//         setState(() {
//           selectedImage = File(value.path);
//         });
//       }
//     });
//   }

//   Future<void> _imgFromCamera() async {
//     await picker
//         .pickImage(source: ImageSource.camera, imageQuality: 50)
//         .then((value) {
//       if (value != null) {
//         setState(() {
//           selectedImage = File(value.path);
//         });
//       }
//     });
//   }
// }

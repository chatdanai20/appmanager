import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetTablesPage extends StatefulWidget {
  const SetTablesPage({Key? key}) : super(key: key);

  @override
  _SetTablesPageState createState() => _SetTablesPageState();
}

class _SetTablesPageState extends State<SetTablesPage> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> timeSlots = [];
  List<TextEditingController> timeSlotControllers = [];
  List<TextEditingController> tableControllers = [];

  @override
  void initState() {
    super.initState();
    _initTimeSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('กำหนดจำนวนโต๊ะ'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: timeSlots.length + 2,
              itemBuilder: (context, index) {
                if (index < timeSlots.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: timeSlotControllers[index],
                            onChanged: (value) {
                              timeSlots[index]['timeSlot'] = value;
                            },
                            decoration: const InputDecoration(
                              labelText: 'ช่วงเวลา',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: tableControllers[index],
                            onChanged: (value) {
                              if (_isValidNumber(value)) {
                                timeSlots[index]['tables'] = int.parse(value);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'กรุณากรอกจำนวนโต๊ะที่เป็นตัวเลข!'),
                                  ),
                                );
                              }
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'โต๊ะสูงสุด',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            timeSlotControllers.removeAt(index);
                            tableControllers.removeAt(index);
                            setState(() {
                              timeSlots.removeAt(index);
                            });
                            _deleteTableData(index);
                          },
                        ),
                      ],
                    ),
                  );
                } else if (index == timeSlots.length) {
                  return ElevatedButton(
                    child: const Text("เพิ่มช่วงเวลา"),
                    onPressed: () {
                      timeSlotControllers.add(TextEditingController());
                      tableControllers.add(TextEditingController());
                      setState(() {
                        timeSlots.add({'timeSlot': '', 'tables': 0});
                      });
                    },
                  );
                } else {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        '*กรุณากรอกจำนวนโต๊ะ โดย 1 โต๊ะ ได้รับ 4 ที่นั่ง',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          var newTimeSlotController = TextEditingController();
                          _updateTableData();
                          if (timeSlots.any((existing) =>
                              existing['timeSlot'] ==
                              newTimeSlotController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'ช่วงเวลาที่ซ้ำกันไม่สามารถเพิ่มได้!')),
                            );
                            return;
                          }
                          timeSlotControllers.add(newTimeSlotController);
                          tableControllers.add(TextEditingController());
                          setState(() {
                            timeSlots.add({'timeSlot': '', 'tables': 0});
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.redAccent),
                        ),
                        child: const Text('ยืนยัน'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidNumber(String? value) {
    if (value == null) return false;
    return int.tryParse(value) != null;
  }

  void _initTimeSlots() async {
    String? userEmail = FirebaseAuth.instance.currentUser!.email;
    CollectionReference restaurantRef =
        FirebaseFirestore.instance.collection("restaurant");

    QuerySnapshot result =
        await restaurantRef.where('email', isEqualTo: userEmail).get();

    if (result.docs.isNotEmpty) {
      Map<String, dynamic>? dataMap =
          result.docs.first.data() as Map<String, dynamic>?;
      List<Map<String, dynamic>> existingTimeSlots =
          List<Map<String, dynamic>>.from((dataMap?['timeSlots'] as List? ?? [])
              .map((e) => e as Map<String, dynamic>));

      for (var slot in existingTimeSlots) {
        timeSlotControllers.add(TextEditingController(text: slot['timeSlot']));
        tableControllers.add(TextEditingController(text: '${slot['tables']}'));
      }

      setState(() {
        timeSlots = existingTimeSlots;
      });
    }
  }

  void _deleteTableData(int index) async {
    String? userEmail = FirebaseAuth.instance.currentUser!.email;
    CollectionReference restaurantRef =
        FirebaseFirestore.instance.collection("restaurant");
    var doc = await restaurantRef.where('email', isEqualTo: userEmail).get();

    if (doc.docs.isNotEmpty) {
      var docId = doc.docs.first.id;
      var currentData = doc.docs.first.data() as Map<String, dynamic>;
      if (currentData.containsKey('timeSlots')) {
        List<dynamic> slots = List.from(currentData['timeSlots']);
        slots.removeAt(index);
        await restaurantRef.doc(docId).update({'timeSlots': slots});
      }
    }
  }

  void _updateTableData() async {
    String? userEmail = FirebaseAuth.instance.currentUser!.email;
    CollectionReference restaurantRef =
        FirebaseFirestore.instance.collection("restaurant");
    var doc = await restaurantRef.where('email', isEqualTo: userEmail).get();

    if (doc.docs.isNotEmpty) {
      var docId = doc.docs.first.id;
      await restaurantRef.doc(docId).update({'timeSlots': timeSlots});
    }
  }
}

import 'package:intl/intl.dart';
import 'package:manager_res/export.dart';

class AddPromotionPage extends StatefulWidget {
  const AddPromotionPage({super.key});

  @override
  _AddPromotionPageState createState() => _AddPromotionPageState();
}

class _AddPromotionPageState extends State<AddPromotionPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  String _discountType = 'AMOUNT';

  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างโปรโมชั่น'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(
                  'ชื่อโปรโมชั่น',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: _inputDecoration(
                  'รายละเอียดโปรโมชั่น',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                decoration: _inputDecoration(
                  'รหัสโปรโมชั่น',
                ),
              ),
              if (_discountType != 'BUY_ONE_GET_ONE') ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _valueController,
                  decoration: _inputDecoration(
                    _discountType == 'PERCENT' ? 'เปอร์เซ็นต์' : 'จำนวนเงิน',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    itemHeight: 48,
                    value: _discountType,
                    dropdownColor: Colors.redAccent,
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (String? newValue) {
                      setState(() {
                        _discountType = newValue!;
                      });
                    },
                    items: ['PERCENT', 'AMOUNT', 'BUY_ONE_GET_ONE']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _selectDate,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'เลือกวันหมดอายุ'
                        : 'วันหมดอายุ: ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _createPromotion,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                  ),
                  child: const Text(
                    'สร้างโปรโมชั่น',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.redAccent,
            colorScheme: const ColorScheme.light(primary: Colors.redAccent),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  _createPromotion() async {
    if (_nameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _codeController.text.trim().isEmpty ||
        (_discountType != 'BUY_ONE_GET_ONE' &&
            _valueController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('กรุณาเลือกวันหมดอายุ')));
      return;
    }

    final firestore = FirebaseFirestore.instance;
    await firestore.collection('promotions').doc(_codeController.text).set({
      'id': _codeController.text,
      'name': _nameController.text,
      'description': _descriptionController.text,
      'discountType': _discountType,
      'discountValue': _discountType == 'BUY_ONE_GET_ONE'
          ? null
          : double.parse(_valueController.text),
      'expirationDate': Timestamp.fromDate(_selectedDate!),
      'role': 'manager',
      'email': FirebaseAuth.instance.currentUser!.email!,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('สร้างโปรโมชั่นสำเร็จ!')));
    Navigator.pop(context);
  }
}

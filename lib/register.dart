import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import 'order.dart';
import 'orderer.dart';

class RegisterPage extends StatefulWidget {
  final Isar isar;
  const RegisterPage({super.key, required this.isar});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _listTileData = <List<TextEditingController>>[];
  TextEditingController nameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل'),
          actions: [
            IconButton(
                onPressed: () async {
                  final newOrderer = Orderer()
                    ..name = nameController.text
                    ..idNumber = idNumberController.text
                    ..phoneNumber = phoneController.text;

                  List<Order> orders = [];

                  for (var controllers in _listTileData) {
                    final newOrder = Order()
                      ..title = controllers[2].text
                      ..amount = int.parse(controllers[1].text)
                      ..cost = double.parse(controllers[0].text)
                      ..author.value = newOrderer;

                    orders.add(newOrder);
                  }

                  await widget.isar.writeTxn(() async {
                    await widget.isar.orderers.put(newOrderer);
                    for (var order in orders) {
                      await widget.isar.orders.put(order);
                      await order.author.save();
                    }
                  });

                  debugPrint('added');
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      hintText: "الإسم", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: idNumberController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      hintText: "رقم الهوية", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: phoneController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      hintText: "رقم الهاتف", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              ListTile(
                title: const Text("الأعمال"),
                trailing: IconButton(
                  onPressed: _addListTile,
                  icon: const Icon(Icons.add),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _listTileData.length,
                  itemBuilder: (context, index) {
                    final controllers = _listTileData[index];
                    return ListTile(
                      title: ThreeTextFields(
                        controller1: controllers[0],
                        controller2: controllers[1],
                        controller3: controllers[2],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteListTile(index),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _printValues,
                child: const Text('debugPrint Values'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addListTile() {
    setState(() {
      _listTileData.add([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    });
  }

  void _deleteListTile(int index) {
    setState(() {
      _listTileData.removeAt(index);
    });
  }

  void _printValues() {
    for (var i = 0; i < _listTileData.length; i++) {
      final controllers = _listTileData[i];
      debugPrint('ListTile ${i + 1}:');
      debugPrint('  Controller 1: ${controllers[0].text}');
      debugPrint('  Controller 2: ${controllers[1].text}');
      debugPrint('  Controller 3: ${controllers[2].text}');
    }
  }
}

class ThreeTextFields extends StatelessWidget {
  final TextEditingController controller1;
  final TextEditingController controller2;
  final TextEditingController controller3;

  const ThreeTextFields({
    super.key,
    required this.controller1,
    required this.controller2,
    required this.controller3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
                hintText: "العمل", border: OutlineInputBorder()),
            controller: controller3,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: TextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
                hintText: "الكمية", border: OutlineInputBorder()),
            controller: controller2,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: TextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
                hintText: "السعر", border: OutlineInputBorder()),
            controller: controller1,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import 'assigned_order.dart';
import 'order.dart';
import 'orderer.dart';
import 'recipient.dart';

class MyList extends StatefulWidget {
  final Isar isar;
  final Orderer orderer;

  const MyList(this.orderer, {super.key, required this.isar});

  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  final List<Item> _items = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  void addItem() {
    setState(() {
      _items.add(Item(value: null, text1: '', text2: ''));
    });
  }

  void printValues() {
    for (var item in _items) {
      debugPrint(
          "Dropdown: ${item.value!.title}, Amount: ${item.text1}, Cost: ${item.text2}");
    }
  }

  void saveData() async {
    final newRecipient = Recipient()
      ..name = nameController.text
      ..idNumber = idNumberController.text
      ..phoneNumber = phoneController.text;

    List<AssignedOrder> orders = [];

    for (var item in _items) {
      final newOrder = AssignedOrder()
        ..order.value = item.value
        ..amount = int.parse(item.text1)
        ..cost = double.parse(item.text2)
        ..date = DateTime.now()
        ..recipient.value = newRecipient;

      orders.add(newOrder);
      debugPrint(newOrder.order.value!.title);
    }

    await widget.isar.writeTxn(() async {
      await widget.isar.recipients.put(newRecipient);
      for (var order in orders) {
        debugPrint(order.order.value!.title);
        await widget.isar.assignedOrders.put(order);
        newRecipient.assignedOrders.add(order);

        await order.order.save();
        await order.recipient.save();
        await newRecipient.assignedOrders.save();
      }
    }).then((value) => debugPrint(value.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                saveData();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
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
                  onPressed: addItem,
                  icon: const Icon(Icons.add),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return MyListTile(
                      orderer: widget.orderer,
                      item: _items[index],
                      onChanged: (value, text1, text2) {
                        setState(() {
                          _items[index] =
                              Item(value: value, text1: text1, text2: text2);
                        });
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Item {
  final Order? value;
  final String text1;
  final String text2;

  Item({this.value, required this.text1, required this.text2});
}

class MyListTile extends StatefulWidget {
  final Item item;
  final Orderer orderer;
  final Function(Order?, String, String) onChanged;

  const MyListTile(
      {super.key,
      required this.orderer,
      required this.item,
      required this.onChanged});

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  // final List<String> _dropdownItems = ['Option 1', 'Option 2', 'Option 3'];
  Order? _selectedValue;
  final TextEditingController _text1Controller = TextEditingController();
  final TextEditingController _text2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.item.value;
    _text1Controller.text = widget.item.text1;
    _text2Controller.text = widget.item.text2;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            DropdownButton<Order>(
              value: _selectedValue,
              hint: const Text('اختر العمل'),
              items: widget.orderer.orders.map((Order value) {
                return DropdownMenuItem<Order>(
                  value: value,
                  child: Text(value.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedValue = value;
                });
                widget.onChanged(
                    value, _text1Controller.text, _text2Controller.text);
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _text1Controller,
                decoration: const InputDecoration(
                    hintText: 'الكمية', border: OutlineInputBorder()),
                onChanged: (text) => widget.onChanged(
                    _selectedValue, text, _text2Controller.text),
              ),
            ),
          ],
        ),
      ),
      subtitle: TextField(
        controller: _text2Controller,
        decoration: const InputDecoration(
            hintText: 'السعر', border: OutlineInputBorder()),
        onChanged: (text) =>
            widget.onChanged(_selectedValue, _text1Controller.text, text),
      ),
    );
  }
}

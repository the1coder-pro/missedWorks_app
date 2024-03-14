import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'order.dart';
import 'orderer.dart';
import 'prefs.dart';

class RegisterPage extends StatefulWidget {
  final Orderer? orderer;
  const RegisterPage({super.key, this.orderer});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _listTileData = <List<TextEditingController>>[];
  TextEditingController nameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // fill controllers with orderer's data if orderer is not null
  void fillControllers() {
    if (widget.orderer != null) {
      nameController.text = widget.orderer!.name;
      idNumberController.text = widget.orderer!.idNumber!;
      phoneController.text = widget.orderer!.phoneNumber!;

      for (var order in widget.orderer!.orders) {
        _listTileData.add([
          TextEditingController(text: order.cost.toString()),
          TextEditingController(text: order.amount.toString()),
          TextEditingController(text: order.title),
        ]);
      }
    }
  }

  @override
  void initState() {
    fillControllers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mainDatabase = context.watch<MainDatabase>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.orderer == null ? 'تسجيل' : 'تعديل',
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  if (widget.orderer != null) {
                    final newOrderer = Orderer()
                      ..id = widget.orderer!.id
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

                    mainDatabase.addOrderer(newOrderer, orders);

                    debugPrint('updated');
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    return;
                  } else {
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

                    // changed orders
                    List<Order> changedOrders = [];
                    for (var order in orders) {
                      if (order.title != '' &&
                          order.amount != 0 &&
                          order.cost != 0) {
                        changedOrders.add(order);
                      }
                    }

                    mainDatabase.addOrderer(newOrderer, orders);

                    debugPrint('added');
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
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
                  // fill in the name if orderer is not null
                  decoration: const InputDecoration(
                      hintText: "الإسم", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: idNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      hintText: "رقم الهوية", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
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
                          delete: () => _deleteListTile(index)),
                    );
                  },
                ),
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
}

class ThreeTextFields extends StatelessWidget {
  final TextEditingController controller1;
  final TextEditingController controller2;
  final TextEditingController controller3;
  final void Function()? delete;

  const ThreeTextFields(
      {super.key,
      required this.controller1,
      required this.controller2,
      required this.controller3,
      required this.delete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            decoration: const InputDecoration(
                hintText: "العمل", border: OutlineInputBorder()),
            controller: controller3,
          ),
        ),
        const SizedBox(width: 5.0),
        Expanded(
          flex: 2,
          child: TextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                hintText: "الكمية", border: OutlineInputBorder()),
            controller: controller2,
          ),
        ),
        const SizedBox(width: 5.0),
        Expanded(
          flex: 2,
          child: TextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                hintText: "السعر", border: OutlineInputBorder()),
            controller: controller1,
          ),
        ),
        IconButton(onPressed: delete, icon: const Icon(Icons.delete_outline))
      ],
    );
  }
}

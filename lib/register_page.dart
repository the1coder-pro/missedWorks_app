// make the registeration page for orderer and his orders

import 'package:flutter/material.dart';
import 'package:missed_works_app/main.dart';
import 'package:provider/provider.dart';

import 'assigned_order.dart';
import 'order.dart';
import 'orderer.dart';
import 'prefs.dart';

class RegisterOrdererPage extends StatefulWidget {
  // add orderer as a parameter if you want to edit an orderer
  final Orderer? orderer;
  const RegisterOrdererPage({super.key, this.orderer});

  @override
  State<RegisterOrdererPage> createState() => _RegisterOrdererPageState();
}

class _RegisterOrdererPageState extends State<RegisterOrdererPage> {
  // make a list of text controllers for "name" "id number" "phone number"
  final _controllersOfOrder = <List<TextEditingController>>[];

  // make a list of maps for each order wtih his id and data of the order
  final _orders = <Map<String, dynamic>>[];

  TextEditingController nameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // fill controllers with orderer's data if orderer is not null
  void fillControllers() {
    if (widget.orderer != null) {
      nameController.text = widget.orderer!.name;
      idNumberController.text = widget.orderer!.idNumber!;
      phoneController.text = widget.orderer!.phoneNumber!;

      // fill the orders list with the orderer's orders if the orderer is not null
      if (widget.orderer != null) {
        for (var order in widget.orderer!.orders) {
          _orders.add({
            'id': order.id,
            'title': order.title,
            'amount': order.amount,
            'cost': order.cost,
            'assignedOrders': order.assignedOrders,
          });
        }
      }

      // fill the controllers of the orders with the _orders
      for (var order in _orders) {
        _controllersOfOrder.add([
          TextEditingController(text: order['title']),
          TextEditingController(text: order['amount'].toString()),
          TextEditingController(text: order['cost'].toString()),
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
    final mainDatabase = context.read<MainDatabase>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              // make 3 text fields for "name" "id number" "phone number"
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
              ),
              TextField(
                controller: idNumberController,
                decoration: const InputDecoration(labelText: 'رقم الهوية'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الجوال'),
                keyboardType: TextInputType.phone,
              ),
              // make a button to add order
              ElevatedButton(
                onPressed: () {
                  // add new controllers for the new order
                  setState(() {
                    _controllersOfOrder.add([
                      TextEditingController(),
                      TextEditingController(),
                      TextEditingController(),
                    ]);
                  });
                },
                child: const Text('إضافة طلب'),
              ),

              Expanded(
                  child: ListView.builder(
                      itemCount: _controllersOfOrder.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controllersOfOrder[index][0],
                                decoration:
                                    const InputDecoration(labelText: 'العنوان'),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controllersOfOrder[index][1],
                                decoration:
                                    const InputDecoration(labelText: 'الكمية'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controllersOfOrder[index][2],
                                decoration:
                                    const InputDecoration(labelText: 'السعر'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // delete the order
                                setState(() {
                                  _controllersOfOrder.removeAt(index);
                                });
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        );
                      })),
              // make a button to submit
              FilledButton(
                onPressed: () async {
                  if (widget.orderer != null) {
                    // delete the orderer and his orders
                    await mainDatabase.deleteOrdererWithOrders(widget.orderer!);
                    final orderer = Orderer()
                      ..name = nameController.text
                      ..idNumber = idNumberController.text
                      ..phoneNumber = phoneController.text;

                    List<Order> toBeSavedOrders = [];

                    // for (var i = 0; i < _orders.length; i++) {
                    //   final order = Order()
                    //     ..id = _orders[i]['id']
                    //     ..title = _orders[i]['title']
                    //     ..amount = int.parse(_orders[i]['amount'].toString())
                    //     ..cost = double.parse(_orders[i]['cost'].toString())
                    //     ..author.value = orderer;
                    //   toBeSavedOrders.add(order);
                    // }

                    // add the new orders
                    for (var i = 0; i < _controllersOfOrder.length; i++) {
                      final order = Order()
                        ..id = _orders[i]['id'] ?? Order().id
                        ..title = _controllersOfOrder[i][0].text
                        ..amount = int.parse(_controllersOfOrder[i][1].text)
                        ..cost = double.parse(_controllersOfOrder[i][2].text)
                        ..author.value = orderer;
                      if (_orders != null &&
                          _orders[i]['assignedOrders'] != null &&
                          _orders[i]['assignedOrders'].isNotEmpty) {
                        order.assignedOrders
                            .addAll(_orders[i]['assignedOrders']);
                      }

                      toBeSavedOrders.add(order);
                    }

                    mainDatabase.addOrderer(orderer, toBeSavedOrders);
                  } else {
                    // add the orderer
                    final orderer = Orderer()
                      ..name = nameController.text
                      ..idNumber = idNumberController.text
                      ..phoneNumber = phoneController.text;

                    List<Order> toBeSavedOrders = [];
                    for (var i = 0; i < _controllersOfOrder.length; i++) {
                      final order = Order()
                        ..title = _controllersOfOrder[i][0].text
                        ..amount = int.parse(_controllersOfOrder[i][1].text)
                        ..cost = double.parse(_controllersOfOrder[i][2].text)
                        ..author.value = orderer;
                      toBeSavedOrders.add(order);
                    }

                    mainDatabase.addOrderer(orderer, toBeSavedOrders);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('تسجيل'),
              ),
            ])));
  }
}

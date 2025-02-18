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
  final _focusNodes = <List<FocusNode>>[];
  TextEditingController nameController = TextEditingController();
  // TextEditingController idNumberController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  List<Map> mapsOfOrders = [];

  // make focusNodes for every field
  final FocusNode nameFocus = FocusNode();
  final FocusNode idNumberFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();

  // fill controllers with orderer's data if orderer is not null
  void fillControllers() {
    if (widget.orderer != null) {
      nameController.text = widget.orderer!.name;
      // idNumberController.text = widget.orderer!.idNumber!;
      phoneController.text = widget.orderer!.phoneNumber!;

      for (var order in widget.orderer!.orders) {
        mapsOfOrders.add({
          'id': order.id,
          'title': order.title,
          'amount': order.amount,
          'cost': order.cost,
          'assignedOrders': order.assignedOrders.toList(),
        });
      }
      for (var map in mapsOfOrders) {
        _listTileData.add([
          TextEditingController(text: map['cost'].toString()),
          TextEditingController(text: map['amount'].toString()),
          TextEditingController(text: map['title']),
        ]);
        _focusNodes.add([
          FocusNode(),
          FocusNode(),
          FocusNode(),
        ]);
      }
    }
  }

  @override
  void initState() {
    fillControllers();

    nameFocus.addListener(() {
      if (!nameFocus.hasFocus) {
        if (nameController.text.isNotEmpty) {
          idNumberFocus.requestFocus();
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    nameFocus.dispose();
    idNumberFocus.dispose();
    phoneFocus.dispose();
    super.dispose();
  }

  // tobe removed from the list of maps of orders
  List<Map> toBeRemoved = [];

  @override
  Widget build(BuildContext context) {
    final mainDatabase = context.read<MainDatabase>();
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
                      // ..idNumber = idNumberController.text
                      ..phoneNumber = phoneController.text;

                    List<Order> orders = [];

                    // check for new orders and changed orders and update the mapsOfOrders
                    for (var map in mapsOfOrders) {
                      for (var controllers in _listTileData) {
                        if (map['title'] == controllers[2].text) {
                          map['cost'] = controllers[0].text;
                          map['amount'] = controllers[1].text;
                        }
                      }
                    }

                    // add new orders
                    for (var controllers in _listTileData) {
                      // if the order is new add it to the list of map of orders
                      if (mapsOfOrders.every((element) =>
                          element['title'] != controllers[2].text)) {
                        mapsOfOrders.add({
                          'title': controllers[2].text,
                          'amount': controllers[1].text,
                          'cost': controllers[0].text,
                          'assignedOrders': [],
                        });
                      }
                    }

                    debugPrint('mapsOfOrders: $mapsOfOrders');

                    debugPrint('removed: $toBeRemoved');

                    mainDatabase.addOrderer(newOrderer, orders,
                        changedOrders: mapsOfOrders,
                        removedOrders: toBeRemoved);

                    debugPrint('updated');
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    return;
                  } else {
                    final newOrderer = Orderer()
                      ..name = nameController.text
                      // ..idNumber = idNumberController.text
                      ..phoneNumber = phoneController.text;

                    List<Order> orders = [];

                    // check for new orders and changed orders and update the mapsOfOrders
                    for (var controllers in _listTileData) {
                      final newOrder = Order()
                        ..title = controllers[2].text
                        ..amount = int.parse(controllers[1].text)
                        ..cost = double.parse(controllers[0].text)
                        ..author.value = newOrderer;

                      orders.add(newOrder);
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
                  autofocus: true,
                  focusNode: nameFocus,
                  onSubmitted: (value) {
                    nameFocus.unfocus();
                    FocusScope.of(context).requestFocus(phoneFocus);
                  },
                  controller: nameController,
                  // fill in the name if orderer is not null
                  decoration: const InputDecoration(
                      hintText: "الإسم", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              // TextField(
              //     focusNode: idNumberFocus,
              //     onSubmitted: (value) {
              //       idNumberFocus.unfocus();
              //       FocusScope.of(context).requestFocus(phoneFocus);
              //     },
              //     controller: idNumberController,
              //     keyboardType: TextInputType.number,
              //     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              //     decoration: const InputDecoration(
              //         hintText: "رقم الهوية", border: OutlineInputBorder())),
              // const SizedBox(height: 10),
              TextField(
                  focusNode: phoneFocus,
                  onSubmitted: (value) => phoneFocus.unfocus(),
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 5, left: 2, right: 2),
                      child: ThreeTextFields(
                          focusNodes: _focusNodes,
                          index: index,
                          update: widget.orderer != null,
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
      _focusNodes.add([
        FocusNode(),
        FocusNode(),
        FocusNode(),
      ]);
    });
  }

  void _deleteListTile(int index) {
    setState(() {
      _listTileData.removeAt(index);
      _focusNodes.removeAt(index);
      // get the map of the order to be removed
      if (widget.orderer != null) {
        // check if mapsOfOrders has the index
        if (mapsOfOrders.length - 1 >= index) {
          if (mapsOfOrders[index]['id'] != null) {
            toBeRemoved.add(mapsOfOrders[index]);
          }
        }
      }
    });
  }
}

class ThreeTextFields extends StatelessWidget {
  final TextEditingController controller1;
  final TextEditingController controller2;
  final TextEditingController controller3;
  final void Function()? delete;
  final bool update;
  final List<List<FocusNode>> focusNodes;
  final int index;

  const ThreeTextFields(
      {super.key,
      required this.focusNodes,
      required this.index,
      required this.update,
      required this.controller1,
      required this.controller2,
      required this.controller3,
      required this.delete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        update && controller3.text.isNotEmpty
            ? SizedBox(
                width: 100,
                child: Text(
                  controller3.text,
                  softWrap: true,
                  overflow: TextOverflow.fade,
                ))
            : SizedBox(
                width: 100,
                child: TextField(
                  focusNode: focusNodes[index][0],
                  onSubmitted: (value) {
                    focusNodes[index][0].unfocus();
                    FocusScope.of(context).requestFocus(focusNodes[index][1]);
                  },
                  decoration: const InputDecoration(
                      hintText: "العمل", border: OutlineInputBorder()),
                  controller: controller3,
                ),
              ),
        const SizedBox(width: 5.0),
        SizedBox(
          width: 80,
          child: TextField(
            focusNode: focusNodes[index][1],
            onSubmitted: (value) {
              focusNodes[index][1].unfocus();
              FocusScope.of(context).requestFocus(focusNodes[index][2]);
            },
            textAlign: TextAlign.center,
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
            focusNode: focusNodes[index][2],
            onSubmitted: (value) {
              // check if their is a next field to focus on
              debugPrint("${focusNodes.length - 1 > 2}");
              if (focusNodes.length > index + 1) {
                focusNodes[index][2].unfocus();
                FocusScope.of(context).requestFocus(focusNodes[index + 1][1]);
              } else {
                // make a new listTile
                focusNodes[index][2].unfocus();
                FocusScope.of(context).requestFocus(focusNodes.first[1]);
              }
            },
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

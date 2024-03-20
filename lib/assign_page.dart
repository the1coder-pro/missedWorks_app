import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:missed_works_app/details_page.dart';
import 'package:missed_works_app/prefs.dart';
import 'package:provider/provider.dart';
import 'assigned_order.dart';
import 'order.dart';
import 'orderer.dart';
import 'recipient.dart';

class AssignPage extends StatefulWidget {
  const AssignPage({super.key});

  @override
  State<AssignPage> createState() => _AssignPageState();
}

class _AssignPageState extends State<AssignPage> {
  final List<Item> _items = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  List<DropdownMenuItem<Recipient>> recipients = [];

  Recipient? _recipient;

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
    var mainDatabase = context.read<MainDatabase>();

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
        ..recipient.value = nameController.text.isNotEmpty
            ? newRecipient
            : _recipient ?? newRecipient;

      orders.add(newOrder);
      debugPrint(newOrder.order.value!.title);
    }

    mainDatabase.saveDataAfterAddingRecipient(
        nameController.text.isNotEmpty
            ? newRecipient
            : _recipient ?? newRecipient,
        orders);
  }

  // get the list of recipients
  List<DropdownMenuItem<Recipient>> getRecipients() {
    List<DropdownMenuItem<Recipient>> items = [];
    for (var recipient in context.read<MainDatabase>().currentRecipients) {
      items.add(DropdownMenuItem(
        alignment: Alignment.center,
        value: recipient,
        child:
            Center(child: Text("${recipient.name} (${recipient.phoneNumber})")),
      ));
    }
    return items;
  }

  @override
  void initState() {
    recipients = getRecipients();
    if (recipients.isNotEmpty) {
      _recipient = recipients.first.value;
    }
    addItem();
    super.initState();
  }

  void deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<MainDatabase>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                if (nameController.text.isEmpty && _recipient == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("يجب إضافة مستلم أولاً")));
                  return;
                } else {
                  // check the items if amounts or costs are higher than the original
                  for (var item in _items) {
                    if (item.text2.isNotEmpty && item.text1.isNotEmpty) {
                      if (item.value!.amount! < int.parse(item.text1)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            content: Text(
                              "الكمية المدخلة أكبر من الكمية المتبقية",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onError),
                            )));
                        return;
                      }

                      if (item.value!.cost! < double.parse(item.text2)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            content: Text(
                              "السعر المدخل أكبر من السعر المتبقي",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onError),
                            )));
                        return;
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          content: Text(
                            "يجب ملئ الكمية والسعر",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onError),
                          )));
                      return;
                    }
                  }
                  saveData();
                }

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
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                    border: TableBorder.all(
                        color: Theme.of(context).colorScheme.onBackground,
                        borderRadius: BorderRadius.circular(5)),
                    columnWidths: const {
                      0: FlexColumnWidth(0.5),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                          children: const [
                            TableCell(
                                child: Center(
                                    child: Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              child: Text("#"),
                            ))),
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Center(child: Text('العمل'))),
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Center(child: Text('الكمية'))),
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Center(child: Text('السعر'))),
                          ]),
                      ...db.currentOrdererUnasssignedOrders.indexed
                          .map((order) => TableRow(children: [
                                TableCell(
                                    child: Center(
                                        child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Text((order.$1 + 1).toString()),
                                ))),
                                TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 5, left: 5),
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(order.$2.title)),
                                    )),
                                TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Center(
                                        child:
                                            Text(order.$2.amount.toString()))),
                                TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 5, left: 5),
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              "${order.$2.cost!.removeTrailingZero()} ريال")),
                                    )),
                              ]))
                    ]),
              ),
              const SizedBox(height: 20),
              ExpansionTile(
                title: const Text("إضافة مستلم"),
                children: [
                  const SizedBox(height: 5),
                  TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          hintText: "الإسم", border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(
                      controller: idNumberController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          hintText: "رقم الهوية",
                          border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(
                      controller: phoneController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          hintText: "رقم الهاتف",
                          border: OutlineInputBorder())),
                  const SizedBox(height: 20)
                ],
              ),
              const SizedBox(height: 10),
              if (recipients.isNotEmpty)
                Center(
                  child: DropdownButtonFormField<Recipient>(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5))),
                    alignment: Alignment.center,
                    style: TextStyle(
                        fontFamily: "Rubik",
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onBackground),
                    hint: const Text('اختر المستلم'),
                    items: recipients,
                    value: _recipient,
                    onChanged: (value) {
                      debugPrint(value!.name);
                      setState(() {
                        _recipient = value;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 10),
              MyListTile(
                  orderer: db.currentOrderer!,
                  item: _items[0],
                  onChanged: (value, text1, text2) {
                    setState(() {
                      _items[0] =
                          Item(value: value, text1: text1, text2: text2);
                    });
                  }),
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
    final db = context.read<MainDatabase>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              LimitedBox(
                maxWidth: 250,
                child: DropdownButtonFormField<Order>(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5))),
                  value: _selectedValue,
                  style: const TextStyle(fontFamily: "Rubik", fontSize: 15),
                  hint: const Text('اختر العمل'),
                  items: db.currentOrdererUnasssignedOrders.map((Order value) {
                    return DropdownMenuItem<Order>(
                      alignment: Alignment.center,
                      value: value,
                      child: Text(
                        value.title,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
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
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  controller: _text1Controller,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      hintText: 'الكمية', border: OutlineInputBorder()),
                  onChanged: (text) => widget.onChanged(
                      _selectedValue, text, _text2Controller.text),
                ),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: _text2Controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
              hintText: 'السعر', border: OutlineInputBorder()),
          onChanged: (text) =>
              widget.onChanged(_selectedValue, _text1Controller.text, text),
        )
      ],
    );
  }
}

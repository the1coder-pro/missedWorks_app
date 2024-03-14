import 'package:flutter/material.dart';
import 'package:missed_works_app/prefs.dart';
import 'package:missed_works_app/recipient_details.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'assign_page.dart';
import 'assigned_order.dart';
import 'order.dart';
import 'orderer.dart';
import 'register.dart';

// details page with currentOrderer from mainDatabase
class DetailsPage extends StatefulWidget {
  final Orderer? orderer;
  const DetailsPage({this.orderer, super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<Order> orders = [];
  List<Order> remainingOrders = [];
  List<AssignedOrder> assignedOrders = [];

  void fetchData() {
    final mainDatabase = context.read<MainDatabase>();
    if (widget.orderer != null) {
      mainDatabase
          .fetchOrderer(widget.orderer!.id!)
          .then((value) => setState(() {
                debugPrint(assignedOrders.toString());
              }));
    } else {
      mainDatabase
          .fetchOrderer(mainDatabase.currentOrderer!.id!)
          .then((value) => setState(() {
                debugPrint(assignedOrders.toString());
              }));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainDatabase>(
        builder: (context, db, _) => Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                  appBar: AppBar(
                    actions: [
                      IconButton(
                          onPressed: () {
                            db.deleteOrdererWithOrders(db.currentOrderer!);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.delete_outline)),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage(
                                        orderer: db.currentOrderer)));
                          },
                          icon: const Icon(Icons.edit_outlined))
                    ],
                  ),
                  body: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView(children: [
                        Text(db.currentOrderer!.name,
                            softWrap: true,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(fontSize: 40)),
                        const SizedBox(height: 10),
                        ListTile(
                          title: Text(db.currentOrderer!.idNumber.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          subtitle:
                              Text(db.currentOrderer!.phoneNumber.toString()),
                          trailing: IconButton(
                              style: ButtonStyle(
                                  elevation: const MaterialStatePropertyAll(10),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                                  iconColor: MaterialStatePropertyAll(
                                      Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer)),
                              icon: const Icon(Icons.phone_outlined),
                              onPressed: () {}),
                        ),
                        const Divider(thickness: 2),
                        const SizedBox(height: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("جميع الأعمال",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontSize: 25,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )),
                            const SizedBox(height: 20),
                            Center(
                              child: DataTable(
                                  border: TableBorder.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      borderRadius: BorderRadius.circular(5)),
                                  headingRowHeight: 45,
                                  columns: ['العمل', 'الكمية', 'السعر']
                                      .map((title) => DataColumn(
                                          label: Center(
                                              child: Text(title,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)))))
                                      .toList(),
                                  rows: db.currentOrderer!.orders
                                      .map((order) => DataRow(cells: [
                                            DataCell(Center(
                                                child: Text(order.title))),
                                            DataCell(Center(
                                                child: Text(
                                                    order.amount.toString()))),
                                            DataCell(Center(
                                                child: Text(
                                                    order.cost.toString()))),
                                          ]))
                                      .toList()),
                            ),
                            // unassigned orders
                            const SizedBox(height: 20),
                            Visibility(
                              visible:
                                  db.currentOrdererUnasssignedOrders.isNotEmpty,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("الأعمال المتبقية",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                            fontSize: 25,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          )),
                                  Center(
                                    child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('العمل')),
                                          DataColumn(label: Text('الكمية')),
                                          DataColumn(label: Text('السعر')),
                                        ],
                                        rows: db.currentOrdererUnasssignedOrders
                                            .map((order) => DataRow(cells: [
                                                  DataCell(Text(order.title)),
                                                  DataCell(Text(
                                                      order.amount.toString())),
                                                  DataCell(Text(
                                                      order.cost.toString())),
                                                ]))
                                            .toList()),
                                  ),
                                ],
                              ),
                            ),
                            // assigned orders
                            Visibility(
                              visible:
                                  db.currentOrdererAssignedOrders.isNotEmpty,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("الأعمال المستلمة",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              fontSize: 25,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            )),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Center(
                                        child: DataTable(
                                            columns: const [
                                              DataColumn(label: Text("#")),
                                              DataColumn(
                                                  label: Text('المستلم')),
                                              DataColumn(
                                                  label: Text('العنوان')),
                                              DataColumn(label: Text('الكمية')),
                                              DataColumn(label: Text('السعر')),
                                            ],
                                            rows: db
                                                .currentOrdererAssignedOrders
                                                .reversed
                                                .indexed
                                                .map((order) => DataRow(cells: [
                                                      DataCell(Text(
                                                          (order.$1 + 1)
                                                              .toString())),
                                                      DataCell(
                                                          Text(order.$2.recipient.value!.name,
                                                              style: TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Theme.of(context)
                                                                      .colorScheme
                                                                      .primary)),
                                                          onTap: () => Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                  type: PageTransitionType
                                                                      .rightToLeft,
                                                                  child: RecipientDetailsPage(order
                                                                      .$2
                                                                      .recipient
                                                                      .value!)))),
                                                      DataCell(Text(order.$2
                                                          .order.value!.title)),
                                                      DataCell(Text(order
                                                          .$2.amount
                                                          .toString())),
                                                      DataCell(Text(order
                                                          .$2.cost
                                                          .toString())),
                                                    ]))
                                                .toList()),
                                      ),
                                    ),
                                  ]),
                            ),
                            if (db.currentOrdererUnasssignedOrders.isEmpty &&
                                orders.isNotEmpty)
                              const Center(
                                child: Column(
                                  children: [
                                    AlertDialog(
                                      icon: Icon(Icons.check_outlined),
                                      title: Text("انتهت"),
                                      content: Center(
                                        child: Text(
                                            "تم الإنتهاء من جميع الأعمال مسجلة."),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ],
                        ),
                        const SizedBox(height: 70),
                      ])),
                  floatingActionButton: Visibility(
                      visible: db.currentOrdererUnasssignedOrders.isNotEmpty,
                      child: FloatingActionButton(
                        elevation: 2,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AssignPage()));
                        },
                        child: const Icon(Icons.person_add_alt_1_outlined),
                      ))),
            ));
  }
}

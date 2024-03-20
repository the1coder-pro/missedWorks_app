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
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart';

extension BeautifyDouble on double {
  String removeTrailingZero() {
    return toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
  }
}

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
    return Consumer<MainDatabase>(builder: (context, db, _) {
      if (db.currentOrderer == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: Text("لا يوجد مستفيد محدد"),
          ),
        );
      }
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  icon:
                                      const Icon(Icons.warning_amber_outlined),
                                  title:
                                      const Center(child: Text("تأكيد الحذف")),
                                  content: Text(
                                      "هل تريد حذف المستفيد ${db.currentOrderer!.name}؟"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("إلغاء")),
                                    FilledButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);

                                          db.deleteOrdererWithOrders(
                                              db.currentOrderer!);
                                          db.currentOrderer = null;
                                        },
                                        child: const Text("حذف")),
                                  ],
                                ),
                              ));
                    },
                    icon: const Icon(Icons.delete_outline)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RegisterPage(orderer: db.currentOrderer)));
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
                    subtitle: Text(db.currentOrderer!.phoneNumber.toString()),
                    trailing: IconButton(
                        style: ButtonStyle(
                            elevation: const MaterialStatePropertyAll(10),
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.primaryContainer),
                            iconColor: MaterialStatePropertyAll(
                                Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer)),
                        icon: const Icon(Icons.phone_outlined),
                        onPressed: () async {
                          // phone button

                          Uri url = Uri.parse(
                              'tel:${db.currentOrderer!.phoneNumber}');

                          if (!await launchUrl(url)) {
                            throw Exception('Could not launch $url');
                          }
                        }),
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
                                color: Theme.of(context).colorScheme.primary,
                              )),
                      const SizedBox(height: 10),
                      Table(
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
                            ...db.currentOrderer!.orders.indexed.map((order) =>
                                TableRow(children: [
                                  TableCell(
                                      child: Center(
                                          child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5),
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
                                          child: Text(
                                              order.$2.amount.toString()))),
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

                      // unassigned orders
                      const SizedBox(height: 20),

                      Visibility(
                        visible: db.currentOrdererUnasssignedOrders.isNotEmpty,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("الأعمال المتبقية",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontSize: 25,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )),
                            const SizedBox(height: 10),
                            Table(
                                border: TableBorder.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
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
                                          padding: EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: Text("#"),
                                        ))),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child:
                                                Center(child: Text('العمل'))),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child:
                                                Center(child: Text('الكمية'))),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child:
                                                Center(child: Text('السعر'))),
                                      ]),
                                  ...db.currentOrdererUnasssignedOrders.indexed
                                      .map((order) => TableRow(children: [
                                            TableCell(
                                                child: Center(
                                                    child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Text(
                                                  (order.$1 + 1).toString()),
                                            ))),
                                            TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5, left: 5),
                                                  child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child:
                                                          Text(order.$2.title)),
                                                )),
                                            TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Center(
                                                    child: Text(order.$2.amount
                                                        .toString()))),
                                            TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5, left: 5),
                                                  child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                          "${order.$2.cost!.removeTrailingZero()} ريال")),
                                                )),
                                          ]))
                                ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // assigned orders
                      Visibility(
                        visible: db.currentOrdererAssignedOrders.isNotEmpty,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Center(
                                  child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text("#")),
                                        DataColumn(label: Text('العمل')),
                                        DataColumn(label: Text('المستلم')),
                                        DataColumn(
                                            label: Text("تاريخ الإستلام",
                                                style: TextStyle(
                                                    letterSpacing: 0))),
                                        DataColumn(label: Text('الكمية')),
                                        DataColumn(label: Text('السعر')),
                                      ],
                                      rows: db
                                          .currentOrdererAssignedOrders.indexed
                                          .map((order) => DataRow(cells: [
                                                DataCell(Text(
                                                    (order.$1 + 1).toString())),
                                                DataCell(Text(order
                                                    .$2.order.value!.title)),
                                                DataCell(
                                                    Text(order.$2.recipient.value!.name,
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Theme.of(context)
                                                                    .colorScheme
                                                                    .primary)),
                                                    onTap: () => Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type:
                                                                PageTransitionType
                                                                    .rightToLeft,
                                                            child: RecipientDetailsPage(
                                                                order
                                                                    .$2
                                                                    .recipient
                                                                    .value!)))),
                                                DataCell(Text(intl.DateFormat(
                                                        'dd/MM/yyyy')
                                                    .format(order.$2.date!))),
                                                DataCell(Text(order.$2.amount
                                                    .toString())),
                                                DataCell(Text(order.$2.cost
                                                    .removeTrailingZero())),
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
                        PageTransition(
                            child: const AssignPage(),
                            type: PageTransitionType.bottomToTop));
                  },
                  child: const Icon(Icons.person_add_alt_1_outlined),
                ))),
      );
    });
  }
}

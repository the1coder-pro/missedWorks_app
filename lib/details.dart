import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:missed_works_app/assigned_order.dart';
import 'package:missed_works_app/orderer.dart';

import 'assign_page.dart';
import 'package:intl/intl.dart' as intl;

import 'order.dart';

class DetailsPage extends StatefulWidget {
  final Orderer orderer;
  final Isar isar;
  const DetailsPage(this.orderer, {super.key, required this.isar});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<AssignedOrder> assignedOrders = [];
  // List<AssignedOrder> sortedAssignedOrders = [];

  List<AssignedOrder> getAllAssignedOrders() {
    List<AssignedOrder> assignedOrders = [];
    for (var order in widget.orderer.orders) {
      for (var assignedOrder in order.assignedOrders) {
        assignedOrders.add(assignedOrder);
      }
    }
    debugPrint("after added");
    for (var order in assignedOrders) {
      debugPrint(
          "${order.order.value!.title} - ${order.recipient.value!.name}");
    }
    assignedOrders.sort(
        (a, b) => a.recipient.value!.name.compareTo(b.recipient.value!.name));
    return assignedOrders;
  }

  var unselectedOrders = <Order>[];

  // check every assignedOrder if it's amount and cost equal to the order if yes make new Order but with the remaining amount and cost
  List<Order> getAllUnselectedOrders() {
    List<Order> unselectedOrders = [];
    for (var order in widget.orderer.orders) {
      for (var assignedOrder in order.assignedOrders) {
        if (assignedOrder.amount < order.amount!) {
          final newOrder = Order()
            ..title = order.title
            ..amount = order.amount! - assignedOrder.amount
            ..cost = order.cost! - assignedOrder.cost
            ..author.value = order.author.value;
          unselectedOrders.add(newOrder);
        }
      }
    }
    return unselectedOrders;
  }

  @override
  void initState() {
    assignedOrders = getAllAssignedOrders();
    unselectedOrders = getAllUnselectedOrders();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Center(
                  child: Text(widget.orderer.name,
                      style: Theme.of(context).textTheme.displayLarge)),
              const SizedBox(height: 10),
              Text("جميع الأعمال",
                  style: Theme.of(context).textTheme.displaySmall),
              DataTable(
                  columns: const [
                    DataColumn(label: Text("#")),
                    DataColumn(label: Text("العمل")),
                    DataColumn(label: Text("العدد")),
                    DataColumn(label: Text("المبلغ"))
                  ],
                  rows: widget.orderer.orders.indexed
                      .map((order) => DataRow(cells: [
                            DataCell(Text((order.$1 + 1).toString())),
                            DataCell(Text(order.$2.title.toString())),
                            DataCell(Text(order.$2.amount.toString())),
                            DataCell(Text(order.$2.cost.toString())),
                          ]))
                      .toList()),
              const SizedBox(height: 10),
              Visibility(
                visible: unselectedOrders.isNotEmpty,
                child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyList(widget.orderer, isar: widget.isar)));
                    },
                    child: const Text("تسليم عمل")),
              ),
              const SizedBox(height: 10),
              Text("الأعمال المستلمة",
                  style: Theme.of(context).textTheme.displaySmall),
              DataTable(
                  columns: const [
                    DataColumn(label: Text("العمل")),
                    DataColumn(label: Text("العدد")),
                    DataColumn(label: Text("المبلغ")),
                    DataColumn(label: Text("المستلم")),
                    DataColumn(label: Text("التاريخ"))
                  ],
                  rows: assignedOrders
                      .map((order) => DataRow(cells: [
                            DataCell(Text(order.order.value!.title)),
                            DataCell(Text(order.amount.toString())),
                            DataCell(Text(order.cost.toString())),
                            DataCell(Text(order.recipient.value!.name)),
                            DataCell(Text(intl.DateFormat("dd/MM/yyyy")
                                .format(order.date!)))
                          ]))
                      .toList()),
              Text("الأعمال المتبقية",
                  style: Theme.of(context).textTheme.displaySmall),
              DataTable(
                  columns: const [
                    DataColumn(label: Text("العمل")),
                    DataColumn(label: Text("العدد")),
                    DataColumn(label: Text("المبلغ")),
                  ],
                  rows: unselectedOrders
                      .map((order) => DataRow(cells: [
                            DataCell(Text(order.title)),
                            DataCell(Text(order.amount.toString())),
                            DataCell(Text(order.cost.toString())),
                          ]))
                      .toList()),
            ],
          ),
        ),
      ),
    );
  }
}

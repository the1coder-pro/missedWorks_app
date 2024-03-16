import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'assigned_order.dart';
import 'details_page.dart';
import 'prefs.dart';
import 'recipient.dart';
import 'package:intl/intl.dart' as intl;

class RecipientDetailsPage extends StatefulWidget {
  final Recipient recipient;
  const RecipientDetailsPage(this.recipient, {super.key});

  @override
  State<RecipientDetailsPage> createState() => _RecipientDetailsPageState();
}

class _RecipientDetailsPageState extends State<RecipientDetailsPage> {
  List<AssignedOrder> assignedOrders = [];

  void fetchData() {
    final mainDatabase = context.read<MainDatabase>();
    mainDatabase
        .getAllAssignedOrdersOfRecipient(widget.recipient)
        .then((value) => setState(() {
              assignedOrders = value;
              debugPrint(assignedOrders.toString());
            }));
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              Text(widget.recipient.name,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(fontSize: 45)),
              const SizedBox(height: 10),
              ListTile(
                title: Text(widget.recipient.idNumber.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                subtitle: Text(widget.recipient.phoneNumber.toString()),
                trailing: IconButton(
                    style: ButtonStyle(
                        elevation: const MaterialStatePropertyAll(10),
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.primaryContainer),
                        iconColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.onPrimaryContainer)),
                    icon: const Icon(Icons.phone_outlined),
                    onPressed: () {}),
              ),
              const Divider(thickness: 2),
              if (assignedOrders.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(columns: const [
                    DataColumn(label: Text("#")),
                    DataColumn(label: Text("العمل")),
                    DataColumn(label: Text("المستفيد")),
                    DataColumn(
                        label: Text("تاريخ الإستلام",
                            style: TextStyle(letterSpacing: 0))),
                    DataColumn(label: Text("الكمية")),
                    DataColumn(label: Text("السعر")),
                  ], rows: [
                    for (var i = 0; i < assignedOrders.length; i++)
                      DataRow(cells: [
                        DataCell(Text((i + 1).toString())),
                        DataCell(Text(assignedOrders[i].order.value!.title)),
                        DataCell(
                            onTap: () => Navigator.push(
                                context,
                                PageTransition(
                                    child: DetailsPage(
                                        orderer: assignedOrders[i]
                                            .order
                                            .value!
                                            .author
                                            .value!),
                                    type: PageTransitionType
                                        .rightToLeftWithFade)),
                            Text(
                                assignedOrders[i]
                                    .order
                                    .value!
                                    .author
                                    .value!
                                    .name,
                                style: TextStyle(
                                    // underlined,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary))),
                        DataCell(Text(intl.DateFormat('dd/MM/yyyy')
                            .format(assignedOrders[i].date!))),
                        DataCell(Text(assignedOrders[i].amount.toString())),
                        DataCell(Text(assignedOrders[i].cost.toString())),
                      ])
                  ]),
                )
              else
                const Center(child: Text("لا توجد أعمال مسجلة"))
              // Expanded(
              //   flex: 2,
              //   child: StreamBuilder<List<AssignedOrder>>(
              //     stream: MainDatabase.isar.assignedOrders
              //         .where()
              //         .filter()
              //         .recipient((q) => q.idEqualTo(widget.recipient.id))
              //         .watch(fireImmediately: true),
              //     builder: (_, snapshot) {
              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return const Center(child: CircularProgressIndicator());
              //       } else {
              //         if (snapshot.data!.isEmpty) {
              //           return const Center(child: Text("لا توجد أعمال مسجلة."));
              //         }

              //         return SingleChildScrollView(
              //           scrollDirection: Axis.horizontal,
              //           child: DataTable(columns: const [
              //             DataColumn(label: Text("العمل")),
              //             DataColumn(label: Text("المستفيد")),
              //             DataColumn(label: Text("التاريخ")),
              //             DataColumn(label: Text("الكمية")),
              //             DataColumn(label: Text("السعر")),
              //           ], rows: [
              //             for (var assignedOrder in snapshot.data!)
              //               DataRow(cells: [
              //                 DataCell(Text(assignedOrder.order.value!.title)),
              //                 DataCell(Text(
              //                     assignedOrder.order.value!.author.value!.name)),
              //                 DataCell(Text(intl.DateFormat('dd/MM/yyyy')
              //                     .format(assignedOrder.date!))),
              //                 DataCell(Text(assignedOrder.amount.toString())),
              //                 DataCell(Text(assignedOrder.cost.toString())),
              //               ])
              //           ]),
              //         );

              //         // return ListView.builder(
              //         //   itemCount: snapshot.data!.length,
              //         //   itemBuilder: (context, index) {
              //         //     AssignedOrder assignedOrder = snapshot.data![index];
              //         //     return ListTile(
              //         //       title: Text(assignedOrder.order.value!.title),
              //         //       subtitle: Text(
              //         //           "${assignedOrder.order.value!.author.value!.name} - ${intl.DateFormat('dd/MM/yyyy').format(assignedOrder.date!)}"),
              //         //       trailing: Text(assignedOrder.amount.toString()),
              //         //     );
              //         //   },
              //         // );
              //       }
              //     },
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:missed_works_app/register_recipients.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final mainDatabase = context.read<MainDatabase>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              icon: const Icon(Icons.warning_amber_outlined),
                              title: const Center(child: Text("تأكيد الحذف")),
                              content: Text(
                                  "هل تريد حذف المستفيد ${widget.recipient.name}؟"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("إلغاء")),
                                FilledButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      mainDatabase
                                          .deleteRecipient(widget.recipient);
                                    },
                                    child: const Text("حذف")),
                              ],
                            ),
                          ));
                }),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegisterRecipients(recipient: widget.recipient)));
                },
                icon: const Icon(Icons.edit_outlined))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              Text(widget.recipient.name,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(fontSize: 30)),
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
                    onPressed: () async {
                      Uri url =
                          Uri.parse('tel:${widget.recipient.phoneNumber}');

                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                    }),
              ),
              const Divider(thickness: 2),
              if (assignedOrders.isNotEmpty)
                for (var i = 0; i < assignedOrders.length; i++)
                  if (assignedOrders[i].order.value != null)
                    ExpansionTile(
                        title: Text(
                            "${assignedOrders[i].order.value!.author.value!.name} (${assignedOrders[i].order.value!.title})"),
                        subtitle: Text(intl.DateFormat('dd/MM/yyyy')
                            .format(assignedOrders[i].date!)),
                        children: [
                          ListTile(
                            trailing: IconButton(
                                icon: const Icon(Icons.account_circle_outlined),
                                onPressed: () => Navigator.push(
                                    context,
                                    PageTransition(
                                        child: DetailsPage(
                                            orderer: assignedOrders[i]
                                                .order
                                                .value!
                                                .author
                                                .value!),
                                        type: PageTransitionType.rightToLeft))),
                            title: const Text("المستفيد"),
                            subtitle: Text(assignedOrders[i]
                                .order
                                .value!
                                .author
                                .value!
                                .name),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 150,
                                child: ListTile(
                                  title: const Text("تاريخ الإستلام"),
                                  subtitle: Text(intl.DateFormat('dd/MM/yyyy')
                                      .format(assignedOrders[i].date!)),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: ListTile(
                                  title: const Text("العمل"),
                                  subtitle: Text(
                                      assignedOrders[i].order.value!.title),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 150,
                                child: ListTile(
                                  title: const Text("الكمية"),
                                  subtitle:
                                      Text(assignedOrders[i].amount.toString()),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: ListTile(
                                  title: const Text("السعر"),
                                  subtitle: Text(assignedOrders[i]
                                      .cost
                                      .removeTrailingZero()
                                      .toString()),
                                ),
                              ),
                            ],
                          ),
                        ])
                  else
                    Container()
              else
                const Center(child: Text("لا توجد أعمال مسجلة"))
            ],
          ),
        ),
      ),
    );
  }
}

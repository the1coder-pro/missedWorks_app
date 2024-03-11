import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:missed_works_app/assigned_order.dart';
import 'package:missed_works_app/order.dart';
import 'package:missed_works_app/orderer.dart';
import 'package:missed_works_app/recipient.dart';
import 'package:path_provider/path_provider.dart';

import 'details.dart';
import 'register.dart';
import 'package:intl/intl.dart' as intl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();

  final isar = await Isar.open(
      [OrdererSchema, OrderSchema, AssignedOrderSchema, RecipientSchema],
      directory: dir.path, inspector: true);

  runApp(MyApp(isar: isar));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق الأعمال النيابيية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          useMaterial3: true),
      home: MyHomePage(isar: isar),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.isar});

  final Isar isar;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedPage = 0;

  String selectedPageTitle(int selectedPage) {
    switch (selectedPage) {
      case 0:
        return "الأعمال النيابيية";
      case 1:
        return "مستلمين الأعمال";
      case 2:
        return "الإعدادات";
      default:
        return "الأعمال النيابيية";
    }
  }

  Widget pageSelector(BuildContext context, int page) {
    switch (page) {
      case 0:
        return FirstSection(widget: widget);
      case 1:
        return SecondSection(widget: widget);
      default:
        return FirstSection(widget: widget);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(selectedPageTitle(selectedPage)),
        ),
        body: pageSelector(context, selectedPage),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'الأعمال النيابيية',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt),
                title: const Text('التسجيل'),
                onTap: () {
                  setState(() {
                    selectedPage = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_outlined),
                title: const Text('العاملين'),
                onTap: () {
                  setState(() {
                    selectedPage = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('الأعدادات'),
                onTap: () {
                  setState(() {
                    selectedPage = 2;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RegisterPage(isar: widget.isar)));
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class FirstSection extends StatelessWidget {
  const FirstSection({
    super.key,
    required this.widget,
  });

  final MyHomePage widget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Orderer>>(
      stream: widget.isar.orderers.where().watch(fireImmediately: true),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          debugPrint(snapshot.hasData.toString());
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد أعمال مسجلة."));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Orderer orderer = snapshot.data!.reversed.toList()[index];
              // make listtile look better and avatar
              return ListTile(
                title: Text(orderer.name),
                leading: CircleAvatar(
                  child: Text(orderer.name[0]),
                ),
                subtitle: Text(orderer.idNumber.toString()),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailsPage(orderer, isar: widget.isar)));
                },
              );
            },
          );
        }
      },
    );
  }
}

class SecondSection extends StatelessWidget {
  const SecondSection({
    super.key,
    required this.widget,
  });

  final MyHomePage widget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Recipient>>(
      stream: widget.isar.recipients.where().watch(fireImmediately: true),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Recipient recipient = snapshot.data!.reversed.toList()[index];
              return ListTile(
                title: Text(recipient.name),
                // ontap show the orders assigned to the recipient in table
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecipientDetailsPage(recipient,
                              isar: widget.isar)));
                },

                subtitle: Text(recipient.phoneNumber.toString()),
              );
            },
          );
        }
      },
    );
  }
}

class RecipientDetailsPage extends StatefulWidget {
  final Recipient recipient;
  final Isar isar;
  const RecipientDetailsPage(this.recipient, {super.key, required this.isar});

  @override
  State<RecipientDetailsPage> createState() => _RecipientDetailsPageState();
}

class _RecipientDetailsPageState extends State<RecipientDetailsPage> {
  // get all assigned orders to the recipient
  List<AssignedOrder> assignedOrders = [];
  Future<List<AssignedOrder>> getAllAssignedOrders() async {
    final assignedOrders = await widget.isar.assignedOrders
        .where()
        .filter()
        .recipient((q) => q.idEqualTo(widget.recipient.id))
        .findAll();
    return assignedOrders;
  }

  @override
  void initState() {
    getAllAssignedOrders().then((value) => assignedOrders = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recipient.name),
        ),
        body: StreamBuilder<List<AssignedOrder>>(
          stream: widget.isar.assignedOrders
              .where()
              .filter()
              .recipient((q) => q.idEqualTo(widget.recipient.id))
              .watch(fireImmediately: true),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text("لا توجد أعمال مسجلة."));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  AssignedOrder assignedOrder = snapshot.data![index];
                  return ListTile(
                    title: Text(assignedOrder.order.value!.title),
                    subtitle: Text(
                        "${assignedOrder.order.value!.author.value!.name} - ${intl.DateFormat('dd/MM/yyyy').format(assignedOrder.date!)}"),
                    trailing: Text(assignedOrder.amount.toString()),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

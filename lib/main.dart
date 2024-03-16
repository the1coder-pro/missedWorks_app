import 'package:flutter/material.dart';
import 'package:missed_works_app/orderer.dart';
import 'package:missed_works_app/recipient.dart';
import 'package:missed_works_app/register.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'details_page.dart';
import 'prefs.dart';
import 'recipient_details.dart';
import 'register_recipients.dart';
import 'search_widget.dart';
import 'package:page_transition/page_transition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MainDatabase.init();

  runApp(ChangeNotifierProvider(
      create: (context) => MainDatabase(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'تطبيق الأعمال النيابيية',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
              inputDecorationTheme: InputDecorationTheme(
                  hintStyle: const TextStyle(fontFamily: "Rubik", fontSize: 15),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none)),
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                    fontFamily: "Scheherazade",
                    fontSize: 127,
                    fontWeight: FontWeight.w300),
                displayMedium: TextStyle(
                    fontFamily: "Scheherazade",
                    fontSize: 79,
                    fontWeight: FontWeight.w300),
                displaySmall: TextStyle(
                    fontFamily: "Scheherazade",
                    fontSize: 63,
                    fontWeight: FontWeight.w400),
                headlineMedium: TextStyle(
                    fontFamily: "Scheherazade",
                    fontSize: 45,
                    fontWeight: FontWeight.w400),
                headlineSmall: TextStyle(
                    fontFamily: "Scheherazade",
                    fontSize: 32,
                    fontWeight: FontWeight.w400),
                titleLarge: TextStyle(
                    fontFamily: "Scheherazade",
                    fontSize: 26,
                    fontWeight: FontWeight.w500),
                titleMedium: TextStyle(
                    fontFamily: "Scheherazade",
                    fontSize: 21,
                    fontWeight: FontWeight.w400),
                titleSmall: TextStyle(
                    fontFamily: "Scheherazade",
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
                bodyLarge: TextStyle(
                    fontFamily: "Rubik",
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
                bodyMedium: TextStyle(
                    fontFamily: "Rubik",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
                labelLarge: TextStyle(
                    fontFamily: "Rubik",
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                bodySmall: TextStyle(
                    fontFamily: "Rubik",
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
                labelSmall: TextStyle(
                    fontFamily: "Rubik",
                    fontSize: 10,
                    fontWeight: FontWeight.w400),
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.lightGreen,
                brightness:
                    themeProvider.isDark ? Brightness.dark : Brightness.light,
              ),
              useMaterial3: true),
          home: const MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedPage = 0;

  void fetchAllData() {
    context.read<MainDatabase>().fetchOrderers();
    context.read<MainDatabase>().fetchRecipients();
  }

  @override
  void initState() {
    super.initState();

    fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    final mainDatabase = context.watch<MainDatabase>();

    List<Orderer> currentOrderers = mainDatabase.currentOrderers;
    List<Recipient> currentRecipients = mainDatabase.currentRecipients;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              labelStyle: const TextStyle(fontFamily: "Rubik"),
              onTap: (value) {
                setState(() {
                  selectedPage = value;
                });
              },
              tabs: const [
                Tab(
                  icon: Icon(Icons.assignment_outlined),
                  text: "التسجيل",
                ),
                Tab(
                  icon: Icon(Icons.people_outlined),
                  text: "مستلمين الأعمال",
                ),
              ],
            ),
            leading: IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: const SettingsSection(),
                          type: PageTransitionType.rightToLeft));
                }),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.background,
            title: const Text(
              "الأعمال النيابيية",
              style: TextStyle(fontSize: 24),
            ),
            actions: [
              if (selectedPage != 2)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (selectedPage == 0) {
                      showSearch(
                          context: context,
                          delegate: OrdererSearch(currentOrderers));
                    }
                    if (selectedPage == 1) {
                      showSearch(
                          context: context,
                          delegate:
                              RecipientSearch(mainDatabase.currentRecipients));
                    }
                  },
                ),
            ],
          ),
          body: TabBarView(
            children: [
              if (currentOrderers.isNotEmpty)
                ListView.builder(
                    itemCount: currentOrderers.length,
                    itemBuilder: (context, index) {
                      Orderer orderer = currentOrderers[index];
                      return Slidable(
                        key: Key(orderer.id.toString()),
                        startActionPane: ActionPane(
                          // A motion is a widget used to control how the pane animates.
                          motion: const ScrollMotion(),

                          // A pane can dismiss the Slidable.
                          // dismissible: DismissiblePane(onDismissed: () {}),

                          // All actions are defined in the children parameter.
                          children: [
                            // A SlidableAction can have an icon and/or a label.
                            SlidableAction(
                              onPressed: (context) {
                                // delete
                                mainDatabase.deleteOrdererWithOrders(orderer);
                              },
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'حذف',
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                              child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(orderer.name[0],
                                style: const TextStyle(fontSize: 20)),
                          )),
                          title: Text(orderer.name),
                          subtitle: Text(orderer.phoneNumber.toString()),
                          onTap: () {
                            // set the orderer
                            mainDatabase.currentOrderer = orderer;
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: const DetailsPage()));
                          },
                        ),
                      );
                    })
              else
                const Center(child: Text("لا توجد مساعدات.")),
              if (currentRecipients.isNotEmpty)
                ListView.builder(
                  itemCount: currentRecipients.length,
                  itemBuilder: (context, index) {
                    Recipient recipient = currentRecipients[index];

                    return ListTile(
                      leading: CircleAvatar(
                          child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(recipient.name[0],
                            style: const TextStyle(fontSize: 20)),
                      )),
                      title: Text(recipient.name),
                      subtitle: Text(recipient.phoneNumber.toString()),
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: RecipientDetailsPage(recipient)));
                      },
                    );
                  },
                )
              else
                const Center(child: Text("لا يوجد مستلمين أعمال مسجلين."))
            ],
          ),
          floatingActionButton: selectedPage == 0
              ? FloatingActionButton(
                  elevation: 2,
                  onPressed: () async {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: const RegisterPage()));
                  },
                  child: const Icon(Icons.add),
                )
              : FloatingActionButton(
                  elevation: 2,
                  onPressed: () async {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: const RegisterRecipients()));
                  },
                  child: const Icon(Icons.person_add_alt_1_outlined),
                ),
        ),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    // dark mode
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("الإعدادات", style: TextStyle(fontSize: 24)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text("الوضع المظلم"),
              value: themeProvider.isDark,
              onChanged: (value) {
                themeProvider.updateTheme(value);
              },
            )
          ],
        ),
      ),
    );
  }
}

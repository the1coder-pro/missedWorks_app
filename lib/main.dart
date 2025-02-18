import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:missed_works_app/orderer.dart';
import 'package:missed_works_app/recipient.dart';
import 'package:missed_works_app/register.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'details_page.dart';
import 'prefs.dart';
import 'recipient_details.dart';
import 'register_recipients.dart';
import 'search_widget.dart';
import 'package:page_transition/page_transition.dart';

String APPVERSION = '1.0.2';

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
                seedColor: Colors.lightGreen.shade400,
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

extension ColorToHex on Color {
  String get toHex {
    return "#${value.toRadixString(16).substring(2)}";
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
            leading: PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.settings_outlined),
                          Spacer(),
                          Text('الإعدادات'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: const SettingsSection(),
                                type: PageTransitionType.rightToLeft));
                      }),
                ];
              },
            ),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: const Text(
              "الأعمال النيابيية",
              style: TextStyle(fontSize: 24),
            ),
            actions: [
              if (selectedPage != 2)
                mainDatabase.currentOrderers.isNotEmpty
                    ? IconButton(
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
                                delegate: RecipientSearch(
                                    mainDatabase.currentRecipients));
                          }
                        },
                      )
                    : const SizedBox(),
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
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                                icon: Icons.edit_outlined,
                                label: 'تعديل',
                                onPressed: (value) {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.bottomToTop,
                                          child:
                                              RegisterPage(orderer: orderer)));
                                }),
                            SlidableAction(
                              onPressed: (context) {
                                showDialog(
                                    context: context,
                                    builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: AlertDialog(
                                            icon: const Icon(
                                                Icons.warning_amber_outlined),
                                            title: const Center(
                                                child: Text("تأكيد الحذف")),
                                            content: Text(
                                                "هل تريد حذف المستفيد ${orderer.name}؟"),
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
                                                        .deleteOrdererWithOrders(
                                                            orderer);
                                                  },
                                                  child: const Text("حذف")),
                                            ],
                                          ),
                                        ));
                              },
                              backgroundColor:
                                  Theme.of(context).colorScheme.errorContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                              icon: Icons.delete_outline,
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                        height: 300, width: 300, child: SvgPicture.string('''
                <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1080px" height="1080px" style="shape-rendering:geometricPrecision; text-rendering:geometricPrecision; image-rendering:optimizeQuality; fill-rule:evenodd; clip-rule:evenodd" xmlns:xlink="http://www.w3.org/1999/xlink">
                <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.surface).toHex}" d="M -0.5,-0.5 C 359.5,-0.5 719.5,-0.5 1079.5,-0.5C 1079.5,359.5 1079.5,719.5 1079.5,1079.5C 719.5,1079.5 359.5,1079.5 -0.5,1079.5C -0.5,719.5 -0.5,359.5 -0.5,-0.5 Z"/></g>
                      <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 954.5,579.5 C 955.492,587.316 955.826,595.316 955.5,603.5C 840.184,669.826 724.851,736.159 609.5,802.5C 423.707,695.435 238.041,588.102 52.5,480.5C 51.1667,472.5 51.1667,464.5 52.5,456.5C 56.0608,458.779 59.7274,460.779 63.5,462.5C 63.56,463.043 63.8933,463.376 64.5,463.5C 65.4909,459.555 65.8242,455.555 65.5,451.5C 180.24,385.379 295.074,319.379 410,253.5C 444.698,268.733 480.531,280.566 517.5,289C 561.181,302.506 601.181,322.839 637.5,350C 653.058,362.39 666.724,376.557 678.5,392.5C 724.36,403.263 767.694,420.429 808.5,444C 821.729,452.561 834.396,461.895 846.5,472C 865.5,492.333 884.5,512.667 903.5,533C 918.059,545.556 933.726,556.556 950.5,566C 950,566.5 949.5,567 949,567.5C 948.171,572.533 948.338,577.533 949.5,582.5C 951.36,581.74 953.027,580.74 954.5,579.5 Z"/></g>
                      <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.surface).toHex}" d="M 408.5,258.5 C 437.662,270.832 467.662,280.665 498.5,288C 552.283,302.057 600.616,326.39 643.5,361C 654.067,370.897 663.9,381.397 673,392.5C 673.667,393.167 673.667,393.833 673,394.5C 561,459.167 449,523.833 337,588.5C 307.649,551.897 271.483,524.064 228.5,505C 193.577,489.803 157.577,477.803 120.5,469C 105.189,464.119 90.1889,458.452 75.5,452C 186.563,387.473 297.563,322.973 408.5,258.5 Z"/></g>
                      <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.surface).toHex}" d="M 676.5,397.5 C 727.147,407.987 774.147,427.153 817.5,455C 840.584,470.75 860.418,489.917 877,512.5C 895.825,533.668 917.325,551.501 941.5,566C 829.749,630.96 717.915,695.793 606,760.5C 573.011,741.486 545.344,716.486 523,685.5C 486.451,648.958 443.618,622.124 394.5,605C 378.17,599.67 361.837,594.504 345.5,589.5C 456.06,525.726 566.393,461.726 676.5,397.5 Z"/></g>
                      <g><path style="opacity:1" fill="#9d9d9d" d="M 65.5,451.5 C 65.8242,455.555 65.4909,459.555 64.5,463.5C 63.8933,463.376 63.56,463.043 63.5,462.5C 64.1667,458.833 64.8333,455.167 65.5,451.5 Z"/></g>
                      <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.surface).toHex}" d="M 69.5,454.5 C 102.449,468.74 136.449,479.907 171.5,488C 222.501,502.823 267.834,527.49 307.5,562C 316.747,571.243 325.247,581.076 333,591.5C 333.667,600.5 333.667,609.5 333,618.5C 245.582,567.874 158.082,517.374 70.5,467C 69.5363,462.934 69.203,458.767 69.5,454.5 Z"/></g>
                      <g><path style="opacity:1" fill="#8b8b8b" d="M 942.5,571.5 C 942.56,570.957 942.893,570.624 943.5,570.5C 944.814,575.652 944.814,580.652 943.5,585.5C 943.819,580.637 943.486,575.97 942.5,571.5 Z"/></g>
                      <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.surface).toHex}" d="M 942.5,571.5 C 943.486,575.97 943.819,580.637 943.5,585.5C 832.625,650.192 721.459,714.526 610,778.5C 519.208,726.526 428.708,674.192 338.5,621.5C 338.173,611.985 338.506,602.652 339.5,593.5C 399.747,606.794 453.747,632.628 501.5,671C 515.147,683.306 527.314,696.806 538,711.5C 557.788,733.306 580.454,751.306 606,765.5C 717.977,700.431 830.143,635.764 942.5,571.5 Z"/></g>
                      <g><path style="opacity:1" fill="#969696" d="M 954.5,579.5 C 954.56,578.957 954.893,578.624 955.5,578.5C 956.821,586.991 956.821,595.324 955.5,603.5C 955.826,595.316 955.492,587.316 954.5,579.5 Z"/></g>
                      <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 339.5,593.5 C 338.506,602.652 338.173,611.985 338.5,621.5C 337.177,611.992 337.177,602.325 338.5,592.5C 339.107,592.624 339.44,592.957 339.5,593.5 Z"/></g>
                      <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 1008.5,654.5 C 1014.18,654.334 1019.84,654.501 1025.5,655C 1026.02,655.561 1026.36,656.228 1026.5,657C 1019.95,669.555 1010.61,679.555 998.5,687C 921.167,731.667 843.833,776.333 766.5,821C 757.216,826.987 750.049,825.153 745,815.5C 742.72,807.565 745.22,801.731 752.5,798C 829.833,753.333 907.167,708.667 984.5,664C 992.186,659.722 1000.19,656.556 1008.5,654.5 Z"/></g>
                      </svg>
                          ''')),
                    const Center(
                        child: Text("لا يوجد مستفيدين مسجلين.",
                            style: TextStyle(fontSize: 20))),
                  ],
                ),
              if (currentRecipients.isNotEmpty)
                ListView.builder(
                  itemCount: currentRecipients.length,
                  itemBuilder: (context, index) {
                    Recipient recipient = currentRecipients[index];

                    return Slidable(
                      key: Key(recipient.id.toString()),
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                              icon: Icons.edit_outlined,
                              label: 'تعديل',
                              onPressed: (value) {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.bottomToTop,
                                        child: RegisterRecipients(
                                            recipient: recipient)));
                              }),
                          SlidableAction(
                            onPressed: (context) {
                              showDialog(
                                  context: context,
                                  builder: (context) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: AlertDialog(
                                          icon: const Icon(
                                              Icons.warning_amber_outlined),
                                          title: const Center(
                                              child: Text("تأكيد الحذف")),
                                          content: Text(
                                              "هل تريد حذف المستفيد ${recipient.name}؟"),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("إلغاء")),
                                            FilledButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  mainDatabase.deleteRecipient(
                                                      recipient);
                                                },
                                                child: const Text("حذف")),
                                          ],
                                        ),
                                      ));
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            foregroundColor:
                                Theme.of(context).colorScheme.onErrorContainer,
                            icon: Icons.delete_outline,
                            label: 'حذف',
                          ),
                        ],
                      ),
                      child: ListTile(
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
                      ),
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
                            child: RegisterRecipients()));
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("الإعدادات", style: TextStyle(fontSize: 24)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("الوضع المظلم"),
              value: themeProvider.isDark,
              onChanged: (value) {
                themeProvider.updateTheme(value);
              },
            ),
            const SizedBox(height: 20),

            // make a button to open play store to update the app
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text("الذهاب الى المتجر"),
              onTap: () async {
                // open play store
                Uri url = Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.orange.missed_works_app');

                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            const SizedBox(height: 20),
            // version of app
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("الإصدار $APPVERSION",
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

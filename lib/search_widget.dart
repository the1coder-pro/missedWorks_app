import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:missed_works_app/prefs.dart';
import 'package:missed_works_app/recipient_details.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'details_page.dart';
import 'orderer.dart';
import 'recipient.dart';

extension ColorToHex on Color {
  String get toHex {
    return "#${value.toRadixString(16).substring(2)}";
  }
}

// search delegate for orderers
class OrdererSearch extends SearchDelegate<String> {
  final List<Orderer> orderers;
  @override
  String get searchFieldLabel => "البحث";

  OrdererSearch(this.orderers);

  // appbar theme
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);

    return theme.copyWith(
      primaryColor: theme.scaffoldBackgroundColor,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final mainDatabase = context.read<MainDatabase>();

    final results = orderers
        .where((orderer) =>
            orderer.name.contains(query) ||
            orderer.phoneNumber.toString().contains(query))
        .toList();
    if (results.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child:
                  SizedBox(height: 250, width: 250, child: SvgPicture.string('''
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1080px" height="1080px" style="shape-rendering:geometricPrecision; text-rendering:geometricPrecision; image-rendering:optimizeQuality; fill-rule:evenodd; clip-rule:evenodd" xmlns:xlink="http://www.w3.org/1999/xlink">
<g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.surface).toHex}" d="M -0.5,-0.5 C 359.5,-0.5 719.5,-0.5 1079.5,-0.5C 1079.5,359.5 1079.5,719.5 1079.5,1079.5C 719.5,1079.5 359.5,1079.5 -0.5,1079.5C -0.5,719.5 -0.5,359.5 -0.5,-0.5 Z"/></g>
<g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 407.5,161.5 C 491.506,158.427 562.006,187.427 619,248.5C 682.355,325.928 698.022,412.261 666,507.5C 654.361,537.765 637.861,564.932 616.5,589C 710.667,683.167 804.833,777.333 899,871.5C 909.269,887.334 907.102,901.168 892.5,913C 881.607,919.202 870.941,918.869 860.5,912C 765.5,817 670.5,722 575.5,627C 574.5,626.333 573.5,626.333 572.5,627C 515.5,665.404 452.833,679.738 384.5,670C 303.644,654.032 242.811,610.532 202,539.5C 169.331,476.143 162.664,410.143 182,341.5C 210.25,259.583 265.083,203.75 346.5,174C 366.528,167.738 386.861,163.571 407.5,161.5 Z"/></g>
<g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.surface).toHex}" d="M 405.5,216.5 C 491.354,212.171 556.854,246.171 602,318.5C 631.427,374.032 635.427,431.365 614,490.5C 584.157,559.995 531.99,601.828 457.5,616C 372.409,625.526 305.576,595.36 257,525.5C 226.615,475.685 218.281,422.351 232,365.5C 254.049,293.117 301.216,245.617 373.5,223C 384.235,220.476 394.902,218.31 405.5,216.5 Z"/></g>
<g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.surface).toHex}" d="M 460.5,252.5 C 530.363,263.83 576.196,303.497 598,371.5C 612.609,436.661 595.943,492.328 548,538.5C 582.941,489.899 593.274,436.232 579,377.5C 561.159,315.162 521.659,273.496 460.5,252.5 Z"/></g>
</svg>
'''))),
          const Center(child: Text("لا يوجد نتائج")),
        ],
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          Orderer orderer = results[index];

          return ListTile(
            leading: CircleAvatar(
                child: Align(
              alignment: Alignment.topCenter,
              child:
                  Text(orderer.name[0], style: const TextStyle(fontSize: 20)),
            )),
            title: Text(orderer.name),
            subtitle: Text(orderer.phoneNumber.toString()),
            onTap: () {
              mainDatabase.currentOrderer = orderer;

              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.bottomToTop,
                      child: const DetailsPage()));
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final mainDatabase = context.read<MainDatabase>();
    final results = orderers
        .where((orderer) =>
            orderer.name.contains(query) ||
            orderer.phoneNumber.toString().contains(query))
        .toList();
    if (results.isEmpty) {
      return const Center(child: Text("لا يوجد نتائج"));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          Orderer orderer = results[index];

          return ListTile(
            title: Text(results[index].name),
            onTap: () {
              // query = results[index].name;
              // showResults(context);
              mainDatabase.currentOrderer = orderer;

              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.bottomToTop,
                      child: const DetailsPage()));
            },
          );
        },
      ),
    );
  }
}

// search delegate for recipients
class RecipientSearch extends SearchDelegate<String> {
  final List<Recipient> recipients;
  @override
  String get searchFieldLabel => "البحث";

  RecipientSearch(this.recipients);

  // appbar theme
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: theme.scaffoldBackgroundColor,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = recipients
        .where((recipient) =>
            recipient.name.contains(query) ||
            recipient.phoneNumber.toString().contains(query))
        .toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          Recipient recipient = results[index];

          return ListTile(
            leading: CircleAvatar(
                child: Text(recipient.name[0],
                    style: const TextStyle(fontSize: 20))),
            title: Text(recipient.name),
            subtitle: Text(recipient.phoneNumber.toString()),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.bottomToTop,
                      child: RecipientDetailsPage(recipient)));
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = recipients
        .where((recipient) =>
            recipient.name.contains(query) ||
            recipient.phoneNumber.toString().contains(query))
        .toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(results[index].name),
            onTap: () {
              Recipient recipient = results[index];
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.bottomToTop,
                      child: RecipientDetailsPage(recipient)));
            },
          );
        },
      ),
    );
  }
}

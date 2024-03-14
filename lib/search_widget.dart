import 'package:flutter/material.dart';
import 'package:missed_works_app/prefs.dart';
import 'package:missed_works_app/recipient_details.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'details_page.dart';
import 'orderer.dart';
import 'recipient.dart';

// search delegate for orderers
class OrdererSearch extends SearchDelegate<String> {
  final List<Orderer> orderers;
  @override
  String get searchFieldLabel => "البحث";
  // change the alignment of hint to the center

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

    final results =
        orderers.where((orderer) => orderer.name.contains(query)).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          Orderer orderer = results[index];

          return ListTile(
            leading: CircleAvatar(
                child: Text(orderer.name[0],
                    style: const TextStyle(fontSize: 20))),
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
    final results =
        orderers.where((orderer) => orderer.name.contains(query)).toList();
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
        .where((recipient) => recipient.name.contains(query))
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
        .where((recipient) => recipient.name.contains(query))
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

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'details.dart';
import 'orderer.dart';

// search delegate for orderers
class OrdererSearch extends SearchDelegate<String> {
  final List<Orderer> orderers;
  final Isar isar;

  OrdererSearch(this.orderers, this.isar);

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
    final results =
        orderers.where((orderer) => orderer.name.contains(query)).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(results[index].name),
            onTap: () {
              Orderer orderer = results[index];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(orderer, isar: isar)));
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results =
        orderers.where((orderer) => orderer.name.contains(query)).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(results[index].name),
            onTap: () {
              // query = results[index].name;
              // showResults(context);
              Orderer orderer = results[index];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(orderer, isar: isar)));
            },
          );
        },
      ),
    );
  }
}

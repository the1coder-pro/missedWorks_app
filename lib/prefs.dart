import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:missed_works_app/assigned_order.dart';
import 'package:missed_works_app/order.dart';
import 'package:missed_works_app/orderer.dart';
import 'package:missed_works_app/recipient.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void updateTheme(bool isDark) {
    _isDark = isDark;
    notifyListeners();
  }
}

class MainDatabase extends ChangeNotifier {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
        [OrdererSchema, RecipientSchema, OrderSchema, AssignedOrderSchema],
        directory: dir.path);
  }

  final List<Orderer> currentOrderers = [];

  List<Order> getAllUnselectedOrders(Orderer currentOrderer) {
    List<Order> unselectedOrders = [];
    for (var order in currentOrderer.orders) {
      var assignedOrders = order.assignedOrders;
      double totalAssignedCost = 0;
      var totalAssignedAmount = 0;
      for (var assignedOrder in assignedOrders) {
        totalAssignedAmount += assignedOrder.amount;
        totalAssignedCost += assignedOrder.cost;
      }
      if (totalAssignedAmount < order.amount!) {
        var unselectedOrder = Order()
          ..id = order.id
          ..title = order.title
          ..amount = order.amount! - totalAssignedAmount
          ..cost = order.cost! - totalAssignedCost
          ..author.value = order.author.value;
        unselectedOrders.add(unselectedOrder);
      }
    }
    return unselectedOrders;
  }

  // get all assigned Orders
  List<AssignedOrder> getAllAssignedOrders(Orderer currentOrderer) {
    List<AssignedOrder> assignedOrders = [];
    for (var order in currentOrderer.orders) {
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

  // current Orderer
  Orderer? currentOrderer;
  List<Order> currentOrdererUnasssignedOrders = [];
  List<AssignedOrder> currentOrdererAssignedOrders = [];

  // fetch data of orderer
  Future<void> fetchOrderer(int id) async {
    Orderer? fetchedOrderer =
        await isar.orderers.where().idEqualTo(id).findFirst();
    if (fetchedOrderer != null) {
      await fetchedOrderer.orders.load();
    }

    currentOrderer = fetchedOrderer;
    currentOrdererAssignedOrders = getAllAssignedOrders(fetchedOrderer!);
    currentOrdererUnasssignedOrders = getAllUnselectedOrders(fetchedOrderer);

    notifyListeners();
  }

  // add orderer
  Future<void> addOrderer(Orderer orderer, List<Order> orders) async {
    await isar.writeTxn(() async {
      // check if orderer is there
      if (orderer.id == null) {
        await isar.orderers.put(orderer);
        for (var order in orders) {
          await isar.orders.put(order);
          await order.author.save();
        }
      } else {
        // make a variable for the orders and assigned orders
        List<Order> ordersOfOrderer = orderer.orders.toList();
        List<AssignedOrder> assignedOrders = [];
        for (var order in ordersOfOrderer) {
          await order.assignedOrders.load();
          assignedOrders.addAll(order.assignedOrders);
        }
        await isar.orders
            .filter()
            .author((q) => q.idEqualTo(orderer.id))
            .deleteAll();
        // remove assigned orders of order
        await isar.assignedOrders
            .filter()
            .order((q) => q.author((q) => q.idEqualTo(orderer.id)))
            .deleteAll();

        await isar.orderers.put(orderer);

        // check what is different between the orders and orders of the orderer and add them to the list of updated orders
        List<Order> updatedOrders = [];
        for (var order in orders) {
          if (ordersOfOrderer.contains(order)) {
            updatedOrders.add(order);
          } else {
            updatedOrders.add(order);
          }
        }

        for (var order in updatedOrders) {
          if (order.id != null) {
            await isar.orders.put(order);
            await order.author.save();
            for (var assignedOrder in assignedOrders) {
              if (assignedOrder.order.value!.id == order.id) {
                await isar.assignedOrders.put(assignedOrder);
                await assignedOrder.order.save();
              }
            }
          } else {
            await isar.orders.put(order);
            await order.author.save();
          }
        }
      }
    });

    await fetchOrderers();
    await fetchOrderer(orderer.id!);
  }

  // delete orderer with his orders and assigned orders
  Future<void> deleteOrdererWithOrders(Orderer orderer) async {
    await isar.writeTxn(() async {
      for (var order in orderer.orders) {
        await isar.assignedOrders
            .filter()
            .order((q) => q.idEqualTo(order.id))
            .deleteAll();
      }
      await isar.orders
          .filter()
          .author((q) => q.idEqualTo(orderer.id))
          .deleteAll();
      await isar.orderers.delete(orderer.id!);
    });

    await fetchOrderers();
  }

  Future<void> fetchOrderers() async {
    List<Orderer> fetchedOrderers = await isar.orderers.where().findAll();
    currentOrderers.clear();
    currentOrderers.addAll(fetchedOrderers);
    notifyListeners();
  }

  // fetch orderer with its orders
  Future<Orderer?> fetchOrdererWithOrders(int id) async {
    Orderer? orderer = await isar.orderers.where().idEqualTo(id).findFirst();
    if (orderer != null) {
      await orderer.orders.load();
    }
    return orderer;
  }

  List<Recipient> currentRecipients = [];
  // fetch recipients
  Future<void> fetchRecipients() async {
    List<Recipient> fetchedRecipients = await isar.recipients.where().findAll();
    currentRecipients.clear();
    currentRecipients.addAll(fetchedRecipients);

    notifyListeners();
  }

  Future<void> addRecipientOrUpdate(Recipient recipient,
      {List<AssignedOrder>? assignedOrders}) async {
    if (recipient.id == null) {
      await isar.writeTxn(() async {
        await isar.recipients.put(recipient);
        if (assignedOrders != null) {
          await isar.assignedOrders.putAll(assignedOrders);
        }
      });
    } else {
      await isar.writeTxn(() async {
        await isar.recipients.put(recipient);
        if (assignedOrders != null) {
          await isar.assignedOrders.putAll(assignedOrders);
        }
      });
    }
    await fetchRecipients();
  }

  // update the recipient
  Future<void> updateRecipient(Recipient recipient) async {
    await isar.writeTxn(() async {
      await isar.recipients.put(recipient);
    });

    await fetchRecipients();
  }

  // delete the recipient
  Future<void> deleteRecipient(Recipient recipient) async {
    await isar.writeTxn(() async {
      await isar.recipients.delete(recipient.id!);
    });

    await fetchRecipients();
  }

  // addOrder and its assigned orders
  Future<void> addOrder(Order order, List<AssignedOrder> assignedOrders) async {
    final newOrder = order;

    await isar.writeTxn(() async {
      await isar.orders.put(newOrder);
      await isar.assignedOrders.putAll(assignedOrders);
    });

    await fetchOrders();
  }

  Future<void> saveDataAfterAddingRecipient(
      Recipient recipient, List<AssignedOrder> assignedOrders) async {
    await isar.writeTxn(() async {
      await isar.recipients.put(recipient);
      recipient.assignedOrders.addAll(assignedOrders);
      for (var order in assignedOrders) {
        debugPrint(order.order.value!.title);
        await isar.assignedOrders.put(order);
        recipient.assignedOrders.add(order);

        await order.order.save();
        await order.recipient.save();
        await recipient.assignedOrders.save();
      }
    });
    await fetchRecipients();
    await fetchOrderer(currentOrderer!.id!);
    // await fetchOrders();
    notifyListeners();
  }

  //fetch orders
  List<Order> currentOrders = [];
  Future<void> fetchOrders() async {
    List<Order> fetchedOrders = await isar.orders.where().findAll();
    currentOrders.clear();
    currentOrders.addAll(fetchedOrders);
    notifyListeners();
  }

  // fetch assignedOrders
  List<AssignedOrder> currentAssignedOrders = [];
  Future<void> fetchAssignedOrders() async {
    List<AssignedOrder> fetchedAssignedOrders =
        await isar.assignedOrders.where().findAll();
    currentAssignedOrders.clear();
    currentAssignedOrders.addAll(fetchedAssignedOrders);
    notifyListeners();
  }

  Future<List<AssignedOrder>> getAllAssignedOrdersOfRecipient(
      Recipient recipient) async {
    final assignedOrders = await isar.assignedOrders
        .where()
        .filter()
        .recipient((q) => q.idEqualTo(recipient.id))
        .findAll();
    debugPrint(assignedOrders.toString());
    return assignedOrders;
  }

  // delete the order
  Future<void> deleteOrder(Order order) async {
    await isar.writeTxn(() async {
      await isar.assignedOrders
          .deleteAll(order.assignedOrders.map((e) => e.id!).toList());
      await isar.orders.delete(order.id!);
    });

    await fetchOrders();
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(InventoryApp());
}

class InventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InventoryHomePage(title: 'Inventory Home Page'),
    );
  }
}

class InventoryItem {
  final String id;
  final String name;
  final String details;

  InventoryItem({
    required this.id,
    required this.name,
    required this.details,
  });

  factory InventoryItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      details: data.containsKey('details') ? data['details'] as String : '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'details': details,
    };
  }
}

class InventoryHomePage extends StatefulWidget {
  final String title;
  const InventoryHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<InventoryItem> items = (snapshot.data?.docs ?? [])
              .map((doc) => InventoryItem.fromDocument(doc))
              .toList();
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final InventoryItem item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('Details: ${item.details}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditItemDialog(item);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteItem(item);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog() {
    String? itemName;
    String? itemDetails;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Item Name"),
                onChanged: (value) {
                  itemName = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Details"),
                onChanged: (value) {
                  itemDetails = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () {
                if (itemName != null &&
                    itemName!.isNotEmpty &&
                    itemDetails != null &&
                    itemDetails!.isNotEmpty) {
                  itemsCollection.add({
                    'name': itemName,
                    'details': itemDetails,
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(InventoryItem item) {
    String updatedName = item.name;
    String updatedDetails = item.details;
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: item.name);
        final detailsController = TextEditingController(text: item.details);
        return AlertDialog(
          title: const Text("Edit Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Item Name"),
                controller: nameController,
                onChanged: (value) {
                  updatedName = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Details"),
                controller: detailsController,
                onChanged: (value) {
                  updatedDetails = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Update"),
              onPressed: () {
                itemsCollection.doc(item.id).update({
                  'name': updatedName,
                  'details': updatedDetails,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(InventoryItem item) {
    itemsCollection.doc(item.id).delete();
  }
}

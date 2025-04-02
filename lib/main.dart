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
    return InventoryItem(
      id: doc.id,
      name: doc.get('name'),
      details: doc.get('details'),
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
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}

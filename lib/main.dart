import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Firestore Test Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Funkcja do dodania testowego wpisu do Firestore
  void _addTestMessage() async {
    await firestore.collection('test').add({'message': 'Hello Firebase!', 'timestamp': DateTime.now()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Przycisk dodający testowy wpis do Firestore
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addTestMessage,
              child: const Text('Dodaj testowy wpis do Firestore'),
            ),
          ),
          // Lista wyświetlająca dane z Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('test').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Brak danych w Firestore'));
                }
                var docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['message'] ?? 'Brak wiadomości'),
                      subtitle: Text(data['timestamp'] != null
                          ? data['timestamp'].toDate().toString()
                          : 'Brak daty'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

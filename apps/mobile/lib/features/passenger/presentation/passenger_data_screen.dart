import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PassengerDataScreen extends StatelessWidget {
  const PassengerDataScreen({required this.collection, required this.title, super.key});
  final String collection;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Unable to load $title: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return Center(child: Text('No $title available yet.'));
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data();
              return ListTile(
                leading: const Icon(Icons.directions_bus_outlined),
                title: Text(data['name'] as String? ?? data['routeName'] as String? ?? doc.id),
                subtitle: Text(data['description'] as String? ?? data['departureTime'] as String? ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}

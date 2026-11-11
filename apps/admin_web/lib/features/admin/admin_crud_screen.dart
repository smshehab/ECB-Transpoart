import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminCrudScreen extends StatefulWidget {
  const AdminCrudScreen({required this.collection, required this.title, super.key});
  final String collection;
  final String title;

  @override
  State<AdminCrudScreen> createState() => _AdminCrudScreenState();
}

class _AdminCrudScreenState extends State<AdminCrudScreen> {
  final _name = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  Future<void> _edit(DocumentSnapshot<Map<String, dynamic>> document) async {
    final controller = TextEditingController(text: document.data()?['name'] as String? ?? '');
    final value = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: Text('Edit ${widget.title.toLowerCase()}'),
      content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save'))],
    ));
    if (value == null || value.isEmpty) { controller.dispose(); return; }
    try {
      await document.reference.update({'name': value, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $error')));
    } finally { controller.dispose(); }
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection(widget.collection).add({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _name.clear();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [Expanded(child: TextField(controller: _name, decoration: InputDecoration(labelText: 'New ${widget.title.toLowerCase()} name'))), const SizedBox(width: 8), FilledButton(onPressed: _saving ? null : _create, child: const Text('Add'))]),
      const SizedBox(height: 16),
      Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(widget.collection).orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Access denied or query failed: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return Center(child: Text('No ${widget.title.toLowerCase()} created yet.'));
          return ListView.builder(itemCount: snapshot.data!.docs.length, itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return Card(child: ListTile(
              title: Text(doc.data()['name'] as String? ?? doc.id),
              subtitle: Text(doc.id),
              trailing: Wrap(children: [
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(doc)),
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
                try { await doc.reference.delete(); }
                catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $error'))); }
              }),
              ]),
            ));
          });
        },
      )),
    ]);
  }
}

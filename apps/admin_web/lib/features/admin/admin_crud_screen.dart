import 'dart:convert';

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
  final _details = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _name.dispose(); _details.dispose(); super.dispose(); }

  Map<String, dynamic> _parseDetails(String value) {
    final decoded = jsonDecode(value.trim().isEmpty ? '{}' : value);
    if (decoded is! Map) throw const FormatException('Additional fields must be a JSON object.');
    final fields = Map<String, dynamic>.from(decoded);
    const reserved = {'name', 'createdAt', 'updatedAt'};
    if (fields.keys.any(reserved.contains)) throw const FormatException('Do not include name or timestamp fields in additional JSON.');
    return fields;
  }

  Future<void> _edit(DocumentSnapshot<Map<String, dynamic>> document) async {
    final data = Map<String, dynamic>.from(document.data() ?? {});
    final nameController = TextEditingController(text: data.remove('name') as String? ?? '');
    data.remove('createdAt');
    data.remove('updatedAt');
    final detailsController = TextEditingController(text: const JsonEncoder.withIndent('  ').convert(data));
    final saved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text('Edit ${widget.title.toLowerCase()}'),
      content: SizedBox(width: 460, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
        const SizedBox(height: 12),
        TextField(controller: detailsController, minLines: 3, maxLines: 8, decoration: const InputDecoration(labelText: 'Additional fields (JSON object)')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))],
    ));
    if (saved == true) {
      try {
        final name = nameController.text.trim();
        if (name.isEmpty) throw const FormatException('Name is required.');
        await document.reference.update({
          'name': name,
          ..._parseDetails(detailsController.text),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $error')));
      }
    }
    nameController.dispose();
    detailsController.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection(widget.collection).add({
        'name': name,
        ..._parseDetails(_details.text),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _name.clear();
      _details.clear();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _readOnly => widget.collection == 'users' || widget.collection == 'trips';

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!_readOnly) Row(children: [Expanded(child: TextField(controller: _name, decoration: InputDecoration(labelText: 'New ${widget.title.toLowerCase()} name'))), const SizedBox(width: 8), FilledButton(onPressed: _saving ? null : _create, child: const Text('Add'))]),
      if (_readOnly) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(widget.collection == 'users' ? 'User accounts are read-only here. Account provisioning and privileged role changes require a trusted administrative process.' : 'Trip monitoring is read-only. Drivers change their own trip status through the driver application.')),
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
              trailing: _readOnly ? null : Wrap(children: [
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

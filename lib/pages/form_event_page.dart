import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FormEventPage extends StatefulWidget {
  final String? eventId;
  final Map<String, dynamic>? existingData;

  const FormEventPage({super.key, this.eventId, this.existingData});

  @override
  State<FormEventPage> createState() => _FormEventPageState();
}

class _FormEventPageState extends State<FormEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _titleController.text = widget.existingData!['title'] ?? '';
      _descController.text = widget.existingData!['description'] ?? '';
      Timestamp? timestamp = widget.existingData!['timestamp'];
      if (timestamp != null) {
        _selectedDate = timestamp.toDate();
      }
    }
  }

  void saveEvent() async {
    final title = _titleController.text;
    final desc = _descController.text;

    if (title.isEmpty || desc.isEmpty) return;

    final data = {
      'title': title,
      'description': desc,
      'timestamp': Timestamp.fromDate(_selectedDate),
      'ownerId': user?.uid,
    };

    final collection = FirebaseFirestore.instance.collection('events');

    if (widget.eventId != null) {
      await collection.doc(widget.eventId).update(data);
    } else {
      await collection.add(data);
    }

    Navigator.pop(context);
  }

  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.eventId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Event' : 'Tambah Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul Event'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _selectDate,
                  child: const Text('Pilih Tanggal'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveEvent,
              child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Event'),
            ),
          ],
        ),
      ),
    );
  }
}

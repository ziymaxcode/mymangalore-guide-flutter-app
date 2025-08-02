import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Corrected import
//import 'package:firebase_core/firebase_core.dart';     // Added import

class EditPlacePage extends StatefulWidget {
  final Map<String, dynamic> place;

  const EditPlacePage({super.key, required this.place});

  @override
  EditPlacePageState createState() => EditPlacePageState();
}

class EditPlacePageState extends State<EditPlacePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _mapLinkController;
  late TextEditingController _imageUrlController;
  String? _selectedCategory;

  final List<String> _categories = ['Beaches', 'Malls', 'Restaurants', 'Cafes', 'Religious Places'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place['name']);
    _descriptionController = TextEditingController(text: widget.place['description']);
    _mapLinkController = TextEditingController(text: widget.place['mapLink']);
    _imageUrlController = TextEditingController(text: widget.place['image']);
    _selectedCategory = widget.place['category'];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('places').doc(widget.place['id']).update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'mapLink': _mapLinkController.text,
        'image': _imageUrlController.text,
        'category': _selectedCategory,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Place')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Place Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                 maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mapLinkController,
                decoration: const InputDecoration(labelText: 'Google Maps Link', border: OutlineInputBorder()),
                keyboardType: TextInputType.url,
                validator: (value) => value!.isEmpty ? 'Please enter a map link' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                keyboardType: TextInputType.url,
                validator: (value) => value!.isEmpty ? 'Please enter an image URL' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                hint: const Text('Select a Category'),
                onChanged: (value) => setState(() => _selectedCategory = value),
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
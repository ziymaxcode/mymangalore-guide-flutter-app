import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPlacePage extends StatefulWidget {
  final String? initialCategory;
  const AddPlacePage({super.key, this.initialCategory});

  @override
  _AddPlacePageState createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mapLinkController = TextEditingController();
  final _imageUrlController = TextEditingController(); // Renamed for clarity
  String? _selectedCategory;

  final List<String> _categories = ['Beaches', 'Malls', 'Restaurants', 'Cafes', 'Religious Places'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('places').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'mapLink': _mapLinkController.text,
        'image': _imageUrlController.text, // Use the direct URL from the form
        'category': _selectedCategory,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a New Place')),
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
              // MODIFIED: Asks for a direct image URL
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
                child: const Text('Submit Place', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
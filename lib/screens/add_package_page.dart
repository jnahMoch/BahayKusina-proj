import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPackagePage extends StatefulWidget {
  const AddPackagePage({
    super.key,
    this.initialTitle,
    this.initialCategory,
    this.initialPrice,
    this.initialStock,
    this.initialDesc,
  });

  final String? initialTitle;
  final String? initialCategory;
  final String? initialPrice;
  final String? initialStock;
  final String? initialDesc;

  @override
  State<AddPackagePage> createState() => _AddPackagePageState();
}

class _AddPackagePageState extends State<AddPackagePage> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late final _titleController = TextEditingController(text: widget.initialTitle);
  late final _priceController = TextEditingController(text: widget.initialPrice);
  late final _stockController = TextEditingController(text: widget.initialStock);
  late final _descController = TextEditingController(text: widget.initialDesc);
  late String _selectedCategory = widget.initialCategory ?? 'Breakfast';

  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Package", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveForm,
            child: const Text("Save", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Placeholder
              _buildImagePicker(),
              const SizedBox(height: 25),

              // 2. Title Field
              _buildLabel("Package Name"),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration("e.g. Ultimate Breakfast Package"),
                validator: (value) => value!.isEmpty ? "Please enter a name" : null,
              ),
              const SizedBox(height: 20),

              // 3. Category Dropdown
              _buildLabel("Category"),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration(""),
                items: ['Breakfast', 'Lunch', 'Dinner', 'Merienda', 'Dessert']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 20),

              // 4. Price and Stock Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Price (₱)"),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("0.00"),
                          validator: (value) => value!.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Initial Stock"),
                        TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("Qty"),
                          validator: (value) => value!.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Description
              _buildLabel("Description"),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _inputDecoration("What's inside the package?"),
              ),
              const SizedBox(height: 30),

              // 6. Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Publish Package", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text("Upload Package Photo", style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryOrange)),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you'd send this to a database
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Package Saved Successfully!")),
      );
      Navigator.pop(context);
    }
  }
}

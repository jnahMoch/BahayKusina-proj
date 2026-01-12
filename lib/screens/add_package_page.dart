// lib/screens/add_package_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../providers/local_package_provider.dart';
import '../models/meal_package.dart';

class AddPackagePage extends StatefulWidget {
  final String? packageId;
  final String? initialTitle;
  final String? initialCategory;
  final String? initialPrice;
  final String? initialStock;
  final String? initialDesc;
  final String? initialImageUrl;

  const AddPackagePage({
    super.key,
    this.packageId,
    this.initialTitle,
    this.initialCategory,
    this.initialPrice,
    this.initialStock,
    this.initialDesc,
    this.initialImageUrl,
  });

  @override
  State<AddPackagePage> createState() => _AddPackagePageState();
}

class _AddPackagePageState extends State<AddPackagePage> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late final _titleController = TextEditingController(
    text: widget.initialTitle,
  );
  late final _priceController = TextEditingController(
    text: widget.initialPrice ?? '',
  );
  late final _stockController = TextEditingController(
    text: widget.initialStock ?? '0',
  );
  late final _descController = TextEditingController(text: widget.initialDesc);
  late final _imageUrlController = TextEditingController(text: widget.initialImageUrl ?? '');
  late String _selectedCategory = widget.initialCategory ?? 'Lunch';

  // Package items list
  List<String> _packageItems = ['Item 1'];
  
  // Available for order toggle
  bool _isAvailableForOrder = true;

  bool _isSaving = false;

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    // Treat as editing only if we have a non-empty packageId that isn't a fallback
    final bool isEditing =
        widget.packageId != null &&
        widget.packageId!.isNotEmpty &&
        !widget.packageId!.startsWith('fallback_');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Spacer for centering
                    Text(
                      isEditing ? "Edit Package" : "Add New Package",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.grey.shade600, size: 24),
                    ),
                  ],
                ),
              ),
              
              // Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Package Name
                        _buildLabel("Package Name", required: true),
                        TextFormField(
                          controller: _titleController,
                          decoration: _inputDecoration("e.g., Ultimate Breakfast Package"),
                          validator: (value) =>
                              value!.isEmpty ? "Please enter a name" : null,
                        ),
                        const SizedBox(height: 16),

                        // 2. Description
                        _buildLabel("Description", required: true),
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: _inputDecoration("Describe your meal package"),
                        ),
                        const SizedBox(height: 16),

                        // 3. Price and Quantity Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Price (₱)", required: true),
                                  TextFormField(
                                    controller: _priceController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: _inputDecoration("0.00"),
                                    validator: (value) {
                                      if (value!.isEmpty) return "Required";
                                      try {
                                        double.parse(value);
                                        return null;
                                      } catch (e) {
                                        return "Invalid";
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Quantity Available", required: true),
                                  _buildQuantitySpinner(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 4. Category Dropdown
                        _buildLabel("Category", required: true),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _inputDecoration(""),
                          items: ['Breakfast', 'Lunch', 'Dinner', 'Merienda', 'Dessert']
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val!),
                        ),
                        const SizedBox(height: 16),

                        // 5. Image URL with Preview
                        _buildLabel("Image URL (optional)"),
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: _inputDecoration("https://..."),
                          keyboardType: TextInputType.url,
                          onChanged: (value) {
                            setState(() {}); // Refresh to show preview
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Leave blank for default image",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                        // Image Preview
                        if (_imageUrlController.text.trim().isNotEmpty &&
                            (_imageUrlController.text.trim().startsWith('http://') ||
                             _imageUrlController.text.trim().startsWith('https://'))) ...[
                          const SizedBox(height: 12),
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _imageUrlController.text.trim(),
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primaryOrange,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: Colors.red.shade300, size: 32),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Invalid URL",
                                        style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // 6. Package Items Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel("Package Items", required: true),
                            TextButton.icon(
                              onPressed: _addPackageItem,
                              icon: const Icon(Icons.add, size: 18, color: primaryOrange),
                              label: const Text(
                                "Add Item",
                                style: TextStyle(color: primaryOrange, fontWeight: FontWeight.w500),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._buildPackageItemsList(),
                        const SizedBox(height: 20),

                        // 7. Available for Order Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Available for Order",
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "Enable customers to order this package",
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isAvailableForOrder,
                                onChanged: (val) => setState(() => _isAvailableForOrder = val),
                                activeColor: primaryOrange,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 8. Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isEditing ? "Update Package" : "Add Package",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        
                        // Cancel button (only for new packages)
                        if (!isEditing) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Package Items Management
  void _addPackageItem() {
    setState(() {
      _packageItems.add('');
    });
  }

  void _removePackageItem(int index) {
    if (_packageItems.length > 1) {
      setState(() {
        _packageItems.removeAt(index);
      });
    }
  }

  void _updatePackageItem(int index, String value) {
    _packageItems[index] = value;
  }

  // Quantity Spinner Widget
  Widget _buildQuantitySpinner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "0",
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              validator: (value) {
                if (value!.isEmpty) return "Required";
                try {
                  int.parse(value);
                  return null;
                } catch (e) {
                  return "Invalid";
                }
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  int current = int.tryParse(_stockController.text) ?? 0;
                  setState(() {
                    _stockController.text = (current + 1).toString();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Icon(Icons.arrow_drop_up, size: 20, color: Colors.grey.shade600),
                ),
              ),
              InkWell(
                onTap: () {
                  int current = int.tryParse(_stockController.text) ?? 0;
                  if (current > 0) {
                    setState(() {
                      _stockController.text = (current - 1).toString();
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPackageItemsList() {
    return List.generate(_packageItems.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _packageItems[index],
                decoration: _inputDecoration(_packageItems[index].isEmpty ? "Item ${index + 1}" : ""),
                onChanged: (value) => _updatePackageItem(index, value),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removePackageItem(index),
              child: Icon(Icons.close, color: Colors.grey.shade400, size: 20),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontStyle: FontStyle.italic,
          ),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
    );
  }

  Future<void> _saveForm() async {
    print('✓ _saveForm called');

    if (!_formKey.currentState!.validate()) {
      print('✗ Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate numeric fields manually
    try {
      double.parse(_priceController.text);
      int.parse(_stockController.text);
    } catch (e) {
      print('✗ Invalid numeric values: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Price must be a valid number and Stock must be a whole number',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if title is empty
    if (_titleController.text.trim().isEmpty) {
      print('✗ Title is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Package name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Define variables outside try block so they're accessible in catch
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorId = authProvider.currentUser?.userId ?? 'vendor_nanay';
    final vendorName = authProvider.currentUser?.fullName ?? "Nanay's Kitchen";

    try {
      final mealPackage = MealPackage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedCategory,
        title: _titleController.text.trim(),
        vendor: vendorName,
        vendorId: vendorId,
        desc: _descController.text.trim(),
        price: double.parse(_priceController.text),
        left: int.parse(_stockController.text),
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : 'https://images.unsplash.com/photo-1626074353765-517a681e40be?w=400',
        packageItems: _packageItems,
        isAvailable: _isAvailableForOrder,
      );

      await Provider.of<LocalPackageProvider>(context, listen: false).addPackage(mealPackage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✓ Package saved locally!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('✗ Error saving package locally: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

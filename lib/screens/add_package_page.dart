// lib/screens/add_package_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/vendor_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddPackagePage extends StatefulWidget {
  final String? packageId;
  final String? initialTitle;
  final String? initialCategory;
  final String? initialPrice;
  final String? initialStock;
  final String? initialDesc;

  const AddPackagePage({
    super.key,
    this.packageId,
    this.initialTitle,
    this.initialCategory,
    this.initialPrice,
    this.initialStock,
    this.initialDesc,
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
    text: widget.initialPrice,
  );
  late final _stockController = TextEditingController(
    text: widget.initialStock,
  );
  late final _descController = TextEditingController(text: widget.initialDesc);
  late String _selectedCategory = widget.initialCategory ?? 'Breakfast';

  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isSaving = false;
  double _uploadProgress = 0.0;

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    // Treat as editing only if we have a non-empty packageId that isn't a fallback
    final bool isEditing =
        widget.packageId != null &&
        widget.packageId!.isNotEmpty &&
        !widget.packageId!.startsWith('fallback_');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Package" : "Add New Package",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _saveForm,
              child: const Text(
                "Save",
                style: TextStyle(
                  color: primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Form(
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
                    decoration: _inputDecoration(
                      "e.g. Ultimate Breakfast Package",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter a name" : null,
                  ),
                  const SizedBox(height: 20),

                  // 3. Category Dropdown
                  _buildLabel("Category"),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: _inputDecoration(""),
                    items:
                        ['Breakfast', 'Lunch', 'Dinner', 'Merienda', 'Dessert']
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
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
                              validator: (value) =>
                                  value!.isEmpty ? "Required" : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Stock"),
                            TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration("Qty"),
                              validator: (value) =>
                                  value!.isEmpty ? "Required" : null,
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
                      onPressed: _isSaving ? null : _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing ? "Update Package" : "Publish Package",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_uploadProgress > 0 && _uploadProgress < 1)
                      Column(
                        children: [
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: _uploadProgress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                primaryOrange,
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Uploading image... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      const Column(
                        children: [
                          CircularProgressIndicator(color: primaryOrange),
                          SizedBox(height: 16),
                          Text(
                            'Saving package...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
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
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: kIsWeb
                    ? Image.network(
                        _selectedImage!.path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Upload Package Photo",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
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
        borderSide: const BorderSide(color: primaryOrange),
      ),
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

  Future<String?> _uploadImageToStorage(String vendorId) async {
    if (_selectedImage == null) return null;

    try {
      // Create a unique filename
      final String fileName =
          'package_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = 'vendors/$vendorId/packages/$fileName';

      // Create reference to Firebase Storage
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(filePath);

      // Upload file
      UploadTask uploadTask;
      if (kIsWeb) {
        // For web, read bytes
        final bytes = await _selectedImage!.readAsBytes();
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // For mobile, use File
        final file = File(_selectedImage!.path);
        uploadTask = storageRef.putFile(file);
      }

      // Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (mounted) {
          setState(() {
            _uploadProgress =
                snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      // Wait for upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask;
      // Get download URL
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
        _uploadProgress = 0.0;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final vendorId = authProvider.currentUser?.userId ?? 'vendor_nanay';
        final vendorName =
            authProvider.currentUser?.fullName ?? "Nanay's Kitchen";

        final Map<String, dynamic> data = {
          'title': _titleController.text,
          'type': _selectedCategory,
          'price': int.parse(_priceController.text),
          'left': int.parse(_stockController.text),
          'desc': _descController.text,
          'vendorId': vendorId,
          'vendor': vendorName,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        final bool isEditing =
            widget.packageId != null &&
            widget.packageId!.isNotEmpty &&
            !widget.packageId!.startsWith('fallback_');

        // Upload image if selected
        if (_selectedImage != null) {
          final imageUrl = await _uploadImageToStorage(vendorId);
          if (imageUrl != null) {
            data['imageUrl'] = imageUrl;
          } else {
            // Upload failed, use placeholder
            data['imageUrl'] = 'assets/images/food_package_1.jpg';
          }
        } else if (!isEditing) {
          // No image selected for new package, use placeholder
          data['imageUrl'] = 'assets/images/food_package_1.jpg';
        }

        if (!isEditing) {
          // Add new package
          data['createdAt'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance.collection('meals').add(data);
        } else {
          // Update existing package
          await FirebaseFirestore.instance
              .collection('meals')
              .doc(widget.packageId)
              .update(data);
        }

        if (mounted) {
          // Refresh the vendor data
          Provider.of<VendorProvider>(
            context,
            listen: false,
          ).refreshVendorData(vendorId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                !isEditing ? "Package Published!" : "Package Updated!",
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
            _uploadProgress = 0.0;
          });
        }
      }
    }
  }
}

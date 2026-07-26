import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt_model.dart';
import '../services/database_service.dart';

class ReceiptFormScreen extends StatefulWidget {
  final Receipt? receipt; // If null, it's a new receipt; if not null, it's editing

  const ReceiptFormScreen({super.key, this.receipt});

  @override
  State<ReceiptFormScreen> createState() => _ReceiptFormScreenState();
}

class _ReceiptFormScreenState extends State<ReceiptFormScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _receiptNumberController;
  late TextEditingController _vendorNameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food & Beverages';
  String _selectedPaymentMethod = 'Cash';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// Initialize controllers with data if editing, or empty if creating
  void _initializeControllers() {
    if (widget.receipt != null) {
      _receiptNumberController =
          TextEditingController(text: widget.receipt!.receiptNumber);
      _vendorNameController =
          TextEditingController(text: widget.receipt!.vendorName);
      _amountController =
          TextEditingController(text: widget.receipt!.amount.toString());
      _descriptionController =
          TextEditingController(text: widget.receipt!.description ?? '');
      _selectedDate = widget.receipt!.date;
      _selectedCategory = widget.receipt!.category;
      _selectedPaymentMethod = widget.receipt!.paymentMethod ?? 'Cash';
    } else {
      _receiptNumberController = TextEditingController();
      _vendorNameController = TextEditingController();
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _receiptNumberController.dispose();
    _vendorNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Handle form submission
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      if (widget.receipt != null) {
        // Update existing receipt
        final updatedReceipt = widget.receipt!.copyWith(
          receiptNumber: _receiptNumberController.text,
          vendorName: _vendorNameController.text,
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          paymentMethod: _selectedPaymentMethod,
        );

        final success = await _dbService.updateReceipt(updatedReceipt);
        if (success) {
          _showSuccessSnackBar('Receipt updated successfully');
          Navigator.pop(context, true);
        }
      } else {
        // Create new receipt
        final newReceipt = Receipt(
          receiptNumber: _receiptNumberController.text,
          vendorName: _vendorNameController.text,
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          paymentMethod: _selectedPaymentMethod,
        );

        await _dbService.insertReceipt(newReceipt);
        _showSuccessSnackBar('Receipt added successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to save receipt: $e');
    }
  }

  /// Show date picker
  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receipt != null ? 'Edit Receipt' : 'Add Receipt'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Receipt Number Field
                    _buildTextField(
                      controller: _receiptNumberController,
                      label: 'Receipt Number',
                      hint: 'e.g., RCP-2026-001',
                      icon: Icons.receipt,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Receipt number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Vendor Name Field
                    _buildTextField(
                      controller: _vendorNameController,
                      label: 'Vendor Name',
                      hint: 'e.g., Supermarket X',
                      icon: Icons.store,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vendor name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount Field
                    _buildTextField(
                      controller: _amountController,
                      label: 'Amount (KES)',
                      hint: 'e.g., 1500.50',
                      icon: Icons.attach_money,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Amount is required';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date Field
                    _buildDateField(),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),

                    // Payment Method Dropdown
                    _buildPaymentMethodDropdown(),
                    const SizedBox(height: 16),

                    // Description Field
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      hint: 'Add any additional notes',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  /// Build text input field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.red),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  /// Build date field
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.red),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build category dropdown
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
            items: Receipt.getCategories().map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build payment method dropdown
  Widget _buildPaymentMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedPaymentMethod,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPaymentMethod = value);
              }
            },
            items: Receipt.getPaymentMethods().map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _submitForm,
        icon: const Icon(Icons.save),
        label: Text(
          widget.receipt != null ? 'Update Receipt' : 'Save Receipt',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

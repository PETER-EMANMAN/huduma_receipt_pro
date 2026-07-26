import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../services/database_service.dart';
import 'receipt_form_screen.dart';
import 'receipt_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Receipt> _receipts = [];
  List<Receipt> _filteredReceipts = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  /// Load all receipts from database
  Future<void> _loadReceipts() async {
    try {
      setState(() => _isLoading = true);
      final receipts = await _dbService.getAllReceipts();
      final total = await _dbService.getTotalAmount();
      
      setState(() {
        _receipts = receipts;
        _filteredReceipts = receipts;
        _totalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load receipts: $e');
    }
  }

  /// Apply filters based on category and search query
  void _applyFilters() {
    List<Receipt> filtered = _receipts;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((r) => r.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((r) =>
              r.vendorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.receiptNumber.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() => _filteredReceipts = filtered);
  }

  /// Handle delete receipt
  Future<void> _deleteReceipt(Receipt receipt) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    try {
      final success = await _dbService.deleteReceipt(receipt.id!);
      if (success) {
        await _loadReceipts();
        _showSuccessSnackBar('Receipt deleted successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to delete receipt: $e');
    }
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Receipt'),
            content: const Text('Are you sure you want to delete this receipt?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Navigate to receipt form to add new receipt
  void _navigateToAddReceipt() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const ReceiptFormScreen()),
    );
    if (result == true) {
      await _loadReceipts();
    }
  }

  /// Navigate to receipt detail screen
  void _navigateToDetail(Receipt receipt) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptDetailScreen(receipt: receipt),
      ),
    );
    if (result == true) {
      await _loadReceipts();
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
        title: const Text('Huduma Receipt Pro'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Total Amount Card
                _buildTotalAmountCard(),
                
                // Search and Filter Section
                _buildSearchAndFilterSection(),
                
                // Receipts List
                Expanded(
                  child: _filteredReceipts.isEmpty
                      ? _buildEmptyState()
                      : _buildReceiptsList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddReceipt,
        tooltip: 'Add Receipt',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build total amount card
  Widget _buildTotalAmountCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Spent',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'KES ${_totalAmount.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Receipts: ${_filteredReceipts.length}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build search and filter section
  Widget _buildSearchAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search field
          TextField(
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Search by vendor or receipt #',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 12),
          
          // Category filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Receipt.getCategories().length + 1,
              itemBuilder: (context, index) {
                final category =
                    index == 0 ? 'All' : Receipt.getCategories()[index - 1];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                      _applyFilters();
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Receipts Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search criteria'
                : 'Tap the + button to add your first receipt',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build receipts list
  Widget _buildReceiptsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredReceipts.length,
      itemBuilder: (context, index) {
        final receipt = _filteredReceipts[index];
        return _buildReceiptCard(receipt);
      },
    );
  }

  /// Build individual receipt card
  Widget _buildReceiptCard(Receipt receipt) {
    return GestureDetector(
      onTap: () => _navigateToDetail(receipt),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Header row with vendor and amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receipt.vendorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          receipt.getFormattedDate(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        receipt.getFormattedAmount(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          receipt.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Details row
              Row(
                children: [
                  Icon(Icons.receipt, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      receipt.receiptNumber,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (receipt.paymentMethod != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.payment, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      receipt.paymentMethod!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToDetail(receipt),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () => _deleteReceipt(receipt),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/receipt_model.dart';
import '../services/database_service.dart';
import 'receipt_form_screen.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final Receipt receipt;

  const ReceiptDetailScreen({super.key, required this.receipt});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  late Receipt _receipt;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _receipt = widget.receipt;
    _refreshReceipt();
  }

  /// Refresh receipt data from database
  Future<void> _refreshReceipt() async {
    try {
      final updatedReceipt = await _dbService.getReceiptById(_receipt.id!);
      if (updatedReceipt != null) {
        setState(() => _receipt = updatedReceipt);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to refresh receipt: $e');
    }
  }

  /// Navigate to edit receipt form
  Future<void> _navigateToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptFormScreen(receipt: _receipt),
      ),
    );
    if (result == true) {
      await _refreshReceipt();
    }
  }

  /// Handle delete receipt
  Future<void> _deleteReceipt() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    try {
      setState(() => _isLoading = true);
      final success = await _dbService.deleteReceipt(_receipt.id!);
      if (success) {
        _showSuccessSnackBar('Receipt deleted successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
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

  /// Generate PDF of receipt
  Future<void> _generatePDF() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    'HUDUMA RECEIPT PRO',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Receipt details
                _buildPDFDetailRow(
                  'Receipt Number:',
                  _receipt.receiptNumber,
                ),
                _buildPDFDetailRow(
                  'Vendor:',
                  _receipt.vendorName,
                ),
                _buildPDFDetailRow(
                  'Date:',
                  _receipt.getFormattedDate(),
                ),
                _buildPDFDetailRow(
                  'Category:',
                  _receipt.category,
                ),
                _buildPDFDetailRow(
                  'Payment Method:',
                  _receipt.paymentMethod ?? 'N/A',
                ),

                pw.SizedBox(height: 30),

                // Amount section
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Amount',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        _receipt.getFormattedAmount(),
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Description if available
                if (_receipt.description != null &&
                    _receipt.description!.isNotEmpty) ...[
                  pw.Text(
                    'Description:',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    _receipt.description!,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.SizedBox(height: 20),
                ],

                // Footer with timestamps
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(_receipt.createdAt)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.Text(
                  'Last Updated: ${DateFormat('MMM dd, yyyy HH:mm').format(_receipt.updatedAt)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            );
          },
        ),
      );

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      _showSuccessSnackBar('PDF generated successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to generate PDF: $e');
    }
  }

  /// Build detail row for PDF
  pw.Widget _buildPDFDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Receipt Details'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEdit,
              tooltip: 'Edit Receipt',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteReceipt,
              tooltip: 'Delete Receipt',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main info card
                    _buildInfoCard(),
                    const SizedBox(height: 24),

                    // Details section
                    _buildDetailsSection(),
                    const SizedBox(height: 24),

                    // Action buttons
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  /// Build main info card
  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.red[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _receipt.vendorName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              _receipt.getFormattedAmount(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _receipt.getFormattedDate(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _receipt.category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _receipt.paymentMethod ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build details section
  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Receipt Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailTile(
          icon: Icons.receipt,
          label: 'Receipt Number',
          value: _receipt.receiptNumber,
        ),
        const SizedBox(height: 12),
        _buildDetailTile(
          icon: Icons.store,
          label: 'Vendor Name',
          value: _receipt.vendorName,
        ),
        const SizedBox(height: 12),
        _buildDetailTile(
          icon: Icons.attach_money,
          label: 'Amount',
          value: _receipt.getFormattedAmount(),
        ),
        const SizedBox(height: 12),
        _buildDetailTile(
          icon: Icons.calendar_today,
          label: 'Date',
          value: _receipt.getFormattedDate(),
        ),
        const SizedBox(height: 12),
        _buildDetailTile(
          icon: Icons.category,
          label: 'Category',
          value: _receipt.category,
        ),
        const SizedBox(height: 12),
        _buildDetailTile(
          icon: Icons.payment,
          label: 'Payment Method',
          value: _receipt.paymentMethod ?? 'Not specified',
        ),
        if (_receipt.description != null &&
            _receipt.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDetailTile(
            icon: Icons.description,
            label: 'Description',
            value: _receipt.description!,
            maxLines: 3,
          ),
        ],
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        _buildTimestampInfo(),
      ],
    );
  }

  /// Build detail tile
  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.red, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build timestamp info
  Widget _buildTimestampInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timestamps',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(_receipt.createdAt)}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last Updated: ${DateFormat('MMM dd, yyyy HH:mm').format(_receipt.updatedAt)}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _navigateToEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _generatePDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deleteReceipt,
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

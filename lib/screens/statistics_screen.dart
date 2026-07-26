import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt_model.dart';
import '../services/database_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  double _totalAmount = 0.0;
  int _totalReceipts = 0;
  Map<String, double> _categoryTotals = {};
  List<Receipt> _receipts = [];
  String _selectedPeriod = 'All Time';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  /// Load statistics from database
  Future<void> _loadStatistics() async {
    try {
      setState(() => _isLoading = true);
      
      final receipts = await _dbService.getAllReceipts();
      final total = await _dbService.getTotalAmount();
      final count = await _dbService.getReceiptCount();
      final categoryTotals = await _dbService.getTotalAmountByCategory();

      setState(() {
        _receipts = receipts;
        _totalAmount = total;
        _totalReceipts = count;
        _categoryTotals = categoryTotals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load statistics: $e');
    }
  }

  /// Filter receipts by period
  List<Receipt> _getFilteredReceipts() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    switch (_selectedPeriod) {
      case 'Last 7 Days':
        return _receipts.where((r) => r.date.isAfter(sevenDaysAgo)).toList();
      case 'This Month':
        return _receipts.where((r) => r.date.isAfter(startOfMonth)).toList();
      case 'This Year':
        return _receipts.where((r) => r.date.isAfter(startOfYear)).toList();
      default:
        return _receipts;
    }
  }

  /// Calculate average amount
  double _calculateAverage(List<Receipt> receipts) {
    if (receipts.isEmpty) return 0.0;
    final total = receipts.fold<double>(0, (sum, r) => sum + r.amount);
    return total / receipts.length;
  }

  /// Get highest spend receipt
  Receipt? _getHighestSpend(List<Receipt> receipts) {
    if (receipts.isEmpty) return null;
    return receipts.reduce(
      (current, next) => current.amount > next.amount ? current : next,
    );
  }

  /// Get lowest spend receipt
  Receipt? _getLowestSpend(List<Receipt> receipts) {
    if (receipts.isEmpty) return null;
    return receipts.reduce(
      (current, next) => current.amount < next.amount ? current : next,
    );
  }

  /// Get category breakdown percentages
  Map<String, double> _getCategoryPercentages() {
    if (_totalAmount == 0) return {};
    return _categoryTotals.map(
      (category, amount) => MapEntry(category, (amount / _totalAmount) * 100),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),

                  // Summary cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Category breakdown
                  _buildCategoryBreakdown(),
                  const SizedBox(height: 24),

                  // Spending insights
                  _buildSpendingInsights(),
                  const SizedBox(height: 24),

                  // Top categories chart
                  _buildTopCategoriesChart(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  /// Build period selector
  Widget _buildPeriodSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          final periods = ['Last 7 Days', 'This Month', 'This Year', 'All Time'];
          final period = periods[index];
          final isSelected = _selectedPeriod == period;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedPeriod = period);
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
    );
  }

  /// Build summary cards
  Widget _buildSummaryCards() {
    final filtered = _getFilteredReceipts();
    final filteredTotal = filtered.fold<double>(0, (sum, r) => sum + r.amount);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Spent',
                value: _formatCurrency(filteredTotal),
                icon: Icons.attach_money,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Receipts',
                value: filtered.length.toString(),
                icon: Icons.receipt,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Average',
                value: _formatCurrency(_calculateAverage(filtered)),
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Categories',
                value: _categoryTotals.length.toString(),
                icon: Icons.category,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual summary card
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build category breakdown
  Widget _buildCategoryBreakdown() {
    final filtered = _getFilteredReceipts();
    final filteredCategoryTotals = <String, double>{};

    for (final receipt in filtered) {
      filteredCategoryTotals[receipt.category] =
          (filteredCategoryTotals[receipt.category] ?? 0) + receipt.amount;
    }

    final filteredTotal =
        filtered.fold<double>(0, (sum, r) => sum + r.amount);

    if (filteredTotal == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No data available for this period',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...filteredCategoryTotals.entries.map((entry) {
          final percentage = (entry.value / filteredTotal) * 100;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCategoryBar(
              category: entry.key,
              amount: entry.value,
              percentage: percentage,
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Build category bar
  Widget _buildCategoryBar({
    required String category,
    required double amount,
    required double percentage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_formatCurrency(amount)} (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCategoryColor(category),
            ),
          ),
        ),
      ],
    );
  }

  /// Get color for category
  Color _getCategoryColor(String category) {
    const colors = {
      'Food & Beverages': Color(0xFFFF6B6B),
      'Transportation': Color(0xFF4ECDC4),
      'Accommodation': Color(0xFF45B7D1),
      'Entertainment': Color(0xFFFFA502),
      'Shopping': Color(0xFFFFB347),
      'Utilities': Color(0xFF95E1D3),
      'Healthcare': Color(0xFFF38181),
      'Education': Color(0xFFAA96DA),
      'Business': Color(0xFF5A67D8),
      'Other': Color(0xFF808080),
    };
    return colors[category] ?? Colors.grey;
  }

  /// Build spending insights
  Widget _buildSpendingInsights() {
    final filtered = _getFilteredReceipts();
    final highest = _getHighestSpend(filtered);
    final lowest = _getLowestSpend(filtered);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (highest != null)
          _buildInsightCard(
            title: 'Highest Expense',
            vendor: highest.vendorName,
            amount: _formatCurrency(highest.amount),
            date: highest.getFormattedDate(),
            icon: Icons.trending_up,
            color: Colors.red,
          ),
        const SizedBox(height: 12),
        if (lowest != null)
          _buildInsightCard(
            title: 'Lowest Expense',
            vendor: lowest.vendorName,
            amount: _formatCurrency(lowest.amount),
            date: lowest.getFormattedDate(),
            icon: Icons.trending_down,
            color: Colors.green,
          ),
      ],
    );
  }

  /// Build insight card
  Widget _buildInsightCard({
    required String title,
    required String vendor,
    required String amount,
    required String date,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build top categories chart
  Widget _buildTopCategoriesChart() {
    final filtered = _getFilteredReceipts();
    final categoryTotals = <String, double>{};

    for (final receipt in filtered) {
      categoryTotals[receipt.category] =
          (categoryTotals[receipt.category] ?? 0) + receipt.amount;
    }

    if (categoryTotals.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No data available for this period',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      );
    }

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sorted.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...topCategories.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final category = entry.value.key;
          final amount = entry.value.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatCurrency(amount),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: _getCategoryColor(category),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Format currency helper
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'KES ${formatter.format(amount)}';
  }
}

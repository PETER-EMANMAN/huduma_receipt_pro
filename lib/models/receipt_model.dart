import 'package:intl/intl.dart';

class Receipt {
  final int? id;
  final String receiptNumber;
  final String vendorName;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  Receipt({
    this.id,
    required this.receiptNumber,
    required this.vendorName,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
    this.paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert Receipt object to JSON map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receiptNumber': receiptNumber,
      'vendorName': vendorName,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Receipt object from JSON map (database retrieval)
  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'] as int?,
      receiptNumber: map['receiptNumber'] as String,
      vendorName: map['vendorName'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      description: map['description'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Create a copy of Receipt with modified fields
  Receipt copyWith({
    int? id,
    String? receiptNumber,
    String? vendorName,
    double? amount,
    DateTime? date,
    String? category,
    String? description,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      vendorName: vendorName ?? this.vendorName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Format date for display (e.g., "Jul 26, 2026")
  String getFormattedDate() {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format amount as currency (e.g., "KES 1,234.50")
  String getFormattedAmount() {
    return 'KES ${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
  }

  /// Get all available receipt categories
  static List<String> getCategories() {
    return [
      'Food & Beverages',
      'Transportation',
      'Accommodation',
      'Entertainment',
      'Shopping',
      'Utilities',
      'Healthcare',
      'Education',
      'Business',
      'Other',
    ];
  }

  /// Get all available payment methods
  static List<String> getPaymentMethods() {
    return [
      'Cash',
      'Credit Card',
      'Debit Card',
      'Mobile Money',
      'Bank Transfer',
      'Check',
      'Other',
    ];
  }

  @override
  String toString() {
    return 'Receipt(id: $id, receiptNumber: $receiptNumber, vendorName: $vendorName, amount: $amount, date: $date, category: $category)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Receipt &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          receiptNumber == other.receiptNumber &&
          vendorName == other.vendorName &&
          amount == other.amount &&
          date == other.date &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      receiptNumber.hashCode ^
      vendorName.hashCode ^
      amount.hashCode ^
      date.hashCode ^
      category.hashCode;
}

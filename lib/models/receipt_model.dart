import 'package:intl/intl.dart';

class Receipt {
  final int? id;
  final String receiptNumber;
  final String customerName;
  final String? customerContact;
  final String serviceType;
  final double amount;
  final double? hourlyRate;
  final double? duration; // in hours
  final DateTime date;
  final String paymentStatus; // Paid, Pending, Partial
  final String paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Receipt({
    this.id,
    required this.receiptNumber,
    required this.customerName,
    this.customerContact,
    required this.serviceType,
    required this.amount,
    this.hourlyRate,
    this.duration,
    required this.date,
    required this.paymentStatus,
    required this.paymentMethod,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert Receipt to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receiptNumber': receiptNumber,
      'customerName': customerName,
      'customerContact': customerContact,
      'serviceType': serviceType,
      'amount': amount,
      'hourlyRate': hourlyRate,
      'duration': duration,
      'date': date.toIso8601String(),
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Receipt from Map (database)
  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'] as int?,
      receiptNumber: map['receiptNumber'] as String,
      customerName: map['customerName'] as String,
      customerContact: map['customerContact'] as String?,
      serviceType: map['serviceType'] as String,
      amount: (map['amount'] as num).toDouble(),
      hourlyRate: map['hourlyRate'] != null ? (map['hourlyRate'] as num).toDouble() : null,
      duration: map['duration'] != null ? (map['duration'] as num).toDouble() : null,
      date: DateTime.parse(map['date'] as String),
      paymentStatus: map['paymentStatus'] as String,
      paymentMethod: map['paymentMethod'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Create a copy with modified fields
  Receipt copyWith({
    int? id,
    String? receiptNumber,
    String? customerName,
    String? customerContact,
    String? serviceType,
    double? amount,
    double? hourlyRate,
    double? duration,
    DateTime? date,
    String? paymentStatus,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      customerName: customerName ?? this.customerName,
      customerContact: customerContact ?? this.customerContact,
      serviceType: serviceType ?? this.serviceType,
      amount: amount ?? this.amount,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get all service types for Cyber Cafe
  static List<String> getServiceTypes() {
    return [
      'Internet/WiFi Usage',
      'Computer Rental',
      'Printing Services',
      'Scanning Services',
      'Document Typing',
      'Software Installation',
      'Hardware Repair',
      'Gaming Session',
      'Phone Charging',
      'Other Services',
    ];
  }

  /// Get all payment statuses
  static List<String> getPaymentStatuses() {
    return ['Paid', 'Pending', 'Partial'];
  }

  /// Get all payment methods
  static List<String> getPaymentMethods() {
    return [
      'Cash',
      'Card',
      'Mobile Money',
      'Bank Transfer',
      'Credit',
      'Check',
    ];
  }

  /// Format amount as currency
  String getFormattedAmount() {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'KES ${formatter.format(amount)}';
  }

  /// Format date
  String getFormattedDate() {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date with time
  String getFormattedDateTime() {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  /// Calculate total from hourly rate and duration
  static double calculateTotal(double hourlyRate, double hours) {
    return hourlyRate * hours;
  }

  /// Format duration in hours and minutes
  String getFormattedDuration() {
    if (duration == null) return 'N/A';
    final hours = duration!.toInt();
    final minutes = ((duration! - hours) * 60).toInt();
    if (hours > 0 && minutes > 0) {
      return '$hours h ${minutes}m';
    } else if (hours > 0) {
      return '$hours h';
    } else {
      return '${minutes}m';
    }
  }

  /// Get payment status icon
  String getPaymentStatusIcon() {
    switch (paymentStatus) {
      case 'Paid':
        return '✓ Paid';
      case 'Pending':
        return '⏳ Pending';
      case 'Partial':
        return '◐ Partial';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'Receipt(id: $id, receiptNumber: $receiptNumber, customerName: $customerName, serviceType: $serviceType, amount: $amount, paymentStatus: $paymentStatus)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Receipt &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          receiptNumber == other.receiptNumber &&
          customerName == other.customerName &&
          serviceType == other.serviceType &&
          amount == other.amount;

  @override
  int get hashCode =>
      id.hashCode ^
      receiptNumber.hashCode ^
      customerName.hashCode ^
      serviceType.hashCode ^
      amount.hashCode;
}

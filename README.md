# Huduma Receipt Pro

A beautiful and efficient Flutter application for managing, tracking, and analyzing your receipts. Store receipts, categorize expenses, generate PDFs, and get detailed spending insights with intuitive analytics.

## 🎯 Features

### 📋 Receipt Management
- ✅ **Add Receipts** - Create detailed receipt entries with all relevant information
- ✅ **Edit Receipts** - Modify receipt details anytime
- ✅ **Delete Receipts** - Remove unwanted receipts with confirmation
- ✅ **Receipt Details** - View comprehensive receipt information
- ✅ **PDF Generation** - Export receipts as professional PDF documents

### 🔍 Search & Filter
- ✅ **Search by Vendor** - Find receipts by store/vendor name
- ✅ **Search by Receipt Number** - Look up specific receipts
- ✅ **Filter by Category** - View receipts by category type
- ✅ **Smart Filtering** - Combine search and category filters

### 📊 Analytics & Statistics
- ✅ **Dashboard Overview** - Quick summary of all receipts
- ✅ **Spending Statistics** - Detailed spending analytics
- ✅ **Period Filtering** - Last 7 Days, This Month, This Year, All Time
- ✅ **Category Breakdown** - Spending distribution across categories
- ✅ **Top Categories Chart** - Top 5 spending categories ranked
- ✅ **Spending Insights** - Highest and lowest expenses

### 💾 Data Management
- ✅ **Local SQLite Database** - Secure offline storage
- ✅ **Auto-save** - Automatic data persistence
- ✅ **Fast Queries** - Optimized database with indexing
- ✅ **No Cloud Required** - Complete privacy and control

### 🎨 User Interface
- ✅ **Bottom Navigation** - Easy switching between Dashboard and Statistics
- ✅ **Beautiful Design** - Modern Material Design 3
- ✅ **Responsive Layout** - Works perfectly on all screen sizes
- ✅ **Intuitive UX** - Easy to navigate and use

## 📦 Technology Stack

- **Framework:** Flutter 3.x
- **Language:** Dart
- **Database:** SQLite with sqflite
- **UI:** Material Design 3
- **PDF Generation:** PDF package with printing
- **State Management:** StatefulWidget
- **Date Handling:** intl package

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / Xcode (for emulators/simulators)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/PETER-EMANMAN/huduma_receipt_pro.git
   cd huduma_receipt_pro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── receipt_model.dart   # Receipt data model
├── services/
│   └── database_service.dart # SQLite database operations
└── screens/
    ├── splash_screen.dart          # Loading/splash screen
    ├── home_screen.dart            # Navigation hub
    ├── dashboard_screen.dart       # Main receipt list view
    ├── receipt_form_screen.dart    # Create/edit form
    ├── receipt_detail_screen.dart  # Detailed view & PDF
    └── statistics_screen.dart      # Analytics & charts
```

## 📖 Usage

### Adding a Receipt
1. Tap the **+** button on the Dashboard
2. Enter receipt details (number, vendor, amount, etc.)
3. Select date using the date picker
4. Choose category and payment method
5. Add optional description
6. Tap "Save Receipt"

### Viewing Statistics
1. Tap the **Statistics** tab at the bottom
2. Select time period (Last 7 Days, This Month, This Year, All Time)
3. View summary cards, breakdowns, and insights
4. Analyze spending patterns by category

### Exporting to PDF
1. Tap on any receipt to view details
2. Tap the **PDF** button
3. Choose to print or save
4. Share or archive as needed

## 🗂️ Database Schema

### Receipts Table
```sql
CREATE TABLE receipts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  receiptNumber TEXT UNIQUE NOT NULL,
  vendorName TEXT NOT NULL,
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  paymentMethod TEXT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
```

**Indexes:**
- `idx_date` - Fast date-based queries
- `idx_category` - Quick category filtering
- `idx_vendor` - Efficient vendor searches

## 💡 Features Details

### Receipt Categories
- Food & Beverages
- Transportation
- Accommodation
- Entertainment
- Shopping
- Utilities
- Healthcare
- Education
- Business
- Other

### Payment Methods
- Cash
- Credit Card
- Debit Card
- Mobile Money
- Bank Transfer
- Check
- Other

### Statistics Insights
- **Total Spent** - Sum of all receipts
- **Receipt Count** - Number of transactions
- **Average Spending** - Mean per receipt
- **Category Count** - Unique categories used
- **Highest Expense** - Most expensive transaction
- **Lowest Expense** - Least expensive transaction
- **Category Breakdown** - % distribution by category
- **Top 5 Categories** - Ranked by spending

## 🔐 Privacy & Security

- ✅ All data stored locally on device
- ✅ No internet connection required
- ✅ No cloud uploads or tracking
- ✅ Complete user privacy
- ✅ Encrypted database (optional enhancement)

## 📝 API Reference

### DatabaseService

**Create Operations:**
- `insertReceipt(Receipt)` - Add new receipt

**Read Operations:**
- `getAllReceipts()` - Fetch all receipts
- `getReceiptById(int)` - Get single receipt
- `getReceiptsByCategory(String)` - Filter by category
- `getReceiptsByVendor(String)` - Search by vendor
- `getReceiptsByDateRange(DateTime, DateTime)` - Date filtering
- `searchReceipts(String)` - Full-text search
- `getTotalAmount()` - Sum of all amounts
- `getTotalAmountByCategory()` - Breakdown by category
- `getReceiptCount()` - Total receipt count

**Update Operations:**
- `updateReceipt(Receipt)` - Modify receipt

**Delete Operations:**
- `deleteReceipt(int)` - Remove single receipt
- `deleteAllReceipts()` - Clear all data
- `deleteReceiptsByCategory(String)` - Delete by category

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Peter Amui Emanman**
- GitHub: [@PETER-EMANMAN](https://github.com/PETER-EMANMAN)
- Email: 133596247+PETER-EMANMAN@users.noreply.github.com

## 🐛 Bug Reports & Feature Requests

Found a bug or have a feature request? Please [open an issue](https://github.com/PETER-EMANMAN/huduma_receipt_pro/issues) on GitHub.

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [SQLite Tutorial](https://www.sqlite.org/docs.html)
- [Material Design 3](https://m3.material.io/)

## 🎓 Learning Resources

This project demonstrates:
- Flutter state management with StatefulWidget
- Local database operations with SQLite
- Form validation and data handling
- PDF generation and printing
- Bottom navigation implementation
- Chart and statistics visualization
- Real-time data filtering and searching

## ✨ Future Enhancements

Potential features for future versions:
- [ ] Receipt image attachment
- [ ] Dark mode support
- [ ] Backup and restore functionality
- [ ] Export to CSV
- [ ] Monthly expense reports
- [ ] Receipt templates
- [ ] Budget alerts
- [ ] Multi-currency support
- [ ] Cloud sync (optional)
- [ ] Receipt OCR (camera capture)

## 📞 Support

For support, email: 133596247+PETER-EMANMAN@users.noreply.github.com

---

**Made with ❤️ by Peter Amui Emanman**
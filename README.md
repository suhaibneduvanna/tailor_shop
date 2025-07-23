# Tailor Shop Management System

## Overview
A comprehensive desktop application for tailor shop management built with Flutter and Hive embedded database.

## Features

### 1. Customer Management
- Add, edit, and delete customers
- Store customer details: name, phone number, address
- Search customers by name or phone number
- View customer order history

### 2. Garment Type Management
- Create custom garment types (shirts, pants, suits, etc.)
- Define measurements required for each garment type
- Set base pricing for each garment type
- Predefined measurement suggestions

### 3. Order Management
- Create new orders with customer selection
- Record detailed measurements for each garment
- Set quantity, order date, and delivery date
- Track order status (pending, in progress, completed, delivered, cancelled)
- Generate unique invoice numbers automatically
- Add notes for special instructions

### 4. Printing System
- Generate and print invoices
- Generate and print measurement slips
- Professional PDF formatting
- Thermal printer compatible

### 5. Dashboard
- Overview of business statistics
- Recent orders display
- Upcoming deliveries tracking
- Revenue tracking

## Technical Architecture

### Database (Hive)
- **Customer Model**: Stores customer information
- **GarmentType Model**: Defines garment types with measurements and pricing
- **Order Model**: Complete order information with measurements and status
- **Local storage**: All data stored locally using Hive embedded database

### Screens
- **Dashboard**: Business overview and statistics
- **Customers**: Customer management interface
- **Orders**: Order creation and management
- **Garment Types**: Garment type configuration

### Key Components
- **Provider State Management**: Using Flutter Provider for state management
- **PDF Generation**: Professional invoice and measurement slip generation
- **Search Functionality**: Quick search across customers and orders
- **Form Validation**: Comprehensive form validation

## Usage Guide

### Adding a New Customer
1. Navigate to Customers screen
2. Click the "+" button
3. Fill in customer details (name, phone, optional address)
4. Save the customer

### Creating a New Order
1. Navigate to Orders screen
2. Click the "+" button
3. Select existing customer or search for one
4. Choose garment type
5. Enter measurements for all required fields
6. Set quantity, order date, and delivery date
7. Add optional notes
8. Save the order (invoice number auto-generated)

### Adding Garment Types
1. Navigate to Garment Types screen
2. Click the "+" button
3. Enter garment name and base price
4. Add required measurements (use suggested measurements or add custom ones)
5. Save the garment type

### Printing
- **Invoice**: From order details, click "Print Invoice"
- **Measurement Slip**: From order details, click "Print Measurements"
- Both generate professional PDFs suitable for thermal printers

### Search and Filter
- **Customers**: Search by name or phone number
- **Orders**: Search by invoice number, filter by status
- **Real-time search**: Results update as you type

## Default Data
The system comes with three pre-configured garment types:
1. **Shirt**: Chest, Shoulder, Sleeve Length, Collar, Length (₹500)
2. **Pant**: Waist, Hip, Inseam, Outseam, Thigh (₹400)
3. **Suit**: Chest, Shoulder, Sleeve Length, Waist, Hip, Jacket Length, Pant Length (₹1500)

## File Structure
```
lib/
├── main.dart                           # Application entry point
├── models/                             # Data models
│   ├── customer.dart
│   ├── garment_type.dart
│   └── order.dart
├── services/                           # Business logic
│   ├── database_service.dart
│   └── printing_service.dart
├── providers/                          # State management
│   └── tailor_shop_provider.dart
├── screens/                            # UI screens
│   ├── dashboard_screen.dart
│   ├── home_screen.dart
│   ├── customers_screen.dart
│   ├── add_edit_customer_screen.dart
│   ├── orders_screen.dart
│   ├── add_edit_order_screen.dart
│   ├── garment_types_screen.dart
│   └── add_edit_garment_type_screen.dart
└── widgets/                            # Reusable widgets
    ├── dashboard_card.dart
    ├── recent_orders_list.dart
    └── upcoming_deliveries_list.dart
```

## Dependencies
- **flutter**: UI framework
- **hive/hive_flutter**: Local database
- **provider**: State management
- **pdf/printing**: PDF generation and printing
- **uuid**: Unique ID generation
- **intl**: Date formatting

## Future Enhancements
- Backup and restore functionality
- Advanced reporting and analytics
- Multi-user support
- Integration with external payment systems
- Mobile app version
- Cloud synchronization

## Installation and Setup
1. Ensure Flutter is installed and configured
2. Clone the project
3. Run `flutter pub get` to install dependencies
4. Run `dart run build_runner build` to generate Hive adapters
5. Run `flutter run -d macos` for macOS or appropriate platform command

This system provides a complete solution for tailor shop management with professional invoicing, measurement tracking, and customer management capabilities.

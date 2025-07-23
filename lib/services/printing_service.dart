import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/customer.dart';
import '../models/garment_type.dart';
import '../models/order.dart';

class PrintingService {
  // Method to show invoice with proper print dialog
  static Future<void> printInvoice(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = await _generateInvoicePdf(order, customer, garmentType);

    // Use layoutPdf to show proper print dialog with preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${order.invoiceNumber}',
      format: PdfPageFormat.a4,
    );
  }

  // Method to print thermal receipt format invoice
  static Future<void> printThermalInvoice(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = await _generateThermalInvoicePdf(order, customer, garmentType);

    // Use thermal printer format (58mm width)
    const thermalFormat = PdfPageFormat(
      58 * PdfPageFormat.mm, // 58mm width
      double.infinity, // Auto height
      marginAll: 2 * PdfPageFormat.mm,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Thermal_Invoice_${order.invoiceNumber}',
      format: thermalFormat,
    );
  }

  // Method to show measurement slip with proper print dialog
  static Future<void> printMeasurementSlip(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = await _generateMeasurementSlipPdf(order, customer, garmentType);

    // Use layoutPdf to show proper print dialog with preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Measurement_Slip_${order.invoiceNumber}',
      format: PdfPageFormat.a4,
    );
  }

  // Method to print thermal measurement slip
  static Future<void> printThermalMeasurementSlip(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = await _generateThermalMeasurementSlipPdf(
      order,
      customer,
      garmentType,
    );

    // Use thermal printer format (58mm width)
    const thermalFormat = PdfPageFormat(
      58 * PdfPageFormat.mm, // 58mm width
      double.infinity, // Auto height
      marginAll: 2 * PdfPageFormat.mm,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Thermal_Measurement_${order.invoiceNumber}',
      format: thermalFormat,
    );
  }

  // Private method to generate invoice PDF
  static Future<pw.Document> _generateInvoicePdf(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 20),

              // Invoice details
              _buildInvoiceDetails(order),
              pw.SizedBox(height: 20),

              // Customer details
              _buildCustomerDetails(customer),
              pw.SizedBox(height: 20),

              // Order details
              _buildOrderDetails(order, garmentType),
              pw.SizedBox(height: 30),

              // Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // Private method to generate measurement slip PDF
  static Future<pw.Document> _generateMeasurementSlipPdf(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 20),

              // Title
              pw.Center(
                child: pw.Text(
                  'MEASUREMENT SLIP',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Customer details
              _buildCustomerDetails(customer),
              pw.SizedBox(height: 20),

              // Garment type
              pw.Text(
                'Garment Type: ${garmentType.name}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Measurements
              _buildMeasurementDetails(order, garmentType),
              pw.SizedBox(height: 20),

              // Additional info
              pw.Text('Invoice Number: ${order.invoiceNumber}'),
              pw.Text('Delivery Date: ${_formatDate(order.deliveryDate)}'),
              pw.Text('Quantity: ${order.quantity}'),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'TAILOR SHOP',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Professional Tailoring Services',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.blue700),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Address: 123 Fashion Street, City, State 12345',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Phone: +1 (555) 123-4567 | Email: info@tailorshop.com',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceDetails(Order order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Invoice #: ${order.invoiceNumber}'),
              pw.Text('Order Date: ${_formatDate(order.orderDate)}'),
              pw.Text('Delivery Date: ${_formatDate(order.deliveryDate)}'),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Status: ${order.status.name.toUpperCase()}'),
              pw.Text('Quantity: ${order.quantity}'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerDetails(Customer customer) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CUSTOMER DETAILS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Name: ${customer.name}'),
          pw.Text('Phone: ${customer.phoneNumber}'),
          if (customer.address != null) pw.Text('Address: ${customer.address}'),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderDetails(Order order, GarmentType garmentType) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ORDER DETAILS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),

          // Garment and pricing table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Quantity',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Unit Price',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(garmentType.name),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('${order.quantity}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Rs. ${garmentType.basePrice.toStringAsFixed(2)}',
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Rs. ${order.totalPrice.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          // Total
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL AMOUNT',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Rs. ${order.totalPrice.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
              ],
            ),
          ),

          if (order.notes != null) ...[
            pw.SizedBox(height: 15),
            pw.Text(
              'Notes: ${order.notes}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildMeasurementDetails(
    Order order,
    GarmentType garmentType,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MEASUREMENTS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),

          // Measurements table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Measurement',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Value (inches)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ...order.measurements.entries
                  .map(
                    (entry) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(entry.key),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${entry.value}"'),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for choosing our services!',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'For any queries, please contact us at the above mentioned details.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Terms & Conditions: Payment due within 30 days. Custom alterations are non-refundable.',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Thermal printer PDF generation methods
  static Future<pw.Document> _generateThermalInvoicePdf(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          58 * PdfPageFormat.mm, // 58mm thermal width
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              _buildThermalHeader(),
              _thermalDivider(),

              // Invoice details
              _buildThermalInvoiceInfo(order),
              _thermalDivider(),

              // Customer info
              _buildThermalCustomerInfo(customer),
              _thermalDivider(),

              // Items
              _buildThermalItems(order, garmentType),
              _thermalDivider(),

              // Total
              _buildThermalTotal(order),
              _thermalDivider(),

              // Footer
              _buildThermalFooter(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static Future<pw.Document> _generateThermalMeasurementSlipPdf(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          58 * PdfPageFormat.mm, // 58mm thermal width
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              _buildThermalHeader(),
              _thermalDivider(),

              // Title
              pw.Text(
                'MEASUREMENT SLIP',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 8),

              // Order info
              _buildThermalOrderInfo(order),
              _thermalDivider(),

              // Customer info
              _buildThermalCustomerInfo(customer),
              _thermalDivider(),

              // Garment type
              pw.Text(
                'Garment: ${garmentType.name}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),

              // Measurements
              _buildThermalMeasurements(order),
              _thermalDivider(),

              // Footer
              _buildThermalFooter(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // Thermal printer helper widgets
  static pw.Widget _buildThermalHeader() {
    return pw.Column(
      children: [
        pw.Text(
          'TAILOR SHOP',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Professional Tailoring Services',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Phone: +91 98765 43210',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
      ],
    );
  }

  static pw.Widget _buildThermalInvoiceInfo(Order order) {
    return pw.Column(
      children: [
        pw.Text(
          'Retail Invoice',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Date: ${_formatDate(order.orderDate)}',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Bill No: ${order.invoiceNumber}',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Payment Mode: Cash',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _buildThermalOrderInfo(Order order) {
    return pw.Column(
      children: [
        pw.Text(
          'Invoice: ${order.invoiceNumber}',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Date: ${_formatDate(order.orderDate)}',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Delivery: ${_formatDate(order.deliveryDate)}',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _buildThermalCustomerInfo(Customer customer) {
    return pw.Column(
      children: [
        pw.Text(
          customer.name,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Phone: ${customer.phoneNumber}',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        if (customer.address != null)
          pw.Text(
            customer.address!,
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
      ],
    );
  }

  static pw.Widget _buildThermalItems(Order order, GarmentType garmentType) {
    return pw.Column(
      children: [
        // Headers
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Item',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Qty',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Amt',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 0.5, color: PdfColors.black),
        pw.SizedBox(height: 2),

        // Item row
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                garmentType.name,
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                '${order.quantity}',
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                '${garmentType.basePrice.toStringAsFixed(2)}',
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 0.5, color: PdfColors.black),
        pw.SizedBox(height: 2),

        // Subtotal
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Sub Total', style: const pw.TextStyle(fontSize: 8)),
            pw.Text(
              '${order.quantity}',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              '${order.totalPrice.toStringAsFixed(2)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildThermalTotal(Order order) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'TOTAL',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Rs ${order.totalPrice.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Cash:', style: const pw.TextStyle(fontSize: 8)),
            pw.Text(
              'Rs ${order.totalPrice.toStringAsFixed(2)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Cash tendered:', style: const pw.TextStyle(fontSize: 8)),
            pw.Text(
              'Rs ${order.totalPrice.toStringAsFixed(2)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildThermalMeasurements(Order order) {
    return pw.Column(
      children: [
        pw.Text(
          'MEASUREMENTS (inches)',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        ...order.measurements.entries.map(
          (entry) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(entry.key, style: const pw.TextStyle(fontSize: 8)),
              pw.Text(
                '${entry.value}"',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildThermalFooter() {
    return pw.Column(
      children: [
        pw.Text(
          'Thank you for choosing our services!',
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Terms: Payment due within 30 days',
          style: const pw.TextStyle(fontSize: 6),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Custom alterations non-refundable',
          style: const pw.TextStyle(fontSize: 6),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'E & O E',
          style: const pw.TextStyle(fontSize: 6),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _thermalDivider() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 2),
        pw.Container(
          height: 0.5,
          width: double.infinity,
          color: PdfColors.grey400,
        ),
        pw.SizedBox(height: 2),
      ],
    );
  }
}

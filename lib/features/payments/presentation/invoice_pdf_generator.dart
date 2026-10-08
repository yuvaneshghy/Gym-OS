import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/config/tenant_config.dart';
import '../../members/domain/member.dart';
import '../domain/payment.dart';

class InvoicePdfGenerator {
  static Future<Uint8List> generate({
    required TenantConfig config,
    required Member member,
    required Payment payment,
    String? planName,
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('MMM dd, yyyy');
    final currency = config.currency;

    final baseAmount = payment.amount - (payment.gstAmount ?? 0);
    final gstAmount = payment.gstAmount ?? 0;
    final totalAmount = payment.amount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        config.gymName.isEmpty ? 'GYM INVOICE' : config.gymName.toUpperCase(),
                        style: const pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      if (config.gymAddress.isNotEmpty) pw.Text(config.gymAddress),
                      if (config.gymPhone.isNotEmpty) pw.Text('Phone: ${config.gymPhone}'),
                      if (config.gymEmail.isNotEmpty) pw.Text('Email: ${config.gymEmail}'),
                      if (config.gstNumber.isNotEmpty)
                        pw.Text('GSTIN: ${config.gstNumber}', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: const pw.TextStyle(fontSize: 32, color: PdfColors.blueGrey500)),
                      pw.SizedBox(height: 8),
                      pw.Text('Receipt #: ${payment.id.toUpperCase()}'),
                      pw.Text('Date: ${dateFormat.format(payment.date)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Billed To
              pw.Text('BILLED TO:', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              pw.SizedBox(height: 8),
              pw.Text(member.name, style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              if (member.phone.isNotEmpty) pw.Text('Phone: ${member.phone}'),
              
              pw.SizedBox(height: 40),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FlexColumnWidth(),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('DESCRIPTION', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('METHOD', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('AMOUNT', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  // Table Row
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          planName != null 
                            ? 'Membership Plan: $planName' 
                            : (payment.notes?.isNotEmpty ?? false) ? payment.notes! : 'Gym Service/Membership',
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(payment.method.toUpperCase()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('$currency ${baseAmount.toStringAsFixed(2)}', textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 250,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:'),
                            pw.Text('$currency ${baseAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('GST/Tax (${payment.taxRate ?? 0}%):'),
                            pw.Text('$currency ${gstAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Divider(),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTAL PAID:', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                            pw.Text('$currency ${totalAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.Spacer(),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: const pw.TextStyle(color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

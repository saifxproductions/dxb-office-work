// // import 'dart:io';
// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pw;
// // import 'package:intl/intl.dart';
// //
// // import 'invoice_model.dart';
// //
// // class PdfGeneratorService {
// //   static Future<File> generateInvoicePdf(InvoiceModel invoice) async {
// //     final pdf = pw.Document();
// //
// //     // Colors matching the brand
// //     final tealGreen = PdfColor.fromHex('#00897B');
// //     final darkGreen = PdfColor.fromHex('#004D40');
// //     final lightGray = PdfColor.fromHex('#F5F5F5');
// //     final redColor = PdfColor.fromHex('#D32F2F');
// //     final orangeColor = PdfColor.fromHex('#E65100');
// //     final tableHeaderBg = PdfColor.fromHex('#E0F2F1');
// //
// //     final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold);
// //     final normalStyle = const pw.TextStyle();
// //     final smallStyle = pw.TextStyle(fontSize: 9);
// //     final smallBoldStyle = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);
// //
// //     pdf.addPage(
// //       pw.Page(
// //         pageFormat: PdfPageFormat.a4,
// //         margin: const pw.EdgeInsets.all(30),
// //         build: (pw.Context context) {
// //           return pw.Column(
// //             crossAxisAlignment: pw.CrossAxisAlignment.start,
// //             children: [
// //               // ── HEADER ──
// //               pw.Row(
// //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                 children: [
// //                   // Logo text left
// //                   pw.Expanded(
// //                     flex: 2,
// //                     child: pw.Column(
// //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                       children: [
// //                         // Logo text block
// //                         pw.Row(
// //                           crossAxisAlignment: pw.CrossAxisAlignment.end,
// //                           children: [
// //                             pw.Column(
// //                               crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                               children: [
// //                                 pw.Text(
// //                                   'PROPERTY',
// //                                   style: pw.TextStyle(
// //                                     color: tealGreen,
// //                                     fontSize: 22,
// //                                     fontWeight: pw.FontWeight.bold,
// //                                     letterSpacing: 1,
// //                                   ),
// //                                 ),
// //                                 pw.Text(
// //                                   'INSPECTION',
// //                                   style: pw.TextStyle(
// //                                     color: tealGreen,
// //                                     fontSize: 22,
// //                                     fontWeight: pw.FontWeight.bold,
// //                                     letterSpacing: 1,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             pw.Text(
// //                               ' DXB',
// //                               style: pw.TextStyle(
// //                                 color: darkGreen,
// //                                 fontSize: 22,
// //                                 fontWeight: pw.FontWeight.bold,
// //                                 letterSpacing: 1,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         pw.Text(
// //                           'RA PROPERTY OBSERVER LLC',
// //                           style: pw.TextStyle(
// //                             color: darkGreen,
// //                             fontSize: 9,
// //                             fontWeight: pw.FontWeight.bold,
// //                             letterSpacing: 1,
// //                           ),
// //                         ),
// //                         pw.SizedBox(height: 8),
// //                         pw.Text(
// //                           'Inspecting for the unexpected',
// //                           style: pw.TextStyle(
// //                             color: PdfColors.grey700,
// //                             fontSize: 10,
// //                             fontStyle: pw.FontStyle.italic,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   // Right: Invoice info box
// //                   pw.Expanded(
// //                     flex: 1,
// //                     child: pw.Container(
// //                       padding: const pw.EdgeInsets.all(8),
// //                       decoration: pw.BoxDecoration(
// //                         border: pw.Border.all(color: PdfColors.grey400),
// //                       ),
// //                       child: pw.Column(
// //                         crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                         children: [
// //                           pw.Text(
// //                             'Proforma Invoice',
// //                             style: pw.TextStyle(
// //                               fontWeight: pw.FontWeight.bold,
// //                               fontSize: 11,
// //                             ),
// //                           ),
// //                           pw.Divider(color: PdfColors.grey400, height: 6),
// //                           pw.Text(
// //                             DateFormat('MMM-dd-yyyy').format(invoice.issueDate),
// //                             style: smallStyle,
// //                           ),
// //                           pw.Text(invoice.invoiceNumber, style: smallStyle),
// //                           pw.Text(invoice.referenceCode, style: smallStyle),
// //                           pw.SizedBox(height: 6),
// //                           pw.Text(
// //                             invoice.companyName,
// //                             style: pw.TextStyle(
// //                               fontWeight: pw.FontWeight.bold,
// //                               fontSize: 9,
// //                             ),
// //                           ),
// //                           pw.Text(invoice.companyAddress, style: smallStyle),
// //                           pw.Text(
// //                             'TRN: ${invoice.companyTRN}',
// //                             style: smallStyle,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //
// //               pw.SizedBox(height: 16),
// //               pw.Divider(color: PdfColors.grey400),
// //               pw.SizedBox(height: 10),
// //
// //               // ── CLIENT DETAILS ──
// //               pw.Text(
// //                 'CLIENT DETAILS:',
// //                 style: pw.TextStyle(
// //                   fontWeight: pw.FontWeight.bold,
// //                   fontSize: 11,
// //                 ),
// //               ),
// //               pw.SizedBox(height: 6),
// //               pw.Text(
// //                 invoice.clientName,
// //                 style: pw.TextStyle(
// //                   fontWeight: pw.FontWeight.bold,
// //                   fontSize: 12,
// //                 ),
// //               ),
// //               pw.Text('UNIT - ${invoice.unit}', style: smallBoldStyle),
// //               pw.Text(
// //                 'Location: ${invoice.location}',
// //                 style: pw.TextStyle(
// //                   fontWeight: pw.FontWeight.bold,
// //                   fontSize: 9,
// //                 ),
// //               ),
// //               pw.Text(
// //                 'No. of bedrooms: ${invoice.noOfBedrooms}',
// //                 style: smallStyle,
// //               ),
// //               pw.Text('Email: ${invoice.email}', style: smallStyle),
// //               pw.Text('Sqft: ${invoice.sqft}', style: smallStyle),
// //
// //               // Additional dynamic fields
// //               ...invoice.additionalClientFields.map((field) {
// //                 if (field['label']!.isNotEmpty || field['value']!.isNotEmpty) {
// //                   return pw.Text(
// //                     '${field['label']}: ${field['value']}',
// //                     style: smallStyle,
// //                   );
// //                 }
// //                 return pw.SizedBox();
// //               }),
// //
// //               pw.SizedBox(height: 16),
// //
// //               // ── SERVICE ITEMS TABLE ──
// //               pw.Table(
// //                 border: pw.TableBorder.all(
// //                   color: PdfColors.grey400,
// //                   width: 0.5,
// //                 ),
// //                 columnWidths: {
// //                   0: const pw.FlexColumnWidth(4),
// //                   1: const pw.FlexColumnWidth(1.5),
// //                   2: const pw.FlexColumnWidth(1.5),
// //                   3: const pw.FlexColumnWidth(1.5),
// //                   4: const pw.FlexColumnWidth(2),
// //                 },
// //                 children: [
// //                   // Table header
// //                   pw.TableRow(
// //                     decoration: pw.BoxDecoration(color: tableHeaderBg),
// //                     children: [
// //                       _tableCell('', isHeader: true),
// //                       _tableCell('UNIT', isHeader: true),
// //                       _tableCell('NO. OF UNITS', isHeader: true),
// //                       _tableCell('PER UNIT', isHeader: true),
// //                       _tableCell('Amount (AED)', isHeader: true, align: pw.TextAlign.right),
// //                     ],
// //                   ),
// //                   // Service rows
// //                   ...invoice.serviceItems.map((item) {
// //                     return pw.TableRow(
// //                       children: [
// //                         pw.Padding(
// //                           padding: const pw.EdgeInsets.all(6),
// //                           child: pw.Text(item.itemName, style: smallStyle),
// //                         ),
// //                         _tableCell(item.unit),
// //                         _tableCell(item.noOfUnits.toString()),
// //                         _tableCell(item.perUnit > 0 ? item.perUnit.toStringAsFixed(0) : ''),
// //                         _tableCell(
// //                           item.amount > 0 ? item.amount.toStringAsFixed(2) : '0.00',
// //                           align: pw.TextAlign.right,
// //                         ),
// //                       ],
// //                     );
// //                   }),
// //                   // Subtotal row
// //                   pw.TableRow(
// //                     decoration: const pw.BoxDecoration(color: PdfColors.white),
// //                     children: [
// //                       _tableCell(''),
// //                       _tableCell(''),
// //                       _tableCell(''),
// //                       _tableCell(''),
// //                       _tableCell(
// //                         invoice.subtotal.toStringAsFixed(2),
// //                         align: pw.TextAlign.right,
// //                       ),
// //                     ],
// //                   ),
// //                   // VAT row
// //                   pw.TableRow(
// //                     children: [
// //                       _tableCell(''),
// //                       _tableCell(''),
// //                       _tableCell(''),
// //                       pw.Padding(
// //                         padding: const pw.EdgeInsets.all(6),
// //                         child: pw.Text(
// //                           'VAT ${invoice.vatRate.toInt()}% (AED):',
// //                           style: pw.TextStyle(
// //                             fontSize: 9,
// //                             fontWeight: pw.FontWeight.bold,
// //                           ),
// //                           textAlign: pw.TextAlign.right,
// //                         ),
// //                       ),
// //                       _tableCell(
// //                         invoice.vatAmount.toStringAsFixed(2),
// //                         align: pw.TextAlign.right,
// //                       ),
// //                     ],
// //                   ),
// //                   // Total row
// //                   pw.TableRow(
// //                     decoration: pw.BoxDecoration(color: tableHeaderBg),
// //                     children: [
// //                       _tableCell(''),
// //                       _tableCell(''),
// //                       _tableCell(''),
// //                       pw.Padding(
// //                         padding: const pw.EdgeInsets.all(6),
// //                         child: pw.Text(
// //                           'Total Amount (AED):',
// //                           style: pw.TextStyle(
// //                             fontSize: 10,
// //                             fontWeight: pw.FontWeight.bold,
// //                           ),
// //                           textAlign: pw.TextAlign.right,
// //                         ),
// //                       ),
// //                       pw.Padding(
// //                         padding: const pw.EdgeInsets.all(6),
// //                         child: pw.Text(
// //                           invoice.totalAmount.toStringAsFixed(2),
// //                           style: pw.TextStyle(
// //                             fontSize: 10,
// //                             fontWeight: pw.FontWeight.bold,
// //                           ),
// //                           textAlign: pw.TextAlign.right,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //
// //               pw.SizedBox(height: 16),
// //
// //               // ── TERMS ──
// //               pw.Text(
// //                 'TERMS AND CONDITIONS :',
// //                 style: pw.TextStyle(
// //                   fontWeight: pw.FontWeight.bold,
// //                   fontSize: 10,
// //                 ),
// //               ),
// //               pw.SizedBox(height: 4),
// //               pw.Text(
// //                 invoice.termsAndConditions,
// //                 style: pw.TextStyle(
// //                   color: redColor,
// //                   fontSize: 10,
// //                   fontWeight: pw.FontWeight.bold,
// //                 ),
// //               ),
// //               pw.SizedBox(height: 10),
// //               pw.Text(
// //                 'TERMS OF PAYMENT :',
// //                 style: pw.TextStyle(
// //                   fontWeight: pw.FontWeight.bold,
// //                   fontSize: 10,
// //                 ),
// //               ),
// //               pw.SizedBox(height: 4),
// //               pw.Text(
// //                 invoice.termsOfPayment,
// //                 style: pw.TextStyle(
// //                   color: redColor,
// //                   fontSize: 10,
// //                   fontWeight: pw.FontWeight.bold,
// //                 ),
// //               ),
// //               pw.SizedBox(height: 14),
// //
// //               // ── BANK DETAILS ──
// //               pw.Text(
// //                 'Account Details:',
// //                 style: pw.TextStyle(
// //                   fontWeight: pw.FontWeight.bold,
// //                   fontSize: 10,
// //                   color: orangeColor,
// //                 ),
// //               ),
// //               pw.Text(
// //                 'Bank Transfer Details:',
// //                 style: pw.TextStyle(
// //                   fontWeight: pw.FontWeight.bold,
// //                   fontSize: 9,
// //                   color: orangeColor,
// //                 ),
// //               ),
// //               pw.Text(
// //                 '**Note: The Remitter bears ALL charges of the banks engaged in the transfer of payment',
// //                 style: pw.TextStyle(
// //                   fontWeight: pw.FontWeight.bold,
// //                   fontSize: 8,
// //                   color: orangeColor,
// //                 ),
// //               ),
// //               pw.SizedBox(height: 8),
// //               _bankDetailRow('Company Name', invoice.bankCompanyName),
// //               _bankDetailRow('Account Number', '${invoice.accountNumber},'),
// //               _bankDetailRow('IBN Number', invoice.ibanNumber),
// //               _bankDetailRow('Swift Bic', invoice.swiftBic),
// //               _bankDetailRow('Bank Name', invoice.bankName),
// //               _bankDetailRow('Branch Name', invoice.branchName),
// //
// //               pw.SizedBox(height: 16),
// //
// //               pw.Text(
// //                 'COMPANY SEAL & SIGNATURE',
// //                 style: pw.TextStyle(
// //                   fontWeight: pw.FontWeight.bold,
// //                   fontSize: 10,
// //                 ),
// //               ),
// //               pw.SizedBox(height: 50),
// //
// //               // ── FOOTER ──
// //               pw.Divider(color: tealGreen, thickness: 1),
// //               pw.SizedBox(height: 4),
// //               pw.Center(
// //                 child: pw.Text(
// //                   'Office 201, Insurance Building, Dubai , Dubai UAE Tel: +971561300654 | www.propertyinspectiondxb.com',
// //                   style: pw.TextStyle(
// //                     fontSize: 8,
// //                     color: PdfColors.grey700,
// //                   ),
// //                   textAlign: pw.TextAlign.center,
// //                 ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //
// //     // Save to temp directory
// //     final dir = Directory.systemTemp;
// //     final invoiceNum = invoice.invoiceNumberShort;
// //     final clientName = invoice.clientName
// //         .toUpperCase()
// //         .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
// //         .trim();
// //     final fileName = 'Tax Invoice_$invoiceNum\_$clientName.pdf';
// //     final file = File('${dir.path}/$fileName');
// //     await file.writeAsBytes(await pdf.save());
// //     return file;
// //   }
// //
// //   static pw.Widget _tableCell(
// //     String text, {
// //     bool isHeader = false,
// //     pw.TextAlign align = pw.TextAlign.left,
// //   }) {
// //     return pw.Padding(
// //       padding: const pw.EdgeInsets.all(6),
// //       child: pw.Text(
// //         text,
// //         style: pw.TextStyle(
// //           fontSize: 9,
// //           fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
// //         ),
// //         textAlign: align,
// //       ),
// //     );
// //   }
// //
// //   static pw.Widget _bankDetailRow(String label, String value) {
// //     return pw.Padding(
// //       padding: const pw.EdgeInsets.symmetric(vertical: 2),
// //       child: pw.Row(
// //         children: [
// //           pw.SizedBox(
// //             width: 120,
// //             child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
// //           ),
// //           pw.Text(': ', style: const pw.TextStyle(fontSize: 9)),
// //           pw.Expanded(
// //             child: pw.Text(
// //               value,
// //               style: pw.TextStyle(
// //                 fontSize: 9,
// //                 fontWeight: pw.FontWeight.bold,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
//
// import 'invoice_model.dart';
//
// class PdfGeneratorService {
//   static Future<File> generateInvoicePdf(InvoiceModel invoice) async {
//     final pdf = pw.Document();
//
//     // Load Assets
//     final logoImage = pw.MemoryImage(
//       (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
//     );
//     final sealImage = pw.MemoryImage(
//       (await rootBundle.load('assets/images/seal.png')).buffer.asUint8List(),
//     );
//
//     // Exact colors from screenshot
//     const redTextColor = PdfColor.fromInt(0xFFFF0000);
//     const orangeTextColor = PdfColor.fromInt(0xFFFF4500);
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // ── HEADER SECTION ──
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Image(logoImage, width: 220),
//                       pw.SizedBox(height: 15),
//                       pw.Text(
//                         'Inspecting for the unexpected',
//                         style: pw.TextStyle(
//                           fontSize: 10,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   // Top Right Info Box
//                   pw.Container(
//                     width: 160,
//                     decoration: pw.BoxDecoration(
//                       border: pw.Border.all(color: PdfColors.black, width: 1),
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         _infoBoxRow('Proforma Invoice', isBold: true),
//                         _infoBoxRow(DateFormat('MMM-dd-yyyy').format(invoice.issueDate)),
//                         _infoBoxRow(invoice.invoiceNumber),
//                         _infoBoxRow(invoice.referenceCode),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(4),
//                           child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text(invoice.companyName.toUpperCase(),
//                                   style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
//                               pw.Text(invoice.companyAddress, style: const pw.TextStyle(fontSize: 8)),
//                               pw.Text('TRN: ${invoice.companyTRN}',
//                                   style: const pw.TextStyle(fontSize: 8)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//
//               pw.SizedBox(height: 20),
//
//               // ── CLIENT DETAILS ──
//               pw.Text('CLIENT DETAILS:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
//               pw.SizedBox(height: 5),
//               pw.Text(invoice.clientName.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
//               pw.Text('UNIT - ${invoice.unit}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
//               pw.Text('Location: ${invoice.location}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
//               pw.Text('No. of bedrooms: ${invoice.noOfBedrooms}', style: const pw.TextStyle(fontSize: 9)),
//               pw.Text('Email: ${invoice.email}', style: const pw.TextStyle(fontSize: 9)),
//               pw.Text('Sqft: ${invoice.sqft}', style: const pw.TextStyle(fontSize: 9)),
//
//               pw.SizedBox(height: 15),
//
//               // ── DATA TABLE ──
//               pw.Table(
//                 border: pw.TableBorder.all(color: PdfColors.black, width: 1),
//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(3.5),
//                   1: const pw.FixedColumnWidth(60),
//                   2: const pw.FixedColumnWidth(70),
//                   3: const pw.FixedColumnWidth(70),
//                   4: const pw.FixedColumnWidth(100),
//                 },
//                 children: [
//                   // Header
//                   pw.TableRow(
//                     children: [
//                       _tableCell(''),
//                       _tableCell('UNIT', isHeader: true),
//                       _tableCell('NO. OF UNITS', isHeader: true),
//                       _tableCell('PER UNIT', isHeader: true),
//                       _tableCell('Amount (AED)', isHeader: true),
//                     ],
//                   ),
//                   // Items
//                   ...invoice.serviceItems.map((item) => pw.TableRow(
//                     children: [
//                       _tableCell(item.itemName, align: pw.TextAlign.left),
//                       _tableCell(item.unit),
//                       _tableCell(item.noOfUnits.toString()),
//                       _tableCell(item.perUnit.toStringAsFixed(0)),
//                       _tableCell(item.amount.toStringAsFixed(2), align: pw.TextAlign.right),
//                     ],
//                   )),
//                   // Empty Spacer Row
//                   pw.TableRow(children: [_tableCell(''), _tableCell(''), _tableCell(''), _tableCell(''), _tableCell('')]),
//                   // Subtotal
//                   pw.TableRow(
//                     children: [
//                       _tableCell(''), _tableCell(''), _tableCell(''), _tableCell(''),
//                       _tableCell(invoice.subtotal.toStringAsFixed(2), align: pw.TextAlign.right, isHeader: true),
//                     ],
//                   ),
//                   // VAT
//                   pw.TableRow(
//                     children: [
//                       _tableCell(''), _tableCell(''), _tableCell(''),
//                       _tableCell('VAT 5% (AED):', align: pw.TextAlign.right, isHeader: true),
//                       _tableCell(invoice.vatAmount.toStringAsFixed(2), align: pw.TextAlign.right, isHeader: true),
//                     ],
//                   ),
//                   // Total
//                   pw.TableRow(
//                     children: [
//                       _tableCell(''), _tableCell(''), _tableCell(''),
//                       _tableCell('Total Amount (AED):', align: pw.TextAlign.right, isHeader: true),
//                       _tableCell(invoice.totalAmount.toStringAsFixed(2), align: pw.TextAlign.right, isHeader: true),
//                     ],
//                   ),
//                 ],
//               ),
//
//               pw.SizedBox(height: 20),
//
//               // ── TERMS ──
//               pw.Text('TERMS AND CONDITIONS :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
//               pw.Text('As per Proposal', style: pw.TextStyle(color: redTextColor, fontWeight: pw.FontWeight.bold, fontSize: 9)),
//               pw.SizedBox(height: 10),
//               pw.Text('TERMS OF PAYMENT :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
//               pw.Text('100% of the fees payable before commencing any work.',
//                   style: pw.TextStyle(color: redTextColor, fontWeight: pw.FontWeight.bold, fontSize: 9)),
//
//               pw.SizedBox(height: 15),
//
//               // ── BANK DETAILS ──
//               pw.Text('Account Details:', style: pw.TextStyle(color: redTextColor, fontWeight: pw.FontWeight.bold, fontSize: 10, decoration: pw.TextDecoration.underline)),
//               pw.Text('Bank Transfer Details:', style: pw.TextStyle(color: redTextColor, fontWeight: pw.FontWeight.bold, fontSize: 9)),
//               pw.Text('**Note: The Remitter bears ALL charges of the banks engaged in the transfer of payment',
//                   style: pw.TextStyle(color: redTextColor, fontWeight: pw.FontWeight.bold, fontSize: 8)),
//               pw.SizedBox(height: 10),
//
//               _bankRow('Company Name', invoice.bankCompanyName),
//               _bankRow('Account Number', '${invoice.accountNumber},'),
//               _bankRow('IBN Number', invoice.ibanNumber),
//               _bankRow('Swift Bic', invoice.swiftBic),
//               _bankRow('Bank Name', invoice.bankName),
//               _bankRow('Branch Name', invoice.branchName),
//
//               pw.SizedBox(height: 20),
//               pw.Text('COMPANY SEAL & SIGNATURE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
//               pw.SizedBox(height: 10),
//               pw.Image(sealImage, width: 100),
//
//               pw.Spacer(),
//
//               // ── FOOTER ──
//               pw.Divider(thickness: 0.5),
//               pw.Center(
//                 child: pw.Text(
//                   'Office 201, Insurance Building, Dubai , Dubai UAE Tel: +971561300654 | www.propertyinspectiondxb.com',
//                   style: const pw.TextStyle(fontSize: 8),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//
//     final output = await getTemporaryDirectory();
//     final file = File("${output.path}/invoice_${invoice.invoiceNumber}.pdf");
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }
//
//   static pw.Widget _infoBoxRow(String text, {bool isBold = false}) {
//     return pw.Container(
//       width: double.infinity,
//       padding: const pw.EdgeInsets.all(3),
//       decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
//       child: pw.Text(text, style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
//     );
//   }
//
//   static pw.Widget _tableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.center}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(4),
//       child: pw.Text(
//         text,
//         textAlign: align,
//         style: pw.TextStyle(fontSize: 8, fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal),
//       ),
//     );
//   }
//
//   static pw.Widget _bankRow(String label, String value) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 1),
//       child: pw.Row(
//         children: [
//           pw.SizedBox(width: 120, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
//           pw.Text(':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
//           pw.SizedBox(width: 10),
//           pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'invoice_model.dart';

class PdfGeneratorService {
  static Future<File> generateInvoicePdf(InvoiceModel invoice) async {
    final pdf = pw.Document();

    // --- Load Assets ---
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );
    final sealImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/seal.png')).buffer.asUint8List(),
    );

    // --- SaaS Palette for PDF ---
    const pdfEmerald = PdfColor.fromInt(0xFF10B981);
    const pdfDeepTeal = PdfColor.fromInt(0xFF064E3B);
    const pdfDarkSlate = PdfColor.fromInt(0xFF0F172A);
    const pdfMutedSlate = PdfColor.fromInt(0xFF64748B);
    const pdfBgSlate = PdfColor.fromInt(0xFFF1F5F9);
    const pdfBorderColor = PdfColor.fromInt(0xFFE2E8F0);
    const pdfWarningRed = PdfColor.fromInt(0xFFB91C1C);
    const pdfNoteOrange = PdfColor.fromInt(0xFF9A3412);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0), // Full bleed for header gradient
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // --- 1. MODERN GRADIENT HEADER ---
              pw.Container(
                padding: const pw.EdgeInsets.fromLTRB(40, 40, 40, 30),
                decoration: const pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [pdfDeepTeal, pdfEmerald],
                    begin: pw.Alignment.topLeft,
                    end: pw.Alignment.bottomRight,
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Image(logoImage, width: 150),
                        pw.SizedBox(height: 10),
                        pw.Text('RA PROPERTY OBSERVER LLC',
                            style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text('Inspecting for the unexpected',
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontStyle: pw.FontStyle.italic)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        // Using a solid light emerald-white blend instead of transparency
                        // This prevents the "white box" glitch in mobile PDF viewers.
                        color: PdfColor.fromInt(0x33E1F5FE),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                        border: pw.Border.all(
                          color: PdfColors.white, // Solid white thin border for the "glass" edge
                          width: 0.7,
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(
                            'PROFORMA INVOICE',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                              letterSpacing: 1.0,
                            ),
                          ),
                          // A small white line for high-end SaaS styling
                          pw.Container(
                            margin: const pw.EdgeInsets.symmetric(vertical: 4),
                            height: 0.5,
                            width: 30,
                            color: PdfColors.white,
                          ),
                          pw.Text(
                            DateFormat('MMM dd, yyyy').format(invoice.issueDate),
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 8,
                            ),
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            invoice.invoiceNumber,
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            invoice.referenceCode,
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // pw.Container(
                    //   padding: const pw.EdgeInsets.all(14),
                    //   decoration: pw.BoxDecoration(
                    //     // A more sophisticated 'Frosted Glass' effect (15% white opacity)
                    //     color: PdfColor.fromInt(0x26FFFFFF),
                    //     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                    //     // Adding a subtle white border makes the glass "pop" against the green
                    //     border: pw.Border.all(
                    //       color: PdfColor.fromInt(0x4DFFFFFF), // 30% white border
                    //       width: 0.5,
                    //     ),
                    //   ),
                    //   child: pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.start,
                    //     mainAxisSize: pw.MainAxisSize.min,
                    //     children: [
                    //       // Primary Label with extra spacing and slight color highlight
                    //       pw.Text(
                    //         'PROFORMA INVOICE',
                    //         style: pw.TextStyle(
                    //           color: PdfColors.white,
                    //           fontWeight: pw.FontWeight.bold,
                    //           fontSize: 10,
                    //           letterSpacing: 1.2, // SaaS-style wide tracking
                    //         ),
                    //       ),
                    //       pw.SizedBox(height: 8),
                    //
                    //       // Secondary Info with 85% opacity white for visual hierarchy
                    //       pw.Text(
                    //         DateFormat('MMM dd, yyyy').format(invoice.issueDate),
                    //         style: pw.TextStyle(
                    //           color: PdfColor.fromInt(0xD9FFFFFF), // 85% opacity white
                    //           fontSize: 9,
                    //         ),
                    //       ),
                    //       pw.SizedBox(height: 2),
                    //       pw.Text(
                    //         invoice.invoiceNumber,
                    //         style: pw.TextStyle(
                    //           color: PdfColors.white,
                    //           fontSize: 10,
                    //           fontWeight: pw.FontWeight.bold,
                    //         ),
                    //       ),
                    //       pw.SizedBox(height: 2),
                    //       pw.Text(
                    //         invoice.referenceCode,
                    //         style: pw.TextStyle(
                    //           color: PdfColor.fromInt(0xB3FFFFFF), // 70% opacity white for reference
                    //           fontSize: 8,
                    //           fontStyle: pw.FontStyle.italic,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // pw.Container(
                    //   padding: const pw.EdgeInsets.all(12),
                    //   decoration: pw.BoxDecoration(
                    //     color: PdfColor.fromInt(0x26FFFFFF),
                    //     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    //   ),
                    //   child: pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.start,
                    //     children: [
                    //       pw.Text('PROFORMA INVOICE',
                    //           style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    //       pw.SizedBox(height: 5),
                    //       pw.Text(DateFormat('MMM dd, yyyy').format(invoice.issueDate),
                    //           style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                    //       pw.Text(invoice.invoiceNumber,
                    //           style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    //       pw.Text(invoice.referenceCode,
                    //           style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),

              // --- MAIN BODY CONTENT ---
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // --- CLIENT & COMPANY DETAILS ---
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('CLIENT DETAILS:',
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: pdfMutedSlate)),
                              pw.SizedBox(height: 5),
                              if (invoice.useRichTextClientDetails)
                                _buildRichText(invoice.richTextClientDetails, const pw.TextStyle(fontSize: 9))
                              else ...[
                                pw.Text(invoice.clientName.toUpperCase(),
                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: pdfDarkSlate)),
                                pw.Text('UNIT - ${invoice.unit}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                                pw.Text('Location: ${invoice.location}',
                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                                pw.Text('Email: ${invoice.email}', style: const pw.TextStyle(fontSize: 9)),
                                pw.Text('Sqft: ${invoice.sqft}', style: const pw.TextStyle(fontSize: 9)),
                                // RESTORED: Additional Client Fields Loop
                                ...invoice.additionalClientFields
                                    .where((f) => f['label']!.isNotEmpty || f['value']!.isNotEmpty)
                                    .map((f) => pw.Text('${f['label']}: ${f['value']}', style: const pw.TextStyle(fontSize: 9))),
                              ],
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(invoice.companyName.toUpperCase(), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                              pw.Text(invoice.companyAddress, textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8)),
                              pw.Text('TRN: ${invoice.companyTRN}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: pdfEmerald)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 25),

                    // --- TABLE (STRICT LOGIC RETAINED) ---
                    pw.Table(
                      border: pw.TableBorder.all(color: pdfBorderColor, width: 0.5),
                      children: [
                        // Header
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: pdfBgSlate),
                          children: [
                            _tableCell('DESCRIPTION', isHeader: true, align: pw.TextAlign.left),
                            _tableCell('UNIT', isHeader: true),
                            _tableCell('QTY', isHeader: true),
                            _tableCell('PRICE', isHeader: true),
                            _tableCell('AMOUNT (AED)', isHeader: true, align: pw.TextAlign.right),
                          ],
                        ),
                        // Items
                        ...invoice.serviceItems.map((item) => pw.TableRow(
                          children: [
                            _tableCell(item.itemName, align: pw.TextAlign.left),
                            _tableCell(item.unit),
                            _tableCell(item.noOfUnits.toString()),
                            // RESTORED: item.perUnit > 0 Logic
                            _tableCell(item.perUnit > 0 ? item.perUnit.toStringAsFixed(0) : ''),
                            _tableCell(item.amount.toStringAsFixed(2), align: pw.TextAlign.right),
                          ],
                        )),
                        // Subtotal
                        pw.TableRow(
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.SizedBox()),
                            pw.SizedBox(), pw.SizedBox(),
                            _tableCell('Subtotal', align: pw.TextAlign.right, isHeader: true),
                            _tableCell(invoice.subtotal.toStringAsFixed(2), align: pw.TextAlign.right, isHeader: true),
                          ],
                        ),
                        // VAT
                        pw.TableRow(
                          children: [
                            pw.SizedBox(), pw.SizedBox(), pw.SizedBox(),
                            _tableCell('VAT ${invoice.vatRate.toInt()}%', align: pw.TextAlign.right, isHeader: true),
                            _tableCell(invoice.vatAmount.toStringAsFixed(2), align: pw.TextAlign.right, isHeader: true),
                          ],
                        ),
                        // Total
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: pdfBgSlate),
                          children: [
                            pw.SizedBox(), pw.SizedBox(), pw.SizedBox(),
                            _tableCell('Total Amount', align: pw.TextAlign.right, isHeader: true),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(
                                'AED ${invoice.totalAmount.toStringAsFixed(2)}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: pdfDeepTeal),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 20),

                    // --- TERMS ---
                    pw.Text('TERMS AND CONDITIONS :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.Text(invoice.termsAndConditions, style: pw.TextStyle(color: pdfWarningRed, fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.SizedBox(height: 8),
                    pw.Text('TERMS OF PAYMENT :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.Text(invoice.termsOfPayment, style: pw.TextStyle(color: pdfWarningRed, fontWeight: pw.FontWeight.bold, fontSize: 9)),

                    pw.SizedBox(height: 20),

                    // --- BANK DETAILS (RESTORED STRICT LABELS) ---
                    pw.Text('Account Details:', style: pw.TextStyle(color: pdfNoteOrange, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('Bank Transfer Details:', style: pw.TextStyle(color: pdfNoteOrange, fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.Text('**Note: The Remitter bears ALL charges of the banks engaged in the transfer of payment',
                        style: pw.TextStyle(color: pdfNoteOrange, fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    pw.SizedBox(height: 8),

                    _bankRow('Company Name', invoice.bankCompanyName),
                    _bankRow('Account Number', '${invoice.accountNumber},'),
                    _bankRow('IBN Number', invoice.ibanNumber),
                    _bankRow('Swift Bic', invoice.swiftBic),
                    _bankRow('Bank Name', invoice.bankName),
                    _bankRow('Branch Name', invoice.branchName),

                    pw.SizedBox(height: 30),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('COMPANY SEAL & SIGNATURE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: pdfMutedSlate)),
                        pw.Image(sealImage, width: 90),
                      ],
                    ),

                    // pw.Spacer(),
                    pw.SizedBox(height: 40), // FIXED
                    // --- FOOTER ---
                    pw.Divider(thickness: 1, color: pdfEmerald),
                    pw.Center(
                      child: pw.Text(
                        'Office 201, Insurance Building, Dubai , Dubai UAE Tel: +971561300654 | www.propertyinspectiondxb.com',
                        style: const pw.TextStyle(fontSize: 8, color: pdfMutedSlate),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Tax_Invoice_${invoice.invoiceNumberShort}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 8,
          color: isHeader ? PdfColors.blueGrey900 : PdfColors.black,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildRichText(String text, pw.TextStyle baseStyle) {
    if (text.isEmpty) return pw.SizedBox();

    final List<pw.TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');

    int lastMatchEnd = 0;
    for (final Match match in regExp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(pw.TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(pw.TextSpan(
        text: match.group(1),
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(pw.TextSpan(text: text.substring(lastMatchEnd)));
    }

    return pw.RichText(
      text: pw.TextSpan(
        style: baseStyle,
        children: spans,
      ),
    );
  }

  static pw.Widget _bankRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 110, child: pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey700))),
          pw.Text(':  ', style: const pw.TextStyle(fontSize: 9)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
        ],
      ),
    );
  }
}
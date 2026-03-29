// import 'dart:io';
// import 'package:dxb_office_work/pdf_generator_service.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:path_provider/path_provider.dart';
//
// import 'invoice_model.dart';
//
//
// class PreviewScreen extends StatefulWidget {
//   final InvoiceModel invoice;
//   const PreviewScreen({super.key, required this.invoice});
//
//   @override
//   State<PreviewScreen> createState() => _PreviewScreenState();
// }
//
// class _PreviewScreenState extends State<PreviewScreen> {
//   bool _isGenerating = false;
//   File? _generatedFile;
//   String? _errorMessage;
//
//   Future<void> _generateAndSave() async {
//     setState(() {
//       _isGenerating = true;
//       _errorMessage = null;
//     });
//     try {
//       final file =
//           await PdfGeneratorService.generateInvoicePdf(widget.invoice);
//
//       // Copy to downloads/documents directory
//       final docsDir = await getApplicationDocumentsDirectory();
//       final invoiceNum = widget.invoice.invoiceNumberShort;
//       final clientName = widget.invoice.clientName
//           .toUpperCase()
//           .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
//           .trim();
//       final fileName = 'Tax Invoice_${invoiceNum}_$clientName.pdf';
//       final savedFile = await file.copy('${docsDir.path}/$fileName');
//
//       setState(() {
//         _generatedFile = savedFile;
//         _isGenerating = false;
//       });
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('PDF saved: $fileName'),
//             backgroundColor: Colors.green,
//             action: SnackBarAction(
//               label: 'Share',
//               textColor: Colors.white,
//               onPressed: _shareFile,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isGenerating = false;
//         _errorMessage = 'Error: ${e.toString()}';
//       });
//     }
//   }
//
//   Future<void> _shareFile() async {
//     if (_generatedFile == null) {
//       await _generateAndSave();
//       if (_generatedFile == null) return;
//     }
//
//     final invoiceNum = widget.invoice.invoiceNumberShort;
//     final clientName = widget.invoice.clientName
//         .toUpperCase()
//         .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
//         .trim();
//     final fileName = 'Tax Invoice_${invoiceNum}_$clientName.pdf';
//
//     await Share.shareXFiles(
//       [XFile(_generatedFile!.path)],
//       text: 'Proforma Invoice - $fileName',
//       subject: fileName,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final inv = widget.invoice;
//     final teal = const Color(0xFF00897B);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Preview Invoice',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             tooltip: 'Share PDF',
//             onPressed: _isGenerating ? null : _shareFile,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           if (_errorMessage != null)
//             Container(
//               width: double.infinity,
//               color: Colors.red[50],
//               padding: const EdgeInsets.all(10),
//               child: Text(_errorMessage!,
//                   style: const TextStyle(color: Colors.red)),
//             ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           flex: 2,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               RichText(
//                                 text: TextSpan(
//                                   children: [
//                                     TextSpan(
//                                       text: 'PROPERTY\nINSPECTION',
//                                       style: TextStyle(
//                                         color: teal,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18,
//                                         height: 1.2,
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: ' DXB',
//                                       style: TextStyle(
//                                         color: const Color(0xFF004D40),
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Text(
//                                 'RA PROPERTY OBSERVER LLC',
//                                 style: TextStyle(
//                                   color: const Color(0xFF004D40),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 9,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                               const SizedBox(height: 6),
//                               const Text(
//                                 'Inspecting for the unexpected',
//                                 style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 10,
//                                     fontStyle: FontStyle.italic),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey[400]!),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Proforma Invoice',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 11,
//                                   ),
//                                 ),
//                                 const Divider(height: 8),
//                                 Text(
//                                   DateFormat('MMM-dd-yyyy')
//                                       .format(inv.issueDate),
//                                   style: const TextStyle(fontSize: 9),
//                                 ),
//                                 Text(inv.invoiceNumber,
//                                     style: const TextStyle(fontSize: 9)),
//                                 Text(inv.referenceCode,
//                                     style: const TextStyle(fontSize: 9)),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   inv.companyName,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 8),
//                                 ),
//                                 Text(inv.companyAddress,
//                                     style: const TextStyle(fontSize: 8)),
//                                 Text('TRN: ${inv.companyTRN}',
//                                     style: const TextStyle(fontSize: 8)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     const Divider(),
//                     const SizedBox(height: 8),
//
//                     // Client Details
//                     const Text(
//                       'CLIENT DETAILS:',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 10),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       inv.clientName,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 13),
//                     ),
//                     Text('UNIT - ${inv.unit}',
//                         style: const TextStyle(
//                             fontSize: 9, fontWeight: FontWeight.bold)),
//                     Text(
//                       'Location: ${inv.location}',
//                       style: const TextStyle(
//                           fontSize: 9, fontWeight: FontWeight.bold),
//                     ),
//                     Text('No. of bedrooms: ${inv.noOfBedrooms}',
//                         style: const TextStyle(fontSize: 9)),
//                     Text('Email: ${inv.email}',
//                         style: const TextStyle(fontSize: 9)),
//                     Text('Sqft: ${inv.sqft}',
//                         style: const TextStyle(fontSize: 9)),
//                     ...inv.additionalClientFields
//                         .where((f) =>
//                             f['label']!.isNotEmpty || f['value']!.isNotEmpty)
//                         .map((f) => Text(
//                               '${f['label']}: ${f['value']}',
//                               style: const TextStyle(fontSize: 9),
//                             )),
//                     const SizedBox(height: 12),
//
//                     // Table
//                     Table(
//                       border: TableBorder.all(
//                           color: Colors.grey[400]!, width: 0.5),
//                       columnWidths: const {
//                         0: FlexColumnWidth(4),
//                         1: FlexColumnWidth(1.5),
//                         2: FlexColumnWidth(1.5),
//                         3: FlexColumnWidth(1.5),
//                         4: FlexColumnWidth(2),
//                       },
//                       children: [
//                         TableRow(
//                           decoration: BoxDecoration(
//                               color: const Color(0xFFE0F2F1)),
//                           children: [
//                             _tableHeader(''),
//                             _tableHeader('UNIT'),
//                             _tableHeader('NO. OF UNITS'),
//                             _tableHeader('PER UNIT'),
//                             _tableHeader('Amount (AED)',
//                                 align: TextAlign.right),
//                           ],
//                         ),
//                         ...inv.serviceItems.map((item) => TableRow(
//                               children: [
//                                 _tableCell(item.itemName),
//                                 _tableCell(item.unit),
//                                 _tableCell(item.noOfUnits.toString()),
//                                 _tableCell(item.perUnit > 0
//                                     ? item.perUnit.toStringAsFixed(0)
//                                     : ''),
//                                 _tableCell(
//                                   item.amount > 0
//                                       ? item.amount.toStringAsFixed(2)
//                                       : '0.00',
//                                   align: TextAlign.right,
//                                 ),
//                               ],
//                             )),
//                         TableRow(children: [
//                           _tableCell(''),
//                           _tableCell(''),
//                           _tableCell(''),
//                           _tableCell(''),
//                           _tableCell(
//                             inv.subtotal.toStringAsFixed(2),
//                             align: TextAlign.right,
//                           ),
//                         ]),
//                         TableRow(children: [
//                           _tableCell(''),
//                           _tableCell(''),
//                           _tableCell(''),
//                           Padding(
//                             padding: const EdgeInsets.all(5),
//                             child: Text(
//                               'VAT ${inv.vatRate.toInt()}% (AED):',
//                               style: const TextStyle(
//                                   fontSize: 8,
//                                   fontWeight: FontWeight.bold),
//                               textAlign: TextAlign.right,
//                             ),
//                           ),
//                           _tableCell(inv.vatAmount.toStringAsFixed(2),
//                               align: TextAlign.right),
//                         ]),
//                         TableRow(
//                           decoration: const BoxDecoration(
//                               color: Color(0xFFE0F2F1)),
//                           children: [
//                             _tableCell(''),
//                             _tableCell(''),
//                             _tableCell(''),
//                             Padding(
//                               padding: const EdgeInsets.all(5),
//                               child: Text(
//                                 'Total Amount (AED):',
//                                 style: const TextStyle(
//                                     fontSize: 9,
//                                     fontWeight: FontWeight.bold),
//                                 textAlign: TextAlign.right,
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(5),
//                               child: Text(
//                                 inv.totalAmount.toStringAsFixed(2),
//                                 style: const TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold),
//                                 textAlign: TextAlign.right,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//
//                     // Terms
//                     const Text(
//                       'TERMS AND CONDITIONS :',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 10),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       inv.termsAndConditions,
//                       style: TextStyle(
//                           color: Colors.red[700],
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'TERMS OF PAYMENT :',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 10),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       inv.termsOfPayment,
//                       style: TextStyle(
//                           color: Colors.red[700],
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 12),
//
//                     // Bank
//                     Text(
//                       'Account Details:',
//                       style: TextStyle(
//                           color: Colors.orange[800],
//                           fontWeight: FontWeight.bold,
//                           fontSize: 10),
//                     ),
//                     Text(
//                       'Bank Transfer Details:',
//                       style: TextStyle(
//                           color: Colors.orange[800],
//                           fontWeight: FontWeight.bold,
//                           fontSize: 9),
//                     ),
//                     Text(
//                       '**Note: The Remitter bears ALL charges of the banks engaged in the transfer of payment',
//                       style: TextStyle(
//                           color: Colors.orange[800], fontSize: 8),
//                     ),
//                     const SizedBox(height: 6),
//                     _bankRow('Company Name', inv.bankCompanyName),
//                     _bankRow('Account Number', '${inv.accountNumber},'),
//                     _bankRow('IBN Number', inv.ibanNumber),
//                     _bankRow('Swift Bic', inv.swiftBic),
//                     _bankRow('Bank Name', inv.bankName),
//                     _bankRow('Branch Name', inv.branchName),
//
//                     const SizedBox(height: 12),
//                     const Text(
//                       'COMPANY SEAL & SIGNATURE',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 10),
//                     ),
//                     const SizedBox(height: 40),
//
//                     // Footer
//                     Divider(color: teal, thickness: 1),
//                     const SizedBox(height: 4),
//                     const Center(
//                       child: Text(
//                         'Office 201, Insurance Building, Dubai , Dubai UAE Tel: +971561300654 | www.propertyinspectiondxb.com',
//                         style: TextStyle(fontSize: 8, color: Colors.grey),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Bottom action bar
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _isGenerating ? null : _generateAndSave,
//                     icon: _isGenerating
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.download_outlined),
//                     label: Text(_isGenerating ? 'Generating...' : 'Save PDF'),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _isGenerating ? null : _shareFile,
//                     icon: const Icon(Icons.share, color: Colors.white),
//                     label: const Text(
//                       'Share / WhatsApp',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF25D366),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _tableHeader(String text, {TextAlign align = TextAlign.left}) {
//     return Padding(
//       padding: const EdgeInsets.all(5),
//       child: Text(
//         text,
//         style:
//             const TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
//         textAlign: align,
//       ),
//     );
//   }
//
//   Widget _tableCell(String text, {TextAlign align = TextAlign.left}) {
//     return Padding(
//       padding: const EdgeInsets.all(5),
//       child: Text(text, style: const TextStyle(fontSize: 8), textAlign: align),
//     );
//   }
//
//   Widget _bankRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 1.5),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 110,
//             child: Text(label, style: const TextStyle(fontSize: 9)),
//           ),
//           const Text(':  ', style: TextStyle(fontSize: 9)),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                   fontSize: 9, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// //
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:share_plus/share_plus.dart';
// // import 'package:path_provider/path_provider.dart';
// //
// // import 'invoice_model.dart';
// // import 'pdf_generator_service.dart';
// //
// // class PreviewScreen extends StatefulWidget {
// //   final InvoiceModel invoice;
// //   const PreviewScreen({super.key, required this.invoice});
// //
// //   @override
// //   State<PreviewScreen> createState() => _PreviewScreenState();
// // }
// //
// // class _PreviewScreenState extends State<PreviewScreen> {
// //   bool _isGenerating = false;
// //   File? _generatedFile;
// //   String? _errorMessage;
// //
// //   // Exact UI Colors from branding
// //   final Color brandRed = const Color(0xFFFF0000);
// //   final Color brandOrange = const Color(0xFFFF4500);
// //
// //   Future<void> _generateAndSave() async {
// //     setState(() {
// //       _isGenerating = true;
// //       _errorMessage = null;
// //     });
// //     try {
// //       final file = await PdfGeneratorService.generateInvoicePdf(widget.invoice);
// //
// //       final docsDir = await getApplicationDocumentsDirectory();
// //       final invoiceNum = widget.invoice.invoiceNumberShort;
// //       final clientName = widget.invoice.clientName
// //           .toUpperCase()
// //           .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
// //           .trim();
// //       final fileName = 'Tax Invoice_${invoiceNum}_$clientName.pdf';
// //       final savedFile = await file.copy('${docsDir.path}/$fileName');
// //
// //       setState(() {
// //         _generatedFile = savedFile;
// //         _isGenerating = false;
// //       });
// //
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('PDF saved: $fileName'),
// //             backgroundColor: Colors.green,
// //             action: SnackBarAction(
// //               label: 'Share',
// //               textColor: Colors.white,
// //               onPressed: _shareFile,
// //             ),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _isGenerating = false;
// //         _errorMessage = 'Error: ${e.toString()}';
// //       });
// //     }
// //   }
// //
// //   Future<void> _shareFile() async {
// //     if (_generatedFile == null) {
// //       await _generateAndSave();
// //       if (_generatedFile == null) return;
// //     }
// //
// //     final invoiceNum = widget.invoice.invoiceNumberShort;
// //     final clientName = widget.invoice.clientName
// //         .toUpperCase()
// //         .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
// //         .trim();
// //     final fileName = 'Tax Invoice_${invoiceNum}_$clientName.pdf';
// //
// //     await Share.shareXFiles(
// //       [XFile(_generatedFile!.path)],
// //       text: 'Proforma Invoice - $fileName',
// //       subject: fileName,
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final inv = widget.invoice;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.grey[300],
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         title: const Text('Preview Invoice', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
// //         iconTheme: const IconThemeData(color: Colors.black),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.share),
// //             onPressed: _isGenerating ? null : _shareFile,
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           if (_errorMessage != null)
// //             Container(
// //               width: double.infinity,
// //               color: Colors.red[100],
// //               padding: const EdgeInsets.all(8),
// //               child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
// //             ),
// //           Expanded(
// //             child: SingleChildScrollView(
// //               padding: const EdgeInsets.all(12),
// //               child: Container(
// //                 color: Colors.white,
// //                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     // ── HEADER ──
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Image.asset('assets/images/logo.png', width: 180),
// //                             const SizedBox(height: 10),
// //                             const Text(
// //                               'Inspecting for the unexpected',
// //                               style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
// //                             ),
// //                           ],
// //                         ),
// //                         // Top Right Info Box (Matches PDF)
// //                         Container(
// //                           width: 130,
// //                           decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.8)),
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               _infoBoxRow('Proforma Invoice', isBold: true),
// //                               _infoBoxRow(DateFormat('MMM-dd-yyyy').format(inv.issueDate)),
// //                               _infoBoxRow(inv.invoiceNumber),
// //                               _infoBoxRow(inv.referenceCode),
// //                               Padding(
// //                                 padding: const EdgeInsets.all(4),
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Text(inv.companyName.toUpperCase(), style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
// //                                     Text(inv.companyAddress, style: const TextStyle(fontSize: 7)),
// //                                     Text('TRN: ${inv.companyTRN}', style: const TextStyle(fontSize: 7)),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //
// //                     const SizedBox(height: 15),
// //
// //                     // ── CLIENT DETAILS ──
// //                     const Text('CLIENT DETAILS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
// //                     const SizedBox(height: 4),
// //                     Text(inv.clientName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
// //                     Text('UNIT - ${inv.unit}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
// //                     Text('Location: ${inv.location}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
// //                     Text('No. of bedrooms: ${inv.noOfBedrooms}', style: const TextStyle(fontSize: 9)),
// //                     Text('Email: ${inv.email}', style: const TextStyle(fontSize: 9)),
// //                     Text('Sqft: ${inv.sqft}', style: const TextStyle(fontSize: 9)),
// //
// //                     const SizedBox(height: 15),
// //
// //                     // ── DATA TABLE ──
// //                     // Table(
// //                     //   border: TableBorder.all(color: Colors.black, width: 0.8),
// //                     //   columnWidths: const {
// //                     //     0: FlexColumnWidth(3),
// //                     //     1: FixedColumnWidth(40),
// //                     //     2: FixedColumnWidth(60),
// //                     //     3: FixedColumnWidth(50),
// //                     //     4: FixedColumnWidth(80),
// //                     //   },
// //                     //   children: [
// //                     //     TableRow(
// //                     //       children: [
// //                     //         _tableCell(''),
// //                     //         _tableCell('UNIT', isBold: true),
// //                     //         _tableCell('NO. OF UNITS', isBold: true),
// //                     //         _tableCell('PER UNIT', isBold: true),
// //                     //         _tableCell('Amount (AED)', isBold: true),
// //                     //       ],
// //                     //     ),
// //                     //     ...inv.serviceItems.map((item) => TableRow(
// //                     //       children: [
// //                     //         _tableCell(item.itemName, align: TextAlign.left),
// //                     //         _tableCell(item.unit),
// //                     //         _tableCell(item.noOfUnits.toString()),
// //                     //         _tableCell(item.perUnit.toStringAsFixed(0)),
// //                     //         _tableCell(item.amount.toStringAsFixed(2), align: TextAlign.right),
// //                     //       ],
// //                     //     )),
// //                     //     // VAT and Totals
// //                     //     TableRow(
// //                     //       children: [
// //                     //         _tableCell(''), _tableCell(''), _tableCell(''),
// //                     //         _tableCell('VAT 5% (AED):', align: TextAlign.right, isBold: true),
// //                     //         _tableCell(inv.vatAmount.toStringAsFixed(2), align: TextAlign.right, isBold: true),
// //                     //       ],
// //                     //     ),
// //                     //     TableRow(
// //                     //       children: [
// //                     //         _tableCell(''), _tableCell(''), _tableCell(''),
// //                     //         _tableCell('Total (AED):', align: TextAlign.right, isBold: true),
// //                     //         _tableCell(inv.totalAmount.toStringAsFixed(2), align: TextAlign.right, isBold: true),
// //                     //       ],
// //                     //     ),
// //                     //   ],
// //                     // ),
// //                     // ── DATA TABLE ──
// //                     Table(
// //                       border: TableBorder.all(color: Colors.black, width: 0.8),
// //                       columnWidths: const {
// //                         0: FlexColumnWidth(4), // Wider for multi-line description
// //                         1: FixedColumnWidth(55),
// //                         2: FixedColumnWidth(85),
// //                         3: FixedColumnWidth(75),
// //                         4: FixedColumnWidth(110),
// //                       },
// //                       children: [
// //                         // Header Row
// //                         TableRow(
// //                           children: [
// //                             _tableCell(''),
// //                             _tableCell('UNIT', isBold: true),
// //                             _tableCell('NO. OF UNITS', isBold: true),
// //                             _tableCell('PER UNIT', isBold: true),
// //                             _tableCell('Amount (AED)', isBold: true),
// //                           ],
// //                         ),
// //                         // Service Items Row (Exact layout from screenshot)
// //                         ...inv.serviceItems.map((item) => TableRow(
// //                           children: [
// //                             Padding(
// //                               padding: const EdgeInsets.all(4),
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text(item.itemName, style: const TextStyle(fontSize: 8)),
// //                                   const Text('Dubai,UAE', style: TextStyle(fontSize: 8)),
// //                                   const Text('Property Inspection Charges', style: TextStyle(fontSize: 8)),
// //                                 ],
// //                               ),
// //                             ),
// //                             _tableCell(item.unit),
// //                             _tableCell(item.noOfUnits.toString()),
// //                             _tableCell(item.perUnit.toStringAsFixed(0)),
// //                             // Right-aligned column showing 850.00 and 0.00
// //                             Padding(
// //                               padding: const EdgeInsets.all(4),
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.end,
// //                                 children: [
// //                                   Text(item.amount.toStringAsFixed(2),
// //                                       style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
// //                                   const Text('0.00', style: TextStyle(fontSize: 8)),
// //                                   const SizedBox(height: 10), // Space for third line
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         )),
// //                         // Subtotal Row (Middle line in screenshot)
// //                         TableRow(
// //                           children: [
// //                             _tableCell(''),
// //                             _tableCell(''),
// //                             _tableCell(''),
// //                             _tableCell(''),
// //                             _tableCell(inv.subtotal.toStringAsFixed(2), align: TextAlign.right, isBold: true),
// //                           ],
// //                         ),
// //                         // VAT Row
// //                         TableRow(
// //                           children: [
// //                             _tableCell(''),
// //                             _tableCell(''),
// //                             _tableCell(''),
// //                             Padding(
// //                               padding: const EdgeInsets.all(4),
// //                               child: Text('VAT 5% (AED):',
// //                                   textAlign: TextAlign.right,
// //                                   style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
// //                             ),
// //                             _tableCell(inv.vatAmount.toStringAsFixed(2), align: TextAlign.right, isBold: true),
// //                           ],
// //                         ),
// //                         // Total Amount Row
// //                         TableRow(
// //                           children: [
// //                             _tableCell(''),
// //                             _tableCell(''),
// //                             _tableCell(''),
// //                             Padding(
// //                               padding: const EdgeInsets.all(4),
// //                               child: Text('Total Amount (AED):',
// //                                   textAlign: TextAlign.right,
// //                                   style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
// //                             ),
// //                             _tableCell(inv.totalAmount.toStringAsFixed(2), align: TextAlign.right, isBold: true),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //
// //                     const SizedBox(height: 15),
// //
// //                     // ── TERMS ──
// //                     const Text('TERMS AND CONDITIONS :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
// //                     Text('As per Proposal', style: TextStyle(color: brandRed, fontWeight: FontWeight.bold, fontSize: 9)),
// //                     const SizedBox(height: 10),
// //                     const Text('TERMS OF PAYMENT :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
// //                     Text('100% of the fees payable before commencing any work.', style: TextStyle(color: brandRed, fontWeight: FontWeight.bold, fontSize: 9)),
// //
// //                     const SizedBox(height: 15),
// //
// //                     // ── BANK DETAILS ──
// //                     Text('Account Details:', style: TextStyle(color: brandRed, fontWeight: FontWeight.bold, fontSize: 10, decoration: TextDecoration.underline)),
// //                     Text('Bank Transfer Details:', style: TextStyle(color: brandRed, fontWeight: FontWeight.bold, fontSize: 9)),
// //                     const SizedBox(height: 10),
// //                     _bankRow('Company Name', inv.bankCompanyName),
// //                     _bankRow('Account Number', '${inv.accountNumber},'),
// //                     _bankRow('IBN Number', inv.ibanNumber),
// //                     _bankRow('Swift Bic', inv.swiftBic),
// //                     _bankRow('Bank Name', inv.bankName),
// //
// //                     const SizedBox(height: 20),
// //                     const Text('COMPANY SEAL & SIGNATURE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
// //                     const SizedBox(height: 10),
// //                     Image.asset('assets/images/seal.png', width: 80),
// //
// //                     const SizedBox(height: 20),
// //                     const Divider(thickness: 0.5),
// //                     const Center(
// //                       child: Text(
// //                         'Office 201, Insurance Building, Dubai UAE | www.propertyinspectiondxb.com',
// //                         style: TextStyle(fontSize: 7, color: Colors.grey),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //           // Bottom Bar
// //           Container(
// //             padding: const EdgeInsets.all(16),
// //             color: Colors.white,
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: OutlinedButton(
// //                     onPressed: _isGenerating ? null : _generateAndSave,
// //                     child: Text(_isGenerating ? 'Generating...' : 'Save PDF'),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 10),
// //                 Expanded(
// //                   child: ElevatedButton(
// //                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
// //                     onPressed: _isGenerating ? null : _shareFile,
// //                     child: const Text('Share / WhatsApp', style: TextStyle(color: Colors.white)),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _infoBoxRow(String text, {bool isBold = false}) {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(3),
// //       decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 0.5))),
// //       child: Text(text, style: TextStyle(fontSize: 8, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
// //     );
// //   }
// //
// //   Widget _tableCell(String text, {bool isBold = false, TextAlign align = TextAlign.center}) {
// //     return Padding(
// //       padding: const EdgeInsets.all(4),
// //       child: Text(text, textAlign: align, style: TextStyle(fontSize: 8, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
// //     );
// //   }
// //
// //   Widget _bankRow(String label, String value) {
// //     return Row(
// //       children: [
// //         SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9))),
// //         const Text(': ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
// //         Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9))),
// //       ],
// //     );
// //   }
// // }

import 'dart:io';
import 'package:dxb_office_work/pdf_generator_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'invoice_model.dart';

class PreviewScreen extends StatefulWidget {
  final InvoiceModel invoice;
  const PreviewScreen({super.key, required this.invoice});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isGenerating = false;
  File? _generatedFile;
  String? _errorMessage;

  // Modern SaaS Palette
  final Color kPrimaryEmerald = const Color(0xFF10B981);
  final Color kDeepTeal = const Color(0xFF064E3B);
  final Color kDarkSlate = const Color(0xFF0F172A);
  final Color kMutedSlate = const Color(0xFF64748B);
  final Color kBgSlate = const Color(0xFFF1F5F9);
  final Color kBorderColor = const Color(0xFFE2E8F0);

  // --- Core Logic (Kept exactly as provided) ---

  Future<void> _generateAndSave() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    try {
      final file = await PdfGeneratorService.generateInvoicePdf(widget.invoice);
      final docsDir = await getApplicationDocumentsDirectory();
      final invoiceNum = widget.invoice.invoiceNumberShort;
      final clientName = widget.invoice.clientName
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
          .trim();
      final fileName = 'Tax Invoice_${invoiceNum}_$clientName.pdf';
      final savedFile = await file.copy('${docsDir.path}/$fileName');

      setState(() {
        _generatedFile = savedFile;
        _isGenerating = false;
      });
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('PDF saved: $fileName'),
      //       backgroundColor: kPrimaryEmerald,
      //       behavior: SnackBarBehavior.floating,
      //       action: SnackBarAction(
      //         label: 'Share',
      //         textColor: Colors.white,
      //         onPressed: () {
      //           // 1. Immediately hide the snackbar
      //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //
      //           // 2. Execute your share logic
      //           _shareFile();
      //         },
      //       ),
      //     ),
      //   );
      // }
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('PDF saved: $fileName'),
      //       backgroundColor: kPrimaryEmerald,
      //       behavior: SnackBarBehavior.floating,
      //       action: SnackBarAction(
      //         label: 'Share',
      //         textColor: Colors.white,
      //         onPressed: _shareFile,
      //       ),
      //     ),
      //   );
      // }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _shareFile() async {
    if (_generatedFile == null) {
      await _generateAndSave();
      if (_generatedFile == null) return;
    }
    final invoiceNum = widget.invoice.invoiceNumberShort;
    final clientName = widget.invoice.clientName
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
        .trim();
    final fileName = 'Tax Invoice_${invoiceNum}_$clientName.pdf';

    await Share.shareXFiles(
      [XFile(_generatedFile!.path)],
      text: 'Proforma Invoice - $fileName',
      subject: fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;

    return Scaffold(
      backgroundColor: kBgSlate,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: kDarkSlate, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('PREVIEW INVOICE',
            style: TextStyle(color: kDarkSlate, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: kDarkSlate),
            onPressed: _isGenerating ? null : _shareFile,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              color: Colors.red[50],
              padding: const EdgeInsets.all(10),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: kDarkSlate.withOpacity(0.08), blurRadius: 30)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ULTRA MODERN HEADER ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kDeepTeal, kPrimaryEmerald],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset('assets/images/logo.png', width: 150, color: Colors.white, colorBlendMode: BlendMode.srcIn, errorBuilder: (c,e,s) => const Icon(Icons.business, color: Colors.white, size: 40)),
                                const SizedBox(height: 12),
                                const Text('RA PROPERTY OBSERVER LLC',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                                Text('Inspecting for the unexpected',
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                          // --- Replace the Container inside the Header Row ---
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              // Glassmorphism: 15% white opacity
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              // SaaS Detail: Subtle white border to make the glass look sharp
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PROFORMA INVOICE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    letterSpacing: 1.1, // Modern SaaS spacing
                                  ),
                                ),
                                // Clean Divider
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  height: 0.5,
                                  width: 40,
                                  color: Colors.white38,
                                ),
                                Text(
                                  DateFormat('MMM-dd-yyyy').format(inv.issueDate),
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 9),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  inv.invoiceNumber,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  inv.referenceCode,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 8,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Container(
                          //   padding: const EdgeInsets.all(12),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white.withOpacity(0.12),
                          //     borderRadius: BorderRadius.circular(12),
                          //     border: Border.all(color: Colors.white.withOpacity(0.2)),
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       const Text('PROFORMA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                          //       const Divider(color: Colors.white24, height: 12),
                          //       Text(DateFormat('MMM-dd-yyyy').format(inv.issueDate), style: const TextStyle(color: Colors.white, fontSize: 9)),
                          //       Text(inv.invoiceNumber, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          //       Text(inv.referenceCode, style: const TextStyle(color: Colors.white, fontSize: 9)),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- CLIENT DETAILS (EXACT LOOP & FIELDS) ---
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('CLIENT DETAILS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: kMutedSlate)),
                                    const SizedBox(height: 6),
                                    if (inv.useRichTextClientDetails)
                                      _buildRichText(inv.richTextClientDetails)
                                    else ...[
                                      Text(inv.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text('UNIT - ${inv.unit}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text('Location: ${inv.location}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text('No. of bedrooms: ${inv.noOfBedrooms}', style: const TextStyle(fontSize: 10)),
                                      Text('Email: ${inv.email}', style: const TextStyle(fontSize: 10)),
                                      Text('Sqft: ${inv.sqft}', style: const TextStyle(fontSize: 10)),
                                      ...inv.additionalClientFields
                                          .where((f) => f['label']!.isNotEmpty || f['value']!.isNotEmpty)
                                          .map((f) => Text('${f['label']}: ${f['value']}', style: const TextStyle(fontSize: 10))),
                                    ],
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(inv.companyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
                                    Text(inv.companyAddress, textAlign: TextAlign.right, style: const TextStyle(fontSize: 9)),
                                    Text('TRN: ${inv.companyTRN}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kPrimaryEmerald)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // --- TABLE (EXACT LOGIC RETAINED) ---
                          Table(
                            border: TableBorder.all(color: kBorderColor, width: 0.5),
                            columnWidths: const {
                              0: FlexColumnWidth(4),
                              1: FlexColumnWidth(1.5),
                              2: FlexColumnWidth(1.5),
                              3: FlexColumnWidth(1.5),
                              4: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: kBgSlate),
                                children: [
                                  _tableHeader(''),
                                  _tableHeader('UNIT'),
                                  _tableHeader('NO. OF UNITS'),
                                  _tableHeader('PER UNIT'),
                                  _tableHeader('Amount (AED)', align: TextAlign.right),
                                ],
                              ),
                              ...inv.serviceItems.map((item) => TableRow(
                                children: [
                                  _tableCell(item.itemName),
                                  _tableCell(item.unit),
                                  _tableCell(item.noOfUnits.toString()),
                                  _tableCell(item.perUnit > 0 ? item.perUnit.toStringAsFixed(0) : ''),
                                  _tableCell(item.amount > 0 ? item.amount.toStringAsFixed(2) : '0.00', align: TextAlign.right),
                                ],
                              )),
                              TableRow(children: [
                                _tableCell(''), _tableCell(''), _tableCell(''), _tableCell(''),
                                _tableCell(inv.subtotal.toStringAsFixed(2), align: TextAlign.right),
                              ]),
                              TableRow(children: [
                                _tableCell(''), _tableCell(''), _tableCell(''),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Text('VAT ${inv.vatRate.toInt()}% (AED):',
                                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.right),
                                ),
                                _tableCell(inv.vatAmount.toStringAsFixed(2), align: TextAlign.right),
                              ]),
                              TableRow(
                                decoration: BoxDecoration(color: kPrimaryEmerald.withOpacity(0.05)),
                                children: [
                                  _tableCell(''), _tableCell(''), _tableCell(''),
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: const Text('Total Amount (AED):',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.right),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(inv.totalAmount.toStringAsFixed(2),
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kDeepTeal),
                                        textAlign: TextAlign.right),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // --- TERMS ---
                          const Text('TERMS AND CONDITIONS :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          Text(inv.termsAndConditions, style: TextStyle(color: Colors.red[700], fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('TERMS OF PAYMENT :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          Text(inv.termsOfPayment, style: TextStyle(color: Colors.red[700], fontSize: 10, fontWeight: FontWeight.bold)),

                          const SizedBox(height: 20),

                          // --- BANK (EXACT NOTE & LABELS RETAINED) ---
                          Text('Account Details:', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 10)),
                          Text('Bank Transfer Details:', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 9)),
                          Text('**Note: The Remitter bears ALL charges of the banks engaged in the transfer of payment',
                              style: TextStyle(color: Colors.orange[800], fontSize: 8)),
                          const SizedBox(height: 8),
                          _bankRow('Company Name', inv.bankCompanyName),
                          _bankRow('Account Number', '${inv.accountNumber},'),
                          _bankRow('IBN Number', inv.ibanNumber),
                          _bankRow('Swift Bic', inv.swiftBic),
                          _bankRow('Bank Name', inv.bankName),
                          _bankRow('Branch Name', inv.branchName),

                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('COMPANY SEAL & SIGNATURE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                              Image.asset('assets/images/seal.png', width: 90, errorBuilder: (c,e,s) => const SizedBox(height: 40)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // --- FOOTER ---
                          Divider(color: kPrimaryEmerald, thickness: 1.5),
                          const SizedBox(height: 6),
                          const Center(
                            child: Text(
                              'Office 201, Insurance Building, Dubai , Dubai UAE Tel: +971561300654 | www.propertyinspectiondxb.com',
                              style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- SaaS ACTION BAR ---
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isGenerating ? null : _generateAndSave,
                    icon: _isGenerating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.download_rounded, color: kDarkSlate),
                    label: Text(_isGenerating ? 'Generating...' : 'Save PDF', style: TextStyle(color: kDarkSlate, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: kBorderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _shareFile,
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text('Share Invoice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryEmerald,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Design Helpers (Retaining original structure) ---

  Widget _tableHeader(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: Color(0xFF475569)), textAlign: align),
    );
  }

  Widget _tableCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Text(text, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w500), textAlign: align),
    );
  }

  Widget _buildRichText(String text) {
    if (text.isEmpty) return const SizedBox();

    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');

    int lastMatchEnd = 0;
    for (final Match match in regExp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: const TextStyle(color: Colors.black, fontSize: 10),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(color: Colors.black, fontSize: 10),
      ));
    }

    return RichText(
      text: TextSpan(
        children: spans,
      ),
    );
  }

  Widget _bankRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)))),
          const Text(':  ', style: TextStyle(fontSize: 9)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
        ],
      ),
    );
  }
}
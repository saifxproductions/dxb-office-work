import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'invoice_model.dart';

// ============================================================
// DATA MODEL - Fill these fields dynamically
// ============================================================

class ProposalServiceItem {
  final String description;
  final String unit;
  final int qty;
  final double price;

  const ProposalServiceItem({
    required this.description,
    required this.unit,
    required this.qty,
    required this.price,
  });

  double get amount => qty * price;
}

class ProposalData {
  final String clientName;
  final String unitNo;
  final String location;
  final String email;
  final String sqftArea;
  final String phone;
  final String bedroom;
  final String clientDetailsText;
  final List<ProposalServiceItem> serviceItems;
  final double vatRate;
  final int year;

  const ProposalData({
    required this.clientName,
    required this.unitNo,
    required this.location,
    required this.email,
    required this.sqftArea,
    required this.phone,
    required this.bedroom,
    required this.clientDetailsText,
    required this.serviceItems,
    this.vatRate = 5.0,
    this.year = 2026,
  });

  /// Bridge from InvoiceModel to ProposalData
  factory ProposalData.fromInvoiceModel(InvoiceModel invoice) {
    return ProposalData(
      clientName: invoice.clientName.isNotEmpty
          ? invoice.clientName
          : invoice.richTextClientDetails.split('\n').first,
      unitNo: invoice.unit,
      location: invoice.location,
      email: invoice.email,
      sqftArea: invoice.sqft,
      phone: invoice.phoneNo,
      bedroom: invoice.noOfBedrooms,
      clientDetailsText: invoice.richTextClientDetails,
      vatRate: invoice.vatRate,
      serviceItems: invoice.serviceItems
          .map((item) => ProposalServiceItem(
                description: item.itemName,
                unit: item.unit,
                qty: item.noOfUnits,
                price: item.perUnit,
              ))
          .toList(),
    );
  }

  double get subtotal =>
      serviceItems.fold(0.0, (sum, item) => sum + item.amount);
  double get vat => subtotal * (vatRate / 100);
  double get grandTotal => subtotal + vat;
}

// ============================================================
// THEME CONSTANTS
// ============================================================

class AppTheme {
  static const brandGreen = PdfColor.fromInt(0xFF00BF8F);   // teal/mint green
  static const darkText   = PdfColor.fromInt(0xFF1A1A1A);
  static const lightGrey  = PdfColor.fromInt(0xFFF5F5F5);
  static const midGrey    = PdfColor.fromInt(0xFFCCCCCC);
  static const white      = PdfColors.white;
  static const tableHeaderBg = PdfColor.fromInt(0xFF00BF8F);
  static const tableRowBg    = PdfColor.fromInt(0xFFF9F9F9);
}

// ============================================================
// PDF GENERATOR
// ============================================================

class PropertyInspectionPdfGenerator {
  final ProposalData data;
  late pw.MemoryImage _logoImage;
  late pw.MemoryImage _sealImage;
  late pw.MemoryImage _proposalImage;

  PropertyInspectionPdfGenerator({required this.data});

  Future<File> generate(String outputPath) async {
    // Load the logo asset once before building pages
    _logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );
    _sealImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/seal.png')).buffer.asUint8List(),
    );
    _proposalImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/proposal_bg.jpg')).buffer.asUint8List(),
    );

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );

    // Page 1: Cover Page
    pdf.addPage(_buildCoverPage());

    // Page 2: Introduction Letter
    pdf.addPage(_buildIntroPage());

    // Page 3: Scope of Work
    pdf.addPage(_buildScopePage());

    // Page 4: Project Details & Pricing
    pdf.addPage(_buildPricingPage());

    // Page 5: Bank Details
    pdf.addPage(_buildBankPage());

    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ----------------------------------------------------------
  // PAGE 1: COVER PAGE
  // ----------------------------------------------------------
  pw.Page _buildCoverPage() {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Stack(
        children: [
          // Background image
          pw.Container(
            width: double.infinity,
            height: double.infinity,
            child: pw.Image(
              _proposalImage,
              fit: pw.BoxFit.cover,
            ),
          ),

          // Year badge top-right
          pw.Positioned(
            top: 24,
            right: 24,
            child: pw.Text(
              '${data.year}',
              style: pw.TextStyle(
                color: AppTheme.white,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          // Logo top-left
          pw.Positioned(
            top: 24,
            left: 32,
            child: _buildLogo(),
          ),

          // Main headline
          pw.Positioned(
            top: 100,
            left: 32,
            right: 32,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PROPERTY',
                  style: pw.TextStyle(
                    color: AppTheme.white,
                    fontSize: 62,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'INSPECTION',
                  style: pw.TextStyle(
                    color: AppTheme.white,
                    fontSize: 62,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'PROPOSAL',
                  style: pw.TextStyle(
                    color: AppTheme.white,
                    fontSize: 62,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Green info box - bottom right
          pw.Positioned(
            bottom: 120,
            right: 32,
            child: pw.Container(
              width: 220,
              padding: const pw.EdgeInsets.all(20),
              color: AppTheme.brandGreen,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Expert Property Inspection',
                    style: pw.TextStyle(
                      color: AppTheme.white,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'And Snagging Services in Dubai',
                    style: pw.TextStyle(
                      color: AppTheme.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          pw.Positioned(
            bottom: 24,
            left: 32,
            right: 32,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'info@propertyinspectiondxb.com',
                  style: const pw.TextStyle(
                    color: AppTheme.white,
                    fontSize: 10,
                  ),
                ),
                pw.Text(
                  'Office 201, Insurance Building, Dubai',
                  style: const pw.TextStyle(
                    color: AppTheme.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // PAGE 2: INTRODUCTION LETTER
  // ----------------------------------------------------------
  pw.Page _buildIntroPage() {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header bar with logo + year
          _pageHeader(),

          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left column: proposal type label
                pw.SizedBox(
                  width: 160,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Proposal for',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: AppTheme.brandGreen,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Villa/Apartment',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: AppTheme.brandGreen,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Handover Inspection.',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: AppTheme.brandGreen,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(width: 32),

                // Right column: letter body
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Dear Client,',
                        // 'Dear  ${data.clientName}',
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'Thank you for contacting PROPERTY INSEPECTION DXB to issue you with a proposal for the above Services.',
                        style: const pw.TextStyle(fontSize: 11, color: AppTheme.darkText),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'We hope our proposal meets with your requirements and to confirm the same, please send us an email.',
                        style: const pw.TextStyle(fontSize: 11, color: AppTheme.darkText),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'Again, we would like to thank you for the opportunity to present this proposal and look forward to receiving confirmation from you soon.',
                        style: const pw.TextStyle(fontSize: 11, color: AppTheme.darkText),
                      ),
                      pw.SizedBox(height: 24),
                      pw.Text(
                        'Sincerely',
                        style: const pw.TextStyle(fontSize: 11, color: AppTheme.darkText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.Spacer(),

          // Bottom green banner
          pw.Container(
            width: double.infinity,
            color: AppTheme.brandGreen,
            padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Large text
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INSPECTING',
                        style: pw.TextStyle(
                          color: AppTheme.white,
                          fontSize: 42,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'FOR THE',
                        style: pw.TextStyle(
                          color: AppTheme.white,
                          fontSize: 42,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'UNEXPECTED',
                        style: pw.TextStyle(
                          color: AppTheme.white,
                          fontSize: 42,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Contact info
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Tell: 00971561300654', style: const pw.TextStyle(color: AppTheme.white, fontSize: 11)),
                    pw.SizedBox(height: 4),
                    pw.Text('www.propertyinspectiondxb.com', style: const pw.TextStyle(color: AppTheme.white, fontSize: 11)),
                    pw.SizedBox(height: 4),
                    pw.Text('Office 201, Insurance build,', style: const pw.TextStyle(color: AppTheme.white, fontSize: 11)),
                    pw.Text('Dubai, UAE', style: const pw.TextStyle(color: AppTheme.white, fontSize: 11)),
                    pw.SizedBox(height: 4),
                    pw.Text('${data.year}', style: pw.TextStyle(color: AppTheme.white, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // PAGE 3: SCOPE OF WORK
  // ----------------------------------------------------------
  pw.Page _buildScopePage() {
    const bodyStyle = pw.TextStyle(fontSize: 10, color: AppTheme.darkText);
    // const labelStyle = pw.TextStyle(fontSize: 10, color: AppTheme.darkText, fontWeight: pw.FontWeight.bold);
    final labelStyle = pw.TextStyle(fontSize: 10, color: AppTheme.darkText, fontWeight: pw.FontWeight.bold);
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (ctx) => pw.Column(
        children: [
          _pageHeader(),

          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Page title
                pw.Text(
                  'Property Snagging',
                  style: pw.TextStyle(
                    fontSize: 36,
                    color: AppTheme.brandGreen,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Inspection',
                  style: pw.TextStyle(
                    fontSize: 36,
                    color: AppTheme.darkText,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'The purpose of the Property Inspection is to assess the condition of the subject property, to identify physical deficiencies and to provide an objective, independent and professional opinion of the potential repairs associated with the subject property.',
                            style: bodyStyle,
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'The inspection will highlight existing defective works, areas of poor workmanship, incomplete work, breaches of regulations and health and safety issues. During the inspection the surveyor will analyze the existing defect(s), their potential causes and possible remedial actions.',
                            style: bodyStyle,
                          ),
                          pw.SizedBox(height: 12),
                          pw.Text('SCOPE OF WORK', style: labelStyle),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'The Property Inspection shall be conducted in accordance with the RERA requirements, local Municipality Building Code requirements, the UAE Fire and Life Safety Code of practice, and other generally accepted industry standards. The surveyor will inspect the accessible areas on a visual basis.',
                            style: bodyStyle,
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'The specific Property Inspection scope of work included the following:',
                            style: bodyStyle,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Walk-Through Survey - The Property Inspection report shall be based on observations made during the property "walk-through." Observations shall include property interiors.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 24),

                    // RIGHT COLUMN
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Observations shall be conducted at the property as to the type, condition, adequacy and installation of the following systems:',
                            style: bodyStyle,
                          ),
                          pw.SizedBox(height: 8),
                          _bulletItem('Property Interior Elements - interior finishes, fixtures, appliances, and furnishings.'),
                          _bulletItem('Mechanical, Electrical & Plumbing (MEP) Systems - plumbing, heating, ventilation and air conditioning and electrical systems.'),
                          _bulletItem('Life, Health, Safety and Fire Protection - health, life safety and fire protection systems.'),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'The surveyor will not take up or uncover carpets, floor coverings, floor/wall finishing\'s or floorboards, move furniture, remove the contents of the cupboards, remove secured panels and/or hatches or undo electrical fittings.',
                            style: bodyStyle,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'The surveyor use equipment such as a damp-meter, thermal imaging camera, binoculars and torch, and may use a ladder for flat roofs and for hatches no more than 3 meters above ground level (outside) or floor surfaces (inside) if it is safe to do so.',
                            style: bodyStyle,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'It is expected that unrestricted and free access will be provided to all areas during normal working hours. All doors to all spaces will be unlocked.',
                            style: bodyStyle,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'We will only carry out the inspection over the course of no more than one day with the use of one or two engineers.',
                            style: bodyStyle,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'The survey will be on a strictly visual basis; thus we will not force open or uncover any concealed areas etc.',
                            style: bodyStyle,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'No assessment or investigation behind walls or in any other generally inaccessible areas shall be performed. No physical tests shall be made nor shall any samples for engineering analysis be collected.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // PAGE 4: PROJECT DETAILS & PRICING
  // ----------------------------------------------------------
  pw.Page _buildPricingPage() {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _pageHeader(),

          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Section title
                pw.Text(
                  'Project Details',
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: AppTheme.brandGreen,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),

                // Client details quick text
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: AppTheme.midGrey, width: 0.5),
                    color: AppTheme.lightGrey,
                  ),
                  child: pw.Text(
                    data.clientDetailsText,
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: AppTheme.darkText,
                      lineSpacing: 2,
                    ),
                  ),
                ),

                pw.SizedBox(height: 28),

                // Pricing table
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: AppTheme.midGrey, width: 0.5),
                  ),
                  child: pw.Column(
                    children: [
                      // Table title header
                      pw.Container(
                        color: AppTheme.tableHeaderBg,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                'Property Snagging & De-snagging',
                                style: pw.TextStyle(
                                  color: AppTheme.white,
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Column headers
                      _tableRow(
                        ['DESCRIPTION', 'UNIT', 'QTY', 'PRICE', 'AMOUNT (AED)'],
                        isHeader: true,
                      ),

                      // Dynamic service item rows
                      ...data.serviceItems.map((item) => _tableRow([
                        item.description,
                        item.unit,
                        item.qty.toString(),
                        item.price > 0 ? item.price.toStringAsFixed(0) : '',
                        item.amount > 0 ? item.amount.toStringAsFixed(2) : '0.00',
                      ])),

                      // Empty row for visual spacing
                      // _tableRow(['', '', '', '', '']),

                      // Totals
                      _totalRow('Subtotal', data.subtotal.toStringAsFixed(2)),
                      _totalRow('Government Vat ${data.vatRate.toInt()}%', data.vat.toStringAsFixed(2)),
                      _totalRow('Grand Total', data.grandTotal.toStringAsFixed(2), bold: true),
                    ],
                  ),
                ),

                pw.SizedBox(height: 28),

                // Payment info
                _infoBlock(
                  'REPORT WRITING:',
                  'PROPERTY INSEPECTION DXB shall provide the Property Report Card will be delivered within 24 hours.',
                ),
                pw.SizedBox(height: 12),
                _infoBlock(
                  'PAYMENT TERMS:',
                  'PROPERTY INSEPECTION DXB will need 100% of the fees payable before starting any inspection on site.',
                ),
                pw.SizedBox(height: 12),
                _infoBlock(
                  'PAYMENT METHOD:',
                  'The fees should be paid by bank transfer into account number.',
                ),
              ],
            ),
          ),
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // PAGE 5: BANK DETAILS
  // ----------------------------------------------------------
  pw.Page _buildBankPage() {
    const bodyStyle = pw.TextStyle(fontSize: 13, color: AppTheme.darkText);
    // const boldStyle = pw.TextStyle(fontSize: 13, color: AppTheme.darkText, fontWeight: pw.FontWeight.bold);
    final boldStyle = pw.TextStyle(fontSize: 13, color: AppTheme.darkText, fontWeight: pw.FontWeight.bold);
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _pageHeader(),

          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bank Account Details:', style: boldStyle),
                pw.SizedBox(height: 20),
                pw.Text('Company Name: Rukan Alaez Property Observer L.L.C S.O.C', style: bodyStyle),
                pw.SizedBox(height: 8),
                pw.Text('Account No. 0323439354001', style: bodyStyle),
                pw.SizedBox(height: 8),
                pw.Text('IBAN No: AE820400000323439354001', style: bodyStyle),
                pw.SizedBox(height: 8),
                pw.Text('Swift Bic: NRAKAEAK', style: bodyStyle),
                pw.SizedBox(height: 8),
                pw.Text('Bank Name: RAKBANK', style: bodyStyle),
                pw.SizedBox(height: 8),
                pw.Text('Branch Name: Rak Bank', style: bodyStyle),
                pw.SizedBox(height: 8),
                pw.Text('Emaar Business Park', style: bodyStyle),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Image(_sealImage, width: 100),
                ),
              ],
            ),
          ),
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SHARED WIDGETS
  // ----------------------------------------------------------

  pw.Widget _buildLogo() {
    return pw.Image(_logoImage, width: 100);
  }

  pw.Widget _pageHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: PdfColor.fromInt(0xFF1B3A2F),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          pw.Text(
            '${data.year}',
            style: pw.TextStyle(color: AppTheme.white, fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _bulletItem(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6, left: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('* ', style: const pw.TextStyle(fontSize: 10, color: AppTheme.darkText)),
          pw.Expanded(
            child: pw.Text(text, style: const pw.TextStyle(fontSize: 10, color: AppTheme.darkText)),
          ),
        ],
      ),
    );
  }

  pw.Widget _detailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              '$label :',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: AppTheme.darkText),
            ),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11, color: AppTheme.darkText)),
        ],
      ),
    );
  }

  pw.Widget _tableRow(List<String> cells, {bool isHeader = false}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: isHeader ? AppTheme.lightGrey : null,
        border: const pw.Border(
          bottom: pw.BorderSide(color: AppTheme.midGrey, width: 0.5),
        ),
      ),
      child: pw.Row(
        children: cells.asMap().entries.map((entry) {
          return pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                border: entry.key < cells.length - 1
                    ? const pw.Border(right: pw.BorderSide(color: AppTheme.midGrey, width: 0.5))
                    : null,
              ),
              child: pw.Text(
                entry.value,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: AppTheme.darkText,
                ),
                textAlign: entry.key == 0 ? pw.TextAlign.left : pw.TextAlign.center,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _totalRow(String label, String value, {bool bold = false}) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: AppTheme.midGrey, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: AppTheme.darkText,
                ),
              ),
            ),
          ),
          pw.Container(
            width: 100,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(color: AppTheme.midGrey, width: 0.5)),
            ),
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: AppTheme.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 40),
          child: pw.Divider(color: AppTheme.brandGreen, thickness: 1.5),
        ),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(
            'Office 201, Insurance Building, Dubai , Dubai UAE Tel: +971561300654 | www.propertyinspectiondxb.com',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _infoBlock(String label, String body) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label ',
            style: pw.TextStyle(
              color: AppTheme.brandGreen,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.TextSpan(
            text: body,
            style: const pw.TextStyle(fontSize: 11, color: AppTheme.darkText),
          ),
        ],
      ),
    );
  }
}


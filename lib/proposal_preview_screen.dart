import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'property_inspection_pdf_generator.dart';

class ProposalPreviewScreen extends StatelessWidget {
  final ProposalData data;
  final String fileName;

  const ProposalPreviewScreen({
    super.key,
    required this.data,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: PdfPreview(
        build: (format) => PropertyInspectionPdfGenerator(data: data).buildPdf(),
        maxPageWidth: 700,
        allowPrinting: true,
        allowSharing: true,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00897B)),
        ),
      ),
    );
  }
}

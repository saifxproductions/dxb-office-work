import 'package:flutter/material.dart';
import 'invoice_model.dart';
import 'unified_office_form.dart';

class MainForm extends StatefulWidget {
  const MainForm({super.key});

  @override
  State<MainForm> createState() => _MainFormState();
}

class _MainFormState extends State<MainForm> {
  final InvoiceModel _invoice = InvoiceModel();

  @override
  Widget build(BuildContext context) {
    return UnifiedOfficeForm(
      invoice: _invoice,
    );
  }
}

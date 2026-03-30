import 'package:flutter/material.dart';
import 'invoice_model.dart';
import 'step1_invoice_details.dart';
import 'step2_line_items.dart';

class MainForm extends StatefulWidget {
  const MainForm({super.key});

  @override
  State<MainForm> createState() => _MainFormState();
}

class _MainFormState extends State<MainForm> {
  late PageController _pageController;
  final InvoiceModel _invoice = InvoiceModel();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      children: [
        Step1InvoiceDetails(
          invoice: _invoice,
          pageController: _pageController,
        ),
        Step2LineItems(
          invoice: _invoice,
          pageController: _pageController,
        ),
      ],
    );
  }
}

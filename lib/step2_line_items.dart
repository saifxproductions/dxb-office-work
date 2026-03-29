import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'invoice_model.dart';
import 'preview_screen.dart';
import 'property_inspection_pdf_generator.dart';

class Step2LineItems extends StatefulWidget {
  final InvoiceModel invoice;
  const Step2LineItems({super.key, required this.invoice});

  @override
  State<Step2LineItems> createState() => _Step2LineItemsState();
}

class _Step2LineItemsState extends State<Step2LineItems> {
  late List<_ItemControllers> _itemControllersList;

  // Terms controllers
  late TextEditingController _termsCtrl;
  late TextEditingController _paymentTermsCtrl;

  // Bank controllers
  late TextEditingController _bankCompanyCtrl;
  late TextEditingController _accountNoCtrl;
  late TextEditingController _ibanCtrl;
  late TextEditingController _swiftCtrl;
  late TextEditingController _bankNameCtrl;
  late TextEditingController _branchCtrl;

  late TextEditingController _vatCtrl;

  @override
  void initState() {
    super.initState();
    _itemControllersList = widget.invoice.serviceItems.map((item) {
      return _ItemControllers.fromItem(item);
    }).toList();

    _termsCtrl =
        TextEditingController(text: widget.invoice.termsAndConditions);
    _paymentTermsCtrl =
        TextEditingController(text: widget.invoice.termsOfPayment);
    _bankCompanyCtrl =
        TextEditingController(text: widget.invoice.bankCompanyName);
    _accountNoCtrl =
        TextEditingController(text: widget.invoice.accountNumber);
    _ibanCtrl = TextEditingController(text: widget.invoice.ibanNumber);
    _swiftCtrl = TextEditingController(text: widget.invoice.swiftBic);
    _bankNameCtrl = TextEditingController(text: widget.invoice.bankName);
    _branchCtrl = TextEditingController(text: widget.invoice.branchName);
    _vatCtrl =
        TextEditingController(text: widget.invoice.vatRate.toString());
  }

  @override
  void dispose() {
    for (final c in _itemControllersList) {
      c.dispose();
    }
    _termsCtrl.dispose();
    _paymentTermsCtrl.dispose();
    _bankCompanyCtrl.dispose();
    _accountNoCtrl.dispose();
    _ibanCtrl.dispose();
    _swiftCtrl.dispose();
    _bankNameCtrl.dispose();
    _branchCtrl.dispose();
    _vatCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      final newItem = ServiceItem();
      widget.invoice.serviceItems.add(newItem);
      _itemControllersList.add(_ItemControllers.fromItem(newItem));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemControllersList[index].dispose();
      _itemControllersList.removeAt(index);
      widget.invoice.serviceItems.removeAt(index);
    });
  }

  void _syncAndCalculate() {
    for (int i = 0; i < _itemControllersList.length; i++) {
      final ctrl = _itemControllersList[i];
      widget.invoice.serviceItems[i].itemName = ctrl.nameCtrl.text;
      widget.invoice.serviceItems[i].unit = ctrl.unitCtrl.text;
      widget.invoice.serviceItems[i].noOfUnits =
          int.tryParse(ctrl.unitsCtrl.text) ?? 0;
      widget.invoice.serviceItems[i].perUnit =
          double.tryParse(ctrl.perUnitCtrl.text) ?? 0.0;
    }
    widget.invoice.termsAndConditions = _termsCtrl.text;
    widget.invoice.termsOfPayment = _paymentTermsCtrl.text;
    widget.invoice.bankCompanyName = _bankCompanyCtrl.text;
    widget.invoice.accountNumber = _accountNoCtrl.text;
    widget.invoice.ibanNumber = _ibanCtrl.text;
    widget.invoice.swiftBic = _swiftCtrl.text;
    widget.invoice.bankName = _bankNameCtrl.text;
    widget.invoice.branchName = _branchCtrl.text;
    widget.invoice.vatRate =
        double.tryParse(_vatCtrl.text) ?? 5.0;
    setState(() {});
  }

  bool _isGeneratingProposal = false;

  Future<void> _generateProposal() async {
    _syncAndCalculate();
    setState(() => _isGeneratingProposal = true);

    try {
      final proposalData = ProposalData.fromInvoiceModel(widget.invoice);
      final generator = PropertyInspectionPdfGenerator(data: proposalData);

      final dir = await getTemporaryDirectory();
      final clientName = widget.invoice.clientName
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
          .trim();
      final fileName = 'Proposal_${clientName.isNotEmpty ? clientName : 'Client'}.pdf';
      final outputPath = '${dir.path}/$fileName';

      final file = await generator.generate(outputPath);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Property Inspection Proposal - $fileName',
        subject: fileName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating proposal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingProposal = false);
    }
  }

  void _goToPreview() {
    _syncAndCalculate();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(invoice: widget.invoice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncAndCalculate();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1565C0),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Proforma',
              style: TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Step 2 of 2',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Line Items & Totals',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Items Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: _addItem,
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle_outline,
                                color: Color(0xFF1565C0)),
                            const SizedBox(width: 4),
                            const Text(
                              'Add Item',
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Service items list
                  ...List.generate(_itemControllersList.length, (index) {
                    return _buildServiceItemCard(index);
                  }),

                  const SizedBox(height: 16),

                  // Totals
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal',
                                style: TextStyle(color: Colors.grey)),
                            Text(
                              'AED ${widget.invoice.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('VAT ',
                                style: TextStyle(color: Colors.grey)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${widget.invoice.vatRate.toInt()}%',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'AED ${widget.invoice.vatAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount (AED)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'AED ${widget.invoice.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // VAT Rate
                  _buildLabel('VAT RATE (%)'),
                  SizedBox(
                    width: 100,
                    child: _buildTextField(
                      controller: _vatCtrl,
                      hint: '5',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() => _syncAndCalculate()),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Terms & Payment
                  const Text(
                    'Terms & Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('TERMS AND CONDITIONS'),
                  _buildTextField(
                    controller: _termsCtrl,
                    hint: 'As per Proposal',
                    textColor: const Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('TERMS OF PAYMENT'),
                  _buildTextField(
                    controller: _paymentTermsCtrl,
                    hint: '100% of the fees payable before commencing work.',
                    maxLines: 2,
                    textColor: Colors.red[700],
                    fillColor: const Color(0xFFFFF3F3),
                  ),
                  const SizedBox(height: 20),

                  // Bank Details
                  const Text(
                    'Bank Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('COMPANY NAME'),
                                  _buildTextField(
                                      controller: _bankCompanyCtrl,
                                      hint: 'Company Name'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('ACCOUNT NUMBER'),
                                  _buildTextField(
                                      controller: _accountNoCtrl,
                                      hint: '0323439354001'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('IBAN NUMBER'),
                                  _buildTextField(
                                      controller: _ibanCtrl,
                                      hint: 'AE820400000323439354001'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('SWIFT BIC'),
                                  _buildTextField(
                                      controller: _swiftCtrl,
                                      hint: 'NRAKAEAK'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('BANK NAME'),
                                  _buildTextField(
                                      controller: _bankNameCtrl, hint: 'RAK'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('BRANCH NAME'),
                                  _buildTextField(
                                      controller: _branchCtrl,
                                      hint: 'Rak BankEmaar BussinnessPark'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '**Note: The Remitter bears ALL charges of the banks engaged in the transfer of payment',
                            style: TextStyle(fontSize: 11, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                // Preview PDF
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _goToPreview,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Preview', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Generate
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _goToPreview,
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    label: const Text(
                      'Generate',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Proposal
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingProposal ? null : _generateProposal,
                    icon: _isGeneratingProposal
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.description_outlined, color: Colors.white, size: 18),
                    label: Text(
                      _isGeneratingProposal ? 'Wait...' : 'Proposal',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _buildServiceItemCard(int index) {
    final ctrl = _itemControllersList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLabel('ITEM NAME'),
              const Spacer(),
              GestureDetector(
                onTap: () => _removeItem(index),
                child: const Icon(Icons.delete_outline, color: Colors.grey),
              ),
            ],
          ),
          _buildTextField(
            controller: ctrl.nameCtrl,
            hint: 'Item Name',
            onChanged: (_) => setState(() => _syncAndCalculate()),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('UNIT'),
                    _buildTextField(
                      controller: ctrl.unitCtrl,
                      hint: '2BHK',
                      onChanged: (_) => setState(() => _syncAndCalculate()),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('NO. OF UNITS'),
                    _buildTextField(
                      controller: ctrl.unitsCtrl,
                      hint: '1',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() => _syncAndCalculate()),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('PER UNIT'),
                    _buildTextField(
                      controller: ctrl.perUnitCtrl,
                      hint: '850',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() => _syncAndCalculate()),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Amount: AED ${(double.tryParse(ctrl.perUnitCtrl.text) ?? 0.0 * (int.tryParse(ctrl.unitsCtrl.text) ?? 0)).toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    Color? textColor,
    Color? fillColor,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: textColor ?? Colors.black87),
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: fillColor ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1565C0)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _ItemControllers {
  final TextEditingController nameCtrl;
  final TextEditingController unitCtrl;
  final TextEditingController unitsCtrl;
  final TextEditingController perUnitCtrl;

  _ItemControllers({
    required this.nameCtrl,
    required this.unitCtrl,
    required this.unitsCtrl,
    required this.perUnitCtrl,
  });

  factory _ItemControllers.fromItem(ServiceItem item) {
    return _ItemControllers(
      nameCtrl: TextEditingController(text: item.itemName),
      unitCtrl: TextEditingController(text: item.unit),
      unitsCtrl: TextEditingController(text: item.noOfUnits.toString()),
      perUnitCtrl: TextEditingController(text: item.perUnit.toString()),
    );
  }

  void dispose() {
    nameCtrl.dispose();
    unitCtrl.dispose();
    unitsCtrl.dispose();
    perUnitCtrl.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'invoice_model.dart';
import 'invoice_number_service.dart';
import 'preview_screen.dart';
import 'property_inspection_pdf_generator.dart';
import 'proposal_preview_screen.dart';
import 'pdf_generator_service.dart';

class UnifiedOfficeForm extends StatefulWidget {
  final InvoiceModel invoice;

  const UnifiedOfficeForm({
    super.key,
    required this.invoice,
  });

  @override
  State<UnifiedOfficeForm> createState() => _UnifiedOfficeFormState();
}

class _UnifiedOfficeFormState extends State<UnifiedOfficeForm> {
  final _formKey = GlobalKey<FormState>();

  // --- Step 1 Controllers ---
  late TextEditingController _invoiceNumberCtrl;
  late TextEditingController _referenceCodeCtrl;
  late TextEditingController _issueDateCtrl;
  late TextEditingController _richTextClientDetailsCtrl;

  // --- Step 2 Controllers ---
  late List<_ItemControllers> _itemControllersList;
  late TextEditingController _termsCtrl;
  late TextEditingController _paymentTermsCtrl;
  late TextEditingController _bankCompanyCtrl;
  late TextEditingController _accountNoCtrl;
  late TextEditingController _ibanCtrl;
  late TextEditingController _swiftCtrl;
  late TextEditingController _bankNameCtrl;
  late TextEditingController _branchCtrl;
  late TextEditingController _vatCtrl;
  bool _isGeneratingProposal = false;
  bool _isInvoiceNumberEdited = false;
  bool _isReferenceCodeEdited = false;
  bool _isIncrementedThisSession = false;
  bool _isSharingBoth = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize Step 1
    _invoiceNumberCtrl = TextEditingController(text: widget.invoice.invoiceNumber);
    _referenceCodeCtrl = TextEditingController(text: widget.invoice.referenceCode);
    _issueDateCtrl = TextEditingController(
        text: DateFormat('MM/dd/yyyy').format(widget.invoice.issueDate));
    _richTextClientDetailsCtrl = TextEditingController(text: widget.invoice.richTextClientDetails);

    _invoiceNumberCtrl.addListener(() {
      if (!_isInvoiceNumberEdited) {
        setState(() => _isInvoiceNumberEdited = true);
      } else {
        // Save manual changes immediately as unconsumed baselines
        final val = InvoiceNumberService.parseNumber(_invoiceNumberCtrl.text);
        InvoiceNumberService.saveInvoiceNumber(val);
      }
    });
    _referenceCodeCtrl.addListener(() {
      if (!_isReferenceCodeEdited) {
        setState(() => _isReferenceCodeEdited = true);
      } else {
        // Save manual changes immediately as unconsumed baselines
        final val = InvoiceNumberService.parseNumber(_referenceCodeCtrl.text);
        InvoiceNumberService.saveReferenceNumber(val);
      }
    });

    _loadLastInvoiceNumber();

    // Initialize Step 2
    _itemControllersList = widget.invoice.serviceItems.map((item) {
      final ctrl = _ItemControllers.fromItem(item);
      ctrl.perUnitCtrl.addListener(() => setState(() {}));
      ctrl.confirmPerUnitCtrl.addListener(() => setState(() {}));
      return ctrl;
    }).toList();
    _termsCtrl = TextEditingController(text: widget.invoice.termsAndConditions);
    _paymentTermsCtrl = TextEditingController(text: widget.invoice.termsOfPayment);
    _bankCompanyCtrl = TextEditingController(text: widget.invoice.bankCompanyName);
    _accountNoCtrl = TextEditingController(text: widget.invoice.accountNumber);
    _ibanCtrl = TextEditingController(text: widget.invoice.ibanNumber);
    _swiftCtrl = TextEditingController(text: widget.invoice.swiftBic);
    _bankNameCtrl = TextEditingController(text: widget.invoice.bankName);
    _branchCtrl = TextEditingController(text: widget.invoice.branchName);
    _vatCtrl = TextEditingController(text: widget.invoice.vatRate.toString());
  }

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    _referenceCodeCtrl.dispose();
    _issueDateCtrl.dispose();
    _richTextClientDetailsCtrl.dispose();
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

  // --- Logic Methods ---

  Future<void> _loadLastInvoiceNumber() async {
    final lastInv = await InvoiceNumberService.getLastInvoiceNumber();
    final lastRef = await InvoiceNumberService.getLastReferenceNumber();
    final invConsumed = await InvoiceNumberService.isInvoiceConsumed();
    final refConsumed = await InvoiceNumberService.isReferenceConsumed();
    
    // Only increment if the number was "consumed" by a generated report
    final displayInv = invConsumed ? lastInv + 1 : lastInv;
    final displayRef = refConsumed ? lastRef + 1 : lastRef;
    
    final formattedInv = InvoiceNumberService.formatFull(displayInv);
    final formattedRef = InvoiceNumberService.formatRef(displayRef);
    
    setState(() {
      // Temporarily disable save-on-change during initial load
      _isInvoiceNumberEdited = false; 
      _isReferenceCodeEdited = false;
      
      _invoiceNumberCtrl.text = formattedInv;
      widget.invoice.invoiceNumber = formattedInv;
      _referenceCodeCtrl.text = formattedRef;
      widget.invoice.referenceCode = formattedRef;
      
      _isIncrementedThisSession = false;
    });
  }

  Future<void> _handleAutoIncrement() async {
    if (_isIncrementedThisSession) return;

    // Mark current numbers as "consumed" so the next session increments them
    await InvoiceNumberService.markInvoiceConsumed();
    await InvoiceNumberService.markReferenceConsumed();
    
    _isIncrementedThisSession = true;
  }

  Future<void> _incrementInvoiceNumber() async {
    final currentInv = InvoiceNumberService.parseNumber(_invoiceNumberCtrl.text);
    final currentRef = InvoiceNumberService.parseNumber(_referenceCodeCtrl.text);
    
    final nextInv = currentInv + 1;
    final nextRef = currentRef + 1;
    
    final formattedInv = InvoiceNumberService.formatFull(nextInv);
    final formattedRef = InvoiceNumberService.formatRef(nextRef);
    
    // Save the new values as unconsumed baselines
    await InvoiceNumberService.saveInvoiceNumber(nextInv);
    await InvoiceNumberService.saveReferenceNumber(nextRef);
    
    setState(() {
      _isInvoiceNumberEdited = true;
      _isReferenceCodeEdited = true;
      
      _invoiceNumberCtrl.text = formattedInv;
      widget.invoice.invoiceNumber = formattedInv;
      _referenceCodeCtrl.text = formattedRef;
      widget.invoice.referenceCode = formattedRef;
      
      _isIncrementedThisSession = true; // Button click counts as the "action" for this session
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.invoice.issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        widget.invoice.issueDate = picked;
        _issueDateCtrl.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _richTextClientDetailsCtrl.text = data.text!;
      });
    }
  }

  void _addItem() {
    setState(() {
      final newItem = ServiceItem();
      widget.invoice.serviceItems.add(newItem);
      final ctrl = _ItemControllers.fromItem(newItem);
      // Add listeners to rebuild on price change for real-time validation and mirroring
      ctrl.perUnitCtrl.addListener(() => setState(() {}));
      ctrl.confirmPerUnitCtrl.addListener(() => setState(() {}));
      _itemControllersList.add(ctrl);
    });
  }

  bool _allPricesVerified() {
    if (_itemControllersList.isEmpty) return false;
    for (final ctrl in _itemControllersList) {
      if (!ctrl.isVerified) return false;
    }
    return true;
  }

  void _removeItem(int index) {
    setState(() {
      _itemControllersList[index].dispose();
      _itemControllersList.removeAt(index);
      if (index < widget.invoice.serviceItems.length) {
        widget.invoice.serviceItems.removeAt(index);
      }
    });
  }

  void _syncData() {
    widget.invoice.invoiceNumber = _invoiceNumberCtrl.text.trim();
    widget.invoice.referenceCode = _referenceCodeCtrl.text.trim();
    widget.invoice.useRichTextClientDetails = true;
    widget.invoice.richTextClientDetails = _richTextClientDetailsCtrl.text.trim();
    
    for (int i = 0; i < _itemControllersList.length; i++) {
        if (i < widget.invoice.serviceItems.length) {
          final ctrl = _itemControllersList[i];
          widget.invoice.serviceItems[i].itemName = ctrl.nameCtrl.text;
          widget.invoice.serviceItems[i].unit = ctrl.unitCtrl.text;
          widget.invoice.serviceItems[i].noOfUnits = int.tryParse(ctrl.unitsCtrl.text) ?? 0;
          widget.invoice.serviceItems[i].perUnit = double.tryParse(ctrl.perUnitCtrl.text) ?? 0.0;
        }
    }
    widget.invoice.termsAndConditions = _termsCtrl.text;
    widget.invoice.termsOfPayment = _paymentTermsCtrl.text;
    widget.invoice.bankCompanyName = _bankCompanyCtrl.text;
    widget.invoice.accountNumber = _accountNoCtrl.text;
    widget.invoice.ibanNumber = _ibanCtrl.text;
    widget.invoice.swiftBic = _swiftCtrl.text;
    widget.invoice.bankName = _bankNameCtrl.text;
    widget.invoice.branchName = _branchCtrl.text;
    widget.invoice.vatRate = double.tryParse(_vatCtrl.text) ?? 5.0;
  }

  bool _validateAll() {
    if (!_formKey.currentState!.validate()) return false;
    
    for (int i = 0; i < _itemControllersList.length; i++) {
      final ctrl = _itemControllersList[i];
      if (ctrl.unitCtrl.text.trim().isEmpty) {
        _showValidationError('Please enter UNIT for Item ${i + 1}');
        return false;
      }
      final perUnitStr = ctrl.perUnitCtrl.text.trim();
      if (perUnitStr.isEmpty || (double.tryParse(perUnitStr) ?? 0.0) <= 0) {
        _showValidationError('Please enter PER UNIT price for Item ${i + 1}');
        return false;
      }
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _generateProposal() async {
    await _handleAutoIncrement();
    _syncData();
    if (!_validateAll()) return;
    
    setState(() => _isGeneratingProposal = true);

    try {
      final proposalData = ProposalData.fromInvoiceModel(widget.invoice);
      final generator = PropertyInspectionPdfGenerator(data: proposalData);
      final dir = await getTemporaryDirectory();
      
      String nameForFile = widget.invoice.richTextClientDetails.isNotEmpty 
          ? widget.invoice.richTextClientDetails.split('\n').first 
          : 'Client';
      
      final sanitizedName = nameForFile
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
          .trim()
          .replaceAll(' ', '_');
          
      final fileName = 'Proposal_${widget.invoice.invoiceNumberShort}_${sanitizedName}.pdf';
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

  Future<void> _downloadProposal() async {
    await _handleAutoIncrement();
    _syncData();
    if (!_validateAll()) return;
    
    setState(() => _isGeneratingProposal = true);

    try {
      final proposalData = ProposalData.fromInvoiceModel(widget.invoice);
      final generator = PropertyInspectionPdfGenerator(data: proposalData);
      final dir = await getTemporaryDirectory();
      
      String nameForFile = widget.invoice.richTextClientDetails.isNotEmpty 
          ? widget.invoice.richTextClientDetails.split('\n').first 
          : 'Client';
          
      final sanitizedName = nameForFile
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
          .trim()
          .replaceAll(' ', '_');
          
      final fileName = 'Proposal_${widget.invoice.invoiceNumberShort}_${sanitizedName}.pdf';
      final outputPath = '${dir.path}/$fileName';

      final file = await generator.generate(outputPath);
      final bytes = await file.readAsBytes();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: fileName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading proposal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingProposal = false);
    }
  }

  void _goToPreview() async {
    await _handleAutoIncrement();
    _syncData();
    if (!_validateAll()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(invoice: widget.invoice),
      ),
    );
  }

  void _goToProposalPreview() async {
    await _handleAutoIncrement();
    _syncData();
    if (!_validateAll()) return;

    final proposalData = ProposalData.fromInvoiceModel(widget.invoice);
    
    String nameForFile = widget.invoice.richTextClientDetails.isNotEmpty 
        ? widget.invoice.richTextClientDetails.split('\n').first 
        : 'Client';
        
    final sanitizedName = nameForFile
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
        .trim()
        .replaceAll(' ', '_');
        
    final fileName = 'Proposal_${widget.invoice.invoiceNumberShort}_${sanitizedName}.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProposalPreviewScreen(
          data: proposalData,
          fileName: fileName,
        ),
      ),
    );
  }

  Future<void> _shareBothDocuments() async {
    await _handleAutoIncrement();
    _syncData();
    if (!_validateAll()) return;

    setState(() => _isSharingBoth = true);

    try {
      final dir = await getTemporaryDirectory();
      
      // 1. Generate Invoice PDF
      final invoiceFile = await PdfGeneratorService.generateInvoicePdf(widget.invoice);

      // 2. Generate Proposal PDF
      final proposalData = ProposalData.fromInvoiceModel(widget.invoice);
      final proposalGenerator = PropertyInspectionPdfGenerator(data: proposalData);
      
      String nameForFile = widget.invoice.richTextClientDetails.isNotEmpty 
          ? widget.invoice.richTextClientDetails.split('\n').first 
          : 'Client';
          
      final sanitizedName = nameForFile
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
          .trim()
          .replaceAll(' ', '_');
          
      final proposalFileName = 'Proposal_${widget.invoice.invoiceNumberShort}_${sanitizedName}.pdf';
      final proposalPath = '${dir.path}/$proposalFileName';
      final proposalFile = await proposalGenerator.generate(proposalPath);

      // 3. Share Both
      await Share.shareXFiles(
        [
          XFile(invoiceFile.path),
          XFile(proposalFile.path),
        ],
        text: 'Property Inspection Documents - ${widget.invoice.invoiceNumber}',
        subject: 'Invoice & Proposal - ${widget.invoice.invoiceNumber}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing bundle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharingBoth = false);
    }
  }

  String _processSaaSFormatting(String input) {
    if (input.isEmpty) return "";
    return input.split('\n').map((line) {
      String cleanLine = line.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (cleanLine.isEmpty) return "";
      return cleanLine.split(' ').map((word) {
        if (word.isEmpty) return "";
        if (word.length == 1) return word.toUpperCase();
        if (word.startsWith('**') && word.endsWith('**')) {
          String core = word.replaceAll('**', '');
          return '**${core[0].toUpperCase()}${core.substring(1).toLowerCase()}**';
        }
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }).join('\n');
  }

  void _showEditCompanyDialog() {
    final nameCtrl = TextEditingController(text: widget.invoice.companyName);
    final addressCtrl = TextEditingController(text: widget.invoice.companyAddress);
    final trnCtrl = TextEditingController(text: widget.invoice.companyTRN);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Company Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Company Name')),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: trnCtrl, decoration: const InputDecoration(labelText: 'TRN')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.invoice.companyName = nameCtrl.text;
                widget.invoice.companyAddress = addressCtrl.text;
                widget.invoice.companyTRN = trnCtrl.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1565C0)),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Proforma',
              style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.grey), onPressed: () {}),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text('Tax Invoice', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              // const Text('Define the core identity and details of this document.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              // const SizedBox(height: 20),

              // --- INVOICE DETAILS SECTION ---
              // _buildSectionHeader('INVOICE DETAILS'),
              _buildLabel('INVOICE NUMBER'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _invoiceNumberCtrl,
                      hint: '2026-INV00748',
                      validator: (v) => v!.isEmpty ? 'Invoice number required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: IconButton(
                      onPressed: _incrementInvoiceNumber,
                      icon: const Icon(Icons.add, color: Colors.white),
                      tooltip: 'Increment Invoice Number',
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLabel('REFERENCE CODE'),
              _buildTextField(controller: _referenceCodeCtrl, hint: 'ZPI2026-00748'),
              const SizedBox(height: 12),
              _buildLabel('ISSUE DATE'),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _buildTextField(controller: _issueDateCtrl, hint: 'MM/DD/YYYY', suffixIcon: const Icon(Icons.calendar_today, size: 18)),
                ),
              ),
              const SizedBox(height: 20),

              // --- COMPANY DETAILS SECTION ---
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[100], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.business, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        const Text('COMPANY DETAILS (ISSUER)', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        const Spacer(),
                        GestureDetector(
                          onTap: _showEditCompanyDialog,
                          child: const Text('EDIT', style: TextStyle(color: Color(0xFF1565C0), fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(widget.invoice.companyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(widget.invoice.companyAddress, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                      child: Text('TRN: ${widget.invoice.companyTRN}', style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- CLIENT DETAILS SECTION ---
              const Row(children: [Icon(Icons.person_outline, color: Color(0xFF1565C0)), SizedBox(width: 8), Text('Client Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('QUICK TEXT'),
                  Row(
                    children: [
                      TextButton.icon(onPressed: _pasteFromClipboard, icon: const Icon(Icons.content_paste, size: 16), label: const Text('Paste')),
                      TextButton.icon(
                        onPressed: () => setState(() => _richTextClientDetailsCtrl.text = _processSaaSFormatting(_richTextClientDetailsCtrl.text)),
                        icon: const Icon(Icons.auto_fix_high, size: 16, color: Color(0xFF0D9488)),
                        label: const Text('Clean', style: TextStyle(color: Color(0xFF0D9488))),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final text = _richTextClientDetailsCtrl.text;
                          final selection = _richTextClientDetailsCtrl.selection;
                          if (selection.isValid && !selection.isCollapsed) {
                            final selectedText = text.substring(selection.start, selection.end);
                            _richTextClientDetailsCtrl.text = text.replaceRange(selection.start, selection.end, '**$selectedText**');
                          } else {
                            _richTextClientDetailsCtrl.text = text + ' ****';
                          }
                        },
                        icon: const Icon(Icons.format_bold, size: 18), label: const Text('Bold'),
                      ),
                    ],
                  ),
                ],
              ),
              _buildTextField(controller: _richTextClientDetailsCtrl, hint: 'Type or Paste Client Details here...', maxLines: 10),
              const SizedBox(height: 32),

              // --- SERVICE ITEMS SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Service Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(onTap: _addItem, child: const Row(children: [Icon(Icons.add_circle_outline, color: Color(0xFF1565C0)), SizedBox(width: 4), Text('Add Item', style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w600))])),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(_itemControllersList.length, (index) => _buildServiceItemCard(index)),
              const SizedBox(height: 16),

              // --- TOTALS SECTION ---
              _syncTotalsAndBuildTotalsCard(),
              const SizedBox(height: 20),
              _buildLabel('VAT RATE (%)'),
              SizedBox(width: 100, child: _buildTextField(controller: _vatCtrl, hint: '5', keyboardType: TextInputType.number, onChanged: (_) => setState(() => _syncData()))),
              const SizedBox(height: 32),

              // --- TERMS & BANK SECTION ---
              const Text('Terms & Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildLabel('TERMS AND CONDITIONS'),
              _buildTextField(controller: _termsCtrl, hint: 'As per Proposal', textColor: const Color(0xFF1565C0)),
              const SizedBox(height: 12),
              _buildLabel('TERMS OF PAYMENT'),
              _buildTextField(controller: _paymentTermsCtrl, hint: 'Payment terms...', maxLines: 2, textColor: Colors.red[700], fillColor: const Color(0xFFFFF3F3)),
              const SizedBox(height: 32),
              const Text('Bank Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
                child: Column(
                  children: [
                    Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('COMPANY NAME'), _buildTextField(controller: _bankCompanyCtrl, hint: 'Company Name')])), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('ACCOUNT NO'), _buildTextField(controller: _accountNoCtrl, hint: '0323...')]))]),
                    const SizedBox(height: 10),
                    Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('IBAN'), _buildTextField(controller: _ibanCtrl, hint: 'AE82...')])), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('SWIFT'), _buildTextField(controller: _swiftCtrl, hint: 'NRAK...')]))]),
                    const SizedBox(height: 10),
                    Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('BANK'), _buildTextField(controller: _bankNameCtrl, hint: 'RAK')])), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('BRANCH'), _buildTextField(controller: _branchCtrl, hint: 'Branch...')]))]),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Extra space for bottom bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: (_isSharingBoth || !_allPricesVerified()) ? null : _shareBothDocuments,
      backgroundColor: _allPricesVerified() ? const Color(0xFF0D9488) : Colors.grey,
      elevation: 4,
      highlightElevation: 8,
      icon: _isSharingBoth 
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
      label: Text(
        _isSharingBoth ? 'Generating...' : 'Share Both',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.1)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    Color? textColor,
    Color? fillColor,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(color: textColor ?? Colors.black87),
      inputFormatters: keyboardType == TextInputType.number ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: fillColor ?? Colors.white,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1565C0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildServiceItemCard(int index) {
    final ctrl = _itemControllersList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [_buildLabel('ITEM NAME'), const Spacer(), GestureDetector(onTap: () => _removeItem(index), child: const Icon(Icons.delete_outline, color: Colors.grey))]),
          _buildTextField(controller: ctrl.nameCtrl, hint: 'Item Name', onChanged: (_) => setState(() => _syncData())),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('UNIT'), _buildTextField(controller: ctrl.unitCtrl, hint: '2BHK', onChanged: (_) => setState(() => _syncData()))])),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('UNITS'), _buildTextField(controller: ctrl.unitsCtrl, hint: '1', keyboardType: TextInputType.number, onChanged: (_) => setState(() => _syncData()))])),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('PER UNIT'),
                    _buildTextField(controller: ctrl.perUnitCtrl, hint: '850', keyboardType: TextInputType.number, onChanged: (_) => setState(() => _syncData())),
                  ],
                ),
              ),
            ],
          ),
          if (ctrl.perUnitCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
              child: Text(
                '${ctrl.perUnitMirror} AED',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1565C0), letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('CONFIRM PRICE'),
                _buildTextField(
                  controller: ctrl.confirmPerUnitCtrl,
                  hint: 'Confirm Price',
                  keyboardType: TextInputType.number,
                  fillColor: ctrl.confirmPerUnitCtrl.text.isEmpty ? Colors.white : (ctrl.isVerified ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2)),
                  suffixIcon: ctrl.confirmPerUnitCtrl.text.isEmpty 
                    ? null 
                    : (ctrl.isVerified 
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 20) 
                        : const Icon(Icons.error_outline, color: Colors.red, size: 20)),
                  onChanged: (_) => setState(() => _syncData()),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Amount: AED ${( (double.tryParse(ctrl.perUnitCtrl.text) ?? 0.0) * (int.tryParse(ctrl.unitsCtrl.text) ?? 0)).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _syncTotalsAndBuildTotalsCard() {
    _syncData();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal', style: TextStyle(color: Colors.grey)), Text('AED ${widget.invoice.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600))]),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('VAT ', style: TextStyle(color: Colors.grey)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4)), child: Text('${widget.invoice.vatRate.toInt()}%', style: const TextStyle(fontSize: 12, color: Colors.white))),
              const Spacer(),
              Text('AED ${widget.invoice.vatAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Amount (AED)', style: TextStyle(fontWeight: FontWeight.bold)), Text('AED ${widget.invoice.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 18))]),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final bool isReady = _allPricesVerified();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isReady ? _goToPreview : null,
                icon: const Icon(Icons.visibility_outlined, size: 20),
                label: const Text('Preview'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isReady ? _goToPreview : null,
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                label: const Text('Generate', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReady ? const Color(0xFF1565C0) : Colors.grey, 
                  padding: const EdgeInsets.symmetric(vertical: 16), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (isReady && !_isGeneratingProposal) ? _generateProposal : null,
                      icon: _isGeneratingProposal ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.share, color: Colors.white, size: 20),
                      label: Text(_isGeneratingProposal ? 'Processing...' : 'Proposal', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isReady ? const Color(0xFF00897B) : Colors.grey, 
                        padding: const EdgeInsets.symmetric(vertical: 16), 
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))),
                      ),
                    ),
                  ),
                  Container(
                    height: 54, // Match button height
                    decoration: BoxDecoration(
                      color: isReady ? const Color(0xFF00695C) : Colors.grey[400],
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                    ),
                    child: IconButton(
                      onPressed: isReady ? _goToProposalPreview : null,
                      icon: const Icon(Icons.visibility_outlined, color: Colors.white, size: 22),
                      tooltip: 'Preview Proposal',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: isReady ? Colors.teal[700] : Colors.grey, 
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: (isReady && !_isGeneratingProposal) ? _downloadProposal : null,
                icon: _isGeneratingProposal ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white)) : const Icon(Icons.download_rounded, color: Colors.white, size: 24),
                tooltip: 'Download Proposal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemControllers {
  final TextEditingController nameCtrl;
  final TextEditingController unitCtrl;
  final TextEditingController unitsCtrl;
  final TextEditingController perUnitCtrl;
  final TextEditingController confirmPerUnitCtrl;

  _ItemControllers({
    required this.nameCtrl,
    required this.unitCtrl,
    required this.unitsCtrl,
    required this.perUnitCtrl,
    required this.confirmPerUnitCtrl,
  });

  factory _ItemControllers.fromItem(ServiceItem item) {
    return _ItemControllers(
      nameCtrl: TextEditingController(text: item.itemName),
      unitCtrl: TextEditingController(text: item.unit),
      unitsCtrl: TextEditingController(text: item.noOfUnits > 0 ? item.noOfUnits.toString() : '1'),
      perUnitCtrl: TextEditingController(text: item.perUnit > 0 ? item.perUnit.toString() : ''),
      confirmPerUnitCtrl: TextEditingController(),
    );
  }

  String get perUnitMirror {
    final val = int.tryParse(perUnitCtrl.text) ?? 0;
    if (val == 0) return "";
    try {
      return NumberToWordsEnglish.convert(val).toUpperCase();
    } catch (_) {
      return "";
    }
  }

  bool get isVerified {
    final p1 = perUnitCtrl.text.trim();
    final p2 = confirmPerUnitCtrl.text.trim();
    if (p1.isEmpty) return false;
    return p1 == p2;
  }

  void dispose() {
    nameCtrl.dispose();
    unitCtrl.dispose();
    unitsCtrl.dispose();
    perUnitCtrl.dispose();
    confirmPerUnitCtrl.dispose();
  }
}

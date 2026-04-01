import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'invoice_model.dart';
import 'invoice_number_service.dart';
import 'step2_line_items.dart';

class Step1InvoiceDetails extends StatefulWidget {
  final InvoiceModel invoice;
  final PageController pageController;
  
  const Step1InvoiceDetails({
    super.key,
    required this.invoice,
    required this.pageController,
  });

  @override
  State<Step1InvoiceDetails> createState() => _Step1InvoiceDetailsState();
}

class _Step1InvoiceDetailsState extends State<Step1InvoiceDetails> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  bool get wantKeepAlive => true;

  late TextEditingController _invoiceNumberCtrl;
  late TextEditingController _referenceCodeCtrl;
  late TextEditingController _issueDateCtrl;
  late TextEditingController _clientNameCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _bedroomsCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _sqftCtrl;
  late TextEditingController _richTextClientDetailsCtrl;
  bool _useRichTextMode = false;

  final List<Map<String, TextEditingController>> _additionalFieldControllers = [];

  @override
  void initState() {
    super.initState();
    _invoiceNumberCtrl = TextEditingController(text: widget.invoice.invoiceNumber);
    _referenceCodeCtrl = TextEditingController(text: widget.invoice.referenceCode);
    _issueDateCtrl = TextEditingController(
        text: DateFormat('MM/dd/yyyy').format(widget.invoice.issueDate));
    _clientNameCtrl = TextEditingController(text: widget.invoice.clientName);
    _unitCtrl = TextEditingController(text: widget.invoice.unit);
    _bedroomsCtrl = TextEditingController(text: widget.invoice.noOfBedrooms);
    _locationCtrl = TextEditingController(text: widget.invoice.location);
    _emailCtrl = TextEditingController(text: widget.invoice.email);
    _phoneCtrl = TextEditingController(text: widget.invoice.phoneNo);
    _sqftCtrl = TextEditingController(text: widget.invoice.sqft);
    _richTextClientDetailsCtrl = TextEditingController(text: widget.invoice.richTextClientDetails);
    _useRichTextMode = widget.invoice.useRichTextClientDetails;
    _loadLastInvoiceNumber();
  }

  /// Load the last persisted invoice number and pre-fill both fields.
  Future<void> _loadLastInvoiceNumber() async {
    final lastNum = await InvoiceNumberService.getLastInvoiceNumber();
    final formatted = InvoiceNumberService.formatFull(lastNum);
    final refCode = 'ZPI2026-${lastNum.toString().padLeft(5, '0')}';
    setState(() {
      _invoiceNumberCtrl.text = formatted;
      widget.invoice.invoiceNumber = formatted;
      _referenceCodeCtrl.text = refCode;
      widget.invoice.referenceCode = refCode;
    });
  }

  /// Increment the numeric suffix, update both fields, and persist.
  Future<void> _incrementInvoiceNumber() async {
    final currentNum = InvoiceNumberService.parseNumber(_invoiceNumberCtrl.text);
    final nextNum = currentNum + 1;
    final formatted = InvoiceNumberService.formatFull(nextNum);
    final refCode = 'ZPI2026-${nextNum.toString().padLeft(5, '0')}';
    await InvoiceNumberService.saveInvoiceNumber(nextNum);
    setState(() {
      _invoiceNumberCtrl.text = formatted;
      widget.invoice.invoiceNumber = formatted;
      _referenceCodeCtrl.text = refCode;
      widget.invoice.referenceCode = refCode;
    });
  }

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    _referenceCodeCtrl.dispose();
    _issueDateCtrl.dispose();
    _clientNameCtrl.dispose();
    _unitCtrl.dispose();
    _bedroomsCtrl.dispose();
    _locationCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _sqftCtrl.dispose();
    _richTextClientDetailsCtrl.dispose();
    super.dispose();
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

  /// Paste text from clipboard into the rich text client details controller.
  Future<void> _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _richTextClientDetailsCtrl.text = data.text!;
      });
      // Also trigger cleaning/formatting automatically if needed?
      // For now, just paste.
    }
  }

  void _addDynamicField() {
    final labelCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    setState(() {
      _additionalFieldControllers.add({'label': labelCtrl, 'value': valueCtrl});
    });
  }

  void _removeDynamicField(int index) {
    setState(() {
      _additionalFieldControllers[index]['label']!.dispose();
      _additionalFieldControllers[index]['value']!.dispose();
      _additionalFieldControllers.removeAt(index);
    });
  }

  void _proceedToStep2() {
    if (_formKey.currentState!.validate()) {
      widget.invoice.invoiceNumber = _invoiceNumberCtrl.text.trim();
      widget.invoice.referenceCode = _referenceCodeCtrl.text.trim();
      widget.invoice.clientName = _clientNameCtrl.text.trim();
      widget.invoice.unit = _unitCtrl.text.trim();
      widget.invoice.noOfBedrooms = _bedroomsCtrl.text.trim();
      widget.invoice.location = _locationCtrl.text.trim();
      widget.invoice.email = _emailCtrl.text.trim();
      widget.invoice.phoneNo = _phoneCtrl.text.trim();
      widget.invoice.sqft = _sqftCtrl.text.trim();
      widget.invoice.useRichTextClientDetails = _useRichTextMode;
      widget.invoice.richTextClientDetails = _richTextClientDetailsCtrl.text.trim();

      // Persist the current invoice number (handles manual edits too)
      final currentNum = InvoiceNumberService.parseNumber(widget.invoice.invoiceNumber);
      InvoiceNumberService.saveInvoiceNumber(currentNum);

      widget.invoice.additionalClientFields = _additionalFieldControllers.map((m) {
        return {
          'label': m['label']!.text.trim(),
          'value': m['value']!.text.trim(),
        };
      }).toList();

      widget.pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
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
                      'STEP 1 OF 2',
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    const Text(
                      'Tax Invoice',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Define the core identity of this document.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    // Invoice Number
                    _buildLabel('INVOICE NUMBER'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _invoiceNumberCtrl,
                            hint: '2026-INV00748',
                            validator: (v) =>
                                v!.isEmpty ? 'Invoice number required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1565C0).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
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

                    // Reference Code
                    _buildLabel('REFERENCE CODE'),
                    _buildTextField(
                      controller: _referenceCodeCtrl,
                      hint: 'ZPI2026-00748',
                    ),
                    const SizedBox(height: 12),

                    // Issue Date
                    _buildLabel('ISSUE DATE'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _issueDateCtrl,
                          hint: 'MM/DD/YYYY',
                          suffixIcon: const Icon(Icons.calendar_today, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Company Details
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.business, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              const Text(
                                'COMPANY DETAILS (ISSUER)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _showEditCompanyDialog(),
                                child: const Text(
                                  'EDIT',
                                  style: TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.invoice.companyName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.invoice.companyAddress,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                           const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'TRN: ${widget.invoice.companyTRN}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Client Details
                    // Client Details Header & Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                color: Color(0xFF1565C0)),
                            const SizedBox(width: 8),
                            const Text(
                              'Client Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Modern Toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              _buildToggleButton(
                                "Separate",
                                !_useRichTextMode,
                                () => setState(() => _useRichTextMode = false),
                              ),
                              _buildToggleButton(
                                "Quick Text",
                                _useRichTextMode,
                                () => setState(() => _useRichTextMode = true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_useRichTextMode) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _pasteFromClipboard,
                            child: _buildLabel('CLIENT DETAILX'),
                          ),
                          Row(
                            children: [
                              // --- PASTE BUTTON ---
                              TextButton.icon(
                                onPressed: _pasteFromClipboard,
                                icon: const Icon(Icons.content_paste,
                                    size: 16, color: Color(0xFF1565C0)),
                                label: const Text('Paste'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF1565C0),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 4),

                              // --- NEW: CLEAN & FORMAT BUTTON (SaaS Magic Wand) ---
                              TextButton.icon(
                                onPressed: () {
                                  final currentText =
                                      _richTextClientDetailsCtrl.text;
                                  final formatted =
                                      _processSaaSFormatting(currentText);
                                  setState(() {
                                    _richTextClientDetailsCtrl.text = formatted;
                                  });
                                },
                                icon: const Icon(Icons.auto_fix_high,
                                    size: 16,
                                    color: Color(0xFF0D9488)), // Emerald Green
                                label: const Text('Clean'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF0D9488),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 4),

                              // --- YOUR BOLD BUTTON ---
                              TextButton.icon(
                                onPressed: () {
                                  final text = _richTextClientDetailsCtrl.text;
                                  final selection =
                                      _richTextClientDetailsCtrl.selection;
                                  if (selection.isValid &&
                                      !selection.isCollapsed) {
                                    final selectedText = text.substring(
                                        selection.start, selection.end);
                                    final newText = text.replaceRange(
                                        selection.start,
                                        selection.end,
                                        '**$selectedText**');
                                    _richTextClientDetailsCtrl.text = newText;
                                    _richTextClientDetailsCtrl.selection =
                                        TextSelection.collapsed(
                                            offset: selection.start +
                                                2 +
                                                selectedText.length +
                                                2);
                                  } else {
                                    final newText = text + ' ****';
                                    _richTextClientDetailsCtrl.text = newText;
                                    _richTextClientDetailsCtrl.selection =
                                        TextSelection.collapsed(
                                            offset: newText.length - 2);
                                  }
                                },
                                icon: const Icon(Icons.format_bold, size: 18),
                                label: const Text('Bold'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF1565C0),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildTextField(
                        controller: _richTextClientDetailsCtrl,
                        hint: 'Type or Paste Client Details here...\nUse Bold button to highlight.',
                        maxLines: 10,
                        // Ensure text stays left aligned (Default is left, but just being safe)
                      ),
                      const SizedBox(height: 12),
                    ]
                    else ...[
                      _buildLabel('FULL NAME'),
                      _buildTextField(
                        controller: _clientNameCtrl,
                        hint: 'JAIKUMAR RAMAN',
                        validator: (v) =>
                            v!.isEmpty ? 'Client name required' : null,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('UNIT'),
                                _buildTextField(
                                    controller: _unitCtrl, hint: '408'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('NO. OF BEDROOMS'),
                                _buildTextField(
                                    controller: _bedroomsCtrl,
                                    hint: '2+maids'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('LOCATION'),
                      _buildTextField(
                        controller: _locationCtrl,
                        hint: 'Amalia Residences, Al Furjan, Jebel Ali First',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('EMAIL ADDRESS'),
                      _buildTextField(
                        controller: _emailCtrl,
                        hint: 'jazikhaan@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('PHONE NO.'),
                      _buildTextField(
                        controller: _phoneCtrl,
                        hint: '0505276988',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('SQFT'),
                      _buildTextField(
                        controller: _sqftCtrl,
                        hint: '1253',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),

                      // Additional dynamic fields
                      ..._additionalFieldControllers.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final controllers = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('FIELD LABEL'),
                                      _buildTextField(
                                        controller: controllers['label']!,
                                        hint: 'Label',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('VALUE'),
                                      _buildTextField(
                                        controller: controllers['value']!,
                                        hint: 'Value',
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.red),
                                  onPressed: () => _removeDynamicField(idx),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      }),

                      GestureDetector(
                        onTap: _addDynamicField,
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle_outline,
                                color: Color(0xFF1565C0)),
                            const SizedBox(width: 6),
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
                      const SizedBox(height: 6),
                      const Text(
                        'User Can Add More dynamic Fields About Clients',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _proceedToStep2,
                  icon: const SizedBox.shrink(),
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next: Service Items',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _processSaaSFormatting(String input) {
    if (input.isEmpty) return "";

    // 1. Split by lines to preserve the user's vertical structure (New Lines)
    return input.split('\n').map((line) {
      // 2. Remove extra spaces inside the line and trim the ends
      // \s+ catches any number of spaces and replaces them with 1 space
      String cleanLine = line.trim().replaceAll(RegExp(r'\s+'), ' ');

      if (cleanLine.isEmpty) return "";

      // 3. Capitalize every word (First letter Upper, rest Lower)
      return cleanLine.split(' ').map((word) {
        if (word.isEmpty) return "";
        if (word.length == 1) return word.toUpperCase();

        // Keep Markdown ** markers safe if they exist
        if (word.startsWith('**') && word.endsWith('**')) {
          String core = word.replaceAll('**', '');
          return '**${core[0].toUpperCase()}${core.substring(1).toLowerCase()}**';
        }

        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }).join('\n'); // Put the lines back together
  }
  String _formatClientDetails(String input) {
    if (input.isEmpty) return "";

    // Split by lines to keep your formatting (Name, Address, Phone, etc.)
    return input.split('\n').map((line) {
      // 1. Remove extra internal spaces and trim edges
      String cleanLine = line.trim().replaceAll(RegExp(r'\s+'), ' ');

      if (cleanLine.isEmpty) return "";

      // 2. Capitalize First Letter of every word
      return cleanLine.split(' ').map((word) {
        if (word.isEmpty) return "";
        // Handle the "Capitalize" logic
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }).join('\n'); // Join lines back together
  }
  void _showEditCompanyDialog() {
    final nameCtrl = TextEditingController(text: widget.invoice.companyName);
    final addressCtrl = TextEditingController(text: widget.invoice.companyAddress);
    final trnCtrl = TextEditingController(text: widget.invoice.companyTRN);
 nominations:
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Company Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: trnCtrl,
                decoration: const InputDecoration(labelText: 'TRN'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.invoice.companyName = nameCtrl.text;
                widget.invoice.companyAddress = addressCtrl.text;
                widget.invoice.companyTRN = trnCtrl.text;
              });
 nominations:              Navigator.pop(context);
            },
            child: const Text('Save'),
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
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
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
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

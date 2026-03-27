import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'invoice_model.dart';
import 'step2_line_items.dart';

class Step1InvoiceDetails extends StatefulWidget {
  const Step1InvoiceDetails({super.key});

  @override
  State<Step1InvoiceDetails> createState() => _Step1InvoiceDetailsState();
}

class _Step1InvoiceDetailsState extends State<Step1InvoiceDetails> {
  final _formKey = GlobalKey<FormState>();
  final InvoiceModel _invoice = InvoiceModel();

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

  final List<Map<String, TextEditingController>> _additionalFieldControllers = [];

  @override
  void initState() {
    super.initState();
    _invoiceNumberCtrl = TextEditingController(text: _invoice.invoiceNumber);
    _referenceCodeCtrl = TextEditingController(text: _invoice.referenceCode);
    _issueDateCtrl = TextEditingController(
        text: DateFormat('MM/dd/yyyy').format(_invoice.issueDate));
    _clientNameCtrl = TextEditingController(text: _invoice.clientName);
    _unitCtrl = TextEditingController(text: _invoice.unit);
    _bedroomsCtrl = TextEditingController(text: _invoice.noOfBedrooms);
    _locationCtrl = TextEditingController(text: _invoice.location);
    _emailCtrl = TextEditingController(text: _invoice.email);
    _phoneCtrl = TextEditingController(text: _invoice.phoneNo);
    _sqftCtrl = TextEditingController(text: _invoice.sqft);
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
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _invoice.issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _invoice.issueDate = picked;
        _issueDateCtrl.text = DateFormat('MM/dd/yyyy').format(picked);
      });
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
      _invoice.invoiceNumber = _invoiceNumberCtrl.text.trim();
      _invoice.referenceCode = _referenceCodeCtrl.text.trim();
      _invoice.clientName = _clientNameCtrl.text.trim();
      _invoice.unit = _unitCtrl.text.trim();
      _invoice.noOfBedrooms = _bedroomsCtrl.text.trim();
      _invoice.location = _locationCtrl.text.trim();
      _invoice.email = _emailCtrl.text.trim();
      _invoice.phoneNo = _phoneCtrl.text.trim();
      _invoice.sqft = _sqftCtrl.text.trim();

      _invoice.additionalClientFields = _additionalFieldControllers.map((m) {
        return {
          'label': m['label']!.text.trim(),
          'value': m['value']!.text.trim(),
        };
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Step2LineItems(invoice: _invoice),
        ),
      );
    }
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
                      'Proforma Invoice',
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
                    _buildTextField(
                      controller: _invoiceNumberCtrl,
                      hint: '2025-INV00693',
                      validator: (v) =>
                          v!.isEmpty ? 'Invoice number required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Reference Code
                    _buildLabel('REFERENCE CODE'),
                    _buildTextField(
                      controller: _referenceCodeCtrl,
                      hint: 'ZPI2025-00693',
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
                            _invoice.companyName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _invoice.companyAddress,
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
                              'TRN: ${_invoice.companyTRN}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Client Details
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
                    const SizedBox(height: 12),

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

  void _showEditCompanyDialog() {
    final nameCtrl = TextEditingController(text: _invoice.companyName);
    final addressCtrl = TextEditingController(text: _invoice.companyAddress);
    final trnCtrl = TextEditingController(text: _invoice.companyTRN);

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
                _invoice.companyName = nameCtrl.text;
                _invoice.companyAddress = addressCtrl.text;
                _invoice.companyTRN = trnCtrl.text;
              });
              Navigator.pop(context);
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
}

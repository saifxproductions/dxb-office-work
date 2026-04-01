class ServiceItem {
  String itemName;
  String unit;
  int noOfUnits;
  double perUnit;

  ServiceItem({
    this.itemName = '',
    this.unit = '',
    this.noOfUnits = 0,
    this.perUnit = 0.0,
  });

  double get amount => noOfUnits * perUnit;
}

class InvoiceModel {
  // Step 1 - Invoice Details
  String invoiceNumber;
  String referenceCode;
  DateTime issueDate;

  // Company (Issuer)
  String companyName;
  String companyAddress;
  String companyTRN;

  // Client Details
  String clientName;
  String unit;
  String noOfBedrooms;
  String location;
  String email;
  String phoneNo;
  String sqft;
  List<Map<String, String>> additionalClientFields;
  bool useRichTextClientDetails;
  String richTextClientDetails;

  // Step 2 - Service Items
  List<ServiceItem> serviceItems;

  // Terms
  String termsAndConditions;
  String termsOfPayment;

  // Bank Details
  String bankCompanyName;
  String accountNumber;
  String ibanNumber;
  String swiftBic;
  String bankName;
  String branchName;

  double vatRate;

  InvoiceModel({
    this.invoiceNumber = '2026-INV00693',
    this.referenceCode = 'ZPI2026-00693',
    DateTime? issueDate,
    this.companyName = 'RUKN ALAEZ PROPERTY OBSERVER L.L.C S.O.C',
    this.companyAddress = 'Office 201 Insurance Building, UAE',
    this.companyTRN = '104820060200003',
    this.clientName = '',
    this.unit = '',
    this.noOfBedrooms = '',
    this.location = '',
    this.email = '',
    this.phoneNo = '',
    this.sqft = '',
    List<Map<String, String>>? additionalClientFields,
    List<ServiceItem>? serviceItems,
    this.termsAndConditions = 'As per Proposal',
    this.termsOfPayment = '100% of the fees payable before commencing any work.',
    this.bankCompanyName = 'Rukan Alaez Property observer',
    this.accountNumber = '0323439354001',
    this.ibanNumber = 'AE820400000323439354001',
    this.swiftBic = 'NRAKAEAK',
    this.bankName = 'RAK',
    this.branchName = 'Rak BankEmaar BussinnessPark',
    this.vatRate = 5.0,
    this.useRichTextClientDetails = false,
    this.richTextClientDetails = '',
  })  : issueDate = issueDate ?? DateTime.now(),
        additionalClientFields = additionalClientFields ?? [],
        serviceItems = serviceItems ??
            [
              ServiceItem(
                itemName: 'Property Snagging/Inspection',
                unit: '',
                noOfUnits: 1,
                perUnit: 0.0,
              ),
            ];

  double get subtotal =>
      serviceItems.fold(0.0, (sum, item) => sum + item.amount);

  double get vatAmount => subtotal * (vatRate / 100);

  double get totalAmount => subtotal + vatAmount;

  String get invoiceNumberShort {
    final parts = invoiceNumber.split('INV');
    if (parts.length > 1) return parts[1];
    return invoiceNumber;
  }
}

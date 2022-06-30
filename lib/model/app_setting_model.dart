class AppSettingModel {
  bool? success;
  Data? data;

  AppSettingModel({this.success, this.data});

  AppSettingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? cancelReason;
  String? companyWhiteLogo;
  String? companyBlackLogo;
  String? favicon;
  String? businessName;
  String? contactPersonName;
  String? contact;
  String? businessAddress;
  String? country;
  String? taxId;
  String? timezone;
  String? currency;
  String? currencySymbol;
  String? helpLineNo;
  String? startTime;
  String? endTime;
  int? businessAvailability;
  String? message;
  int? isItemTax;
  String? itemTax;
  String? taxType;
  String? vendorName;
  String? driverName;
  String? recommandedMenu;
  int? isPickup;
  int? isSameDayDelivery;
  String? vendorDistance;
  String? paymentType;
  String? itemsCount;
  int? customerNotification;
  String? customerAppId;
  String? androidCustomerVersion;
  String? customerAuthKey;
  String? customerApiKey;
  int? driverNotification;
  String? driverAppId;
  String? driverAuthKey;
  String? driverApiKey;
  int? vendorNotification;
  String? vendorAppId;
  String? vendorAuthKey;
  String? vendorApiKey;
  String? privacyPolicy;
  String? companyDetails;
  String? termsAndCondition;
  String? help;
  String? aboutUs;
  String? siteColor;
  int? settlementDays;
  String? isDriverAllocation;
  int? isDriverAcceptMultipleOrder;
  int? driverAcceptMultipleOrderCount;
  int? driverAssignKm;
  String? driverVehicalType;
  String? driverEarning;
  String? twilioAccId;
  int? verification;
  int? verificationEmail;
  int? verificationPhone;
  String? twilioAuthToken;
  String? twilioPhoneNo;
  String? radius;
  int? driverAutoRefrese;
  String? mailMailer;
  String? mailHost;
  String? mailPort;
  String? mailUsername;
  String? mailPassword;
  String? mailEncryption;
  String? mailFromAddress;
  int? customerMail;
  int? vendorMail;
  int? driverMail;
  String? createdAt;
  String? updatedAt;
  String? whiteLogo;
  String? blackLogo;

  Data(
      {this.id,
        this.cancelReason,
        this.companyWhiteLogo,
        this.companyBlackLogo,
        this.favicon,
        this.businessName,
        this.contactPersonName,
        this.contact,
        this.businessAddress,
        this.country,
        this.taxId,
        this.timezone,
        this.currency,
        this.currencySymbol,
        this.helpLineNo,
        this.startTime,
        this.companyDetails,
        this.endTime,
        this.businessAvailability,
        this.androidCustomerVersion,
        this.message,
        this.isItemTax,
        this.itemTax,
        this.taxType,
        this.vendorName,
        this.driverName,
        this.recommandedMenu,
        this.isPickup,
        this.isSameDayDelivery,
        this.vendorDistance,
        this.paymentType,
        this.itemsCount,
        this.customerNotification,
        this.customerAppId,
        this.customerAuthKey,
        this.customerApiKey,
        this.driverNotification,
        this.driverAppId,
        this.driverAuthKey,
        this.driverApiKey,
        this.vendorNotification,
        this.vendorAppId,
        this.vendorAuthKey,
        this.vendorApiKey,
        this.privacyPolicy,
        this.termsAndCondition,
        this.help,
        this.aboutUs,
        this.siteColor,
        this.settlementDays,
        this.isDriverAllocation,
        this.isDriverAcceptMultipleOrder,
        this.driverAcceptMultipleOrderCount,
        this.driverAssignKm,
        this.driverVehicalType,
        this.driverEarning,
        this.twilioAccId,
        this.verification,
        this.verificationEmail,
        this.verificationPhone,
        this.twilioAuthToken,
        this.twilioPhoneNo,
        this.radius,
        this.driverAutoRefrese,
        this.mailMailer,
        this.mailHost,
        this.mailPort,
        this.mailUsername,
        this.mailPassword,
        this.mailEncryption,
        this.mailFromAddress,
        this.customerMail,
        this.vendorMail,
        this.driverMail,
        this.createdAt,
        this.updatedAt,
        this.whiteLogo,
        this.blackLogo});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cancelReason = json['cancel_reason'];
    companyWhiteLogo = json['company_white_logo'];
    companyBlackLogo = json['company_black_logo'];
    favicon = json['favicon'];
    businessName = json['business_name'];
    contactPersonName = json['contact_person_name'];
    contact = json['contact'];
    androidCustomerVersion = json['android_customer_version'];
    businessAddress = json['business_address'];
    country = json['country'];
    taxId = json['tax_id'];
    timezone = json['timezone'];
    currency = json['currency'];
    currencySymbol = json['currency_symbol'];
    helpLineNo = json['help_line_no'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    companyDetails = json['company_details'];
    businessAvailability = json['business_availability'];
    message = json['message'];
    isItemTax = json['isItemTax'];
    itemTax = json['item_tax'];
    taxType = json['tax_type'];
    vendorName = json['vendor_name'];
    driverName = json['driver_name'];
    recommandedMenu = json['recommanded_menu'];
    isPickup = json['isPickup'];
    isSameDayDelivery = json['isSameDayDelivery'];
    vendorDistance = json['vendor_distance'];
    paymentType = json['payment_type'];
    itemsCount = json['items_count'];
    customerNotification = json['customer_notification'];
    customerAppId = json['customer_app_id'];
    customerAuthKey = json['customer_auth_key'];
    customerApiKey = json['customer_api_key'];
    driverNotification = json['driver_notification'];
    driverAppId = json['driver_app_id'];
    driverAuthKey = json['driver_auth_key'];
    driverApiKey = json['driver_api_key'];
    vendorNotification = json['vendor_notification'];
    vendorAppId = json['vendor_app_id'];
    vendorAuthKey = json['vendor_auth_key'];
    vendorApiKey = json['vendor_api_key'];
    privacyPolicy = json['privacy_policy'];
    termsAndCondition = json['terms_and_condition'];
    help = json['help'];
    aboutUs = json['about_us'];
    siteColor = json['site_color'];
    settlementDays = json['settlement_days'];
    isDriverAllocation = json['is_driver_allocation'];
    isDriverAcceptMultipleOrder = json['is_driver_accept_multipleorder'];
    driverAcceptMultipleOrderCount = json['driver_accept_multiple_order_count'];
    driverAssignKm = json['driver_assign_km'];
    driverVehicalType = json['driver_vehical_type'];
    driverEarning = json['driver_earning'];
    twilioAccId = json['twilio_acc_id'];
    verification = json['verification'];
    verificationEmail = json['verification_email'];
    verificationPhone = json['verification_phone'];
    twilioAuthToken = json['twilio_auth_token'];
    twilioPhoneNo = json['twilio_phone_no'];
    radius = json['radius'];
    driverAutoRefrese = json['driver_auto_refrese'];
    mailMailer = json['mail_mailer'];
    mailHost = json['mail_host'];
    mailPort = json['mail_port'];
    mailUsername = json['mail_username'];
    mailPassword = json['mail_password'];
    mailEncryption = json['mail_encryption'];
    mailFromAddress = json['mail_from_address'];
    customerMail = json['customer_mail'];
    vendorMail = json['vendor_mail'];
    driverMail = json['driver_mail'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    whiteLogo = json['whitelogo'];
    blackLogo = json['blacklogo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cancel_reason'] = this.cancelReason;
    data['company_white_logo'] = this.companyWhiteLogo;
    data['company_black_logo'] = this.companyBlackLogo;
    data['favicon'] = this.favicon;
    data['company_details'] = this.companyDetails;
    data['business_name'] = this.businessName;
    data['contact_person_name'] = this.contactPersonName;
    data['contact'] = this.contact;
    data['business_address'] = this.businessAddress;
    data['country'] = this.country;
    data['tax_id'] = this.taxId;
    data['timezone'] = this.timezone;
    data['currency'] = this.currency;
    data['currency_symbol'] = this.currencySymbol;
    data['help_line_no'] = this.helpLineNo;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['android_customer_version'] = this.androidCustomerVersion;
    data['business_availability'] = this.businessAvailability;
    data['message'] = this.message;
    data['isItemTax'] = this.isItemTax;
    data['item_tax'] = this.itemTax;
    data['tax_type'] = this.taxType;
    data['vendor_name'] = this.vendorName;
    data['driver_name'] = this.driverName;
    data['recommanded_menu'] = this.recommandedMenu;
    data['isPickup'] = this.isPickup;
    data['isSameDayDelivery'] = this.isSameDayDelivery;
    data['vendor_distance'] = this.vendorDistance;
    data['payment_type'] = this.paymentType;
    data['items_count'] = this.itemsCount;
    data['customer_notification'] = this.customerNotification;
    data['customer_app_id'] = this.customerAppId;
    data['customer_auth_key'] = this.customerAuthKey;
    data['customer_api_key'] = this.customerApiKey;
    data['driver_notification'] = this.driverNotification;
    data['driver_app_id'] = this.driverAppId;
    data['driver_auth_key'] = this.driverAuthKey;
    data['driver_api_key'] = this.driverApiKey;
    data['vendor_notification'] = this.vendorNotification;
    data['vendor_app_id'] = this.vendorAppId;
    data['vendor_auth_key'] = this.vendorAuthKey;
    data['vendor_api_key'] = this.vendorApiKey;
    data['privacy_policy'] = this.privacyPolicy;
    data['terms_and_condition'] = this.termsAndCondition;
    data['help'] = this.help;
    data['about_us'] = this.aboutUs;
    data['site_color'] = this.siteColor;
    data['settlement_days'] = this.settlementDays;
    data['is_driver_allocation'] = this.isDriverAllocation;
    data['is_driver_accept_multipleorder'] = this.isDriverAcceptMultipleOrder;
    data['driver_accept_multiple_order_count'] =
        this.driverAcceptMultipleOrderCount;
    data['driver_assign_km'] = this.driverAssignKm;
    data['driver_vehical_type'] = this.driverVehicalType;
    data['driver_earning'] = this.driverEarning;
    data['twilio_acc_id'] = this.twilioAccId;
    data['verification'] = this.verification;
    data['verification_email'] = this.verificationEmail;
    data['verification_phone'] = this.verificationPhone;
    data['twilio_auth_token'] = this.twilioAuthToken;
    data['twilio_phone_no'] = this.twilioPhoneNo;
    data['radius'] = this.radius;
    data['driver_auto_refrese'] = this.driverAutoRefrese;
    data['mail_mailer'] = this.mailMailer;
    data['mail_host'] = this.mailHost;
    data['mail_port'] = this.mailPort;
    data['mail_username'] = this.mailUsername;
    data['mail_password'] = this.mailPassword;
    data['mail_encryption'] = this.mailEncryption;
    data['mail_from_address'] = this.mailFromAddress;
    data['customer_mail'] = this.customerMail;
    data['vendor_mail'] = this.vendorMail;
    data['driver_mail'] = this.driverMail;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['whitelogo'] = this.whiteLogo;
    data['blacklogo'] = this.blackLogo;
    return data;
  }
}

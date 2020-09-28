
import 'payment_method_models.dart';
//The purpose of including most of these datas here is so if needed, you can store some of these datas in your database after receiving them from stripe. The idea is, the more option, the better.

class LastPaymentErrorModel {
  final String code, message, declineCode, charge, param, type;
  final Map<String, dynamic> lastPaymentErrorPaymentMethod;

  LastPaymentErrorModel(
      {this.code,
      this.message,
      this.declineCode,
      this.param,
      this.type,
      this.charge,
      this.lastPaymentErrorPaymentMethod});

  factory LastPaymentErrorModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return LastPaymentErrorModel(
      code: json['code'],
      message: json['message'],
      declineCode: json[''],
      param: json['param'],
      type: json['type'],
      charge: json['charge'],
      lastPaymentErrorPaymentMethod: json['payment_method'],
    );
  }
  @override
  String toString() {
    return 'code: $code, message: $message, ${lastPaymentErrorPaymentMethod.toString()}';
  }
}

////////////////////////////////Payment Intent/////////////////////////////
///[canceledAt] is the time at which the PaymentIntent was canceled
///[created] is time at which the object was created. Measured in seconds since the
/// Unix epoch

class PaymentIntentModel {
  final String id,
      application,
      status,
      receiptEmail,
      cancellationReason,
      clientSecret,
      paymentMethod,
      currency,
      customer,
      confirmationMethod,
      description,
      invoice,
      onBehalfOf,
      setupFutureUsage,
      statementDescriptorSuffix,
      statementDescriptor,
      transferGroup,
      review;
  final Map<String, dynamic> metadata, transferData, nextAction,charges;
  final int amount,
      amountCapturable,
      applicationFee,
      amountReceived,
      canceledAt,
      created;
  final bool livemode;

  final BillingDetailModel shipping;
  final LastPaymentErrorModel lastPaymentErrorModel;

  PaymentIntentModel({
    this.setupFutureUsage,
    this.statementDescriptorSuffix,
    this.statementDescriptor,
    this.transferGroup,
    this.charges,
    this.transferData,
    this.lastPaymentErrorModel,
    this.id,
    this.nextAction,
    this.currency,
    this.customer,
    this.application,
    this.confirmationMethod,
    this.description,
    this.invoice,
    this.onBehalfOf,
    this.review,
    this.metadata,
    this.amountCapturable,
    this.applicationFee,
    this.amountReceived,
    this.livemode,
    this.status,
    this.paymentMethod,
    this.clientSecret,
    this.amount,
    this.shipping,
    this.created,
    this.receiptEmail,
    this.canceledAt,
    this.cancellationReason,
  });

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return PaymentIntentModel(
        id: json['id'],
        application: json['application'],
        description: json['description'],
        confirmationMethod: json['confirmation_method'],
        invoice: json['invoice'],
        onBehalfOf: json['on_behalf_of'],
        review: json['review'],
        nextAction: json['next_action'],
        metadata: json['metadata'],
        amountCapturable: json['amount_capturable'],
        applicationFee: json['application_fee'],
        amountReceived: json['amount_received'],
        livemode: json['livemode'],
        currency: json['currency'],
        customer: json['customer'],
        status: json['status'],
        clientSecret: json['client_secret'],
        paymentMethod: json['payment_method'],
        amount: json['amount'],
        shipping: BillingDetailModel.fromJson(json['shipping']),
        receiptEmail: json['receipt_email'],
        cancellationReason: json['cancellation_reason:'],
        canceledAt: json['canceled_at'],
        created: json['created'],
        setupFutureUsage: json['setup_future_usage'],
        statementDescriptorSuffix: json['statement_descriptor_suffix'],
        statementDescriptor: json['statement_descriptor'],
        transferGroup: json['transfer_group'],
        charges: json['charges'],
        transferData: json['transfer_data'],
        lastPaymentErrorModel:
            LastPaymentErrorModel.fromJson(json['last_payment_error']));
  }

  @override
  String toString() {
    return 'intentId: $id, application: $application, description:$description, currency: $currency, customer: $customer, confirmationMethod: $confirmationMethod, review: $review, invoice: $invoice, onBehalfOf: $onBehalfOf, paymentMethod: $paymentMethod, nextAction: ${nextAction.toString()}, metadata: ${metadata.toString()}, amountCapturable: $amountCapturable, applicationFee: $applicationFee,  status: $status, clientSecret: $clientSecret, amountReceived: $amountReceived, livemode: $livemode,  amount: $amount, shipping: ${shipping.toString()}, receiptEmail: $receiptEmail, cancellationReason: $cancellationReason, paymentCanceledAt: $canceledAt, paymentCreatedTimestamp: $created, lastPaymentErrorModel: ${lastPaymentErrorModel.toString()}, setupFutureUsage: $setupFutureUsage, statementDescriptorSuffix: $statementDescriptorSuffix, statementDescriptor: $statementDescriptor, transferGroup: $transferGroup, charges: $charges, transferData: ${transferData.toString()}';
  }
}

////////////////////////Setup Intent///////////////////////////////

class SetupIntentModel {
  final String id,
      clientSecret,
      customer,
      description,
      paymentMethod,
      status,
      usage,
      application,
      cancellationReason,
      onBehalfOf,
      singleUseMandate,
      mandate;
  final int created;
  final bool livemode;
  final LastPaymentErrorModel lastPaymentErrorModel;
  final Map<String, dynamic> metadata, nextAction, paymentMethodOptions;
  final List paymentMethodTypes;

  SetupIntentModel({
    this.id,
    this.clientSecret,
    this.customer,
    this.description,
    this.paymentMethod,
    this.status,
    this.usage,
    this.application,
    this.cancellationReason,
    this.onBehalfOf,
    this.singleUseMandate,
    this.mandate,
    this.created,
    this.livemode,
    this.lastPaymentErrorModel,
    this.metadata,
    this.nextAction,
    this.paymentMethodOptions,
    this.paymentMethodTypes,
  });

  factory SetupIntentModel.fromJson(Map<String, dynamic> json) {
    return SetupIntentModel(
      id: json['id'],
      clientSecret: json['client_secret'],
      customer: json['customer'],
      description: json['description'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      usage: json['usage'],
      application: json['application'],
      cancellationReason: json['cancellation_reason'],
      onBehalfOf: json['on_behalf_of'],
      singleUseMandate: json['single_use_mandate'],
      mandate: json['mandate'],
      created: json['created'],
      livemode: json['livemode'],
      lastPaymentErrorModel:
          LastPaymentErrorModel.fromJson(json['last_payment_error']),
      metadata: json['metadata'],
      nextAction: json['next_action'],
      paymentMethodOptions: json['payment_method_options'],
      paymentMethodTypes: json['payment_method_types'],
    );
  }

  @override
  String toString() {
    return 'intentId: $id, application: $application, description:$description,  customer: $customer, onBehalfOf: $onBehalfOf, paymentMethod: $paymentMethod, nextAction: ${nextAction.toString()}, metadata: ${metadata.toString()}, status: $status, clientSecret: $clientSecret, livemode: $livemode, cancellationReason: $cancellationReason, paymentCreatedTimestamp: $created, lastPaymentErrorModel: ${lastPaymentErrorModel.toString()}, paymentMethodTypes: ${paymentMethodTypes}, paymentMethodOptions: ${paymentMethodOptions.toString()}, nextAction: ${nextAction.toString()}, mandate: $mandate, singleUseMandate: $singleUseMandate, usage: $usage';
  }
}

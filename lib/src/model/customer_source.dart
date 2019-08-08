import 'card.dart';
import 'source.dart';
import 'source_card_data.dart';
import 'stripe_json_utils.dart';

import 'stripe_json_model.dart';
import 'stripe_payment_source.dart';

class CustomerSource extends StripeJsonModel implements StripePaymentSource {
  StripePaymentSource stripePaymentSource;

  factory CustomerSource.fromJson(Map<String, dynamic> json) {
    String objectString = optString(json, "object");
    StripePaymentSource sourceObject;
    if (StripeCard.VALUE_CARD == objectString) {
      sourceObject = new StripeCard.fromJson(json.cast<String, dynamic>());
    } else if (Source.VALUE_SOURCE == objectString) {
      sourceObject = new Source.fromJson(json.cast<String, dynamic>());
    }

    if (sourceObject == null) {
      return null;
    } else {
      return new CustomerSource._internal(sourceObject);
    }
  }

  CustomerSource._internal(this.stripePaymentSource);

  @override
  String get id => stripePaymentSource == null ? null : stripePaymentSource.id;

  Source asSource() {
    if (stripePaymentSource is Source) {
      return stripePaymentSource;
    }
    return null;
  }

  String getTokenizationMethod() {
    Source paymentAsSource = asSource();
    StripeCard paymentAsCard = asCard();
    if (paymentAsSource != null && paymentAsSource.type == Source.CARD) {
      SourceCardData cardData =
          paymentAsSource.sourceTypeModel as SourceCardData;
      if (cardData != null) {
        return cardData.tokenizationMethod;
      }
    } else if (paymentAsCard != null) {
      return paymentAsCard.tokenizationMethod;
    }
    return null;
  }

  StripeCard asCard() {
    if (stripePaymentSource is StripeCard) {
      return stripePaymentSource;
    }
    return null;
  }

  String getSourceType() {
    if (stripePaymentSource is StripeCard) {
      return Source.CARD;
    } else if (stripePaymentSource is Source) {
      return (stripePaymentSource as Source).type;
    } else {
      return Source.UNKNOWN;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    if (stripePaymentSource is Source) {
      return (stripePaymentSource as Source).toMap();
    } else if (stripePaymentSource is StripeCard) {
      return (stripePaymentSource as StripeCard).toMap();
    }
    return new Map();
  }
}

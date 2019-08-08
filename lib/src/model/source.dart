import 'source_code_verification.dart';
import 'source_owner.dart';
import 'source_receiver.dart';
import 'source_redirect.dart';
import 'stripe_json_model.dart';
import 'stripe_json_utils.dart';
import 'stripe_payment_source.dart';
import 'stripe_source_type_model.dart';
import 'package:stripe_api/src/stripe_network_utils.dart';

class Source extends StripeJsonModel implements StripePaymentSource {
  static const String VALUE_SOURCE = "source";

  static const String ALIPAY = "alipay";
  static const String CARD = "card";
  static const String THREE_D_SECURE = "three_d_secure";
  static const String GIROPAY = "giropay";
  static const String SEPA_DEBIT = "sepa_debit";
  static const String IDEAL = "ideal";
  static const String SOFORT = "sofort";
  static const String BANCONTACT = "bancontact";
  static const String P24 = "p24";
  static const String EPS = "eps";
  static const String MULTIBANCO = "multibanco";
  static const String UNKNOWN = "unknown";

  static final Set<String> MODELED_TYPES = new Set()..add(CARD)..add(SEPA_DEBIT);

  static const String PENDING = "pending";
  static const String CHARGEABLE = "chargeable";
  static const String CONSUMED = "consumed";
  static const String CANCELED = "canceled";
  static const String FAILED = "failed";

  static const String REUSABLE = "reusable";
  static const String SINGLE_USE = "single_use";

  static const String REDIRECT = "redirect";
  static const String RECEIVER = "receiver";
  static const String CODE_VERIFICATION = "code_verification";
  static const String NONE = "none";

  static const String EURO = "eur";
  static const String USD = "usd";

  static const String FIELD_ID = "id";
  static const String FIELD_OBJECT = "object";
  static const String FIELD_AMOUNT = "amount";
  static const String FIELD_CLIENT_SECRET = "client_secret";
  static const String FIELD_CODE_VERIFICATION = "code_verification";
  static const String FIELD_CREATED = "created";
  static const String FIELD_CURRENCY = "currency";
  static const String FIELD_FLOW = "flow";
  static const String FIELD_LIVEMODE = "livemode";
  static const String FIELD_METADATA = "metadata";
  static const String FIELD_OWNER = "owner";
  static const String FIELD_RECEIVER = "receiver";
  static const String FIELD_REDIRECT = "redirect";
  static const String FIELD_STATUS = "status";
  static const String FIELD_TYPE = "type";
  static const String FIELD_USAGE = "usage";

  @override
  String id;
  int amount;
  String clientSecret;
  SourceCodeVerification codeVerification;
  int created;
  String currency;
  String typeRaw;
  String flow;
  bool liveMode;
  Map<String, String> metaData;
  SourceOwner owner;
  SourceReceiver receiver;
  SourceRedirect redirect;
  String status;
  Map<String, Object> sourceTypeData;
  StripeSourceTypeModel sourceTypeModel;
  String type;
  String usage;

  Source({
    this.id,
    this.amount,
    this.clientSecret,
    this.codeVerification,
    this.created,
    this.currency,
    this.flow,
    this.liveMode,
    this.metaData,
    this.owner,
    this.receiver,
    this.redirect,
    this.status,
    this.sourceTypeData,
    this.sourceTypeModel,
    this.type,
    this.typeRaw,
    this.usage,
  });

  Source.fromJson(Map<String, dynamic> json) {
    id = optString(json, FIELD_ID);
    amount = optInteger(json, FIELD_AMOUNT);
    clientSecret = optString(json, FIELD_CLIENT_SECRET);
    final codeVerf = json[FIELD_CODE_VERIFICATION];
    if (codeVerf != null) {
      codeVerification = new SourceCodeVerification.fromJson(codeVerf.cast<String, dynamic>());
    }

    created = optInteger(json, FIELD_CREATED); // TODO:: maybe we need to convert it into long
    currency = optString(json, FIELD_CURRENCY);
    flow = asSourceFlow(optString(json, FIELD_FLOW));
    liveMode = optBoolean(json, FIELD_LIVEMODE);

    var metaDataObj = json[FIELD_METADATA];
    if (metaDataObj != null) {
      metaData = metaDataObj.cast<String, String>();
    } else {
      metaData = new Map();
    }

    final ownerObject = json[FIELD_OWNER];
    if (ownerObject != null) {
      owner = new SourceOwner.fromJson(ownerObject.cast<String, dynamic>());
    }

    var receiverObject = json[FIELD_RECEIVER];
    if (receiverObject != null) {
      receiver = new SourceReceiver.fromJson(receiverObject.cast<String, dynamic>());
    }

    var redirectObject = json[FIELD_REDIRECT];
    if (redirectObject != null) {
      redirect = new SourceRedirect.fromJson(redirectObject.cast<String, dynamic>());
    }

    status = asSourceStatus(optString(json, FIELD_STATUS));

    String typeRaw = optString(json, FIELD_TYPE);
    if (typeRaw == null) {
      // We can't allow this type to be null, as we are using it for a key
      // on the JSON object later.
      typeRaw = UNKNOWN;
    }

    type = asSourceType(typeRaw);
    if (type == null) {
      type = UNKNOWN;
    }

    // Until we have models for all types, keep the original hash and the
    // model object. The customType variable can be any field, and is not altered by
    // trying to force it to be a type that we know of.
    /*
    sourceTypeData = json[typeRaw];
    if (MODELED_TYPES.contains(typeRaw)) {
      sourceTypeModel = new StripeSourceTypeModel(json[typeRaw]);
    }
    */

    usage = asUsage(optString(json, FIELD_USAGE));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, Object> hashMap = new Map();
    hashMap[FIELD_ID] = id;
    hashMap[FIELD_AMOUNT] = amount;
    hashMap[FIELD_CLIENT_SECRET] = clientSecret;

    StripeJsonModel.putStripeJsonModelMapIfNotNull(
        hashMap, FIELD_CODE_VERIFICATION, codeVerification);

    hashMap[FIELD_CREATED] = created;
    hashMap[FIELD_CURRENCY] = currency;
    hashMap[FIELD_FLOW] = flow;
    hashMap[FIELD_LIVEMODE] = liveMode;
    hashMap[FIELD_METADATA] = metaData;

    StripeJsonModel.putStripeJsonModelMapIfNotNull(hashMap, FIELD_OWNER, owner);
    StripeJsonModel.putStripeJsonModelMapIfNotNull(hashMap, FIELD_RECEIVER, receiver);
    StripeJsonModel.putStripeJsonModelMapIfNotNull(hashMap, FIELD_REDIRECT, redirect);

    hashMap[typeRaw] = sourceTypeData;

    hashMap[FIELD_STATUS] = status;
    hashMap[FIELD_TYPE] = typeRaw;
    hashMap[FIELD_USAGE] = usage;
    removeNullAndEmptyParams(hashMap);
    return hashMap;
  }

  static String asSourceStatus(String sourceStatus) {
    if (PENDING == sourceStatus) {
      return PENDING;
    } else if (CHARGEABLE == sourceStatus) {
      return CHARGEABLE;
    } else if (CONSUMED == sourceStatus) {
      return CONSUMED;
    } else if (CANCELED == sourceStatus) {
      return CANCELED;
    } else if (FAILED == sourceStatus) {
      return FAILED;
    }
    return null;
  }

  static String asSourceType(String sourceType) {
    if (CARD == sourceType) {
      return CARD;
    } else if (THREE_D_SECURE == sourceType) {
      return THREE_D_SECURE;
    } else if (GIROPAY == sourceType) {
      return GIROPAY;
    } else if (SEPA_DEBIT == sourceType) {
      return SEPA_DEBIT;
    } else if (IDEAL == sourceType) {
      return IDEAL;
    } else if (SOFORT == sourceType) {
      return SOFORT;
    } else if (BANCONTACT == sourceType) {
      return BANCONTACT;
    } else if (ALIPAY == sourceType) {
      return ALIPAY;
    } else if (P24 == sourceType) {
      return P24;
    } else if (UNKNOWN == sourceType) {
      return UNKNOWN;
    }

    return null;
  }

  static String asUsage(String usage) {
    if (REUSABLE == usage) {
      return REUSABLE;
    } else if (SINGLE_USE == usage) {
      return SINGLE_USE;
    }
    return null;
  }

  static String asSourceFlow(String sourceFlow) {
    if (REDIRECT == sourceFlow) {
      return REDIRECT;
    } else if (RECEIVER == sourceFlow) {
      return RECEIVER;
    } else if (CODE_VERIFICATION == sourceFlow) {
      return CODE_VERIFICATION;
    } else if (NONE == sourceFlow) {
      return NONE;
    }
    return null;
  }
}

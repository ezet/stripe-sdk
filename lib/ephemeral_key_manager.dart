import 'dart:async';
import 'dart:convert' show json;

import 'model/stripe_json_model.dart';
import 'model/stripe_json_utils.dart';
import 'stripe_api_handler.dart';
import 'stripe_error.dart';

///
///
///
typedef Future<String> EphemeralKeyProvider(String apiVersion);

///
///
///
class EphemeralKey extends StripeJsonModel {
  static const String FIELD_CREATED = "created";
  static const String FIELD_EXPIRES = "expires";
  static const String FIELD_SECRET = "secret";
  static const String FIELD_LIVEMODE = "livemode";
  static const String FIELD_OBJECT = "object";
  static const String FIELD_ID = "id";
  static const String FIELD_ASSOCIATED_OBJECTS = "associated_objects";
  static const String FIELD_TYPE = "type";

  static const String NULL = "null";

  String _id;
  int _created;
  int _expires;
  bool _liveMode;
  String _customerId;
  String _object;
  String _secret;
  String _type;
  DateTime _createdAt;
  DateTime _expiresAt;

  EphemeralKey.fromJson(Map<String, dynamic> json) {
    _id = optString(json, FIELD_ID);
    _created = optInteger(json, FIELD_CREATED);
    _expires = optInteger(json, FIELD_EXPIRES);
    _liveMode = optBoolean(json, FIELD_LIVEMODE);
    _customerId = json[FIELD_ASSOCIATED_OBJECTS][0][FIELD_ID];
    _type = json[FIELD_ASSOCIATED_OBJECTS][0][FIELD_TYPE];
    _object = optString(json, FIELD_OBJECT);
    _secret = optString(json, FIELD_SECRET);
    _createdAt = new DateTime.fromMillisecondsSinceEpoch(_created);
    _expiresAt = new DateTime.fromMillisecondsSinceEpoch(_expires);
  }

  String get id => _id;

  int get created => _created;

  int get expires => _expires;

  String get customerId => _customerId;

  bool get liveMode => _liveMode;

  String get object => _object;

  String get secret => _secret;

  String get type => _type;

  DateTime get createdAt => _createdAt;

  DateTime get expiresAt => _expiresAt;

  @override
  Map<String, dynamic> toMap() {
    return {
      FIELD_CREATED: _created,
      FIELD_EXPIRES: _expires,
      FIELD_OBJECT: _object,
      FIELD_ID: _id,
      FIELD_SECRET: _secret,
      FIELD_LIVEMODE: _liveMode,
      FIELD_ASSOCIATED_OBJECTS: [
        {FIELD_TYPE: _type, FIELD_ID: _customerId}
      ]
    };
  }
}

///
///
///
class EphemeralKeyManager {
  EphemeralKey _ephemeralKey;
  final EphemeralKeyProvider ephemeralKeyProvider;
  final int timeBufferInSeconds;

  EphemeralKeyManager(this.ephemeralKeyProvider, this.timeBufferInSeconds);

  ///
  ///
  ///
  Future<EphemeralKey> retrieveEphemeralKey() async {
    if (_shouldRefreshKey()) {
      String key;
      try {
        key = await ephemeralKeyProvider(API_VERSION);
      } catch (error) {
        final e = new StripeAPIError(null, {
          StripeAPIError.FIELD_MESSAGE:
              "Failed to retrive ephemeralKey from server",
        });
        throw new StripeAPIException(e);
      }

      try {
        Map<String, dynamic> decodedKey = json.decode(key);
        _ephemeralKey = new EphemeralKey.fromJson(decodedKey);
      } catch (error) {
        final e = new StripeAPIError(null, {
          StripeAPIError.FIELD_MESSAGE:
              "Failed to parse Ephemeral Key, Please return the response as it is as you recieved from stripe server",
        });
        throw new StripeAPIException(e);
      }

      return _ephemeralKey;
    } else {
      return _ephemeralKey;
    }
  }

  ///
  ///
  ///
  bool _shouldRefreshKey() {
    if (_ephemeralKey == null) {
      return true;
    }

    DateTime now = DateTime.now();
    final diff = _ephemeralKey.expiresAt.difference(now).abs();
    return diff.inSeconds < timeBufferInSeconds;
  }
}

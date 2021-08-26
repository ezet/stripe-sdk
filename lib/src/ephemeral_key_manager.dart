

import 'dart:async';
import 'dart:convert' show json;
import 'dart:developer';

import 'stripe_api_handler.dart';
import 'stripe_error.dart';
import 'util/stripe_json_utils.dart';

/// Function that takes a apiVersion and returns a Stripe ephemeral key response
typedef EphemeralKeyProvider = Future<String> Function(String apiVersion);

/// Represents a Stripe Ephemeral Key
class EphemeralKey {
  static const String fieldCreated = 'created';
  static const String fieldExpires = 'expires';
  static const String fieldSecret = 'secret';
  static const String fieldLiveMode = 'livemode';
  static const String fieldObject = 'object';
  static const String fieldId = 'id';
  static const String fieldAssociatedObjects = 'associated_objects';
  static const String fieldType = 'type';

  static const String fieldNull = 'null';

  late String _id;
  late int _created;
  late int _expires;
  late bool _liveMode;
  late String _customerId;
  late String _object;
  late String _secret;
  late String _type;
  late DateTime _createdAt;
  late DateTime _expiresAt;

  EphemeralKey.fromJson(Map<String, dynamic> json) {
    // TODO might throw an error if ephemeralKey doesn't provide all fields.
    _id = optString(json, fieldId)!;
    _created = optInteger(json, fieldCreated)!;
    _expires = optInteger(json, fieldExpires)!;
    _liveMode = optBoolean(json, fieldLiveMode)!;
    _customerId = json[fieldAssociatedObjects][0][fieldId];
    _type = json[fieldAssociatedObjects][0][fieldType];
    _object = optString(json, fieldObject)!;
    _secret = optString(json, fieldSecret)!;
    _createdAt = DateTime.fromMillisecondsSinceEpoch(_created * 1000);
    _expiresAt = DateTime.fromMillisecondsSinceEpoch(_expires * 1000);
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
}

class EphemeralKeyManager {
  EphemeralKey? _ephemeralKey;
  final EphemeralKeyProvider ephemeralKeyProvider;
  final int timeBufferInSeconds;

  EphemeralKeyManager(this.ephemeralKeyProvider, this.timeBufferInSeconds);

  /// Retrieve a ephemeral key.
  /// Will fetch a new one using [EphemeralKeyProvider] if required.
  Future<EphemeralKey> retrieveEphemeralKey() async {
    if (_shouldRefreshKey()) {
      String key;
      try {
        key = await ephemeralKeyProvider(defaultApiVersion);
      } catch (error) {
        log(error.toString());
        rethrow;
      }

      try {
        Map<String, dynamic> decodedKey = json.decode(key);
        _ephemeralKey = EphemeralKey.fromJson(decodedKey);
      } catch (error) {
        log(error.toString());
        final e = StripeApiError(null, {
          StripeApiError.fieldMessage:
              'Failed to parse Ephemeral Key, Please return the response as it is as you received from stripe server',
        });
        throw StripeApiException(e);
      }

      return _ephemeralKey!;
    } else {
      return _ephemeralKey!;
    }
  }

  bool _shouldRefreshKey() {
    if (_ephemeralKey == null) {
      return true;
    }

    final now = DateTime.now();
    final diff = _ephemeralKey!.expiresAt.difference(now);
    return diff.inSeconds < timeBufferInSeconds;
  }
}

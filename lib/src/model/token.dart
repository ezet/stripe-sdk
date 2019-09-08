import 'stripe_payment_source.dart';
import 'stripe_json_utils.dart';
import 'card.dart';

class Token implements StripePaymentSource {
  static const String TYPE_CARD = "card";
  static const String TYPE_BANK_ACCOUNT = "bank_account";
  static const String TYPE_PII = "pii";
  static const String TYPE_ACCOUNT = "account";

  // The key for these object fields is identical to their retrieved values
  // from the Type field.
  static const String FIELD_BANK_ACCOUNT = Token.TYPE_BANK_ACCOUNT;
  static const String FIELD_CARD = Token.TYPE_CARD;
  static const String FIELD_CREATED = "created";
  static const String FIELD_ID = "id";
  static const String FIELD_LIVEMODE = "livemode";

  static const String FIELD_TYPE = "type";
  static const String FIELD_USED = "used";

  @override
  final String id;

  final String type;
  final DateTime created;
  final bool liveMode;
  final bool used;

  //final BankAccount bankAccount;
  final StripeCard card;

  Token._internal(
    this.id,
    this.liveMode,
    this.created,
    this.type,
    this.used, {
    this.card,
  });

  factory Token(Map<String, dynamic> json) {
    String tokenId = optString(json, FIELD_ID);
    int createdTimeStamp = optInteger(json, FIELD_CREATED);
    bool liveMode = optBoolean(json, FIELD_LIVEMODE);
    String tokenType = asTokenType(optString(json, FIELD_TYPE));
    bool used = optBoolean(json, FIELD_USED);

    if (tokenId == null || createdTimeStamp == null || liveMode == null) {
      return null;
    }
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(2000);

    Token token;
    if (Token.TYPE_BANK_ACCOUNT == tokenType) {
      final bankAccountObject = json[FIELD_BANK_ACCOUNT];
      if (bankAccountObject == null) {
        return null;
      }
      //BankAccount bankAccount = BankAccount.fromJson(bankAccountObject);
      //token = new Token(tokenId, liveMode, date, used, bankAccount);

    } else if (Token.TYPE_CARD == tokenType) {
      final cardObject = json[FIELD_CARD];
      if (cardObject == null) {
        return null;
      }
      StripeCard card = StripeCard.fromJson(cardObject.cast<String, dynamic>());
      token = new Token._internal(tokenId, liveMode, date, tokenType, used,
          card: card);
    } else if (Token.TYPE_PII == tokenType || Token.TYPE_ACCOUNT == tokenType) {
      token = new Token._internal(tokenId, liveMode, date, tokenType, used);
    }
    return token;
  }

  /// Converts an unchecked String value to a {@link TokenType} or {@code null}.
  ///
  /// @param possibleTokenType a String that might match a {@link TokenType} or be empty
  /// @return {@code null} if the input is blank or otherwise does not match a {@link TokenType},
  /// else the appropriate {@link TokenType}.
  static String asTokenType(String possibleTokenType) {
    if (possibleTokenType == null || possibleTokenType.trim().isEmpty) {
      return null;
    }

    if (Token.TYPE_CARD == possibleTokenType) {
      return Token.TYPE_CARD;
    } else if (Token.TYPE_BANK_ACCOUNT == possibleTokenType) {
      return Token.TYPE_BANK_ACCOUNT;
    } else if (Token.TYPE_PII == possibleTokenType) {
      return Token.TYPE_PII;
    } else if (Token.TYPE_ACCOUNT == possibleTokenType) {
      return Token.TYPE_ACCOUNT;
    }

    return null;
  }
}

class SIWEUtils {
  static String generateNonce() {
    return 'randomNonce123';
  }

  static String formatMessage(dynamic args) {
    return 'Formatted SIWE message';
  }

  static String getChainIdFromMessage(String message) {
    return '1';
  }

  static String getAddressFromMessage(String message) {
    return '0x0000000000000000000000000000000000000000';
  }

  static Future<bool> verifySignature(
      String address, String message, dynamic cacaoSignature, String chainId, String projectId) async {
    // Add your signature verification logic here.
    return true;
  }
}

class SIWEMessageArgs {
  final String domain;
  final String uri;
  final String statement;
  final List<String> methods;

  SIWEMessageArgs({
    required this.domain,
    required this.uri,
    required this.statement,
    required this.methods,
  });
}

class SIWECreateMessageArgs {
  // Define properties for SIWE message creation.
}

class SIWEVerifyMessageArgs {
  final String message;
  final String signature;
  final dynamic cacao;

  SIWEVerifyMessageArgs({
    required this.message,
    required this.signature,
    this.cacao,
  });
}

class SIWESession {
  final String address;
  final List<String> chains;

  SIWESession({required this.address, required this.chains});
}

class CacaoSignature {
  static const String EIP191 = 'eip191';
  final String t;
  final String s;

  CacaoSignature({required this.t, required this.s});
}
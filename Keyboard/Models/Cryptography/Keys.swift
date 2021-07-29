//
//  Keys.swift
//  Seal
//
//  Created by tz on 6/15/21.
//

import Foundation
import CryptoKit

final class EncryptionKeys {
  static let `default` = EncryptionKeys()

  // Internal get vars for public keys & computed var for symmetric key digests
  private(set) var signingPublicKey: Curve25519.Signing.PublicKey!
  private(set) var encryptionPublicKey: Curve25519.KeyAgreement.PublicKey!
  var symmetricKeyDigests: [String] {
    return Array(symmetricKeys.keys)
  }

  // Private vars for secret & symmetric keys
  private var signingSecretKey: Curve25519.Signing.PrivateKey!
  private var encryptionSecretKey: Curve25519.KeyAgreement.PrivateKey!
  private var symmetricKeys: [String:SymmetricKey]!

  private let keyChain = GenericPasswordStore()

  // TODO: placeholder. use random salt for each msg
  private let protocolSalt = "CryptoKit Playgrounds Putting It Together".data(using: .utf8)!

  private init() {
    // Try reading keys from KeyChain. If no key exists, generate new keys and save them.
    // Signing Secret Key
    var account = KeyChainAccount.signingSecretKey.rawValue
    if let storedKey: Curve25519.Signing.PrivateKey =
        try? keyChain.readKey(account: account) {
      signingSecretKey = storedKey
      NSLog("\(account) restored from KeyChain.")
    } else {
      signingSecretKey = Curve25519.Signing.PrivateKey()
      try! keyChain.storeKey(signingSecretKey, account: account)
      NSLog("\(account) created and saved to KeyChain.")
    }
    // Encryption Secret Key
    account = KeyChainAccount.encryptionSecretKey.rawValue
    if let storedKey: Curve25519.KeyAgreement.PrivateKey =
        try? keyChain.readKey(account: account) {
      encryptionSecretKey = storedKey
      NSLog("\(account) restored from KeyChain.")
    } else {
      encryptionSecretKey = Curve25519.KeyAgreement.PrivateKey()
      try! keyChain.storeKey(encryptionSecretKey, account: account)
      NSLog("\(account) created and saved to KeyChain.")
    }

    // Symmetric Keys
    account = KeyChainAccount.symmetricKeys.rawValue
    if let storedKeys: [SymmetricKey] = try? keyChain.readKeys(account: account) {
      symmetricKeys = Dictionary(uniqueKeysWithValues: zip(
        storedKeys.compactMap {$0.digest},
        storedKeys
      ))
      NSLog("\(account) restored from KeyChain.")
    } else {
      let newSymmetricKey = SymmetricKey(size: .bits256)
      symmetricKeys = [:]
      symmetricKeys[newSymmetricKey.digest] = newSymmetricKey
      let service = newSymmetricKey.digest
      try! keyChain.storeKey(newSymmetricKey, account: account, service: service)
      NSLog("\(account) created and saved to KeyChain.")
    }

    signingPublicKey = signingSecretKey.publicKey
    encryptionPublicKey = encryptionSecretKey.publicKey

    NSLog("signingPublicKey: \(asString(signingPublicKey.rawRepresentation))")
    NSLog("encryptionPublicKey: \(asString(encryptionPublicKey.rawRepresentation))")
    for key in symmetricKeyDigests {
      NSLog("symmetric key digest: \(key)")
    }
    NSLog("Keys instance initialized.")
  }

  // MARK: - Asymmetric key exchange (symmetric key generation) methods

  /// Generates an ephemeral key agreement key and performs key agreement to  derive the symmetric encryption key and
  ///    save the symmetric encryption key to keychain.
  /// Modified from: developer.apple.com/documentation/cryptokit/performing_common_cryptographic_operations
  /// - Parameters:
  ///   - theirEncryptionPublicKeyString: Encryption public key of the recipient.
  /// - Throws:
  ///   - parsingError if input public key string cannot be converted into a PublicKey object
  ///   - Errors from cryptokit operation failures.
  ///   - Errors from GenericPasswordStore.update operation failures.
  /// - Returns:
  ///   - Public key of the ephemeral secret key used for generating the symmetric key.
  ///   - Signature signed by signing secret key.
  ///   - Public key of the signing secret key.
  func ECDHKeyExchange(with theirEncryptionPublicKeyString: String) throws ->(
    ephemeralPublicKeyString: String,
    signatureString: String,
    signingPublicKeyString: String
  ) {
    // Convert string back to public key type
    guard let theirEncryptionPublicKeyData = asData(theirEncryptionPublicKeyString),
          let theirEncryptionPublicKey = try? Curve25519.KeyAgreement.PublicKey(
            rawRepresentation: theirEncryptionPublicKeyData
    ) else {
      throw DecryptionErrors.parsingError
    }

    let ephemeralSecretKey = Curve25519.KeyAgreement.PrivateKey()
    let ephemeralPublicKey = ephemeralSecretKey.publicKey

    let sharedSecret = try ephemeralSecretKey.sharedSecretFromKeyAgreement(
      with: theirEncryptionPublicKey
    )

    let newSymmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: protocolSalt,
      sharedInfo: ephemeralPublicKey.rawRepresentation +
        theirEncryptionPublicKey.rawRepresentation +
        signingPublicKey.rawRepresentation,
      outputByteCount: 32
    )

    // Save new symmetric key to memory & keychain
    symmetricKeys[newSymmetricKey.digest] = newSymmetricKey
    try keyChain.storeKey(newSymmetricKey,
      account: KeyChainAccount.symmetricKeys.rawValue,
      service: newSymmetricKey.digest
    )

    NSLog("New symmetricKey saved to KeyChain. Digest: \(newSymmetricKey.digest)")

    let signature = try signingSecretKey.signature(
      for: ephemeralPublicKey.rawRepresentation + theirEncryptionPublicKey.rawRepresentation
    )

    return (
      asString(ephemeralPublicKey.rawRepresentation),
      asString(signature),
      asString(signingPublicKey.rawRepresentation)
    )
  }

  /// Verifiy the response of the key exchange by checking the signature and finish the key exchange by computing the
  ///   symmetric key based on the ephmeral public key sent by the sender.
  /// Modified from: developer.apple.com/documentation/cryptokit/performing_common_cryptographic_operations
  /// - Parameters:
  ///   - ephemeralPublicKeyString: The public key of the key pair used for generating the symmetric key.
  ///   - signatureString: Signature of the sender on the ephermeral public key + our encryption public key
  ///   - theirSigningPublicKeyString: Signing public key of the sender
  /// - Throws:
  ///   - .parsingError fi unable to convert input key strings  into  PublicKey objects
  ///   - authenticationError if signature unmatch
  ///   - Other errors from CryptoKit operation failures.
  func verifyECDHKeyExchangeResponse(
      ephemeralPublicKeyString: String,
      signatureString: String,
      theirSigningPublicKeyString: String
  ) throws {
    // Convert input strings into corresponding data types
    guard let ephemeralPublicKeyData = asData(ephemeralPublicKeyString),
          let signature = asData(signatureString),
          let theirSigningPublicKeyData = asData(theirSigningPublicKeyString),
          let theirSigningPublicKey = try? Curve25519.Signing.PublicKey(
            rawRepresentation: theirSigningPublicKeyData
    ) else {
      throw DecryptionErrors.parsingError
    }

    // Verify signature
    let data = ephemeralPublicKeyData + encryptionPublicKey.rawRepresentation
    guard theirSigningPublicKey.isValidSignature(signature, for: data) else {
      throw DecryptionErrors.authenticationError
    }

    guard let ephemeralPublicKey = try? Curve25519.KeyAgreement.PublicKey(
      rawRepresentation: ephemeralPublicKeyData
    ) else {
      throw DecryptionErrors.parsingError
    }

    let sharedSecret = try encryptionSecretKey.sharedSecretFromKeyAgreement(
      with: ephemeralPublicKey
    )
    let receivedSymmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: protocolSalt,
      sharedInfo: ephemeralPublicKey.rawRepresentation +
        encryptionPublicKey.rawRepresentation +
        theirSigningPublicKey.rawRepresentation,
      outputByteCount: 32
    )

    // If received symmetric key already exists, give error
    if let _ = symmetricKeys[receivedSymmetricKey.digest] {
      NSLog("""
        Following symmetric key received already exists. Digest: \(receivedSymmetricKey.digest)
        """)
      throw DecryptionErrors.newSymmetricKeyAlreadyExistsError
    } else {
      // Save new symmetric key to memory & keychain
      symmetricKeys[receivedSymmetricKey.digest] = receivedSymmetricKey
      try keyChain.storeKey(receivedSymmetricKey,
        account: KeyChainAccount.symmetricKeys.rawValue,
        service: receivedSymmetricKey.digest
      )
      NSLog("New symmetricKey saved to KeyChain. Digest: \(receivedSymmetricKey.digest)")
    }
  }

  // MARK: - Symmetric encryption and decryption methods

  /// Encrypt via symmetric encryption with current symmetric key.
  /// - Parameters:
  ///   - msg: Message to encrypt with current symmetric key
  ///   - with: Digest of the symmetric key to use to encrypt.
  /// - Throws:
  ///   - Errors from CryptoKit operation failures.
  /// - Returns:
  ///   - ciphertextString: Ciphertext of the encrypted message.
  ///   - signatureString: Signature signed with signing secret key.
  ///   - signingPublicKeyString: Public key of the secret key used for signing the signature.
  func encrypt(_ msg: String, with digest: String) throws -> (
    ciphertextString: String,
    signatureString: String,
    signingPublicKeyString: String
  ){
    let data = msg.data(using: .utf8)!

    guard let symmetricKey = symmetricKeys[digest] else {
      throw DecryptionErrors.nonexistentSymmetricDigestError
    }

    let ciphertext = try ChaChaPoly.seal(data, using: symmetricKey).combined
    let signature = try signingSecretKey.signature(for: ciphertext)

    return (
      asString(ciphertext), asString(signature), asString(signingPublicKey.rawRepresentation)
    )
  }

  /// Decrypt via symmetric encryption with current symmetric key.
  /// - Parameters:
  ///   - sealedMessage:
  ///       - ciphertextString: The ciphertext received.
  ///       - signatureString: Signature along the message.
  ///   - theirSigningPublicKeyString: Public key of the secret key used for signing the signature.
  ///   - with: Digest of the symmetric key to use to decrypt.
  /// - Throws:
  ///   - .parsingError if unable to convert input key strings into PublicKey objects
  ///   - authenticationError if unable to parse or match signature.
  ///   - Other errors from CryptoKit operation failures.
  /// - Returns: Decrypted message.
  func decrypt(
    _ sealedMessage: (ciphertextString: String, signatureString: String),
    from theirSigningPublicKeyString: String,
    with digest: String
  ) throws -> String {

    guard let ciphertext = asData(sealedMessage.ciphertextString),
          let signature = asData(sealedMessage.signatureString),
          let theirSigningPublicKeyData = asData(theirSigningPublicKeyString),
          let theirSigningPublicKey = try? Curve25519.Signing.PublicKey(
            rawRepresentation: theirSigningPublicKeyData
    ) else {
      throw DecryptionErrors.parsingError
    }

    guard theirSigningPublicKey.isValidSignature(signature, for: ciphertext) else {
      throw DecryptionErrors.authenticationError
    }

    guard let symmetricKey = symmetricKeys[digest] else {
      throw DecryptionErrors.nonexistentSymmetricDigestError
    }

    let sealedBox = try ChaChaPoly.SealedBox(combined: ciphertext)
    let msg = try ChaChaPoly.open(sealedBox, using: symmetricKey)

    return String(decoding: msg, as: UTF8.self)
  }


  /// Delete symmetric key with digest @with from keychain.
  func deleteSymmetricKey(with digest: String) throws {
    let account = KeyChainAccount.symmetricKeys.rawValue
    try keyChain.deleteKey(account: account, service: digest)
  }
}

enum DecryptionErrors: Error {
  case authenticationError
  case parsingError
  case nonexistentSymmetricDigestError
  case newSymmetricKeyAlreadyExistsError
}

enum KeyChainAccount: String {
  case encryptionSecretKey
  case signingSecretKey
  case symmetricKeys
}

extension SymmetricKey {
  var digest: String {
    SHA256.hash(data: self.rawRepresentation).string
  }
}

extension SHA256.Digest {
  var string: String {
    return self.compactMap { String(format: "%02x", $0) }.joined()
  }
}

func asData(_ str: String) -> Data? {
  return Data(base64Encoded: str)
}

func asString(_ data: Data) -> String {
  return data.withUnsafeBytes { Data(Array($0)).base64EncodedString()}
}

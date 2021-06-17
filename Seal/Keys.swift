//
//  Keys.swift
//  Seal
//
//  Created by tz on 6/15/21.
//

import Foundation
import CryptoKit

final class Keys {
  private var signingSecretKey: Curve25519.Signing.PrivateKey!
  var signingPublicKey: Curve25519.Signing.PublicKey!
  private var encryptionSecretKey: Curve25519.KeyAgreement.PrivateKey!
  var encryptionPublicKey: Curve25519.KeyAgreement.PublicKey!
  private var symmetricKey: SymmetricKey!

  // TODO: placeholder. use random salt for each msg
  let protocolSalt = "CryptoKit Playgrounds Putting It Together".data(using: .utf8)!

  init() {
    // TODO: currently private keys are always different from each initialization.
    // Might need to  give the option to load locally.
    // TODO: Keys are using constant placehodlers.
    signingSecretKey = try! Curve25519.Signing.PrivateKey(
      rawRepresentation: asData("mHx2QASPQLvKmZPJcmHgBi3PW259a1nwRMIt0i2qEnA=")
    )
    signingPublicKey = signingSecretKey.publicKey

    encryptionSecretKey = try! Curve25519.KeyAgreement.PrivateKey(
      rawRepresentation: asData("qtuI5HeGBBxelfBT7aqBGKqncDIfmwGS30pbILNy7IE=")
    )
    encryptionPublicKey = encryptionSecretKey.publicKey
    symmetricKey = SymmetricKey(
      data: Data(base64Encoded: "prA6/h5XuHvM3EN5NN63DjP2kuGHgHou1MU4QxoAWlc=")!
    )
    print("Keys instance initialized.")
  }

  // MARK: - Asymmetric key exchange (symmetric key generation) methods

  /// Generates an ephemeral key agreement key and performs key agreement to  derive the symmetric encryption key.
  /// Modified from: developer.apple.com/documentation/cryptokit/performing_common_cryptographic_operations
  /// - Parameters:
  ///   - theirEncryptionPublicKeyString: Encryption public key of the recipient.
  /// - Throws: TODO:
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
    let theirEncryptionPublicKey = try Curve25519.KeyAgreement.PublicKey(
      rawRepresentation: asData(theirEncryptionPublicKeyString)
    )

    // TODO: constant placeholder
    let ephemeralSecretKey = try! Curve25519.KeyAgreement.PrivateKey(
      rawRepresentation: asData("yMpWYAgBSbeJldLXT77quy6u9Kmt7DaXFMNSe8byj1g=")
    )
    let ephemeralPublicKey = ephemeralSecretKey.publicKey

    let sharedSecret = try ephemeralSecretKey.sharedSecretFromKeyAgreement(with: theirEncryptionPublicKey)

    symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: protocolSalt,
      sharedInfo: ephemeralPublicKey.rawRepresentation +
        theirEncryptionPublicKey.rawRepresentation +
        signingPublicKey.rawRepresentation,
      outputByteCount: 32
    )

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
  /// - Throws: Error if signature unmatch or incorrect key information TODO: finish
  func verifyECDHKeyExchangeResponse(
      ephemeralPublicKeyString: String,
      signatureString: String,
      theirSigningPublicKeyString: String
  ) throws {
    // Convert input strings into corresponding data types
    let ephemeralPublicKeyData = asData(ephemeralPublicKeyString)
    let signature = asData(signatureString)
    let theirSigningPublicKey = try Curve25519.Signing.PublicKey(
      rawRepresentation: asData(theirSigningPublicKeyString)
    )

    // Verify signature
    let data = ephemeralPublicKeyData + encryptionPublicKey.rawRepresentation
    guard theirSigningPublicKey.isValidSignature(signature, for: data) else {
      throw DecryptionErrors.authenticationError
    }

    let ephemeralPublicKey = try Curve25519.KeyAgreement.PublicKey(
      rawRepresentation: ephemeralPublicKeyData
    )
    let sharedSecret = try encryptionSecretKey.sharedSecretFromKeyAgreement(
      with: ephemeralPublicKey
    )
    symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: protocolSalt,
      sharedInfo: ephemeralPublicKey.rawRepresentation +
        encryptionPublicKey.rawRepresentation +
        theirSigningPublicKey.rawRepresentation,
      outputByteCount: 32
    )
  }

  // MARK: - Symmetric encryption and decryption methods

  /// Encrypt via symmetric encryption with current symmetric key.
  /// - Parameter msg: Message to encrypt with current symmetric key
  /// - Throws: TODO
  /// - Returns:
  ///   - ciphertextString: Ciphertext of the encrypted message.
  ///   - signatureString: Signature signed with signing secret key.
  ///   - signingPublicKeyString: Public key of the secret key used for signing the signature.
  func encrypt(_ msg: String) throws -> (
    ciphertextString: String,
    signatureString: String,
    signingPublicKeyString: String
  ){
    let data = msg.data(using: .utf8)!

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
  /// - Throws: TODO
  /// - Returns: Decrypted message.
  func decrypt(
    _ sealedMessage: (ciphertextString: String, signatureString: String),
    from theirSigningPublicKeyString: String
  ) throws -> String {

    let ciphertext = asData(sealedMessage.ciphertextString)
    let signature = asData(sealedMessage.signatureString)
    let theirSigningPublicKey = try Curve25519.Signing.PublicKey(
      rawRepresentation: asData(theirSigningPublicKeyString)
    )

    guard theirSigningPublicKey.isValidSignature(signature, for: ciphertext) else {
      throw DecryptionErrors.authenticationError
    }

    let sealedBox = try! ChaChaPoly.SealedBox(combined: ciphertext)
    let msg = try ChaChaPoly.open(sealedBox, using: symmetricKey)

    return String(decoding: msg, as: UTF8.self)
  }
}

enum DecryptionErrors: Error {
    case authenticationError
}

func asData(_ str: String) -> Data {
  return Data(base64Encoded: str)!
}

func asString(_ data: Data) -> String {
  return data.withUnsafeBytes { Data(Array($0)).base64EncodedString()}
}

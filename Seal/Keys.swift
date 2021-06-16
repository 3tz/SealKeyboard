//
//  Keys.swift
//  Seal
//
//  Created by tz on 6/15/21.
//

import Foundation
import CryptoKit

final class Keys {
  var signingSecretKey: Curve25519.Signing.PrivateKey!
  var signingPublicKey: Curve25519.Signing.PublicKey!
  var encryptionSecretKey: Curve25519.KeyAgreement.PrivateKey!
  var encryptionPublicKey: Curve25519.KeyAgreement.PublicKey!
  var symmetricKey: SymmetricKey!

  // TODO: placeholder. use random salt for each msg
  let protocolSalt = "CryptoKit Playgrounds Putting It Together".data(using: .utf8)!

  init() {
    // TODO: currently private keys are always different from each initialization.
    // Might need to  give the option to load locally.
    signingSecretKey = Curve25519.Signing.PrivateKey()
    signingPublicKey = signingSecretKey.publicKey
    encryptionSecretKey = Curve25519.KeyAgreement.PrivateKey()
    encryptionPublicKey = encryptionSecretKey.publicKey
    symmetricKey = SymmetricKey(size: .bits256)
  }

  /// Generates an ephemeral key agreement key and performs key agreement to  derive the symmetric encryption key.
  /// Modified from: developer.apple.com/documentation/cryptokit/performing_common_cryptographic_operations
  /// - Parameters:
  ///   - theirEncryptionPublicKey: Encryption public key of the recipient.
  /// - Throws: TODO:
  /// - Returns:
  ///   - Public key of the ephemeral secret key used for generating the symmetric key.
  ///   - Signature signed by signing secret key.
  ///   - Public key of the signing secret key.
  func ECDHKeyExchange(
    with theirEncryptionPublicKey: Curve25519.KeyAgreement.PublicKey
  ) throws ->(
    ephemeralPublicKeyData: Data,
    signature: Data,
    signingPublicKey: Curve25519.Signing.PublicKey
  ) {
    let ephemeralSecretKey = Curve25519.KeyAgreement.PrivateKey()
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

    return (ephemeralPublicKey.rawRepresentation, signature, signingPublicKey)
  }

  /// Generates an ephemeral key agreement key and the performs key agreement to get the shared secret and derive the
  ///   symmetric encryption key.
  /// From: developer.apple.com/documentation/cryptokit/performing_common_cryptographic_operations
  func verifyECDHKeyExchangeResponse(
      ephemeralPublicKeyData: Data,
      signature: Data,
      theirSigningPublicKey: Curve25519.Signing.PublicKey
  ) throws {
    // Verify signature
    let data = ephemeralPublicKeyData + encryptionPublicKey.rawRepresentation
    guard theirSigningPublicKey.isValidSignature(signature, for: data) else {
      throw DecryptionErrors.authenticationError
    }


    let ephemeralPublicKey = try Curve25519.KeyAgreement.PublicKey(
      rawRepresentation: ephemeralPublicKeyData
    )
    let sharedSecret = try encryptionSecretKey.sharedSecretFromKeyAgreement(with: ephemeralPublicKey)
    symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: protocolSalt,
      sharedInfo: ephemeralPublicKey.rawRepresentation +
        encryptionPublicKey.rawRepresentation +
        theirSigningPublicKey.rawRepresentation,
      outputByteCount: 32
    )
  }

  /// Encrypt via symmetric encryption with current symmetric key.
  func encrypt(_ data: Data) throws -> (
    ciphertext: Data,
    signature: Data
  ){
    let ciphertext = try ChaChaPoly.seal(data, using: symmetricKey).combined
    let signature = try signingSecretKey.signature(for: ciphertext)

    return (ciphertext, signature)
  }

  /// Decrypt via symmetric encryption with current symmetric key.
  func decrypt(
    _ sealedMessage: (ciphertext: Data, signature: Data),
    from theirSigningPublicKey: Curve25519.Signing.PublicKey
  ) throws -> Data {

    let data = sealedMessage.ciphertext

    guard theirSigningPublicKey.isValidSignature(sealedMessage.signature, for: data) else {
      throw DecryptionErrors.authenticationError
    }


    let sealedBox = try! ChaChaPoly.SealedBox(combined: sealedMessage.ciphertext)

    return try ChaChaPoly.open(sealedBox, using: symmetricKey)
  }

}

enum DecryptionErrors: Error {
    case authenticationError
}

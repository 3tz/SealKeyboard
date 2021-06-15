//
//  Encryption.swift
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
  let protocolSalt = "CryptoKit Playgrounds Putting It Together".data(using: .utf8)!
  
  init() {
    // TODO: currently private keys are always different from each initialization.
    // Might need to  give the option to load locally.
    signingSecretKey = Curve25519.Signing.PrivateKey()
    signingPublicKey = signingSecretKey.publicKey
    encryptionSecretKey = Curve25519.KeyAgreement.PrivateKey()
    encryptionPublicKey = encryptionSecretKey.publicKey
  }
  
  /// Generates an ephemeral key agreement key and performs key agreement to get the shared secret and derive the
  ///   symmetric encryption key.
  /// Modified from: developer.apple.com/documentation/cryptokit/performing_common_cryptographic_operations
  func encrypt(
    _ data: Data,
    to theirEncryptionPublicKey: Curve25519.KeyAgreement.PublicKey
  ) throws ->(
    ephemeralPublicKeyData: Data,
    ciphertext: Data,
    signature: Data
  ) {
    let ephemeralKey = Curve25519.KeyAgreement.PrivateKey()
    let ephemeralPublicKey = ephemeralKey.publicKey.rawRepresentation

    let sharedSecret = try ephemeralKey.sharedSecretFromKeyAgreement(with: theirEncryptionPublicKey)

    let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: protocolSalt,
      sharedInfo: ephemeralPublicKey +
        theirEncryptionPublicKey.rawRepresentation +
        signingPublicKey.rawRepresentation,
      outputByteCount: 32
    )

    let ciphertext = try ChaChaPoly.seal(data, using: symmetricKey).combined
    let signature = try signingSecretKey.signature(
      for: ciphertext + ephemeralPublicKey + theirEncryptionPublicKey.rawRepresentation
    )

    return (ephemeralPublicKey, ciphertext, signature)
  }



  
  /// Generates an ephemeral key agreement key and the performs key agreement to get the shared secret and derive the
  ///   symmetric encryption key.
  /// From: developer.apple.com/documentation/cryptokit/performing_common_cryptographic_operations
  func decrypt(
    _ sealedMessage: (ephemeralPublicKeyData: Data, ciphertext: Data, signature: Data),
    from theirSigningPublicKey: Curve25519.Signing.PublicKey
  ) throws -> Data {
    let data = sealedMessage.ciphertext +
      sealedMessage.ephemeralPublicKeyData +
      encryptionPublicKey.rawRepresentation
    
    guard theirSigningPublicKey.isValidSignature(sealedMessage.signature, for: data) else {
      throw DecryptionErrors.authenticationError
    }

    let ephemeralKey = try Curve25519.KeyAgreement.PublicKey(
      rawRepresentation: sealedMessage.ephemeralPublicKeyData
    )
    let sharedSecret = try encryptionSecretKey.sharedSecretFromKeyAgreement(with: ephemeralKey)
    let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: protocolSalt,
      sharedInfo: ephemeralKey.rawRepresentation +
        encryptionPublicKey.rawRepresentation +
        theirSigningPublicKey.rawRepresentation,
      outputByteCount: 32
    )

    let sealedBox = try! ChaChaPoly.SealedBox(combined: sealedMessage.ciphertext)

    return try ChaChaPoly.open(sealedBox, using: symmetricKey)
  }
  
}

enum DecryptionErrors: Error {
    case authenticationError
}

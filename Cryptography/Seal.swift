//
//  Seal.swift
//  Seal
//
//  Created by tz on 7/3/21.
//

import Foundation


enum SealMessageType: String {
  case ECDH0
  case ECDH1
  case ciphertext
}

class Seal {
  private let keys: Keys

  init() {
    keys = Keys()
  }

  /// Return a string that indicates a MessageType.ECDH0 event
  func initiateECDHRequest() -> String {
    return [
      SealMessageType.ECDH0.rawValue,
      asString(keys.encryptionPublicKey.rawRepresentation)
   ].joined(separator: "|")
  }

  func unseal(string: String) throws -> (SealMessageType, String?) {
    let tokens = string.components(separatedBy: "|")
    var msg: String? = nil

    switch SealMessageType(rawValue: tokens[0]){
    case .ECDH0:
      // Request to initiate ECDH, i.e., to generate a symmetric key.
      // Generate a symmetric key and send it over.
      // Expected format: "{.ECDH0}|{sender's public key}"
      if tokens.count != 2 { throw DecryptionErrors.parsingError }

      let theirEncryptionPublicKeyString = tokens[1]

      // Start ECDH, store the symmetric key, and send them the public key
      let (ephemeralPublicKeyString, signatureString, signingPublicKeyString) =
        try keys.ECDHKeyExchange(with: theirEncryptionPublicKeyString)

      msg = [
        SealMessageType.ECDH1.rawValue,
        ephemeralPublicKeyString,
        signatureString,
        signingPublicKeyString
      ].joined(separator: "|")

    case .ECDH1:
      // Reposne to request to ECDH. Expect to receive ephemeral public key.
      // Verify signature, compute and save symmetric key.
      // Expected format: "{.ECDH1}|{ephemeralPublicKey}|{signature}|{signingPublicKey}"
      if tokens.count != 4 { throw DecryptionErrors.parsingError }

      try keys.verifyECDHKeyExchangeResponse(
        ephemeralPublicKeyString: tokens[1],
        signatureString: tokens[2],
        theirSigningPublicKeyString: tokens[3]
      )

    case .ciphertext:
      // Ciphertext received. Verify signature and decrypt using symmetric key.
      if tokens.count != 4 { throw DecryptionErrors.parsingError }
      msg = try keys.decrypt((tokens[1], tokens[2]), from: tokens[3])

    default:
      throw DecryptionErrors.parsingError
    }

    return (SealMessageType(rawValue: tokens[0])!, msg)
  }

  func seal(string: String) throws -> String {
    var ciphertextString, signatureString, signingPublicKeyString: String!
    (ciphertextString, signatureString, signingPublicKeyString) = try keys.encrypt(string)

    return [
      SealMessageType.ciphertext.rawValue,
      ciphertextString,
      signatureString,
      signingPublicKeyString
    ].joined(separator: "|")
  }
}

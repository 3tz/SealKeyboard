//
//  Seal.swift
//  Seal
//
//  Created by tz on 7/3/21.
//

import Foundation

class Seal {
  private init() {}

  /// Return a string that indicates a MessageType.ECDH0 event
  static func initiateECDHRequest() -> String {
    let encryptionPublicKeyString = asString(
      EncryptionKeys.default.encryptionPublicKey.rawRepresentation
    )
    let message = SealMessage(
      kind: .ECDH0(encryptionPublicKey: encryptionPublicKeyString),
      name: Placeholder.name
    )

    return message.asJSONString()
  }

  static func unseal(string: String) throws -> (SealMessage, String?) {

    let receivedMessage = try parse(string)
    var outgoingMessageString: String? = nil

    switch receivedMessage.kind{
      case .ECDH0(let encryptionPublicKey):
      // Request to initiate ECDH, i.e., to generate a symmetric key.
      // Generate a symmetric key and send it over.
      // Start ECDH, store the symmetric key, and send them the public key
      let (ephemeralPublicKeyString, signatureString, signingPublicKeyString) =
        try EncryptionKeys.default.ECDHKeyExchange(with: encryptionPublicKey)

      outgoingMessageString = SealMessage(
        kind: .ECDH1(
          ephemeralPublicKey: ephemeralPublicKeyString,
          signature: signatureString,
          signingPublicKey: signingPublicKeyString),
        name: Placeholder.name
      ).asJSONString()

      case .ECDH1(let ephemeralPublicKey, let signature, let signingPublicKey):
      // Reposne to request to ECDH. Expect to receive ephemeral public key.
      // Verify signature, compute and save symmetric key.

      try EncryptionKeys.default.verifyECDHKeyExchangeResponse(
        ephemeralPublicKeyString: ephemeralPublicKey,
        signatureString: signature,
        theirSigningPublicKeyString: signingPublicKey
      )

      case .ciphertext(let ciphertext, let signature, let signingPublicKey):
      // Ciphertext received. Verify signature and decrypt using symmetric key.
      guard let currentChat = ChatManager.shared.currentChat else {
        throw DecryptionErrors.noCurrentChatExistsError
      }
      outgoingMessageString = try EncryptionKeys.default.decrypt(
        (ciphertext, signature),
        from: signingPublicKey,
        with: currentChat.symmetricDigest
      )

    }

    return (receivedMessage, outgoingMessageString)
  }

  static func seal(string: String) throws -> String {
    guard let currentChat = ChatManager.shared.currentChat else {
      throw DecryptionErrors.noCurrentChatExistsError
    }
    var ciphertextString, signatureString, signingPublicKeyString: String!
    (ciphertextString, signatureString, signingPublicKeyString) =
      try EncryptionKeys.default.encrypt(
        string, with: currentChat.symmetricDigest)

    let outgoingMessage = SealMessage(
      kind: .ciphertext(
        ciphertext: ciphertextString,
        signature: signatureString,
        signingPublicKey: signingPublicKeyString),
      name: Placeholder.name
    )

    return outgoingMessage.asJSONString()
  }

  static private func parse(_ string: String) throws -> SealMessage {
    do {
      let data = string.data(using: .utf8)!
      return try JSONDecoder().decode(SealMessage.self, from: data)
    } catch {
      throw DecryptionErrors.parsingError
    }
  }
}

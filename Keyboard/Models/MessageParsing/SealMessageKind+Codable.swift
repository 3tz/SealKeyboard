//
//  SealMessageKind+Codable.swift
//  Seal
//
//  Created by tz on 7/27/21.
//

import Foundation


extension SealMessageKind: Codable {

  enum CodingKeys: String, CodingKey {
    case encryptionPublicKey
    case signature
    case signingPublicKey
    case ephemeralPublicKey
    case salt
    case ciphertext
    case type
  }

  enum MessageTypeString: String, Codable {
    case ECDH0
    case ECDH1
    case ciphertext
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let messageType = try container.decode(MessageTypeString.self, forKey: .type)

    switch messageType{
      case .ECDH0:
        self = .ECDH0(
          encryptionPublicKey: try container.decode(String.self, forKey: .encryptionPublicKey)
        )
      case .ECDH1:
        self = .ECDH1(
          ephemeralPublicKey: try container.decode(String.self, forKey: .ephemeralPublicKey),
          signature: try container.decode(String.self, forKey: .signature),
          signingPublicKey: try container.decode(String.self, forKey: .signingPublicKey),
          salt: try container.decode(String.self, forKey: .salt)
        )
      case .ciphertext:
        self = .ciphertext(
          ciphertext: try container.decode(String.self, forKey: .ciphertext),
          signature: try container.decode(String.self, forKey: .signature),
          signingPublicKey: try container.decode(String.self, forKey: .signingPublicKey)
        )
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
      case .ECDH0(let encryptionPublicKey):
        try container.encode(encryptionPublicKey, forKey: .encryptionPublicKey)
        try container.encode(MessageTypeString.ECDH0, forKey: .type)
      case .ECDH1(let ephemeralPublicKey, let signature, let signingPublicKey, let salt):
        try container.encode(ephemeralPublicKey, forKey: .ephemeralPublicKey)
        try container.encode(signature, forKey: .signature)
        try container.encode(signingPublicKey, forKey: .signingPublicKey)
        try container.encode(salt, forKey: .salt)
        try container.encode(MessageTypeString.ECDH1, forKey: .type)
      case .ciphertext(let ciphertext, let signature, let signingPublicKey):
        try container.encode(ciphertext, forKey: .ciphertext)
        try container.encode(signature, forKey: .signature)
        try container.encode(signingPublicKey, forKey: .signingPublicKey)
        try container.encode(MessageTypeString.ciphertext, forKey: .type)
    }
  }

}


//
//  SealMessageKind.swift
//  Keyboard
//
//  Created by tz on 7/26/21.
//

import Foundation

enum SealMessageKind {
  case ECDH0(encryptionPublicKey: String)
  case ECDH1(ephemeralPublicKey: String, signature: String, signingPublicKey: String)
  case ciphertext(ciphertext: String, signature: String, signingPublicKey: String)
}

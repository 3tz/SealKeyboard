//
//  SealMessage.swift
//  Seal
//
//  Created by tz on 7/27/21.
//

import Foundation

struct SealMessage: Codable {
  var kind: SealMessageKind
  var name: String

  func asJSONString() -> String {
    return String(data: try! JSONEncoder().encode(self), encoding: .utf8)!
  }
}

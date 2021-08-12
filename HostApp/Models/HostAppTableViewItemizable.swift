//
//  File.swift
//  Seal
//
//  Created by tz on 8/11/21.
//

import Foundation

protocol HostAppTableViewItemizable {
  var displayTitle: String { get }
  func performAction(controller: ViewController)
}

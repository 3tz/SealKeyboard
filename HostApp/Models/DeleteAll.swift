//
//  File.swift
//  Seal
//
//  Created by tz on 8/11/21.
//

import Foundation
import UIKit
import CoreData

class DeleteAll: HostAppTableViewItemizable {
  var leftLabelText = "Delete All Chats & Messages"
  var leftLabelTextColor: UIColor? = .systemRed

  func performAction(controller: ViewController) {
    // Delete all chats & associated messages
    let context = CoreDataContainer.shared.persistentContainer.viewContext
    try! context.execute(NSBatchDeleteRequest(fetchRequest: Chat.fetchRequest()))
    CoreDataContainer.shared.saveContext()
    EncryptionKeys.default.reloadKeys()
    // Delete all symmetric keys
    for digest in EncryptionKeys.default.symmetricKeyDigests {
      do {
        try EncryptionKeys.default.deleteSymmetricKey(with: digest)
      } catch {
        let errorMsg = """
        Received error while trying to remove a symmetric key.
        Digest: \(digest)
        Error:
        \(error)
        """
        NSLog(errorMsg)
      }
    }
  }
}

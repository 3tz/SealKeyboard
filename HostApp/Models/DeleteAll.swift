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
    // Display name is empty, so initialize.
    let alertMessage = ""
    let title = "This will delete all of your chats, messages, and associated chat keys."
    let alert = UIAlertController(title: title, message: alertMessage, preferredStyle: .actionSheet)
    // Save to UserDefaults and reload VC
    let saveAction = UIAlertAction(title: "Delete All Chats & Messages", style: .destructive) { [unowned self] _ in
      self.deleteAll()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    controller.present(alert, animated: true, completion: nil)
  }

  private func deleteAll() {
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

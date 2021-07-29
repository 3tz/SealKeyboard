//
//  ChatManager.swift
//  Keyboard
//
//  Created by tz on 7/21/21.
//

import Foundation
import CoreData

class ChatManager {
  static let shared = ChatManager()

  var chats: [Chat]!
  var titleLookup: [String:String]!
  private(set) var currentIndex: Int!

  var selectedDigest: String {
    return chats[currentIndex].symmetricDigest
  }
  var currentChat: Chat {
    return chats[currentIndex]
  }


  private init() {
    reloadChats()
  }

  func reloadChats() {
    // First get the symmetric digests
    let keyChainSymmetricKeyDigests = EncryptionKeys.default.symmetricKeyDigests

    // Fetch Chats from core data
    let context = CoreDataContainer.shared.persistentContainer.viewContext
    (titleLookup, chats) = fetchChatsFromCoreData()

    // If there's a key in keychain that doesn't exist in core data yet, create a Chat
    //   object and save it to core data.
    // This can happen upon the first time app is used or after delete all chats.
    for keyDigest in keyChainSymmetricKeyDigests {
      guard let _ = titleLookup[keyDigest] else {
        let chat = Chat(context: context)
        chat.lastEditTime = Date.init()
        chat.displayTitle = "chat \(titleLookup.count + 1)" // TODO: add index
        chat.symmetricDigest = keyDigest
        CoreDataContainer.shared.saveContext()
        (titleLookup, chats) = fetchChatsFromCoreData()
        NSLog("Key w/ digest \(keyDigest) is added to core data w/ name \(chat.displayTitle)")
        continue
      }
    }

    // TODO: On the other hand, if there's a chat that relies on a non-existing key, ???
    for (keyDigest, displayTitle) in titleLookup {
      if !keyChainSymmetricKeyDigests.contains(keyDigest) {
        fatalError("""
          Cannot find symmetric key for the following chat:
          displayTitle: \(displayTitle)
          digest: \(keyDigest)
          """)
      }
    }
    currentIndex = 0
  }

  // MARK: Helper methods.

  private func fetchChatsFromCoreData() -> (lookup: [String:String], orderedChatObjects: [Chat]) {
    let context = CoreDataContainer.shared.persistentContainer.viewContext
    let request: NSFetchRequest<Chat> = Chat.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "lastEditTime", ascending: false)]
    request.includesPendingChanges = false
    // fetch results in descending order according to last edit time
    let orderedChatObjects = try! context.fetch(request)
    let symmetricKeyDigests = orderedChatObjects.compactMap {$0.symmetricDigest},
        displayTitles = orderedChatObjects.compactMap {$0.displayTitle}
    return (
      lookup: Dictionary(uniqueKeysWithValues: zip(symmetricKeyDigests, displayTitles)),
      orderedChatObjects: orderedChatObjects
    )
  }

  // MARK: property modification methods

  func setCurrentIndex(_ newIndex: Int) {
    // TODO: maybe need to do other things like checking index range
    currentIndex = newIndex
  }

  func deleteChat(at index: Int) {
    let context = CoreDataContainer.shared.persistentContainer.viewContext
    let symmetricDigest = chats[index].symmetricDigest
    context.delete(chats[index])
    chats.remove(at: index)
    CoreDataContainer.shared.saveContext()
    try! EncryptionKeys.default.deleteSymmetricKey(with: symmetricDigest)
  }

  func appendMessageToCurrentChat(
    coreMessageId: String,
    coreSentDate: Date,
    coreSender: NSMessageSender,
    coreKind: NSMessageKind
  ) {
    // Add the message to Message entity
    let message = Message(context: CoreDataContainer.shared.persistentContainer.viewContext)
    message.coreMessageId = coreMessageId
    message.coreSentDate = coreSentDate
    message.coreSender = coreSender
    message.coreKind = coreKind
    message.chat = currentChat
    // Add the message to current Chat's NSSet
    currentChat.addToMessages(message)
    currentChat.lastEditTime = Date()

    CoreDataContainer.shared.saveContext()
    reloadChats()
  }

}


//
//  Message+CoreDataProperties.swift
//  Seal
//
//  Created by tz on 7/7/21.
//
//

import Foundation
import CoreData
import MessageKit


extension Message {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
    return NSFetchRequest<Message>(entityName: "Message")
  }

  @NSManaged public var coreSender: NSMessageSender
  @NSManaged public var coreMessageId: String
  @NSManaged public var coreSentDate: Date
  @NSManaged public var coreKind: NSMessageKind
  @NSManaged public var chat: Chat
}

extension Message : Identifiable {

}

extension Message: MessageType {
  public var sender: SenderType { get { return coreSender } }

  public var messageId: String { get { return coreMessageId } }

  public var sentDate: Date { get { return coreSentDate } }

  public var kind: MessageKind { get { return coreKind.asMessageKind() } }
}

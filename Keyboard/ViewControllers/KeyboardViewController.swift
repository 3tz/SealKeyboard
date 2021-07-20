//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by tz on 6/12/21.
//

import UIKit
import CoreData

enum KeyboardLayout {
  case typingView
  case detailView
}

class KeyboardViewController: UIInputViewController {
  // TODO: placeholder
  var currentLayout: KeyboardLayout! = .detailView // .typingView

  var textView: UITextView!

  var chatSelectionButton: UIButton!
  var topBarView: UIStackView!
  var typingViewController: TypingViewController!
  var detailViewController: DetailViewController!
  var bottomBarView: UIStackView!

  // TODO: placeholder
  var chatTitleLookup: [String:String]!
  var chatSymmetricKeyDigests: [String]!
  var selectedChatIndex: Int!
  var selectedChatDigest: String {
    return chatSymmetricKeyDigests[selectedChatIndex]
  }

  var stageToSendText = false

  var pasteboardChangeCountTimer: Timer!

  var taskRunning = false

  // MARK: - Core Data methods copied from xcode init

  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
    */
    let container = NSPersistentContainer(name: "Seal")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

  // MARK: view overrides

  override func loadView() {
    // Use stackview as the main view
    let mainStackView = UIStackView()

    mainStackView.axis = .vertical
    mainStackView.spacing = KeyboardSpecs.superViewSpacing
    mainStackView.alignment = .center
    mainStackView.translatesAutoresizingMaskIntoConstraints = false

    view = mainStackView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    loadChats()
    loadTopBarView()

    switch currentLayout {
      case .typingView:
        loadTypingView()
      case .detailView:
        loadChatView()
      default:
        fatalError()
    }

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startPasteboardChangeCountMonitor()
    pasteboardChangeCountTimer.fire()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()

    guard let mainStackView = view as? UIStackView else {
      fatalError()
    }
    NSLayoutConstraint.activate([
      mainStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width),
      mainStackView.heightAnchor.constraint(equalToConstant: KeyboardSpecs.superViewHeight),
      topBarView.widthAnchor.constraint(equalToConstant:  UIScreen.main.bounds.size.width),
    ])

    switch currentLayout {
      case .typingView:
        NSLayoutConstraint.activate([
          typingViewController.view.heightAnchor.constraint(
            equalToConstant:  KeyboardSpecs.keyboardButtonsViewHeight),
          typingViewController.view.widthAnchor.constraint(
            equalToConstant:  UIScreen.main.bounds.size.width),
        ])
      case .detailView:
        NSLayoutConstraint.activate([
          detailViewController.view.heightAnchor.constraint(
            equalToConstant:  KeyboardSpecs.keyboardButtonsViewHeight),
          detailViewController.view.widthAnchor.constraint(
            equalToConstant:  UIScreen.main.bounds.size.width),
        ])
      default:
        fatalError()
    }

  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopPasteboardChangeCountMonitor()
  }

  // MARK: UI Input overrides

  override func textDidChange(_ textInput: UITextInput?) {
    super.textDidChange(textInput)

    if stageToSendText == true {
      textDocumentProxy.insertText("\n")
      stageToSendText = false
    }

  }

  // MARK: view & data loading methods

  func fetchChatsFromCoreData() -> (lookup: [String:String], orderedDigests: [String]) {
    let context = persistentContainer.viewContext
    let request: NSFetchRequest<Chat> = Chat.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "lastEditTime", ascending: false)]
    request.includesPendingChanges = false
    let result = try! context.fetch(request)
    let symmetricKeyDigests = result.compactMap {$0.symmetricDigest},
        displayTitles = result.compactMap {$0.displayTitle}
    return (
      lookup: Dictionary(uniqueKeysWithValues: zip(symmetricKeyDigests, displayTitles)),
      orderedDigests: symmetricKeyDigests
    )
  }

  func loadChats() {
    // First get the symmetric digests
    let keyChainSymmetricKeyDigests = EncryptionKeys.default.symmetricKeyDigests

    // Fetch Chats from core data
    let context = persistentContainer.viewContext
    (chatTitleLookup, chatSymmetricKeyDigests) = fetchChatsFromCoreData()

    // If there's a key in keychain that doesn't exist in core data yet, create a Chat
    //   object and save it to core data.
    // This can happen upon the first time app is used or after delete all chats.
    for keyDigest in keyChainSymmetricKeyDigests {
      guard let _ = chatTitleLookup[keyDigest] else {
        let chat = Chat(context: context)
        chat.lastEditTime = Date.init()
        chat.displayTitle = "chat \(chatTitleLookup.count + 1)" // TODO: add index
        chat.symmetricDigest = keyDigest
        saveContext()
        (chatTitleLookup, chatSymmetricKeyDigests) = fetchChatsFromCoreData()
        NSLog("Key w/ digest \(keyDigest) is added to core data w/ name \(chat.displayTitle)")
        continue
      }
    }

    // TODO: On the other hand, if there's a chat that relies on a non-existing key, ???
    for (keyDigest, displayTitle) in chatTitleLookup {
      if !keyChainSymmetricKeyDigests.contains(keyDigest) {
        fatalError("Cannot find symmetric key for chat named \"\(displayTitle)\".")
      }
    }
    selectedChatIndex = 0
  }

  func loadTypingView() {
    typingViewController = TypingViewController(parentController: self)
    addChild(typingViewController)
    (view as! UIStackView).addArrangedSubview(typingViewController.view)

  }

  func loadChatView() {
    detailViewController = DetailViewController(keyboardViewController: self)
    addChild(detailViewController)
    (view as! UIStackView).addArrangedSubview(detailViewController.view)
    (view as! UIStackView).sendSubviewToBack(detailViewController.view)
  }

  func loadTopBarView() {
    let mainStackView = view as! UIStackView

    // create the layout switch button
    let layoutButton = UIButton()
    layoutButton.translatesAutoresizingMaskIntoConstraints = false
    let imageSystemName = currentLayout == .typingView ? "message.fill" : "keyboard"
    layoutButton.setImage(UIImage(systemName: imageSystemName), for: .normal)
    layoutButton.backgroundColor = .systemBlue
    layoutButton.tintColor = .white
    layoutButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    layoutButton.addTarget(self, action: #selector(layoutButtonPressed(_:)), for: .touchUpInside)

    // Create the status / decryption text view
    textView = UITextView()
    textView.isEditable = true
    textView.isSelectable = false
    textView.text = "Ready!"
    textView.backgroundColor = .clear
    textView.translatesAutoresizingMaskIntoConstraints = false

    // create chat selection button w/ a drop down list
    chatSelectionButton = UIButton()
    // TODO: placeholder
    updateCurrentChatTitle()
    chatSelectionButton.addTarget(
      self, action: #selector(chatSelectionButtonPressed), for: .touchUpInside)

    // add above views to a hori stackview
    topBarView = UIStackView(arrangedSubviews: [layoutButton, textView, chatSelectionButton])
    topBarView.axis = .horizontal
    topBarView.spacing = KeyboardSpecs.horizontalSpacing
    topBarView.backgroundColor = KeyboardSpecs.topBarViewBackgroundColor

    NSLayoutConstraint.activate([
      layoutButton.widthAnchor.constraint(equalToConstant: KeyboardSpecs.cryptoButtonsViewHeight),
      layoutButton.heightAnchor.constraint(equalTo: layoutButton.widthAnchor),
      chatSelectionButton.heightAnchor.constraint(equalTo: topBarView.heightAnchor),
      chatSelectionButton.widthAnchor.constraint(equalToConstant: KeyboardSpecs.cryptoButtonsViewHeight * 2),
    ])

    mainStackView.addArrangedSubview(topBarView)
  }

  // MARK: @objc #selector methods

  @objc func layoutButtonPressed(_ sender: UIButton) {
    switch currentLayout {
      case .detailView:
        detailViewController.view.removeFromSuperview()
        detailViewController.removeFromParent()
        loadTypingView()
        currentLayout = .typingView
        (topBarView.arrangedSubviews[0] as! UIButton).setImage(
          UIImage(systemName: "message.fill"), for: .normal)
      case .typingView:
        typingViewController.view.removeFromSuperview()
        typingViewController.removeFromParent()
        loadChatView()
        currentLayout = .detailView
        (topBarView.arrangedSubviews[0] as! UIButton).setImage(
          UIImage(systemName: "keyboard"), for: .normal)
      default:
        fatalError()
    }
  }

  @objc func chatSelectionButtonPressed(_ sender: UIButton) {
    let popover = ChatSelectionPopoverViewController(parentController: self)

    popover.modalPresentationStyle = .popover
    popover.preferredContentSize = CGSize(width: KeyboardSpecs.cryptoButtonsViewHeight * 2.5, height: KeyboardSpecs.cryptoButtonsViewHeight * 3)
    let popoverController = popover.popoverPresentationController
    popoverController?.delegate = self
    popoverController?.sourceView = sender
    // TODO: y offset should probably match with text size of chat title
    popoverController?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.midY + 10, width: 0, height: 0)

    popoverController?.permittedArrowDirections = .up
    present(popover, animated: true, completion: nil)
  }

  // MARK: Sealing/unsealing/ECDH methods

  func ECDHRequestStringToMessageBox() {
    textView.text =  StatusText.ECDHInitialized // TODO: placeholder
    let message = Seal.initiateECDHRequest()
    clearInputText()
    textDocumentProxy.insertText(message)
  }

  func sealMessageBox(andSend: Bool = false) {
    if !taskRunning {
      taskRunning = true
      DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        guard let self = self else { return }

        let textInput = self.getFullDocumentContextString()

        DispatchQueue.main.sync { [weak self] in
          guard let self = self else { return }

          // Delete all text
          for _ in 0..<textInput.count {
            self.textDocumentProxy.deleteBackward()
          }

          if textInput.isEmpty {
            self.textView.text = StatusText.sealFailureEmpty
            return
          }

          let message: String

          do {
            message = try Seal.seal(string: textInput)
          } catch {
            NSLog("sealMessageBox error caught:\n\(error)")
            self.textView.text = StatusText.sealFailureSymmetricAlgo
            return
          }

          self.textDocumentProxy.insertText(message)
          self.textView.text = StatusText.sealSuccessButNotSent

          self.detailViewController.appendStringMessageToChatView(textInput, sender: ChatView.senderMe)
          if andSend {
            self.textView.text = StatusText.sealSuccessAndSent
            // Apps with ReturnType of .send look for a single "\n" upon text change.
            // Thus, change the text to ciphertext first, and insert one "\n" under textDidChange.
            self.stageToSendText = true
          }
          self.taskRunning = false
        } // DispatchQueue.main.sync
      }
    }
  }

  func unsealCopiedText() {
    guard let copiedText = UIPasteboard.general.string else {
      textView.text = StatusText.unsealFailureEmpty // TODO: placeholder
      return
    }

    let messageType: SealMessageType, message: String?

    do {
      (messageType, message) = try Seal.unseal(string: copiedText)
    } catch DecryptionErrors.parsingError {
      textView.text = StatusText.unsealFailureParsingError
      return
    } catch DecryptionErrors.authenticationError {
      textView.text = StatusText.unsealFailureAuthenticationError
      return
    } catch {
      textView.text = StatusText.unsealFailureOtherError
      return
    }

    switch messageType {
      case .ECDH0:
        clearInputText()
        textDocumentProxy.insertText(message!)
        // TODO: placeholder
        textView.text = StatusText.unsealSuccessReceivedECDH0
      case .ECDH1:
        textView.text = StatusText.unsealSuccessReceivedECDH1
      case .ciphertext:
        let statusText: String!
        switch currentLayout {
          case .detailView:
            statusText = "\(StatusText.unsealSuccessReceivedCiphertext). See below."
            detailViewController.appendStringMessageToChatView(
              message!,
              sender: NSMessageSender(senderId: "placeholder", displayName: "placeholder"))
          case .typingView:
             statusText = "\(StatusText.unsealSuccessReceivedCiphertext):\n\(message!)"
          default:
            fatalError()
        }
        textView.text = statusText
    }
  }


  // MARK: helper methods

  /// Modified from: https://stackoverflow.com/a/37956477/10693217
  /// Must be run on a non-main thread due to the nature of it checking while UI updating
  func getFullDocumentContextString() -> String {
    var totalOffset = 0,
        fullString = ""
    let sleepTimeInterval = 0.05

      // Move cursor to the end of the text
      // Note: For some reason, newlines cannot be parsed from contextAfterInput, which is
      //   why it only moves to the end instead of reading along the way.
      while let context = textDocumentProxy.documentContextAfterInput{
        textDocumentProxy.adjustTextPosition(byCharacterOffset: max(context.count, 1))
        Thread.sleep(forTimeInterval: sleepTimeInterval)
      }

      // Keep moving cursor backward until it's at the beginning & reading along the way
      while let context = textDocumentProxy.documentContextBeforeInput, !context.isEmpty {
        fullString = context + fullString
        textDocumentProxy.adjustTextPosition(byCharacterOffset: -context.count)
        totalOffset += context.count
        Thread.sleep(forTimeInterval: sleepTimeInterval)
      }

      // Teleport cursor to the end
      textDocumentProxy.adjustTextPosition(byCharacterOffset: totalOffset)
      Thread.sleep(forTimeInterval: sleepTimeInterval)

    return fullString
  }

  /// Clear the input text field if it's not empty.
  func clearInputText() {
    if !textDocumentProxy.hasText { return }

    let textBeforeInput = textDocumentProxy.documentContextBeforeInput ?? ""
    let textAfterInput = textDocumentProxy.documentContextAfterInput ?? ""
    let selectedText = textDocumentProxy.selectedText ?? ""

    // move cursor to the end of the text input
    textDocumentProxy.adjustTextPosition(byCharacterOffset: textAfterInput.count)

    // delete backward n times where n is the length of the text
    for _ in 0..<textAfterInput.count + textBeforeInput.count + selectedText.count {
      textDocumentProxy.deleteBackward()
    }
  }

  /// Check if pasteboard has changed every 1 second, and unseal if it has.
  func startPasteboardChangeCountMonitor() {
    pasteboardChangeCountTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
      timer in
      if self.pasteboardChanged() { self.unsealCopiedText() }
//      NSLog("Pasteboard counter checked")
    }
  }

  func stopPasteboardChangeCountMonitor() {
    pasteboardChangeCountTimer?.invalidate()
  }

  func pasteboardChanged() -> Bool {
    let oldChangeCount = UserDefaults.standard.integer(
      forKey: DefaultKeys.previousPasteboardChangeCount.rawValue)
    let currentChangeCount = UIPasteboard.general.changeCount
    UserDefaults.standard.setValue(
      currentChangeCount, forKey: DefaultKeys.previousPasteboardChangeCount.rawValue)
    if oldChangeCount == currentChangeCount { return false }

    return true
  }

  func updateCurrentChatTitle() {
    let currentChatTitle = "▼ " + chatTitleLookup[selectedChatDigest]!
    chatSelectionButton.setTitle(currentChatTitle, for: .normal)
  }
}

extension KeyboardViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}

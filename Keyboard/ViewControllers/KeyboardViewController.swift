//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by tz on 6/12/21.
//

import UIKit

enum KeyboardLayout: Int {
  case typingView
  case detailView
}

enum SetupRequestType: String {
  case fullAccess
  case displayName
}

class KeyboardViewController: UIInputViewController {
  var currentLayout: KeyboardLayout!

  var layoutButton: UIButton!
  var textView: UITextView!

  var mainStackView: UIStackView!
  var chatSelectionButton: UIButton!
  var topBarView: UIStackView!
  var typingViewController: TypingViewController!
  var detailViewController: DetailViewController!
  var bottomBarView: UIStackView!

  var setupRequestStackView: UIStackView!
  var setupRequestLabel: UILabel!
  var goToButton: UIButton!

  var constraints: [NSLayoutConstraint] = []

  var stageToSendText = false

  var pasteboardChangeCountTimer: Timer!

  var taskRunning = false

  var pasteboardLock = NSLock()

  var hasDisplayName: Bool {
    // assuming hasFullAccess == true
    let userDefaults = UserDefaults(suiteName: "group.com.3tz.seal")!
    if let _ = userDefaults.string(forKey: UserDefaultsKeys.chatDisplayName.rawValue) {
      return true
    }
    return false
  }

  // MARK: view overrides

  override func loadView() {
    super.loadView()
    loadSetupRequestView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupRequestStackView.isHidden = hasFullAccess
    if !hasFullAccess {
      displaySetupRequestText(for: .fullAccess)
      return
    }
    setupRequestStackView.isHidden = hasDisplayName
    if !hasDisplayName {
      displaySetupRequestText(for: .displayName)
      return
    }

    // initialize the main stack view
    mainStackView = UIStackView()
    mainStackView.axis = .vertical
    mainStackView.spacing = KeyboardSpecs.superViewSpacing
    mainStackView.alignment = .center
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mainStackView)

    // Use the layout from last time
    let storedLayoutInt = UserDefaults(suiteName: "group.com.3tz.seal")!.integer(forKey: UserDefaultsKeys.currentLayout.rawValue)
    currentLayout = KeyboardLayout(rawValue: storedLayoutInt)

    loadTopBarView()
    loadTypingViewControllerWithViewHidden()
    loadChatViewControllerWithViewHidden()

    // Unhide the view for current layout
    switch currentLayout {
      case .typingView:
        typingViewController.view.isHidden = false
      case .detailView:
        detailViewController.view.isHidden = false
      default:
        fatalError()
    }

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if !hasFullAccess || !hasDisplayName {
      return
    }
    startPasteboardChangeCountMonitor()
    pasteboardChangeCountTimer.fire()
    EncryptionKeys.default.reloadKeys()
    ChatManager.shared.reloadChats()
    updateCurrentChatTitle()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()
    if !hasFullAccess || !hasDisplayName {
      // TODO: redundant code
      KeyboardSpecs.isLandscape = UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
      NSLayoutConstraint.deactivate(constraints)
      let heightConstraint = view.heightAnchor.constraint(equalToConstant: KeyboardSpecs.superViewHeight)
      heightConstraint.priority = UILayoutPriority(999)
      constraints = [
        heightConstraint
      ]
      NSLayoutConstraint.activate(constraints)
      return
    }

    KeyboardSpecs.isLandscape = UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height

    NSLayoutConstraint.deactivate(constraints)

    let heightConstraint = view.heightAnchor.constraint(equalToConstant: KeyboardSpecs.superViewHeight)
    heightConstraint.priority = UILayoutPriority(999)
    constraints = [
      heightConstraint,
      mainStackView.heightAnchor.constraint(equalToConstant: KeyboardSpecs.superViewHeight),
      mainStackView.widthAnchor.constraint(equalTo: view.widthAnchor),

      topBarView.heightAnchor.constraint(equalToConstant:  KeyboardSpecs.cryptoButtonsViewHeight),
      topBarView.widthAnchor.constraint(equalTo:  mainStackView.widthAnchor),

      typingViewController.view.widthAnchor.constraint(equalTo:  mainStackView.widthAnchor),
      detailViewController.view.widthAnchor.constraint(equalTo:  mainStackView.widthAnchor),

      layoutButton.heightAnchor.constraint(
        equalToConstant: KeyboardSpecs.bottomBarViewHeight - KeyboardSpecs.verticalSpacing),
      layoutButton.widthAnchor.constraint(equalTo: layoutButton.heightAnchor),
      textView.heightAnchor.constraint(equalTo: topBarView.heightAnchor),
      chatSelectionButton.heightAnchor.constraint(equalTo: topBarView.heightAnchor),
      chatSelectionButton.widthAnchor.constraint(equalToConstant: KeyboardSpecs.cryptoButtonsViewHeight * 2),
    ]

    NSLayoutConstraint.activate(constraints)
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    updateViewConstraints()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if !hasFullAccess || !hasDisplayName {
      return
    }
    let darkMode = traitCollection.userInterfaceStyle == .dark
    let color = darkMode ? UIColor.white : UIColor.black
    chatSelectionButton.setTitleColor(color, for: .normal)
    chatSelectionButton.tintColor = color
    layoutButton.tintColor = color
    layoutButton.layer.borderColor = color.cgColor
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

  // MARK: view loading methods

  func loadSetupRequestView() {
    setupRequestLabel = UILabel()
    setupRequestLabel.numberOfLines = 0

    goToButton = UIButton(type: .system)
    goToButton.setTitleColor(.white, for: .normal)
    goToButton.backgroundColor = .systemBlue
    goToButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius

    setupRequestStackView = UIStackView(arrangedSubviews: [
      setupRequestLabel,
      goToButton,
    ])
    setupRequestStackView.axis = .vertical
    setupRequestStackView.translatesAutoresizingMaskIntoConstraints = false
    setupRequestStackView.alignment = .center
    setupRequestStackView.distribution = .fill
    view.addSubview(setupRequestStackView)

    NSLayoutConstraint.activate([
      setupRequestStackView.heightAnchor.constraint(equalToConstant: 200),
      setupRequestStackView.widthAnchor.constraint(equalToConstant: 300),
      goToButton.widthAnchor.constraint(equalToConstant: 150),
      goToButton.heightAnchor.constraint(equalToConstant: KeyboardSpecs.cryptoButtonsViewHeight - KeyboardSpecs.verticalSpacing),
      setupRequestStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      setupRequestStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])
  }

  func loadTypingViewControllerWithViewHidden() {
    typingViewController = TypingViewController(parentController: self)
    addChild(typingViewController)
    mainStackView.addArrangedSubview(typingViewController.view)
    typingViewController.view.isHidden = true
  }

  func loadChatViewControllerWithViewHidden() {
    detailViewController = DetailViewController(keyboardViewController: self)
    addChild(detailViewController)
    mainStackView.addArrangedSubview(detailViewController.view)
    mainStackView.sendSubviewToBack(detailViewController.view)
    detailViewController.view.isHidden = true
  }

  func loadTopBarView() {
    let darkMode = traitCollection.userInterfaceStyle == .dark
    let color = darkMode ? UIColor.white : UIColor.black

    // create the layout switch button
    layoutButton = UIButton()
    layoutButton.translatesAutoresizingMaskIntoConstraints = false
    let imageSystemName = currentLayout == .typingView ? "message" : "keyboard"
    layoutButton.setImage(UIImage(systemName: imageSystemName), for: .normal)
    layoutButton.backgroundColor = .clear
    layoutButton.tintColor = color
    let layoutButtonWidth = KeyboardSpecs.bottomBarViewHeight - KeyboardSpecs.verticalSpacing
    layoutButton.layer.cornerRadius = layoutButtonWidth / 2
    layoutButton.layer.borderWidth = 1.5
    layoutButton.layer.borderColor = color.cgColor
    layoutButton.addTarget(self, action: #selector(layoutButtonPressed(_:)), for: .touchUpInside)

    // Create the status / decryption text view
    textView = UITextView()
    textView.isEditable = true
    textView.isSelectable = false
    textView.text = ""
    textView.backgroundColor = .clear
    textView.translatesAutoresizingMaskIntoConstraints = false

    // create chat selection button w/ a drop down list
    chatSelectionButton = UIButton()
    chatSelectionButton.setImage(UIImage(systemName: "arrowtriangle.down.fill"), for: .normal)
    chatSelectionButton.semanticContentAttribute = .forceRightToLeft
    updateCurrentChatTitle()
    chatSelectionButton.contentHorizontalAlignment = .right
    chatSelectionButton.setTitleColor(color, for: .normal)
    chatSelectionButton.tintColor = color
    chatSelectionButton.addTarget(
      self, action: #selector(chatSelectionButtonPressed), for: .touchUpInside)

    // add above views to a hori stackview
    let spacerView = UIView()
    let spacerView2 = UIView()
    topBarView = UIStackView(arrangedSubviews: [spacerView, layoutButton, textView, chatSelectionButton, spacerView2])
    topBarView.axis = .horizontal
    topBarView.spacing = KeyboardSpecs.horizontalSpacing
    topBarView.backgroundColor = KeyboardSpecs.topBarViewBackgroundColor
    topBarView.alignment = .center
    topBarView.distribution = .fill

    NSLayoutConstraint.activate([
      spacerView.widthAnchor.constraint(equalToConstant: 0),
      spacerView2.widthAnchor.constraint(equalToConstant: 0),
    ])

    mainStackView.addArrangedSubview(topBarView)
  }

  // MARK: @objc #selector methods

  func goToApp(for requestType: SetupRequestType) {
    // modified from https://stackoverflow.com/a/60302256/10693217

    var components = URLComponents()
    components.scheme = "sealkeyboard"

    if requestType == .fullAccess {
      components.path = "settings"
    }

    var responder: UIResponder? = self as UIResponder
    let selector = #selector(openURL(_:))
    while responder != nil {
      if responder!.responds(to: selector) && responder != self {
        responder!.perform(selector, with: components.url!)
        return
      }
      responder = responder?.next
    }
  }

  @objc func openURL(_ url: URL) {
    // From https://stackoverflow.com/a/60302256/10693217
    return
  }

  @objc func goToSettingsButtonPressed() {
    goToApp(for: .fullAccess)
  }

  @objc func goToHostAppButtonPressed() {
    goToApp(for: .displayName)
  }

  @objc func layoutButtonPressed(_ sender: UIButton) {
    switch currentLayout {
      case .detailView:
        detailViewController.view.isHidden = true
        typingViewController.view.isHidden = false
        currentLayout = .typingView
        layoutButton.setImage(
          UIImage(systemName: "message"), for: .normal)
      case .typingView:
        typingViewController.view.isHidden = true
        detailViewController.view.isHidden = false
        currentLayout = .detailView
        layoutButton.setImage(
          UIImage(systemName: "keyboard"), for: .normal)
        detailViewController.chatViewController.messagesCollectionView.reloadDataAndKeepOffset()
      default:
        fatalError()
    }
    // Store current layout, so it's used the next time the keyboard is opened
    let userDefaults = UserDefaults(suiteName: "group.com.3tz.seal")!
    userDefaults.setValue(currentLayout.rawValue, forKey: UserDefaultsKeys.currentLayout.rawValue)
    userDefaults.synchronize()
  }

  @objc func chatSelectionButtonPressed(_ sender: UIButton) {
    let popover = ChatSelectionPopoverViewController(parentController: self)

    popover.modalPresentationStyle = .popover
    popover.preferredContentSize = CGSize(width: KeyboardSpecs.cryptoButtonsViewHeight * 4, height: KeyboardSpecs.cryptoButtonsViewHeight * 3)
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
      guard let _ = ChatManager.shared.currentChat else {
        self.textView.text = StatusText.sealFailureNoCurrentChatExists
        return
      }
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

          if let _ = try? Seal.parse(textInput) {
            // if it's already sealed, do nothing.
            NSLog("Attempted to seal a sealed string. Do nothing.")
            self.textDocumentProxy.insertText(textInput)
          } else {
            do {
              message = try Seal.seal(string: textInput)
            } catch DecryptionErrors.noCurrentChatExistsError {
              self.textView.text = StatusText.sealFailureNoCurrentChatExists
              return
            } catch {
              NSLog("sealMessageBox error caught:\n\(error)")
              self.textView.text = StatusText.sealFailureSymmetricAlgo
              return
            }

            self.textDocumentProxy.insertText(message)
            self.textView.text = StatusText.sealSuccessButNotSent

            self.detailViewController.appendStringMessageToChatView(textInput, sender: ChatView.senderMe)
          }


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

    let receivedMessage: SealMessage, outgoingMessageString: String?

    do {
      (receivedMessage, outgoingMessageString) = try Seal.unseal(string: copiedText)
    } catch DecryptionErrors.parsingError {
      textView.text = StatusText.unsealFailureParsingError
      return
    } catch DecryptionErrors.authenticationError {
      textView.text = StatusText.unsealFailureAuthenticationError
      return
    } catch DecryptionErrors.newSymmetricKeyAlreadyExistsError {
      textView.text = StatusText.unsealFailureNewSymmetricKeyAlreadyExists
      return
    } catch DecryptionErrors.noCurrentChatExistsError {
      textView.text = StatusText.unsealFailureNoCurrentChatExists
      return
    } catch {
      textView.text = StatusText.unsealFailureOtherError
      return
    }

    // Message unsealed successfully. Now perform operations according to message kind.
    switch receivedMessage.kind {
      case .ECDH0:
        clearInputText()
        textDocumentProxy.insertText(outgoingMessageString!)
        // Create new chat
        let displayTitle = receivedMessage.name
        let newDigest = EncryptionKeys.default.newlyAddedSymmetricKeyDigest!
        ChatManager.shared.addNewChat(named: displayTitle, with: newDigest)
        // Update chat selection button & reload chat view messages
        updateCurrentChatTitle()
        detailViewController.chatViewController.reloadMessages()

        textView.text = StatusText.unsealSuccessReceivedECDH0
      case .ECDH1:
        // Create new chat
        let displayTitle = receivedMessage.name
        let newDigest = EncryptionKeys.default.newlyAddedSymmetricKeyDigest!
        ChatManager.shared.addNewChat(named: displayTitle, with: newDigest)
        // Update chat selection button & reload chat view messages
        updateCurrentChatTitle()
        detailViewController.chatViewController.reloadMessages()

        textView.text = StatusText.unsealSuccessReceivedECDH1
      case .ciphertext(_, _, signingPublicKey: let theirSigningPublicKey):
        let statusText: String!
        switch currentLayout {
          case .detailView:
            statusText = "\(StatusText.unsealSuccessReceivedCiphertext). See below."
          case .typingView:
             statusText = "\(StatusText.unsealSuccessReceivedCiphertext):\n\(outgoingMessageString!)"
          default:
            fatalError()
        }
        detailViewController.appendStringMessageToChatView(
          outgoingMessageString!,
          sender: NSMessageSender(
            senderId: theirSigningPublicKey, displayName: receivedMessage.name)
        )
        textView.text = statusText
    }
  }


  // MARK: helper methods

  func displaySetupRequestText(for requestType: SetupRequestType) {
    goToButton.removeTarget(nil, action: nil, for: .allEvents)

    switch requestType {
      case .fullAccess:
        setupRequestLabel.text = """
        "Allow Full Access" must be turned on in order to use Seal.
        Full access is required for Seal to store encryption keys and chats.
        """
        goToButton.setTitle("Go to Settings", for: .normal)
        goToButton.addTarget(self, action: #selector(goToSettingsButtonPressed), for: .touchUpInside)
      case .displayName:
        setupRequestLabel.text = """
        You need to setup a display name in order to use Seal.
        """
        goToButton.setTitle("Go to Seal Keyboard", for: .normal)
        goToButton.addTarget(self, action: #selector(goToHostAppButtonPressed), for: .touchUpInside)
    }
  }

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
      [unowned self] _ in
      if self.pasteboardChanged() { self.unsealCopiedText() }
    }
  }

  func stopPasteboardChangeCountMonitor() {
    pasteboardChangeCountTimer?.invalidate()
    pasteboardLock.unlock()
  }

  func pasteboardChanged() -> Bool {
    pasteboardLock.lock()
    let oldChangeCount = UserDefaults(suiteName: "group.com.3tz.seal")!.integer(
      forKey: UserDefaultsKeys.previousPasteboardChangeCount.rawValue)
    let currentChangeCount = UIPasteboard.general.changeCount
    let userDefaults = UserDefaults(suiteName: "group.com.3tz.seal")!
    userDefaults.setValue(
      currentChangeCount, forKey: UserDefaultsKeys.previousPasteboardChangeCount.rawValue)
    userDefaults.synchronize()
    pasteboardLock.unlock()
    if oldChangeCount == currentChangeCount { return false }

    return true
  }

  func writeToPasteboardAndIncrementPasteboardChangeCount(_ string: String) {
    pasteboardLock.lock()
    UIPasteboard.general.string = string
    let userDefaults = UserDefaults(suiteName: "group.com.3tz.seal")!
    userDefaults.setValue(
      UIPasteboard.general.changeCount,
      forKey: UserDefaultsKeys.previousPasteboardChangeCount.rawValue
    )
    userDefaults.synchronize()
    pasteboardLock.unlock()
  }

  func updateCurrentChatTitle() {

    let currentChatTitle = ChatManager.shared.currentChat?.displayTitle ??  "<Empty>"
    chatSelectionButton.setTitle(currentChatTitle, for: .normal)
    // Switch Chat

  }
}

extension KeyboardViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    return .none
  }
}

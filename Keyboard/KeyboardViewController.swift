//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by tz on 6/12/21.
//

import UIKit
import CryptoKit

class KeyboardViewController: UIInputViewController {
  
  var keyboardView: UIView!
  @IBOutlet var decryptedMsg: UILabel!
  @IBOutlet var nextKeyboardButton: UIButton!
  
  // Encryption and Signing Keys
  var keys: Keys!

  // AES-256 key
  var aes: ContiguousBytes!
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    keys = Keys()
    
    // Use xib as view
    view = UINib(
      nibName: "KeyboardView",
      bundle: nil
    ).instantiate(withOwner: self, options: nil)[0] as? UIView
    
    // Actually make the globe button switch keyboard
    nextKeyboardButton.addTarget(
      self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    decryptedMsg.text = ""
  }
  
  override func viewWillLayoutSubviews() {
    self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
    super.viewWillLayoutSubviews()
  }
  
  override func textWillChange(_ textInput: UITextInput?) {
    // The app is about to change the document's contents. Perform any preparation here.
  }
  
  override func textDidChange(_ textInput: UITextInput?) {
    // The app has just changed the document's contents, the document context has been updated.

    var textColor: UIColor
    let proxy = self.textDocumentProxy
    if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
      textColor = UIColor.white
    } else {
      textColor = UIColor.black
    }
    self.nextKeyboardButton.setTitleColor(textColor, for: [])
  }

  /// Request button pressed, so perform key exchange process by placing our encryption public key in the input text field.
  @IBAction func requestButtonPressed(_ sender: Any) {
    decryptedMsg.text = "request pressed" // TODO: placeholder
    let msg =
      "\(MessageType.requestSymmetricKey.rawValue)|\(keys.encryptionPublicKey.string)"
    clearInputText()
    textDocumentProxy.insertText(msg)
  }
  
  @IBAction func decryptButtonPressed(_ sender: Any) {
    // TODO: finish
    guard let copiedText = UIPasteboard.general.string else {
      decryptedMsg.text = "No copied text found." // TODO: placeholder
      return
    }
    
    let tokens = copiedText.components(separatedBy: "|")
  
    switch MessageType(rawValue: tokens[0]){
    case .requestSymmetricKey:
      // Request to generate Symmetric key.
      // Generate a symmetric key and send it over.
      // Expected format: "req_aes|{sender's public key}"
      if tokens.count != 2 { fallthrough }
      
      
      // TODO: error handling: check if it's a valid pk
      let senderPkData = Data(base64Encoded: tokens[1])!
      let theirEncryptionPublicKey = try! Curve25519.KeyAgreement.PublicKey(
        rawRepresentation: senderPkData
      )
      
    case .encryptedSymmetricKey:
      break
    case .ciphertext:
      break
    default:
      decryptedMsg.text = "Unknown type of message copied."
    }
    
    
    
  }
  
  @IBAction func encryptButtonPressed(_ sender: Any) {
    // TODO: finish
    decryptedMsg.text = "encrypt pressed"
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

  
}

enum MessageType: String {
  case requestSymmetricKey = "req_sym"
  case encryptedSymmetricKey = "enc_sym"
  case ciphertext = "ciphertext"
}

extension Data {
  var string: String { return String(decoding: self, as: UTF8.self) }
}

extension Curve25519.KeyAgreement.PrivateKey {
  var string: String {
    return self.rawRepresentation.withUnsafeBytes { Data(Array($0)).base64EncodedString() }
  }
}

extension Curve25519.KeyAgreement.PublicKey {
  var string: String {
    return self.rawRepresentation.withUnsafeBytes { Data(Array($0)).base64EncodedString() }
  }
}

extension ContiguousBytes {
  var string: String {
    return self.withUnsafeBytes { Data(Array($0)).base64EncodedString() }
  }
}

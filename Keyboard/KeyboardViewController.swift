//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by tz on 6/12/21.
//

import UIKit

class KeyboardViewController: UIInputViewController {
  
  var keyboardView: UIView!
  @IBOutlet var textBox: UILabel!
  @IBOutlet var nextKeyboardButton: UIButton!

  // Encryption and Signing Keys
  var keys: Keys!

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
    textBox.text = ""
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
    textBox.text = "request pressed" // TODO: placeholder
    let msg = MessageType.ECDH0.rawValue + "|" +
      asString(keys.encryptionPublicKey.rawRepresentation)
    clearInputText()
    textDocumentProxy.insertText(msg)
  }
  
  @IBAction func unsealButtonPressed(_ sender: Any) {
    // TODO: finish
    guard let copiedText = UIPasteboard.general.string else {
      textBox.text = "No copied text found." // TODO: placeholder
      return
    }
    
    let tokens = copiedText.components(separatedBy: "|")
    NSLog("Tokens read: \(tokens)")

    switch MessageType(rawValue: tokens[0]){
    case .ECDH0:
      // Request to initiate ECDH, i.e., to generate a symmetric key.
      // Generate a symmetric key and send it over.
      // Expected format: "{.ECDH0}|{sender's public key}"
      if tokens.count != 2 { fallthrough }

      let theirEncryptionPublicKeyString = tokens[1]

      var ephemeralPublicKeyString, signatureString, signingPublicKeyString: String!
      // Start ECDH, store the symmetric key, and send them the public key
      do {
        (ephemeralPublicKeyString, signatureString, signingPublicKeyString) =
                try keys.ECDHKeyExchange(with: theirEncryptionPublicKeyString)
      } catch {
        NSLog(".ECDH0 error caught:\n\(error)")
        fallthrough
      }

      let msg = [
        MessageType.ECDH1.rawValue,
        ephemeralPublicKeyString,
        signatureString,
        signingPublicKeyString
      ].joined(separator: "|")

      clearInputText()
      textDocumentProxy.insertText(msg)

      // TODO: placeholder
      textBox.text = "Request to generate symmetric key received."

    case .ECDH1:
      // Reposne to request to ECDH. Expect to receive ephemeral public key.
      // Verify signature, compute and save symmetric key.
      // Expected format: "{.ECDH1}|{ephemeralPublicKey}|{signature}|{signingPublicKey}"
      if tokens.count != 4 { fallthrough }

      do {
        try keys.verifyECDHKeyExchangeResponse(
          ephemeralPublicKeyString: tokens[1],
          signatureString: tokens[2],
          theirSigningPublicKeyString: tokens[3]
        )
      } catch {
        NSLog(".ECDH1 error caught:\n\(error)")
        fallthrough
      }


      // TODO: placeholder
      textBox.text = "Symmetric key generated"

    case .ciphertext:
      // Ciphertext received. Verify signature and decrypt using symmetric key.
      if tokens.count != 4 { fallthrough }
      var plaintext: String

      do {
        plaintext = try keys.decrypt((tokens[1], tokens[2]), from: tokens[3])
      } catch {
          NSLog(".ciphertext error caught:\n\(error)")
          fallthrough
      }

      // TODO: placeholder
      textBox.text = "Decrypted Message:\n\(plaintext)"

    default:
      textBox.text = "Unknown type of message copied."
    }
    

  }
  
  @IBAction func sealButtonPressed(_ sender: Any) {
    // TODO: finish
    let textInput = (textDocumentProxy.documentContextBeforeInput ?? "") +
      (textDocumentProxy.selectedText ?? "") +
      (textDocumentProxy.documentContextAfterInput ?? "")

    if textInput.isEmpty {
      textBox.text = "Unable to seal message because input text field is empty."
      return
    }

    var ciphertextString, signatureString, signingPublicKeyString: String!

    do {
      (ciphertextString, signatureString, signingPublicKeyString) = try keys.encrypt(textInput)
    } catch {
      NSLog("encryptButtonPressed error caught:\n\(error)")
      textBox.text = "Something went wrong. Unable to encrypt. Try again later."
      return
    }


    let msg = [
      MessageType.ciphertext.rawValue,
      ciphertextString,
      signatureString,
      signingPublicKeyString
    ].joined(separator: "|")

    clearInputText()
    textDocumentProxy.insertText(msg)

    textBox.text = "Text encrypted! Ready to be sent."

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
  case ECDH0
  case ECDH1
  case ciphertext
}


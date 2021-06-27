//
//  Keyboard.swift
//  Keyboard
//
//  Created by tz on 6/22/21.
//

import Foundation
import UIKit

extension String {
  var isSingleAlphabet: Bool {
    return self.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil &&
      !self.isEmpty &&
      self.count == 1
  }
  var isLowercasedAlphabet: Bool {
    return self.rangeOfCharacter(from: CharacterSet.lowercaseLetters.inverted) == nil &&
      !self.isEmpty
  }
  var isUppercasedAlphabet: Bool {
    return self.rangeOfCharacter(from: CharacterSet.uppercaseLetters.inverted) == nil &&
      !self.isEmpty
  }
}

class Keyboard{
  enum State: String {
    case alphabets
    case numbers
    case symbols
  }

  enum ShiftState: Int {
    case off
    case on
    case locked
  }

  var mode: State!
  var shiftState: ShiftState!
  var shiftDoubleTapped: Bool = false

  var darkMode: Bool!
  var controller: KeyboardViewController!
  var view: UIStackView! = nil

  var returnButton: KeyboardButton!

  var backspaceHeldTimer: Timer!

  init(controller: KeyboardViewController, darkMode: Bool) {
    self.darkMode = darkMode
    self.controller = controller

    mode = .alphabets
    shiftState = .off
    view = getButtonsView()
  }

  // MARK: internal methods for getting view & switching dark mode

  func getButtonsView() -> UIStackView{
    if view != nil {
      return view
    }

    view = UIStackView()
    view.axis = .vertical
    view.spacing = 0
    reloadButtonsAndLooks()
    return view
  }

  func updateColors(darkModeOn: Bool) {
    darkMode = darkModeOn
    for rowStackView in view.arrangedSubviews {
      for subView in (rowStackView as! UIStackView).arrangedSubviews {
        guard let button = subView as? KeyboardButton else {
          // It's a spacer UIView
          continue
        }
        let keyname = button.accessibilityIdentifier!

        if specialKeyNames.contains(keyname) && keyname != "space" {
          // special buttons except for space have a darker color
          button.setBackgroundColor(darkMode ? .darkGray : .lightGray)
          if keyname == "switch" {
            button.setTintColor(darkMode ? .white : .black)
          } else {
            button.setTitleColor(darkMode ? .white : .black, for: [])
          }

        } else {
          // regular input buttons
          button.setBackgroundColor(darkMode ? .gray : .white)
          button.setTitleColor(darkMode ? .white : .black, for: [])
        }
      }
    }
  }

  func updateReturnKeyType() {
    let returnType = controller.textDocumentProxy.returnKeyType ?? .default
    switch returnType {
      case .send:
        returnButton.setTitle("Seal & Send", for: .normal)
      case .default:
        returnButton.setTitle("return", for: .normal)
      default:
        returnButton.setTitle(
          returnKeyTypeToString[returnType, default: "return"],
          for: .normal)

    }
  }

  // MARK: private methods for adjusting views, constraints, and colors.

  private func reloadButtonsAndLooks() {
    reloadButtonsToView()
    updateConstraints()
    updateColors()
    updateReturnKeyType()
  }

  private func reloadButtonsToView() {
    for subview in view.subviews {
      subview.removeFromSuperview()
    }
    // Create the buttons
    for row in buttonLayout[mode.rawValue]! {
      var rowOfButtons: [UIView] = []
      for keyname in row {
        if keyname == "spacer_1" || keyname == "spacer_2" {
          let spacer = UIView()
          spacer.translatesAutoresizingMaskIntoConstraints = false
          spacer.accessibilityIdentifier = keyname
          rowOfButtons.append(spacer)
          continue
        }

        let button = KeyboardButton(keyname: keyname)

        // Assign display char
        // Special symbols: ⇧ ⇪  ⌫
        switch keyname {
          case "shift":
            button.setTitle("⇧", for: .normal)
          case "backspace":
            button.setTitle("⌫", for: .normal)
          case "switch":
            button.setImage(UIImage(systemName: "globe"), for: .normal)
          case "return":
            returnButton = button
          default:
            button.setTitle(keyname, for: .normal)
        }

        button.setFontSize(KeyboardSpecs.fontSize(keyname))
        button.sizeToFit()

        switch keyname {
          case "switch":
            button.addTarget(
              controller,
              action: #selector(controller.handleInputModeList(from:with:)),
              for: .allTouchEvents
            )
          case "shift":
            button.addTarget(
              self,
              action: #selector(shiftMutipleTouch(_:event:)),
              for: .touchDownRepeat
            )
            button.addTarget(self, action: #selector(keyTouchUpInside), for: .touchUpInside)
          case "backspace":
            button.addGestureRecognizer(
              UILongPressGestureRecognizer(target: self, action: #selector(backspaceHeld(_:)))
            )
            button.addTarget(self, action: #selector(keyTouchDown), for: .touchDown)
          default:
            button.addTarget(self, action: #selector(keyTouchUpInside), for: .touchUpInside)
        }

        rowOfButtons.append(button)
      }

      let rowStackView = UIStackView(arrangedSubviews: rowOfButtons)
      rowStackView.axis = .horizontal
      rowStackView.spacing = 0
      rowStackView.alignment = .fill

      view.addArrangedSubview(rowStackView)
    }

  }

  private func updateConstraints() {
    // All normal buttons have the same size, so choose one of them and set constraints of
    //  other normal buttons based on that.
    let firstRow = view.arrangedSubviews[0] as! UIStackView
    let buttonWithStandardSize = firstRow.arrangedSubviews[0]

    // Same idea for spacers: spacers of the same row have the same width
    var spacerView: UIView? = nil
    var spacer2View: UIView? = nil

    // Add constraints to buttons
    for rowStackView in view.arrangedSubviews {
      for subView in (rowStackView as! UIStackView).arrangedSubviews {
        let keyname = subView.accessibilityIdentifier!

        guard let button = subView as? KeyboardButton else {
          // It's a spacer UIView
          // spacers of the same row have the same width
          switch keyname {
            case "spacer_1":
              if spacerView == nil {
                spacerView = subView
              }
              subView.widthAnchor.constraint(equalTo: spacerView!.widthAnchor).isActive = true
            case "spacer_2":
              if spacer2View == nil {
                spacer2View = subView
              }
              subView.widthAnchor.constraint(equalTo: spacer2View!.widthAnchor).isActive = true
            default:
              fatalError()
          }
          subView.heightAnchor.constraint(
            equalTo: buttonWithStandardSize.heightAnchor).isActive = true
          continue
        }

        // all buttons have the same height
        button.heightAnchor.constraint(
          equalTo: buttonWithStandardSize.heightAnchor).isActive = true

        // Calculate width of keys
        // Letters = Symbols \ {.,?!'}
        // Spacers_of_row_i = Spacers_of_row_i
        // Space = 5 * Letter + 4 * HorizonalSpacing
        // 123 = ABC = switch = Shift = Backspace = Numbers = #+=
        //     = [(10-5) * Letter + (9-6-2) * HorizontalSpacing] / 4
        //     = 1.25 * Letter + 0.25 * horizontal Spacing
        switch keyname {
          case "123", "ABC", "switch", "shift", "backspace", "#+=", ".", ",", "?", "!", "'":
            button.widthAnchor.constraint(
                equalTo: buttonWithStandardSize.widthAnchor,
                multiplier: 1.25
              ).isActive = true
          case keyname where keyname.count == 1:
            button.widthAnchor.constraint(
              equalTo: buttonWithStandardSize.widthAnchor).isActive = true
          case "space":
            button.widthAnchor.constraint(
              equalTo: buttonWithStandardSize.widthAnchor,
              multiplier: 5
            ).isActive = true
          default:
            break
        }
      }
    }
  }

  private func updateColors() {
    updateColors(darkModeOn: darkMode)
  }

  private func toggleLettersCases(to newState: ShiftState) {
    if shiftState == newState { return }
    NSLog("Letter cases toggled from \(shiftState!) to \(newState)")
    shiftState = newState

    for rowStackView in view.arrangedSubviews {
      for subView in (rowStackView as! UIStackView).arrangedSubviews {
        guard let button = subView as? KeyboardButton else { continue }
        var keyname = button.accessibilityIdentifier!

        switch keyname {
          case "shift":
            switch shiftState {
              case .off:
                button.setBackgroundColor(darkMode ? .darkGray : .lightGray)
                button.setTitleColor(darkMode ? .white : .black, for: [])
                button.setTitle("⇧", for: .normal)
              case .on:
                button.setBackgroundColor(.white)
                button.setTitleColor(.black, for: [])
                button.setTitle("⇧", for: .normal)
              case .locked:
                button.setBackgroundColor(.white)
                button.setTitleColor(.black, for: [])
                button.setTitle("⇪", for: .normal)
              default:
                fatalError()
            }
          case keyname where keyname.isSingleAlphabet:
            keyname = shiftState == .on || shiftState == .locked
              ? keyname.uppercased() : keyname.lowercased()
            button.accessibilityIdentifier = keyname
            button.setTitle(keyname, for: .normal)
          default:
            break
        }
      }
    }
  }

  // MARK: button trigger methods

  @objc private func keyTouchUpInside(_ sender:KeyboardButton) {
    let keyname = sender.accessibilityIdentifier!

    // Clicking any key key while shift is on but not locked toggles shift back to off
    if shiftState == .on && keyname != "shift"{
      toggleLettersCases(to: .off)
      shiftDoubleTapped = false
    }

    switch keyname {
      case "space":
        controller.textDocumentProxy.insertText(" ")
      case "shift":
        if !shiftDoubleTapped {
          switch shiftState {
            case .on:
              toggleLettersCases(to: .off)
            case .off:
              toggleLettersCases(to: .on)
            case .locked:
              toggleLettersCases(to: .off)
            default:
              fatalError()
          }
        }
        shiftDoubleTapped = false
      case "123":
        mode = .numbers
        reloadButtonsAndLooks()
      case "ABC":
        mode = .alphabets
        reloadButtonsAndLooks()
        toggleLettersCases(to: .off)
      case "return":
        let returnKeyType = controller.textDocumentProxy.returnKeyType ?? .default

        switch returnKeyType {
          case .send:
            if !controller.textDocumentProxy.hasText { break }
            controller.cryptoBar.sealAndSend()
          default:
            controller.textDocumentProxy.insertText("\n")
        }
      case "#+=":
        mode = .symbols
        reloadButtonsAndLooks()
      default:
        controller.textDocumentProxy.insertText(keyname)
    }
  }

  @objc private func shiftMutipleTouch(_ sender: KeyboardButton, event: UIEvent) {
    if event.allTouches!.first!.tapCount != 2 { return }
    // Let touchUpInside know that the touch up action this time is from doubletaps
    shiftDoubleTapped = true
    toggleLettersCases(to: .locked)
  }

  @objc private func keyTouchDown(_ sender:KeyboardButton) {
    controller.textDocumentProxy.deleteBackward()
  }

  @objc private func backspaceHeld(_ sender: UIGestureRecognizer) {
    var count = 0
    if sender.state == .began {
      backspaceHeldTimer = Timer.scheduledTimer(
        withTimeInterval: backspaceHeldDeleteInterval, repeats: true) { timer in
        count += 1
        self.controller.textDocumentProxy.deleteBackward()

        // Delete faster
        if count > 10 {
          self.backspaceHeldTimer.invalidate()
          self.backspaceHeldTimer =  Timer.scheduledTimer(
            withTimeInterval: backspaceHeldDeleteInterval * 2, repeats: true) { timer in
            for _ in 0..<20 {
              self.controller.textDocumentProxy.deleteBackward()
            }
          }
        }
      }
    }
    else if sender.state == .ended {
      backspaceHeldTimer.invalidate()
    }
  }
}

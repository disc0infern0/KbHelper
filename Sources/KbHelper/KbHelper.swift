import SwiftUI
import Foundation
#if !os(macOS)
import UIKit
public typealias KbKey = UIKey
public typealias KbKeyCode = UIKeyboardHIDUsage
public typealias KbModifiers = UIKeyModifierFlags  // [.alphaShift,.shift,.control,.alternate,.command,.numericPad ]

#else
import AppKit
public typealias KbKey = NSEvent
// type KbKeyCode defined for macOS below
public typealias KbModifiers = NSEvent.ModifierFlags  // [.capsLock,.shift,.control,.option,.command,.numericPad ]
#endif


#if !os(macOS)
public class KbHelper : UIViewController, ObservableObject {

    public private(set) var text = "Hello, World!"

    var canBecomeFirstReponsder: Bool { return true }
    let focusable:Bool = false
    /// kbCallbacks:
    /// Description: Stores the callback to be invoked when a keyboard combo(keypress and modifier) are recognised
    fileprivate var kbCallbacks : [KbCombo: (KbKey)->Void] = [:]

    /// keyPress:
    /// Description: Combine publisher for matched keypress
    @Published public var keyPress = KbKey()   // dummy initialiser

    /// func pressesBegan
    /// Detect keyboard presses, trigger publisher for registered keyboard presses, and optionally call the callback handler if one was specified.
    /// - Parameters:
    ///   - presses: Set of UIPress. The key member is of main interest, as it contains the character representation (key.characters)
    ///   - event: Ignored except for passing back to super.init if the keypress was not recognised
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?)
    {
        guard let kbPress = presses.first?.key else { return }
        let kbCombo = KbCombo(keyCode: kbPress.keyCode, modifiers: kbPress.modifierFlags)

        //A valid combination will always have a callback entry
        if let callback = kbCallbacks[kbCombo]  {
            keyPress = kbPress  // Set combine publisher
            callback(kbPress)
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        becomeFirstResponder()
    }
}
#else
//macOS
public class KbHelper : NSView, ObservableObject {
    public private(set) var text = "Hello, World!" // For the glorious test suite

    public override var acceptsFirstResponder : Bool { return true }

    /// kbCallbacks:
    /// Description: Stores the callback to be invoked when a keyboard combo(keypress and modifier) are recognised
    fileprivate var kbCallbacks : [KbCombo: (KbKey)->Void] = [:]

    /// keyPress:
    /// Description: Combine publisher for matched keypress
    @Published public var keyPress = KbKey() //undocumented initialiser

    /// func pressesBegan
    /// Detect keyboard presses, trigger publisher for registered keyboard presses, and optionally call the callback handler if one was specified.
    /// - Parameters:
    ///   - presses: Set of UIPress. The key member is of main interest, as it contains the character representation (key.characters)
    ///   - event: Ignored except for passing back to super.init if the keypress was not recognised
    ///
    public override func keyDown(with event: KbKey)
    {
        let found = event.charactersIgnoringModifiers ?? "Nothing in characters"
        print("Keypress found: <\(found)>")
        let keyCode = KbKeyCode(rawValue: event.keyCode) ?? KbKeyCode.empty
        let modifiers = event.modifierFlags
        let kbCombo = KbCombo(keyCode: keyCode, modifiers: modifiers )
        //A valid combination will always have a callback entry
        // since supplying no callback will associate an empty function.
        if let callback = kbCallbacks[kbCombo]  {
            keyPress = event  // Set combine publisher
            callback(event)
        } else {
            print("no match")
            super.keyDown(with: event)
        }
    }

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
        self.becomeFirstResponder()
    }

    override init(frame frameRect: NSRect) {
        fatalError("init(frame:) not implemented")
    }
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func viewDidAppear(_ animated: Bool) {
        becomeFirstResponder()
    }

}
#endif


extension KbHelper {

    /// func register:
    /// Registers keystrokes of interest to the app. Keystrokes that are registered will trigger a publisher event, and optionally a callback, when the keystroke is detected
    /// - Parameters:
    ///   - keystroke: Single character string that is of interest to the invoker
    ///   - callback: Handling function to be called. The function should accept a String parameter which will contain the keypress detected
    ///
    public func kbRegister(_ keyCodes : [KbKeyCode],
                           modifiers: KbModifiers = [],
                           _ callback: @escaping (KbKey) -> Void = {_  in return }) {
        for keyCode in keyCodes {
            print("you registered \(modifiers.description())"+"\(keyCode.description()) ")
            _register(keyCode: keyCode, modifiers: modifiers, callback: callback)
        }
    }
    public func kbRegister(_ arrayinput : [String],
                           _ callback: @escaping (KbKey) -> Void = {_  in return }) {
        for input in  arrayinput {
            self.kbRegister(input,callback)
        }
    }
    public func kbRegister(_ input : String,
                           _ callback: @escaping (KbKey) -> Void = {_  in return }) {
        let (kbModifiers,inputMinusModifiers) = getModifiers(input)
        let kbKeyCode = translate(input:inputMinusModifiers)
        _register(keyCode: kbKeyCode, modifiers: kbModifiers, callback: callback)
    }
    private func _register(keyCode: KbKeyCode, modifiers: KbModifiers, callback: @escaping(KbKey)-> Void) {
        kbCallbacks[KbCombo(keyCode: keyCode, modifiers: modifiers)] = callback
    }

    /// kbCombo
    /// Description:  Store the registered keyboard combinations;- both base character and modifiers.
    struct KbCombo : Hashable { // cannot simply use a tuple to store this pair since the tuple of kbKeyCode and kbModifiers is not hashable for use in a dictionary
        /// The tuple of keyCode and modifiers is a joint key to the callback table.
        var keyCode : KbKeyCode; var modifiers : KbModifiers
        // create unique value for each combination.
        // Since the rawvalues of both KBKeyCode and KBModifiers are on CFIndex, which is based on Int
        // compliance is trivial:
        func hash(into hasher: inout Hasher) {
            hasher.combine(keyCode)
            hasher.combine(modifiers.rawValue)
        }
        func description() -> String   {
            return modifiers.description()+"keyCode.description() " // e.g. <Command><Shift>q  for parameters of .keyboardQ and [.command, .shift]
        }
    }

}


extension KbKey {
    func description() -> String {
        //if self.keyCode.description() != self.characters
        let c = self.charactersIgnoringModifiers ?? (self.characters ?? "")
        return self.modifierFlags.description()+c
    }
}

extension KbKeyCode {
    func description(_ modifiers:KbModifiers=[]) -> String {
        //Sadly there appears to be no built in method for initialising a UIKey from a raw value
        // so here we are.
        // (The UIKey initialiser is undocumented, but appears to be based on NSCoder.. eugh )
        let cfIndex = Int(self.rawValue)
        switch (cfIndex) {
            case 0: return ""               // UIKey().keyCode is initialised with 0. i.e. nothing
            case 4...29 :                   // .keyboarda...z
                //Check if the OptionSet includes either CapsLock or Shift
                //if !(modifiers.intersection([.shift,.alphaShift]).isEmpty) {
                //    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[cfIndex-4]
                //} else {
                    return "abcdefghijklmnopqrstuvwxyz"[cfIndex-4]
                //}
            case 30...38 :                  // .keyboard1...9
                return "\(cfIndex-29)"
            case 39: return "0"             // .keyboard0
            case 41: return "Esc"           // .keyboardEscape
            case 43: return "Tab"           // .keyboardTab
            case 44: return " "             // .keyboardSpacebar
            case 45: return "-"             // .keyboardHyphen
            case 46: return "="             // .keyboardEqualSign
            case 54: return ","             // .keyboardComma
            case 55: return "."             // .keyboardPeriod
            case 56: return "/"             // .keyboardSlash
            case 57: return "CapsLock"      // .keyboardCapsLock
            case 58...69:                   // .keyboardF1..12
                return "F\(cfIndex-57)"
            case 72: return "Pause"         // .keyboardPause
            case 73: return "Insert"        // .keyboardInsert
            case 74: return "Home"          // .keyboardHome
            case 75: return "PageUp"        // .keyboardPageUp
            case 76: return "DeleteForward" // .keyboardDeleteForward
            case 77: return "End"           // .keyboardEnd
            case 78: return "PageDown"      // .keyboardPageDown
            case 79 : return "RightArrow"   // .keyboardRightArrow
            case 80: return "LeftArrow"     // .keyboardLeftArrow
            case 81: return "DownArrow"     // .keyboardDownArrow
            case 82: return "UpArrow"       // .keyboardUpArrow
            case 89...97:                   // .keypad1...9
                return "\(cfIndex-88)"
            case 98:                        // .keypad0 or Insert
                if modifiers.contains(.numericPad) {
                    return "0"
                } else {
                    return "Insert"
                }
            case 104...115:                 // .keyboardF13...F24
                return "F\(cfIndex-91)"
            case 117: return "Help"         // .keyboardHelp
            case 118: return "Menu"         // .keyboardMenu
            case 119: return "Select"       // .keyboardSelect
            case 127: return "Mute"         // .keyboardMute
            case 128: return "VolumeUp"     // .keyboardVolumeUp
            case 129: return "VolumeDown"   // .keyboardVolumeDown
            case 224: return "LeftControl"     // .keyboardLeftControl
            case 225: return "LeftShift"       // .keyboardLeftShift
            case 226: return "LeftOption"      // .keyboardLeftAlt
            case 227: return "LeftCMD"      // .keyboardLeftGUI
            default : return "Undecoded \(cfIndex)"
        }
    }
}

fileprivate extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
/// Allow addition of  ".kb()" to any view, and thus attaching an instance of a keyboard controller
/// This is the only way to instantiate the keyboard controller
public extension View {
    func kb() -> some View {
        @ObservedObject var kb : KbHelper = KbHelper()
        return self.environmentObject(kb).background(kb.asView())
    }
}

#if !os(macOS)
/// Transform the main class, which inherits from UIViewController, into a SwiftUI view
public extension KbHelper {
    struct kbView: UIViewControllerRepresentable {
        var kbHc: KbHelper

        public func makeUIViewController(context: Context) -> KbHelper { kbHc }
        public func updateUIViewController(_ kbHc: KbHelper, context: Context) {  } //No-op
    }
    /// .asView() is a convenience initialiser for the SwiftUI view
    @available(iOS 13, *)
    func asView() -> some View {
        return kbView(kbHc: self)
    }
}
#else
public extension KbHelper {
    struct kbView: NSViewRepresentable {
        var kbHc: KbHelper

        public func makeNSView(context: Context) -> KbHelper { kbHc }
        public func updateNSView(_ kbHc: KbHelper, context: Context) {  } //No-op
    }
    /// .asView() is a convenience initialiser for the SwiftUI view
    @available(iOS 13, *)
    func asView() -> some View {
        return kbView(kbHc: self)
    }
}
#endif

fileprivate func getModifiers(_ input: String) -> (KbModifiers, String) {
    var kbModifiers : KbModifiers = []
    var string = input
#if os(macOS)
    let pairs: [(modifier:String,modcode:KbModifiers)] =  [
        ( "<Command>", .command ),
        ("<Control>",   .control),
        ("<NumLock>",   .numericPad),
        ("<Shift>",     .shift),
        ("<CapsLock>",  .capsLock),
        ("<Option>",    .option) ]
#else
    let pairs: [(modifier:String,modcode:KbModifiers)] =  [
        ( "<Command>", .command ),
        ("<Control>",   .control),
        ("<NumLock>",   .numericPad),
        ("<Shift>",     .shift),
        ("<CapsLock>",  .alphaShift),
        ("<Option>",    .alternate) ]
#endif

    for pair in pairs {
        if string.contains(pair.modifier) {
            kbModifiers.insert(pair.modcode) //add modifier
            string = string.replacingOccurrences(of: pair.modifier, with: "") //strip matches
        }
    }
   // if kbModifiers.contains(.alternate) { print("modifiers contains .alternate")}
    return (kbModifiers, string)
}

fileprivate func translate(input : String) -> KbKeyCode {
    var keyCode : KbKeyCode
    switch (input.uppercased() ) {
        case "A":   keyCode = .keyboardA
        case "B":   keyCode = .keyboardB
        case "C":   keyCode = .keyboardC
        case "D":   keyCode = .keyboardD
        case "E":   keyCode = .keyboardE
        case "F":   keyCode = .keyboardF
        case "G":   keyCode = .keyboardG
        case "H":   keyCode = .keyboardH
        case "I":   keyCode = .keyboardI
        case "J":   keyCode = .keyboardJ
        case "K":   keyCode = .keyboardK
        case "L":   keyCode = .keyboardL
        case "M":   keyCode = .keyboardM
        case "N":   keyCode = .keyboardN
        case "O":   keyCode = .keyboardO
        case "P":   keyCode = .keyboardP
        case "Q":   keyCode = .keyboardQ
        case "R":   keyCode = .keyboardR
        case "S":   keyCode = .keyboardS
        case "T":   keyCode = .keyboardT
        case "U":   keyCode = .keyboardU
        case "V":   keyCode = .keyboardV
        case "W":   keyCode = .keyboardW
        case "X":   keyCode = .keyboardX
        case "Y":   keyCode = .keyboardY
        case "Z":   keyCode = .keyboardZ
        case "0":   keyCode = .keyboard0
        case "1":   keyCode = .keyboard1
        case "2":   keyCode = .keyboard2
        case "3":   keyCode = .keyboard3
        case "4":   keyCode = .keyboard4
        case "5":   keyCode = .keyboard5
        case "6":   keyCode = .keyboard6
        case "7":   keyCode = .keyboard7
        case "8":   keyCode = .keyboard8
        case "9":   keyCode = .keyboard9
        case "F1":  keyCode = .keyboardF1
        case "F2":  keyCode = .keyboardF2
        case "F3":  keyCode = .keyboardF3
        case "F4":  keyCode = .keyboardF4
        case "F5":  keyCode = .keyboardF5
        case "F6":  keyCode = .keyboardF6
        case "F7":  keyCode = .keyboardF7
        case "F8":  keyCode = .keyboardF8
        case "F9":  keyCode = .keyboardF9
        case "F10": keyCode = .keyboardF10
        case "F11": keyCode = .keyboardF11
        case "F12": keyCode = .keyboardF12
        case "F13": keyCode = .keyboardF13
        case "F14": keyCode = .keyboardF14
        case "F15": keyCode = .keyboardF15
        case "F16": keyCode = .keyboardF16
        case "F17": keyCode = .keyboardF17
        case "F18": keyCode = .keyboardF18
        case "F19": keyCode = .keyboardF19
        case "F20": keyCode = .keyboardF20
        case "F21": keyCode = .keyboardF21
        case "F22": keyCode = .keyboardF22
        case "F23": keyCode = .keyboardF23
        case "F24": keyCode = .keyboardF24
        case "Esc": keyCode = .keyboardEscape
        case "Tab": keyCode = .keyboardTab
        case " "  : keyCode = .keyboardSpacebar
        case "-"  : keyCode = .keyboardHyphen
        case "="  : keyCode = .keyboardEqualSign
        case ","  : keyCode = .keyboardComma
        case "."  : keyCode = .keyboardPeriod
        case "/"  : keyCode = .keyboardSlash
        case "CapsLock"      : keyCode = .keyboardCapsLock
        case "Pause"         : keyCode = .keyboardPause
        case "Insert"        : keyCode = .keyboardInsert
        case "Home"          : keyCode = .keyboardHome
        case "PageUp"        : keyCode = .keyboardPageUp
        case "DeleteForward" : keyCode = .keyboardDeleteForward
        case "End"           : keyCode = .keyboardEnd
        case "PageDown"      : keyCode = .keyboardPageDown
        case "RightArrow"    : keyCode = .keyboardRightArrow
        case "LeftArrow"     : keyCode = .keyboardLeftArrow
        case "DownArrow"     : keyCode = .keyboardDownArrow
        case "UpArrow"       : keyCode = .keyboardUpArrow
        case "Help"          : keyCode = .keyboardHelp
        case "Menu"          : keyCode = .keyboardMenu
        case "Select"        : keyCode = .keyboardSelect
        case "Mute"          : keyCode = .keyboardMute
        case "VolumeUp"      : keyCode = .keyboardVolumeUp
        case "VolumeDown"    : keyCode = .keyboardVolumeDown
        case "LeftControl"   : keyCode = .keyboardLeftControl
        case "LeftShift"     : keyCode = .keyboardLeftShift
        case "LeftOption"    : keyCode = KbKeyCode(rawValue: 226)! //.keyboardLeftOption
        case "LeftCommand"   : keyCode = KbKeyCode(rawValue: 227)! //.keyboardLeftCMD
        default :
            fatalError("\(input) not recongnised")
    }
    return keyCode
}


public extension KbModifiers {
    /// - Returns: String version of the modifiers contained in self. e.g. "<Option><Shift>"
    func description() -> String {
        var modString : String = ""
#if os(macOS)
        let caps:Bool = self.contains(.capsLock)
        let opt:Bool  = self.contains(.option)
#else
        let caps:Bool = self.contains(.alphaShift)
        let opt:Bool  = self.contains(.alternate)
#endif
        if caps == true {modString += "<CapsLock>"}
        if opt == true { modString += "<Option>"}
        if self.contains(.command)  { modString += "<Command>"}
        if self.contains(.control)  { modString += "<Control>"}
        if self.contains(.numericPad){modString += "<NumLock>"}
        if self.contains(.shift)    { modString += "<Shift>"}
        return modString
    }
}

#if os(macOS)
public enum KbKeyCode : UInt16, Hashable {

    case empty = 0
    case keyboardErrorRollOver = 1 /* ErrorRollOver */
    case keyboardPOSTFail = 2 /* POSTFail */
    case keyboardErrorUndefined = 3 /* ErrorUndefined */

    // Letters
    case keyboardA = 4 /* a or A */
    case keyboardB = 5 /* b or B */
    case keyboardC = 6 /* c or C */
    case keyboardD = 7 /* d or D */
    case keyboardE = 8 /* e or E */
    case keyboardF = 9 /* f or F */
    case keyboardG = 10 /* g or G */
    case keyboardH = 11 /* h or H */
    case keyboardI = 12 /* i or I */
    case keyboardJ = 13 /* j or J */
    case keyboardK = 14 /* k or K */
    case keyboardL = 15 /* l or L */
    case keyboardM = 16 /* m or M */
    case keyboardN = 17 /* n or N */
    case keyboardO = 18 /* o or O */
    case keyboardP = 19 /* p or P */
    case keyboardQ = 20 /* q or Q */
    case keyboardR = 21 /* r or R */
    case keyboardS = 22 /* s or S */
    case keyboardT = 23 /* t or T */
    case keyboardU = 24 /* u or U */
    case keyboardV = 25 /* v or V */
    case keyboardW = 26 /* w or W */
    case keyboardX = 27 /* x or X */
    case keyboardY = 28 /* y or Y */
    case keyboardZ = 29 /* z or Z */

    // Numbers
    case keyboard1 = 30 /* 1 or ! */
    case keyboard2 = 31 /* 2 or @ */
    case keyboard3 = 32 /* 3 or # */
    case keyboard4 = 33 /* 4 or $ */
    case keyboard5 = 34 /* 5 or % */
    case keyboard6 = 35 /* 6 or ^ */
    case keyboard7 = 36 /* 7 or & */
    case keyboard8 = 37 /* 8 or * */
    case keyboard9 = 38 /* 9 or ( */
    case keyboard0 = 39 /* 0 or ) */

    // Misc
    case keyboardReturnOrEnter      = 40 /* Return (Enter) */
    case keyboardEscape             = 41 /* Escape */
    case keyboardDeleteOrBackspace  = 42 /* Delete (Backspace) */
    case keyboardTab                = 43 /* Tab */
    case keyboardSpacebar           = 44 /* Spacebar */
    case keyboardHyphen             = 45 /* - or _ */
    case keyboardEqualSign          = 46 /* = or + */
    case keyboardOpenBracket        = 47 /* [ or { */
    case keyboardCloseBracket       = 48 /* ] or } */
    case keyboardBackslash          = 49 /* \ or | */
    case keyboardNonUSPound         = 50 /* Non-US # or _ */

    /* Typical language mappings: US: \| Belg: μ`£ FrCa: <}> Dan:’* Dutch: <> Fren:*μ
     Ger: #’ Ital: ù§ LatAm: }`] Nor:,* Span: }Ç Swed: ,*
     Swiss: $£ UK: #~. */
    case keyboardSemicolon           = 51 /* ; or : */
    case keyboardQuote               = 52 /* ' or " */
    case keyboardGraveAccentAndTilde = 53 /* Grave Accent and Tilde */
    case keyboardComma               = 54 /* , or < */
    case keyboardPeriod              = 55 /* . or > */
    case keyboardSlash               = 56 /* / or ? */

    case keyboardCapsLock = 57 /* Caps Lock ***************/
    case keypadNumLock = 83 /* Keypad NumLock or Clear ***********/


    /* Function keys */
    case keyboardF1  = 58 /* F1 */
    case keyboardF2  = 59 /* F2 */
    case keyboardF3  = 60 /* F3 */
    case keyboardF4  = 61 /* F4 */
    case keyboardF5  = 62 /* F5 */
    case keyboardF6  = 63 /* F6 */
    case keyboardF7  = 64 /* F7 */
    case keyboardF8  = 65 /* F8 */
    case keyboardF9  = 66 /* F9 */
    case keyboardF10 = 67 /* F10 */
    case keyboardF11 = 68 /* F11 */
    case keyboardF12 = 69 /* F12 */

    // Misc
    case keyboardPrintScreen   = 70 /* Print Screen */
    case keyboardScrollLock    = 71 /* Scroll Lock */
    case keyboardPause         = 72 /* Pause */
    case keyboardInsert        = 73 /* Insert */
    case keyboardHome          = 74 /* Home */
    case keyboardPageUp        = 75 /* Page Up */
    case keyboardDeleteForward = 76 /* Delete Forward */
    case keyboardEnd           = 77 /* End */
    case keyboardPageDown      = 78 /* Page Down */

    // Arrow keys
    case keyboardRightArrow = 79 /* Right Arrow */
    case keyboardLeftArrow  = 80 /* Left Arrow */
    case keyboardDownArrow  = 81 /* Down Arrow */
    case keyboardUpArrow    = 82 /* Up Arrow */

    /* Keypad (numpad) keys */
    //case keypadNumLock = 83 /* Keypad NumLock or Clear ***********/

    case keypadSlash    = 84 /* Keypad / */
    case keypadAsterisk = 85 /* Keypad * */
    case keypadHyphen   = 86 /* Keypad - */
    case keypadPlus     = 87 /* Keypad + */
    case keypadEnter    = 88 /* Keypad Enter */
    case keypad1        = 89 /* Keypad 1 or End */
    case keypad2        = 90 /* Keypad 2 or Down Arrow */
    case keypad3        = 91 /* Keypad 3 or Page Down */
    case keypad4        = 92 /* Keypad 4 or Left Arrow */
    case keypad5        = 93 /* Keypad 5 */
    case keypad6        = 94 /* Keypad 6 or Right Arrow */
    case keypad7        = 95 /* Keypad 7 or Home */
    case keypad8        = 96 /* Keypad 8 or Up Arrow */
    case keypad9        = 97 /* Keypad 9 or Page Up */
    case keypad0        = 98 /* Keypad 0 or Insert */
    case keypadPeriod   = 99 /* Keypad . or Delete */
    case keypadComma    = 133 /* Keypad Comma */
    case keypadEqualSignAS400 = 134 /* Keypad Equal Sign for AS/400 */

    // Misc
    case keyboardNonUSBackslash = 100 /* Non-US \ or | */

    /* On Apple ISO keyboards, this is the section symbol (§/±) */
    /* Typical language mappings: Belg:<\> FrCa:«°» Dan:<\> Dutch:]|[ Fren:<> Ger:<|>
     Ital:<> LatAm:<> Nor:<> Span:<> Swed:<|> Swiss:<\>
     UK:\| Brazil: \|. */
    case keyboardApplication = 101 /* Application */
    case keyboardPower       = 102 /* Power */
    case keypadEqualSign     = 103 /* Keypad = */

    /* Additional keys */
    case keyboardF13 = 104 /* F13 */
    case keyboardF14 = 105 /* F14 */
    case keyboardF15 = 106 /* F15 */
    case keyboardF16 = 107 /* F16 */
    case keyboardF17 = 108 /* F17 */
    case keyboardF18 = 109 /* F18 */
    case keyboardF19 = 110 /* F19 */
    case keyboardF20 = 111 /* F20 */
    case keyboardF21 = 112 /* F21 */
    case keyboardF22 = 113 /* F22 */
    case keyboardF23 = 114 /* F23 */
    case keyboardF24 = 115 /* F24 */

    // Misc
    case keyboardExecute    = 116 /* Execute */
    case keyboardHelp       = 117 /* Help */
    case keyboardMenu       = 118 /* Menu */
    case keyboardSelect     = 119 /* Select */
    case keyboardStop       = 120 /* Stop */
    case keyboardAgain      = 121 /* Again */
    case keyboardUndo       = 122 /* Undo */
    case keyboardCut        = 123 /* Cut */
    case keyboardCopy       = 124 /* Copy */
    case keyboardPaste      = 125 /* Paste */
    case keyboardFind       = 126 /* Find */
    case keyboardMute       = 127 /* Mute */
    case keyboardVolumeUp   = 128 /* Volume Up */
    case keyboardVolumeDown = 129 /* Volume Down */


    case keyboardLockingCapsLock = 130 /* Locking Caps Lock */
    case keyboardLockingNumLock  = 131 /* Locking Num Lock */

    /* Implemented as a locking key; sent as a toggle button. Available for legacy support;
     however, most systems should use the non-locking version of this key. */
    case keyboardLockingScrollLock = 132 /* Locking Scroll Lock */

    // case keypadComma = 133 /* Keypad Comma */
    // case keypadEqualSignAS400 = 134 /* Keypad Equal Sign for AS/400 */

    /* See the footnotes in the USB specification for what keys these are commonly mapped to.
     * https://www.usb.org/sites/default/files/documents/hut1_12v2.pdf */
    case keyboardro                 = 135 /* International1 */
    case keyboardkatakanahiragana   = 136 /* International2 */
    case keyboardyen = 137 /* International3 */
    case keyboardhenkan = 138 /* International4 */
    case keyboardmuhenkan = 139 /* International5 */
    case keyboardkpjpcomma = 140 /* International6 */
    case keyboardhangeul = 141 /* International7 */
    case keyboardhanja = 142 /* International8 */
    case keyboardkatakana = 143 /* International9 */

    /* LANG1: On Apple keyboard for Japanese, this is the kana switch (かな) key */
    /* On Korean keyboards, this is the Hangul/English toggle key. */
    case keyboardhiragana = 144 /* LANG1 */

    /* LANG2: On Apple keyboards for Japanese, this is the alphanumeric (英数) key */
    /* On Korean keyboards, this is the Hanja conversion key. */
    case keyboardzenkakuhankaku = 145 /* LANG2 */

    /* LANG3: Defines the Katakana key for Japanese USB word-processing keyboards. */
    case keyboardLANG3 = 146 /* LANG3 */

    /* LANG4: Defines the Hiragana key for Japanese USB word-processing keyboards. */
    case keyboardLANG4 = 147 /* LANG4 */

    /* LANG5: Defines the Zenkaku/Hankaku key for Japanese USB word-processing keyboards. */
    case keyboardLANG5 = 148 /* LANG5 */

    /* LANG6-9: Reserved for language-specific functions, such as Front End Processors and Input Method Editors. */
    case keyboardLANG6 = 149 /* LANG6 */
    case keyboardLANG7 = 150 /* LANG7 */
    case keyboardLANG8 = 151 /* LANG8 */
    case keyboardLANG9 = 152 /* LANG9 */

    case keyboardAlternateErase     = 153 /* AlternateErase */
    case keyboardSysReqOrAttention  = 154 /* SysReq/Attention */
    case keyboardCancel             = 155 /* Cancel */
    case keyboardClear              = 156 /* Clear */
    case keyboardPrior              = 157 /* Prior */
    case keyboardReturn             = 158 /* Return */
    case keyboardSeparator          = 159 /* Separator */
    case keyboardOut                = 160 /* Out */
    case keyboardOper               = 161 /* Oper */
    case keyboardClearOrAgain       = 162 /* Clear/Again */
    case keyboardCrSelOrProps       = 163 /* CrSel/Props */
    case keyboardExSel              = 164 /* ExSel */

    /* 165-223: Reserved */

    // Keyboard Modifiers
    case keyboardLeftControl  = 224 /* Left Control */
    case keyboardLeftShift    = 225 /* Left Shift */
    case keyboardLeftOption   = 226 /* Left Alt */
    case keyboardLeftCMD      = 227 /* Left GUI */
    case keyboardRightControl = 228 /* Right Control */
    case keyboardRightShift   = 229 /* Right Shift */
    case keyboardRightOption  = 230 /* Right Alt */
    case keyboardRightCMD     = 231 /* Right GUI */

    case media_playpause    = 232
    case media_stopcd       = 233
    case media_previoussong = 234
    case media_nextsong     = 235
    case media_ejectcd      = 236
    case media_volumeup     = 237
    case media_volumedown   = 238
    case media_mute         = 239
    case media_www          = 240
    case media_back         = 241
    case media_forward      = 242
    case media_stop         = 243
    case media_find         = 244
    case media_scrollup     = 245
    case media_scrolldown   = 246
    case media_edit         = 247
    case media_sleep        = 248
    case media_coffee       = 249
    case media_refresh      = 250
    case media_calc         = 251
}
#endif

extension KbKeyCode {
    static let functionKeys: Set<Self> = [
        .keyboardF1,
        .keyboardF2,
        .keyboardF3,
        .keyboardF4,
        .keyboardF5,
        .keyboardF6,
        .keyboardF7,
        .keyboardF8,
        .keyboardF9,
        .keyboardF10,
        .keyboardF11,
        .keyboardF12,
        .keyboardF13,
        .keyboardF14,
        .keyboardF15,
        .keyboardF16,
        .keyboardF17,
        .keyboardF18,
        .keyboardF19,
        .keyboardF20,
        .keyboardF21,
        .keyboardF22,
        .keyboardF23,
        .keyboardF24
    ]

    /// Returns true if the key is a function key. For example, `F1`.
    var isFunctionKey: Bool { Self.functionKeys.contains(self) }

}

/*

 // Punctuation
 public static let enter = Self(0x28)
 public static let esc = Self(0x29)
 public static let backspace = Self(0x2a)
 public static let tab = Self(0x2b)
 public static let space = Self(0x2c)
 public static let minus = Self(0x2d)
 public static let equal = Self(0x2e)
 public static let leftbrace = Self(0x2f)
 public static let rightbrace = Self(0x30)
 public static let backslash = Self(0x31)
 public static let hashtilde = Self(0x32)
 public static let semicolon = Self(0x33)
 public static let apostrophe = Self(0x34)
 public static let grave = Self(0x35)
 public static let comma = Self(0x36)
 public static let dot = Self(0x37)
 public static let slash = Self(0x38)

 // Misc
 //public static let 102nd = Self(0x64)
 public static let compose = Self(0x65)
 public static let power = Self(0x66)

 // Oddments
 public static let stop = Self(0x78)
 public static let mute = Self(0x7f)
 public static let volumeup = Self(0x80)
 public static let volumedown = Self(0x81)
 public static let open = Self(0x74)
 public static let help = Self(0x75)
 public static let props = Self(0x76)
 public static let front = Self(0x77)
 public static let undo = Self(0x7a)
 public static let cut = Self(0x7b)
 public static let copy = Self(0x7c)
 public static let paste = Self(0x7d)
 public static let find = Self(0x7e)
*/

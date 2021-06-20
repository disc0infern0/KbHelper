import SwiftUI


#if !os(macOS)
final class KbHelper : UIViewController, ObservableObject {

    public private(set) var text = "Hello, World!"

    var canBecomeFirstReponsder: Bool { return true }
    let focusable:Bool = false
    /// kbCallbacks:
    /// Description: Stores the callback to be invoked when a keyboard combo(keypress and modifier) are recognised
    fileprivate var kbCallbacks : [KbCombo: (KbKey)->Void] = [:]

    /// keyPress:
    /// Description: Combine publisher for matched keypress
    @Published var keyPress = KbKey() //? //= UIKey() //undocumented initialiser

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
final class KbHelper : NSViewController, ObservableObject {
    public private(set) var text = "Hello, World!" // For the glorious test suite

    var acceptsFirstReponsder: Bool { return true }
    let focusable:Bool = false

    /// kbCallbacks:
    /// Description: Stores the callback to be invoked when a keyboard combo(keypress and modifier) are recognised
    fileprivate var kbCallbacks : [KbCombo: (KbKey)->Void] = [:]

    /// keyPress:
    /// Description: Combine publisher for matched keypress
    @Published var keyPress = KbKey() //? //= UIKey() //undocumented initialiser

    /// func pressesBegan
    /// Detect keyboard presses, trigger publisher for registered keyboard presses, and optionally call the callback handler if one was specified.
    /// - Parameters:
    ///   - presses: Set of UIPress. The key member is of main interest, as it contains the character representation (key.characters)
    ///   - event: Ignored except for passing back to super.init if the keypress was not recognised
    ///
    override func keyDown(with event: KbKey)
    {
        let keyCode = KbKeyCode(rawValue: event.keyCode) ?? KbKeyCode.empty
        let modifiers = event.modifierFlags
        let kbCombo = KbCombo(keyCode: keyCode, modifiers: modifiers )
        //A valid combination will always have a callback entry
        if let callback = kbCallbacks[kbCombo]  {
            keyPress = event  // Set combine publisher
            callback(event)
        }
    }
    //override func flagsChanged(with event: NSEvent) {
     //   modifierCode = event.keyCode
    //}

    init() { //nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
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
    func kbRegister(_ keyCodes : [KbKeyCode],
                           modifiers: KbModifiers = [],
                           _ callback: @escaping (KbKey) -> Void = {_  in return }) {
        for keyCode in keyCodes {
            print("you registered \(modifiers.description())"+"(keyCode.description()) ")
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
    //
//}

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
        @ObservedObject var kb = KbHelper()
        return self.environmentObject(kb).background(kb.asView())
    }
}

#if !os(macOS)
/// Transform the main class, which inherits from UIViewController, into a SwiftUI view
fileprivate extension KbHelper {
    @available(iOS 13, *)
    private struct kbView: UIViewControllerRepresentable {
        var kbHc: KbHelper

        func makeUIViewController(context: Context) -> KbHelper { kbHc }
        func updateUIViewController(_ kbHc: KbHelper, context: Context) {  } //No-op
    }
    /// .asView() is a convenience initialiser for the SwiftUI view
    @available(iOS 13, *)
    func asView() -> some View {
        return kbView(kbHc: self)
    }
}
#else
fileprivate extension KbHelper {
    @available(iOS 13, *)
    private struct kbView: NSViewControllerRepresentable {
        typealias NSViewControllerType = KbHelper

        var kbHc: KbHelper

        func makeNSViewController(context: Context) -> KbHelper { kbHc }
        func updateNSViewController(_ kbHc: KbHelper, context: Context) {  } //No-op
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
        case "0":    keyCode = .keyboard0
        case "1":    keyCode = .keyboard1
        case "2":    keyCode = .keyboard2
        case "3":    keyCode = .keyboard3
        case "4":    keyCode = .keyboard4
        case "5":    keyCode = .keyboard5
        case "6":    keyCode = .keyboard6
        case "7":    keyCode = .keyboard7
        case "8":    keyCode = .keyboard8
        case "9":    keyCode = .keyboard9
        case "F1":    keyCode = .keyboardF1
        case "F2":    keyCode = .keyboardF2
        case "F3":    keyCode = .keyboardF3
        case "F4":    keyCode = .keyboardF4
        case "F5":    keyCode = .keyboardF5
        case "F6":    keyCode = .keyboardF6
        case "F7":    keyCode = .keyboardF7
        case "F8":    keyCode = .keyboardF8
        case "F9":    keyCode = .keyboardF9
        case "F10":   keyCode = .keyboardF10
        case "F11":   keyCode = .keyboardF11
        case "F12":   keyCode = .keyboardF12
        case "F13":   keyCode = .keyboardF13
        case "F14":   keyCode = .keyboardF14
        case "F15":   keyCode = .keyboardF15
        case "F16":   keyCode = .keyboardF16
        case "F17":   keyCode = .keyboardF17
        case "F18":   keyCode = .keyboardF18
        case "F19":   keyCode = .keyboardF19
        case "F20":   keyCode = .keyboardF20
        case "Esc"           : keyCode = .keyboardEscape
        case "Tab"           : keyCode = .keyboardTab
        case " "             : keyCode = .keyboardSpacebar
        case "-"             : keyCode = .keyboardHyphen
        case "="             : keyCode = .keyboardEqualSign
        case ","             : keyCode = .keyboardComma
        case "."             : keyCode = .keyboardPeriod
        case "/"             : keyCode = .keyboardSlash
        case "CapsLock"      : keyCode = .keyboardCapsLock
        case "Pause"         : keyCode = .keyboardPause
        case "Insert"        : keyCode = .keyboardInsert
        case "Home"          : keyCode = .keyboardHome
        case "PageUp"        : keyCode = .keyboardPageUp
        case "DeleteForward" : keyCode = .keyboardDeleteForward
        case "End"           : keyCode = .keyboardEnd
        case "PageDown"      : keyCode = .keyboardPageDown
        case "RightArrow"   : keyCode = .keyboardRightArrow
        case "LeftArrow"     : keyCode = .keyboardLeftArrow
        case "DownArrow"     : keyCode = .keyboardDownArrow
        case "UpArrow"       : keyCode = .keyboardUpArrow
        case "Help"         : keyCode = .keyboardHelp
        case "Menu"         : keyCode = .keyboardMenu
        case "Select"       : keyCode = .keyboardSelect
        case "Mute"         : keyCode = .keyboardMute
        case "VolumeUp"     : keyCode = .keyboardVolumeUp
        case "VolumeDown"   : keyCode = .keyboardVolumeDown
        case "LeftControl"  : keyCode = .keyboardLeftControl
        case "LeftShift"    : keyCode = .keyboardLeftShift
        case "LeftOption"   : keyCode = KbKeyCode(rawValue: 226)! // LeftOption
        case "LeftCommand"  : keyCode = KbKeyCode(rawValue: 227)! //.keyboardLeftCMD
        default :
            fatalError("\(input) not recongnised")
    }
    return keyCode
}

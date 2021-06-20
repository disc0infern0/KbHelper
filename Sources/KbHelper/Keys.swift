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
    case keyboardReturnOrEnter = 40 /* Return (Enter) */
    case keyboardEscape = 41 /* Escape */
    case keyboardDeleteOrBackspace = 42 /* Delete (Backspace) */
    case keyboardTab = 43 /* Tab */
    case keyboardSpacebar = 44 /* Spacebar */
    case keyboardHyphen = 45 /* - or _ */
    case keyboardEqualSign = 46 /* = or + */
    case keyboardOpenBracket = 47 /* [ or { */
    case keyboardCloseBracket = 48 /* ] or } */
    case keyboardBackslash = 49 /* \ or | */
    case keyboardNonUSPound = 50 /* Non-US # or _ */

    /* Typical language mappings: US: \| Belg: μ`£ FrCa: <}> Dan:’* Dutch: <> Fren:*μ
     Ger: #’ Ital: ù§ LatAm: }`] Nor:,* Span: }Ç Swed: ,*
     Swiss: $£ UK: #~. */
    case keyboardSemicolon = 51 /* ; or : */
    case keyboardQuote = 52 /* ' or " */
    case keyboardGraveAccentAndTilde = 53 /* Grave Accent and Tilde */
    case keyboardComma = 54 /* , or < */
    case keyboardPeriod = 55 /* . or > */
    case keyboardSlash = 56 /* / or ? */

    case keyboardCapsLock = 57 /* Caps Lock ***************/
    case keypadNumLock = 83 /* Keypad NumLock or Clear ***********/


    /* Function keys */
    case keyboardF1 = 58 /* F1 */
    case keyboardF2 = 59 /* F2 */
    case keyboardF3 = 60 /* F3 */
    case keyboardF4 = 61 /* F4 */
    case keyboardF5 = 62 /* F5 */
    case keyboardF6 = 63 /* F6 */
    case keyboardF7 = 64 /* F7 */
    case keyboardF8 = 65 /* F8 */
    case keyboardF9 = 66 /* F9 */
    case keyboardF10 = 67 /* F10 */
    case keyboardF11 = 68 /* F11 */
    case keyboardF12 = 69 /* F12 */

    // Misc
    case keyboardPrintScreen = 70 /* Print Screen */
    case keyboardScrollLock = 71 /* Scroll Lock */
    case keyboardPause = 72 /* Pause */
    case keyboardInsert = 73 /* Insert */
    case keyboardHome = 74 /* Home */
    case keyboardPageUp = 75 /* Page Up */
    case keyboardDeleteForward = 76 /* Delete Forward */
    case keyboardEnd = 77 /* End */
    case keyboardPageDown = 78 /* Page Down */

    // Arrow keys
    case keyboardRightArrow = 79 /* Right Arrow */
    case keyboardLeftArrow = 80 /* Left Arrow */
    case keyboardDownArrow = 81 /* Down Arrow */
    case keyboardUpArrow = 82 /* Up Arrow */

    /* Keypad (numpad) keys */
    //case keypadNumLock = 83 /* Keypad NumLock or Clear ***********/

    case keypadSlash = 84 /* Keypad / */
    case keypadAsterisk = 85 /* Keypad * */
    case keypadHyphen = 86 /* Keypad - */
    case keypadPlus = 87 /* Keypad + */
    case keypadEnter = 88 /* Keypad Enter */
    case keypad1 = 89 /* Keypad 1 or End */
    case keypad2 = 90 /* Keypad 2 or Down Arrow */
    case keypad3 = 91 /* Keypad 3 or Page Down */
    case keypad4 = 92 /* Keypad 4 or Left Arrow */
    case keypad5 = 93 /* Keypad 5 */
    case keypad6 = 94 /* Keypad 6 or Right Arrow */
    case keypad7 = 95 /* Keypad 7 or Home */
    case keypad8 = 96 /* Keypad 8 or Up Arrow */
    case keypad9 = 97 /* Keypad 9 or Page Up */
    case keypad0 = 98 /* Keypad 0 or Insert */
    case keypadPeriod = 99 /* Keypad . or Delete */

    // Misc
    case keyboardNonUSBackslash = 100 /* Non-US \ or | */

    /* On Apple ISO keyboards, this is the section symbol (§/±) */
    /* Typical language mappings: Belg:<\> FrCa:«°» Dan:<\> Dutch:]|[ Fren:<> Ger:<|>
     Ital:<> LatAm:<> Nor:<> Span:<> Swed:<|> Swiss:<\>
     UK:\| Brazil: \|. */
    case keyboardApplication = 101 /* Application */
    case keyboardPower = 102 /* Power */
    case keypadEqualSign = 103 /* Keypad = */

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
    case keyboardExecute = 116 /* Execute */
    case keyboardHelp = 117 /* Help */
    case keyboardMenu = 118 /* Menu */
    case keyboardSelect = 119 /* Select */
    case keyboardStop = 120 /* Stop */
    case keyboardAgain = 121 /* Again */
    case keyboardUndo = 122 /* Undo */
    case keyboardCut = 123 /* Cut */
    case keyboardCopy = 124 /* Copy */
    case keyboardPaste = 125 /* Paste */
    case keyboardFind = 126 /* Find */
    case keyboardMute = 127 /* Mute */
    case keyboardVolumeUp = 128 /* Volume Up */
    case keyboardVolumeDown = 129 /* Volume Down */


    case keyboardLockingCapsLock = 130 /* Locking Caps Lock */

    case keyboardLockingNumLock = 131 /* Locking Num Lock */

    /* Implemented as a locking key; sent as a toggle button. Available for legacy support;
     however, most systems should use the non-locking version of this key. */
    case keyboardLockingScrollLock = 132 /* Locking Scroll Lock */

    case keypadComma = 133 /* Keypad Comma */

    case keypadEqualSignAS400 = 134 /* Keypad Equal Sign for AS/400 */


    /* See the footnotes in the USB specification for what keys these are commonly mapped to.
     * https://www.usb.org/sites/default/files/documents/hut1_12v2.pdf */
    case keyboardInternational1 = 135 /* International1 */
    case keyboardInternational2 = 136 /* International2 */
    case keyboardInternational3 = 137 /* International3 */
    case keyboardInternational4 = 138 /* International4 */
    case keyboardInternational5 = 139 /* International5 */
    case keyboardInternational6 = 140 /* International6 */
    case keyboardInternational7 = 141 /* International7 */
    case keyboardInternational8 = 142 /* International8 */
    case keyboardInternational9 = 143 /* International9 */

    /* LANG1: On Apple keyboard for Japanese, this is the kana switch (かな) key */
    /* On Korean keyboards, this is the Hangul/English toggle key. */
    case keyboardLANG1 = 144 /* LANG1 */

    /* LANG2: On Apple keyboards for Japanese, this is the alphanumeric (英数) key */
    /* On Korean keyboards, this is the Hanja conversion key. */
    case keyboardLANG2 = 145 /* LANG2 */


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

    case keyboardAlternateErase = 153 /* AlternateErase */
    case keyboardSysReqOrAttention = 154 /* SysReq/Attention */
    case keyboardCancel = 155 /* Cancel */
    case keyboardClear = 156 /* Clear */
    case keyboardPrior = 157 /* Prior */
    case keyboardReturn = 158 /* Return */
    case keyboardSeparator = 159 /* Separator */
    case keyboardOut = 160 /* Out */
    case keyboardOper = 161 /* Oper */
    case keyboardClearOrAgain = 162 /* Clear/Again */
    case keyboardCrSelOrProps = 163 /* CrSel/Props */
    case keyboardExSel = 164 /* ExSel */

    /* 0xA5-0xDF: Reserved */

    case keyboardLeftControl = 224 /* Left Control */
    case keyboardLeftShift = 225 /* Left Shift */
    case keyboardLeftOption = 226 /* Left Alt */
    case keyboardLeftCMD = 227 /* Left GUI */
    case keyboardRightControl = 228 /* Right Control */
    case keyboardRightShift = 229 /* Right Shift */
    case keyboardRightOption = 230 /* Right Alt */
    case keyboardRightCMD = 231 /* Right GUI */

    case media_playpause = 0xE8 //232
    case media_stopcd = 0xE9
    case media_previoussong = 0xEA
    case media_nextsong = 0xEB
    case media_ejectcd = 0xEC
    case media_volumeup = 0xED
    case media_volumedown = 0xEE
    case media_mute = 0xEF
    case media_www = 0xF0
    case media_back = 0xF1
    case media_forward = 0xF2
    case media_stop = 0xF3
    case media_find = 0xF4
    case media_scrollup = 0xF5
    case media_scrolldown = 0xF6
    case media_edit = 0xF7
    case media_sleep = 0xF8
    case media_coffee = 0xF9
    case media_refresh = 0xFA
    case media_calc = 0xFB //251

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
#endif

/*
struct KeyCode : Hashable {

    let rawValue : Int

    private init(_ value : Int) {
        rawValue = value
    }

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    // Letters
    public static let a = Self(0x04)
    public static let b = Self(0x05)
    public static let c = Self(0x06)
    public static let d = Self(0x07)
    public static let e = Self(0x08)
    public static let f = Self(0x09)
    public static let g = Self(0x0a)
    public static let h = Self(0x0b)
    public static let i = Self(0x0c)
    public static let j = Self(0x0d)
    public static let k = Self(0x0e)
    public static let l = Self(0x0f)
    public static let m = Self(0x10)
    public static let n = Self(0x11)
    public static let o = Self(0x12)
    public static let p = Self(0x13)
    public static let q = Self(0x14)
    public static let r = Self(0x15)
    public static let s = Self(0x16)
    public static let t = Self(0x17)
    public static let u = Self(0x18)
    public static let v = Self(0x19)
    public static let w = Self(0x1a)
    public static let x = Self(0x1b)
    public static let y = Self(0x1c)
    public static let z = Self(0x1d)

    // Arrow keys
    public static let arrowRight = Self(0x4f)
    public static let arrowLeft = Self(0x50)
    public static let arrowDown = Self(0x51)
    public static let arrowUp = Self(0x52)

    // Numbers
    public static let one = Self(0x1e)
    public static let two = Self(0x1f)
    public static let three = Self(0x20)
    public static let four = Self(0x21)
    public static let five = Self(0x22)
    public static let six = Self(0x23)
    public static let seven = Self(0x24)
    public static let eight = Self(0x25)
    public static let nine = Self(0x26)
    public static let zero = Self(0x27)

    //Modifiers
    public static let capslock = Self(0x39)
    public static let numlock = Self(0x53)

    public static let ctrlleft = Self(0xe0)
    public static let shiftleft = Self(0xe1)
    public static let optionleft = Self(0xe2)
    public static let commandleft = Self(0xe3)
    public static let ctrlright = Self(0xe4)
    public static let shiftright = Self(0xe5)
    public static let optionright = Self(0xe6)
    public static let commandright = Self(0xe7)


    // Function keys
    public static let f1 = Self(0x3a)
    public static let f2 = Self(0x3b)
    public static let f3 = Self(0x3c)
    public static let f4 = Self(0x3d)
    public static let f5 = Self(0x3e)
    public static let f6 = Self(0x3f)
    public static let f7 = Self(0x40)
    public static let f8 = Self(0x41)
    public static let f9 = Self(0x42)
    public static let f10 = Self(0x43)
    public static let f11 = Self(0x44)
    public static let f12 = Self(0x45)
    public static let f13 = Self(0x68)
    public static let f14 = Self(0x69)
    public static let f15 = Self(0x6a)
    public static let f16 = Self(0x6b)
    public static let f17 = Self(0x6c)
    public static let f18 = Self(0x6d)
    public static let f19 = Self(0x6e)
    public static let f20 = Self(0x6f)
    public static let f21 = Self(0x70)
    public static let f22 = Self(0x71)
    public static let f23 = Self(0x72)
    public static let f24 = Self(0x73)

    // Insert/Delete/PageDown etc
    public static let sysrq = Self(0x46)
    public static let scrolllock = Self(0x47)
    public static let pause = Self(0x48)
    public static let insert = Self(0x49)
    public static let home = Self(0x4a)
    public static let pageup = Self(0x4b)
    public static let delete = Self(0x4c)
    public static let end = Self(0x4d)
    public static let pagedown = Self(0x4e)

    // KeyPad
    public static let keypadslash = Self(0x54)
    public static let keypadasterisk = Self(0x55)
    public static let keypadminus = Self(0x56)
    public static let keypadplus = Self(0x57)
    public static let keypadenter = Self(0x58)
    public static let keypad1 = Self(0x59)
    public static let keypad2 = Self(0x5a)
    public static let keypad3 = Self(0x5b)
    public static let keypad4 = Self(0x5c)
    public static let keypad5 = Self(0x5d)
    public static let keypad6 = Self(0x5e)
    public static let keypad7 = Self(0x5f)
    public static let keypad8 = Self(0x60)
    public static let keypad9 = Self(0x61)
    public static let keypad0 = Self(0x62)
    public static let keypaddot = Self(0x63)
    public static let keypadequal = Self(0x67)
    public static let keypadcomma = Self(0x85)
    public static let keypadleftparen = Self(0xb6)
    public static let keypadrightparen = Self(0xb7)

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
    // public static let repeat = Self(0x79)
    public static let undo = Self(0x7a)
    public static let cut = Self(0x7b)
    public static let copy = Self(0x7c)
    public static let paste = Self(0x7d)
    public static let find = Self(0x7e)
    public static let ro = Self(0x87)
    public static let katakanahiragana = Self(0x88)
    public static let yen = Self(0x89)
    public static let henkan = Self(0x8a)
    public static let muhenkan = Self(0x8b)
    public static let kpjpcomma = Self(0x8c)
    public static let hangeul = Self(0x90)
    public static let hanja = Self(0x91)
    public static let katakana = Self(0x92)
    public static let hiragana = Self(0x93)
    public static let zenkakuhankaku = Self(0x94)
    //Mediakeys
    public static let media_playpause = Self(0xe8)
    public static let media_stopcd = Self(0xe9)
    public static let media_previoussong = Self(0xea)
    public static let media_nextsong = Self(0xeb)
    public static let media_ejectcd = Self(0xec)
    public static let media_volumeup = Self(0xed)
    public static let media_volumedown = Self(0xee)
    public static let media_mute = Self(0xef)
    public static let media_www = Self(0xf0)
    public static let media_back = Self(0xf1)
    public static let media_forward = Self(0xf2)
    public static let media_stop = Self(0xf3)
    public static let media_find = Self(0xf4)
    public static let media_scrollup = Self(0xf5)
    public static let media_scrolldown = Self(0xf6)
    public static let media_edit = Self(0xf7)
    public static let media_sleep = Self(0xf8)
    public static let media_coffee = Self(0xf9)
    public static let media_refresh = Self(0xfa)
    public static let media_calc = Self(0xfb)

    static let functionKeys: Set<Self> = [
        .f1,
        .f2,
        .f3,
        .f4,
        .f5,
        .f6,
        .f7,
        .f8,
        .f9,
        .f10,
        .f11,
        .f12,
        .f13,
        .f14,
        .f15,
        .f16,
        .f17,
        .f18,
        .f19,
        .f20,
        .f21,
        .f22,
        .f23,
        .f24
    ]

    /// Returns true if the key is a function key. For example, `F1`.
    var isFunctionKey: Bool { Self.functionKeys.contains(self) }
}

*/

# KbHelper

Allow easy detection of keyboard presses that your app has to respond to, and provides a convenient
callback mechanism to  trigger actions caused by those keypresses, as well as a Combine publisher that 
can be used if preferred

## Usage:
 First attach the controller to your root view by adding .kb()
 e.g.  ContentView().kb()
 A kb object is injected into the environment of your root view which you can then use to register the keystrokes you want to recognise in your app.
 keystrokes to be recognised are passed as types of kbKey which covers all the common keys found on modern keyboards, along with some of the more esoteric ones.  (See UIKit.UIKeyConstants for further details)

##  Registration : kb.register()
 To register keystrokes directly in your view, you should call the register method in a .onAppear block. More typically, registration is done in a viewmodel by passing the kb object to a registration method in your viewmodel.
 ## Parameters:
     [kbKey]            // e.g [.keyboardW, .keyboardF1]
     [kbModifier]?      // e.g. [.command, .shift, .option, .control ]
     ((_ KbKey)-> Void)?  // Function to call when keypress detected.
                        // A callback function, if specified,  must accept a KbKey as the first (unnamed) parameter. Often the KbKey.descrption() will be useful which will return a string of the matched character prefixed with any matched modifiers. e.g "<Shift>N"
                        // Alternatively, access  kbKey.characters to return the single matched character.
     
 ## Example usage:
 ```swift
 // call move(key: kbKey) when A or D is pressed
 kb.register([.keyboardA, .keyboardD], move)   
 
 // Register Command-M to invoke the menu(key: kbKey) method
 kb.register(.keyboardM, modifiers: [.command], menu)  
```

 If callback is omitted, you can still access registered keypresses via the kb.$keyPress Publisher, which emits values of type kbKey.


 ## ToDo:
 Input error checking for string arguments in register( undocumented feature; register("<Option>S"))
 Override Menu items for registered keys, e.g. <Commnd>M always minimises the window, even if set to be recognised

 ## Example view model :
 ```swift
 class Viewmodel : ObservableObject {
    var pressedKey = kbKey()
    var kbChar : String { return pressedKey.characters }
    var kbText : String { return pressedKey.description() }
    var cancellable : AnyCancellable?

    func action(_ key: kbKey )  {
        print("Callback \(key.description()) ")
    }

    /// Register key presses
    func kbRegistration(_ kb : KbHc) {

        // setup the combine subsciber for recognised keypresses
        cancellable = kb.$keyPress
        .receive(on: RunLoop.main)
        .assign(to: \.pressedKey, on: self)

        // Typical key press registrations
        kb.register([.keyboardA], action )
        kb.register([" <Option>s", "<Command>D" ], action )
        kb.register([.keyboardD, .keyboardU], modifiers: [.shift], action )
        kb.register([.keyboardF], modifiers: [.command], action )

        //No completion handler supplied, but keypress recognised by combine publisher $keyPress
        kb.register([.keyboardW])
        //completion handler supplied as trailing closure
        kb.register([.keyboardY]) { (keypress : kbKey) in print(keypress.description()) }
    }
 }
 ```

# CFAx33-KL
Library Class for the CrystalFontz CFA533 and CFA633 Serial LCD Displays

The [CFAx33](https://www.crystalfontz.com/product/cfa533tmikl-display-module-text-uart-16x2) family of displays is an integrated keypad + LCD with a simple UART interface. The display lines can be written or cleared individually or together, and the backlight is controllable. Keypress callbacks can be attached to a class instance to handle specific key presses.

The CFA533-TMI-KL is used in the Electric Imp Factory BlinkUp Box.

To add this library to your project, add #require "CFAx33-KL.class.nut:1.0.1" to the top of your device code.

## Class Usage

#### Constructor

The constructor takes one required parameter: an imp UART, which will be configured by the constructor.

```Squirrel
lcd <- CFAx33KL(hardware.uart6E);
```

#### setText(*x*, *y*, *text*, [*callback*])

Sets the display at point x,y to the string 'text'. Maximum length of string 'text' is 16 characters. Optional callback will be called when the CFAx33KL acknowledges the command.

```Squirrel
lcd.setText(0, 0, "Hello World!", function() {
    server.log("Text received by display");
});
```

#### setLine1(*text*, [*callback*])

Clears the first line of the display and sets the first line to string 'text'. Maximum length of string 'text' is 16 characters. Optional callback will be called when the CFAx33KL acknowledges the command.

#### setLine2(*text*, [*callback*])

Clears the second line of the display and sets the first line to string 'text'. Maximum length of string 'text' is 16 characters. Optional callback will be called when the CFAx33KL acknowledges the command.

```Squirrel
lcd.setLine1("Hello World!");
lcd.setLine2("I'm an LCD");
```

#### clearAll([*callback*])

Clears the entire display. Optional callback will be called when the CFAx33KL acknowledges the command.

#### clearLine1([*callback*])

Clears the first line of the display. Optional callback will be called when the CFAx33KL acknowledges the command.

#### clearLine2([*callback*])

Clears the second line of the display. Optional callback will be called when the CFAx33KL acknowledges the command.

#### setBrightness(*brightness*, [*callback*])

Sets the backlight brightness to 'brightness' with valid range 0-100 with 0 being off and 100 being maximum brightness. Optional callback will be called when the CFAx33KL acknowledges the command.

```Squirrel
// set 50% brightness
lcd.setBrightness(50);
```

#### setContrast(*contrast*, [*callback*])

Sets the backlight contrast to 'contrast' with valid range 0-100 with 0 being off and 100 being maximum contrast.

```Squirrel
// set 50% contrast
lcd.setContrast(50);
```

#### storeCurrentStateAsBootState([*callback*])

Saves the current state of the LCD to non volatile memory to be displayed on boot. Optional callback will be called when the CFAx33KL acknowledges the command.

```Squirrel
// store a useful boot-up message and state to be displayed on power-on
lcd.clearAll();
lcd.setLine1("Electric Imp");
lcd.setLine2("Is Excellent!");
lcd.setBrightness(50);
lcd.setContrast(50);
lcd.setCurrentStateAsBootState();
```

#### onKeyEvent(*callback*)

Set a callback function to be called when a keypress event is received from the CFAx33KL. The callback is called with one parameter corresponding to one of the CFAx33KL.KEY_* event constants:

| Key Event Constants |
| ------------------- |
| KEY_UP_PRESS |
| KEY_DOWN_PRESS |
| KEY_LEFT_PRESS |
| KEY_RIGHT_PRESS |
| KEY_ENTER_PRESS |
| KEY_EXIT_PRESS |
| KEY_UP_RELEASE |
| KEY_DOWN_RELEASE |
| KEY_LEFT_RELEASE |
| KEY_RIGHT_RELEASE |
| KEY_ENTER_RELEASE |
| KEY_EXIT_RELEASE |

```Squirrel
// test the lcd's integrated keys
lcd.setLine1("Key Test");
lcd.clearLine2();
lcd.onKeyEvent(function(key) {
    if (key == lcd.KEY_UP_PRESS) {
        lcd.setLine2("UP Press");
    } else if (key == lcd.KEY_DOWN_PRESS) {
        lcd.setLine2("DOWN Press");
    } else if (key == lcd.KEY_LEFT_PRESS) {
        lcd.setLine2("LEFT Press");
    } else if (key == lcd.KEY_RIGHT_PRESS) {
        lcd.setLine2("RIGHT Press");
    } else if (key == lcd.KEY_ENTER_PRESS) {
        lcd.setLine2("OK Press");
    } else if (key == lcd.KEY_EXIT_PRESS) {
        lcd.setLine2("EXIT Press");
    } else if (key == lcd.KEY_UP_RELEASE) {
        lcd.setLine2("UP Rel");
    } else if (key == lcd.KEY_DOWN_RELEASE) {
        lcd.setLine2("DOWN Rel");
    } else if (key == lcd.KEY_LEFT_RELEASE) {
        lcd.setLine2("LEFT Rel");
    } else if (key == lcd.KEY_RIGHT_RELEASE) {
        lcd.setLine2("RIGHT Rel");
    } else if (key == lcd.KEY_ENTER_RELEASE) {
        lcd.setLine2("OK Rel");
    } else if (key == lcd.KEY_EXIT_RELEASE) {
        lcd.setLine2("EXIT Rel");
    } else {
        lcd.setLine2("Unknown Key!");
    }
});
```

#### onError(*callback*)

Callback will be called when an error is encountered. The callback must take one parameter: a string describing the error.

```Squirrel
lcd.noError(function(errorStr) {
    server.error(errorStr);
});
```
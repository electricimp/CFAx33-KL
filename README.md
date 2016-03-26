# CFAx33-KL
Library Class for the CrystalFontz CFA533 and CFA633 Serial LCD Displays

The [CFAx33](https://www.crystalfontz.com/product/cfa533tmikl-display-module-text-uart-16x2) family of displays is an integrated keypad + LCD with a simple UART interface. The display lines can be written or cleared individually or together, and the backlight is controllable. Keypress callbacks can be attached to a class instance to handle specific key presses.

The CFA533-TMI-KL is used in the Electric Imp Factory BlinkUp Box.

**To add this library to your project, add** `#require "CFAx33KL.class.nut:1.0.1"` **to the top of your device code.**

## Class Usage

**Optional Callback Note:**  Most methods in this library contain an optional *callback* parameter.  If an optional callback is passed in, it will be called when the CFAx33KL acknowledges the command.  The callback function takes one parameter, a response table.  The response table will contain either an *err* key with an error message, or a *msg* key with the data received from the response packet.  A successful response often contains an empty array as the *msg*.


#### Constructor

The constructor takes one required parameter: an imp UART, which will be configured by the constructor.

```Squirrel
lcd <- CFAx33KL(hardware.uart6E);
```

#### setText(*index*, *row*, *text*, [*callback*])

The display contains 2 rows with 16 characters each.  The *#setText* method uses the *index* and *row* to position the display *text*.  The *index* parameter determines the starting position of the *text*, and can be any integer from 0 to 15. The length of the *text* plus the *index* must be less than 16.  The *row* can be either 0, to display text on the first row, or 1, to display text on the second row.  An optional callback can also be passed in, please see *Optional Callback Note* for details.

```Squirrel
lcd.setText(0, 0, "Hello World!", function(res) {
    if("err" in res) {
        server.error(res.err);
    } else {
        server.log("Text received by display");
    }
});
```

#### setLine1(*text*, [*callback*])

Clears the first line of the display and sets the first line to string 'text'. Maximum length of string 'text' is 16 characters. An optional callback can also be passed in, please see *Optional Callback Note* for details.

#### setLine2(*text*, [*callback*])

Clears the second line of the display and sets the second line to string 'text'. Maximum length of string 'text' is 16 characters. An optional callback can also be passed in, please see *Optional Callback Note* for details.

```Squirrel
lcd.setLine1("Hello World!");
lcd.setLine2("I'm an LCD");
```

#### clearAll([*callback*])

Clears the entire display.  An optional callback can also be passed in, please see *Optional Callback Note* for details.

#### clearLine1([*callback*])

Clears the first line of the display. An optional callback can also be passed in, please see *Optional Callback Note* for details.

#### clearLine2([*callback*])

Clears the second line of the display. An optional callback can also be passed in, please see *Optional Callback Note* for details.


#### setBrightness(*brightness*, [*callback*])

Sets the backlight brightness to 'brightness' with valid range 0-100 with 0 being off and 100 being maximum brightness. An optional callback can also be passed in, please see *Optional Callback Note* for details.

```Squirrel
// set 50% brightness
lcd.setBrightness(50);
```

#### setContrast(*contrast*, [*callback*])

Sets the backlight contrast to 'contrast' with valid range 0-100 with 0 being off and 100 being maximum contrast.  An optional callback can also be passed in, please see *Optional Callback Note* for details.

```Squirrel
// set 10% contrast
lcd.setContrast(10);
```

#### storeCurrentStateAsBootState([*callback*])

Saves the current state of the LCD to non volatile memory to be displayed on boot. An optional callback can also be passed in, please see *Optional Callback Note* for details.

```Squirrel
// store a useful boot-up message and state to be displayed on power-on
lcd.clearAll();
lcd.setLine1("Electric Imp");
lcd.setLine2("Is Excellent!");
lcd.setBrightness(50);
lcd.setContrast(0);
lcd.storeCurrentStateAsBootState();
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
lcd.onError(function(errorStr) {
    server.error(errorStr);
});
```
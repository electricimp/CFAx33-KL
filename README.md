# CFAx33-KL #

This library provides support for CrystalFontz CFA533 and CFA633 serial LCD displays. The [CFAx33](https://www.crystalfontz.com/product/cfa533tmikl-display-module-text-uart-16x2) series integrates a keypad and the LCD with a simple UART interface. The display lines can be written or cleared individually or together, and the backlight is controllable. Keypress callbacks can be attached to a class instance to handle specific key presses.

The CFA533-TMI-KL is used in the [Electric Imp impFactory™](https://developer.electricimp.com/manufacturing/impfactory).

**To add this library to your project, add** `#require "CFAx33KL.device.lib.nut:2.0.0"` **to the top of your device code.**

## Class Usage ##

### Constructor: CFAx33KL(*impUART*) ###

The constructor takes one (required) parameter: an imp UART object which will be configured by the constructor.

#### Example ####

```Squirrel
#require "CFAx33KL.device.lib.nut:2.0.0"

lcd <- CFAx33KL(hardware.uart6E);
```

## Class Methods ##

### Optional Callbacks ###

Most methods in this library contain an optional parameter, *callback*. If a callback function is passed in, it will be called when the CFAx33 acknowledges the command. The callback function has one parameter of its own: a response table. This table will contain either an *err* key with an error message, or a *msg* key with the data received from the response packet. If no response data is expected, a successful response often contains an empty array as the value of *msg*.

### setText(*column, row, text[, callback]*) ###

The display features two 16-character rows. The *setText()* method uses the *column* and *row* parameters to position the text that will be displayed (the value of *text*). The *column* parameter determines the starting position of the text, and can be any integer from 0 to 15. The length of the text plus the *column* value must be less than 16 or the text will be truncated. The *row* can be either 0, to display text on the first row, or 1, to display text on the second row.

An optional callback can also be provided; please see [‘Optional Callbacks’](#optional-callbacks) for details.

#### Example ####

```Squirrel
lcd.setText(0, 0, "Hello World!", function(res) {
    if ("err" in res) {
        server.error(res.err);
    } else {
        server.log("Text received by display");
    }
});
```

### setLine1(*text[, callback]*) ###

This method clears the first line of the display and sets it to the string *text*. The maximum length of the string is 16 characters; the text will be truncated if the string is longer than 16 characters. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [‘Optional Callbacks’](#optional-callbacks) for details.

### setLine2(*text[, callback]*) ###

This method clears the second line of the display and sets it to the string *text*. The maximum length of the string is 16 characters; the text will be truncated if the string is longer than 16 characters. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [‘Optional Callbacks’](#optional-callbacks) for details.

#### Example ####

```Squirrel
lcd.setLine1("Hello, World!");
lcd.setLine2("I'm a CFAx33KL LCD");
```

### clearAll(*[callback]*) ###

This method clears the entire display. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [‘Optional Callbacks’](#optional-callbacks) for details.

### clearLine1(*[callback]*) ###

This method clears the first line of the display. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [‘Optional Callbacks’](#optional-callbacks) for details.

### clearLine2(*[callback]*) ###

This method clears the second line of the display. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [‘Optional Callbacks’](#optional-callbacks) for details.

### setBrightness(*brightness[, callback]*) ###

This method sets the keypad and LCD backlight brightness to the value of *brightness*. The value should be a percentage between 0 (backlight off) and 100 (max brightness).

If you are using a CFA533 unit, you can pass either a single integer, as above, or an array of two integers. If one value is supplied, both the keypad and LCD backlights will be set to that brightness. If two values are supplied as an array, the first value will set the LCD brightness and the second value will set the keypad brightness.

The CFA633 only supports the single value *brightness* control.

The optional callback function will be called when the CFAx33KL acknowledges the command; please see [‘Optional Callbacks’](#optional-callbacks) for details.

#### CFA633 Example ####

```Squirrel
// Set 50% brightness
lcd.setBrightness(50);
```

#### CFA533 Example ####

```Squirrel
// Set LCD to 20% and keypad 5% brightness
lcd.setBrightness([20, 5]);
```

### setContrast(*contrast[, callback]*)

This method sets the backlight contrast to the value of *contrast*, which should be between 0 (no contrast, ie. text invisible) and 50 (maximum contrast, ie. fully black). The recommended value is 16. *setContrast()* only supports the one-byte “CFA633 Compatible” version of the command. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [‘Optional Callbacks’](#optional-callbacks) for details.

| Contrast Value | Text Presentation |
| --- | --- |
| 0 | Invisible |
| 1 | Light |
| 16 | Recommended |
| 29 | Dark |
| 30-50 | Very dark |

#### Example ####

```Squirrel
// Set 16% contrast
lcd.setContrast(16);
```

### storeCurrentStateAsBootState(*[callback]*) ###

This method saves the current state of the LCD &mdash; text, brightness and contrast &mdash; to non-volatile memory so that it can be displayed when the display powers up. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [‘Optional Callbacks’](#optional-callbacks) for details.

#### Example ####

```Squirrel
// Store a useful boot-up message and state 
// to be displayed on power-on
lcd.clearAll();
lcd.setLine1("Electric Imp");
lcd.setLine2("Is Excellent!");
lcd.setBrightness(20);
lcd.setContrast(12);
lcd.storeCurrentStateAsBootState();
```

### onKeyEvent(*callback*) ###

This method registers a callback function that will be executed when a keypress event is received from the CFAx33KL. The callback has one paramater of its own into which one of the following *CFAx33KL_KEY_<EVENT>* constants is passed:

- *CFAx33KL_KEY_UP_PRESS*
- *CFAx33KL_KEY_DOWN_PRESS*
- *CFAx33KL_KEY_LEFT_PRESS*
- *CFAx33KL_KEY_RIGHT_PRESS*
- *CFAx33KL_KEY_ENTER_PRESS*
- *CFAx33KL_KEY_EXIT_PRESS*
- *CFAx33KL_KEY_UP_RELEASE*
- *CFAx33KL_KEY_DOWN_RELEASE*
- *CFAx33KL_KEY_LEFT_RELEASE*
- *CFAx33KL_KEY_RIGHT_RELEASE*
- *CFAx33KL_KEY_ENTER_RELEASE*
- *CFAx33KL_KEY_EXIT_RELEASE*

To clear a previously registered callback pass in `null` instead of a callback function. 

#### Example ####

```Squirrel
// Test the LCD's integrated keys
lcd.setLine1("Key Test");
lcd.clearLine2();
lcd.onKeyEvent(function(key) {
  if (key == CFAx33KL_KEY_UP_PRESS) {
    lcd.setLine2("UP Pressed");
  } else if (key == CFAx33KL_KEY_DOWN_PRESS) {
    lcd.setLine2("DOWN Pressed");
  } else if (key == CFAx33KL_KEY_LEFT_PRESS) {
    lcd.setLine2("LEFT Pressed");
  } else if (key == CFAx33KL_KEY_RIGHT_PRESS) {
    lcd.setLine2("RIGHT Pressed");
  } else if (key == CFAx33KL_KEY_ENTER_PRESS) {
    lcd.setLine2("OK Pressed");
  } else if (key == CFAx33KL_KEY_EXIT_PRESS) {
    lcd.setLine2("EXIT Pressed");
  } else if (key == CFAx33KL_KEY_UP_RELEASE) {
    lcd.setLine2("UP Released");
  } else if (key == CFAx33KL_KEY_DOWN_RELEASE) {
    lcd.setLine2("DOWN Released");
  } else if (key == CFAx33KL_KEY_LEFT_RELEASE) {
    lcd.setLine2("LEFT Released");
  } else if (key == CFAx33KL_KEY_RIGHT_RELEASE) {
    lcd.setLine2("RIGHT Released");
  } else if (key == CFAx33KL_KEY_ENTER_RELEASE) {
    lcd.setLine2("OK Released");
  } else if (key == CFAx33KL_KEY_EXIT_RELEASE) {
    lcd.setLine2("EXIT Released");
  } else {
    lcd.setLine2("Unknown Key!");
  }
});
```

### getKeyState(*keyName*) ###

This method’s *keyName* parameter takes one of the following *CFAx33KL_KEY_<NAME>* constants and returns a boolean `true` if the key is currently pressed, otherwise `false`.  

- *CFAx33KL_KEY_UP*
- *CFAx33KL_KEY_DOWN*
- *CFAx33KL_KEY_LEFT*
- *CFAx33KL_KEY_RIGHT*
- *CFAx33KL_KEY_ENTER*
- *CFAx33KL_KEY_EXIT*

#### Example ####

```Squirrel
server.log("Up key is " + (lcd.getKeyState(CFAx33KL_KEY_UP) ? "" : "not ") + "pressed");
```

### onError(*callback*) ###

This method registers a callback function that will be executed when an error is encountered. The callback has one parameter of its own into which a string containing a description of the error will be placed.

To clear a previously set callback pass in `null` instead of a callback function. 

#### Example ####

```Squirrel
lcd.onError(function(errorString) {
  server.error(errorString);
});
```

### getVersion(*callback*) ###

This method retrieves the display’s hardware and firmware version and passes the response to the callback. The callback takes one parameter: a table containing either *version* or *err* keys. For the CFA633, the version is formatted `"CFA633:hX.X,yY.Y"`, where hX.X is the hardware revision and yY.Y is the firmware version. For the CFA533, the version is formatted `"CFA533:XhX,YsY"`.

#### Example ####

```Squirrel
lcd.getVersion(function(response) {
  if ("err" in response) {
    server.error(response.err);
  } else {
    server.log(response.version);
  }
});
```

## License ##

CFAx33-KL is licensed under the [MIT License](./LICENSE).

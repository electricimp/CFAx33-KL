# CFAx33-KL
Library Class for the CrystalFontz CFA533 and CFA633 Serial LCD Displays

The [CFAx33](https://www.crystalfontz.com/product/cfa533tmikl-display-module-text-uart-16x2) family of displays is an integrated keypad + LCD with a simple UART interface. The display lines can be written or cleared individually or together, and the backlight is controllable. Keypress callbacks can be attached to a class instance to handle specific key presses.

The CFA533-TMI-KL is used in the Electric Imp Factory BlinkUp Box.

**To add this library to your project, add** `#require "CFAx33KL.class.nut:1.1.0"` **to the top of your device code.**

## Class Usage

### Optional Callbacks

Most methods in this library contain an optional *callback* parameter. If a callback function (inline or by reference) is passed in, it will be called when the CFAx33KL acknowledges the command. The callback function takes one parameter: a response table. This table will contain either an *err* key with an error message, or a *msg* key with the data received from the response packet. If no response data is expected, a successful response often contains an empty array as the *msg*.

### Constructor: CFAx33KL(*impUART*)

The constructor takes one (required) parameter: an imp UART object which will be configured by the constructor.

```Squirrel
#require "CFAx33KL.class.nut:1.1.0"

lcd <- CFAx33KL(hardware.uart6E);
```

## Class Methods

### setText(*column, row, text[, callback]*)

The display features two 16-character rows.  The *setText()* method uses the *column* and *row* paramerts to position the text that will be displayed &mdash; the text is passed into *text*. The *column* parameter determines the starting position of the text, and can be any integer from 0 to 15. The length of the text plus the *column* value must be less than 16 or the text will be truncated. The *row* can be either 0, to display text on the first row, or 1, to display text on the second row.

An optional callback can also be provided; please see [Optional Callbacks](#optional-callbacks) for details.

```Squirrel
lcd.setText(0, 0, "Hello World!", function(res) {
    if("err" in res) {
        server.error(res.err);
    } else {
        server.log("Text received by display");
    }
});
```

### setLine1(*text[, callback]*)

This method clears the first line of the display and sets the first line to string *text*. The maximum length of the string is 16 characters. The text will be truncated if the string is longer than 16 characters. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [Optional Callbacks](#optional-callbacks) for details.

### setLine2(*text[, callback]*)

This method clears the second line of the display and sets the first line to string *text*. The maximum length of the string is 16 characters. The text will be truncated if the string is longer than 16 characters. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [Optional Callbacks](#optional-callbacks) for details.

```Squirrel
lcd.setLine1("Hello, World!");
lcd.setLine2("I'm an LCD");
```

### clearAll(*[callback]*)

This method clears the entire display. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [Optional Callbacks](#optional-callbacks) for details.

### clearLine1(*[callback]*)

This method clears the first line of the display. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [Optional Callbacks](#optional-callbacks) for details.

#### clearLine2(*[callback]*)

This method clears the second line of the display. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [Optional Callbacks](#optional-callbacks) for details.

### setBrightness(*brightness[, callback]*)

This method sets the keypad and LCD backlight brightness to *brightness* as a percentage, with 0 being off and 100 being maximum brightness.

For the CFA533 unit, you can pass either a single integer or an array of two integers. If one value is supplied, both the keypad and LCD backlights will be set to that brightness. If two values are supplied as an array, the first value will set the LCD brightness and the second value will set the keypad brightness.

The CFA633 only supports the single value *brightness* control.

The optional callback function will be called when the CFAx33KL acknowledges the command; please see [Optional Callbacks](#optional-callbacks) for details.

#### CFA633 Example

```Squirrel
// set 50% brightness
lcd.setBrightness(50);
```

#### CFA533 Example

```Squirrel
// set LCD to 20% and keypad 5% brightness
lcd.setBrightness([20, 5]);
```

### setContrast(*contrast[, callback]*)

This method sets the backlight contrast to *contrast*, with 0 being no contrast (ie. text invisible) and 50 being maximum contrast. The *setContrast()* method only supports the one-byte “CFA633 Compatible” version of the command. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [Optional Callbacks](#optional-callbacks) for details.

| Contrast Value | Text Presentation |
| --- | --- |
| 0 | Invisible |
| 1 | Light |
| 16 | Recommended |
| 29 | Dark |
| 30-50 | Very dark |

```Squirrel
// Set 16% contrast
lcd.setContrast(16);
```

### storeCurrentStateAsBootState(*[callback]*)

This method saves the current state of the LCD to non-volatile memory to be displayed on boot. The optional callback function will be called when the CFAx33KL acknowledges the command; please see [Optional Callbacks](#optional-callbacks) for details.

```Squirrel
// Store a useful boot-up message and state to be displayed on power-on
lcd.clearAll();
lcd.setLine1("Electric Imp");
lcd.setLine2("Is Excellent!");
lcd.setBrightness(20);
lcd.setContrast(12);
lcd.storeCurrentStateAsBootState();
```

### onKeyEvent(*callback*)

This method specifies a callback function to be executed when a keypress event is received from the CFAx33KL. The callback is called with one parameter, one of the *CFAx33KL.KEY_<EVENT>* constants:

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
// Test the LCD's integrated keys
lcd.setLine1("Key Test");
lcd.clearLine2();
lcd.onKeyEvent(function(key) {
  if (key == CFAx33KL.KEY_UP_PRESS) {
    cd.setLine2("UP Pressed");
  } else if (key == CFAx33KL.KEY_DOWN_PRESS) {
    lcd.setLine2("DOWN Pressed");
  } else if (key == CFAx33KL.KEY_LEFT_PRESS) {
    lcd.setLine2("LEFT Pressed");
  } else if (key == CFAx33KL.KEY_RIGHT_PRESS) {
    lcd.setLine2("RIGHT Pressed");
  } else if (key == CFAx33KL.KEY_ENTER_PRESS) {
    lcd.setLine2("OK Pressed");
  } else if (key == CFAx33KL.KEY_EXIT_PRESS) {
    lcd.setLine2("EXIT Pressed");
  } else if (key == CFAx33KL.KEY_UP_RELEASE) {
    lcd.setLine2("UP Released");
  } else if (key == CFAx33KL.KEY_DOWN_RELEASE) {
    lcd.setLine2("DOWN Released");
  } else if (key == CFAx33KL.KEY_LEFT_RELEASE) {
    lcd.setLine2("LEFT Released");
  } else if (key == CFAx33KL.KEY_RIGHT_RELEASE) {
    lcd.setLine2("RIGHT Released");
  } else if (key == CFAx33KL.KEY_ENTER_RELEASE) {
    lcd.setLine2("OK Released");
  } else if (key == CFAx33KL.KEY_EXIT_RELEASE) {
    lcd.setLine2("EXIT Released");
  } else {
    lcd.setLine2("Unknown Key!");
  }
});
```

#### onError(*callback*)

This method specifies the callback function that will be executed when an error is encountered. The callback must take one parameter: a variable into which a string containing a description of the error will be placed.

```Squirrel
lcd.onError(function(errorString) {
  server.error(errorString);
});
```

### getVersion(*callback*)

This method retrieves the hardware and firmware version of the display from the host and passes the response to the callback.   The callback takes one parameter: a table containing either *version* or *err* keys. For the CFA633, the version is formatted `"CFA633:hX.X,yY.Y"`, where hX.X is the hardware revision and yY.Y is the firmware version. For the CFA533, the version is formatted `"CFA533:XhX,YsY"`.

```Squirrel
lcd.getVersion(function(res) {
    if("err" in res) {
        server.error(res.err);
    } else {
        server.log(res.version);
    }
});
```


## Testing

Tests can be launched with:

```bash
imptest test
```

By default configuration for the testing is read from [.imptest](https://github.com/electricimp/impTest/blob/develop/docs/imptest-spec.md).

To run test with your settings (for example while you are developing), create your copy of **.imptest** file and name it something like **.imptest.local**, then run tests with:

 ```bash
 imptest test -c .imptest.local
 ```

### Hardware Required

Tests require _imp002_ module with _CrystalFontz CFA533_ display connected to _uart6E_.

## License

CFAx33-KL is licensed under the [MIT License](./LICENSE).

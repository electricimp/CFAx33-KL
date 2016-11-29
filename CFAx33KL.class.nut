// Class for interfacing with the Crystalfontz CFA533-KL/KS and CFA633-KL/KS serial LCDs
class CFAx33KL {

  static version = [1, 1, 0];

  // names for keys
  static KEY_UP = "UP";
  static KEY_DOWN = "DOWN";
  static KEY_LEFT = "LEFT";
  static KEY_RIGHT = "RIGHT";
  static KEY_ENTER = "ENTER";
  static KEY_EXIT = "EXIT";

  // key codes for key activity reports
  static KEY_UP_PRESS = 1;
  static KEY_DOWN_PRESS = 2;
  static KEY_LEFT_PRESS = 3;
  static KEY_RIGHT_PRESS = 4;
  static KEY_ENTER_PRESS = 5;
  static KEY_EXIT_PRESS = 6;
  static KEY_UP_RELEASE = 7;
  static KEY_DOWN_RELEASE = 8;
  static KEY_LEFT_RELEASE = 9;
  static KEY_RIGHT_RELEASE = 10;
  static KEY_ENTER_RELEASE = 11;
  static KEY_EXIT_RELEASE = 12;

  // map for key codes to name
  _keyToNameLookup = null;

  // table keeping record of key states
  _currentKeyStates = null;

  // first two bits of a packet indicate it's type
  static _PACKET_TYPE_HOST = 0x00;
  static _PACKET_TYPE_RESPONSE = 0x01;
  static _PACKET_TYPE_REPORT = 0x02;
  static _PACKET_TYPE_ERROR = 0x03;

  // tx command codes
  static _COMMAND_SET_TEXT = 0x1F;
  static _COMMAND_CLEAR_ALL = 0x06;
  static _COMMAND_SET_BRIGHTNESS = 0x0E;
  static _COMMAND_SET_CONTRAST = 0x0D;
  static _COMMAND_STORE_BOOTSTATE = 0x04;
  static _COMMAND_GET_VERSION = 0x01;

  // rx reports codes
  static _REPORT_KEY_ACTIVITY = 0x80;

  // packet rx state machine states
  static _RX_STATE_COMMAND = 0;
  static _RX_STATE_DATA_LENGTH = 1;
  static _RX_STATE_DATA = 2;
  static _RX_STATE_CRC_FIRST_BYTE = 3;
  static _RX_STATE_CRC_SECOND_BYTE = 4;

  static _LINE_LENGTH = 16; // this is a 16x2 character LCD
  static _BLANK_LINE = "                "; // 16 spaces
  static _UART_BAUD = 19200; // default baud rate

  _uart = null;
  _keyEventCallback = null;
  _errorCallback = null;
  _versionCallback = null;
  _packetTxQueue = null; // queue of packet objects waiting to be sent
  _activeTxPacket = null; // the currenting running packet waiting for an ACK
  _currentRxState = null; // rx packet state machine state
  _currentRxPacket = null; // rx packet being constructed by state machine

  // Constructs a new instance of CFAx33KL.
  // This WILL reset your UART configuration for the supplied uart parameter.
  constructor(uart) {
    _uart = uart
    _uart.configure(_UART_BAUD, 8, PARITY_NONE, 1, NO_CTSRTS, _uartReceive.bindenv(this))
    _packetTxQueue = [];
    _currentRxState = _RX_STATE_COMMAND; // initial state is to wait for start of incoming packet
    _currentRxPacket = {};

    _keyToNameLookup = {
      [KEY_UP_PRESS] = KEY_UP,
      [KEY_UP_RELEASE] = KEY_UP,
      [KEY_DOWN_PRESS] = KEY_DOWN,
      [KEY_DOWN_RELEASE] = KEY_DOWN,
      [KEY_LEFT_PRESS] = KEY_LEFT,
      [KEY_LEFT_RELEASE] = KEY_LEFT,
      [KEY_RIGHT_PRESS] = KEY_RIGHT,
      [KEY_RIGHT_RELEASE] = KEY_RIGHT,
      [KEY_ENTER_PRESS] = KEY_ENTER,
      [KEY_ENTER_RELEASE] = KEY_ENTER,
      [KEY_EXIT_PRESS] = KEY_EXIT,
      [KEY_EXIT_RELEASE] = KEY_EXIT
    };

    _currentKeyStates = { //assume that no keys are pressed when initialized
      [KEY_UP] = false,
      [KEY_DOWN] = false,
      [KEY_LEFT] = false,
      [KEY_RIGHT] = false,
      [KEY_ENTER] = false,
      [KEY_EXIT] = false
    };
  }

  function getVersion(callback) {
    _versionCallback = callback;
    local packet = _buildPacket(_COMMAND_GET_VERSION, [], _convertVersionResponse.bindenv(this));
    _enqueue(packet);
  }

  // Sets the display at point x,y to the string 'text'. Maximum length of string 'text' is 16 characters.
  // Optional callback will be called when the CFAx33KL acknowledges the command.
  function setText(x, y, text, callback = null) {

    if (typeof text != "string") text = text.tostring();

    // Truncate text if it is too long
    local maxLength = _LINE_LENGTH - x;
    if(text.len() > maxLength) {
      text = text.slice(0, maxLength);
    }
    local data = [ x, y ];
    data.extend(_stringToCharArray(text));
    local packet = _buildPacket(_COMMAND_SET_TEXT, data, callback);
    _enqueue(packet)
  }

  // Clears the first line of the display and sets the first line to string 'text'. Maximum length of string 'text' is 16 characters.
  // Optional callback will be called when the CFAx33KL acknowledges the command.
  function setLine1(text, callback = null) {
    clearLine1();
    setText(0,0, text, callback);
  }

  // Clears the second line of the display and sets the second line to string 'text'. Maximum length of string 'text' is 16 characters.
  // Optional callback will be called when the CFAx33KL acknowledges the command.
  function setLine2(text, callback = null) {
    clearLine2();
    setText(0,1, text, callback);
  }

  // Clears the entire display.
  // Optional callback will be called when the CFAx33KL acknowledges the command.
  function clearAll(callback = null) {
    local packet = _buildPacket(_COMMAND_CLEAR_ALL, [], callback);
    _enqueue(packet);
  }

  // Clears the first line of the display.
  // Optional callback will be called when the CFAx33KL acknowledges the command.
  function clearLine1(callback = null) {
    setText(0,0, _BLANK_LINE, callback);
  }

  // Clears the second line of the display.
  // Optional callback will be called when the CFAx33KL acknowledges the command.
  function clearLine2(callback = null) {
    setText(0,1, _BLANK_LINE, callback);
  }

  // Sets the backlight brightness to 'brightness' with valid range 0-100 with 0 being off and 100 being maximum brightness.
  // Optional callback will be called when the CFAx33KL acknowledges the command.
  function setBrightness(brightness, callback = null) {
    // reconcile brightness data type
    if(typeof brightness == "integer" || typeof brightness == "float") { brightness = [ brightness ]; }

    // adjust brightness to be in range
    local err = false;
    foreach(index, value in brightness) {
        if(value < 0) {
            brightness[index] = 0;
        } else if (value > 100) {
            brightness[index] = 100;
        }
    }
    _enqueue(_buildPacket(_COMMAND_SET_BRIGHTNESS, brightness, callback));

  }

  // Sets the backlight contrast to 'contrast' with valid range 0-50 with 0 being off and 50 being maximum contrast.
  function setContrast(contrast, callback = null) {
    // adjust contrast to be in range
    if(contrast < 0) {
        contrast = 0;
    } else if (contrast > 50) {
        contrast = 50;
    }
    _enqueue(_buildPacket(_COMMAND_SET_CONTRAST, [ contrast ], callback));
  }

  // Saves the current state of the LCD to non volatile memory to be displayed on boot.
  // Optional callback will be called when the CFAx33KL acknowledges the command.
  function storeCurrentStateAsBootState(callback = null) {
    _enqueue(_buildPacket(_COMMAND_STORE_BOOTSTATE, [], callback));
  }

  // 'callback' will be called when a keypress event is received from the CFAx33KL.
  // The callback is called with one parameter corresponding to one of the CFAx33KL.KEY_* event constants.
  function onKeyEvent(callback=null) {
    _keyEventCallback = callback;
  }

  // 'callback' will be called when an error is encountered with a parameter string describing the error
  function onError(callback) {
    _errorCallback = callback;
  }

  function getKeyState(key) {
    return _currentKeyStates[key]
  }

  // construct a packet table
  function _buildPacket(command, data, callback) {
    local packet = {};
    packet.command <- command;
    packet.dataLength <- data.len();
    packet.data <- data;
    packet.callback <- callback;
    return packet;
  }

  function _stringToCharArray(string) {
    local chars = [];
    for(local i = 0; i < string.len(); i++) {
      chars.append(string[i])
    }
    return chars;
  }

  // adds a packet to the tx queue
  function _enqueue(packet) {
    _packetTxQueue.push(packet);
    if(_activeTxPacket == null) {
      _transmitNextInQueue();
    }
  }

  // dequeues a packet from the tx queue and transmits it
  function _transmitNextInQueue() {
    if(_packetTxQueue.len() > 0) {
      _activeTxPacket = _packetTxQueue.remove(0);
      _transmit(_activeTxPacket);
    }
  }

  // transmits packet bytes over uart to the CFAx33KL
  function _transmit(packet) {
      local bytes = [ packet.command, packet.dataLength ];
      bytes.extend(packet.data);
      local crc = _crc(bytes)
      local packetBlob = blob()
      for(local i = 0; i < bytes.len(); i++) {
          packetBlob.writen(bytes[i], 'b')
      }
      packetBlob.writen(crc, 'w')
      _uart.write(packetBlob)
  }

  // uart rx callback
  function _uartReceive() {
    local byte;
    while((byte = _uart.read()) != -1) {
        _processIncomingByte(byte);
    }
  }

  // rx state machine
  function _processIncomingByte(byte) {
    switch(_currentRxState) {
      case _RX_STATE_COMMAND:
        _currentRxPacket.command <- byte;
        _currentRxState = _RX_STATE_DATA_LENGTH;
      break;
      case _RX_STATE_DATA_LENGTH:
        _currentRxPacket.dataLength <- byte;
        _currentRxPacket.data <- [];
        if(_currentRxPacket.dataLength > 0) {
          _currentRxState = _RX_STATE_DATA;
        } else {
          _currentRxState = _RX_STATE_CRC_FIRST_BYTE;
        }
      break;
      case _RX_STATE_DATA:
        _currentRxPacket.data.push(byte);
        if(_currentRxPacket.data.len() >= _currentRxPacket.dataLength) {
          _currentRxState = _RX_STATE_CRC_FIRST_BYTE;
        }
      break;
      case _RX_STATE_CRC_FIRST_BYTE:
        _currentRxPacket.crc <- byte;
        _currentRxState = _RX_STATE_CRC_SECOND_BYTE;
      break;
      case _RX_STATE_CRC_SECOND_BYTE:
        _currentRxPacket.crc = (byte << 8) + _currentRxPacket.crc; // LSB first
        _currentRxState = _RX_STATE_COMMAND;
        _processPacket(_currentRxPacket); // all done, process packet
      break;
    }
  }

  // processes an rx packet once it has been fully recieved
  function _processPacket(packet) {
    local bytes = [ packet.command, packet.dataLength ];
    bytes.extend(packet.data);
    local crc = _crc(bytes);
    if(crc != packet.crc) { // bad CRC
      if(_activeTxPacket != null && "callback" in _activeTxPacket && _activeTxPacket.callback != null) {
        _activeTxPacket.callback({ "err": "Received packet failed CRC" });
      }
      _activeTxPacket = null;
      _transmitNextInQueue(); // move on
    }
    local type = packet.command >> 6; // grab first two bits

    if(type == _PACKET_TYPE_RESPONSE && _activeTxPacket != null) {
      if((packet.command & 0x3F) == _activeTxPacket.command) { // trim first two bits, check if rx packet matches tx packet command id
        if(_activeTxPacket != null && "callback" in _activeTxPacket && _activeTxPacket.callback != null) {
          _activeTxPacket.callback({ "msg": packet.data });
        }
      } else { // ack id does not match rx id
        if(_errorCallback != null) {
          _errorCallback("packet ACK sequencing error!")
        }
      }
      _activeTxPacket = null;
      _transmitNextInQueue(); // move on
    }
    if(type == _PACKET_TYPE_REPORT) {
      if(packet.command == _REPORT_KEY_ACTIVITY) { // key press packet
        if(packet.dataLength == 1) {
          local key = packet.data[0];
          if (key >= 1 && key <= 12) _currentKeyStates[_keyToNameLookup[key]] <- (key <= 6 ? true : false);
          if(_keyEventCallback != null) {
            _keyEventCallback(key); // call key event cb
          }
        }
      }
    }
    if(type == _PACKET_TYPE_ERROR) { // error packet, if tx was invalid
      if(_activeTxPacket != null && "callback" in _activeTxPacket && _activeTxPacket.callback != null) {
        // treat from setting empty text as success
        if (_activeTxPacket.command = _COMMAND_SET_TEXT && _activeTxPacket.dataLength == 2) {
          _activeTxPacket.callback({ "msg": _activeTxPacket.data });
        } else {
          _activeTxPacket.callback({ "err": "Transmitted packet was invalid" });
        }
      }
      _activeTxPacket = null;
      _transmitNextInQueue(); // move on
    }
  }

  // 16 bit CRC of byte array (polynomial 0x8408)
  function _crc(bytes) {
      local i; // loop count, bits in byte
      local data; // current byte being shifted
      local crc = 0xFFFF;
      for(local j = 0; j < bytes.len(); j++) {
          data = bytes[j];
          i = 8;
          do {
              if((crc ^ data) & 0x01) {
                  crc = crc >> 1;
                  crc = crc ^ 0x8408;
              } else {
                  crc = crc >> 1;
              }
              data = data >> 1;
          } while(--i != 0);
      }
      return _s16tou16(~crc);
  }

  // signed short to unsigned short
  function _s16tou16(b) {
    local lowByte = b & 0xFF;
    local highByte = (b >> 8) & 0xFF;
    return (highByte << 8) + lowByte;
  }

  function _convertVersionResponse(res) {
    if(_versionCallback != null) {
      if(res.msg.len() == 16) {
        local version = "";
        foreach(v in res.msg) {
          version += v.tochar();
        }
        _versionCallback({"version": version});
      } else {
        _versionCallback({"err": "Packet received was invalid"});
      }
    }
  }

}

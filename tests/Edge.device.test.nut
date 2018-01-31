class EdgeTestCase extends ImpTestCase {
  _i = null;

  function setUp() {
    return Promise(function(ok, err) {
      this._i = CFAx33KL(hardware.uart6E);
      this._i.setContrast(16);
      this._i.onError(function(e) {
        this.info(e);
      }.bindenv(this))
      this._i.clearAll(function(res1) {
        this._i.setText(0, 0, "Edge Tests", function(res) {
          imp.wakeup(2, function() {
            ("err" in res || "err" in res1) ? err(res.err) : ok("Testing edge cases");
          }.bindenv(this))
        }.bindenv(this))
      }.bindenv(this))
    }.bindenv(this))
  }

  /**
   * Setting text off boundaries should fail
   */
  function test_setTextOffBoundaries() {
    return Promise(function (ok, err) {
      imp.wakeup(1, function() {
        this._i.setText(18, 0, "###", function (res) {
          if (!"err" in res || res.err != CFAx33KL_ERROR_TX_INVALID) {
            err(res.err)
          } else {
            ok("Got expected error");
          }
        });
      }.bindenv(this))
    }.bindenv(this));
  }

  /**
   * Setting empty text should succeed
   */
  function test_setEmptyText() {
    return Promise(function (ok, err) {
      imp.wakeup(1, function() {
        this._i.setText(0, 0, "", function (res) {
          if ("err" in res ) {
            err("Setting empty text should succeed")
          } else {
            this.info("settting empty string");
            ok();
          }
        }.bindenv(this));
      }.bindenv(this))
    }.bindenv(this));
  }

  /**
   * Setting empty line 1
   */
  function test_setEmptyLine1() {
    return Promise(function (ok, err) {
      imp.wakeup(1, function() {
        this._i.setLine1("", function (res) {
          if ("err" in res ) {
            err("Setting empty line #1 should succeed")
          } else {
            this.info("settting empty string");
            ok();
          }
        }.bindenv(this));
      }.bindenv(this))
    }.bindenv(this));
  }

  /**
   * Setting empty line 2
   */
  function test_setEmptyLine2() {
    return Promise(function (ok, err) {
      imp.wakeup(1, function() {
        this._i.setLine2("", function (res) {
          if ("err" in res ) {
            err("Setting empty line #2 should succeed")
          } else {
            this.info("settting empty string");
            ok();
          }
        }.bindenv(this));
      }.bindenv(this))
    }.bindenv(this));
  }

  function test_getKeyState() {
    return Promise(function (ok, err) {
      this.info("Press up key and hold");
      this._i.setLine1("Press Up", function (res) {
        imp.wakeup(5, function() {
          local upState = _i.getKeyState(CFAx33KL_KEY_UP);
          this.info("Up key is pressed: " + upState);
          this._i.setLine2("Pressed: " + upState, function(res) {
            this.info("Release up key now.");
            this._i.setLine1("Release Up", function(res) {
              imp.wakeup(2, function() {
                upState = _i.getKeyState(CFAx33KL_KEY_UP);
                this.info("Up key is pressed: " + upState);
                this._i.setLine2("Pressed: " + upState, function(res) {
                  ok();
                }.bindenv(this))
              }.bindenv(this))
            }.bindenv(this))
          }.bindenv(this))
        }.bindenv(this))
      }.bindenv(this));
    }.bindenv(this));
  }

  function tearDown() {
    return Promise(function (ok, err) {
      this._i.clearAll(function(res) {
        ok("Edge tests completed");
      }.bindenv(this));
    }.bindenv(this));
  }
}

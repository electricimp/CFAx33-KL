class EdgeTestCase extends ImpTestCase {
  _i = null;

  function setUp() {
    this._i = CFAx33KL(hardware.uart6E);
    this._i.setContrast(16);
    this._i.onError(function(e) {
      this.info(e);
    }.bindenv(this))
    return "Testing edge cases";
  }

  /**
   * Setting text off boundaries should fail
   */
  function test_setTextOffBoundaries() {
    return Promise(function (ok, err) {
      this._i.setText(18, 0, "###", function (res) {
        if (!"err" in res || res.err != CFAx33KL_ERROR_TX_INVALID) {
          err(res.err)
        } else {
          ok("Got expected error");
        }
      });
    }.bindenv(this));
  }

  /**
   * Setting empty text should succeed
   */
  function test_setEmptyText() {
    return Promise(function (ok, err) {
      this._i.setText(0, 0, "", function (res) {
        if ("err" in res ) {
          err("Setting empty text should succeed")
        } else {
          this.info("settting empty string");
          ok();
        }
      }.bindenv(this));
    }.bindenv(this));
  }

  /**
   * Setting empty line 1
   */
  function test_setEmptyLine1() {
    return Promise(function (ok, err) {
      this._i.setLine1("", function (res) {
        if ("err" in res ) {
          err("Setting empty line #1 should succeed")
        } else {
          this.info("settting empty string");
          ok();
        }
      }.bindenv(this));
    }.bindenv(this));
  }

  /**
   * Setting empty line 2
   */
  function test_setEmptyLine2() {
    return Promise(function (ok, err) {
      this._i.setLine2("", function (res) {
        if ("err" in res ) {
          err("Setting empty line #2 should succeed")
        } else {
          this.info("settting empty string");
          ok();
        }
      }.bindenv(this));
    }.bindenv(this));
  }
}

class EdgeTestCase extends ImpTestCase {
  _i = null;

  function setUp() {
    this._i = CFAx33KL(hardware.uart6E);
    return "This should iterate contrast from 50 to 0";
  }

  /**
   * Setting text off boundaries should fail
   */
  function test_setTextOffBoundaries() {
    return Promise(function (ok, err) {
      this._i.setText(18, 0, "###", function (res) {
        if (!"err" in res || res.err != "Transmitted packet was invalid") {
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
          ok();
        }
      });
    }.bindenv(this));
  }

  /**
   * Setting empty line 1
   */
  function test_setEmptyLine1() {
    return Promise(function (ok, err) {
      this._i.setLine1("", function (res) {
        if ("err" in res ) {
          err("Setting empty line 1 should succeed")
        } else {
          ok();
        }
      });
    }.bindenv(this));
  }

  /**
   * Setting empty line 2
   */
  function test_setEmptyLine2() {
    return Promise(function (ok, err) {
      this._i.setLine2("", function (res) {
        if ("err" in res ) {
          err("Setting empty line 2 should succeed")
        } else {
          ok();
        }
      });
    }.bindenv(this));
  }
}

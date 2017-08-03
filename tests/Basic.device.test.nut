class BasicTestCase extends ImpTestCase {
  _i = null;

  function setUp() {
    this._i = CFAx33KL(hardware.uart6E);
    this._i.setContrast(1);
  }

  /**
   * Should set random text
   */
  function test01_setRandomText() {
    return Promise(function (ok, err) {
      this._i.setText(0, 0, "################", function (res) {
        if ("err" in res) {
          err(res.err)
        } else {
          this._i.setText(0, 1, "################", function (res) {
            if ("err" in res) {
              err(res.err);
            } else {
              ok();
            }
          });
        };

      }.bindenv(this));
    }.bindenv(this));
  }

  /**
   * Should set random text on the first line
   */
  function test02_setRandomTextOnLine1() {
    return Promise(function (ok, err) {
      imp.wakeup(1, function () {
        this._i.setLine1("" + math.rand(), function (res) {
          "err" in res ? err(res.err) : ok();
        });
      }.bindenv(this));
    }.bindenv(this));
  }

  /**
   * Should set random text on the second line
   */
  function test03_setRandomTextOnLine1() {
    return Promise(function (ok, err) {
      imp.wakeup(1, function () {
        this._i.setLine2("" + math.rand(), function (res) {
          "err" in res ? err(res.err) : ok();
        });
      }.bindenv(this));
    }.bindenv(this));
  }

  function test04_getVersion() {
    return Promise(function (ok, err) {
      this._i.getVersion(function (res) {
        "err" in res ? err(res.err) : ok("Version" + res.version);
      });
    }.bindenv(this));
  }
}

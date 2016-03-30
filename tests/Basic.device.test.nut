
class BasicTestCase extends ImpTestCase {
  _i = null;

  function setUp() {
    this._i = CFAx33KL(hardware.uart6E);
    this._i.setContrast(16);
  }

  /**
   * Should set random text on the first line
   */
  function test_setRandomText() {
    return Promise(function (ok, err) {
      this._i.setText(0, 0, math.rand() + "", @(res) "err" in res ? err(res.err) : ok());
    }.bindenv(this));
  }
}

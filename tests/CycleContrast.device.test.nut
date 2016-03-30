class DeviceTestCase extends ImpTestCase {
  _i = null;

  function setUp() {
    this._i = CFAx33KL(hardware.uart6E);
    return "This should iterate contrast from 50 to 0";
  }

  /**
   * Should cycle contrast
   */
  function test_cycleContrastFromMaxToMin() {
    return Promise(function (ok, err) {

      imp.wakeup(0, function() {
        this._i.setContrast(50);
      }.bindenv(this));

      imp.wakeup(2, function() {
        this._i.setContrast(30);
      }.bindenv(this));

      imp.wakeup(4, function() {
        this._i.setContrast(16);
      }.bindenv(this));

      imp.wakeup(6, function() {
        this._i.setContrast(1);
        ok();
      }.bindenv(this));

    }.bindenv(this));
  }
}

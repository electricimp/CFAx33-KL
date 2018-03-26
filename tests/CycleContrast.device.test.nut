class CycleContrastTestCase extends ImpTestCase {
  _i = null;

  function setUp() {
    return Promise(function (ok, err) {
      this._i = CFAx33KL(hardware.uart6E);
      this._i.onError(function(e) {
        this.info(e);
      }.bindenv(this))
      this._i.clearAll(function(res1) {
        this._i.setText(0, 0, "Contrast Tests", function(res) {
            ("err" in res || "err" in res1) ? err(res.err) : ok("This should iterate contrast from 50 to 0");
        }.bindenv(this))
      }.bindenv(this))
    }.bindenv(this));
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
        this._i.setContrast(20);
      }.bindenv(this));

      imp.wakeup(6, function() {
        this._i.setContrast(16);
      }.bindenv(this));

      imp.wakeup(8, function() {
        this._i.setContrast(1);
        ok();
      }.bindenv(this));

    }.bindenv(this));
  }

  function tearDown() {
    return Promise(function (ok, err) {
      this._i.clearAll(function(res) {
        this._i.setContrast(16);
        ok("Contrast tests completed");
      }.bindenv(this));
    }.bindenv(this));
  }
}

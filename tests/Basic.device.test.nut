class BasicTestCase extends ImpTestCase {
  _i = null;

  function setUp() {
    return Promise(function (ok, err) {
      this._i = CFAx33KL(hardware.uart6E);
      this._i.setContrast(16);
      this._i.onError(function(e) {
        this.info(e);
      }.bindenv(this))
      this._i.clearAll(function(res1) {
        this._i.setText(0, 0, "Basic Tests", function(res) {
          imp.wakeup(2, function() {
            ("err" in res || "err" in res1) ? err(res.err) : ok("Basic tests");
          }.bindenv(this))
        }.bindenv(this))
      }.bindenv(this))
    }.bindenv(this));
  }

  /**
   * Should set random text
   */
  function test01_setText() {
    this.info("starting test 1")
    
    return Promise(function (ok, err) {
      this._i.setText(0, 0, "################", function (res) {
        if ("err" in res) {
          err(res.err)
        } else {
          imp.wakeup(2, function() {
            this._i.setText(0, 1, "################", function (res) {
              if ("err" in res) {
                err(res.err);
              } else {
                imp.wakeup(2, function() {
                  this.info("test 1 done");
                  ok();
                }.bindenv(this)) // wakeup 
              }
            }.bindenv(this)); // set text 0 1
          }.bindenv(this)); // wakeup
        };
      }.bindenv(this)); // set text 0 0
    }.bindenv(this)); // promise

  }

  /**
   * Should set random text on the first line
   */
  function test02_setRandomTextOnLine1() {
    this.info("Starting test 2");
    return Promise(function (ok, err) {
      imp.wakeup(1, function () {
        this._i.setLine1("" + math.rand(), function (res) {
          imp.wakeup(2, function() {
            this.info("test 2 done");
            "err" in res ? err(res.err) : ok();
          }.bindenv(this)) // wakeup
        }.bindenv(this)); // set line1
      }.bindenv(this)); // wakeup 
    }.bindenv(this)); // promise
  }

  /**
   * Should set random text on the second line
   */
  function test03_setRandomTextOnLine1() {
    this.info("Starting test 3");
    return Promise(function (ok, err) {
      imp.wakeup(1, function () {
        this._i.setLine2("" + math.rand(), function (res) {
          imp.wakeup(2, function() {
            this.info("test 3 done");
            "err" in res ? err(res.err) : ok();
          }.bindenv(this)) // wakeup
        }.bindenv(this)); // set line2 
      }.bindenv(this)); // wakeup
    }.bindenv(this)); // promise
  }

  function test04_getVersion() {
    return Promise(function (ok, err) {
      this._i.getVersion(function (res) {
        "err" in res ? err(res.err) : ok("Version" + res.version);
      });
    }.bindenv(this));
  }

  function tearDown() {
    return Promise(function (ok, err) {
      this._i.clearAll(function(res) {
        ok("Basic tests completed");
      }.bindenv(this));
    }.bindenv(this));
  }
}

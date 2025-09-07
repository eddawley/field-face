import Toybox.System;
import Toybox.Lang;

class RefreshContext {
    public var clockTime as System.ClockTime;
    public var sleeping as Boolean;
    
    public function initialize(clockTime as System.ClockTime, sleeping as Boolean) {
        self.clockTime = clockTime;
        self.sleeping = sleeping;
    }
}
    
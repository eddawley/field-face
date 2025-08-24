import Toybox.System;
import Toybox.Lang;

class RefreshContext {
    private var _clockTime as System.ClockTime;
    private var _isAwake as Boolean;
    private var _currentTime as Number;
    
    public function initialize(clockTime as System.ClockTime, isAwake as Boolean) {
        _clockTime = clockTime;
        _isAwake = isAwake;
        _currentTime = clockTime.hour * 3600 + clockTime.min * 60 + clockTime.sec;
    }
    
    public function getClockTime() as System.ClockTime {
        return _clockTime;
    }
    
    public function isAwake() as Boolean {
        return _isAwake;
    }
    
    public function getCurrentTime() as Number {
        return _currentTime;
    }
    
    public function shouldUpdate(lastUpdateTime as Number, interval as Number) as Boolean {
        return lastUpdateTime == 0 || (_currentTime - lastUpdateTime) >= interval;
    }
}
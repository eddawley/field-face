import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;

class HeartRateField extends Field {
    public function initialize(location as Number) {
        Field.initialize(location, 30); // 30 seconds when awake, 120 when sleeping
        _font = Graphics.FONT_TINY;
    }
    
    public function refreshValue(clockTime as System.ClockTime, isAwake as Boolean) as Void {
        if (!isAwake) {
            return; // Only update when awake
        }
        
        var currentTime = clockTime.hour * 3600 + clockTime.min * 60 + clockTime.sec;
        var interval = isAwake ? 30 : 120;
        
        if (_lastUpdateTime == 0 || (currentTime - _lastUpdateTime) >= interval) {
            _lastUpdateTime = currentTime;
            
            var hrHistory = ActivityMonitor.getHeartRateHistory(1, true);
            if (hrHistory != null) {
                var hrIterator = hrHistory.next();
                if (hrIterator != null && hrIterator.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    _lastValue = Lang.format("$1$", [hrIterator.heartRate]);
                } else {
                    _lastValue = "--";
                }
            } else {
                _lastValue = "--";
            }
        }
    }
    
    public function draw(dc as Graphics.Dc, isAwake as Boolean) as Void {
        // Only draw when awake and has valid value
        if (isAwake && _lastValue != "" && _lastValue != "--") {
            Field.draw(dc, isAwake);
        }
    }
    
    public function loadIcon() as Void {
        try {
            _icon = WatchUi.loadResource(Rez.Drawables.HeartRateIcon);
        } catch(ex) {
            _icon = null;
        }
    }
}
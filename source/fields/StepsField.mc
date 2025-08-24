import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;

class StepsField extends Field {
    public function initialize(location as Number) {
        Field.initialize(location, 600); // 10 minutes
        _font = Graphics.FONT_TINY;
    }
    
    public function refreshValue(clockTime as System.ClockTime, isAwake as Boolean) as Void {
        var currentTime = clockTime.hour * 3600 + clockTime.min * 60 + clockTime.sec;
        if (shouldUpdate(currentTime)) {
            _lastUpdateTime = currentTime;
            
            var activityInfo = ActivityMonitor.getInfo();
            if (activityInfo != null && activityInfo.steps != null) {
                _lastValue = Lang.format("$1$", [activityInfo.steps]);
            } else {
                _lastValue = "--";
            }
        }
    }
    
    public function loadIcon() as Void {
        try {
            _icon = WatchUi.loadResource(Rez.Drawables.StepsIcon);
        } catch(ex) {
            _icon = null;
        }
    }
}
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;

class SecondsField extends Field {
    public function initialize(location as Number) {
        Field.initialize(location, 1); // Updates every second
        _font = Graphics.FONT_XTINY;
    }
    
    protected function _refreshValue(context as RefreshContext) as Void {
        if (context.isAwake()) {
            var clockTime = context.getClockTime();
            _lastValue = clockTime.sec.format("%02d");
        }
    }
    
    public function draw(dc as Graphics.Dc, isAwake as Boolean) as Void {
        // Only draw when awake and has value
        if (isAwake && _lastValue != "") {
            dc.drawText(_x, _y, _font, _lastValue, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }
}
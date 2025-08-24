import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

class DateField extends Field {
    public function initialize(location as Number) {
        Field.initialize(location, 86400); // Daily updates
        _font = Graphics.FONT_XTINY;
    }
    
    public function refreshValue(clockTime as System.ClockTime, isAwake as Boolean) as Void {
        // Update at midnight or first run
        if (_lastUpdateTime == 0 || (clockTime.hour == 0 && clockTime.min == 0)) {
            _lastUpdateTime = clockTime.hour * 3600 + clockTime.min * 60 + clockTime.sec;
            
            var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
            var fullDayName = today.day_of_week;
            var monthAbbrev = today.month.substring(0, 3);
            _lastValue = Lang.format("$1$, $2$ $3$", [fullDayName, monthAbbrev, today.day]);
        }
    }
    
    public function draw(dc as Graphics.Dc, isAwake as Boolean) as Void {
        // DateField uses left justification
        dc.drawText(_x, _y, _font, _lastValue, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
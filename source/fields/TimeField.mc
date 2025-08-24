import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeField extends Field {
    private var _is24Hour as Boolean = false;
    
    public function initialize(location as Number) {
        Field.initialize(location, 1); // Updates every second
        _font = Graphics.FONT_NUMBER_THAI_HOT;
    }
    
    public function set24Hour(is24Hour as Boolean) as Void {
        _is24Hour = is24Hour;
    }
    
    public function refreshValue(clockTime as System.ClockTime, isAwake as Boolean) as Void {
        if (_is24Hour) {
            _lastValue = Lang.format("$1$:$2$", [
                clockTime.hour.format("%02d"),
                clockTime.min.format("%02d")
            ]);
        } else {
            var hour = clockTime.hour;
            if (hour == 0) {
                hour = 12;
            } else if (hour > 12) {
                hour = hour - 12;
            }
            _lastValue = Lang.format("$1$:$2$", [
                hour,
                clockTime.min.format("%02d")
            ]);
        }
    }
    
    public function draw(dc as Graphics.Dc, isAwake as Boolean) as Void {
        dc.drawText(_x, _y, _font, _lastValue, Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    public function getTimeWidth(dc as Graphics.Dc) as Number {
        return dc.getTextWidthInPixels(_lastValue, _font);
    }
    
    public function loadIcon() as Void {
        try {
            _font = WatchUi.loadResource(Rez.Fonts.LargeTimeFont);
        } catch(ex) {
            // Font loading failed, use default
        }
    }
}
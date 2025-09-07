import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;

class TimeField extends Field {
    private var _is24Hour as Boolean = false;
    
    public function initialize() {
        Field.initialize();
        font = Graphics.FONT_NUMBER_THAI_HOT;
    }
    
    public function set24Hour(is24Hour as Boolean) as Void {
        _is24Hour = is24Hour;
    }
    
    public function refresh(context as RefreshContext) as Time.Duration {
        var clockTime = context.clockTime;
        if (_is24Hour) {
            text = Lang.format("$1$:$2$", [
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
            text = Lang.format("$1$:$2$", [
                hour,
                clockTime.min.format("%02d")
            ]);
        }

        return new Time.Duration(60 - clockTime.sec);
    }
    
    public function getTimeWidth(dc as Graphics.Dc) as Number {
        return dc.getTextWidthInPixels(text, font);
    }
    
    public function loadResources() as Void {
        try {
            font = WatchUi.loadResource(Rez.Fonts.LargeTimeFont);
        } catch(ex) {
            // Font loading failed, use default
        }
    }
}
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

class BatteryField extends Field {
    public function initialize(location as Number) {
        Field.initialize(location, 300); // 5 minutes
        _font = Graphics.FONT_TINY;
    }
    
    public function refreshValue(clockTime as System.ClockTime, isAwake as Boolean) as Void {
        var currentTime = clockTime.hour * 3600 + clockTime.min * 60 + clockTime.sec;
        if (shouldUpdate(currentTime)) {
            _lastUpdateTime = currentTime;
            
            var stats = System.getSystemStats();
            if (stats != null) {
                var battery = stats.battery;
                var batteryInDays = stats.batteryInDays;
                if (batteryInDays != null && batteryInDays > 1) {
                    _lastValue = Lang.format("$1$d", [batteryInDays.format("%.0f")]);
                } else if (battery != null) {
                    _lastValue = Lang.format("$1$%", [battery.format("%.0f")]);
                } else {
                    _lastValue = "--";
                }
            } else {
                _lastValue = "--";
            }
        }
    }
    
    public function loadIcon() as Void {
        try {
            _icon = WatchUi.loadResource(Rez.Drawables.BatteryIcon);
        } catch(ex) {
            _icon = null;
        }
    }
    
    public function draw(dc as Graphics.Dc, isAwake as Boolean) as Void {
        // Battery field uses special right-aligned positioning at x=99
        if (_icon != null) {
            var iconWidth = 12;
            var gap = 2;
            var textWidth = dc.getTextWidthInPixels(_lastValue, _font);
            var totalWidth = iconWidth + gap + textWidth;
            var startX = _x - totalWidth;
            
            dc.drawBitmap(startX, _y, _icon);
            dc.drawText(startX + iconWidth + gap, _y - 5, _font, _lastValue, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(_x - dc.getTextWidthInPixels(_lastValue, _font), _y - 5, _font, _lastValue, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }
}
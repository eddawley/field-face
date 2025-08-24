import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;

module LayoutLocation {
    const TOP = 0;
    const UPPER_RIGHT = 1;
    const RIGHT_OF_TIME = 2;
    const ABOVE_TIME = 3;
    const TIME = 4;
    const BOTTOM = 5;
}

class Field {
    protected var _location as Number;
    protected var _updateInterval as Number;
    protected var _x as Number = 0;
    protected var _y as Number = 0;
    protected var _lastValue as String = "";
    protected var _lastUpdateTime as Number = 0;
    protected var _icon = null;
    protected var _font as Graphics.FontType = Graphics.FONT_TINY;
    
    public function initialize(location as Number, updateInterval as Number) {
        _location = location;
        _updateInterval = updateInterval;
    }
    
    public function getLocation() as Number {
        return _location;
    }
    
    public function setPosition(x as Number, y as Number) as Void {
        _x = x;
        _y = y;
    }
    
    public function refreshValue(context as RefreshContext) as Void {
        _refreshValue(context);
    }
    
    protected function _refreshValue(context as RefreshContext) as Void {
        // Override in subclasses
    }
    
    public function loadIcon() as Void {
        // Override in subclasses that need icons
    }
    
    public function draw(dc as Graphics.Dc, isAwake as Boolean) as Void {
        if (_icon != null) {
            var iconWidth = 12;
            var gap = 2;
            var textWidth = dc.getTextWidthInPixels(_lastValue, _font);
            var totalWidth = iconWidth + gap + textWidth;
            var startX = _x - totalWidth / 2;
            
            dc.drawBitmap(startX, _y + 5, _icon);
            dc.drawText(startX + iconWidth + gap, _y, _font, _lastValue, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(_x, _y, _font, _lastValue, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
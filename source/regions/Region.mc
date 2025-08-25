
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Time;


class Drawn {
    public var text as String or Null = null;
    public var icon as Graphics.BitmapReference or Null = null; 
}


class Region{
    protected var _name as String = "unknown";
    protected var _layer as WatchUi.Layer;
    protected var _field as Field;
    private var _lastDrawn as Drawn = new Drawn();
    protected var _nextRefresh as Time.Moment = new Time.Moment(999999999);
    private var _cleared as Drawn = new Drawn();

    public function initialize(name as String, layer as WatchUi.Layer, field as Field){
        _name = name;
        _layer = layer;
        _field = field;
    }

    public function refresh(context as RefreshContext) as Void {
        var now = Time.now();

        // check sleep
        if (context.sleeping and !_field.allowed_when_sleeping) {
            // clear if we haven't yet
            if (_lastDrawn != _cleared) {
                _clear();
                _lastDrawn = _cleared;
                _field.text = _cleared.text;
            }
            return;
        }
        
        // only refresh if enough time has passed
        if (now.lessThan(_nextRefresh)) {
            return;
        }

        var interval = _field.refresh(context);
        _nextRefresh = now.add(interval);
    }

    public function loadResources() as Void {
        _field.loadResources();
    }

    public function draw(context as DrawContext) as Void{
        // only draw if content is changing
        if (_field.text == _lastDrawn.text and _field.icon == _lastDrawn.icon) {
            return;
        }

        var dc = _layer.getDc();

        _clear();
        
        // draw
        if (_field.icon != null) {
            var iconWidth = 12;
            var gap = 2;

            dc.drawBitmap(0, 5, _field.icon);
            dc.drawText(iconWidth + gap, 0, _field.font, _field.text, Graphics.TEXT_JUSTIFY_LEFT);
        }
        else {
            if (_field instanceof TimeField) {
                dc.drawText(131, 0, _field.font, _field.text, Graphics.TEXT_JUSTIFY_RIGHT);
            } else {
                dc.drawText(0, 0, _field.font, _field.text, Graphics.TEXT_JUSTIFY_LEFT);
            }
        }

        _lastDrawn = new Drawn();
        _lastDrawn.text = _field.text;
        _lastDrawn.icon = _field.icon;

    }

    protected function _clear() as Void {
        var dc = _layer.getDc();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    }
}
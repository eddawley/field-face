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
    
    protected function _refreshValue(context as RefreshContext) as Void {
        if (context.shouldUpdate(_lastUpdateTime, _updateInterval)) {
            _lastUpdateTime = context.getCurrentTime();
            
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
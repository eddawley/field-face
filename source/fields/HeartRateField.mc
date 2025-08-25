import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Time;

class HeartRateField extends Field {
    public function initialize() {
        Field.initialize();
        font = Graphics.FONT_TINY;
        allowed_when_sleeping = false;
    }
    
    public function refresh(context as RefreshContext) as Time.Duration {
        var hrHistory = ActivityMonitor.getHeartRateHistory(1, true);
        var hrIterator = hrHistory.next();
        if (hrIterator != null && hrIterator.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            text = Lang.format("$1$", [hrIterator.heartRate]);
        } else {
            text = "--";
        }

        return new Time.Duration(30);
    }
    
    public function loadResources() as Void {
        try {
            icon = WatchUi.loadResource(Rez.Drawables.HeartRateIcon);
        } catch(ex) {}
    }
}
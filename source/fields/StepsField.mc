import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Time;

class StepsField extends Field {
    private var _interval as Time.Duration = new Time.Duration(60); // 1 minute

    public function initialize() {
        Field.initialize();
        font = Graphics.FONT_TINY;
    }
    
    public function refresh(context as RefreshContext) as Time.Duration {
        var activityInfo = ActivityMonitor.getInfo();
        if (activityInfo != null && activityInfo.steps != null) {
            text = Lang.format("$1$", [activityInfo.steps]);
        } else {
            text = "--";
        }

        return _interval;
    }
    
    public function loadResources() as Void {
        try {
            icon = WatchUi.loadResource(Rez.Drawables.StepsIcon);
        } catch(ex) {}
    }
}
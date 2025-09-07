import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;

class BatteryField extends Field {
    public function initialize() {
        Field.initialize();
        font = Graphics.FONT_TINY;
    }
    
    public function refresh(context as RefreshContext) as Time.Duration {
        var interval = new Time.Duration(300);

        var stats = System.getSystemStats();
        var battery = stats.battery;
        var batteryInDays = stats.batteryInDays;
        if (batteryInDays != null && batteryInDays > 1) {
            text = Lang.format("$1$d", [batteryInDays.format("%.0f")]);
        } else if (battery != null) {
            text = Lang.format("$1$%", [battery.format("%.0f")]);
        } else {
            text = "--";
        }

        return interval;
    }
    
    public function loadResources() as Void {
        try {
            icon = WatchUi.loadResource(Rez.Drawables.BatteryIcon);
        } catch(ex) {}
    }
}
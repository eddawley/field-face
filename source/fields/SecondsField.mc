import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;

class SecondsField extends Field {
    public function initialize() {
        Field.initialize();
        font = Graphics.FONT_XTINY;
        allowed_when_sleeping = false;
    }
    
    public function refresh(context as RefreshContext) as Time.Duration {
        text = context.clockTime.sec.format("%02d");
        return new Time.Duration(1);
    }
}
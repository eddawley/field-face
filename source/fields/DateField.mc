import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

class DateField extends Field {
    public function initialize() {
        Field.initialize();
        font = Graphics.FONT_XTINY;
    }
    
    public function refresh(context as RefreshContext) as Time.Duration {
        // Update at midnight or first run
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var fullDayName = today.day_of_week;
        var monthAbbrev = today.month.substring(0, 3);
        text = Lang.format("$1$, $2$ $3$", [fullDayName, monthAbbrev, today.day]);

        // refresh midnight tomorrow
        var secondsToday = (Gregorian.SECONDS_PER_HOUR * today.hour) + (Gregorian.SECONDS_PER_MINUTE * today.min) + today.sec;
        return new Time.Duration(Gregorian.SECONDS_PER_DAY - secondsToday);
    }
} 
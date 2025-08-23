import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Application;

class CleanFaceView extends WatchUi.WatchFace {
    private var _isAwake = false;
    private var _is24Hour = null;
    private var _batteryString = "--";
    private var _stepsString = "--";
    private var _dayOfWeekString = "";
    private var _dayString = "";
    private var _batteryIcon = null;
    private var _stepsIcon = null;
    private var _largeTimeFont = null;
    private var _cachedLayout = null;
    private var _lastWidth = 0;
    private var _lastHeight = 0;
    private var _lastTimeFont = null;
    private var _lastBatteryMinute = -1;
    private var _lastStepsMinute = -1;
    private var _lastDateDay = -1;
    private var _initialized = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onLoad(dc as Dc) as Void {
        // Initialize cached values
        _is24Hour = System.getDeviceSettings().is24Hour;
        updateBattery();
        updateSteps();
        updateDate();
        loadIcons();
        // Force initial update request
        WatchUi.requestUpdate();
    }

    function onUnload() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Force initial update of battery, steps, date and icons on first render
        if (!_initialized) {
            _initialized = true;
            updateBattery();
            updateSteps();
            updateDate();
            loadIcons();
        }
        
        var clockTime = System.getClockTime();
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Update cached values and layout based on conditions
        var timeFont = _largeTimeFont != null ? _largeTimeFont : Graphics.FONT_NUMBER_THAI_HOT;
        updateCachedValues(clockTime, dc, width, height, timeFont);
        
        // Draw all display elements using cached layout
        drawBattery(dc, _cachedLayout);
        drawDate(dc, _cachedLayout);
        drawTime(dc, _cachedLayout, clockTime);
        drawSteps(dc, _cachedLayout);
    }
    
    private function calculateLayout(dc as Dc, width as Number, height as Number, timeFont) as Dictionary {
        // Calculate time dimensions and position
        var timeWidth = dc.getTextWidthInPixels("00:00", timeFont);
        var timeX = width / 2;
        var timeY = height / 2 - 22;
        
        // Calculate all positions relative to time
        var layout = {
            // Time positioning
            "timeX" => timeX,
            "timeY" => timeY,
            "timeFont" => timeFont,
            "timeWidth" => timeWidth,
            
            // Date directly above time, left aligned (below battery)
            "dateX" => timeX - timeWidth / 2,
            "dateY" => timeY - 10,
            
            // Battery at top, avoiding right edge at 99px
            "batteryMaxX" => 99,
            "batteryY" => 20,
            "batteryTextY" => 15,
            
            // Seconds centered in right subscreen (100px to edge)
            "secondsX" => 100 + (width - 100) / 2 + 5,
            "secondsY" => 20,
            
            // Steps at bottom center
            "stepsX" => width / 2,
            "stepsY" => height - 15,
            "stepsTextY" => height - 20
        };
        
        return layout;
    }
    
    private function updateCachedValues(clockTime as ClockTime, dc as Dc, width as Number, height as Number, timeFont) as Void {
        // Update battery every 5 minutes
        if (clockTime.min != _lastBatteryMinute && clockTime.min % 5 == 0) {
            _lastBatteryMinute = clockTime.min;
            updateBattery();
        }
        
        // Update date daily (when day changes)
        if (clockTime.hour == 0 && clockTime.min == 0 && _lastDateDay != clockTime.sec) {
            _lastDateDay = clockTime.sec;
            updateDate();
        }
        
        // Update steps every 10 minutes
        if (clockTime.min != _lastStepsMinute && clockTime.min % 10 == 0) {
            _lastStepsMinute = clockTime.min;
            updateSteps();
        }
        
        // Update layout when screen dimensions or font changes
        if (_cachedLayout == null || width != _lastWidth || height != _lastHeight || timeFont != _lastTimeFont) {
            _cachedLayout = calculateLayout(dc, width, height, timeFont);
            _lastWidth = width;
            _lastHeight = height;
            _lastTimeFont = timeFont;
        }
    }
    
    private function drawBattery(dc as Dc, layout as Dictionary) as Void {
        // Battery at top with icon, can extend up to pixel 99
        if (_batteryIcon != null) {
            var iconWidth = 12;
            var gap = 2;
            var textWidth = dc.getTextWidthInPixels(_batteryString, Graphics.FONT_TINY);
            var totalWidth = iconWidth + gap + textWidth;
            var startX = layout["batteryMaxX"] - totalWidth;
            
            dc.drawBitmap(startX, layout["batteryY"], _batteryIcon);
            dc.drawText(startX + iconWidth + gap, layout["batteryTextY"], Graphics.FONT_TINY, _batteryString, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(layout["batteryMaxX"] - dc.getTextWidthInPixels(_batteryString, Graphics.FONT_TINY), layout["batteryTextY"], Graphics.FONT_TINY, _batteryString, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }
    
    private function drawDate(dc as Dc, layout as Dictionary) as Void {
        // Date directly above time, left justified to time
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var fullDayName = today.day_of_week;
        var monthAbbrev = today.month.substring(0, 3);
        var dateString = Lang.format("$1$, $2$ $3$", [fullDayName, monthAbbrev, today.day]);
        
        dc.drawText(
            layout["dateX"],
            layout["dateY"],
            Graphics.FONT_XTINY,
            dateString,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }
    
    private function drawTime(dc as Dc, layout as Dictionary, clockTime as ClockTime) as Void {
        // Use cached 24-hour setting
        var timeString;
        if (_is24Hour) {
            timeString = Lang.format("$1$:$2$", [
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
            timeString = Lang.format("$1$:$2$", [
                hour,
                clockTime.min.format("%02d")
            ]);
        }
        var secondsString = clockTime.sec.format("%02d");
        
        // Time in center with large custom font
        dc.drawText(
            layout["timeX"],
            layout["timeY"],
            layout["timeFont"],
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        _isAwake = true;
        // Seconds centered in upper right subscreen (only when awake)
        if (_isAwake) {
            dc.drawText(
                layout["secondsX"],
                layout["secondsY"],
                Graphics.FONT_SMALL,
                secondsString,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
    
    private function drawSteps(dc as Dc, layout as Dictionary) as Void {
        // Steps at bottom with icon
        if (_stepsIcon != null) {
            var iconWidth = 12;
            var gap = 2;
            var textWidth = dc.getTextWidthInPixels(_stepsString, Graphics.FONT_TINY);
            var totalWidth = iconWidth + gap + textWidth;
            var startX = layout["stepsX"] - totalWidth / 2;
            
            dc.drawBitmap(startX, layout["stepsY"], _stepsIcon);
            dc.drawText(startX + iconWidth + gap, layout["stepsTextY"], Graphics.FONT_TINY, _stepsString, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(layout["stepsX"], layout["stepsTextY"], Graphics.FONT_TINY, _stepsString, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        _isAwake = true;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        _isAwake = false;
    }

    function onSettingsChanged() as Void {
        _is24Hour = System.getDeviceSettings().is24Hour;
    }
    
    private function updateBattery() as Void {
        var stats = System.getSystemStats();
        if (stats != null) {
            var battery = stats.battery;
            var batteryInDays = stats.batteryInDays;
            if (batteryInDays != null && batteryInDays > 1) {
                _batteryString = Lang.format("$1$d", [batteryInDays.format("%.0f")]);
            } else if (battery != null) {
                _batteryString = Lang.format("$1$%", [battery.format("%.0f")]);
            } else {
                _batteryString = "--";
            }
        } else {
            _batteryString = "--";
        }
    }
    
    private function updateSteps() as Void {
        var activityInfo = ActivityMonitor.getInfo();
        if (activityInfo != null && activityInfo.steps != null) {
            _stepsString = Lang.format("$1$", [activityInfo.steps]);
        } else {
            _stepsString = "--";
        }
    }
    
    private function updateDate() as Void {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        if (today != null && today.day_of_week != null && today.day != null) {
            _dayOfWeekString = today.day_of_week.substring(0, 3).toUpper();
            _dayString = Lang.format("$1$", [today.day]);
        } else {
            _dayOfWeekString = "";
            _dayString = "--";
        }
    }
    
    private function loadIcons() as Void {
        _batteryIcon = WatchUi.loadResource(Rez.Drawables.BatteryIcon);
        _stepsIcon = WatchUi.loadResource(Rez.Drawables.StepsIcon);
        _largeTimeFont = WatchUi.loadResource(Rez.Fonts.LargeTimeFont);
    }

}
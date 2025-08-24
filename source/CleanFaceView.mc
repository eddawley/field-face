import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Application;

class Layout {
    public var timeX as Number;
    public var timeY as Number;
    public var timeFont as Graphics.FontType;
    public var timeWidth as Number;
    public var dateX as Number;
    public var dateY as Number;
    public var batteryMaxX as Number;
    public var batteryY as Number;
    public var batteryTextY as Number;
    public var secondsX as Number;
    public var secondsY as Number;
    public var heartRateX as Number;
    public var heartRateY as Number;
    public var stepsX as Number;
    public var stepsY as Number;
    public var stepsTextY as Number;
    
    function initialize(
        timeX as Number, timeY as Number, timeFont as Graphics.FontType, timeWidth as Number,
        dateX as Number, dateY as Number,
        batteryMaxX as Number, batteryY as Number, batteryTextY as Number,
        secondsX as Number, secondsY as Number,
        heartRateX as Number, heartRateY as Number,
        stepsX as Number, stepsY as Number, stepsTextY as Number
    ) {
        self.timeX = timeX;
        self.timeY = timeY;
        self.timeFont = timeFont;
        self.timeWidth = timeWidth;
        self.dateX = dateX;
        self.dateY = dateY;
        self.batteryMaxX = batteryMaxX;
        self.batteryY = batteryY;
        self.batteryTextY = batteryTextY;
        self.secondsX = secondsX;
        self.secondsY = secondsY;
        self.heartRateX = heartRateX;
        self.heartRateY = heartRateY;
        self.stepsX = stepsX;
        self.stepsY = stepsY;
        self.stepsTextY = stepsTextY;
    }
}

class CleanFaceView extends WatchUi.WatchFace {
    private var _isAwake = false;
    private var _is24Hour = null;
    private var _batteryString = "--";
    private var _stepsString = "--";
    private var _heartRateString = "--";
    private var _batteryIcon = null;
    private var _stepsIcon = null;
    private var _heartRateIcon = null;
    private var _largeTimeFont = null;
    private var _cachedLayout as Layout or Null = null;
    private var _lastWidth = 0;
    private var _lastHeight = 0;
    private var _lastTimeFont = null;
    private var _lastBatteryMinute = -1;
    private var _lastStepsMinute = -1;
    private var _lastDateDay = -1;
    private var _lastHeartRateTime = 0;

    function initialize() {
        WatchFace.initialize();
    }

    function onLoad(dc as Dc) as Void {
        // Initialize settings only
        _is24Hour = System.getDeviceSettings().is24Hour;
        
        // Note: Layout, data, and icon initialization deferred to first onUpdate()
        // where we have proper drawing context dimensions

        
        // Force initial update request
        WatchUi.requestUpdate();
    }

    function onUnload() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        
        var clockTime = System.getClockTime();
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Update cached values and layout based on conditions
        var timeFont = _largeTimeFont != null ? _largeTimeFont : Graphics.FONT_NUMBER_THAI_HOT;
        updateCachedValues(clockTime, dc, width, height, timeFont);
        
        // Draw all display elements using cached layout
        drawBattery(dc);
        drawDate(dc);
        drawTime(dc, clockTime);
        drawSteps(dc);
        drawHeartRate(dc);
    }
    
    private function calculateLayout(dc as Dc, width as Number, height as Number, timeFont as Graphics.FontType) as Layout {
        // Calculate time dimensions and position
        var timeWidth = dc.getTextWidthInPixels("00:00", timeFont);
        var timeX = width / 2 - 2;
        var timeY = height / 2 - 22;
        
        // Calculate all positions relative to time
        return new Layout(
            timeX, timeY, timeFont, timeWidth,
            timeX - timeWidth / 2, timeY - 10,
            99, 20, 15,
            timeX + timeWidth / 2 + 1, timeY + 10,
            100 + (width - 100) / 2 + 5, 20,
            width / 2, height - 15, height - 20
        );
    }
    
    private function updateCachedValues(clockTime as ClockTime, dc as Dc, width as Number, height as Number, timeFont as Graphics.FontType) as Void {
        // Load icons on first run
        if (_batteryIcon == null) {
            loadIcons();
        }
        
        // Update battery every 5 minutes or on first run
        if (_lastBatteryMinute == -1 || (clockTime.min != _lastBatteryMinute && clockTime.min % 5 == 0)) {
            _lastBatteryMinute = clockTime.min;
            updateBattery();
        }
        
        // Update date daily or on first run  
        if (_lastDateDay == -1 || (clockTime.hour == 0 && clockTime.min == 0 && _lastDateDay != clockTime.sec)) {
            _lastDateDay = clockTime.sec;
            updateDate();
        }
        
        // Update steps every 10 minutes or on first run
        if (_lastStepsMinute == -1 || (clockTime.min != _lastStepsMinute && clockTime.min % 10 == 0)) {
            _lastStepsMinute = clockTime.min;
            updateSteps();
        }
        
        // Update heart rate with smart timing (only when awake) or on first run
        if (_isAwake) {
            var currentTime = clockTime.hour * 3600 + clockTime.min * 60 + clockTime.sec;
            var awakeInterval = 30; // 30 seconds when awake
            var sleepInterval = 120; // 120 seconds when sleeping
            var interval = _isAwake ? awakeInterval : sleepInterval;
            
            if (_lastHeartRateTime == 0 || currentTime - _lastHeartRateTime >= interval) {
                _lastHeartRateTime = currentTime;
                updateHeartRate();
            }
        }
        
        // Update layout when screen dimensions or font changes
        if (_cachedLayout == null || width != _lastWidth || height != _lastHeight || timeFont != _lastTimeFont) {
            _cachedLayout = calculateLayout(dc, width, height, timeFont);
            _lastWidth = width;
            _lastHeight = height;
            _lastTimeFont = timeFont;
        }
    }
    
    private function drawBattery(dc as Dc) as Void {
        // Battery at top with icon, can extend up to pixel 99
        if (_batteryIcon != null) {
            var iconWidth = 12;
            var gap = 2;
            var textWidth = dc.getTextWidthInPixels(_batteryString, Graphics.FONT_TINY);
            var totalWidth = iconWidth + gap + textWidth;
            var startX = _cachedLayout.batteryMaxX - totalWidth;
            
            dc.drawBitmap(startX, _cachedLayout.batteryY, _batteryIcon);
            dc.drawText(startX + iconWidth + gap, _cachedLayout.batteryTextY, Graphics.FONT_TINY, _batteryString, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(_cachedLayout.batteryMaxX - dc.getTextWidthInPixels(_batteryString, Graphics.FONT_TINY), _cachedLayout.batteryTextY, Graphics.FONT_TINY, _batteryString, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }
    
    private function drawDate(dc as Dc) as Void {
        // Date directly above time, left justified to time
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var fullDayName = today.day_of_week;
        var monthAbbrev = today.month.substring(0, 3);
        var dateString = Lang.format("$1$, $2$ $3$", [fullDayName, monthAbbrev, today.day]);
        
        dc.drawText(
            _cachedLayout.dateX,
            _cachedLayout.dateY,
            Graphics.FONT_XTINY,
            dateString,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }
    
    private function drawTime(dc as Dc, clockTime as ClockTime) as Void {
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
            _cachedLayout.timeX,
            _cachedLayout.timeY,
            _cachedLayout.timeFont,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        // Seconds right after time with minimal spacing (only when awake)
        if (_isAwake) {
            dc.drawText(
                _cachedLayout.secondsX,
                _cachedLayout.secondsY,
                Graphics.FONT_XTINY,
                secondsString,
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }
    
    private function drawSteps(dc as Dc) as Void {
        // Steps at bottom with icon
        if (_stepsIcon != null) {
            var iconWidth = 12;
            var gap = 2;
            var textWidth = dc.getTextWidthInPixels(_stepsString, Graphics.FONT_TINY);
            var totalWidth = iconWidth + gap + textWidth;
            var startX = _cachedLayout.stepsX - totalWidth / 2;
            
            dc.drawBitmap(startX, _cachedLayout.stepsY, _stepsIcon);
            dc.drawText(startX + iconWidth + gap, _cachedLayout.stepsTextY, Graphics.FONT_TINY, _stepsString, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(_cachedLayout.stepsX, _cachedLayout.stepsTextY, Graphics.FONT_TINY, _stepsString, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
    
    private function drawHeartRate(dc as Dc) as Void {
        // Heart rate centered in top right subscreen (only when awake)
        if (_isAwake) {
            if (_heartRateIcon != null) {
                var iconWidth = 12;
                var gap = 2;
                var textWidth = dc.getTextWidthInPixels(_heartRateString, Graphics.FONT_TINY);
                var totalWidth = iconWidth + gap + textWidth;
                var startX = _cachedLayout.heartRateX - totalWidth / 2;
                
                dc.drawBitmap(startX, _cachedLayout.heartRateY + 5, _heartRateIcon);
                dc.drawText(startX + iconWidth + gap, _cachedLayout.heartRateY, Graphics.FONT_TINY, _heartRateString, Graphics.TEXT_JUSTIFY_LEFT);
            } else {
                dc.drawText(_cachedLayout.heartRateX, _cachedLayout.heartRateY, Graphics.FONT_TINY, _heartRateString, Graphics.TEXT_JUSTIFY_CENTER);
            }
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
        // Request update to clear seconds immediately
        WatchUi.requestUpdate();
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
        // Date is calculated on-demand in drawDate, no caching needed
    }
    
    private function updateHeartRate() as Void {
        var hrHistory = ActivityMonitor.getHeartRateHistory(1, true);
        if (hrHistory != null) {
            var hrIterator = hrHistory.next();
            if (hrIterator != null && hrIterator.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                _heartRateString = Lang.format("$1$", [hrIterator.heartRate]);
            } else {
                _heartRateString = "--";
            }
        } else {
            _heartRateString = "--";
        }
    }
    
    private function loadIcons() as Void {
        try {
            _batteryIcon = WatchUi.loadResource(Rez.Drawables.BatteryIcon);
        } catch(ex) {
            _batteryIcon = null;
        }
        try {
            _stepsIcon = WatchUi.loadResource(Rez.Drawables.StepsIcon);
        } catch(ex) {
            _stepsIcon = null;
        }
        try {
            _heartRateIcon = WatchUi.loadResource(Rez.Drawables.HeartRateIcon);
        } catch(ex) {
            _heartRateIcon = null;
        }
        try {
            _largeTimeFont = WatchUi.loadResource(Rez.Fonts.LargeTimeFont);
        } catch(ex) {
            _largeTimeFont = null;
        }
    }

}
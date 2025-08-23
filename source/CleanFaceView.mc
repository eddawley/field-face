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
        
        // Update cached values based on time intervals
        updateCachedValues(clockTime);
        
        // Draw all display elements
        drawBattery(dc, clockTime);
        drawDate(dc, width);
        drawTime(dc, width, height, clockTime);
        drawSteps(dc, width, height, clockTime);
    }
    
    private function updateCachedValues(clockTime as ClockTime) as Void {
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
    }
    
    private function drawBattery(dc as Dc, clockTime as ClockTime) as Void {
        // Battery at top with icon, can extend up to pixel 99
        if (_batteryIcon != null) {
            var iconWidth = 12;
            var gap = 2;
            var textWidth = dc.getTextWidthInPixels(_batteryString, Graphics.FONT_TINY);
            var totalWidth = iconWidth + gap + textWidth;
            var maxRightEdge = 99; // Last pixel before right subscreen
            var startX = maxRightEdge - totalWidth;
            
            dc.drawBitmap(startX, 20, _batteryIcon);
            dc.drawText(startX + iconWidth + gap, 15, Graphics.FONT_TINY, _batteryString, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(99 - dc.getTextWidthInPixels(_batteryString, Graphics.FONT_TINY), 30, Graphics.FONT_TINY, _batteryString, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }
    
    private function drawDate(dc as Dc, width as Number) as Void {
        // Date in top right corner (cached)
        var rightMargin = 20;
        var topMargin = 15;
        
        dc.drawText(width - rightMargin, topMargin, Graphics.FONT_TINY, _dayOfWeekString, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width - rightMargin, topMargin + 15, Graphics.FONT_SMALL, _dayString, Graphics.TEXT_JUSTIFY_RIGHT);
    }
    
    private function drawTime(dc as Dc, width as Number, height as Number, clockTime as ClockTime) as Void {
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
        
        // Time in center
        dc.drawText(
            width / 2,
            height / 2 - 15,
            Graphics.FONT_NUMBER_THAI_HOT,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        // Seconds right after time (only when awake)
        if (_isAwake) {
            var timeWidth = dc.getTextWidthInPixels(timeString, Graphics.FONT_NUMBER_THAI_HOT);
            dc.drawText(
                width / 2 + timeWidth / 2 + 5,
                height / 2 - 10,
                Graphics.FONT_SMALL,
                secondsString,
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }
    
    private function drawSteps(dc as Dc, width as Number, height as Number, clockTime as ClockTime) as Void {
        // Steps at bottom with icon
        if (_stepsIcon != null) {
            var iconWidth = 12;
            var gap = 2;
            var textWidth = dc.getTextWidthInPixels(_stepsString, Graphics.FONT_TINY);
            var totalWidth = iconWidth + gap + textWidth;
            var centerX = width / 2;
            var startX = centerX - totalWidth / 2;
            
            dc.drawBitmap(startX, height - 15, _stepsIcon);
            dc.drawText(startX + iconWidth + gap, height - 20, Graphics.FONT_TINY, _stepsString, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(width / 2, height - 20, Graphics.FONT_TINY, _stepsString, Graphics.TEXT_JUSTIFY_CENTER);
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
    }

}
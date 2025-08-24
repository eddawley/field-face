import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;

class CleanFaceView extends WatchUi.WatchFace {
    private var _isAwake = false;
    private var _is24Hour = null;
    private var _fieldManager as FieldManager;

    function initialize() {
        WatchFace.initialize();
        
        // Initialize field manager and add all fields
        _fieldManager = new FieldManager();
        
        // Add all fields in their default locations
        _fieldManager.addField(new TimeField(LayoutLocation.TIME));
        _fieldManager.addField(new BatteryField(LayoutLocation.TOP));
        _fieldManager.addField(new StepsField(LayoutLocation.BOTTOM));
        // _fieldManager.addField(new HeartRateField(LayoutLocation.UPPER_RIGHT));
        _fieldManager.addField(new WeatherField(LayoutLocation.UPPER_RIGHT));
        _fieldManager.addField(new DateField(LayoutLocation.ABOVE_TIME));
        _fieldManager.addField(new SecondsField(LayoutLocation.RIGHT_OF_TIME));
    }

    function onLoad(dc as Dc) as Void {
        // Initialize settings
        _is24Hour = System.getDeviceSettings().is24Hour;
        _fieldManager.set24Hour(_is24Hour);
        
        // Note: Field/Icon initialization deferred to first onUpdate()
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
        
        // Draw all fields
        _fieldManager.draw(dc, _isAwake, clockTime, width, height);
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
        _fieldManager.set24Hour(_is24Hour);
    }

}
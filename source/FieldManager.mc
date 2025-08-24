import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;

// Layout constants
module LayoutConstants {
    // Screen layout
    const TIME_CENTER_X_OFFSET = -2;
    const TIME_CENTER_Y_OFFSET = -22;
    
    // Location-specific positioning
    const TOP_RIGHT_EDGE_X = 99;
    const TOP_Y = 20;
    
    const UPPER_RIGHT_START_X = 100;
    const UPPER_RIGHT_OFFSET_X = 5;
    const UPPER_RIGHT_Y = 20;
    
    const RIGHT_OF_TIME_OFFSET_X = 0;
    const RIGHT_OF_TIME_OFFSET_Y = 10;
    
    const ABOVE_TIME_OFFSET_Y = -10;
    
    const BOTTOM_OFFSET_Y = -20;
}

class FieldManager {
    private var _fields as Array = [];
    private var _timeField as TimeField or Null = null;
    private var _lastHour = -1;
    private var _iconsLoaded = false;
    
    public function initialize() {
        // Empty constructor
    }
    
    public function addField(field as Field) as Void {
        if (field instanceof TimeField) {
            _timeField = field as TimeField;
        }
        _fields.add(field);
    }
    
    public function _loadIconsOnce() as Void {
        if (_iconsLoaded) {
            return;
        }

        // Load icons/resources for all fields
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].loadIcon();
        }
    }
    
    private function _refreshFields(clockTime as System.ClockTime, isAwake as Boolean) as Void {
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].refreshValue(clockTime, isAwake);
        }
    }
    
    private function _refreshPositions(dc as Graphics.Dc, width as Number, height as Number, clockTime as System.ClockTime) as Void {
        // Guard clause - only recalculate layout when hour changes or first run
        if (_lastHour != -1 && clockTime.hour == _lastHour) {
            return;
        }
        
        _lastHour = clockTime.hour;
        
        // Calculate TIME position first (center of screen)
        var timeX = width / 2 + LayoutConstants.TIME_CENTER_X_OFFSET;
        var timeY = height / 2 + LayoutConstants.TIME_CENTER_Y_OFFSET;
        var timeWidth = 0;
        
        if (_timeField != null) {
            _timeField.setPosition(timeX, timeY);
            timeWidth = _timeField.getTimeWidth(dc);
        }

        var upperRightCenterX = LayoutConstants.UPPER_RIGHT_START_X + (width - LayoutConstants.UPPER_RIGHT_START_X) / 2;
        
        // Calculate positions for all other fields based on their location
        for (var i = 0; i < _fields.size(); i++) {
            var field = _fields[i];
            var location = field.getLocation();
            
            if (location == LayoutLocation.TOP) {
                // Top area, right-aligned to avoid screen edge
                field.setPosition(LayoutConstants.TOP_RIGHT_EDGE_X, LayoutConstants.TOP_Y);
            } else if (location == LayoutLocation.UPPER_RIGHT) {
                // Upper right quadrant, centered with offset
                field.setPosition(upperRightCenterX + LayoutConstants.UPPER_RIGHT_OFFSET_X, LayoutConstants.UPPER_RIGHT_Y);
            } else if (location == LayoutLocation.RIGHT_OF_TIME) {
                // Right of time display, positioned relative to time width
                field.setPosition(timeX + (timeWidth / 2) + LayoutConstants.RIGHT_OF_TIME_OFFSET_X, 
                                timeY + LayoutConstants.RIGHT_OF_TIME_OFFSET_Y);
            } else if (location == LayoutLocation.ABOVE_TIME) {
                // Above time display, left-aligned to time
                field.setPosition(timeX - timeWidth / 2, timeY + LayoutConstants.ABOVE_TIME_OFFSET_Y);
            } else if (location == LayoutLocation.BOTTOM) {
                // Bottom area, centered horizontally
                field.setPosition(width / 2, height + LayoutConstants.BOTTOM_OFFSET_Y);
            }
            // TIME location handled above
        }
    }

    private function _drawFields(dc as Graphics.Dc, isAwake as Boolean) as Void{
        // Draw all fields
        for (var i = 0; i < _fields.size(); i++) {
            var field = _fields[i];
            field.draw(dc, isAwake);
        }
    }
    
    public function draw(dc as Graphics.Dc, isAwake as Boolean, clockTime as System.ClockTime, width as Number, height as Number) as Void {
        _loadIconsOnce();
        _refreshFields(clockTime, isAwake);
        _refreshPositions(dc, width, height, clockTime);
        _drawFields(dc, isAwake);
    }
    
    public function set24Hour(is24Hour as Boolean) as Void {
        if (_timeField != null) {
            _timeField.set24Hour(is24Hour);
        }
    }
}
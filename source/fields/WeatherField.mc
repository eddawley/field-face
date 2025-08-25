import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Time;

class WeatherField extends Field {
    private var _refreshInterval as Time.Duration = new Time.Duration(900); // 15 minutes
    private var _sunIcon = null;
    private var _cloudIcon = null;
    private var _rainIcon = null;
    private var _snowIcon = null;
    private var _conditionToIconMap as Dictionary = {};

    public function initialize() {
        Field.initialize();
        _buildConditionMap();

        font = Graphics.FONT_TINY;
    }
    
    public function refresh(context as RefreshContext) as Time.Duration {
        if (!(Toybox has :Weather)) {
            text = "--";
            icon = null;
            return _refreshInterval;
        }
        
        var currentConditions = Weather.getCurrentConditions();
        if (currentConditions == null || currentConditions.temperature == null) {
            text = "--";
            icon = null;
            return _refreshInterval;
        }
        
        var temp = currentConditions.temperature;
        var deviceSettings = System.getDeviceSettings();
        
        // Convert to Fahrenheit if needed
        if (deviceSettings.temperatureUnits == 1) { // UNIT_IMPERIAL
            temp = (temp * 9 / 5) + 32;
            text = Lang.format("$1$°F", [temp.format("%.0f")]);
        } else {
            text = Lang.format("$1$°C", [temp.format("%.0f")]);
        }
        
        // Update icon based on condition
        var possible = _conditionToIconMap.get(currentConditions.condition);
        icon = possible != null ? possible : _cloudIcon;

        return _refreshInterval;
    }
    
    private function _buildConditionMap() as Void {
        // SUN ICON - Clear/sunny conditions
        _conditionToIconMap[Weather.CONDITION_CLEAR] = _sunIcon;
        _conditionToIconMap[Weather.CONDITION_PARTLY_CLEAR] = _sunIcon;
        _conditionToIconMap[Weather.CONDITION_MOSTLY_CLEAR] = _sunIcon;
        _conditionToIconMap[Weather.CONDITION_FAIR] = _sunIcon;
        
        // CLOUD ICON - Cloudy/overcast/atmospheric conditions
        _conditionToIconMap[Weather.CONDITION_PARTLY_CLOUDY] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_MOSTLY_CLOUDY] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_CLOUDY] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_THIN_CLOUDS] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_WINDY] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_FOG] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_HAZY] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_MIST] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_DUST] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_SMOKE] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_SAND] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_SANDSTORM] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_VOLCANIC_ASH] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_HAZE] = _cloudIcon;
        _conditionToIconMap[Weather.CONDITION_UNKNOWN] = _cloudIcon;
        
        // RAIN ICON - All rain/storm conditions
        _conditionToIconMap[Weather.CONDITION_RAIN] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_THUNDERSTORMS] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_SCATTERED_SHOWERS] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_SCATTERED_THUNDERSTORMS] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_UNKNOWN_PRECIPITATION] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_LIGHT_RAIN] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_HEAVY_RAIN] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_LIGHT_SHOWERS] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_SHOWERS] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_HEAVY_SHOWERS] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_CHANCE_OF_SHOWERS] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_CHANCE_OF_THUNDERSTORMS] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_DRIZZLE] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_TORNADO] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_SQUALL] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_HURRICANE] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_TROPICAL_STORM] = _rainIcon;
        _conditionToIconMap[Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN] = _rainIcon;
        
        // SNOW ICON - All snow/ice/winter conditions
        _conditionToIconMap[Weather.CONDITION_SNOW] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_WINTRY_MIX] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_HAIL] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_LIGHT_SNOW] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_HEAVY_SNOW] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_LIGHT_RAIN_SNOW] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_HEAVY_RAIN_SNOW] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_RAIN_SNOW] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_ICE] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_CHANCE_OF_SNOW] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_CHANCE_OF_RAIN_SNOW] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_FLURRIES] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_FREEZING_RAIN] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_SLEET] = _snowIcon;
        _conditionToIconMap[Weather.CONDITION_ICE_SNOW] = _snowIcon;
    }
    
    public function loadResources() as Void {
        // Preload all weather icons once
        try {
            _sunIcon = WatchUi.loadResource(Rez.Drawables.SunIcon);
            _cloudIcon = WatchUi.loadResource(Rez.Drawables.CloudIcon);
            _rainIcon = WatchUi.loadResource(Rez.Drawables.RainIcon);
            _snowIcon = WatchUi.loadResource(Rez.Drawables.SnowIcon);
        } catch(ex) {}
    }
}
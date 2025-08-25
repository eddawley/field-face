import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;

class CleanFaceView extends WatchUi.WatchFace {
    private var _sleeping = false;
    private var _regionManager as RegionManager;
    private var _doneInitialClear as Boolean = false;

    function initialize() {
        WatchFace.initialize();

        var upperRight = new WatchUi.Layer({
            :width=>176-117, :height=>30
        });
        var aboveTime = new WatchUi.Layer({
            :width=>90, :height=>25
        });
        var time = new WatchUi.Layer({
            :width=>150, :height=>72
        });
        var top = new WatchUi.Layer({
            :width=>60, :height=>25
        });
        var bottom = new WatchUi.Layer({
            :width=>60, :height=>25
        });
        var rightOfTime = new WatchUi.Layer({
            :width=>30, :height=>30
        });

        _regionManager = new RegionManager();
        _regionManager.addRegion(
            new Region(
                "upperRight",
            upperRight,
            new WeatherField()
            )
        );
        _regionManager.addRegion(
            new Region(
                "time",
            time,
            new TimeField()
            )
        );
        _regionManager.addRegion(
            new Region(
                "aboveTime",
            aboveTime,
            new DateField()
            )
        );
        _regionManager.addRegion(
            new Region(
                "top",
            top,
            new BatteryField()
            )
        );
        _regionManager.addRegion(
            new Region(
                "bottom",
            bottom,
            new StepsField()
            )
        );
        _regionManager.addRegion(
            new Region(
                "rightOfTime",
            rightOfTime,
            new SecondsField()
            )
        );

        upperRight.setLocation(117,20);
        time.setLocation(20,60);
        aboveTime.setLocation(15,50);
        top.setLocation(60,10);
        bottom.setLocation(75,150);
        rightOfTime.setLocation(155,75);

        addLayer(upperRight);
        addLayer(time);
        addLayer(aboveTime);
        addLayer(top);
        addLayer(bottom);
        addLayer(rightOfTime);
    }

    function onLoad(dc as Dc) as Void {
        // Initialize settings
        // Force initial update request
        WatchUi.requestUpdate();

    }

    function onUnload() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        if (!_doneInitialClear) {
            // clear
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.clear();
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            _doneInitialClear = true;

        }

        var clockTime = System.getClockTime();
        
        _regionManager.loadResourcesOnce();
        _regionManager.refresh(
            new RefreshContext(clockTime, _sleeping)
        );
        _regionManager.draw(
            new DrawContext(clockTime, _sleeping)
        );
    }
        

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        _sleeping = false;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        _sleeping = true;
        // Request update to clear seconds immediately
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        _regionManager.forceNextDraw();
        WatchUi.requestUpdate();
    }

    function onSettingsChanged() as Void {
    }

}
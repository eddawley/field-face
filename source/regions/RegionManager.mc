import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;

class RegionManager {
    private var _resourcesLoaded as Boolean = false;
    private var _regions as Array = [];
    
    public function initialize() {
        // Empty constructor
    }
    
    public function loadResourcesOnce() as Void {
        if (_resourcesLoaded) {
            return;
        }

        // Load resources in all regions
        for (var i = 0; i < _regions.size(); i++) {
            _regions[i].loadResources();
        }

        _resourcesLoaded = true;
    }
    
    public function refresh(context as RefreshContext) as Void {
        // Refresh all regions
        for (var i = 0; i < _regions.size(); i++) {
            _regions[i].refresh(context);
        }
    }
    
    public function draw(context as DrawContext) as Void{
        // Draw all regions
        for (var i = 0; i < _regions.size(); i++) {
            _regions[i].draw(context);
        }
    }

    public function addRegion(region as Region) as Void {
        _regions.add(region);
    }
}
    
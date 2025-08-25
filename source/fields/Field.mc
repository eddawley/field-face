import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;

class Field {
    public var icon as Graphics.BitmapReference or Null = null;
    public var text as Lang.String or Null = null;
    public var font as Graphics.FontType or Null = null;
    public var allowed_when_sleeping as Boolean = true;
    
    public function initialize() {
    }

    public function loadResources() as Void {
        // Override in subclasses that need icons
    }

    public function refresh(context as RefreshContext) as Time.Duration {
        // Override in subclasses
        return new Time.Duration(1);
    }
}
package haxe.ui.backend.heaps;

import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import hxd.Window;

class MouseHelper {
    public static var currentMouseX:Float = 0;
    public static var currentMouseY:Float = 0;
    
    private static var _hasOnEvent:Bool = false;
    
    private static var _callbacks:Map<String, Array<MouseEvent->Void>> = new Map<String, Array<MouseEvent->Void>>();
    
    public static function notify(event:String, callback:MouseEvent->Void) {
        switch (event) {
            case MouseEvent.MOUSE_DOWN:
                if (_hasOnEvent == false) {
                    Window.getInstance().addEventTarget(onEvent);
                    _hasOnEvent = true;
                }
            case MouseEvent.MOUSE_UP:
                if (_hasOnEvent == false) {
                    Window.getInstance().addEventTarget(onEvent);
                    _hasOnEvent = true;
                }
            case MouseEvent.MOUSE_MOVE:
                if (_hasOnEvent == false) {
                    Window.getInstance().addEventTarget(onEvent);
                    _hasOnEvent = true;
                }
            case MouseEvent.MOUSE_WHEEL:
                if (_hasOnEvent == false) {
                    Window.getInstance().addEventTarget(onEvent);
                    _hasOnEvent = true;
                }
        }
        
        var list = _callbacks.get(event);
        if (list == null) {
            list = new Array<MouseEvent->Void>();
            _callbacks.set(event, list);
        }
        
        list.push(callback);
    }
    
    public static function remove(event:String, callback:MouseEvent->Void) {
        var list = _callbacks.get(event);
        if (list != null) {
            list.remove(callback);
            if (list.length == 0) {
                _callbacks.remove(event);
            }
        }
    }
    
    private static var _isCapturing:Bool = false;
    private static function onEvent(e:hxd.Event) {
        /*
        var scene = Screen.instance.scene;
        if (scene != null) {
            var xpos = Window.getInstance().mouseX / Toolkit.scaleX;
            var ypos = Window.getInstance().mouseY / Toolkit.scaleY;
            var b = Screen.instance.hasComponentUnderPoint(xpos, ypos);
            var i = scene.getInteractive(xpos, ypos);
            var isTextField = false;
            if (i != null && ((i.parent is TextField) || (i.parent is TextArea))) {
                isTextField = true;
            }
            var f = scene.getFocus();
            if (f != null && ((f.parent.parent is TextField) || (f.parent.parent is TextArea))) {
                isTextField = true;
            }
            
            if (b == true && isTextField == false) {
                e.cancel = true;
                e.propagate = false;
                if (_isCapturing == false) {
                    _isCapturing = true;
                    hxd.System.setNativeCursor(Default);
                    scene.startCapture(onEvent);
                }
            } else {
                if (_isCapturing == true) {
                    _isCapturing = false;
                    if (i != null) {
                        hxd.System.setNativeCursor(i.cursor);
                    }
                    scene.stopCapture();
                }
            }
        }
        */
        
        switch (e.kind) {
            case EMove:
                onMouseMove(e);
            case EPush:    
                onMouseDown(e);
            case ERelease | EReleaseOutside:
                onMouseUp(e);
            case EWheel:
                onMouseWheel(e);
            case _:    
        }
    }
    
    private static var scaleX:Null<Float> = null;
    private static var scaleY:Null<Float> = null;
    public static function updateScale(force:Bool = false) {
        if (force) {
            scaleX = null;
            scaleY = null;
        }
        if (scaleX != null && scaleY != null) {
            return;
        }

        switch (Screen.instance.scene.scaleMode) {
            case LetterBox(width, height, integerScale, horizontalAlign, verticalAlign):
                scaleX = hxd.Window.getInstance().width / width;
                scaleY = hxd.Window.getInstance().height / height;
            case _:    
                scaleX = 1;
                scaleY = 1;
        }
    }

    private static function onMouseMove(e:hxd.Event) {
        currentMouseX = e.relX / (Toolkit.scaleX * scaleX);
        currentMouseY = e.relY / (Toolkit.scaleY * scaleY);
        
        var list = _callbacks.get(MouseEvent.MOUSE_MOVE);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();
        list.reverse();

        var event = new MouseEvent(MouseEvent.MOUSE_MOVE);
        @:privateAccess event._originalEvent = e;
        event.screenX = e.relX / (Toolkit.scaleX * scaleX);
        event.screenY = e.relY / (Toolkit.scaleY * scaleY);
        for (l in list) {
            l(event);
			if (event.canceled) {
				break;
			}
        }
    }
    
    private static function onMouseDown(e:hxd.Event) {
        var list = _callbacks.get(MouseEvent.MOUSE_DOWN);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();
        list.reverse();
       
        var event = new MouseEvent(MouseEvent.MOUSE_DOWN);
        @:privateAccess event._originalEvent = e;
        event.screenX = e.relX / (Toolkit.scaleX * scaleX);
        event.screenY = e.relY / (Toolkit.scaleX * scaleX);
        event.data = e.button;
        for (l in list) {
            l(event);
			if (event.canceled) {
				break;
			}
        }
    }
    
    private static function onMouseUp(e:hxd.Event) {
        var list = _callbacks.get(MouseEvent.MOUSE_UP);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();
		list.reverse();
        
        var event = new MouseEvent(MouseEvent.MOUSE_UP);
        @:privateAccess event._originalEvent = e;
        event.screenX = e.relX / (Toolkit.scaleX * scaleX);
        event.screenY = e.relY / (Toolkit.scaleX * scaleX);
        event.data = e.button;
        for (l in list) {
            l(event);
			if (event.canceled) {
				break;
			}
        }
    }
    
    private static function onMouseWheel(e:hxd.Event) {
        var list = _callbacks.get(MouseEvent.MOUSE_WHEEL);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();
		list.reverse();
        
        var event = new MouseEvent(MouseEvent.MOUSE_WHEEL);
        @:privateAccess event._originalEvent = e;
        event.delta = e.wheelDelta;
        for (l in list) {
            l(event);
			if (event.canceled) {
				break;
			}
        }
    }
}
import 'dart:html';
import 'package:angular_app/GameObject.dart';
import 'package:angular_app/Game.dart';
import 'package:angular_app/Time.dart';

import 'Vector.dart';

enum CursorType{
  Lock,
  Follow,
  None
}

class _Cursor extends GameObject{
  CanvasRenderingContext2D _ctx;

  dynamic storage;
  double timeDelay;

  CursorType _type;

  Vector2 _position = Vector2();
  Vector2 _size;


  void Function(CanvasRenderingContext2D, Vector2, [dynamic storage]) _drawFunction;

  _Cursor(CanvasRenderingContext2D context,{
    ImageElement data,
    void Function(CanvasRenderingContext2D, Vector2, dynamic) draw,
    CursorType type = CursorType.Lock,
    num secondsDelay = 0.1,
    Vector2 size,
    dynamic store
  }){

    if(context == null && data == null && draw == null)throw "Cursor Requires Context and Either Image data or Function to be Used for Drawing";
    _ctx = context;
    _size = size ?? null;
    _type = type;

    storage = store;

    timeDelay = secondsDelay;

    if(data != null)_drawFunction = (ctx, pos, [_]){
      if(_size == null)
        ctx.drawImage(data, pos.x, pos.y);
      else
        ctx.drawImageScaled(data, _position.x, _position.y, _size.x, _size.y);
    };

    if(draw != null)_drawFunction = draw;
  }
  
  void OnRender(CanvasRenderingContext2D ctx){

    switch(_type){
      case CursorType.Lock:
        _position = Mouse.position;
        break;
      case CursorType.Follow:
        _position += (Mouse.position - _position) * Time.DeltaTime / timeDelay;
        break;
      case CursorType.None:
    }
    _drawFunction?.call(_ctx, _position, storage);
  }

}

class Mouse extends GameObject{
  static Mouse _Instance;

  static Vector2 _position = Vector2();
  static Vector2 _delta = Vector2();
  static bool _isDown = false;

  static bool get pressed => _isDown;
  static double get x => _position.x;
  static double get y => _position.y;
  static double get dx => _delta.x;
  static double get dy => _delta.y;
  static Vector2 get position => _position;
  static Vector2 get delta => _delta;

  Mouse._();

  static Mouse Create(){
    Mouse._Instance ??= new Mouse._();

    window.onMouseMove.listen(_UpdateMousePosition);

    window.onMouseUp.listen((data) => {_isDown = false});
    window.onMouseDown.listen((data) => {_isDown = true});

    Game.OnUpdate = _Clear;

    return Mouse._Instance;
  }

  static void _Clear(){
    _delta = Vector2.zero;
  }

  static void _UpdateMousePosition(MouseEvent evt){
    _position = Vector2.fromPoint(evt.page);
    _delta = Vector2.fromPoint(evt.movement);
  }
}

class Keyboard extends GameObject{

	List<bool> _data = List<bool>.filled(256, false);

	static Keyboard Instance;

	void keyCallback(int state, KeyboardEvent evt) {
    if(_data[evt.keyCode] && state == 0){
      released[evt.keyCode] = true;
      anyUp = true;
    }else if(!_data[evt.keyCode] && state == 1){
      anyDown = true;
      pressed[evt.keyCode] = true;
    }

    _data[evt.keyCode] = state != 0;

    ctrlKey = evt.ctrlKey;
    shiftKey = evt.shiftKey;
    altKey = evt.altKey;
	}

	bool ctrlKey = false;
	bool shiftKey = false;
	bool altKey = false;

  bool anyDown = false;
  bool anyUp = false;

	List<bool> pressed = List<bool>.filled(256, false);
	List<bool> released = List<bool>.filled(256, false);

	void OnUpdate(){
		if(Instance == null)return;

    anyUp = anyDown = false;

    pressed = List<bool>.filled(256, false);
    released = List<bool>.filled(256, false);
	}

	static Keyboard CreateKeyManager() {
		if (Instance != null)
			return Instance;

		Instance = Keyboard();

    window.onKeyUp.listen((evt) => Instance.keyCallback.call(0, evt));
    window.onKeyDown.listen((evt) => Instance.keyCallback.call(1, evt));
    window.onKeyPress.listen((evt) => Instance.keyCallback.call(2, evt));

		return Instance;
	}

	bool operator[](key) {
    int i;
    if(key is String)
      i = key.codeUnitAt(0);
    else if(key is num)
      i = key.toInt();
    else throw "Type ${key.runtimeType} Cannot be used for Indexing";
		return _data[i];
	}


	static bool Get(String key) {
		if (Instance == null)return false;
    int i = key.codeUnitAt(0);
		if (i > 96 && i < 123)
			return Instance._data[i - 32];

		return Instance._data[i];
	}

}


class MouseCodes{
}

class Input{
  static Input _instance = Input._();
  Mouse mouse;
  Keyboard keyboard;

  Input._(){
    Mouse.Create();
    Keyboard.CreateKeyManager();
  }

  static bool GetKeyDown(KeyCode key){
    return _instance.keyboard.pressed[key.Code];
  }

  static bool GetKeyUp(KeyCode key){
    return _instance.keyboard.released[key.Code];
  }

  static bool GetKey(KeyCode key){
    return _instance.keyboard._data[key.Code];
  }

  static Vector2 MouseDelta(){
    return Mouse.delta;
  }

  static Vector2 MousePosition(){
    return Mouse.position;
  }
}



enum KeyCode {
    backspace,
    tab,
    enter,
    shift,
    ctrl,
    alt,
    pause,
    capslock,
    escape,
    pageUp,
    space,
    pageDown,
    end,
    home,
    arrowLeft,
    arrowUp,
    arrowRight,
    arrowDown,
    prtscrn,
    insert,
    delete,
    num0,
    num1,
    num2,
    num3,
    num4,
    num5,
    num6,
    num7,
    num8,
    num9,
    a,
    b,
    c,
    d,
    e,
    f,
    g,
    h,
    i,
    j,
    k,
    l,
    m,
    n,
    o,
    p,
    q,
    r,
    s,
    t,
    u,
    v,
    w,
    x,
    y,
    z,
    lwindowKey,
    rwindowKey,
    selectKey,
    numpad0,
    numpad1,
    numpad2,
    numpad3,
    numpad4,
    numpad5,
    numpad6,
    numpad7,
    numpad8,
    numpad9,
    multiply,
    add,
    subtract,
    decimalpoint,
    divide,
    f1,
    f2,
    f3,
    f4,
    f5,
    f6,
    f7,
    f8,
    f9,
    f10,
    f11,
    f12,
    numLock,
    scrollLock,
    myComputer,
    myCalculator,
    semicolon,
    equalsign,
    comma,
    dash,
    period,
    forwardSlash,
    openBracket,
    backSlash,
    closeBraket,
    singleQuote
}

final Codes = {
  KeyCode.backspace: 8,
  KeyCode.tab: 9,
  KeyCode.enter: 13,
  KeyCode.shift: 16,
  KeyCode.ctrl: 17,
  KeyCode.alt: 18,
  KeyCode.pause: 19,
  KeyCode.capslock: 20,
  KeyCode.escape: 27,
  KeyCode.pageUp: 33,
  KeyCode.space: 32,
  KeyCode.pageDown: 34,
  KeyCode.end: 35,
  KeyCode.home: 36,
  KeyCode.arrowLeft: 37,
  KeyCode.arrowUp: 38,
  KeyCode.arrowRight: 39,
  KeyCode.arrowDown: 40,
  KeyCode.prtscrn: 44,
  KeyCode.insert: 45,
  KeyCode.delete: 46,
  KeyCode.num0: 48,
  KeyCode.num1: 49,
  KeyCode.num2: 50,
  KeyCode.num3: 51,
  KeyCode.num4: 52,
  KeyCode.num5: 53,
  KeyCode.num6: 54,
  KeyCode.num7: 55,
  KeyCode.num8: 56,
  KeyCode.num9: 57,
  KeyCode.a: 65,
  KeyCode.b: 66,
  KeyCode.c: 67,
  KeyCode.d: 68,
  KeyCode.e: 69,
  KeyCode.f: 70,
  KeyCode.g: 71,
  KeyCode.h: 72,
  KeyCode.i: 73,
  KeyCode.j: 74,
  KeyCode.k: 75,
  KeyCode.l: 76,
  KeyCode.m: 77,
  KeyCode.n: 78,
  KeyCode.o: 79,
  KeyCode.p: 80,
  KeyCode.q: 81,
  KeyCode.r: 82,
  KeyCode.s: 83,
  KeyCode.t: 84,
  KeyCode.u: 85,
  KeyCode.v: 86,
  KeyCode.w: 87,
  KeyCode.x: 88,
  KeyCode.y: 89,
  KeyCode.z: 90,
  KeyCode.lwindowKey: 91,
  KeyCode.rwindowKey: 92,
  KeyCode.selectKey: 93,
  KeyCode.numpad0: 96,
  KeyCode.numpad1: 97,
  KeyCode.numpad2: 98,
  KeyCode.numpad3: 99,
  KeyCode.numpad4: 100,
  KeyCode.numpad5: 101,
  KeyCode.numpad6: 102,
  KeyCode.numpad7: 103,
  KeyCode.numpad8: 104,
  KeyCode.numpad9: 105,
  KeyCode.multiply: 106,
  KeyCode.add: 107,
  KeyCode.subtract: 109,
  KeyCode.decimalpoint: 110,
  KeyCode.divide: 111,
  KeyCode.f1: 112,
  KeyCode.f2: 113,
  KeyCode.f3: 114,
  KeyCode.f4: 115,
  KeyCode.f5: 116,
  KeyCode.f6: 117,
  KeyCode.f7: 118,
  KeyCode.f8: 119,
  KeyCode.f9: 120,
  KeyCode.f10: 121,
  KeyCode.f11: 122,
  KeyCode.f12: 123,
  KeyCode.numLock: 144,
  KeyCode.scrollLock: 145,
  KeyCode.myComputer: 182,
  KeyCode.myCalculator: 183,
  KeyCode.semicolon: 186,
  KeyCode.equalsign: 187,
  KeyCode.comma: 188,
  KeyCode.dash: 189,
  KeyCode.period: 190,
  KeyCode.forwardSlash: 191,
  KeyCode.openBracket: 219,
  KeyCode.backSlash: 220,
  KeyCode.closeBraket: 221,
  KeyCode.singleQuote: 222
};
extension foo on KeyCode{
  int get Code => Codes[this];
}
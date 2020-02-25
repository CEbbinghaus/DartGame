import 'dart:convert';
import 'dart:html';
import 'dart:js_util';

import 'package:angular_app/Game.dart';

import 'Vector.dart';

enum CursorType{
  Lock,
  Follow,
  None
}

class Cursor{
  CanvasRenderingContext2D _ctx;

  CursorType _type;

  Vector2 _position = Vector2();
  Vector2 _size;

  Function(CanvasRenderingContext2D, Vector2) _drawFunction;

  Cursor(CanvasRenderingContext2D context, {ImageElement data, Function(CanvasRenderingContext2D, Vector2) draw, CursorType type = CursorType.Lock, Vector2 size}){
    if(context == null && data == null && draw == null)throw "Cursor Requires Context and Either Image data or Function to be Used for Drawing";
    _ctx = context;
    _size = size ?? null;
    _type = type;

    if(data != null)_drawFunction = (ctx, pos){
      if(_size == null)
        ctx.drawImage(data, pos.x, pos.y);
      else
        ctx.drawImageScaled(data, _position.x, _position.y, _size.x, _size.y);
    };

    if(draw != null)_drawFunction = draw;

    Game.onUpdate = this.draw;
  }
  
  void draw(dynamic){
    switch(_type){
      case CursorType.Lock:
        _position = Mouse.position;
        break;
      case CursorType.Follow:
        _position += (Mouse.position - _position) * 0.2;
        break;
      case CursorType.None:
    }
    _drawFunction?.call(_ctx, _position);
  }

}

class Mouse{
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

    Game.onUpdate = _Clear;

    return Mouse._Instance;
  }

  static void _Clear(dynamic){
    _delta = Vector2.zero;
  }

  static void _UpdateMousePosition(MouseEvent evt){
    _position = Vector2.fromPoint(evt.page);
    _delta = Vector2.fromPoint(evt.movement);
    // Vector2 current = new Vector2(evt.client.x, evt.client.y);
    // Vector2 diff = _position - current;

    // _delta = diff;   
  }
}
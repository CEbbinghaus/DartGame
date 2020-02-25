import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:angular_app/Keyboard.dart';
import 'package:angular_app/Mouse.dart';
import 'package:angular_app/Time.dart';


class Game{
  static Game Instance;

  static StreamController _updateStream = StreamController.broadcast();
  static void set onUpdate(Function f){
    _updateStream.stream.listen(f);
  }

  int frame = 0;
  CanvasElement canvas;
  CanvasRenderingContext2D context;

  Cursor cursor;
  KeyManager keyboard;

  Game(CanvasElement this.canvas, CanvasRenderingContext2D this.context){
    Instance = this;
    keyboard = KeyManager.CreateKeyManager();
    window.requestAnimationFrame(Main);
    cursor = new Cursor(context, draw: (ctx, pos){
      ctx.beginPath();
      ctx.arc(pos.x, pos.y, 50, 0, pi * 2);
      ctx.fill();
    });
  }

  void Main(num time){
    Time.Update(time);
    frame++;
    context.clearRect(0, 0, window.innerWidth, window.innerHeight);

    if(keyboard.pressed[32])
      print("Space Pressed");

    // print("Current Frame: $frame\nCurrent Delta: ${Time.DeltaTime}");
    _updateStream.add({});
    window.requestAnimationFrame(Main);
  }
}
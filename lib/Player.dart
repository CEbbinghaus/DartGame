import 'dart:html';

import 'package:angular_app/GameObject.dart';
import 'package:angular_app/Vector.dart';

class Player extends GameObject{
  Vector2 position;
  Vector2 size = Vector2(100, 400);


  void OnStart(){
    position = Vector2(window.innerWidth / 2, window.innerHeight / 2);
  }

  void OnRender(CanvasRenderingContext2D ctx){
    ctx.fillRect(position.x, position.y, size.x, size.y);
  }
}
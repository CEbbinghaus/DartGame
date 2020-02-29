import 'dart:html';

import 'package:angular_app/GameManager.dart';
import 'package:angular_app/GameObject.dart';
import 'package:angular_app/Gun.dart';
import 'package:angular_app/Input.dart';
import 'package:angular_app/Time.dart';
import 'package:angular_app/Vector.dart';
import 'Overloads.dart';

class Player extends GameObject{
  Vector2 velocity = Vector2();

  Vector2 size = Vector2(50, 100);

  Gun gun;

  int lives = 3;

  double _invinibility = 0;

  bool get isInvinible{
    return _invinibility > 0;
  }

  Player(){
    transform.position = Vector2(window.innerWidth / 2, window.innerHeight / 2);
    gun = Gun(transform, ClipSize: 10, FireRate: 5, AutoReload: true);
  }

  void OnUpdate(){

    Vector2 input = Input.GetDirectionVector().Normalize();

    if(Input.GetKeyDown(KeyCode.shift)){
      GameManager.Inverted = !GameManager.Inverted;

      Vector2 direction = (Input.GetMousePosition() - transform.position).Normalized;

      velocity = direction * 30;
    }

    if(Input.GetKeyDown(KeyCode.r)){
      gun.Reload();
    }

    if(Input.GetMouseButtonDown(MouseButton.Left)){
      if(gun.CanShoot){
        velocity -= (Input.GetMousePosition() - transform.position).Normalized * 3;
        GameManager.CameraShake = 50;
      }

      gun.Shoot(Input.GetMousePosition());
    }


    velocity += input * 0.6;

    velocity *= 0.90;

    transform.position += velocity * Time.OneTime;
  }

  void OnLateUpdate(){
    Vector2 position = transform.position;
    Vector2 halfSize = size / 2;
    if(position.x - halfSize.x < 0)
      position.x = halfSize.x;
    if(position.x + halfSize.x > window.innerWidth)
      position.x = window.innerWidth - halfSize.x;
    if(position.y - halfSize.y < 0)
      position.y = halfSize.y;
    if(position.y + halfSize.y > window.innerHeight)
      position.y = window.innerHeight - halfSize.y;
  }

  void OnLateRender(CanvasRenderingContext2D ctx){
    ctx.fillStyle = "#72e9ff";
    ctx.filter = GameManager.Inverted ? "invert(1)" : "none";
    ctx.fillRectC(transform.position, size);
  }

  void OnGUI(CanvasRenderingContext2D ctx){
    ctx.fillStyle = "#000";
    ctx.SetInverted();
    ctx.fillRect(0, 0, 100, 100);
    ctx.save();
    ctx.globalCompositeOperation = "destination-out";
    GameManager.spriteRender?.DrawSprite(ctx, Vector2.zero, (Time.TotalTime % 17).toInt(), size: Vector2.one * 100);
    ctx.restore();
  }
}
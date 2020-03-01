import 'dart:html';

import 'package:angular_app/Enemy.dart';
import 'package:angular_app/Game.dart';
import 'package:angular_app/GameManager.dart';
import 'package:angular_app/GameObject.dart';
import 'package:angular_app/Gun.dart';
import 'package:angular_app/Icon.dart';
import 'package:angular_app/Input.dart';
import 'package:angular_app/Time.dart';
import 'package:angular_app/Vector.dart';
import 'Overloads.dart';

class Player extends GameObject{
  Icon icon;
  ImageElement heartSprite;

  Vector2 velocity = Vector2();

  Vector2 size = Vector2(50, 100);

  Gun gun;

  int lives = 3;

  double _invinibility = 2;

  bool get isInvinible{
    return _invinibility > 0;
  }

  double DashTimeout = 2;
  double _dashCooldown = 0;

  Player(){
    transform.position = Vector2(window.innerWidth / 2, window.innerHeight / 2);
    gun = Gun(transform, ClipSize: 10, FireRate: 5, AutoReload: true, ReloadMode: AutoReloadMode.OnShot);
    Initialize();
  }

  Initialize() async{
    ImageElement d = await LoadImage("Dash.png");
    icon = Icon(d, size: Vector2.one * 100);
    heartSprite = await LoadImage("Heart.png");
  }

  void OnEarlyUpdate(){
    if(_dashCooldown > 0)_dashCooldown -= Time.DeltaTime;
    if(_invinibility > 0)_invinibility -= Time.DeltaTime;
  }

  void OnUpdate(){

    Vector2 input = Input.GetDirectionVector().Normalize();

    if(Input.GetKeyDown(KeyCode.shift) && _dashCooldown <= 0){
      GameManager.Inverted = !GameManager.Inverted;

      Vector2 direction = (Input.GetMousePosition() - transform.position).Normalized;

      velocity = direction * 30;
      _dashCooldown = DashTimeout;
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

  void TakeDamage(Enemy e){
    Vector2 diff = (e.transform.position - transform.position).Normalized;
    lives -= 1;
    if(lives <= 0)
      Game.Instance.Quit();
    _invinibility = 5;
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
    ImageData data = icon?.DrawRotatedPercentage(_dashCooldown > 0 ? 1 - (_dashCooldown / DashTimeout) : 1);
    if(data == null)return;

    ctx.filter = GameManager.getInverted();
    ctx.putImageData(data, 700, 0);

    if(heartSprite != null)
      for(int i = 0; i < lives; ++i){
        ctx.drawImageScaled(heartSprite, i * 100, 0, 100, 100);
    }
    // ctx.fillStyle = "#000";
    // ctx.fillRect(0, 0, 100, 100);
    // ctx.save();
    // ctx.globalCompositeOperation = "destination-out";
    // GameManager.spriteRender?.DrawSprite(ctx, Vector2.zero, (Time.TotalTime % 17).toInt(), size: Vector2.one * 100);
    // ctx.restore();
  }
}
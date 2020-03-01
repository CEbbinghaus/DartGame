import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:angular_app/Enemy.dart';
import 'package:angular_app/GameObject.dart';
import 'package:angular_app/Gun.dart';
import 'package:angular_app/Player.dart';
import 'package:angular_app/Time.dart';
import 'package:angular_app/Vector.dart';
import 'Overloads.dart';
import 'SpriteRenderer.dart';

extension InvertRendering on CanvasRenderingContext2D {
  void SetInverted() => () {
    print("Iverted? ${GameManager.Inverted}");
        this.filter = GameManager.Inverted ? "invert(1)" : "none";
      };
}

bool CircleBox(Vector2 CirclePos, Vector2 BoxPos, double Radius, Vector2 BoxSize){
  Vector2 bpos = CirclePos;
  Vector2 apos = BoxPos;
  Vector2 asize = BoxSize;

  Vector2 testEdge = Vector2(bpos);

  if (bpos.x < apos.x - asize.x / 2)
    testEdge.x = apos.x - asize.x / 2; // left edge
  else if (bpos.x > apos.x + asize.x / 2)
    testEdge.x = apos.x + asize.x / 2; // right edge

  if (bpos.y < apos.y - asize.x / 2)
    testEdge.y = apos.y - asize.x / 2; // top edge
  else if (bpos.y > apos.y + asize.y / 2)
    testEdge.y = apos.y + asize.y / 2; // bottom edge

  Vector2 diff = (bpos - testEdge);
  double distance = diff.Magnitude;
  return distance < Radius;
}

bool BoxBox(Vector2 aPos, Vector2 bPos, Vector2 aSize, Vector2 bSize){
  Vector2 haSize = aSize / 2;
  Vector2 hbSize = bSize / 2;
  return (aPos.x + haSize.x > bPos.x - hbSize.x &&
    aPos.x - haSize.x < bPos.x + hbSize.x &&
    aPos.y + haSize.y > bPos.y - hbSize.y &&
    aPos.y - haSize.y < bPos.y + hbSize.y);
}

Future<ImageElement> LoadImage(String source) {
  Completer<ImageElement> c = Completer<ImageElement>();
  ImageElement e = ImageElement(src: source);

  e.onLoad.listen((data) {
    c.complete(e);
  });

  e.onAbort.listen((onData){
    c.completeError(Exception("Could not find Image"));
  });

  return c.future;
}


class GameManager extends GameObject {
  Player p;

  static bool Inverted = false;

  static String getInverted(){
    return Inverted ? "invert(1)" : "none";
  }

  static List<Bullet> bullets = [];
  static List<Enemy> blackEnemies = [];
  static List<Enemy> whiteEnemies = [];

  static double totalEnemyCount = 10;

  static SpriteRender spriteRender;

  static void set CameraShake(double value){
    _cameraShakeTimeout = value / 16.666666666;
  }

  static double _cameraShakeTimeout = 0;

  Random random = Random();

  GameManager() : super() {
    print("Game Started");
    p = Player();
  }

  void OnAwake() async{
    ImageElement SpriteSheet = await LoadImage("SpriteSheet.png");
    spriteRender = SpriteRender(SpriteSheet, Vector2.one * 32);
  }

  void OnStart() {
    for (int i = 0; i < totalEnemyCount.toInt(); ++i) {
      if (random.nextBool())
        blackEnemies.add(Enemy(p, EnemyType.black));
      else
        whiteEnemies.add(Enemy(p, EnemyType.white));
    }
  }

  void OnEarlyUpdate(){

  }

  void OnFixedUpdate(){

  }

  void OnUpdate(){
    totalEnemyCount += Time.DeltaTime / 100;


    if(blackEnemies.length + whiteEnemies.length < totalEnemyCount && random.nextDouble() < 0.1){
      if (random.nextBool())
        blackEnemies.add(Enemy(p, EnemyType.black));
      else
        whiteEnemies.add(Enemy(p, EnemyType.white));
    }
  }

  void OnLateUpdate() {
    //print("Looping over Bullet Array");
    for (Bullet b in [...bullets]) {
      for (Enemy e in [...(Inverted ? whiteEnemies : blackEnemies)]) {
        Vector2 cpos = b.transform.position;
        Vector2 bpos = e.transform.position;

        double csize = b.size;
        Vector2 bsize = e.size;
        
        if (CircleBox(cpos, bpos, csize, bsize)){
          e.TakeDamage(b.Direction, b.damage);
          bullets.remove(b);
          GameObject.destroy(b);
        } 
      }
    }

  for (Enemy e in [...(Inverted ? whiteEnemies : blackEnemies)]) {
      Vector2 bpos = e.transform.position;
      Vector2 bsize = e.size;

      Vector2 apos = p.transform.position;
      Vector2 asize = p.size;
      
      if (BoxBox(apos, bpos, asize, bsize)){
        if(!p.isInvinible)
          p.TakeDamage(e);
      } 
    }

    if(_cameraShakeTimeout > 0)_cameraShakeTimeout -= Time.OneTime;

  }

  void OnEarlyRender(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = "#fff";
    ctx.SetInverted();
    ctx.fillRect(0, 0, window.innerWidth, window.innerHeight);
    ctx.resetTransform();

    if(_cameraShakeTimeout > 0){
      double shakeTime = (Time.TotalTime + _cameraShakeTimeout);
      Vector2 ShakeDirection = Vector2(sin(shakeTime), cos(shakeTime));
      ShakeDirection *= max(_cameraShakeTimeout / 20, 2.5);
      ctx.translate(ShakeDirection.x, ShakeDirection.y);
    }
    //ctx.fillRect(window.inneasize.xidth / 2 - 50, window.inneasize.yeight / 2 - 50, 100, 100);
  }

  void OnQuit(CanvasRenderingContext2D ctx){
    ctx.fillStyle = "rgb(20, 20, 40)";
    ctx.fillRect(0, 0, window.innerWidth, window.innerHeight);
    ctx.fillStyle = "#fff";
    ctx.font = "100px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText("Game Over", window.innerWidth / 2, window.innerHeight / 2);
  }
}

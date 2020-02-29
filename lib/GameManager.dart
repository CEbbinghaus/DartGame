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
        this.filter = GameManager.Inverted ? "invert(1)" : "none";
      };
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
    for (Bullet b in bullets) {
      for (Enemy e in (Inverted ? whiteEnemies : blackEnemies)) {
        Vector2 bpos = b.transform.position;
        Vector2 apos = e.transform.position;

        double bsize = b.size;
        Vector2 asize = e.size;

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
        if (distance <= bsize){
          e.TakeDamage(b.Direction, b.damage);
          bullets.remove(b);
          GameObject.destroy(b);
        } 
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
}

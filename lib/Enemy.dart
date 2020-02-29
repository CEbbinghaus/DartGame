import 'dart:html';
import 'dart:math';

import 'package:angular_app/GameManager.dart';
import 'package:angular_app/GameObject.dart';
import 'package:angular_app/Player.dart';
import 'package:angular_app/Time.dart';
import 'package:angular_app/Vector.dart';
import 'Overloads.dart';

enum EnemyType{
  white,
  black
}

class Enemy extends GameObject{
  double health = 20;
  double speed;
  Player target;

  EnemyType type;

  Vector2 size = Vector2(50, 100);

  double _spawnWaitTimer = 1;

  Vector2 velocity = Vector2();

  Enemy(this.target, this.type){
    Random r = Random();
    transform.position = Vector2(r.nextDouble() * window.innerWidth, r.nextDouble() * window.innerHeight);
  }

  OnUpdate(){
    if (_spawnWaitTimer > 0)
      _spawnWaitTimer -= Time.DeltaTime;
    else if(type == EnemyType.white){
      if(GameManager.Inverted){
        velocity += (target.transform.position - transform.position).Normalized * 0.6 * Time.OneTime;
      }
    }else{
      if(!GameManager.Inverted){
        velocity += (target.transform.position - transform.position).Normalized * 0.6 * Time.OneTime;
      }
    }

    velocity *= 0.8;

    transform.position += velocity * Time.OneTime;
  }

  TakeDamage(Vector2 direction, double amount){
    velocity += direction * 10;
    health -= amount;
    if(health < 0){
      (type == EnemyType.black ? GameManager.blackEnemies : GameManager.whiteEnemies).remove(this);
      GameObject.destroy(this);
    }
  }

  OnRender(CanvasRenderingContext2D ctx){

    if(type == EnemyType.white){
      if(!GameManager.Inverted)return;
    }else{
      if(GameManager.Inverted)return;
    }

    ctx.fillStyle = "#000";
    ctx.fillRectC(transform.position, size);
  }
}
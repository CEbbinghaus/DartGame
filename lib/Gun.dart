import 'dart:html';

import 'package:angular_app/GameManager.dart';
import 'package:angular_app/Icon.dart';
import 'package:angular_app/Transform.dart';

import 'Overloads.dart';
import 'package:angular_app/Game.dart';
import 'package:angular_app/GameObject.dart';
import 'package:angular_app/Time.dart';
import 'package:angular_app/Vector.dart';

class Bullet extends GameObject {
  double size;
  Vector2 Direction;
  Vector2 Origin;
  double speed;
  double damage;
  double Range;

  double get Distance {
    return (transform.position - Origin).Magnitude;
  }

  Bullet(this.Origin, this.Direction, this.speed, this.Range,
      {this.size = 7, this.damage = 20}) {
    this.transform.position = this.Origin + this.Direction * 5;
  }

  OnUpdate() {
    transform.position += Direction * speed * Time.DeltaTime;

    if (Distance > Range) {
      GameManager.bullets.remove(this);
      GameObject.destroy(this);
    }
  }

  OnRender(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = "#000";
    ctx.SetInverted();

    ctx.beginPath();
    ctx.Circle(transform.position, size);
    ctx.fill();
  }
}

enum AutoReloadMode { OnShot, NextShot }

class Gun extends GameObject {
  int ClipSize;
  double Range;
  double Velocity;
  double ReloadTime;
  double FireRate;
  double Damage;
  bool AutoReload;
  AutoReloadMode ReloadMode;

  double _FireRateTimeout = 0;
  double _ReloadTimeout = 0;

  int _bulletCount;

  Transform Origin;

  int get BulletCount {
    return _bulletCount;
  }

  double get ReloadPercentage {
    return _ReloadTimeout / ReloadTime;
  }

  Icon icon;

  Gun(this.Origin,
      {this.ClipSize = 20,
      this.Range = 2000,
      this.Velocity = 1000,
      this.ReloadTime = 2,
      this.FireRate = 2,
      this.Damage = 20,
      this.AutoReload = false,
      this.ReloadMode = AutoReloadMode.NextShot}) {
    _bulletCount = this.ClipSize;

    Initialize();
  }

  void Initialize() async {
    ImageElement e = await LoadImage("Bullet.png");
    icon = Icon(e, size: Vector2.one * 100);
  }

  bool get CanShoot {
    return _bulletCount >= 1 && _ReloadTimeout <= 0 && _FireRateTimeout <= 0;
  }

  Shoot(Vector2 target) {
    Vector2 direction = (target - Origin.position).Normalized;
    if (CanShoot) {
      _bulletCount--;
      GameManager.bullets.add(
          Bullet(Origin.position, direction, Velocity, Range, damage: Damage));
      _FireRateTimeout = 1 / FireRate;
      if (AutoReload && ReloadMode == AutoReloadMode.OnShot && BulletCount == 0)
        Reload();
    } else {
      if (AutoReload &&
          ReloadMode == AutoReloadMode.NextShot &&
          _bulletCount == 0) {
        Reload();
      }
    }
  }

  void Reload() {
    if (_ReloadTimeout <= 0 && _bulletCount != ClipSize) {
      _ReloadTimeout = ReloadTime;
      _bulletCount = ClipSize;
    }
  }

  void OnUpdate() {
    if (_FireRateTimeout > 0) _FireRateTimeout -= Time.DeltaTime;
    if (_ReloadTimeout > 0) _ReloadTimeout -= Time.DeltaTime;
  }

  void OnGUI(CanvasRenderingContext2D ctx) {
    ImageData data = icon?.DrawRotatedPercentage(
        _ReloadTimeout > 0 ? 1 - (_ReloadTimeout / ReloadTime) : 1);
    if (data != null) {
      ctx.putImageData(data, 400, 0);

      if (_ReloadTimeout <= 0) {
        ctx.font = "75px Arial";
        ctx.fillText(_bulletCount.toString(), 500, 80);
      }
    }
  }
}

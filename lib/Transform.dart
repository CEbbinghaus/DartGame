
import 'package:angular_app/GameObject.dart';
import 'package:angular_app/Vector.dart';

class Transform{
  GameObject gameObject;
  Vector2 position = Vector2();
  Vector2 scale = Vector2.one;
  double rotaion = 0;

  Transform(this.gameObject);
}
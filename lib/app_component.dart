import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular_app/Game.dart';

@Component(
  selector: 'my-app',
  styles: ["canvas: {position: absolute; top: 0px; left: 0px;}"],
  template: '<canvas></canvas>'
)
class AppComponent implements OnInit {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;

  Game game;

  @override
  void ngOnInit() {
    canvas = querySelector("canvas");
    ctx = canvas?.getContext("2d") as CanvasRenderingContext2D;

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    window.onResize.listen((Event){
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    });

    print((ctx != null ? "Loaded Canvas Context" : "Context Doesnt Exist"));
    //canvas.requestPointerLock();
    game = new Game(canvas, ctx);
  }
}

import 'dart:async';
import 'dart:html';
import 'package:angular_app/Time.dart';

class CursorData{
  double value;
  bool enabled = false;
}

enum Event{
  awake,
  start,
  earlyUpdate,
  fixedUpdate,
  update,
  lateUpdate,
  earlyRender,
  render,
  lateRender,
  gui,
  quit
}

class _GameUpdateEventEmitter{
  static StreamController<void> _awakeStream = StreamController.broadcast();
  static StreamController<void> _startStream = StreamController.broadcast();
  static StreamController<void> _earlyUpdateStream = StreamController.broadcast();
  static StreamController<void> _fixedUpdateStream = StreamController.broadcast();
  static StreamController<void> _updateStream = StreamController.broadcast();
  static StreamController<void> _lateUpdateStream = StreamController.broadcast();
  static StreamController<CanvasRenderingContext2D> _earlyRenderStream = StreamController.broadcast();
  static StreamController<CanvasRenderingContext2D> _renderStream = StreamController.broadcast();
  static StreamController<CanvasRenderingContext2D> _lateRenderStream = StreamController.broadcast();
  static StreamController<CanvasRenderingContext2D> _guiStream = StreamController.broadcast();
  static StreamController<void> _quitStream = StreamController.broadcast();

  static _runCase(Event event, Function(dynamic) callback){
    switch(event){
      case Event.awake:
        callback(_awakeStream);
        break;
      case Event.start:
        callback(_startStream);
        break;
      case Event.earlyUpdate:
        callback(_earlyUpdateStream);
        break;
      case Event.fixedUpdate:
        callback(_fixedUpdateStream);
        break;
      case Event.update:
        callback(_updateStream);
        break;
      case Event.lateUpdate:
        callback(_lateUpdateStream);
        break;
      case Event.earlyRender:
        callback(_earlyRenderStream);
        break;
      case Event.render:
        callback(_renderStream);
        break;
      case Event.lateRender:
        callback(_lateRenderStream);
        break;
      case Event.gui:
        callback(_guiStream);
        break;
      case Event.quit:
        callback(_quitStream);
        break;
    }
  }

  static SetStream(Event e, dynamic t){
    var f = (dynamic) => t();
    _runCase(e, (dynamic s){
      if(
        e == Event.earlyRender ||
        e == Event.render ||
        e == Event.lateRender ||
        e == Event.gui
      ){
        s.stream.listen(t);
      }else{
        s.stream.listen(f);
      }
    });
    
  }

  static Emit(Event e, [dynamic v = null]){
    _runCase(e, (stream){
      stream.add(v);
    });
  }
}

class Game extends _GameUpdateEventEmitter{
  static Game Instance;

  static void _SetStream(Event e, dynamic t) => _GameUpdateEventEmitter.SetStream(e, t);
  static void _Emit(Event e, [dynamic t]) => _GameUpdateEventEmitter.Emit(e, t);

  static void set OnAwake(Function f) => _SetStream(Event.awake, f);
  static void set OnStart(Function f) => _SetStream(Event.start, f);
  static void set OnEarlyUpdate(Function f) => _SetStream(Event.earlyUpdate, f);
  static void set OnFixedUpdate(Function f) => _SetStream(Event.fixedUpdate, f);
  static void set OnUpdate(Function f) => _SetStream(Event.update, f);
  static void set OnLateUpdate(Function f) => _SetStream(Event.lateUpdate, f);
  static void set OnEarlyRender(Function(CanvasRenderingContext2D) f) => _SetStream(Event.earlyRender, f);
  static void set OnRender(Function(CanvasRenderingContext2D) f) => _SetStream(Event.render, f);
  static void set OnLateRender(Function(CanvasRenderingContext2D) f) => _SetStream(Event.lateRender, f);
  static void set OnGUI(Function(CanvasRenderingContext2D) f) => _SetStream(Event.gui, f);
  static void set OnQuit(Function f) => _SetStream(Event.quit, f);

  int frame = 0;
  CanvasElement canvas;
  CanvasRenderingContext2D context;

  Game(CanvasElement this.canvas, CanvasRenderingContext2D this.context){
    Instance = this;
    window.requestAnimationFrame(Main);

    _Emit(Event.awake);
    _Emit(Event.start);
  }

  void Main(num time){
    Time.Update(time);
    frame++;
    _Emit(Event.earlyUpdate);
    _Emit(Event.fixedUpdate);
    _Emit(Event.update);
    _Emit(Event.lateRender);

    context.clearRect(0, 0, window.innerWidth, window.innerHeight);

    _Emit(Event.earlyRender);
    _Emit(Event.render, context);
    _Emit(Event.lateRender);
    _Emit(Event.gui);

    window.requestAnimationFrame(Main);
  }
}

/*
   cursor = Cursor(context, draw: (ctx, pos, [data]){
      CursorData cdata = data as CursorData;

      if(Mouse.pressed){
        if(cdata.enabled)
          cdata.value += Time.DeltaTime;
      }else{
        cdata.value = 0;
        cdata.enabled = true;
      }


      ctx.beginPath();
      ctx.arc(pos.x, pos.y, 10, 0, pi * 2);
      ctx.fill();

      ctx.beginPath();
      ctx.moveTo(pos.x, pos.y);
      ctx.arc(pos.x, pos.y, 20, 0, (pi * 2) * cdata.value);
      ctx.fill();

      if(cdata.value > 1 && cdata.enabled){
        print("Click Occurred at ${pos.x}, ${pos.y}");
        cdata.enabled = false;
      }
    }, store: CursorData());
    */
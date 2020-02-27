import 'package:angular_app/Game.dart';

RegExp SymbolName = RegExp(r'Symbol\("(\w+)[=]"\)');
String Function(Symbol) getName = (Symbol data) => SymbolName.firstMatch(data.toString()).group(1);

class GameObject{
  GameObject(){
    dynamic d = this;
    if(d.OnAwake != null)Game.OnAwake = d.OnAwake;
    if(d.OnStart != null)Game.OnStart = d.OnStart;
    if(d.OnEarlyUpdate != null)Game.OnEarlyUpdate = d.OnEarlyUpdate;
    if(d.OnFixedUpdate != null)Game.OnFixedUpdate = d.OnFixedUpdate;
    if(d.OnUpdate != null)Game.OnUpdate = d.OnUpdate;
    if(d.OnLateUpdate != null)Game.OnLateUpdate = d.OnLateUpdate;
    if(d.OnEarlyRender != null)Game.OnEarlyRender = d.OnEarlyRender;
    if(d.OnRender != null)Game.OnRender = d.OnRender;
    if(d.OnLateRender != null)Game.OnLateRender = d.OnLateRender;
    if(d.OnGUI != null)Game.OnGUI = d.OnGUI;
    if(d.OnQuit != null)Game.OnQuit = d.OnQuit;
  }

  @override
  noSuchMethod(Invocation invocation) {
    // TODO: implement noSuchMethod
    return null;
  }
} 
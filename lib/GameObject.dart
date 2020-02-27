import 'dart:mirrors';
import 'package:angular_app/Game.dart';

RegExp SymbolName = RegExp(r'Symbol\("(\w+)[=]"\)');
String Function(Symbol) getName = (Symbol data) => SymbolName.firstMatch(data.toString()).group(1);

class GameObject{
  GameObject(){
    InstanceMirror r = reflect(this);
    var functions = r.type.instanceMembers;
    var staticFunctions = r.type.staticMembers;
    var staticC = reflectClass(Game);

    for(var v in staticC.staticMembers.values){
      String name = getName(v.simpleName);
      Symbol method = Symbol(name);

      if(functions.containsKey(method) || staticFunctions.containsKey(method)){
        try{
          staticC.setField(method, r.getField(method).reflectee);
        }catch(identifier){
          throw new ArgumentError("$name Does not Take the Right amount of Arguments");
        }
      }
    };
  }
} 
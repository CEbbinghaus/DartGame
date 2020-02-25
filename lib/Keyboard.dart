import 'dart:html';

import 'package:angular_app/Game.dart';

class KeyManager{

	List<bool> _data = List<bool>.filled(256, false);

	static KeyManager Instance;

	void keyCallback(int state, KeyboardEvent evt) {
    if(state == 1)pressed[evt.keyCode] = true;
    if(state == 0)released[evt.keyCode] = true;
    _data[evt.keyCode] = state != 0;
    ctrlKey = evt.ctrlKey;
    shiftKey = evt.shiftKey;
    altKey = evt.altKey;
	}

	bool ctrlKey;
	bool shiftKey;
	bool altKey;

	List<bool> pressed = List<bool>.filled(256, false);
	List<bool> released = List<bool>.filled(256, false);

	static void Update(dynamic){
		if(Instance == null)return;

    Instance.pressed = List<bool>.filled(256, false);
    Instance.released = List<bool>.filled(256, false);
	}

	static KeyManager CreateKeyManager() {
		if (Instance != null)
			return Instance;

		Instance = new KeyManager();

    window.onKeyUp.listen((evt) => Instance.keyCallback.call(0, evt));
    window.onKeyDown.listen((evt) => Instance.keyCallback.call(1, evt));
    window.onKeyPress.listen((evt) => Instance.keyCallback.call(2, evt));

    Game.onUpdate = Update;

		return Instance;
	}

	bool operator[](String key) {
    int i = key.codeUnitAt(0);
		return _data[i];
	}
	
	// bool operator[](KeyCode key) {
	// 	return data[(int)key];
	// }

	static bool Get(String key) {
		if (Instance == null)return false;
    int i = key.codeUnitAt(0);
		if (i > 96 && i < 123)
			return Instance._data[i - 32];

		return Instance._data[i];
	}

	// static bool Get(KeyCode key) {
	// 	if (Instance == nullptr)return false;

	// 	return Instance->data[(int)key];
	// }
}


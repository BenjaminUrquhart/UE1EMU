emu = new UE1Emulator(code);
has_source = !is_undefined(lines);

emu.loop_on_end = true;

if(!has_source) {
	// Attempt to disassemble code if no source is provided
	// Feather ignore GM1041
	var len = array_length(code);
	var real_len = len;
	lines = array_create(len, undefined);
	for(var i = 0; i < len; i++) {
		var pos = code[i]._lineno == -1 ? i : code[i]._lineno;
		if(pos > real_len) {
			lines[pos] = undefined;
			real_len = pos;
		}
		if(!is_undefined(lines[pos])) {
			// this shouldn't happen unless instructions came from different places
			do_throw($"Conflict: {lines[pos]} and {code[i]} share the same line number ({pos})");	
		}
		lines[pos] = code[i].toString();
	}
}

ticked = false;
paused = true;
step = false;

clock_speed = 60;
alarm[0] = game_get_speed(gamespeed_fps) / clock_speed;

count = array_length(lines);

init = false;
previous = -1;
index = 0;

fast_forward = false;
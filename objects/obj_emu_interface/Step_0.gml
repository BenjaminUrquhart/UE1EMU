if(keyboard_check_pressed(vk_space)) {
	if(emu.flagF) {
		paused = false;
		emu.resume();
	}
	else {
		paused = !paused;	
	}
}
if(keyboard_check_pressed(vk_enter)) {
	emu.resume();
	step = true;
}
if(keyboard_check_pressed(ord("R"))) {
	emu.reset();
	init = false;
	step = false;
	paused = true;
}
if(keyboard_check_pressed(ord("E"))) {
	keyboard_string = "";
	instance_activate_object(obj_asm_editor);
	instance_activate_object(obj_options_bar);
	instance_destroy();
	return;
}
if(keyboard_check_pressed(vk_shift)) {
	fast_forward = !fast_forward;	
}

if(fast_forward) {
	do {
		ticked = false;
		previous = emu.current;
		event_perform(ev_alarm, 0);
	} until(!ticked);
	ticked = true;
}

if(ticked || !init) {
	if(init) {
		previous = index;	
	}
	else {
		previous = -1;
	}
	if(!emu.reached_end()) {
		var inst = emu.instructions[emu.current];
		index = inst._lineno == -1 ? emu.current : inst._lineno;
	}
	else {
		index = array_length(lines);	
	}
	ticked = false;
	init = true;
}
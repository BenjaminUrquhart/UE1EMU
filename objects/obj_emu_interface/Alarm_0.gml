if((step || !paused) && !emu.flagF && !emu.reached_end()) {
	var inst = emu.instructions[emu.current].toString();
	emu.tick();
	show_debug_message($"{inst} -> {emu}");
	ticked = true;
}
step = false;

alarm[0] = game_get_speed(gamespeed_fps) / clock_speed;
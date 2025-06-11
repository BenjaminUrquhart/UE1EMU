if((step || !paused) && !emu.flagF) {
	var inst = emu.instructions[emu.reached_end() ? 0 : emu.current].toString();
	ticked = !emu.tick();
	show_debug_message($"{inst} -> {emu}");
}
step = false;

alarm[0] = game_get_speed(gamespeed_fps) / clock_speed;
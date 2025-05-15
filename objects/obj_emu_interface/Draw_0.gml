draw_set_alpha(1);
draw_set_font(fnt_main);
draw_set_color(c_lime);

draw_text(10, 0, $"{paused || emu.flagF ? "Paused" : "Running"} {previous} {index} {count}");

render_items(index, lines, function(i, line, liney) {
	if(is_undefined(line)) return;
	
	var draw = false;
	if(i == previous) {
		draw_set_color(c_yellow);
		draw = true;
	}
	else if(i == index) {
		draw_set_color(c_orange);
		draw = true;
	}
	
	if(draw) {
		draw_rectangle(0, liney, room_width, liney + string_height("A"), false);	
	}
	
	draw_text_highlighted(10, liney, line);
});

draw_set_color(c_lime);
draw_set_halign(fa_right);
draw_text(room_width - 10, 10, emu.toString("\n"));
draw_set_halign(fa_left);
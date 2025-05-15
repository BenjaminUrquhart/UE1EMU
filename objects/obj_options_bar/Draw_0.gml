draw_set_alpha(1);
draw_set_font(fnt_main);
draw_set_color(backing_color);
draw_rectangle(0, 0, room_width, string_height("A"), false);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for(var i = 0; i < num_options; i++) {
	var option = options[i];
	var offsetx = options_width * i;
	
	draw_set_color(c_ltgray);
	if(hovered_index == i || option.active_timer != -1) {
		draw_rectangle(offsetx, 0, offsetx + options_width, bar_height, false);
		draw_set_color(backing_color);
	}
	draw_text(offsetx + options_width / 2, bar_height / 2, option.name);
	/*
	draw_set_color(c_black);
	draw_line(offsetx + options_width, 0, offsetx + options_width, bar_height);*/
}
draw_set_halign(fa_right);
draw_set_valign(fa_top);

draw_set_color(c_red);
draw_text(room_width, 0, $"{mouse_x} {mouse_y}");
draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_font(fnt_main);

render_items(cursor.line, code, function(i, line, liney) {
	if(is_undefined(line)) return;
	
	draw_text_highlighted(10, liney, line);
	
	var charw = string_width("A");
	var charh = string_height("A");
	
	if(i == cursor.line && cursor.visible) {
		draw_set_color(c_lime);
		var pos = cursor.pos();
		var cursorx = 10 + charw * pos;
		draw_rectangle(cursorx, liney, cursorx + charw, liney + charh, false);
		draw_set_color(c_black);
		draw_text(cursorx, liney, string_char_at(line, pos + 1));
	}
});
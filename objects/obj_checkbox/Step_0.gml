hovered = (mouse_x >= x && mouse_x <= x + size && mouse_y >= y && mouse_y <= y + size);

if(hovered) {
	if(mouse_check_button_pressed(mb_left)) {
		clicking = true;
	}
	else if(mouse_check_button_released(mb_left) && clicking) {
		checked = !checked;
		callback(checked);
	}
}
if(!mouse_check_button(mb_left)) {
	clicking = false;	
}
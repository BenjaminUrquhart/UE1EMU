if(!active) {
	return;	
}

while(!ds_queue_empty(action_queue)) {
	var info = ds_queue_dequeue(action_queue);
	try_exec(info.callback, info.args);
}

// In case a callback disables the bar
if(!active) {
	return;	
}

for(var i = 0; i < num_options; i++) {
	var option = options[i];
	var binds = option.keybind;
	if(option.active_timer >= 0) {
		option.active_timer--;	
	}
	if(is_array(binds)) {
		var num_keys = array_length(binds);
		var pressed = num_keys > 0;
		for(var j = 0; j < num_keys; j++) {
			if(!keyboard_check(binds[j])) {
				pressed = false;
				break;
			}
		}
		if(pressed && option.active_timer < 0 && keyboard_check_pressed(binds[num_keys - 1])) {
			keyboard_string = "";
			array_foreach(binds, keyboard_clear);
			enqueue_action(any_option_callback, option);
			option.active_timer = 5;
			
			if(is_callable(variable_struct_get(option, "callback"))) {
				enqueue_action(option.callback);
			}
		}
	}
}
if(mouse_y >= 0 && mouse_y < bar_height) {
	var option_index = floor(mouse_x / options_width);
	if(option_index < num_options) {
		if(mouse_check_button_pressed(mb_left)) {
			window_set_cursor(cr_arrow);
			var option = options[option_index];
			if(is_callable(variable_struct_get(option, "callback"))) {
				enqueue_action(any_option_callback, option);
				enqueue_action(option.callback);	
			}
		}
		else {
			window_set_cursor(cr_handpoint);
		}
	}
	else {
		window_set_cursor(cr_arrow);
	}
	hovered_index = option_index;
}
else {
	window_set_cursor(cr_arrow);
	hovered_index = -1;	
}
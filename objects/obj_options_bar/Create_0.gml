num_options = 0;
options_width = 1;
options = [];

active = true;

draw_set_font(fnt_main);

bar_height = string_height("A");

hovered_index = -1;

action_queue = ds_queue_create();

any_option_callback = undefined;

enqueue_action = function(callback) {
	if(is_callable(callback)) {
		var args = array_create(argument_count - 1);
		for(var i = 1; i < argument_count; i++) {
			args[i - 1] = argument[i];	
		}
		ds_queue_enqueue(action_queue, { callback, args });
	}
}

add_option = function() {
	var option;
	if(argument_count == 1) {
		if(is_string(argument0)) {
			option = { name: argument0 }
		}
		else if(is_struct(argument0)) {
			option = argument0;
		}
		else if(is_callable(argument0)) {
			option = { callback: argument0 };	
		}
		else {
			throw $"Invalid argument to add_option: {argument0}";	
		}
	}
	else if(argument_count == 2) {
		option = {
			name: argument0,
			callback: argument1
		}
	}
	else if(argument_count == 3) {
		var binds = is_array(argument1) ? argument1 : [argument1];
		option = {
			name: argument0,
			keybind: argument1,
			callback: argument2,
		}
	}
	else {
		throw $"Expected 1-3 arguments to add_option, got {argument_count}";	
	}
	
	if(!variable_struct_exists(option, "name")) {
		option.name = $"Unnamed {num_options + 1}";	
	}
	if(!variable_struct_exists(option, "callback")) {
		option.callback = undefined;	
	}
	
	if(variable_struct_exists(option, "keybind")) {
		if(!is_array(option.keybind)) {
			option.keybind = [option.keybind];	
		}
	}
	else {
		option.keybind = undefined;		
	}
	
	option.active_timer = -1;
	
	var fnt = draw_get_font();
	draw_set_font(fnt_main);
	var len = floor(string_width(option.name) * 1.1);
	if(len > options_width) {
		options_width = len;
	}
	array_push(options, option);
	draw_set_font(fnt);
	num_options++;
}

backing_color = merge_color(c_gray, c_black, 0.5);

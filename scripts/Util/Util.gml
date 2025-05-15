function do_throw(msg) {
	global.__last_exception = { message: msg, stacktrace: debug_get_callstack() }
	throw global.__last_exception;
}

function dec_to_bin(number, pad = 8) {
	pad = max(pad, 1);
	if(number == 0) {
		return string_repeat("0", pad);	
	}
	
	var out = "";
	var len = 0;
	while(number != 0) {
		out = ((number & 1) ? "1" : "0") + out;
		number = number >> 1;
		len++;
	}
	if(len < pad) {
		out = string_repeat("0", pad - len) + out;	
	}
	return out;
}

function read_text_file(filename) {
	var file = file_text_open_read(filename);

	var out = "";
	while(!file_text_eof(file)) {
		out += file_text_read_string(file) + "\n";
		file_text_readln(file);
	}

	file_text_close(file);
	return out;
}

function seek_to_char(line, target, pos, len) {
	while(pos <= len && string_char_at(line, pos) != target) {
		pos++;
	}
	return pos;
}

function seek_to_nonspace(line, pos, len) {
	while(pos <= len && string_char_at(line, pos) == " ") {
		pos++;
	}
	return pos;
}

function create_options_bar() {
	var bar = instance_create_depth(0, 0, 0, obj_options_bar);
	for(var i = 0; i < argument_count; i++) {
		var option = argument[i];
		if(variable_struct_exists(option, "callback") && is_callable(option.callback)) {
			option.callback = method(id, option.callback);	
		}
		// idk what feather is going on about
		// Feather ignore once GM1020
		bar.add_option(option);	
	}
	return bar;
}

function try_exec(func, args = []) {
	try {
		if(!is_callable(func)) {
			do_throw($"Provided argument is not callable: {func}");	
		}
		method_call(func, args);
	}
	catch(e) {
		show_exception(e);	
	}
}

function show_exception(e, prefix = "") {
	var out = prefix;
	if(is_struct(e) && variable_struct_exists(e, "message")) {
		if(variable_global_exists("__last_exception") && string_pos("Unable to find a handler for exception", e.message) == 1) {
			e = global.__last_exception;
		}
		out += e.message;
		if(is_array(e.stacktrace)) {
			var len = array_length(e.stacktrace);
			for(var i = 0; i < len; i++) {
				var trace = e.stacktrace[i];
				if(is_string(trace)) {
					out += $"\nat {trace}";
				}
			}
		}
	}
	else {
		out += string(e);	
	}
	show_debug_message(out);
	show_message(out);
}
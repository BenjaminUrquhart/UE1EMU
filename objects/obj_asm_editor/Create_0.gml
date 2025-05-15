cursor = {
	line: 0,
	realpos: 0,
	visible: false,
	
	editor: other.id,
	
	
	moveUp: function(wrapping = false) {
		if(line > 0) {
			line--;
			if(wrapping) {
				realpos = lineLen();	
			}
			return true;
		}
		return false;
	},
	
	moveDown: function(wrapping = false) {
		if(line < array_length(editor.code) - 1) {
			line++;
			if(wrapping) {
				realpos = 0;
			}
			return true;
		}
		return false;
	},
	
	moveLeft: function() {
		realpos = pos();
		if(realpos > 0) {
			realpos--;
			return true;
		}
		return moveUp(true);
	},
	
	moveRight: function() {
		if(realpos < lineLen()) {
			realpos++;
			return true;
		}
		return moveDown(true);
	},
	
	lineLen: function() {
		return string_length(editor.code[line]);	
	},
	
	pos: function() {
		return min(lineLen(), realpos);	
	}
}

input = {
	repeat_timer: 40,
	repeat_interval: 2,
	
	key_timers: {},
	
	reset_keys: function(keys) {
		array_foreach(keys, function(key) { key_timers[$ key] = -1 });	
	},
	
	step: function() {
		var keys = variable_struct_get_names(key_timers);
		return array_reduce(keys, function(state, key) {
			if(keyboard_check(real(key))) {
				key_timers[$ key]++;
				return state || check(key);
			}
			else {
				key_timers[$ key] = -1;
				return state;
			}
		}, false) || keyboard_check_pressed(vk_anykey);
	},
	
	check: function(key) {
		if(!variable_struct_exists(key_timers, string(key))) {
			key_timers[$ key] = keyboard_check_pressed(key) - 1;
		}
		var count = key_timers[$ key];
		return count == 0 || (count >= repeat_timer && (count % repeat_interval == 0));
	}
}

code = [""];

keyboard_lastchar = "";

scroll_pos = 0;

blink_delay = 30;
alarm[0] = 1;

buffer_space = 5;

filepath = undefined;
//disassembly = false;
saved = true;

update_titlebar = function() {
	var title = "UE1EMU - ";
	if(!saved) {
		title += "*";	
	}
	title += is_undefined(filepath) || filepath == "" ? "<new file>" : filepath;
	window_set_caption(title);	
}

create_full_code_string = function() {
	var fullcode = "";
	var len = array_length(code);
	for(var i = 0; i < len; i++) {
		fullcode += code[i] + "\n";	
	}
	return fullcode;
}

load_file = function(path) {
	var code = new DynamicArray();
	var file = file_text_open_read(path);
	var line;
	while(!file_text_eof(file)) {
		line = file_text_read_string(file);
		file_text_readln(file);
		code.push(line);
	}
	file_text_close(file);
	self.code = code.get();
	filepath = path;
	cursor.realpos = 0;
	cursor.line = 0;
	saved = true;
}

assemble = function(to_bytes = false) {
	return (to_bytes ? UE1_assemble_binary : UE1_assemble)(create_full_code_string());
}

disassemble = function(path) {
	var buff = buffer_load(path);
	try {
		var out = UE1_disassemble(buff);
		saved = true;
		return out;
	}
	finally {
		buffer_delete(buff);
	}
}

save_file =  function(asm = false) {
	// Doing this early to catch errors before prompting for where to save
	var compiled;
	if(asm /*|| disassembly*/) {
		compiled = assemble(true);	
	}
	
	var path = filepath;
	if(asm /*&& !disassembly*/) {
		path = get_save_filename("*.bin", "");
	}
	else if(is_undefined(filepath) || filepath == "") {
		filepath = get_save_filename((asm /*|| disassembly*/) ? "*.bin" : "*.asm", "");
		path = filepath;
	}
	if(path != "") {
		if(/*disassembly ||*/ asm) {
			buffer_save(compiled, path);
		}
		else {
			var file = file_text_open_write(path ?? filepath);
			var len = array_length(code);
			for(var i = 0; i < len; i++) {
				file_text_write_string(file, code[i]);
				file_text_writeln(file);
			}
			file_text_close(file);
		}
		saved = true;
	}
}

options = create_options_bar(
	{
		name: "Open",
		callback: function() {
			var path = get_open_filename("*.asm", "");
			if(path != "") {
				load_file(path);	
			}
		}
	},
	{
		name: "Save",
		keybind: [vk_control, ord("S")],
		callback: save_file
	},
	{
		name: "Disasm.",
		callback: function() {
			var path =  get_open_filename("*.bin", "");
			if(path != "") {
				var instructions = disassemble(path);
				var len = array_length(instructions);
				var code = array_create(len);
				for(var i = 0; i < len; i++) {
					code[i] = instructions[i].toString();	
				}
				self.code = code;
				//disassembly = true;
				//filepath = path;
				filepath = "";
			}
		}
	},
	{
		name: "Assemble",
		callback: function() {
			save_file(true);
		}
	},
	{
		name: "Run",
		keybind: vk_f5,
		callback: function() {
			try {
				instance_create_depth(0, 0, depth, obj_emu_interface, {
					lines: code,
					code: assemble()
				});
			}
			catch(e) {
				show_exception(e);
				return;
			}
			window_set_cursor(cr_arrow);
			instance_deactivate_object(options);
			instance_deactivate_object(self);
			options.active = false;
		}
	}
);

options.any_option_callback = function(opt) {
	update_titlebar();
}
if(!input.step()) {
	return;	
}

cursor.visible = true;
alarm[0] = blink_delay;

if(input.check(vk_left)) {
	cursor.moveLeft();
}
if(input.check(vk_right)) {
	cursor.moveRight();
}
if(input.check(vk_up)) {
	cursor.moveUp();
}
if(input.check(vk_down)) {
	cursor.moveDown();	
}

// The line is re-fetched every time to make sure multiple operations within the same frame don't operate on stale data

if(input.check(vk_enter)) {
	var line = code[cursor.line];
	array_insert(code, cursor.line + 1, string_copy(line, cursor.pos() + 1, string_length(line) - cursor.pos()));
	code[cursor.line] = string_copy(line, 1, cursor.pos());
	cursor.moveDown(true);
	saved = false;
}
if(input.check(vk_backspace)) {
	var line = code[cursor.line];
	var pos = cursor.pos();
	if(pos == 0) {
		if(cursor.line > 0) {
			var lineno = cursor.line;
			cursor.moveLeft();
			array_delete(code, lineno , 1);
			code[cursor.line] += line;
			saved = false;
		}
	}
	else {
		cursor.moveLeft();
		code[cursor.line] = string_delete(line, pos, 1);
		saved = false;
	}
}

if(input.check(vk_delete)) {
	var line = code[cursor.line];
	var len = string_length(line);
	var pos = cursor.pos();
	if(pos >= len) {
		if(cursor.line < array_length(code) - 1) {
			code[cursor.line] += code[cursor.line + 1];
			array_delete(code, cursor.line + 1, 1);
			saved = false;
		}
	}
	else {
		code[cursor.line] = string_delete(line, pos + 1, 1);
		saved = false;
	}
}

if(keyboard_string != "") {
	show_debug_message(keyboard_string);
	var line = code[cursor.line];
	var len = string_length(line);
	
	if(cursor.pos() == 0) {
		code[cursor.line] = keyboard_string + line;	
	}
	else if(cursor.pos() >= len) {
		code[cursor.line] += keyboard_string;
		if(cursor.realpos > len) {
			cursor.realpos = len;	
		}
	}
	else {
		code[cursor.line] = string_copy(line, 1, cursor.pos()) + keyboard_string + string_copy(line, cursor.pos() + 1, len - cursor.pos() + 1);	
	}
	repeat(string_length(keyboard_string)) {
		cursor.moveRight();	
	}
	keyboard_string = "";
	saved = false;
}
function render_items(index, items, callback) {
	render_items_ext(index, items, 5, callback);
}
function render_items_ext(index, items, buffer_space, callback) {
	callback = method(other.id ?? global, callback); // bind callback to calling instance or global scope
	
	var line_height = string_height("A") + buffer_space;
	var num_fit = floor(room_height / line_height) - 1;
	var count = array_length(items);

	var start = index - floor(num_fit/2);
	var stop = index + ceil(num_fit/2);

	if(stop > count) {
		start -= (stop - count);
		stop = count;
	}

	if(start < 0) {
		stop -= start;
		start = 0;
	}
	
	for(var i = start; i < stop; i++) {
		if(i >= count) break;
	
		if(is_undefined(items[i])) continue;
	
		var liney = line_height * (i - start + 1) + buffer_space;
		
		callback(i, items[i], liney);
	}
	
}

// you ever build 2 different parsers for no reason
function draw_text_highlighted(xx, yy, line) {	
	line += " "; // to ensure the last word on the line is displayed
	
	var len = string_length(line);
	var charw = string_width("A");
	var start = seek_to_nonspace(line, 1, len);
	
	var num_tokens = 0;
	var prev_token = "";
	var valid_token = false;
	
	var buffer = "";
	for(var i = start; i <= len; i++) {
		var char = string_char_at(line, i);
		var drawx = xx + charw * (i - 1);
		if(char != " " && char != ";") {
			buffer += char;
		}
		else {
			if(string_length(buffer) > 0) {
				var color = c_white;
				
				// opcode
				if(num_tokens == 0) {
					valid_token = true;
					switch(string_upper(buffer)) {
						case "NOP0": 
						case "NOPF":  color = c_maroon; break;
					
						case "LD":    color = c_lime; break;
					
						case "ADD":
						case "SUB":   color = c_aqua; break;
					
						case "ONE":   color = c_yellow; break;
					
						case "NAND":
						case "XOR":   color = c_green; break;
					
						case "STO":
						case "STOC":  color = c_fuchsia; break;
					
						case "IEN":
						case "OEN":
						case "IOC":   color = c_blue; break;
					
						case "RTN":
						case "SKZ":   color = c_orange; break;
					
						default:      color = c_white; valid_token = false; break;
					}	
				}
				// address
				else if(num_tokens == 1 && valid_token) {
					var addr = string_upper(buffer);
					if(variable_struct_exists(Register, addr)) {
						switch(prev_token) {
							case "NOP0":
							case "NOPF":// address is ignored for these
							case "ONE": color = merge_color(c_ltgray, c_black, 0.5); break;
								
							default: {
								switch(string_char_at(addr, 1)) {
									case "I": color = c_lime; break;
									case "O": color = c_purple; break;
									case "R": color = c_orange; break;
									case "S": color = merge_color(c_red, c_white, 0.25);
								}
							}
						}
					}
				}
				draw_set_color(color);
				draw_text(drawx - (string_width(buffer) - 1), yy, buffer);
				prev_token = string_upper(buffer);
				num_tokens++;
				buffer = "";
			}
			if(char == ";") {
				draw_set_color(c_gray);
				draw_text(drawx, yy, char + string_delete(line, 1, i));
				return;	
			}
			i = seek_to_nonspace(line, i, len) - 1;
		}
	}
}
function Instruction() constructor {
	opcode = -1
	register = -1
	
	// for UI purposes
	_lineno = -1
	//_line = ""
	
	if(argument_count == 1) {
		opcode = (argument[0] >> 4) & 0xf;
		register = argument[0] & 0xf;
	}
	else if(argument_count >= 2) {
		opcode = argument[0];
		register = argument[1];
	}
	
	if(argument_count) {
		// Should never happen under normal circumstances
		if(opcode < 0 || opcode > 15) {
			do_throw($"Invalid opcode: {opcode}");	
		}
		if(register < 0 || register > 15) {
			do_throw($"Invalid register: {register}");	
		}
	}
	
	static toByte = function() {
		return ((opcode << 4) | register) & 0xff;	
	}
	
	static toString = function() {
		if(opcode == -1 || register == -1) {
			return "<not initialized>";	
		}
		var op = global.opcode_mapping[$ opcode];
		var reg;
		if(register < 8) {
			reg = "SR" + string(register);
		}
		else if(opcode == Opcode.STO || opcode == Opcode.STOC) {
			reg = "OR" + string(register - 8);	
		}
		else if(register == 8) {
			reg = "RR";	
		}
		else {
			reg = "IR" + string(register - 8);	
		}
		return op + " " + reg;
	}
}

// Parses code into instructions
// TODO: allow arrays of strings (as lines of code)
// to optimize parsing input from the integrated editor.
function UE1_assemble(code) {
	static no_reg = {
		"NOP0": true,
		"ONE": true,
		"IOC": true,
		"RTN": true,
		"SKZ": true,
		"NOPF": true
	}
	
	var out = new DynamicArray();
	
	var pos = 1;
	
	var inst = new Instruction();
	
	var buffer = "", char;
	var len = string_length(code);
	var line = 1, line_start = 1;
	try {
		while(pos <= len) {
			char = string_char_at(code, pos);
			if(char == "\r") {
				pos++;
				continue;
			}
			if(char == "\n") {
				if(string_length(buffer) > 0) {
					if(inst.opcode == -1) {
						throw $"Incomplete instruction near {buffer}";
					}
					if(!variable_struct_exists(Register, buffer)) {
						throw $"Invalid register: {buffer}";
					}
					inst.register = Register[$ buffer];
					buffer = "";
				}
				else if(inst.register == -1 && inst.opcode != -1) {
					if(variable_struct_exists(no_reg, global.opcode_mapping[$ inst.opcode])) {
						inst.register = Register.RR;
					}
					else {
						throw $"Unexpected EOL";
					}
				}
				if(inst.opcode != -1) {
					inst._lineno = line - 1;
					//inst._line = string_copy(code, line_start, pos - 1);
					out.push(inst);
					//show_debug_message(inst);
					inst = new Instruction();
				}
				line_start = pos + 1;
				line++;
			}
			else if(char == ";") {
				pos = seek_to_char(code, "\n", pos, len) - 1;
			}
			else if(char == " ") {
				if(string_length(buffer) > 0) {
					if(inst.opcode == -1) {
						if(!variable_struct_exists(Opcode, buffer)) {
							throw $"Invalid opcode: {buffer}";
						}
						inst.opcode = Opcode[$ buffer];
					}
					else if(inst.register == -1) {
						// TODO: validate whether register is a valid target
						// for the given opcode.
						if(!variable_struct_exists(Register, buffer)) {
							throw $"Invalid register: {buffer}";
						}
						inst.register = Register[$ buffer];
					}
				}
				buffer = "";
			}
			else {
				if(inst.opcode != -1 && inst.register != -1) {
					throw $"Unexpected character: {char}";
				}
				buffer += string_upper(char);	
			}
			pos++;
		}
	}
	catch(e) {
		if(is_string(e)) {
			throw $"Assembly error occurred on line {line}: {e}";	
		}
		var msg = is_struct(e) && variable_struct_exists(e, "message") ? e.message : e;
		do_throw($"Assembly error occurred on line {line}: {msg}");
	}
	return out.get();
}

// Parses code into assembly binary
function UE1_assemble_binary(code) {
	var instructions = UE1_assemble(code);
	var len = array_length(instructions);
	var out = buffer_create(len, buffer_fixed, 1);
	for(var i = 0; i < len; i++) {
		buffer_write(out, buffer_u8, instructions[i].toByte());	
	}
	return out;
}

// Disassembles a binary into instructions
function UE1_disassemble(buff) {
	var size = buffer_get_size(buff)
	var out = array_create(size);
	for(var i = 0; i < size; i++) {
		out[i] = new Instruction(buffer_read(buff, buffer_u8));	
	}
	return out;
}
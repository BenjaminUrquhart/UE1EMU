function UE1Emulator(instructions, switches = 0) constructor {
	
	// A soft reset only clears flag0, flagF, rtn, and the instruction pointer
	// A standard reset also clears all the registers.
	static reset = function(soft = false) {
		self.current = 0;
		self.flag0 = 0;
		self.flagF = 0; // halt flag, stops tape reader on real hardware
		self.rtn = 0;
		
		if(!soft) {
			self.scratch = 0;
			self.result = 0;
			self.output = 0;
			self.ien = 0;
			self.oen = 0;
			self.carry = 0;
		}
	}
	
	self.switches = switches;
	self.instructions = instructions;
	
	reset();
	
	static read_reg = function(reg) {
		if(reg == 8) {
			return result;
		}
		if(!ien) {
			return 0;
		}
		if(reg < 8) {
			return (scratch >> reg) & 1;	
		}
		return (switches >> (reg - 9)) & 1;
	}
	
	static write_reg = function(reg, bit) {
		if(!oen) {
			return;
		}
		if(reg < 8) {
			scratch = ((scratch & ~(1 << reg)) | (bit << reg)) & 0xff;
			return;
		}
		output = ((output & ~(1 << (reg - 8))) | (bit << (reg - 8))) & 0xff;
	}
	
	static format_reg = function(reg) {
		return $"{reg} ({dec_to_bin(reg)})";
	}
	
	static tick = function() {
		var ended = reached_end();
		if(!flagF && !ended) {
			// idk when these are reset on hardware
			flag0 = 0;
			flagF = 0; // redundant
			rtn = 0;
			
			var inst = instructions[current];
			switch(inst.opcode) {
				case Opcode.NOP0: flag0 = 1; break;
				case Opcode.LD:   if ien result = read_reg(inst.register); break;
				case Opcode.ADD:  if ien {
					var res = result + carry + read_reg(inst.register);
					result = res & 1;
					carry = (res >> 1) & 1;
				} break;
				case Opcode.SUB:  if ien {
					// this doesn't make sense to me but it's how I understand the spec
					// and I don't want to look at existing emulators
					var res = result + carry + !read_reg(inst.register);
					result = res & 1;
					carry = (res >> 1) & 1;
				} break;
				case Opcode.ONE:  result = 1; carry = 0; break;
				case Opcode.NAND: if ien result &= (~read_reg(inst.register)) & 1; break;
				case Opcode.OR:   if ien result |= read_reg(inst.register); break;
				case Opcode.XOR:  if ien result ^= read_reg(inst.register); break;
				case Opcode.STO:  if oen write_reg(inst.register, result); break;
				case Opcode.STOC: if oen write_reg(inst.register, !result); break; //result is 1 bit
				case Opcode.IEN:  ien = read_reg(inst.register); break;
				case Opcode.OEN:  oen = read_reg(inst.register); break;
				case Opcode.IOC:  ioc_handler(); break;
				case Opcode.RTN:  rtn = 1; current++; break;
				case Opcode.SKZ:  current += !result; break;
				case Opcode.NOPF: flagF = 1; break;
				default: do_throw($"Invalid opcode {inst.opcode} at position {current}");
			}
			current++;
		}
		return flagF || ended;
	}
	
	static reached_end = function() {
		return current >= array_length(instructions);
	}
	
	static resume = function() {
		flagF = 0;
	}
	
	// Ring bell
	static ioc_handler = function() {
		show_debug_message("Ding!");
		audio_stop_sound(snd_bell);
		audio_play_sound(snd_bell, 50, false);
	}
	
	static toString = function(sep=", ") {
		return $"s={format_reg(scratch)}{sep}i={format_reg(switches)}{sep}o={format_reg(output)}{sep}rr={result}{sep}carry={carry}{sep}ien={ien}{sep}oen={oen}";
	}
}
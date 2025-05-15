// Using structs instead of enums since I would like 
// a lookup table for the assembler anyway

// For syntax highlighting
#macro Opcode global.opcodes
#macro Register global.registers

global.opcodes = {
	NOP0: 0,
	LD: 1,
	ADD: 2,
	SUB: 3,
	ONE: 4,
	NAND: 5,
	OR: 6,
	XOR: 7,
	STO: 8,
	STOC: 9,
	IEN: 10,
	OEN: 11,
	IOC: 12,
	RTN: 13,
	SKZ: 14,
	NOPF: 15
}

global.opcode_mapping = {}

var opcodes = variable_struct_get_names(Opcode);
var len = array_length(opcodes);
for(var i = 0; i < len; i++) {
	global.opcode_mapping[$ Opcode[$ opcodes[i]]] = opcodes[i];
}

global.registers = {
	SR0: 0,
	SR1: 1,
	SR2: 2,
	SR3: 3,
	SR4: 4,
	SR5: 5,
	SR6: 6,
	SR7: 7,
	
	RR: 8,
	
	OR0: 8,
	OR1: 9,
	OR2: 10,
	OR3: 11,
	OR4: 12,
	OR5: 13,
	OR6: 14,
	OR7: 15,
	
	// IR0 is shadowed by RR when reading
	IR1: 9,
	IR2: 10,
	IR3: 11,
	IR4: 12,
	IR5: 13,
	IR6: 14,
	IR7: 15
}
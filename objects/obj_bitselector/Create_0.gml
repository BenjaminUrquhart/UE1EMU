get_value = function() { return 0; }
set_value = function(val) {}
can_modify = function() { return false; }

get_bit = function(bit) {
	return (get_value() >> bit) & 1;
}

set_bit = function(bit, value) {
	if(can_modify()) {
		var val = get_value();
		set_value((val & ~(1 << bit)) | (value << bit));
	}
}
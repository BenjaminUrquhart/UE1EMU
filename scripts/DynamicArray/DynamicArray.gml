// I got tired of manually managing array resizing
// because Gamemaker isn't the smartest with them
// (and also I don't want to manage ds_lists).
function DynamicArray(capacity = 10) constructor {
	self.length = 0;
	self.capacity = capacity;
	self.arr = array_create(capacity)
	
	static _checkResize = function(extra = 0) {
		if(length + extra >= capacity /*|| length + extra < floor(capacity / 1.5)*/) {
			capacity = floor((length + extra) * 1.5);
			array_resize(arr, capacity);
		}
	}
	
	static get = function() {
		if(capacity > length) {
			capacity = length;
			array_resize(arr, length);	
		}
		return arr;
	}
	
	static push = function() {
		_checkResize(argument_count);
		var i = 0;
		repeat(argument_count) {
			arr[length] = argument[i++];
			length++;
		}
	}
}
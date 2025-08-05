

struct OptByte {
	private ubyte value;
	bool isNone;
	
	this(ubyte b) {
		value = b;
		isNone = false;
	}
	this(bool x) {
		value = 0;
		isNone = x;
	}
	
	ubyte get() {
		if (isNone) assert(0);
		return value;
	}
	
	// Compiler-generated opEquals should be fine, as isNone=true, value!=0 is invalid
}


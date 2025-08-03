

class Atom {
	// TODO: Replace with a proper algebraic data type
	AtomType type;
	
	ulong row;
	StringType styleKey;
	string content;
	char c;
	
	this(ulong r) {
		type = AtomType.startOfRow;
		
		row = r;
		styleKey = StringType.none;
		content = "";
		c = '\xFF';
	}
	
	this(StringType t) {
		type = AtomType.style;
		
		row = 0;
		styleKey = t;
		content = "";
		c = '\xFF';
	}
	
	this(string s) {
		type = AtomType.str;
		
		row = 0;
		styleKey = StringType.none;
		content = s;
		c = '\xFF';
	}
	
	this(char x) {
		type = AtomType.chr;
		
		row = 0;
		styleKey = StringType.none;
		content = "";
		c = x;
	}
	
	this(StringType t, string s) {
		type = AtomType.stylePlusStr;
		
		row = 0;
		styleKey = t;
		content = s;
		c = '\xFF';
	}
}

enum AtomType {
	startOfRow,
	
	style,
	str,
	chr,
	
	stylePlusStr
}

enum StringType {
	none,
	ui,
	fileHeader,
	
	addressPrimary,
	addressSecondary,
	integerPrimary,
	integerSecondary,
	textPrimary,
	textSecondary,
	
	diff1Primary,
	diff1Secondary,
	diff2Primary,
	diff2Secondary
}
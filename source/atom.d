

class Atom {
	// TODO: Replace with a proper algebraic data type
	AtomType type;
	
	ulong row;
	StringType styleKey;
	string content;
	
	this(ulong r) {
		type = AtomType.startOfRow;
		
		row = r;
		styleKey = StringType.none;
		content = "";
	}
	
	this(string s) {
		type = AtomType.str;
		
		row = 0;
		styleKey = StringType.none;
		content = s;
	}
	
	this(StringType t) {
		type = AtomType.style;
		
		row = 0;
		styleKey = t;
		content = "";
		
	}
	
	this(StringType t, string s) {
		type = AtomType.stylePlusStr;
		
		row = 0;
		styleKey = t;
		content = s;
	}
}

enum AtomType {
	startOfRow,
	
	style,
	str,
	
	stylePlusStr
}

enum StringType {
	none,
	ui,
	
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
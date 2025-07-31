

class Atom {
	// TODO: Replace with a proper algebraic data type
	AtomType type;
	
	StringType styleKey;
	string content;
	
	this(bool b) {
		type = AtomType.dummy;
		if (b) type = AtomType.endOfRow;
		
		styleKey = StringType.none;
		content = "";
	}
	
	this(string s) {
		type = AtomType.str;
		
		styleKey = StringType.none;
		content = s;
	}
	
	this(StringType t) {
		type = AtomType.style;
		
		styleKey = t;
		content = "";
		
	}
	
	this(StringType t, string s) {
		type = AtomType.stylePlusStr;
		
		styleKey = t;
		content = s;
	}
}

enum AtomType {
	dummy,
	endOfRow,
	
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
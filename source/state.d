import atom;
import init_shutdown;

class WholeProcessState {
	ExitInformation exit;
	ScreenInformation screen;
	FileInformation[] files;
	
	TypesetInformation typeset;
	RenderInformation render;
	InputInformation input;
	
	this(Arguments arguments, ExitInformation e, ScreenInformation s) {
		exit = e;
		screen = s;
		
		files = new FileInformation[arguments.filenameCount];
		for (int i = 0; i < files.length; i++) {
			files[i] = new FileInformation(arguments.filenames[i], arguments.indexZeroAddresses[i]);
		}
		
		typeset = new TypesetInformation();
		render = new RenderInformation();
		input = new InputInformation();
	}
}



class ExitInformation {
	bool shouldQuit;
	string[] warningMessages;
	string errorMessage;
	
	this() {
		shouldQuit = false;
		warningMessages = null;
		errorMessage = "";
	}
	
	void normal() {
		shouldQuit = true;
	}
	void error(string s) {
		if (errorMessage != "") return;
		
		shouldQuit = true;
		errorMessage = "ERROR: " ~ s;
	}
	void warn(string s) {
		warningMessages ~= ("Warning: " ~ s);
	}
}

class ScreenInformation {
	ulong rows;
	ulong columns;
	
	this(ulong r, ulong c) {
		update(r, c);
	}
	void update(ulong r, ulong c) { // TODO needed? or just construct a new instance?
		rows = r;
		columns = c;
	}
}

// FIXME various file exceptions
class FileInformation {
	import std.mmfile;
	string filename;
	MmFile fileHandle;
	
	ulong currentTopRowIndex;
	ulong addressOfIndexZero;
	ubyte[] getSlice(ulong startIndex, ulong length) {
		import std.checkedint;
		Checked!(ulong, Saturate) working = startIndex;
		working += length;
		if (working > fileHandle.length) working = fileHandle.length;
		
		ulong endExclusive = working.get;
		return cast(ubyte[]) fileHandle[startIndex .. endExclusive];
	}
	
	this(string name, ulong iza) {
		filename = name;
		fileHandle = new MmFile(filename, MmFile.Mode.read, 0, null); // FIXME make readWrite
		addressOfIndexZero = iza;
	}
	
	ulong address(ulong actingIndex) {
		import std.checkedint;
		
		Checked!(ulong, Saturate) working = actingIndex;
		working += addressOfIndexZero;
		return working.get;
	}
	ulong length() const {
		return fileHandle.length;
	}
}



class TypesetInformation {
	AddressInformation address;
	IntegerInformation integer;
	TextInformation text;
	
	ulong bytesPerRow;
	ulong columnsPerRow() {
		ulong addressColumns = 10;
		ulong integerDataColumns = 3 * bytesPerRow;
		ulong integerInternalSpacing = (bytesPerRow + 2) / 4; // See below
		ulong textColumns = bytesPerRow;
		// For internal spacing (with aligned data, unaligned addresses):
			// 5 bytes needs 1 internal space (1.4)
			// 6 bytes needs 2 internal spaces (1.4.1)
			// Every additional 4 bytes needs an additional internal space: 10 -> (1.4.4.1)
		
		// 80 columns @ 16 bytes per row
		return addressColumns + 1 + integerDataColumns + integerInternalSpacing + 1 + textColumns;
	}
	
	this() {
		address = new AddressInformation();
		integer = new IntegerInformation();
		text = new TextInformation();
	}
}

enum LetterCase {
	lowercase,
	uppercase
}

class AddressInformation {
	LetterCase letterCase;
	AddressMode mode;
	
	this() {
		letterCase = LetterCase.uppercase;
		mode = AddressMode.hexadecimal;
	}
}
enum AddressMode {
	hexadecimal,
	decimal,
	//TODO gbRom
}

class IntegerInformation {
	LetterCase letterCase;
	
	IntAlignedness alignedness;
	IntEndianness endianness;
	IntSignedness signedness;
	IntWidth width;
	IntRadix radix;
	
	this() {
		letterCase = LetterCase.uppercase;
		alignedness = IntAlignedness.unaligned;
		endianness = IntEndianness.littleEndian;
		signedness = IntSignedness.unsigned;
		width = IntWidth.w8;
		radix = IntRadix.hexadecimal;
	}
}
enum IntAlignedness {
	unaligned,
	aligned
}
enum IntEndianness {
	littleEndian,
	bigEndian
}
enum IntSignedness {
	unsigned,
	signed
}
enum IntWidth {
	w8,
	w16,
	w32,
	//TODO? w64
}
enum IntRadix {
	hexadecimal,
	decimal,
	//TODO binary
}

class TextInformation {
	TextEncoding encoding;
	
	this() {
		encoding = TextEncoding.ascii;
	}
}
enum TextEncoding {
	ascii,
	//TODO ebcdic
	//TODO utf-8
	//TODO? thumb1
}



class RenderInformation {
	private Style[StringType] styleMap;
	
	this() {
		styleMap = null;
	}
	
	// FIXME properly implement
	Style getStyle(StringType styleKey) {
		return new Style(15, 4, 0);
	}
}

class Style {
	ubyte foregroundColor;
	ubyte backgroundColor;
	ubyte underline;
	// TODO underline colors (not supported by all terminals)
	
	this(ubyte fg, ubyte bg, ubyte u) {
		foregroundColor = fg;
		backgroundColor = bg;
		
		underline = u;
		if (underline >= 2) underline = 2;
	}
}



class InputInformation {
	CommandPaletteMode mode;
	
	this() {
		mode = CommandPaletteMode.topLevel;
	}
}
enum CommandPaletteMode {
	topLevel,
	//TODO editFiles,
	//FIXME findInteger,
	//FIXME findText,
	//FIXME gotoAddress,
}
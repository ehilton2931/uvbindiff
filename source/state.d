import atom;
import init_shutdown;
import typesetinformation;

class WholeProcessState {
	ExitInformation exit;
	ScreenInformation screen;
	FileInformationArray files;
	
	TypesetInformation typeset;
	RenderInformation render;
	InputInformation input;
	
	this(Arguments arguments, ExitInformation e, ScreenInformation s) {
		exit = e;
		screen = s;
		files = new FileInformationArray(arguments);
		
		typeset = new TypesetInformation(arguments.bytesPerRow);
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
	ulong firstRowOfPalette;
	
	this(ulong r, ulong c) {
		rows = r;
		columns = c;
		firstRowOfPalette = 15;
	}
	
	void calculateFirstRowOfPalette(WholeProcessState state) {
		// FIXME implement
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
	
	ulong addressOfIndex(ulong actingIndex) {
		import std.checkedint;
		
		Checked!(ulong, Saturate) working = actingIndex;
		working += addressOfIndexZero;
		return working.get;
	}
	ulong length() const {
		return fileHandle.length;
	}
}

class FileInformationArray {
	FileInformation[] fileData;
	private bool[] frozen;
	
	this(Arguments arguments) {
		import std.algorithm;//.comparison
		ulong count = min(arguments.filenameCount, arguments.filenames.length);
		
		fileData = new FileInformation[count];
		frozen = new bool[count];
		
		for (int i = 0; i < count; i++) {
			fileData[i] = new FileInformation(arguments.filenames[i], arguments.indexZeroAddresses[i]);
		}
	}
	
	void toggleFreeze(ulong i) {
		if (i >= frozen.length) return;
		frozen[i] = !frozen[i];
	}
	bool isFrozen(ulong i) {
		if (i >= frozen.length) return false;
		return frozen[i];
	}
	
	
	
	private void tryMoveFileRelative(ulong file, ulong forwards, ulong backwards) {
		if (file > fileData.length) return;
		if (frozen[file]) return;
		
		import std.checkedint;
		Checked!(ulong, Saturate) working = fileData[file].currentTopRowIndex;
		
		working -= backwards;
		working += forwards;
		// TODO -bytesDisplayedPerFile?
		if (working >= fileData[file].length) working = fileData[file].length - 1;
		
		fileData[file].currentTopRowIndex = working.get;
	}
}



// TypesetInformation in its own file

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
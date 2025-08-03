import atom;
import fileinformation;
import init_shutdown;
import typesetinformation;

class WholeProcessState {
	ExitInformation exit;
	ScreenInformation screen;
	FileInformationArray files;
	
	TypesetInformation typeset;
	RenderInformation render;
	InputInformation input;
	
	this(Arguments arguments, ExitInformation e) {
		exit = e;
		screen = new ScreenInformation(0, 0, 0);
		files = new FileInformationArray(arguments, exit);
		
		typeset = new TypesetInformation(arguments.bytesPerRow);
		render = new RenderInformation();
		input = new InputInformation();
		
		if (!e.shouldQuit) updateScreenInformation();
	}
	
	void updateScreenInformation() {
		ulong rows = getRows();
		ulong columns = getColumns();
		ulong bytesPerRow = typeset.bytesPerRow_root;
		if (rows == screen.rows && columns == screen.columns && bytesPerRow == screen.bytesPerRow) {
			return;
		}
		screen = new ScreenInformation(rows, columns, bytesPerRow);
		
		// File placement
		{
			// FIXME catch window not wide enough / potential arithmetic errors
			screen.columnsPerFileRow = typeset.columnsPerFileRow(bytesPerRow);
			
			ulong potentialFilesSideBySide = (columns+1) / (screen.columnsPerFileRow+1);
			import std.algorithm;
			screen.filesSideBySide = min(files.length, potentialFilesSideBySide);
			screen.filesSideBySide = 1; // TODO implement side-by-side files
			
			screen.filesOverUnder = (files.length + (screen.filesSideBySide-1)) / screen.filesSideBySide;
		}
		
		// Row and page calculation
		{
			// FIXME catch window not tall enough / potential underflows
			screen.firstRowOfPalette = rows - 5; // FIXME or TODO implement proper palette calculation
			screen.rowsPerFileWithHeader = screen.firstRowOfPalette / screen.filesOverUnder;
		}
	}
	
	import impl_ncurses;
	private ulong getRows() {
		return getRows__ncurses();
	}
	private ulong getColumns() {
		return getColumns__ncurses();
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
	// Raw information, set by constructor
	ulong rows;
	ulong columns;
	ulong bytesPerRow;
	
	// Derived information, set by caller of constructor
	// File placement
	ulong columnsPerFileRow;
	ulong filesSideBySide;
	ulong filesOverUnder;
	
	// Rows and pages
	ulong firstRowOfPalette;
	ulong rowsPerFileWithHeader;
	ulong rowsPerFilePage() {
		return rowsPerFileWithHeader - 1;
	}
	ulong bytesPerFilePage() {
		return rowsPerFilePage * bytesPerRow; // TODO potential overflow
	}
	
	this(ulong r, ulong c, ulong b) {
		rows = r;
		columns = c;
		bytesPerRow = b;
	}
}



// TypesetInformation in its own file

class RenderInformation {
	private Style[StringType] styleMap;
	
	this() {
		styleMap = new Style[StringType];
		
		styleMap[StringType.none] = new Style(0, 0, 0);
		styleMap[StringType.ui] = new Style(15, 4, 0);
		styleMap[StringType.fileHeader] = new Style(0, 15, 0);
		
		styleMap[StringType.addressPrimary] = new Style(15, 4, 0);
		styleMap[StringType.addressSecondary] = new Style(7, 4, 0);
		styleMap[StringType.integerPrimary] = new Style(15, 4, 0);
		styleMap[StringType.integerSecondary] = new Style(7, 4, 0);
		styleMap[StringType.textPrimary] = new Style(15, 4, 0);
		styleMap[StringType.textSecondary] = new Style(7, 4, 0);
		
		styleMap[StringType.diff1Primary] = new Style(9, 4, 0);
		styleMap[StringType.diff1Secondary] = new Style(1, 4, 0);
		styleMap[StringType.diff2Primary] = new Style(10, 4, 0);
		styleMap[StringType.diff2Secondary] = new Style(2, 4, 0);
	}
	
	Style getStyle(StringType styleKey) {
		return styleMap[styleKey];
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
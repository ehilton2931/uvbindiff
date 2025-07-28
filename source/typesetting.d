import render;
import state_1;

class TypesettingAtom {
	TerminalStyle style;
	int row;
	int col;
	dstring content;
	
	this(int r, int c, dstring s) {
		style = new TerminalStyle(7, 4, 0, 0); // FIXME
		row = r;
		col = c;
		content = s;
	}
}
class TerminalStyle {
	ubyte fgColor;
	ubyte bgColor;
	ubyte underlineCount;
	ubyte underlineColor;
	
	this(int a, int b, int c, int d) {
		fgColor = cast(ubyte) a;
		bgColor = cast(ubyte) b;
		underlineCount = cast(ubyte) c;
		underlineColor = cast(ubyte) d;
	}
}



TypesettingAtom[] typesetScreen(WholeProcessState state) {
	int totalRows = getRows();
	int fileCount = 0; // FIXME
	if (totalRows < 2*fileCount + 4) { // Every file needs at least 2 rows, and the palette needs 4
		state.quit = true;
		//TODO msg
		return null;
	}
	
	// Command palette always occupies the last 4 rows
	TypesettingAtom[] retVal = typesetCommandPalette(state, totalRows - 4);
	
	/*int rowsRemaining = totalRows - 4;
	int rowsPerFile = rowsRemaining / fileCount;
	int filesWithAdditionalRow = rowsRemaining % fileCount;
	
	int startRow = 0;
	for (int i = 0; i < fileCount; i++) {
		int rowCount = rowsPerFile;
		if (i < filesWithAdditionalRow) rowCount++;
		
		FIXME retVal ~= typesetFile(state, startRow, rowCount);
		startRow += rowCount;
	}*/
	
	return retVal;
}
TypesettingAtom[] typesetCommandPalette(WholeProcessState state, int startRow) {
	TypesettingAtom[] retVal = new TypesettingAtom[4];
	const int columnCount = getColumns();
	dchar[] activeRow = new dchar[columnCount];
	
	// First row
	activeRow[0] = '┌';
	activeRow[columnCount-1] = '┐';
	for (int i = 1; i < columnCount-1; i++) activeRow[i] = '─';
	retVal[0] = new TypesettingAtom(startRow, 0, activeRow.idup);
	// Fourth row
	activeRow[0] = '└';
	activeRow[columnCount-1] = '┘';
	retVal[3] = new TypesettingAtom(startRow+3, 0, activeRow.idup);
	
	retVal[1] = new TypesettingAtom(0, 0, ""d);
	retVal[2] = new TypesettingAtom(2, 0, ""d);
	
	return retVal;
}

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
	if (totalRows < 2*fileCount + 5) { // Every file needs at least 2 rows, and the palette needs 5
		state.quit = true;
		//TODO msg
		return null;
	}
	
	// Command palette always occupies the last 5 rows
	TypesettingAtom[] retVal = typesetCommandPalette(state, totalRows - 5);
	
	/*int rowsRemaining = totalRows - 5;
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
	TypesettingAtom[] retVal = new TypesettingAtom[5];
	const int columnCount = getColumns();
	dchar[] activeRow = new dchar[columnCount];
	
	retVal[0] = typesetHeaderRow(state, startRow);
	retVal[4] = typesetFooterRow(state, startRow + 4);
	
	final switch (state.commandPaletteMode) {
		case CommandPaletteMode.topLevel:
			retVal[1] = typesetEmptyRow(startRow + 1);
			retVal[2] = typesetEmptyRow(startRow + 2);
			retVal[3] = typesetEmptyRow(startRow + 3);
			break;
	}
	
	return retVal;
}

TypesettingAtom typesetHeaderRow(WholeProcessState state, int startRow) {
	int columnCount = state.terminal.targetColumns;
	dchar[] rowChars = new dchar[columnCount];
	
	rowChars[0] = '┌';
	for (int i = 1; i < columnCount-1; i++) rowChars[i] = '─';
	rowChars[columnCount-1] = '┐';
	
	return new TypesettingAtom(startRow, 0, rowChars.idup);
}
TypesettingAtom typesetFooterRow(WholeProcessState state, int startRow) {
	int columnCount = state.terminal.targetColumns;
	dchar[] rowChars = new dchar[columnCount];
	
	rowChars[0] = '└';
	for (int i = 1; i < columnCount-1; i++) rowChars[i] = '─';
	rowChars[columnCount-1] = '┘';
	
	return new TypesettingAtom(startRow, 0, rowChars.idup);
}
TypesettingAtom typesetEmptyRow(int startRow) { // FIXME remove
	return new TypesettingAtom(startRow, 0, ""d);
}

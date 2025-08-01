import atom;
import state;

Atom[] typeset(WholeProcessState state) {
	state.screen.calculateFirstRowOfPalette(state);
	
	Atom[] atoms = typesetFiles(state);
	//FIXME atoms ~= typesetCommandPalette();
	
	return atoms;
}



Atom[] typesetFiles(WholeProcessState state) {
	Atom[] atoms = null;
	
	// TODO add side-by-side support
	ulong rowsDisplayedPerFile = state.screen.firstRowOfPalette / state.files.fileData.length;
	if (rowsDisplayedPerFile < 2) { // 1 for header, 1 for bytes
		state.exit.error("Not enough rows!");
		return null;
	}
	
	/*FIXME uncomment after render is implemented
	ulong bytesDisplayedPerFile = (rowsDisplayedPerFile - 1) * state.typeset.bytesPerRow;
	DiffType[] diff = calculateDifferences(state.files, bytesDisplayedPerFile);
	
	for (int fileIndex = 0; fileIndex < state.files.length; fileIndex++) {
		atoms ~= typesetFileHeader(state, fileIndex);
		
		for (int rowIndex = 1; rowIndex < rowsDisplayedPerFile; rowIndex++) {
			ulong diffStart = (rowIndex - 1) * state.typeset.bytesPerRow;
			ulong diffEnd = diffStart + state.typeset.bytesPerRow;
			
			// FIXME edge cases: last row of data, rows past end of data
			if (diffStart > state.files[fileIndex].length) {
				diffStart = state.files[fileIndex].length;
			}
			if (diffEnd > state.files[fileIndex].length) {
				diffEnd = state.files[fileIndex].length;
			}
			atoms ~= typesetFileRow(state, fileIndex, diff[diffStart..diffEnd]);
		}
	}*/
	
	for (
		int rowIndex = 0; /*FIXME state.files.length * rowsDisplayedPerFile;*/
		rowIndex < state.screen.firstRowOfPalette;
		rowIndex++
	) {
		atoms ~= new Atom(rowIndex);
		atoms ~= typesetEmptyRow(state);
	}
	
	return atoms;
}

Atom[] typesetEmptyRow(WholeProcessState state) {
	import std.format;
	Atom[] retVal = null;
	
	retVal ~= new Atom(StringType.ui);
	string s = format("%%%ss", state.typeset.columnsPerRow);
	s = format(s, "");
	retVal ~= new Atom(s);
	
	return retVal;
}

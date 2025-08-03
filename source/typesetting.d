import atom;
import fileinformation;
import state;
import typesetinformation;

Atom[] typeset(WholeProcessState state) {
	Atom[] retVal = null;
	
	retVal ~= typesetFiles(state);
	retVal ~= typesetCommandPalette(state);
	
	return retVal;
}

Atom[] typesetCommandPalette(WholeProcessState state) {
	return null; // FIXME stub
}



Atom[] typesetFiles(WholeProcessState state) {
	Atom[] retVal = null;
	FileDifference[] diff = state.files.calculateDifferences(state.screen.bytesPerFilePage);
	
	// TODO implement side-by-side files, requires interleaving or changing Atoms
	ulong row = 0;
	for (ulong fileNumber = 0; fileNumber < state.files.length; fileNumber++) {
		retVal ~= new Atom(row++);
		retVal ~= typesetFileHeader(state, fileNumber);
		
		for (ulong fileDataRow = 0; fileDataRow < state.screen.rowsPerFilePage; fileDataRow++) {
			retVal ~= new Atom(row++);
			retVal ~= typesetFileDataRow(state, fileNumber, fileDataRow);
		}
	}
	
	return retVal;
}

Atom typesetFileHeader(WholeProcessState state, ulong fileNumber) {
	import std.format;
	string formatString = format("%s: %%-%ss", fileNumber+1, state.screen.columnsPerFileRow);
	string printedFilename = format(formatString, state.files.file[fileNumber].filename);
	return new Atom(StringType.fileHeader, printedFilename);
}

Atom[] typesetFileDataRow(WholeProcessState state, ulong fileNumber, ulong fileDataRow) {
	// FIXME figure out arguments
	return null;
}



Atom[] typesetAddress(AddressInformation addrInfo, ulong address) {
	Atom[] retVal = null;
	
	// FIXME overflow bypass
	
	StringType previousStringType = StringType.none;
	for (ulong i = 0; i < 10; i++) { // NOTE assumes address is 10 characters long
		// StringType
		StringType currentStringType = getStringTypeAddress(addrInfo.mode, i);
		if (currentStringType != previousStringType) retVal ~= new Atom(currentStringType);
		previousStringType = currentStringType;
		
		// character
		retVal ~= new Atom(getCharacterAddress(addrInfo, address, i));
	}
	
	return retVal;
}

StringType getStringTypeAddress(AddressMode mode, ulong position) {
	StringType[] array;
	StringType t1 = StringType.addressPrimary;
	StringType t2 = StringType.addressSecondary;
	
	final switch (mode) {
		case AddressMode.hexadecimal:
			array = [t1,t1,  t2,t2,t2,t2,  t1,t1,t1,t1];
			break;
		case AddressMode.decimal:
			array = [t2,  t1,t1,t1,  t2,t2,t2,  t1,t1,t1];
			break;
	}
	
	return array[position];
}

char getCharacterAddress(AddressInformation addrInfo, ulong address, ulong position) {
	string hexDigits;
	final switch (addrInfo.letterCase) {
		case LetterCase.uppercase:
			hexDigits = "0123456789ABCDEF";
			break;
		case LetterCase.lowercase:
			hexDigits = "0123456789abcdef";
			break;
	}
	
	ulong modulus;
	final switch (addrInfo.mode) {
		case AddressMode.hexadecimal:
			modulus = 16;
			break;
		case AddressMode.decimal:
			modulus = 10;
			break;
	}
	ulong divisor = modulus ^^ (10-1 - position); // TODO assumes address is 10 characters long and contiguous
	
	ulong value = address / divisor;
	value %= modulus;
	return hexDigits[value];
}







Atom[] typesetText(WholeProcessState state, ulong fileNumber, ubyte[] data, FileDifference[] diff) {
	Atom[] retVal = null;
	if (data.length != diff.length) {
		state.exit.error("Internal error: data.length != diff.length !");
		return null;
	}
	// TODO assumes ASCII (or 1 byte per character encodings)
	
	StringType previousStringType = StringType.none;
	StringType[] allowedTypes = [
		StringType.textPrimary,
		StringType.textSecondary,
		StringType.diff1Primary,
		StringType.diff1Secondary,
		StringType.diff2Primary,
		StringType.diff2Secondary
	];
	
	for (ulong i = 0; i < data.length; i++) {
		ulong typeIndex = 0;
		if (diff[i] != FileDifference.allSame) {
			typeIndex = 2;
			if (diff[i] == FileDifference.same12 && fileNumber == 0) typeIndex = 4;
			if (diff[i] == FileDifference.same02 && fileNumber == 1) typeIndex = 4;
			if (diff[i] == FileDifference.same01 && fileNumber == 2) typeIndex = 4;
		}
		if (i % 8 >= 4) typeIndex++;
		
		StringType currentStringType = allowedTypes[typeIndex];
		if (currentStringType != previousStringType) retVal ~= new Atom(currentStringType);
		previousStringType = currentStringType;
		
		char x;
		final switch (state.typeset.text.encoding) {
			case TextEncoding.ascii: {
				if (data[i] < 0x20)       x = '.'; // Control characters
				else if (data[i] >= 0x7F) x = '.'; // Delete and non-ASCII
				else                      x = cast(char) data[i];
			}
		}
		retVal ~= new Atom(x);
	}
	
	// Last row + empty rows
	if (data.length < state.screen.bytesPerRow) {
		import std.format;
		string formatString = format("%%%ss", state.screen.bytesPerRow - data.length);
		string atomString = format(formatString, "");
		retVal ~= new Atom(StringType.textPrimary, atomString);
	}
	
	return retVal;
}

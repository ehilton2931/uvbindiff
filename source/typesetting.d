import atom;
import fileinformation;
import optbyte;
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
			
			// TODO potential overflow
			ulong sliceStart = fileDataRow * state.screen.bytesPerRow;
			ulong sliceEndExclusive = sliceStart + state.screen.bytesPerRow;
			
			ulong address = state.files.file[fileNumber].getOffsetAddress(sliceStart);
			OptByte[] dataRowSlice = state.files.file[fileNumber].getSlice(sliceStart, state.screen.bytesPerRow);
			FileDifference[] diffRowSlice = diff[sliceStart..sliceEndExclusive];
			
			retVal ~= typesetFileDataRow(state, address, dataRowSlice, diffRowSlice, fileNumber);
		}
	}
	
	return retVal;
}

Atom typesetFileHeader(WholeProcessState state, ulong fileNumber) {
	import std.format;
	string formatString = format("%s: %%-%ss", fileNumber+1, state.screen.columnsPerFileRow-3);
	string printedFilename = format(formatString, state.files.file[fileNumber].filename);
	return new Atom(StringType.fileHeader, printedFilename);
}

Atom[] typesetFileDataRow(WholeProcessState state, ulong address, OptByte[] data, FileDifference[] diff, ulong fileNumber) {
	Atom[] retVal = null;
	
	retVal ~= typesetAddress(state.typeset.address, address);
	retVal ~= new Atom(StringType.ui, " ");
	retVal ~= typesetInteger(state, address, data, diff, fileNumber);
	retVal ~= new Atom(StringType.ui, " ");
	retVal ~= typesetText(state, data, diff, fileNumber);
	
	return retVal;
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



Atom[] typesetInteger(WholeProcessState state, ulong address, OptByte[] data, FileDifference[] diff, ulong fileNumber) {
	Atom[] retVal = null;
	if (data.length != diff.length) {
		state.exit.error("Internal error: data.length != diff.length !");
		return null;
	}
	
	import std.checkedint;
	long allowedSpaces = state.typeset.getIntegerInternalSpacing(state.screen.bytesPerRow);
	long sectionNumber = 0;
	ulong sliceStart = 0;
	Checked!(ulong, Saturate) sliceEnd = 0u;
	
	ulong addressMod4 = address % 4;
	final switch (state.typeset.integer.alignedness) {
		case IntAlignedness.aligned:
			if (addressMod4 == 0) goto case;
			sectionNumber = -1;
			sliceEnd = 4u - addressMod4;
			break;
		case IntAlignedness.unaligned:
			sectionNumber = 0;
			sliceEnd = 4u;
			break;
	}
	
	while (sliceStart < data.length) {
		if (sliceEnd > data.length) sliceEnd = data.length;
		
		retVal ~= typesetIntegerSection(
			state.typeset.integer,
			sectionNumber,
			data[sliceStart..sliceEnd.get],
			diff[sliceStart..sliceEnd.get],
			fileNumber
		);
		
		if (allowedSpaces > 0) retVal ~= new Atom(StringType.ui, " ");
		allowedSpaces--;
		
		sliceStart = sliceEnd.get;
		sliceEnd += 4;
		sectionNumber++;
	}
	
	return retVal;
}

Atom[] typesetIntegerSection(IntegerInformation intInfo, long sectionNumber, OptByte[] data, FileDifference[] diff, ulong fileNumber) {
	Atom[] retVal = null;
	StringType sectionStyle = StringType.integerPrimary;
	if (sectionNumber % 2 != 0) sectionStyle = StringType.integerSecondary;
	bool jumpBack16 = false;
	
	// Figure out width
	ulong nonNoneLength = data.length;
	while (nonNoneLength > 1) {
		if (data[nonNoneLength-1].isNone) {
			nonNoneLength--;
		} else {
			break;
		}
	}
	final switch (intInfo.width) {
		case IntWidth.w8:
			goto label8;
		case IntWidth.w16:
			// TODO improve handling for 3-wide
			if (nonNoneLength % 2 != 0) goto label8;
			goto label16;
		case IntWidth.w32:
			if (nonNoneLength < 4) goto label8;
			goto label32;
	}
	assert(0);
	
	// 
	label32:{
		// Get integer value
		uint integer;
		final switch (intInfo.endianness) {
			case IntEndianness.littleEndian:
				integer = data[0].get | (data[1].get << 8) | (data[2].get << 16) | (data[3].get << 24);
				break;
			case IntEndianness.bigEndian:
				integer = data[3].get | (data[2].get << 8) | (data[1].get << 16) | (data[0].get << 24);
				break;
		}
		
		// Get StringTypes
		StringType primary = getDiffStringType(StringType.integerPrimary, diff, fileNumber);
		StringType secondary = getDiffStringType(StringType.integerSecondary, diff, fileNumber);
		
		retVal ~= typesetInteger32(intInfo, integer, primary, secondary);
		goto exit;
	}
	
	label16:{
		for (ulong i = 0; (i+1) < data.length && !data[i+1].isNone; i += 2) {
			// Get integer value
			ushort integer;
			final switch (intInfo.endianness) {
				case IntEndianness.littleEndian:
					integer = data[i+0].get | (data[i+1].get << 8);
					break;
				case IntEndianness.bigEndian:
					integer = data[i+1].get | (data[i+0].get << 8);
					break;
			}
			
			// Get StringTypes
			StringType currentStyle;
			if (intInfo.radix == IntRadix.decimal && intInfo.signedness == IntSignedness.signed) {
				currentStyle = StringType.integerPrimary;
				if (i % 4 != 0) currentStyle = StringType.integerSecondary;
				currentStyle = getDiffStringType(currentStyle, diff[i..i+2], fileNumber);
			} else {
				currentStyle = getDiffStringType(sectionStyle, diff[i..i+2], fileNumber);
			}
			
			retVal ~= new Atom(currentStyle);
			retVal ~= typesetInteger16(intInfo, integer);
		}
		
		goto exit;
	}
	
	label8:{
		for (ulong i = 0; i < data.length; i++) {
			StringType currentStyle;
			if (intInfo.radix == IntRadix.hexadecimal && intInfo.signedness == IntSignedness.unsigned) {
				currentStyle = getDiffStringType(sectionStyle, diff[i], fileNumber);
			} else {
				currentStyle = StringType.integerPrimary;
				if (i % 2 != 0) currentStyle = StringType.integerSecondary;
				currentStyle = getDiffStringType(currentStyle, diff[i], fileNumber);
			}
			
			retVal ~= new Atom(currentStyle);
			retVal ~= typesetInteger8(intInfo, data[i]);
		}
		
		goto exit;
	}
	
	exit:
	return retVal;
}

Atom[] typesetInteger32(IntegerInformation intInfo, uint integer, StringType primary, StringType secondary) {
	import std.format;
	import std.math;
	Atom[] retVal = null;
	
	// Signedness handling
	bool negative = false;
	final switch (intInfo.signedness) {
		case IntSignedness.unsigned:
			break;
		case IntSignedness.signed:
			if (integer <= cast(uint) int.max) break;
			
			negative = true;
			integer = cast(uint) abs(cast(int) integer);
			break;
	}
	
	// Radix and letter case
	final switch (intInfo.radix) {
		case IntRadix.hexadecimal: {
			string spacing = "   "; // 3 spaces
			string highString = format(gFSKW(true, negative, 4, intInfo), integer / 0x1_0000);
			string lowString = format(gFSKW(false, false, 4, intInfo), integer % 0x1_0000);
			
			retVal ~= new Atom(secondary, spacing ~ highString);
			retVal ~= new Atom(primary, lowString);
			break;
		}
		case IntRadix.decimal: {
			string spacing = " ";
			string billions = format(gFSKW(true, negative, 1, intInfo), integer / 1_000_000_000);
			string millions = format(gFSKW(false, false, 3, intInfo), (integer / 1_000_000) % 1_000);
			string thousands = format(gFSKW(false, false, 3, intInfo), (integer / 1_000) % 1_000);
			string units = format(gFSKW(false, false, 3, intInfo), integer % 1_000);
			
			retVal ~= new Atom(secondary, spacing ~ billions);
			retVal ~= new Atom(primary, millions);
			retVal ~= new Atom(secondary, thousands);
			retVal ~= new Atom(primary, units);
			break;
		}
	}
	
	return retVal;
}

Atom typesetInteger16(IntegerInformation intInfo, ushort integer) {
	import std.format;
	import std.math;
	
	// Signedness handling
	bool negative = false;
	final switch (intInfo.signedness) {
		case IntSignedness.unsigned:
			break;
		case IntSignedness.signed:
			if (integer <= cast(ushort) short.max) break;
			
			negative = true;
			integer = cast(ushort) abs(cast(short) integer);
			break;
	}
	
	// Radix and letter case
	final switch (intInfo.radix) {
		case IntRadix.hexadecimal: {
			return new Atom(" " ~ format(gFSKW(true, negative, 4, intInfo), integer));
		}
		case IntRadix.decimal: {
			return new Atom(format(gFSKW(true, negative, 5, intInfo), integer));
		}
	}
}

Atom typesetInteger8(IntegerInformation intInfo, OptByte optInteger) {
	import std.format;
	import std.math;
	if (optInteger.isNone) return new Atom("   "); // 3 spaces
	ubyte integer = optInteger.get;
	
	// Signedness handling
	bool negative = false;
	string tString = "";
	final switch (intInfo.signedness) {
		case IntSignedness.unsigned:
			break;
		case IntSignedness.signed:
			if (integer <= cast(ubyte) byte.max) break;
			
			negative = true;
			integer = cast(ubyte) abs(cast(byte) integer);
			break;
	}
	
	// Radix and letter case
	final switch (intInfo.radix) {
		case IntRadix.hexadecimal:
			return new Atom(format(gFSKW(true, negative, 2, intInfo), integer));
		case IntRadix.decimal:
			if (!negative) return new Atom(format(gFSKW(false, false, 3, intInfo), integer));
			break;
	}
	
	// Negative decimal hundreds handling
	bool hundred = false;
	if (integer >= 100) {
		integer -= 100;
		hundred = true;
	}
	tString = "-";
	if (hundred) tString = "T";
	return new Atom(tString ~ format(gFSKW(false, false, 2, intInfo), integer));
}

// getFormatStringKnownWidth
string gFSKW(bool spaceIfNotNegative, bool negative, ulong length, IntegerInformation intInfo) {
	import std.format;
	string formatString = "%s%%0%s%s";
	
	string negativeString = "";
	if (spaceIfNotNegative) negativeString = " ";
	if (negative) negativeString = "-";
	
	string radixString = "";
	final switch (intInfo.radix) {
		case IntRadix.hexadecimal:
			final switch (intInfo.letterCase) {
				case LetterCase.uppercase:
					radixString = "X";
					break;
				case LetterCase.lowercase:
					radixString = "x";
					break;
			}
			break;
		case IntRadix.decimal:
			radixString = "u";
	}
	
	string retVal = format(formatString, negativeString, length, radixString);
	return retVal;
}



Atom[] typesetText(WholeProcessState state, OptByte[] data, FileDifference[] diff, ulong fileNumber) {
	Atom[] retVal = null;
	if (data.length != diff.length) {
		state.exit.error("Internal error: data.length != diff.length !");
		return null;
	}
	// TODO assumes ASCII (or 1 byte per character encodings)
	
	StringType previousStringType = StringType.none;
	for (ulong i = 0; i < data.length; i++) {
		StringType currentStringType = getStringTypeText(diff[i], fileNumber, i);
		if (currentStringType != previousStringType) retVal ~= new Atom(currentStringType);
		previousStringType = currentStringType;
		
		char x;
		final switch (state.typeset.text.encoding) {
			case TextEncoding.ascii: {
				if (data[i].isNone)           x = ' '; // Past end of file
				else if (data[i].get < 0x20)  x = '.'; // Control characters
				else if (data[i].get >= 0x7F) x = '.'; // Delete and non-ASCII
				else                          x = cast(char) data[i].get;
			}
		}
		retVal ~= new Atom(x);
	}
	
	return retVal;
}

// FIXME replace with getDiffStringType
StringType getStringTypeText(FileDifference diff, ulong fileNumber, ulong position) {
	StringType[] allowedTypes = [
		StringType.textPrimary,
		StringType.textSecondary,
		StringType.diff1Primary,
		StringType.diff1Secondary,
		StringType.diff2Primary,
		StringType.diff2Secondary
	];
	
	ulong typeIndex = 0;
	final switch (diff) {
		case FileDifference.allSame:
			typeIndex = 0;
			break;
		case FileDifference.allDifferent:
			typeIndex = 2;
			break;
		
		case FileDifference.same12:
			typeIndex = 4;
			if (fileNumber == 0) typeIndex = 2;
			break;
		case FileDifference.same02:
			typeIndex = 4;
			if (fileNumber == 1) typeIndex = 2;
			break;
		case FileDifference.same01:
			typeIndex = 4;
			if (fileNumber == 2) typeIndex = 2;
			break;
	}
	
	// TODO follow integer alignment
	if (position % 8 >= 4) typeIndex++;
	return allowedTypes[typeIndex];
}



StringType getDiffStringType(StringType normal, FileDifference diff, ulong fileNumber) {
	return getDiffStringType(normal, [diff], fileNumber);
}

StringType getDiffStringType(StringType normal, FileDifference[] diff, ulong fileNumber) {
	StringType[] diffTypes = [
		StringType.diff1Primary,
		StringType.diff1Secondary,
		StringType.diff2Primary,
		StringType.diff2Secondary
	];
	StringType[] secondaryTypes = [
		StringType.integerSecondary,
		StringType.textSecondary
	];
	
	bool same12 = true;
	bool same02 = true;
	bool same01 = true;
	for (ulong i = 0; i < diff.length; i++) final switch (diff[i]) {
		case FileDifference.allSame:
			break;
		case FileDifference.allDifferent:
			same12 = false;
			same02 = false;
			same01 = false;
			break;
		
		case FileDifference.same12:
			same02 = false;
			same01 = false;
			break;
		case FileDifference.same02:
			same12 = false;
			same01 = false;
			break;
		case FileDifference.same01:
			same12 = false;
			same02 = false;
			break;
	}
	if (same12 && same02 && same01) return normal;
	
	ulong typeIndex = 0;
	switch (fileNumber) {
		case 0:
			if (same02 || same01) typeIndex = 2;
			break;
		case 1:
			if (same12 || same01) typeIndex = 2;
			break;
		case 2:
			if (same12 || same02) typeIndex = 2;
			break;
		
		default:
			assert(0);
	}
	
	for (ulong i = 0; i < secondaryTypes.length; i++) if (normal == secondaryTypes[i]) {
		typeIndex++;
		break;
	}
	
	return diffTypes[typeIndex];
}

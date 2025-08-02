

class TypesetInformation {
	AddressInformation address;
	IntegerInformation integer;
	TextInformation text;
	
	ulong bytesPerRow_root;
	ulong columnsPerRow(ulong bytesPerRow) {
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
	
	this(ulong b) {
		address = new AddressInformation();
		integer = new IntegerInformation();
		text = new TextInformation();
		
		bytesPerRow = b;
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
	
	void nextAlignedness() {
		final switch (alignedness) {
			case IntAlignedness.unaligned:
				alignedness = IntAlignedness.aligned;
				break;
			case IntAlignedness.aligned:
				alignedness = IntAlignedness.unaligned;
				break;
		}
	}
	void nextEndianness() {
		final switch (endianness) {
			case IntEndianness.littleEndian:
				endianness = IntEndianness.bigEndian;
				break;
			case IntEndianness.bigEndian:
				endianness = IntEndianness.littleEndian;
				break;
		}
	}
	void nextSignedness() {
		final switch (signedness) {
			case IntSignedness.unsigned:
				signedness = IntSignedness.signed;
				break;
			case IntSignedness.signed:
				signedness = IntSignedness.unsigned;
				break;
		}
	}
	void nextWidth() {
		final switch (width) {
			case IntWidth.w8:
				width = IntWidth.w16;
				break;
			case IntWidth.w16:
				width = IntWidth.w32;
				break;
			case IntWidth.w32:
				width = IntWidth.w8;
				break;
		}
	}
	void nextRadix() {
		final switch (radix) {
			case IntRadix.hexadecimal:
				radix = IntRadix.decimal;
				break;
			case IntRadix.decimal:
				radix = IntRadix.hexadecimal;
				break;
		}
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


class FileArrayState {
	FileRenderState render;
	//private FileHandler[] array;
	
	this() {
		render = new FileRenderState();
		// FIXME array = 
	}
}



class FileRenderState {
	FRS_Width width;
	FRS_Alignedness alignedness;
	FRS_Signedness signedness;
	FRS_Endianness endianness;
	FRS_Radix radix;
	
	this() {
		width = FRS_Width.w8;
		alignedness = FRS_Alignedness.alignedAddress;
		signedness = FRS_Signedness.unsigned;
		endianness = FRS_Endianness.littleEndian;
		radix = FRS_Radix.hexadecimal;
	}
	
	void nextWidth() {
		final switch (width) {
			case FRS_Width.w8:
				width = FRS_Width.w16;
				break;
			case FRS_Width.w16:
				width = FRS_Width.w32;
				break;
			case FRS_Width.w32:
				width = FRS_Width.w8;
				break;
		}
	}
	void nextAlignedness() {
		final switch (alignedness) {
			case FRS_Alignedness.unaligned:
				alignedness = FRS_Alignedness.alignedData;
				break;
			case FRS_Alignedness.alignedData:
				alignedness = FRS_Alignedness.alignedAddress;
				break;
			case FRS_Alignedness.alignedAddress:
				alignedness = FRS_Alignedness.unaligned;
				break;
		}
	}
	void nextSignedness() {
		final switch (signedness) {
			case FRS_Signedness.unsigned:
				signedness = FRS_Signedness.signed;
				break;
			case FRS_Signedness.signed:
				signedness = FRS_Signedness.unsigned;
				break;
		}
	}
	void nextEndianness() {
		final switch (endianness) {
			case FRS_Endianness.littleEndian:
				endianness = FRS_Endianness.bigEndian;
				break;
			case FRS_Endianness.bigEndian:
				endianness = FRS_Endianness.littleEndian;
				break;
		}
	}
	void nextRadix() {
		final switch (radix) {
			case FRS_Radix.hexadecimal:
				radix = FRS_Radix.decimal;
				break;
			case FRS_Radix.decimal:
				radix = FRS_Radix.hexadecimal;
				break;
		}
	}
}
enum FRS_Width {
	w8,
	w16,
	w32
}
enum FRS_Alignedness {
	unaligned,
	alignedData,
	alignedAddress
}
enum FRS_Signedness {
	unsigned,
	signed
}
enum FRS_Endianness {
	littleEndian,
	bigEndian
}
enum FRS_Radix {
	hexadecimal,
	decimal,
	// TODO binary
}

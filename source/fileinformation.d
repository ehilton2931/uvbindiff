import init_shutdown;
import optbyte;
import state;

class FileInformationArray {
	FileInformation[] file;
	ulong length() {
		return file.length;
	}
	
	this(Arguments arguments, ExitInformation exit) {
		file = new FileInformation[arguments.filenameCount];
		for (ulong i = 0; i < file.length; i++) {
			file[i] = new FileInformation(arguments.filenames[i], arguments.indexZeroAddresses[i], exit);
		}
	}
	
	
	
	void gotoRelative(ulong forwards, ulong backwards) {
		for (ulong i = 0; i < file.length; i++) {
			file[i].attemptGotoRelative(forwards, backwards);
		}
	}
	
	void gotoAbsoluteIndex(ulong value) {
		for (ulong i = 0; i < file.length; i++) {
			file[i].attemptGotoAbsoluteIndex(value);
		}
	}
	
	void gotoNextDifference(ulong pageMovement) {
		if (file.length <= 1) {
			gotoRelative(pageMovement, 0);
			return;
		}
		// TODO what if already in a difference
		
		OptByte[] bytesToDiff = new OptByte[file.length];
		ulong offset = 1;
		
		while (true) {
			for (ulong i = 0; i < file.length; i++) {
				bytesToDiff[i] = file[i].attemptGetPositiveOffset(offset);
			}
			
			// If all are None, backtrack 1 and exit
			bool shouldBacktrack = true;
			for (ulong i = 0; i < file.length; i++) if (!bytesToDiff[i].isNone) {
				shouldBacktrack = false;
				break;
			}
			if (shouldBacktrack) {
				offset--;
				break;
			}
			
			// If any are different, exit
			bool shouldBreak = false;
			for (ulong i = 1; i < file.length; i++) if (bytesToDiff[i] != bytesToDiff[0]) {
				shouldBreak = true;
				break;
			}
			if (shouldBreak) break;
			
			offset++;
		}
		
		gotoRelative(offset, 0);
	}
	
	void gotoPreviousDifference(ulong pageMovement) {
		if (file.length <= 1) {
			gotoRelative(0, pageMovement);
			return;
		}
		// TODO what if already in a difference
		
		OptByte[] bytesToDiff = new OptByte[file.length];
		ulong offset = 1;
		
		while (true) {
			for (ulong i = 0; i < file.length; i++) {
				bytesToDiff[i] = file[i].attemptGetNegativeOffset(offset);
			}
			
			// If all are None, backtrack 1 and exit
			bool shouldBacktrack = true;
			for (ulong i = 0; i < file.length; i++) if (!bytesToDiff[i].isNone) {
				shouldBacktrack = false;
				break;
			}
			if (shouldBacktrack) {
				offset--;
				break;
			}
			
			// If any are different, exit
			bool shouldBreak = false;
			for (ulong i = 1; i < file.length; i++) if (bytesToDiff[i] != bytesToDiff[0]) {
				shouldBreak = true;
				break;
			}
			if (shouldBreak) break;
			
			offset++;
		}
		
		gotoRelative(0, offset);
	}
	
	FileDifference[] calculateDifferences(ulong numBytesToDiff) {
		FileDifference[] retVal = new FileDifference[numBytesToDiff];
		
		for (ulong i = 0; i < numBytesToDiff; i++) {
			// Default value, useful for single file
			retVal[i] = FileDifference.allSame;
			
			OptByte[] bytesToDiff = new OptByte[file.length];
			for (ulong j = 0; j < file.length; j++) {
				bytesToDiff[j] = file[j].attemptGetPositiveOffset(i);
			}
			
			switch (file.length) {
				case 1: break;
				case 2:
					if (bytesToDiff[0] != bytesToDiff[1]) retVal[i] = FileDifference.allDifferent;
					break;
				case 3:
					bool same01 = bytesToDiff[0] == bytesToDiff[1];
					bool same02 = bytesToDiff[0] == bytesToDiff[2];
					bool same12 = bytesToDiff[1] == bytesToDiff[2];
					
					if (same01 && same02 && same12) {
						// All same, use default
						break;
					} else if (!same01 && !same02 && !same12) {
						// All different
						retVal[i] = FileDifference.allDifferent;
						break;
					}
					
					// Two but not three are the same
					if (same01) retVal[i] = FileDifference.same01;
					if (same02) retVal[i] = FileDifference.same02;
					if (same12) retVal[i] = FileDifference.same12;
					break;
				
				default: assert(0);
			}
		}
		
		return retVal;
	}
}

class FileInformation {
	import std.checkedint;
	import std.mmfile;
	
	string filename;
	private MmFile fileHandle;
	private ubyte[] data() {
		return cast(ubyte[]) fileHandle[];
	}
	bool isReadOnly;
	
	Checked!(ulong, Saturate) index;
	ulong addressOfIndexZero;
	bool isIndexFrozen;
	
	this(string name, ulong iza, ExitInformation exit) {
		filename = name;
		
		try {
			fileHandle = new MmFile(name, MmFile.Mode.readWrite, 0, null);
			isReadOnly = false;
		} catch (Exception e) {
			isReadOnly = true;
			
			try {
				fileHandle = new MmFile(name, MmFile.Mode.read, 0, null);
				exit.warn("Opened " ~ name ~ " in read-only mode.");
			} catch (Exception e2) {
				exit.error("Could not open file " ~ name);
			}
		}
		
		index = 0u;
		addressOfIndexZero = iza;
		isIndexFrozen = false;
	}
	
	
	
	private void boundIndex() {
		if (index >= fileHandle.length) index = fileHandle.length - 1;
	}
	
	void attemptGotoRelative(ulong forwards, ulong backwards) {
		if (isIndexFrozen) return;
		
		index -= backwards;
		index += forwards;
		boundIndex();
	}
	
	void attemptGotoAbsoluteIndex(ulong value) {
		if (isIndexFrozen) return;
		
		index = value;
		boundIndex();
	}
	
	void toggleFreeze() {
		isIndexFrozen = !isIndexFrozen;
	}
	
	
	
	OptByte attemptGetPositiveOffset(ulong offset) {
		Checked!(ulong, Saturate) working = index;
		working += offset;
		
		if (working >= fileHandle.length) return OptByte(true);
		return OptByte(data[working.get]);
	}
	
	OptByte attemptGetNegativeOffset(ulong offset) {
		Checked!(ulong, Saturate) working = index;
		working -= offset;
		
		if (working == 0 && offset > index) return OptByte(true);
		return OptByte(data[working.get]);
	}
	
	OptByte[] getSlice(ulong offset, ulong length) {
		OptByte[] retVal = new OptByte[length];
		
		for (ulong i = 0; i < length; i++) {
			Checked!(ulong, Saturate) working = offset;
			working += i;
			
			retVal[i] = attemptGetPositiveOffset(working.get);
		}
		
		return retVal;
	}
	
	ulong getOffsetAddress(ulong offset) {
		Checked!(ulong, Saturate) working = index;
		working += addressOfIndexZero;
		working += offset;
		return working.get;
	}
}

enum FileDifference : ubyte {
	allSame,
	allDifferent,
	
	same12,
	same02,
	same01
}
import init_shutdown;
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
		
		ushort[] activeArr = new ushort[file.length];
		ulong offset = 1;
		
		while (true) {
			for (int i = 0; i < file.length; i++) {
				activeArr[i] = file[i].attemptGetPositiveOffset(offset);
			}
			
			// If all are None, backtrack 1 and exit
			bool shouldBacktrack = true;
			for (int i = 0; i < file.length; i++) if (activeArr[i] <= ubyte.max) {
				shouldBacktrack = false;
				break;
			}
			if (shouldBacktrack) {
				offset--;
				break;
			}
			
			bool shouldBreak = false;
			for (int i = 1; i < file.length; i++) if (activeArr[i] != activeArr[0]) {
				shouldBreak = true;
				break;
			}
			if (shouldBreak) break;
		}
		
		gotoRelative(offset, 0);
	}
	
	void gotoPreviousDifference(ulong pageMovement) {
		if (file.length <= 1) {
			gotoRelative(0, pageMovement);
			return;
		}
		// TODO what if already in a difference
		
		ushort[] activeArr = new ushort[file.length];
		ulong offset = 1;
		
		while (true) {
			for (ulong i = 0; i < file.length; i++) {
				activeArr[i] = file[i].attemptGetPositiveOffset(offset);
			}
			
			// If all are None, backtrack 1 and exit
			bool shouldBacktrack = true;
			for (ulong i = 0; i < file.length; i++) if (activeArr[i] <= ubyte.max) {
				shouldBacktrack = false;
				break;
			}
			if (shouldBacktrack) {
				offset--;
				break;
			}
			
			bool shouldBreak = false;
			for (ulong i = 1; i < file.length; i++) if (activeArr[i] != activeArr[0]) {
				shouldBreak = true;
				break;
			}
			if (shouldBreak) break;
		}
		
		gotoRelative(0, offset);
	}
	
	FileDifference[] calculateDifferences(ulong numBytesToDiff) {
		FileDifference[] retVal = new FileDifference[numBytesToDiff];
		
		for (ulong i = 0; i < numBytesToDiff; i++) {
			// Default value, useful for single file
			retVal[i] = FileDifference.allSame;
			
			ushort[] activeArr = new ushort[file.length];
			for (ulong j = 0; j < file.length; j++) {
				activeArr[j] = file[j].attemptGetPositiveOffset(i);
			}
			
			switch (file.length) {
				case 1: break;
				case 2:
					if (activeArr[0] != activeArr[1]) retVal[i] = FileDifference.allDifferent;
					break;
				case 3:
					bool same01 = activeArr[0] == activeArr[1];
					bool same02 = activeArr[0] == activeArr[2];
					bool same12 = activeArr[1] == activeArr[2];
					
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
	
	
	
	ushort attemptGetPositiveOffset(ulong offset) {
		Checked!(ulong, Saturate) working = index;
		working += offset;
		
		if (working >= fileHandle.length) return ushort.max;
		return data[working.get];
	}
	
	ushort attemptGetNegativeOffset(ulong offset) {
		Checked!(ulong, Saturate) working = index;
		working -= offset;
		
		if (working == 0 && offset > index) return ushort.max;
		return data[working.get];
	}
}

enum FileDifference : ubyte {
	allSame,
	allDifferent,
	
	same12,
	same02,
	same01
}
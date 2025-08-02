import init_shutdown;

class FileInformationArray {
	FileInformation[] file;
	
	this(Arguments arguments) {
		file = new FileInformation[arguments.filenameCount];
		for (int i = 0; i < file.length; i++) {
			file[i] = new FileInformation(arguments.filenames[i], arguments.indexZeroAddresses[i]);
		}
	}
	
	ulong length() {
		return file.length;
	}
}

class FileInformation {
	import std.checkedint;
	import std.mmfile;
	
	string filename;
	private MmFile fileHandle;
	
	Checked!(ulong, Saturate) index;
	ulong addressOfIndexZero;
	bool isIndexFrozen;
	
	this(string name, ulong iza) {
		filename = name;
		// FIXME various file exceptions + readWrite
		fileHandle = new MmFile(name, MmFile.Mode.read, 0, null);
		
		index = 0u;
		addressOfIndexZero = iza;
		isIndexFrozen = false;
	}
	
	
	
	void attemptGotoRelative(ulong forwards, ulong backwards) {
		if (isIndexFrozen) return;
		
		index -= backwards;
		index += forwards;
		if (index >= fileHandle.length) index = fileHandle.length;
	}
}
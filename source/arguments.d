
class Arguments {
	ulong bytesPerRow;
	ulong[] indexZeroAddresses;
	string[] filenames;
	int filenameCount;
	
	this() {
		bytesPerRow = 0;
		indexZeroAddresses = new ulong[9];
		filenames = new string[9];
		filenameCount = 0;
	}
}

// TODO Error handling, help message, etc.
Arguments parseArguments(string[] args) {
	import std.algorithm;
	Arguments arguments = new Arguments();
	
	bool forceFilename = false;
	for (int i = 0; i < args.length; i++) {
		if (forceFilename) {
			if (arguments.filenameCount >= arguments.filenames.length) continue;
			arguments.filenames[arguments.filenameCount] = args[i];
			arguments.filenameCount++;
		} else if (args[i] == "--width") {
			i++;
			arguments.bytesPerRow = parseDecimalOrHexadecimal(args[i]);
		} else if (args[i] == "--address") {
			i++;
			int value = cast(int) parseDecimalOrHexadecimal(args[i]); 
			for (int j = 0; j < arguments.indexZeroAddresses.length; j++) {
				arguments.indexZeroAddresses[j] = value;
			}
			
			
		} else if (args[i].startsWith("--address")) {
			int index = cast(int) parseDecimalOrHexadecimal(args[i][9..10]);
			i++;
			if (index == 0 || index >= arguments.indexZeroAddresses.length) continue;
			arguments.indexZeroAddresses[index-1] = parseDecimalOrHexadecimal(args[i]);
		} else if (args[i] == "--") {
			forceFilename = true;
		} else {
			if (arguments.filenameCount >= arguments.filenames.length) continue;
			arguments.filenames[arguments.filenameCount] = args[i];
			arguments.filenameCount++;
		}
	}
	
	return arguments;
}

ulong parseDecimalOrHexadecimal(string s) {
	import std.algorithm;
	import std.conv;
	ulong retVal = 0;
	
	try {
		if (s.startsWith("0x")) {
			retVal = to!ulong(s[2..$], 16);
		} else {
			retVal = to!ulong(s, 10);
		}
	} catch (Exception e) {
		retVal = 0;
	}
	
	
	return retVal;
}

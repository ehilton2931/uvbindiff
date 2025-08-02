import impl_ncurses;
import state;

enum MAX_FILES = 3;
class Arguments {
	ulong bytesPerRow;
	ulong[] indexZeroAddresses;
	string[] filenames;
	int filenameCount;
	
	this() {
		bytesPerRow = 16;
		indexZeroAddresses = new ulong[MAX_FILES];
		filenames = new string[MAX_FILES];
		filenameCount = 0;
	}
}



WholeProcessState init(string[] args) {
	ExitInformation exit = new ExitInformation();
	Arguments arguments = parseArguments(args, exit);
	// TODO User configuration
	
	if (!exit.shouldQuit) initRender(exit);
	if (!exit.shouldQuit) initKeyboard();
	
	WholeProcessState state = new WholeProcessState(arguments, exit);
	return state;
}

// TODO help message
private Arguments parseArguments(string[] args, ExitInformation exit) {
	import std.algorithm;
	import std.conv;
	Arguments arguments = new Arguments();
	
	// Parsing
	bool forceFilename = false;
	for (int i = 1; i < args.length; i++) {
		if (forceFilename) {
			// Same as final else
			if (arguments.filenameCount >= arguments.filenames.length) {
				exit.error("Too many files! The maximum number of files allowed is " ~ to!string(MAX_FILES));
				break;
			}
			arguments.filenames[arguments.filenameCount] = args[i];
			arguments.filenameCount++;
		} else if (args[i] == "--") {
			forceFilename = true;
		}
		
		
		else if (args[i] == "--address") {
			ulong value = parseIntSafe(args[i]);
			if (value == 0 && args[i] != "0") { // In theory could be a script-generated value (e.g., 0x00000000) instead of an illegal value
				exit.warn("Potentially illegal address parameter, parsing as 0: " ~ args[i]);
			}
			
			// Only change addresses not already handled
			for (ulong j = arguments.filenameCount; j < arguments.indexZeroAddresses.length; j++) {
				arguments.indexZeroAddresses[j] = value;
			}
		} else if (args[i].startsWith("--address")) {
			ulong index = parseIntSafe(args[i][9..$]);
			if (index == 0 || index > arguments.indexZeroAddresses.length) {
				exit.error("Illegal file index in parameter " ~ args[i]);
				break;
			}
			i++;
			
			// Same as == "--address" case
			ulong value = parseIntSafe(args[i]);
			if (value == 0 && args[i] != "0") { // In theory could be a script-generated value (e.g., 0x00000000) instead of an illegal value
				exit.warn("Potentially illegal address parameter, parsing as 0: " ~ args[i]);
			}
			
			// Remember the arguments are 1-indexed but the array is 0-indexed
			arguments.indexZeroAddresses[index-1] = value;
		}
		
		else if (args[i] == "--width") {
			i++;
			ulong value = parseIntSafe(args[i]);
			if (value == 0) { // Zero bytes per row must be invalid
				exit.error("The width must be a positive integer!");
				break;
			}
		} else {
			if (arguments.filenameCount >= arguments.filenames.length) {
				exit.error("Too many files! The maximum number of files allowed is " ~ to!string(MAX_FILES));
				break;
			}
			arguments.filenames[arguments.filenameCount] = args[i];
			arguments.filenameCount++;
		}
	}
	
	if (arguments.filenameCount == 0) {
		exit.error("You must specify at least one file!");
	}
	return arguments;
}

private ulong parseIntSafe(string s) {
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

private void initRender(ExitInformation exit) {
	initRender__ncurses(exit);
}

private void initKeyboard() {
	initKeyboard__ncurses();
}



void shutdown(WholeProcessState state) {
	import std.stdio;
	// FIXME implement any state destructors necessary
	
	shutdownKeyboard();
	shutdownRender();
	
	for (int i = 0; i < state.exit.warningMessages.length; i++) {
		writeln(state.exit.warningMessages[i]);
	}
	if (state.exit.errorMessage != "") {
		writeln(state.exit.errorMessage);
	}
}

private void shutdownKeyboard() {
	shutdownKeyboard__ncurses();
}

private void shutdownRender() {
	shutdownRender__ncurses();
}
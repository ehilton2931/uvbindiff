import state_2;

class WholeProcessState {
	bool quit;
	
	CommandPaletteMode commandPaletteMode;
	FileArrayState files;
	string[] gcScope;
	
	this() {
		quit = false;
		commandPaletteMode = CommandPaletteMode.topLevel;
		//files = new FileArrayState(); // FIXME implement
		gcScope = ["test"];
	}
}



enum CommandPaletteMode {
	topLevel,
	// editFile
	// findInteger
	// findText
	// gotoAddress
	
}

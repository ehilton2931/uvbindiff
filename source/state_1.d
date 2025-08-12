import arguments;
import state_2;

class WholeProcessState {
	bool quit;
	
	CommandPaletteMode commandPaletteMode;
	FileArrayState files;
	TerminalState terminal;
	
	string[] gcScope;
	
	this(Arguments args) {
		quit = false;
		
		commandPaletteMode = CommandPaletteMode.topLevel;
		//files = new FileArrayState(); // FIXME implement
		terminal = new TerminalState(cast(int) args.bytesPerRow);
		
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



class TerminalState {
	int targetColumns;
	
	this(int bytesPerRow) {
		int addressColumns = 10;
		int integerColumns = 3 * bytesPerRow; // 3 for decimal support
		int integerInternalSpacing = (bytesPerRow + 2) / 4; // 5 -> 1 (1.4), 6 -> 2 (1.4.1)
		int textColumns = bytesPerRow;
		
		targetColumns = addressColumns + 1 + integerColumns + integerInternalSpacing + 1 + textColumns;
		// 80 @ 16 bytes per row
		// Ideally it would be 79, but alignment forces an extra character for spacing
	}
}

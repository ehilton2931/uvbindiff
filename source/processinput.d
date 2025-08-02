import keyinput;
import state;

void processKeyInput(WholeProcessState state, KeyInput input) {
	// Changes to window size will cause a(n empty) KeyInput, so this needs to be run regardless
	state.updateScreenInformation();
	
	final switch (state.input.mode) {
		case CommandPaletteMode.topLevel:
			process__topLevel(state, input);
			return;
	}
}

private void process__topLevel(WholeProcessState state, KeyInput input) {
	// Handle potential changes to ScreenInformation first (and quit, because it's special)
	switch (input.unicode) {
		case 'q', 'Q': state.exit.normal(); return;
		// FIXME handle overflow / decrement to 0
		case '=', '+': state.typeset.bytesPerRow_root++; goto case '\U0010FFFE';
		case '-', '_': state.typeset.bytesPerRow_root--; goto case '\U0010FFFE';
		
		case '\U0010FFFE': state.updateScreenInformation(); break;
		default: break;
	}
	
	// Handle everything else
	if (input.unicode != '\U0010FFFF') switch (input.unicode) {
		// File movement
		case '1': .. case '3': break; // FIXME toggle freeze
		case ' ': break; // FIXME goto next file difference
		
		// TODO? Address typesetting settings
		// Integer typesetting settings
		case 'w', 'W': state.typeset.integer.nextWidth(); return;
		case 'a', 'A': state.typeset.integer.nextAlignedness(); return;
		case 's', 'S': state.typeset.integer.nextSignedness(); return;
		case 'z', 'Z': state.typeset.integer.nextEndianness(); return;
		case 'x', 'X': state.typeset.integer.nextRadix(); return;
		// TODO Text typesetting settings
		
		// FIXME Switch command palette
		
		default: break;
	} else switch (input.scancode) {
		// FIXME File movement
		default: break;
	}
}
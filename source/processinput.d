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
	
	ulong pageMovement = state.screen.bytesPerFilePage - state.screen.bytesPerRow;
	ulong rowMovement = state.screen.bytesPerRow;
	ulong singleMovement = 1; // NOTE aligned addresses would need values other than 1 
	
	// Handle everything else
	if (input.unicode != '\U0010FFFF') switch (input.unicode) {
		// File movement
		case '1': .. case '3': state.files.file[input.unicode-1].toggleFreeze(); break;
		case ' ': state.files.gotoNextDifference(pageMovement); return;
		
		// TODO? Address typesetting settings
		// Integer typesetting settings
		case 'w', 'W': state.typeset.integer.nextWidth(); return;
		case 'a', 'A': state.typeset.integer.nextAlignedness(); return;
		case 's', 'S': state.typeset.integer.nextSignedness(); return;
		case 'z', 'Z': state.typeset.integer.nextEndianness(); return;
		case 'x', 'X': state.typeset.integer.nextRadix(); return;
		// TODO Text typesetting settings
		
		// FIXME Switch command palette
		// c/u configuration
		// e edit
		// f find
		// g goto
		
		default: break;
	} else switch (input.scancode) {
		// File movement
		case Scancode.kb_up:    state.files.gotoRelative(0, rowMovement); return;
		case Scancode.kb_down:  state.files.gotoRelative(rowMovement, 0); return;
		case Scancode.kb_left:  state.files.gotoRelative(0, singleMovement); return;
		case Scancode.kb_right: state.files.gotoRelative(singleMovement, 0); return;
		
		case Scancode.kb_home: state.files.gotoAbsoluteIndex(0); return;
		case Scancode.kb_end:  state.files.gotoAbsoluteIndex(ulong.max); return;
		case Scancode.kb_page_up:   state.files.gotoRelative(0, pageMovement); return;
		case Scancode.kb_page_down: state.files.gotoRelative(pageMovement, 0); return;
		
		case Scancode.kb_return:    state.files.gotoNextDifference(pageMovement); return;
		case Scancode.kb_backspace: state.files.gotoPreviousDifference(pageMovement); return;
		
		default: break;
	}
}
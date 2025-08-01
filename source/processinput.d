import keyinput;
import state;

void processKeyInput(WholeProcessState state, KeyInput input) {
	final switch (state.input.mode) {
		case CommandPaletteMode.topLevel:
			process__topLevel(state, input);
			return;
	}
}

// FIXME remember to make other functions private when possible
private void process__topLevel(WholeProcessState state, KeyInput input) {
	if (input.unicode != '\U0010FFFF') switch (input.unicode) {
		// Quit
		case 'q', 'Q': state.exit.normal(); return;
		// Integer settings
		case 'w', 'W': state.typeset.integer.nextWidth(); return;
		case 'a', 'A': state.typeset.integer.nextAlignedness(); return;
		case 's', 'S': state.typeset.integer.nextSignedness(); return;
		case 'z', 'Z': state.typeset.integer.nextEndianness(); return;
		case 'x', 'X': state.typeset.integer.nextRadix(); return;
		// Other top-level actions
		case '1': .. case '3': state.files.toggleFreeze(input.unicode - 1); return;
		//FIXME case ' ': state.files.gotoSpecial_nextDiff(); return;
		
		// Switch command palette
		// TODO c/u for configuration
		// TODO e for edit
		// FIXME f for find
		// FIXME g for goto
		
		default: break;
	} else switch (input.scancode) {
		/*FIXME case Scancode.kb_up: state.files.gotoSpecial_up(); return;
		case Scancode.kb_down: state.files.gotoSpecial_down(); return;
		case Scancode.kb_left: state.files.gotoSpecial_left(); return;
		case Scancode.kb_right: state.files.gotoSpecial_right(); return;
		
		case Scancode.kb_home: state.files.gotoSpecial_home(); return;
		case Scancode.kb_end: state.files.gotoSpecial_end(); return;
		case Scancode.kb_page_up: state.files.gotoSpecial_pageUp(); return;
		case Scancode.kb_page_down: state,files.gotoSpecial_pageDown(); return;
		
		case Scancode.kb_return: state.files.gotoSpecial_nextDiff(); return;
		case Scancode.kb_backspace: state.files.gotoSpecial_prevDiff(); return;*/
		
		default: break;
	}
}
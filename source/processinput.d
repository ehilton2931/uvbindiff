import keyinput;
import state_1;

void processKeyInput(WholeProcessState state, KeyInput input) {
	final switch (state.commandPaletteMode) {
		case CommandPaletteMode.topLevel:
			process__topLevel(state, input);
			return;
	}
}

private void process__topLevel(WholeProcessState state, KeyInput input) {
	if (input.unicode != '\U0010FFFF') switch (input.unicode) {
		// Quit
		case 'q', 'Q': state.quit = true; return;
		// Integer settings
		case 'w', 'W': state.files.render.nextWidth(); return;
		case 'a', 'A': state.files.render.nextAlignedness(); return;
		case 's', 'S': state.files.render.nextSignedness(); return;
		case 'z', 'Z': state.files.render.nextEndianness(); return;
		case 'x', 'X': state.files.render.nextRadix(); return;
		// Other top-level actions
		//FIXME case '1': .. case '9': state.files.toggleFreeze(input.unicode); return;
		//FIXME case ' ': state.files.gotoSpecial_nextDiff(); return;
		
		// Switch command palette
		// FIXME c/u for configuration
		// FIXME e for edit
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

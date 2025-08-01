import keyinput;
import state;

void processKeyInput(WholeProcessState state, KeyInput input) {
	final switch (state.input.mode) {
		case CommandPaletteMode.topLevel:
			process__topLevel(state, input);
			return;
	}
}

private void process__topLevel(WholeProcessState state, KeyInput input) {
	
}
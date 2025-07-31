import std.stdio;

import atom;
import init_shutdown;
import keyinput;
import processinput;
import rendering;
import state;
import typesetting;

void main(string[] args) {
	appMain(args);
}

void appMain(string[] args) {
	WholeProcessState state = init(args);
	loop(state);
	shutdown(state);
}

// FIXME check 0- vs 1-indexing of files
void loop(WholeProcessState state) {
	while (!state.exit.shouldQuit) {
		Atom[] atoms = typeset(state);
		if (state.exit.shouldQuit) break;
		render(state, atoms);
		
		KeyInput input = getKeyInput();
		processKeyInput(state, input);
	}
}

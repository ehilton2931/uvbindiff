import std.stdio;

import atom;
import impl_ncurses;
import init_shutdown;
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

void loop(WholeProcessState state) {
	while (!state.exit.shouldQuit) {
		Atom[] atoms = typeset(state);
		if (state.exit.shouldQuit) break;
		render(state, atoms);
		import deimos.ncurses; getch__ncurses();
		state.exit.normal();
		
		/*FIXME KeyInput input = getInput();
		processInput(state, input);*/
	}
}

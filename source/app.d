import keyinput;
import processinput;
import render;
import state_1;
import typesetting;

void main(string[] args) {
	appMain(args);
}

// FIXME: @safe chaining/discovery
// TODO: Evaluate ulong vs size_t
// TODO: Enforce dstring
void appMain(string[] args) {
	WholeProcessState state = init(args);
	loop(state);
	shutdown(state);
}



WholeProcessState init(string[] args) {
	WholeProcessState state = new WholeProcessState(); // FIXME
	
	// FIXME
	initRender();
	initKeyboard();
	
	return state;
}

void loop(WholeProcessState state) {
	while (!state.quit) {
		// Render, *then* block waiting for input
		TypesettingAtom[] atoms = typesetScreen(state); // FIXME universal
		if (state.quit) break;
		renderScreen(state, atoms);
		
		KeyInput input = getKeyInput();
		processKeyInput(state, input);  // FIXME universal
	}
}

void shutdown(WholeProcessState state) {
	// FIXME
	shutdownRender();
}

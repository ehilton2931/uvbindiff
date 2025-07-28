import render_impl_ncurses;
import state_1;
import typesetting;

void initRender() {
	initRender__ncurses();
}

void renderScreen(WholeProcessState state, TypesettingAtom[] atoms) {
	state.gcScope = ["Test"];
	
	for (int i = 0; i < atoms.length; i++) {
		renderAtom(state, atoms[i]);
	}
	
	commitRender();
}

void shutdownRender() {
	shutdownRender__ncurses();
}

int getRows() {
	return getRows__ncurses();
}

int getColumns() {
	return getColumns__ncurses();
}



void renderAtom(WholeProcessState state, TypesettingAtom atom) {
	renderAtom__ncurses(state, atom);
}

void commitRender() {
	commitRender__ncurses();
}

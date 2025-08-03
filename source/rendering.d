import atom;
import impl_ncurses;
import state;

void render(WholeProcessState state, Atom[] atoms) {
	for (ulong i = 0; i < atoms.length; i++) {
		renderAtom(state, atoms[i]);
	}
	
	commitRender();
}

private void renderAtom(WholeProcessState state, Atom atom) {
	renderAtom__ncurses(state, atom);
}

private void commitRender() {
	commitRender__ncurses();
}
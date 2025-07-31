import core.stdc.locale;
import deimos.ncurses;

import atom;
import state;

// init and shutdown //=======================================================//

void initRender__ncurses() {
	setlocale(LC_CTYPE, "");
	initscr();
	/*FIXME if (!has_colors()) {
		endwin();
		state.quit = true;
		if not already occupied, state.errmsg = "Your terminal doesn't support colors!"
	}*/
	
	start_color();
}

void initKeyboard__ncurses() {
	raw(); // Disable line buffering, let uvbindiff handle Ctrl+C
	noecho(); // Disable echoing, as most input is not intended to be text
	keypad(stdscr, true); // Enable reading of arrow keys
}

ScreenInformation getScreenInformation__ncurses() {
	return new ScreenInformation(LINES, COLS);
}

void shutdownKeyboard__ncurses() {
	return;
}

void shutdownRender__ncurses() {
	endwin();
}

void getch__ncurses() {
	getch();
}

// render //==================================================================//

void renderAtom__ncurses(WholeProcessState state, Atom atom) {
	import std.conv;
	import std.string;
	
	if (atom.type == AtomType.style || atom.type == AtomType.stylePlusStr) {
		Style style = state.render.getStyle(atom.styleKey);
		setColorPair(style);
		setUnderlining(style);
	}
	
	if (atom.type == AtomType.str || atom.type == AtomType.stylePlusStr) {
		printw(toStringz(atom.content));
	}
	
	if (atom.type == AtomType.startOfRow) {
		move(cast(int) atom.row, 0);
	}
}

private static short nextColorPair = 1;
private const bool assumeBoldIsBright = true;
void setColorPair(Style style) {
	// If bright & bold are conflated, enable bold and mask out bright
	short trueFg = cast(short) style.foregroundColor;
	short trueBg = cast(short) style.backgroundColor;
	if (assumeBoldIsBright && 8 <= trueFg && trueFg < 16) {
		trueFg &= ~8;
		attron(A_BOLD);
	} else {
		attroff(A_BOLD);
	}
	
	// Find the color pair, if it exists
	int foundColorPair = 0;
	for (short i = 1; i < nextColorPair && i < COLOR_PAIRS; i++) {
		short fgCheck = 0;
		short bgCheck = 0;
		pair_content(i, &fgCheck, &bgCheck);
		
		if (fgCheck == trueFg && bgCheck == trueBg) {
			foundColorPair = i;
			break;
		}
	}
	
	// If the color pair wasn't found, create it if possible
	// do {} while (false) enables the use of break to leave the if statement
	if (foundColorPair == 0) do {
		if (nextColorPair == short.max) break;
		if (COLOR_PAIRS <= nextColorPair) break;
		
		init_pair(nextColorPair, trueFg, trueBg);
		foundColorPair = nextColorPair;
		nextColorPair++;
	} while (false);
	
	attron(COLOR_PAIR(foundColorPair));
}

void setUnderlining(Style style) {
	if (style.underline > 0) {
		attron(A_UNDERLINE);
	} else {
		attroff(A_UNDERLINE);
	}
}

void commitRender__ncurses() {
	refresh();
}
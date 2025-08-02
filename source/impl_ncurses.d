import core.stdc.locale;
import deimos.ncurses;

import atom;
import keyinput;
import state;

// init and shutdown //=======================================================//

void initRender__ncurses(ExitInformation exit) {
	setlocale(LC_CTYPE, "");
	initscr(); // Does not return on error
	
	if (!has_colors()) {
		endwin();
		exit.error("Your terminal doesn't support colors!");
	} else {
		start_color();
	}
}

void initKeyboard__ncurses() {
	raw(); // Disable line buffering, let uvbindiff handle Ctrl+C
	noecho(); // Disable echoing, as most input is not intended to be text
	keypad(stdscr, true); // Enable reading of arrow keys
}

ulong getRows__ncurses() {
	return LINES;
}

ulong getColumns__ncurses() {
	return COLS;
}

void shutdownKeyboard__ncurses() {
	return; // AFAIK no action is needed
}

void shutdownRender__ncurses() {
	endwin();
}

void getch__ncurses(WholeProcessState state) { // FIXME remove on process input q
	import std.format;
	int val = wgetch(stdscr);
	state.exit.warn(format("%s", val));
}

// keyinput //================================================================//

KeyInput getKeyInput__ncurses() {
	dchar ncursesChar = wgetch(stdscr);
	
	switch (ncursesChar) {
		// 60% keys
		case ' ': .. case '~':
			return new KeyInput(ncursesChar);
		case KEY_BACKSPACE:
			return new KeyInput(Scancode.kb_backspace);
		case '\t':
			return new KeyInput(Scancode.kb_tab); // TODO shift tab?
		case '\r', '\n':
			return new KeyInput(Scancode.kb_return);
			
		// Navigation keys
		case KEY_IC:
			return new KeyInput(Scancode.kb_insert);
		case KEY_DC:
			return new KeyInput(Scancode.kb_delete);
		case KEY_HOME:
			return new KeyInput(Scancode.kb_home);
		case KEY_END:
			return new KeyInput(Scancode.kb_end);
		case KEY_PPAGE:
			return new KeyInput(Scancode.kb_page_up);
		case KEY_NPAGE:
			return new KeyInput(Scancode.kb_page_down);
		case KEY_UP:
			return new KeyInput(Scancode.kb_up);
		case KEY_DOWN:
			return new KeyInput(Scancode.kb_down);
		case KEY_LEFT:
			return new KeyInput(Scancode.kb_left);
		case KEY_RIGHT:
			return new KeyInput(Scancode.kb_right);
			
		// TODO escape & function keys?
			
		default:
			return new KeyInput(Scancode.none);
	}
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
private void setColorPair(Style style) {
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

private void setUnderlining(Style style) {
	if (style.underline > 0) {
		attron(A_UNDERLINE);
	} else {
		attroff(A_UNDERLINE);
	}
}

private void commitRender__ncurses() { // FIXME private test
	refresh();
}
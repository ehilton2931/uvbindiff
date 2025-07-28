import core.stdc.locale;
import deimos.ncurses;
import state_1;
import typesetting;

void initRender__ncurses() {
	setlocale(LC_CTYPE,"");
	initscr();
	/*TODO if (!has_colors()) {
		endwin();
		state.quit = true;
		if not already occupied, state.errmsg = "Your terminal doesn't support colors!"
	}*/
	start_color();
}

void renderAtom__ncurses(WholeProcessState state, TypesettingAtom atom) {
	import std.string : toStringz;
	import std.conv : to;
	setColorPair(atom);
	setUnderlining(atom);
	
	string content = to!string(atom.content);
	mvprintw(atom.row, atom.col, toStringz(content));
	state.gcScope ~= content;
}

void commitRender__ncurses() {
	refresh();
}

void shutdownRender__ncurses() {
	endwin();
}

int getRows__ncurses() {
	return LINES;
}

int getColumns__ncurses() {
	return COLS;
}



private static short nextColorPair = 1;
private const bool assumeBoldIsBright = true;
void setColorPair(TypesettingAtom atom) {
	// If bright & bold are conflated, enable bold and mask out bright
	short trueFg = cast(short) atom.style.fgColor;
	short trueBg = cast(short) atom.style.bgColor;
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

void setUnderlining(TypesettingAtom atom) {
	// ncurses doesn't support underline colors or double underlining
	if (atom.style.underlineCount > 0) {
		attron(A_UNDERLINE);
	} else {
		attroff(A_UNDERLINE);
	}
}



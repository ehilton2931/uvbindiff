import core.stdc.locale;
import deimos.ncurses;

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
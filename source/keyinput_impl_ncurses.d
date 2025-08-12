import deimos.ncurses;
import keyinput;

void initKeyboard__ncurses() {
	raw(); // Disable line buffering, let uvbindiff handle Ctrl+C
	noecho(); // Disable echoing, as most input is not intended to be text
	keypad(stdscr, true); // Enable reading of arrow keys
}

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
		// TODO caps lock
		case '\r', '\n':
			return new KeyInput(Scancode.kb_return);
		// TODO application menu
		
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

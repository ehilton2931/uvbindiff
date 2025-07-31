import impl_ncurses;

class KeyInput {
	// TODO rework one or the other to accept e.g. Shift+Tab
	Scancode scancode;
	dchar unicode; // TODO add proper unicode support
	
	this(dchar c) {
		scancode = Scancode.none;
		unicode = c;
	}
	
	this(Scancode code) {
		scancode = code;
		unicode = '\U0010FFFF';
	}
}

KeyInput getKeyInput() {
	return getKeyInput__ncurses();
}

// Hex values follow the USB HID Spec
// Only includes codes that
	// (a) don't correspond to (printable) characters, and 
	// (b) are present on a tenkeyless keyboard (i.e. an ANSI English keyboard without a numpad)
// The numpad is (mostly) excluded because with num lock on, all but enter are already accounted for
// Order in enum declaration is 60%, then navigation, then function row
enum Scancode {
	none = 0x00,
	
	// TODO check if caps lock and application menu are always intercepted by the OS/terminal
	kb_backspace = 0x2a,
	kb_tab       = 0x2b,
	kb_caps_lock = 0x39,
	kb_return    = 0x28, // Implementation note: fold numpad enter into this
	// Space, while not technically printable, is handled by the unicode side
	kb_menu      = 0x65, // The application menu key, a.k.a. the right click key
	
	kb_insert    = 0x49,
	kb_home      = 0x4a,
	kb_page_up   = 0x4b,
	kb_delete    = 0x4c,
	kb_end       = 0x4d,
	kb_page_down = 0x4e,
	kb_right     = 0x4f,
	kb_left      = 0x50,
	kb_down      = 0x51,
	kb_up        = 0x52,
	
	//kb_escape = 0x29, // TODO ncurses requires work to use escape
	kb_f1 = 0x3a,
	kb_f2 = 0x3b,
	kb_f3 = 0x3c,
	kb_f4 = 0x3d,
	kb_f5 = 0x3e,
	kb_f6 = 0x3f,
	kb_f7 = 0x40,
	kb_f8 = 0x41,
	kb_f9 = 0x42,
	kb_f10 = 0x43,
	kb_f11 = 0x44,
	kb_f12 = 0x45,
	
	/*
	kb_f13 = 0x68,
	kb_f14 = 0x69,
	kb_f15 = 0x6a,
	kb_f16 = 0x6b,
	kb_f17 = 0x6c,
	kb_f18 = 0x6d,
	kb_f19 = 0x6e,
	kb_f20 = 0x6f,
	kb_f21 = 0x70,
	kb_f22 = 0x71,
	kb_f23 = 0x72,
	kb_f24 = 0x73,
	*/
}
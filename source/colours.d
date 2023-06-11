module ycraft.colours;

import ysge.project;

// palette:
// https://lospec.com/palette-list/resurrect-64

struct Colours {
	SDL_Color background;
	SDL_Color text;
	SDL_Color uiBackground;
	SDL_Color uiOutline;
	SDL_Color uiBackgroundHover;
	SDL_Color uiOutlineHover;
	SDL_Color inventoryBackground;
	SDL_Color inventoryForeground;
}

static Colours GetColours() {
	static bool    first = true;
	static Colours colours;

	if (first) {
		first = false;
		colours.background          = HexToColour(0x3E3546); // 0x4D65B4
		colours.text                = HexToColour(0xFFFFFF);
		colours.uiBackground        = HexToColour(0x4D65B4); // 0x3E3546
		colours.uiOutline           = HexToColour(0xFFFFFF);
		colours.uiBackgroundHover   = HexToColour(0x4D9BE6);
		colours.uiOutlineHover      = HexToColour(0xFFFFFF);
		colours.inventoryBackground = HexToColour(0x966C6C);
		colours.inventoryForeground = HexToColour(0xFFFFFF);
	}

	return colours;
}

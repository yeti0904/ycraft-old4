module ycraft.ui;

import ysge.ui.button;
import ycraft.colours;

Button CreateButton() {
	Button button = new Button();

	button.rect.w       = 200;
	button.rect.h       = 32;
	button.fill         = GetColours().uiBackground;
	button.outline      = GetColours().uiOutline;
	button.labelColour  = GetColours().text;
	button.fillHover    = GetColours().uiBackgroundHover;
	button.outlineHover = GetColours().uiOutlineHover;

	return button;
}

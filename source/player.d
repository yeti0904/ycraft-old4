module ycraft.player;

import ysge.project;
import ycraft.item;
import ycraft.entity;
import ycraft.scenes.game;

class Player : Entity {
	ItemStorage[][] inventory;
	long            selectedItem;

	this(Game game) {
		super(game);

		box.render.props = RenderProps(true, SDL_Rect(0, 496, 16, 16));
		box.physicsOn    = true;

		health    = 5;
		maxHealth = 10;

		inventory = new ItemStorage[][](5, 9);
	}

	void SetItem(ulong line, ulong column, int id) {
		inventory[line][column] = ItemStorage(false, id, 1);
	}
}

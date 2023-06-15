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

		health    = 5;
		maxHealth = 10;

		inventory = new ItemStorage[][](5, 9);
	}

	void SetItem(ulong line, ulong column, int id) {
		inventory[line][column] = ItemStorage(false, id, 1);
	}
}

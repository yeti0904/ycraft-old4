module ycraft.entity;

import ysge.project;
import ycraft.scenes.game;

class Entity {
	SimpleBox box;
	uint      health;
	uint      maxHealth;

	this(Game game) {
		box = new SimpleBox(SDL_Rect(0, 0, 16, 16), game.gameTextures);
	}
}

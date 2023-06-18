module ycraft.item;

import ysge.project;
import ycraft.scenes.game;

struct ItemDef {
	string name;

	// block info
	bool isBlock;
	uint blockID;

	// display
	SDL_Rect textureSource;
}

struct ItemStorage {
	bool empty = true;
	int  id;
	int  amount;
}

class ItemManager {
	ItemDef[int] defs;

	void CreateBlock(Game game, int id, string name, uint blockID) {
		defs[id] = ItemDef(
			name, true, blockID,
			game.frontLayer.tileDefs[blockID].render.props.crop
		);
	}

	ItemDef GetDef(int id) {
		return defs[id];
	}
}

module ycraft.hotbarUI;

import std.math;
import ysge.project;
import ycraft.app;
import ycraft.item;
import ycraft.colours;
import ycraft.scenes.game;

class Hotbar : UIElement {
	ItemStorage[] hotbar;

	override bool HandleEvent(Project project, SDL_Event e) {
		return false;
	}

	override void Render(Project project) {
		auto game      = cast(Ycraft) project;
		auto gameScene = cast(Game) game.currentScene;
		auto res       = game.GetResolution();

		auto hotbarRect = SDL_Rect(
			(res.x / 2) - ((16 * 9) / 2), res.y - 18, 16 * 9, 16
		);

		// render hotbar background
		auto hotbarBack = SDL_Rect(
			hotbarRect.x - 2, hotbarRect.y - 2,
			hotbarRect.w + 4, hotbarRect.h + 4
		);
		auto hotbarBackColour = GetColours().inventoryBackground;
		auto hotbarForeColour = GetColours().inventoryForeground;
		SDL_SetRenderDrawColor(
			game.renderer, hotbarBackColour.r, hotbarBackColour.g,
			hotbarBackColour.b, hotbarBackColour.a
		);
		SDL_RenderFillRect(game.renderer, &hotbarBack);
		SDL_SetRenderDrawColor(
			game.renderer, hotbarForeColour.r, hotbarForeColour.g,
			hotbarForeColour.b, hotbarForeColour.a
		);
		SDL_RenderDrawRect(game.renderer, &hotbarBack);

		foreach (i, ref item ; gameScene.player.inventory[4]) {
			if (item.empty) {
				continue;
			}
		
			auto itemRect  = hotbarRect;
			itemRect.x    += i * 16;
			itemRect.w     = 16;

			auto itemDef = gameScene.itemDefs.GetDef(item.id);

			SDL_RenderCopy(
				game.renderer, gameScene.gameTextures, &itemDef.textureSource,
				&itemRect
			);
		}

		// draw outline on selected item
		SDL_SetRenderDrawColor(
			game.renderer, hotbarForeColour.r, hotbarForeColour.g,
			hotbarForeColour.b,
			cast(ubyte) (abs(sin(cast(float) game.frames / 10.0)) * 255.0)
		);

		auto outlineRect = SDL_Rect(
			cast(int) ((gameScene.player.selectedItem * 16) + hotbarRect.x),
			hotbarRect.y, 16, 16
		);

		for (size_t j = 0; j < 2; ++ j) {
			outlineRect.x -= 1;
			outlineRect.y -= 1;
			outlineRect.w += 2;
			outlineRect.h += 2;

			SDL_RenderDrawRect(game.renderer, &outlineRect);
		}
	}
}

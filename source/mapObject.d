module ycraft.mapObject;

import ysge.project;
import ysge.objects.tileMap;
import ycraft.scenes.game;

class Map : TileMap {
	bool drawOutlines;

	this(Vec2!ulong size) {
		super(size);
	}

	override void Render(Project parent) {
		Vec2!int start = Vec2!int(
			pos.x - parent.currentScene.camera.x,
			pos.y - parent.currentScene.camera.y
		);

		for (int y = 0; y < tiles.length; ++ y) {
			for (int x = 0; x < tiles[0].length; ++ x) {
				Vec2!int tilePos = Vec2!int(
					start.x + (x * tileSize.x),
					start.y + (y * tileSize.y)
				);
				Vec2!int tileEnd = Vec2!int(
					tilePos.x + tileSize.x,
					tilePos.y + tileSize.y
				);

				if (tiles[y][x].id == 0) {
					continue;
				}

				auto res = parent.GetResolution();

				if (
					(tileEnd.x < 0) ||
					(tileEnd.y < 0)
				) {
					continue;
				}

				if (
					(tilePos.x > res.x) ||
					(tilePos.y > res.y)
				) {
					break;
				}

				auto tile = cast(GameTile*) tiles[y][x];
				auto def  = tileDefs[tile.id];
				auto rect = SDL_Rect(
					tilePos.x, tilePos.y, tileSize.x, tileSize.y
				);

				switch (def.renderType) {
					case RenderType.Colour: {
						if (def.render.colour.a == 0) {
							break;
						}
						
						SDL_SetRenderDrawColor(
							parent.renderer,
							def.render.colour.r,
							def.render.colour.g,
							def.render.colour.b,
							def.render.colour.a
						);
						SDL_RenderFillRect(parent.renderer, &rect);
						break;
					}
					case RenderType.Texture: {
						SDL_Rect* src;

						if (def.renderProps.doCrop) {
							src  = new SDL_Rect();
							*src = def.renderProps.crop;
						}
					
						SDL_RenderCopyEx(
							parent.renderer, def.render.texture.texture, src,
							&rect, cast(double) tile.rotate * 90.0, null,
							SDL_FLIP_NONE
						);
						break;
					}
					default: assert(0);
				}

				SDL_SetRenderDrawColor(parent.renderer, 255, 255, 255, 255);

				if ((x > 0) && (tiles[y][x - 1].id == 0)) {
					SDL_RenderDrawLine(
						parent.renderer, rect.x, rect.y, rect.x,
						(rect.y + rect.h) - 1
					);
				}

				if ((y > 0) && (tiles[y - 1][x].id == 0)) {
					SDL_RenderDrawLine(
						parent.renderer, rect.x, rect.y,
						(rect.x + rect.w) - 1, rect.y
					);
				}

				if ((x < tiles[y].length - 1) && (tiles[y][x + 1].id == 0)) {
					SDL_RenderDrawLine(
						parent.renderer, (rect.x + rect.w) - 1, rect.y,
						(rect.x + rect.w) - 1, (rect.y + rect.h) - 1
					);
				}

				if ((y < tiles.length - 1) && (tiles[y + 1][x].id == 0)) {
					SDL_RenderDrawLine(
						parent.renderer, rect.x, (rect.y + rect.h) - 1,
						(rect.x + rect.w) - 1, (rect.y + rect.h) - 1
					);
				}
			}
		}
	}
}

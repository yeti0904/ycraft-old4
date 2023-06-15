module ycraft.mapObject;

import std.algorithm;
import ysge.project;
import ysge.objects.tileMap;
import ycraft.scenes.game;

class Map : TileMap {
	bool drawOutlines;
	bool drawShadows;

	this(Vec2!ulong size) {
		super(size);
	}

	override void Render(Project parent) {
		auto camera = parent.currentScene.camera;
		auto game   = cast(Game) parent.currentScene;

		auto size = Vec2!ulong(tiles[0].length, tiles.length);
	
		Vec2!int start = Vec2!int(
			pos.x - game.camera.x,
			pos.y - game.camera.y
		);

		Vec2!int startPos = Vec2!int(
			max((camera.x / tileSize.x) - 2, 0),
			max((camera.y / tileSize.y) - 2, 0)
		);

		Vec2!int endPos = Vec2!int(
			min(startPos.x + (parent.GetResolution().x / tileSize.x) + 4, size.x),
			min(startPos.y + (parent.GetResolution().y / tileSize.y) + 4, size.x)
		);

		for (int y = startPos.y; y < endPos.y; ++ y) {
			for (int x = startPos.x; x < endPos.x; ++ x) {
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

				/*if (
					(tileEnd.x < 0) ||
					(tileEnd.y < 0)
				) {
					continue;
				}

				if (
					(tilePos.x > res.x / tileSize.x) ||
					(tilePos.y > res.y / tileSize.y)
				) {
					break;
				}*/

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

						if (drawShadows) {
							SDL_SetTextureAlphaMod(
								def.render.texture.texture, 25
							);
							SDL_SetTextureColorMod(
								def.render.texture.texture, 0, 0, 0
							);

							auto shadowRect = rect;
							foreach (i ; 0 .. 10) {
								++ shadowRect.x;
								++ shadowRect.y;

								SDL_RenderCopy(
									parent.renderer, def.render.texture.texture, src,
									&shadowRect
								);
							}
							
							SDL_SetTextureAlphaMod(
								def.render.texture.texture, 255
							);
							SDL_SetTextureColorMod(
								def.render.texture.texture, 255, 255, 255
							);
						}
						
						// can someone fix it pls
						//if (tile.rotate == 0) {
							SDL_RenderCopy(
								parent.renderer, def.render.texture.texture, src,
								&rect
							);
						/*}
						else {
							SDL_RendererFlip flip;
							switch (tile.rotate) {
								case 1: {
									flip = SDL_FLIP_HORIZONTAL;
									break;
								}
								case 2: {
									flip = SDL_FLIP_VERTICAL;
									break;
								}
								case 3: {
									flip = SDL_FLIP_HORIZONTAL | SDL_FLIP_VERTICAL;
									break;
								}
								default: assert(0);
							}
						
							SDL_RenderCopyEx(
								parent.renderer, def.render.texture.texture, src,
								&rect, 0, null, flip
							);
						}*/

						break;
					}
					default: assert(0);
				}

				SDL_SetRenderDrawColor(parent.renderer, 255, 255, 255, 255);

				if (
					(tile.id in game.extraInfo) &&
					(!game.extraInfo[tile.id].drawBorder)
				) {
					continue;
				}

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

		// handle special blocks
		for (int y = startPos.y; y < endPos.y; ++ y) {
			for (int x = startPos.x; x < endPos.x; ++ x) {
				auto tile = cast(GameTile*) tiles[y][x];
				Vec2!int tilePos = Vec2!int(
					start.x + (x * tileSize.x),
					start.y + (y * tileSize.y)
				);
				auto def  = tileDefs[tile.id];
				auto rect = SDL_Rect(
					tilePos.x, tilePos.y, tileSize.x, tileSize.y
				);
			
				if (tile.id == GameBlocks.Tree) {
					SDL_Rect[] leaves = [
						SDL_Rect(rect.x, rect.y, rect.w, rect.h),
						SDL_Rect(rect.x - 16, rect.y, rect.w, rect.h),
						SDL_Rect(rect.x, rect.y - 16, rect.w, rect.h),
						SDL_Rect(rect.x + 16, rect.y, rect.w, rect.h),
						SDL_Rect(rect.x, rect.y + 16, rect.w, rect.h),
						SDL_Rect(rect.x - 16, rect.y - 16, rect.w, rect.h),
						SDL_Rect(rect.x + 16, rect.y - 16, rect.w, rect.h),
						SDL_Rect(rect.x - 16, rect.y + 16, rect.w, rect.h),
						SDL_Rect(rect.x + 16, rect.y + 16, rect.w, rect.h)
					];
					auto src = SDL_Rect(0x40, 0x00, 0x10, 0x10);

					SDL_SetRenderDrawColor(parent.renderer, 0, 0, 0, 80);

					foreach (leaf ; leaves) {
						leaf.x += 4;
						leaf.y += 4;
						SDL_RenderFillRect(parent.renderer, &leaf);
					}

					foreach (ref leaf ; leaves) {
						SDL_RenderCopy(
							parent.renderer, def.render.texture.texture,
							&src, &leaf
						);
					}
				}
			}
		}
	}
}

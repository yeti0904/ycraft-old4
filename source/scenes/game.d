module ycraft.scenes.game;

import std.math;
import std.random;
import ysge.project;
import ysge.objects.tileMap;
import ycraft.item;
import ycraft.player;
import ycraft.hotbarUI;
import ycraft.generator;
import ycraft.mapObject;

enum GameBlocks {
	Air,
	Grass,
	Stone,
	Sand,
	Water,
	Tree,
	Cactus
}

enum GameAnimations {
	PlayerWalking,
	PlayerStationary
}

// extension for tile definitions
struct ExtraTileInfo {
	bool drawBorder;
}

struct GameTile {
	int   id;
	ubyte rotate; // (0 - 3) * 90

	this(int pid) {
		id     = pid;
		rotate = 0;
	}

	this(int pid, ubyte protate) {
		id     = pid;
		rotate = protate;
	}
}

class Game : Scene {
	Map                frontLayer;
	Map                backLayer;
	Player             player;
	Texture            gameTextures;
	ItemManager        itemDefs;
	ExtraTileInfo[int] extraInfo;

	override void Init(Project parent) {
		// load textures
		gameTextures = parent.LoadTextureFromFile(
			// TODO: make configurable
			parent.GetGameDirectory() ~ "/assets/textures/default.png"
		);
	
		player = new Player(this);
		CameraFollowObject(player.box);

		// create walking animation
		Animation walkingAnimation;
		walkingAnimation.updateTicks = 15;
		walkingAnimation.frames = [
			RenderInfo(
				RenderType.Texture,
				RenderValue(gameTextures),
				RenderProps(true, SDL_Rect(16, 496, 16, 16))
			),
			RenderInfo(
				RenderType.Texture,
				RenderValue(gameTextures),
				RenderProps(true, SDL_Rect(32, 496, 16, 16))
			)
		];
		animations.animations[GameAnimations.PlayerWalking] = walkingAnimation;

		// create stationary animation
		Animation stationaryAnimation;
		stationaryAnimation.updateTicks = 0xFFFFFFFF;
		stationaryAnimation.frames = [
			RenderInfo(
				RenderType.Texture,
				RenderValue(gameTextures),
				RenderProps(true, SDL_Rect(0, 496, 16, 16))
			)
		];
		animations.animations[GameAnimations.PlayerStationary] = stationaryAnimation;
		animations.StartAnimation(
			&player.box.render, GameAnimations.PlayerStationary
		);

		frontLayer = new Map(Vec2!ulong(0, 0));
		backLayer  = new Map(Vec2!ulong(0, 0));


		MakeBlock(GameBlocks.Air,    false, SDL_Rect(0x00, 0x00, 0x00, 0x00));
		MakeBlock(GameBlocks.Grass,  true,  SDL_Rect(0x00, 0x00, 0x10, 0x10));
		MakeBlock(GameBlocks.Stone,  true,  SDL_Rect(0x10, 0x00, 0x10, 0x10));
		MakeBlock(GameBlocks.Sand,   true,  SDL_Rect(0x20, 0x00, 0x10, 0x10));
		MakeBlock(GameBlocks.Water,  true,  SDL_Rect(0x30, 0x00, 0x10, 0x10));
		MakeBlock(GameBlocks.Tree,   true,  SDL_Rect(0x50, 0x00, 0x10, 0x10));
		MakeBlock(GameBlocks.Cactus, true,  SDL_Rect(0x60, 0x00, 0x10, 0x10));
		
		frontLayer.tileSize    = Vec2!int(16, 16);
		frontLayer.drawShadows = true;

		extraInfo[GameBlocks.Tree]   = ExtraTileInfo(false);
		extraInfo[GameBlocks.Cactus] = ExtraTileInfo(false);

		backLayer.tileDefs     = frontLayer.tileDefs;
		backLayer.tileSize     = frontLayer.tileSize;
		backLayer.doCollision  = false;

		itemDefs = new ItemManager();

		// create items
		itemDefs.CreateBlock(this, 0, "Grass", GameBlocks.Grass);
		itemDefs.CreateBlock(this, 1, "Stone", GameBlocks.Stone);
		itemDefs.CreateBlock(this, 2, "Sand",  GameBlocks.Sand);

		player.SetItem(4, 0, 0);
		player.SetItem(4, 1, 1);

		AddObject(backLayer);
		AddObject(player.box);
		AddObject(frontLayer);

		// set up UI
		AddUI(new Hotbar());
	}

	void MakeBlock(int id, bool collides, SDL_Rect crop) {
		frontLayer.tileDefs[id] = TileDef(
			RenderInfo(
				RenderType.Texture,
				RenderValue(gameTextures),
				RenderProps(true, crop)
			),
			collides
		);
	}

	void Generate(Vec2!ulong size) {
		frontLayer.SetSize(size);
		backLayer.SetSize(size);

		GenerateWorld(this, uniform!"[]"(0, 0x7FFFFFFF));

		// spawn player
		Vec2!ulong spawnPos;
		do {
			spawnPos = Vec2!ulong(
				uniform(0, GetWorldSize().x),
				uniform(0, GetWorldSize().y)
			);
		} while (backLayer.tiles[spawnPos.y][spawnPos.x].id == GameBlocks.Water);

		player.box.box.x = cast(int) spawnPos.x * 16;
		player.box.box.y = cast(int) spawnPos.y * 16;
	}

	override void Update(Project parent) {
		// movement
		bool moved;
		if (parent.KeyPressed(SDL_SCANCODE_W)) {
			player.box.MoveUp(this, 1);
			moved = true;
		}
		if (parent.KeyPressed(SDL_SCANCODE_A)) {
			player.box.MoveLeft(this, 1);
			moved = true;
		}
		if (parent.KeyPressed(SDL_SCANCODE_S)) {
			player.box.MoveDown(this, 1);
			moved = true;
		}
		if (parent.KeyPressed(SDL_SCANCODE_D)) {
			player.box.MoveRight(this, 1);
			moved = true;
		}

		if (
			moved && !animations.IsAnimationRunning(GameAnimations.PlayerWalking)
		) {
			animations.StopAnimation(GameAnimations.PlayerStationary);
			animations.StartAnimation(
				&player.box.render, GameAnimations.PlayerWalking
			);
		}
		if (
			!moved && animations.IsAnimationRunning(GameAnimations.PlayerWalking)
		) {
			animations.StopAnimation(GameAnimations.PlayerWalking);
			animations.StartAnimation(
				&player.box.render, GameAnimations.PlayerStationary
			);
		}

		// hotbar selection
		if (parent.KeyPressed(SDL_SCANCODE_1)) {
			player.selectedItem = 0;
		}
		if (parent.KeyPressed(SDL_SCANCODE_2)) {
			player.selectedItem = 1;
		}
		if (parent.KeyPressed(SDL_SCANCODE_3)) {
			player.selectedItem = 2;
		}
		if (parent.KeyPressed(SDL_SCANCODE_4)) {
			player.selectedItem = 3;
		}
		if (parent.KeyPressed(SDL_SCANCODE_5)) {
			player.selectedItem = 4;
		}
		if (parent.KeyPressed(SDL_SCANCODE_6)) {
			player.selectedItem = 5;
		}
		if (parent.KeyPressed(SDL_SCANCODE_7)) {
			player.selectedItem = 6;
		}
		if (parent.KeyPressed(SDL_SCANCODE_8)) {
			player.selectedItem = 7;
		}
		if (parent.KeyPressed(SDL_SCANCODE_9)) {
			player.selectedItem = 8;
		}
	}

	override void PostRender(Project parent, GameObject obj) {
		if (obj is frontLayer) {
			auto hovered = GetHoveredTile(parent);

			if (hovered is null) {
				return;
			}

			SDL_Rect hover;
			hover.x = cast(int) hovered.x * frontLayer.tileSize.x;
			hover.y = cast(int) hovered.y * frontLayer.tileSize.y;
			hover.w = 16;
			hover.h = 16;

			hover.x -= camera.x;
			hover.y -= camera.y;

			SDL_SetRenderDrawColor(
				parent.renderer, 255, 255, 255,
				cast(ubyte) (abs(sin(cast(float) parent.frames / 10.0)) * 255.0)
			);

			SDL_RenderDrawRect(parent.renderer, &hover);
		}
	}

	override void HandleEvent(Project parent, SDL_Event e) {
		switch (e.type) {
			case SDL_MOUSEWHEEL: {
				if (e.wheel.y > 0) {
					-- player.selectedItem;

					if (player.selectedItem < 0) {
						player.selectedItem = 8;
					}
				}
				else if (e.wheel.y < 0) {
					++ player.selectedItem;

					if (player.selectedItem > 8) {
						player.selectedItem = 0;
					}
				}
				break;
			}
			case SDL_MOUSEBUTTONDOWN: {
				switch (e.button.button) {
					case SDL_BUTTON_LEFT: {
						auto pos = GetHoveredTile(parent);

						if (pos is null) {
							break;
						}

						auto frontTile = &frontLayer.tiles[pos.y][pos.x];
						auto backTile  = &backLayer.tiles[pos.y][pos.x];

						if ((*frontTile).id == GameBlocks.Air) {
							*backTile = new Tile(GameBlocks.Air);
						}
						else {
							*frontTile = new Tile(GameBlocks.Air);
						}

						break;
					}
					case SDL_BUTTON_RIGHT: {
						auto pos = GetHoveredTile(parent);

						if (pos is null) {
							break;
						}

						auto frontTile = &frontLayer.tiles[pos.y][pos.x];
						auto backTile  = &backLayer.tiles[pos.y][pos.x];

						auto item = player.inventory[4][player.selectedItem];

						if (item.empty) {
							break;
						}

						auto itemDef = itemDefs.GetDef(item.id);

						if (!itemDef.isBlock) {
							break;
						}

						auto tile = new Tile(itemDef.blockID);

						if ((*backTile).id == GameBlocks.Air) {
							*backTile = tile;
						}
						else {
							*frontTile = tile;
						}

						break;
					}
					default: break;
				}
				break;
			}
			default: {
				break;
			}
		}
	}

	Vec2!ulong* GetHoveredTile(Project parent) {
		auto mapMousePos = new Vec2!ulong(
			(parent.mousePos.x + camera.x) / frontLayer.tileSize.x,
			(parent.mousePos.y + camera.y) / frontLayer.tileSize.y
		);

		Vec2!ulong playerPos  = Vec2!ulong(player.box.box.x, player.box.box.y);
		playerPos.x          /= 16;
		playerPos.y          /= 16;

		if (playerPos.DistanceTo(*mapMousePos) > 6) {
			return null;
		}

		if (
			(mapMousePos.x >= 0) &&
			(mapMousePos.y >= 0) &&
			(mapMousePos.x <= frontLayer.GetSize().x) &&
			(mapMousePos.y <= frontLayer.GetSize().y)
		) {
			return mapMousePos;
		}
		else {
			return null;
		}
	}

	Vec2!ulong GetWorldSize() {
		return Vec2!ulong(frontLayer.tiles[0].length, frontLayer.tiles.length);
	}
}

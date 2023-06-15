module ycraft.generator;

import std.math;
import std.random;
import fast_noise;
import ysge.project;
import ysge.objects.tileMap;
import ycraft.scenes.game;

void GenerateWorld(Game game, int seed) {
	auto noise       = fnlCreateState();
	noise.seed       = seed;
	noise.noise_type = FNLNoiseType.FNL_NOISE_PERLIN;

	for (ulong y = 0; y < game.GetWorldSize().y; ++ y) {
		for (ulong x = 0; x < game.GetWorldSize().x; ++ x) {
			auto floatPos = Vec2!double(cast(double) x, cast(double) y);

			auto point =  abs(fnlGetNoise3D(&noise, floatPos.x, floatPos.y, 0));

			game.frontLayer.tiles[y][x] = cast(Tile*) new GameTile(GameBlocks.Air);

			if (point > 0.20) {
				game.backLayer.tiles[y][x] = cast(Tile*) new GameTile(
					GameBlocks.Grass, cast(ubyte) uniform!"[]"(0, 3)
				);
			}
			else if (point > 0.15) {
				game.backLayer.tiles[y][x] = cast(Tile*) new GameTile(
					GameBlocks.Sand, cast(ubyte) uniform!"[]"(0, 3)
				);
			}
			else {
				game.backLayer.tiles[y][x] = cast(Tile*) new GameTile(GameBlocks.Water);
			}
		}
	}
}

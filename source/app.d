module ycraft.app;

import std.stdio;
import std.format;
import ycraft.info;
import ysge.info;
import ysge.project;
import ycraft.scenes.game;
import ycraft.scenes.titleScreen;

enum GameScenes {
	TitleScreen = 0,
	Game        = 1
}

class Ycraft : Project {
	override void Init() {
		string windowName = format("ycraft %s (%s)", appVersion, ysgeVersion);
	
		InitWindow(windowName, 640, 360, true);
		SetResolution(640, 360);

		SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);

		InitLibs();
		LoadFontFile(GetGameDirectory() ~ "/assets/font.ttf", 16);

		AddScene(new TitleScreen());
		AddScene(new Game());
		SetScene(GameScenes.TitleScreen);
	}
}

void main() {
	auto game = new Ycraft();

	game.Run();
}

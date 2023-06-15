module ycraft.scenes.titleScreen;

import ysge.project;
import ysge.ui.text;
import ysge.ui.button;
import ycraft.ui;
import ycraft.app;
import ycraft.colours;
import ycraft.scenes.game;

class TitleScreen : Scene {
	Button playButton;
	Button quitButton;

	override void Init(Project parent) {
		bg = GetColours().background;

		auto res = parent.GetResolution();
	
		auto titleText   = new Text();
		titleText.scale  = 3.0;
		titleText.colour = GetColours().text;
		titleText.SetText("ycraft");

		auto titleTextSize = titleText.GetTextSize(parent);

		titleText.pos = Vec2!int(
			(res.x / 2) - (titleTextSize.x / 2),
			50
		);

		AddUI(titleText);

		playButton         = CreateButton();
		playButton.onClick = (Project parent, Button button) {
			auto game = cast(Ycraft) parent;

			game.SetScene(GameScenes.Game);
			auto gameScene = cast(Game) game.scenes[GameScenes.Game];
			gameScene.Generate(Vec2!ulong(512, 512));
		};
		playButton.rect.x = (res.x / 2) - (playButton.rect.w / 2);
		playButton.rect.y = 110;
		playButton.SetLabel("Play");
		AddUI(playButton);

		quitButton = CreateButton();
		quitButton.onClick = (Project parent, Button button) {
			parent.running = false;
		};
		quitButton.rect.x = (res.x / 2) - (playButton.rect.w / 2);
		quitButton.rect.y = 150;
		quitButton.SetLabel("Quit");
		AddUI(quitButton);
	}

	override void Update(Project parent) {
		
	}

	override void PostRender(Project parent, GameObject obj) {
		
	}
	
	override void HandleEvent(Project parent, SDL_Event e) {
		
	}
}

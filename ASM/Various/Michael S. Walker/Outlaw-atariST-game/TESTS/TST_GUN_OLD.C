#include <stdio.h>
#include <osbind.h>
#include <RASTER.H>
#include <MODEL.H>
#include <RENDERER.H>
#include <BITMAP/BULLET.C>
#include <EVENTS.H>

int main(int argc, char *argv[])
{
	Game game;
	void *base = Physbase();
	game.gun_slinger[PLAYER_ONE].bullet[0].sprite.bitmap.current_image = gs_bullet;
	game.gun_slinger[PLAYER_ONE].bullet[0].sprite.bitmap.raster.Draw = Rast8Draw;
	game.gun_slinger[PLAYER_ONE].bullet[0].sprite.bitmap.height = (sizeof(gs_bullet) / sizeof gs_bullet[0]);
	game.gun_slinger[PLAYER_ONE].bullet[0].sprite.x_pos = 50;
	game.gun_slinger[PLAYER_ONE].bullet[0].sprite.y_pos = 50;

	game.gun_slinger[PLAYER_ONE].bullet[0].sprite.render_flag = ON;
	while (1)
	{
		Render(&game, base);
		EventMoveBullets(game)
	}
	return 0;
}
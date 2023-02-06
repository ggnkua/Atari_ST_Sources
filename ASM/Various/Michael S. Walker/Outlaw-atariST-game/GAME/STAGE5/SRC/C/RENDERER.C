#include <RENDERER.H>
#include <TYPES.H>
#include <RASTER.H>
#include <stdio.h>

#include <osbind.h> /* for Vsync() */ 

void RenderGunSlinger(GunSlinger *gs, void *base)
{
	gs->sprite.bitmap.current_image = gs->sprite.bitmap.stored_images[gs->player_state];
	gs->sprite.bitmap.raster.Draw(base, &gs->sprite);
	gs->sprite.render_flag = OFF;
}

void RenderBullet(Bullet *bullet, void *base)
{
	bullet->sprite.bitmap.raster.Draw(base, &bullet->sprite);
	bullet->sprite.render_flag = OFF;
}

void RenderCylinder(Cylinder *cylinder, void *base)
{
	cylinder->sprite.bitmap.current_image = cylinder->sprite.bitmap.stored_images[cylinder->state];
	cylinder->sprite.bitmap.raster.Draw(base, &cylinder->sprite);
	cylinder->sprite.render_flag = OFF;
}

void RenderScore(unsigned char c, void *base, int x0, int y0)
{
	PlotChar(base, x0, y0, c);
}

void RenderBackground(BackGround *bg, void *base)
{
	bg->sprite.bitmap.raster.Draw(base, &bg->sprite);
	bg->sprite.render_flag = OFF;
}

void Render(Game *game, void *base)
{
	int i;

	/* render background */

	if (game->background.sprite.render_flag == ON)
		RenderBackground(&game->background, base);

	Vsync(); 

	/* render player one state */

	if (game->gun_slinger[PLAYER_ONE].sprite.render_flag == ON)
		RenderGunSlinger(&game->gun_slinger[PLAYER_ONE], base);

	/* render player two state */

	if (game->gun_slinger[PLAYER_TWO].sprite.render_flag == ON)
		RenderGunSlinger(&game->gun_slinger[PLAYER_TWO], base);

	/* render player one bullets */

	for (i = 0; i < NUM_ROUNDS; i++)
		if (game->gun_slinger[PLAYER_ONE].bullet[i].sprite.render_flag == ON)
			RenderBullet(&game->gun_slinger[PLAYER_ONE].bullet[i], base);

	/* render player two bullets */

	for (i = 0; i < NUM_ROUNDS; i++)
		if (game->gun_slinger[PLAYER_TWO].bullet[i].sprite.render_flag == ON)
			RenderBullet(&game->gun_slinger[PLAYER_TWO].bullet[i], base);

	/* render player one cylinder */

	if (game->gun_slinger[PLAYER_ONE].cylinder.sprite.render_flag == ON)
		RenderCylinder(&game->gun_slinger[PLAYER_ONE].cylinder, base);

	/* render player two cylinder */

	if (game->gun_slinger[PLAYER_TWO].cylinder.sprite.render_flag == ON)
		RenderCylinder(&game->gun_slinger[PLAYER_TWO].cylinder, base);

	/* render player one score */

	if (game->gun_slinger[PLAYER_ONE].score.sprite.render_flag == ON)
	{
		RenderScore(game->gun_slinger[PLAYER_ONE].score.msd, base, 80, 16);
		RenderScore(game->gun_slinger[PLAYER_ONE].score.lsd, base, 88, 16);
		game->gun_slinger[PLAYER_ONE].score.sprite.render_flag = OFF;
	}

	/* render player two score */

	if (game->gun_slinger[PLAYER_TWO].score.sprite.render_flag == ON)
	{
		RenderScore(game->gun_slinger[PLAYER_TWO].score.msd, base, 548, 16);
		RenderScore(game->gun_slinger[PLAYER_TWO].score.lsd, base, 552, 16);
		game->gun_slinger[PLAYER_TWO].score.sprite.render_flag = OFF;
	}
}

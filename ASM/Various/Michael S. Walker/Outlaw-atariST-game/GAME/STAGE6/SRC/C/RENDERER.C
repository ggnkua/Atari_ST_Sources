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
	int i, flag = -1;

	/* render background */

	if (game->background.sprite.render_flag == ON)
	{
		RenderBackground(&game->background, base);
		flag = 1;
	}

	/* render player one state */

	if (game->gun_slinger[PLAYER_ONE].sprite.render_flag == ON)
	{
		RenderGunSlinger(&game->gun_slinger[PLAYER_ONE], base);
		flag = 1;
	}

	/* render player two state */

	if (game->gun_slinger[PLAYER_TWO].sprite.render_flag == ON)
	{
		RenderGunSlinger(&game->gun_slinger[PLAYER_TWO], base);
		flag = 1;
	}

	/* render player one bullets */

	for (i = 0; i < NUM_ROUNDS; i++)
		if (game->gun_slinger[PLAYER_ONE].bullet[i].sprite.render_flag == ON)
		{
			RenderBullet(&game->gun_slinger[PLAYER_ONE].bullet[i], base);
			flag = 1;
		}

	/* render player two bullets */

	for (i = 0; i < NUM_ROUNDS; i++)
		if (game->gun_slinger[PLAYER_TWO].bullet[i].sprite.render_flag == ON)
		{
			RenderBullet(&game->gun_slinger[PLAYER_TWO].bullet[i], base);
			flag = 1;
		}

	/* render player one cylinder */

	if (game->gun_slinger[PLAYER_ONE].cylinder.sprite.render_flag == ON)
	{
		RenderCylinder(&game->gun_slinger[PLAYER_ONE].cylinder, base);
		flag = 1;
	}

	/* render player two cylinder */

	if (game->gun_slinger[PLAYER_TWO].cylinder.sprite.render_flag == ON)
	{
		RenderCylinder(&game->gun_slinger[PLAYER_TWO].cylinder, base);
		flag = 1;
	}

	/* render player one score */

	RenderScore(game->gun_slinger[PLAYER_ONE].score.msd, base, 80, 16);
	RenderScore(game->gun_slinger[PLAYER_ONE].score.lsd, base, 88, 16);

	/* render player two score */

	RenderScore(game->gun_slinger[PLAYER_TWO].score.msd, base, 548, 16);
	RenderScore(game->gun_slinger[PLAYER_TWO].score.lsd, base, 552, 16);

	if (flag > 0)
		ScrFlipBuffers(&game->screen);
}

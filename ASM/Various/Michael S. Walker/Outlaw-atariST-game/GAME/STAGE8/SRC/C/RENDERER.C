/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *         _    _
 *        | |  | |	OUTLAW. 
 *       -| |  | |- 
 *   _    | |- | |
 * -| |   | |  | |- 	
 *  |.|  -| ||/  |
 *  | |-  |  ___/ 
 * -|.|   | | |
 *  |  \_|| |
 *   \____  |
 *    |   | |- 
 *        | |
 *       -| |
 *        |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#include <RENDERER.H>
#include <TYPES.H>
#include <RASTER.H>
#include <unistd.h> /* for sleep() */

/*-------------------------------------------- RenderMenu -----
|  Function RenderMenu
|
|  Purpose: Draw the game menu
|
|  Parameters: game, base
|
|  Returns:
*-------------------------------------------------------------------*/

void RenderMenu(Game *game, void *base)
{
	game->menu.sprite.bitmap.raster.Draw(base, &game->menu.sprite);
	RenderString(base, 0, 390, "Michael S. Walker <mwalk762@mtroyal.ca>");
	ScrFlipBuffers(&game->screen);
}

/*-------------------------------------------- RenderGunSlinger -----
|  Function RenderGunSlinger
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void RenderGunSlinger(GunSlinger *gs, void *base)
{
	gs->sprite.bitmap.current_image = gs->sprite.bitmap.stored_images[gs->player_state];
	gs->sprite.bitmap.raster.Draw(base, &gs->sprite);
}

/*-------------------------------------------- RenderBullet -----
|  Function RenderBullet
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void RenderBullet(Bullet *bullet, void *base)
{
	bullet->sprite.bitmap.raster.Draw(base, &bullet->sprite);
}

/*-------------------------------------------- RenderCylinder -----
|  Function RenderCylinder
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void RenderCylinder(Cylinder *cylinder, void *base)
{
	cylinder->sprite.bitmap.current_image = cylinder->sprite.bitmap.stored_images[cylinder->state];
	cylinder->sprite.bitmap.raster.Draw(base, &cylinder->sprite);
}

/*-------------------------------------------- RenderScore -----
|  Function RenderScore
|
|  Purpose: Write the score to the screen
|
|  Parameters: C the score, base, x0, y0
|
|  Returns:
*-------------------------------------------------------------------*/

void RenderScore(unsigned char c, void *base, int x0, int y0)
{
	PlotChar(base, x0, y0, c);
}

/*-------------------------------------------- RenderString -----
|  Function RenderString
|
|  Purpose: Draw a string to the screen
|
|  Parameters: base, x the x pos to plot, y the y post to plot, st the string
|
|  Returns:
*-------------------------------------------------------------------*/

void RenderString(void *base, int x, int y, char *st)
{
	while (*st)
	{
		PlotChar(base, x, y, *st++);
		x += 8;
	}
}

/*-------------------------------------------- RenderWin -----
|  Function RenderWin
|
|  Purpose: Print win condition to the screen
|
|  Parameters: sc, base, player the number of the player who won
|
|  Returns:
*-------------------------------------------------------------------*/

void RenderWin(Screen *sc, void *base, int player)
{
	ClearScreen(base);
	if (player == 1)
		RenderString(base, 280, 200, "Player One Wins");
	else
		RenderString(base, 280, 200, "Player Two Wins");

	ScrFlipBuffers(sc);

	sleep(5);
}

/*-------------------------------------------- RenderBackground -----
|  Function RenderBackground
|
|  Purpose: Render the background
|
|  Parameters: bg, base
|
|  Returns:
*-------------------------------------------------------------------*/

void RenderBackground(BackGround *bg, void *base)
{
	bg->sprite.bitmap.raster.Draw(base, &bg->sprite);
}

/*-------------------------------------------- RenderSplash -----
|  Function RenderSplash
|
|  Purpose: Render the splash screen
|
|  Parameters: game, base pointer to current framebuffer
|
|  Returns:
*-------------------------------------------------------------------*/

void RenderSplash(Game *game, void *base)
{
	game->splash.sprite.bitmap.raster.Draw(base, &game->splash.sprite);
	ScrFlipBuffers(&game->screen);
}

/*-------------------------------------------- Render -----
|  Function Render
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void Render(Game *game, void *base)
{
	int i;

	/* render background */

	RenderBackground(&game->background, base);

	/* render player one state */

	RenderGunSlinger(&game->gun_slinger[PLAYER_ONE], base);

	/* render player two state */

	RenderGunSlinger(&game->gun_slinger[PLAYER_TWO], base);

	/* render player one bullets */

	for (i = 0; i < NUM_ROUNDS; i++)
		RenderBullet(&game->gun_slinger[PLAYER_ONE].bullet[i], base);

	/* render player two bullets */

	for (i = 0; i < NUM_ROUNDS; i++)
		RenderBullet(&game->gun_slinger[PLAYER_TWO].bullet[i], base);

	/* render player one cylinder */
	RenderCylinder(&game->gun_slinger[PLAYER_ONE].cylinder, base);

	/* render player two cylinder */

	RenderCylinder(&game->gun_slinger[PLAYER_TWO].cylinder, base);

	/* render player one score */

	RenderScore(game->gun_slinger[PLAYER_ONE].score.msd, base, 80, 16);
	RenderScore(game->gun_slinger[PLAYER_ONE].score.lsd, base, 88, 16);

	/* render player two score */

	RenderScore(game->gun_slinger[PLAYER_TWO].score.msd, base, 548, 16);
	RenderScore(game->gun_slinger[PLAYER_TWO].score.lsd, base, 552, 16);

	ScrFlipBuffers(&game->screen);
}

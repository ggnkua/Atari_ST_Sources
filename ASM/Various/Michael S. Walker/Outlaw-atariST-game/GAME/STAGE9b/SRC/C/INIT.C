/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#include <RASTER.H>
#include <INIT.H>
#include <EVENTS.H>

#include <BITMAP/MOUSE.C>
#include <BITMAP/BG.C>
#include <BITMAP/P1_DEAD.C>
#include <BITMAP/P1_NORM.C>
#include <BITMAP/P1_SH.C>
#include <BITMAP/P1_SHDWN.C>
#include <BITMAP/P1_SHUP.C>
#include <BITMAP/P1_WALK.C>

#include <BITMAP/P2_DEAD.C>
#include <BITMAP/P2_NORM.C>
#include <BITMAP/P2_SH.C>
#include <BITMAP/P2_SHDWN.C>
#include <BITMAP/P2_SHUP.C>
#include <BITMAP/P2_WALK.C>
#include <BITMAP/BULLET.C>

#include <BITMAP/0CYL.c>
#include <BITMAP/1CYL.c>
#include <BITMAP/2CYL.c>
#include <BITMAP/3CYL.c>
#include <BITMAP/4CYL.c>
#include <BITMAP/5CYL.c>
#include <BITMAP/6CYL.C>

/*-------------------------------------------- InitGame -----
|  Function InitGame
|
|  Purpose: setup game states
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitGame(Game *game)
{
	InitGameBackGround(game);
	InitBullets(game);
	InitScore(game);
	InitP1(&game->gun_slinger[PLAYER_ONE], game->screen.current_fb_index);
	InitP2(&game->gun_slinger[PLAYER_TWO], game->screen.current_fb_index);
}

/*-------------------------------------------- InitP1 -----
|  Function InitP1
|
|  Purpose: init human players bitmaps and start location
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitP1(GunSlinger *gs, int current_frame)
{
	InitP1States(gs);
	InitStartLocation(gs, P1_START_X, P1_START_Y, STANDARD, current_frame);
	InitCylinder(&gs->cylinder, CYL_P1_X_LOC, CYL_P1_Y_LOC);
	EventShoot(RELOAD, gs);
}

/*-------------------------------------------- InitP2 -----
|  Function InitP2
|
|  Purpose: init computer players bitmaps and start location
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitP2(GunSlinger *gs, int current_frame)
{
	InitP2States(gs);
	InitStartLocation(gs, P2_START_X, P2_START_Y, INVERTED, current_frame);
	InitCylinder(&gs->cylinder, CYL_P2_X_LOC, CYL_P2_Y_LOC);
	EventShoot(RELOAD, gs);
}

/*-------------------------------------------- InitGameBackGround -----
|  Function InitGameBackGround
|
|  Purpose: init the background
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitGameBackGround(Game *game)
{
	/* INIT SCREEN STATES */
	game->background.sprite.bitmap.current_image = screen;
	game->background.sprite.bitmap.raster.Draw = PrintScreen;
	game->background.sprite.bitmap.height = (sizeof(screen) / (sizeof screen[0]));
}

/*-------------------------------------------- InitBullets -----
|  Function InitBullets
|
|  Purpose: init bullet bitmap states
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitBullets(Game *game)
{
	int i;

	for (i = 0; i < NUM_ROUNDS; i++)
	{
		MDLTurnOffBullet(&game->gun_slinger[PLAYER_ONE].bullet[i]);
		InitRaster8Lib(&game->gun_slinger[PLAYER_ONE].bullet[i].sprite);

		game->gun_slinger[PLAYER_ONE].bullet[i].sprite.bitmap.current_image = gs_bullet;
		game->gun_slinger[PLAYER_ONE].bullet[i].sprite.bitmap.height = (sizeof(gs_bullet) / (sizeof gs_bullet[0]));

		MDLTurnOffBullet(&game->gun_slinger[PLAYER_TWO].bullet[i]);
		InitRaster8Lib(&game->gun_slinger[PLAYER_TWO].bullet[i].sprite);

		game->gun_slinger[PLAYER_TWO].bullet[i].sprite.bitmap.current_image = gs_bullet;
		game->gun_slinger[PLAYER_TWO].bullet[i].sprite.bitmap.height = (sizeof(gs_bullet) / (sizeof gs_bullet[0]));
	}
}

/*-------------------------------------------- InitScore -----
|  Function InitScore
|
|  Purpose: initialize scores to 0 
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitScore(Game *game)
{
	/* initialize score to zero */

	game->gun_slinger[PLAYER_ONE].score.msd =
		game->gun_slinger[PLAYER_ONE].score.lsd =
			game->gun_slinger[PLAYER_TWO].score.msd =
				game->gun_slinger[PLAYER_TWO].score.lsd = 48; /* 48 base 10 is the character '0' */
}

/*-------------------------------------------- InitP1States -----
|  Function InitP1States
|
|  Purpose: init player 1 bitmap states
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitP1States(GunSlinger *gs)
{
	gs->sprite.bitmap.stored_images[STATE_DEAD] = p1_dead;
	gs->sprite.bitmap.stored_images[STATE_NORM] = p1_normal;
	gs->sprite.bitmap.stored_images[STATE_SHOOT] = p1_shoot;
	gs->sprite.bitmap.stored_images[STATE_SHOOT_UP] = p1_shoot_up;
	gs->sprite.bitmap.stored_images[STATE_SHOOT_DOWN] = p1_shoot_down;
	gs->sprite.bitmap.stored_images[STATE_WALK] = p1_walk;

	gs->player_state = STATE_NORM;

	InitRaster32Lib(&gs->sprite);
}

/*-------------------------------------------- InitP2States -----
|  Function InitP2States
|
|  Purpose: initt player 2 bitmap states
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitP2States(GunSlinger *gs)
{
	gs->sprite.bitmap.stored_images[STATE_DEAD] = p2_dead;
	gs->sprite.bitmap.stored_images[STATE_NORM] = p2_normal;
	gs->sprite.bitmap.stored_images[STATE_SHOOT] = p2_shoot;
	gs->sprite.bitmap.stored_images[STATE_SHOOT_UP] = p2_shoot_down;
	gs->sprite.bitmap.stored_images[STATE_SHOOT_DOWN] = p2_shoot_up;
	gs->sprite.bitmap.stored_images[STATE_WALK] = p2_walk;

	gs->player_state = STATE_NORM;

	InitRaster32Lib(&gs->sprite);
}

/*-------------------------------------------- InitStartLocation -----
|  Function InitStartLocation
|
|  Purpose: init gunslingers start location
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitStartLocation(GunSlinger *gs, int x_pos, int y_pos, int orientation, int current_frame)
{
	gs->sprite.x_pos = x_pos;
	gs->sprite.y_pos = y_pos;
	gs->sprite.bitmap.height = 32;

	gs->sprite.y_vel =
		gs->sprite.x_vel =
			gs->score.current_score = 0;

	gs->num_bullets = MAX_ROUNDS;
	gs->flag_alive = ALIVE;
	gs->orientation = orientation;
}

/*-------------------------------------------- InitRaster8Lib -----
|  Function InitRaster8Lib
|
|  Purpose: initialize raster 8 bit lib
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitRaster8Lib(Sprite *sp)
{
	sp->bitmap.raster.Alpha = Rast8Alpha;
	sp->bitmap.raster.Clear = Rast8Clear;
	sp->bitmap.raster.Draw = Rast8Draw;
}

/*-------------------------------------------- InitRaster32Lib -----
|  Function InitRaster32Lib
|
|  Purpose: init sprites raster 32 bit lib
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitRaster32Lib(Sprite *sp)
{
	sp->bitmap.raster.Alpha = Rast32Alpha;
	sp->bitmap.raster.Clear = Rast32Clear;
	sp->bitmap.raster.Draw = Rast32Draw;
}

/*-------------------------------------------- InitCylinder -----
|  Function InitCylinder
|
|  Purpose: init gun cylinders (for ammunition bitmap)
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void InitCylinder(Cylinder *cyl, int x_pos, int y_pos)
{
	InitRaster32Lib(&cyl->sprite);

	cyl->sprite.bitmap.stored_images[CYLINDER_ZERO] = cylinder_0;
	cyl->sprite.bitmap.stored_images[CYLINDER_ONE] = cylinder_1;
	cyl->sprite.bitmap.stored_images[CYLINDER_TWO] = cylinder_2;
	cyl->sprite.bitmap.stored_images[CYLINDER_THREE] = cylinder_3;
	cyl->sprite.bitmap.stored_images[CYLINDER_FOUR] = cylinder_4;
	cyl->sprite.bitmap.stored_images[CYLINDER_FIVE] = cylinder_5;
	cyl->sprite.bitmap.stored_images[CYLINDER_SIX] = cylinder_6;

	cyl->sprite.x_pos = x_pos;
	cyl->sprite.y_pos = y_pos;

	cyl->sprite.x_vel =
		cyl->sprite.y_vel = 0;

	cyl->sprite.bitmap.height = sizeof(cylinder_6) / sizeof cylinder_6[0];
	cyl->sprite.bitmap.current_image = cylinder_6;
}

/*-------------------------------------------- InitMouse -----
|  Function InitMouse
|
|  Purpose: init the mouse 
|
|  Parameters: Game ptr
|
|  Returns:
*-------------------------------------------------------------------*/

void InitMouse(Game *game)
{
	game->mouse.sprite.bitmap.current_image = mouse_ptr;
	game->mouse.sprite.bitmap.height = (sizeof(mouse_ptr) / sizeof mouse_ptr[0]);
	InitRaster8Lib(&game->mouse.sprite);
}

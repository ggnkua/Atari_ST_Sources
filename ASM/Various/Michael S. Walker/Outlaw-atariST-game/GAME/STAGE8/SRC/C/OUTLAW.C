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

#include <OUTLAW.H>
#include <INPUT.H>
#include <MODEL.H>
#include <EVENTS.H>
#include <RENDERER.H>
#include <SYSCALLS.H>
#include <SCREEN.H>
#include <UTIL.H>
#include <PSG.H>
#include <MUSIC.H>
#include <INIT.H>
#include <RASTER.H>
#include <unistd.h> /* for sleep */
#include <BITMAP/SPL_SCRN.C>
#include <BITMAP/MENU.C>

int main(int argc, char *argv[])
{
	Game game;
	long old_ssp;
	int i, n, read_char, flag_music_on, player_mode_flag;
	uint32_t time_then, time_now, time_elapsed, music_time_then, music_time_now, music_time_elapsed;

	old_ssp = MySuper(0); /* enter privileged mode */

	ScrInit(&game.screen);
	LoadMenu(&game);
	LoadSplash(&game);
	RenderSplash(&game, game.screen.next_buffer);
	sleep(2);

	player_mode_flag = -1;
	RenderMenu(&game, game.screen.next_buffer);
	while (read_char < 0) /* menu loop */
	{
		if (CheckInputStatus() < 0) /* check ikbd codes */
		{
			read_char = ReadCharNoEcho();
			switch (read_char)
			{
			case UP: /* (KEY W) Or mouse one player game */
				player_mode_flag = 1;
				break;
			case DOWN: /* (KEY S) Or mouse two player game */
				player_mode_flag = 2;
				break;
			}
		}
		RenderMenu(&game, game.screen.next_buffer);
	}

	InitGame(&game);
	Render(&game, game.screen.next_buffer);

	music_time_now = time_now = GetTime();
	time_then = time_now;

	flag_music_on = 1;
	if (flag_music_on) /* For (POSSIBLE) menu selection in future */
	{
		music_time_then = music_time_now;
		StartMusic();
	}

	read_char = -1;
	while (read_char != 27) /* main game loop */
	{
		music_time_now = time_now = GetTime();
		time_elapsed = time_now - time_then;

		if (flag_music_on)
		{
			music_time_elapsed = music_time_now - music_time_then;

			UpdateMusic(music_time_elapsed);

			if (music_time_elapsed >= 20)
				music_time_then = music_time_now;
		}

		/* Player 1 wins */

		if (EventWin(game.gun_slinger[PLAYER_ONE]))
		{
			RenderWin(&game.screen, game.screen.next_buffer, 1);
			InitGame(&game);
			Render(&game, game.screen.next_buffer);
		}

		/* Player 2 wins */

		if (EventWin(game.gun_slinger[PLAYER_TWO]))
		{
			RenderWin(&game.screen, game.screen.next_buffer, 2);
			InitGame(&game);
			Render(&game, game.screen.next_buffer);
		}

		if (CheckInputStatus() < 0) /* check ikbd codes */
		{
			read_char = ReadCharNoEcho();
			switch (read_char)
			{
			case 119: /* w up */
				EventWalk(UP, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 115: /* s down */
				EventWalk(DOWN, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 97: /* a BACK */
				EventWalk(BACK, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 100: /* d FORWARD */
				EventWalk(FORWARD, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 54: /* NUMPAD 6 SHOOT STRAIGHT */
				EventShoot(STRAIGHT, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 50: /* NUMPAD 2 SHOOT DOWN */
				EventShoot(DOWN, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 56: /* NUMPAD 8 SHOOT UP */
				EventShoot(UP, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 114: /* r RELOAD */
				EventShoot(RELOAD, &game.gun_slinger[PLAYER_ONE]);
				break;
			default:
				break;
			}
		}

		/* computer player movement */

		switch (MyRand() % 200)
		{
		case 0: /* Case UP */
			EventWalk(UP, &game.gun_slinger[PLAYER_TWO]);
			break;
		case 1: /* Case DOWN */
			EventWalk(DOWN, &game.gun_slinger[PLAYER_TWO]);
			break;
		case 2: /* case BACK */
			EventWalk(BACK, &game.gun_slinger[PLAYER_TWO]);
			break;
		case 3: /* case FORWARD */
			EventWalk(FORWARD, &game.gun_slinger[PLAYER_TWO]);
			break;
		case 4: /* case SHOOT STRAIGHT */
			EventShoot(STRAIGHT, &game.gun_slinger[PLAYER_TWO]);
			break;
		case 5: /* case SHOOT DOWN */
			EventShoot(DOWN, &game.gun_slinger[PLAYER_TWO]);
			break;
		case 6: /* case SHOOT UP */
			EventShoot(UP, &game.gun_slinger[PLAYER_TWO]);
			break;
		case 7: /* case RELOAD */
			EventShoot(RELOAD, &game.gun_slinger[PLAYER_TWO]);
			break;
		default:
			break;
		}

		/* update all bullets */
		if (time_elapsed > 3)
		{
			EventMoveBullets(&game.gun_slinger[PLAYER_ONE], &game.gun_slinger[PLAYER_TWO]);
			EventMoveBullets(&game.gun_slinger[PLAYER_TWO], &game.gun_slinger[PLAYER_ONE]);
		}

		/* check if player 2 is dead and update score */

		if (EventPlayerDead(&game.gun_slinger[PLAYER_TWO]))
		{
			game.gun_slinger[PLAYER_TWO].flag_alive = ALIVE;
			EventUpdateScore(&game.gun_slinger[PLAYER_ONE]);
		}

		/* check if player 1 is dead and update score */

		if (EventPlayerDead(&game.gun_slinger[PLAYER_ONE]))
		{
			game.gun_slinger[PLAYER_ONE].flag_alive = ALIVE;
			EventUpdateScore(&game.gun_slinger[PLAYER_TWO]);
		}

		Render(&game, game.screen.next_buffer); /* render the frame */
		time_then = time_now;
	}

	ScrCleanup(&game.screen);
	MySuper(old_ssp); /* exit privileged mode */

	return 0;
}

/*-------------------------------------------- GetTime -----
|  Function GetTime
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

uint32_t GetTime(void)
{
	long time_now;
	long *timer = (long *)0x462; /* address of longword auto-inc’ed 70 x per s */

	time_now = *timer;

	return time_now;
}

/*-------------------------------------------- LoadSplash -----
|  Function LoadSplash
|
|  Purpose: Load the intro screen
|
|  Parameters: game
|
|  Returns:
*-------------------------------------------------------------------*/

void LoadSplash(Game *game)
{
	game->splash.sprite.bitmap.current_image = splscrn;
	game->splash.sprite.bitmap.raster.Draw = PrintScreen;
	game->splash.sprite.bitmap.height = (sizeof(splscrn) / (sizeof splscrn[0]));
}

/*-------------------------------------------- LoadMenu -----
|  Function LoadMenu
|
|  Purpose: Load the menu screen
|
|  Parameters: game
|
|  Returns:
*-------------------------------------------------------------------*/

void LoadMenu(Game *game)
{
	game->menu.sprite.bitmap.current_image = menu;
	game->menu.sprite.bitmap.raster.Draw = PrintScreen;
	game->menu.sprite.bitmap.height = (sizeof(menu) / (sizeof menu[0]));
}

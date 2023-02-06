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
#include <ISR.H>
#include <VBL.H>
#include <BITMAP/SPL_SCRN.C>
#include <BITMAP/MENU.C>

#include <osbind.h>

int main()
{
	Game game;
	SCANCODE read_char;
	uint32_t time_then, time_now, time_elapsed, music_time_then, music_time_now, music_time_elapsed;
	Vector hbl_orig_vector, vbl_orig_vector, ikbd_orig_vector;
	int i, n, flag_music_on, player_mode_flag;

	long old_ssp = Super(0);
	InstallMfp();									  /* Set up MFP */
	ikbd_orig_vector = InstallVector(IKBD_ISR, Ikbd); /* install IKBD vector */
	vbl_orig_vector = InstallVector(VBL_ISR, Vbl);	/* install VBL vector */
	hbl_orig_vector = InstallVector(HBL_ISR, Hbl);	/* install HBL vector */
	FlushIKBD();									  /* flush the keyboard */
	FifoInit();										  /* init circular keyboard buffer */
	ResetVblankFlag();								  /* reset VBL flag for MyVsync() */
	ScrInit(&game.screen);							  /* initialize frame buffers */
	ResetTicks();									  /* reset vblank timer */
	ResetSeconds();									  /* reset seconds timer */
	LoadMenu(&game);								  /* load game menu */
	LoadSplash(&game);								  /* load game splash screen */
	InitMouse(&game);								  /* init mouse */

	RenderSplash(&game, game.screen.next_buffer);
	MySleep(4);

	game.num_players = -1;
	RenderMenu(&game, game.screen.next_buffer);

	while (game.num_players == -1) /* menu loop */
	{
		EventUpdateMouse(&game.mouse);
		EventMenuClick(&game);
		RenderMenu(&game, game.screen.next_buffer);
	}

	MouseOff();		 /* disable the mouse */
	InitGame(&game); /* initialize main game loop */
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
	while (read_char != ALPHA_Q) /* main game loop */
	{
		music_time_now = time_now = GetTime();
		time_elapsed = time_now - time_then;

		if (flag_music_on)
		{
			music_time_elapsed = music_time_now - music_time_then;

			UpdateMusic(music_time_elapsed);

			if (music_time_elapsed >= 15)
				music_time_then = music_time_now;
		}

		/* Player 1 wins */

		if (EventWin(game.gun_slinger[PLAYER_ONE]))
		{
			RenderWin(&game.screen, game.screen.next_buffer, 1);
			MySleep(5);
			InitGame(&game);
			Render(&game, game.screen.next_buffer);
		}

		/* Player 2 wins */

		if (EventWin(game.gun_slinger[PLAYER_TWO]))
		{
			RenderWin(&game.screen, game.screen.next_buffer, 2);
			MySleep(5);
			InitGame(&game);
			Render(&game, game.screen.next_buffer);
		}

		if (CheckInputStatus() < 0) /* check ikbd codes */
		{
			read_char = ReadCharNoEcho();
			switch (read_char)
			{
			case ALPHA_W: /* w up */
				EventWalk(UP, &game.gun_slinger[PLAYER_ONE]);
				break;
			case ALPHA_S: /* s down */
				EventWalk(DOWN, &game.gun_slinger[PLAYER_ONE]);
				break;
			case ALPHA_A: /* a BACK */
				EventWalk(BACK, &game.gun_slinger[PLAYER_ONE]);
				break;
			case ALPHA_D: /* d FORWARD */
				EventWalk(FORWARD, &game.gun_slinger[PLAYER_ONE]);
				break;
			case NUM_PAD_6: /* NUMPAD 6 SHOOT STRAIGHT */
				EventShoot(STRAIGHT, &game.gun_slinger[PLAYER_ONE]);
				break;
			case NUM_PAD_2: /* NUMPAD 2 SHOOT DOWN */
				EventShoot(DOWN, &game.gun_slinger[PLAYER_ONE]);
				break;
			case NUM_PAD_8: /* NUMPAD 8 SHOOT UP */
				EventShoot(UP, &game.gun_slinger[PLAYER_ONE]);
				break;
			case ALPHA_R: /* r RELOAD */
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

	StopSound();							   /* stop all game sound */
	ScrCleanup(&game.screen);				   /* restore original frame buffer */
	FlushIKBD();							   /* flush the keyboard */
	MouseOn();								   /* re enable the mouse */
	InstallVector(IKBD_ISR, ikbd_orig_vector); /* install old IKBD vector */
	InstallVector(VBL_ISR, vbl_orig_vector);   /* install old ISR vector */
	InstallVector(HBL_ISR, hbl_orig_vector);   /* install old HBL vector */

	Super(old_ssp); /* exit privileged mode */

	return 0;
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

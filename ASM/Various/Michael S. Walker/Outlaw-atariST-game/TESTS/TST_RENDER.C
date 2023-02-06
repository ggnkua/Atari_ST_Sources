#include <MODEL.H>
#include <EVENTS.H>
#include <RASTER.H>
#include <osbind.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	int i, n;
	Game game;
	int read_char = -1;
	void *base = Physbase();
	MDLInitGameStates(&game);
	ClearScreen(base);

	while (read_char != 27)
	{
		/* EventMoveBullets(&game.gun_slinger[PLAYER_ONE], &game.gun_slinger[PLAYER_TWO]); */
		if (Cconis() < 0) /* check ikbd codes */
		{
			read_char = Cnecin();
			switch (read_char)
			{
			case 119: /* w up */
				game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_ONE].sprite);
				EventWalk(UP, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 115: /* s down */
				game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_ONE].sprite);
				EventWalk(DOWN, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 97: /* a left */
				game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_ONE].sprite);
				EventWalk(BACK, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 100: /* d right */
				game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_ONE].sprite);
				EventWalk(FORWARD, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 54: /* NUMPAD 6 shoot forward */
				game.gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].cylinder.sprite);
				game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_ONE].sprite);
				EventShoot(STRAIGHT, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 50: /* NUMPAD 2 shoot down */
				game.gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].cylinder.sprite);
				game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_ONE].sprite);
				EventShoot(DOWN, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 56: /* NUMPAD 8 shoot up */
				game.gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].cylinder.sprite);
				game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_ONE].sprite);
				EventShoot(UP, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 114: /* r RELOAD */
				game.gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].cylinder.sprite);
				EventShoot(RELOAD, &game.gun_slinger[PLAYER_ONE]);
				break;
			default:
				break;
			}
		}

		/* enemy player movement */
		switch (rand() % 2500)
		{
		case 0:
			game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_TWO].sprite);
			EventWalk(UP, &game.gun_slinger[PLAYER_TWO]);
			break;

		case 1:
			game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_TWO].sprite);
			EventWalk(DOWN, &game.gun_slinger[PLAYER_TWO]);
			break;

		case 2:
			game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_TWO].sprite);
			EventWalk(BACK, &game.gun_slinger[PLAYER_TWO]);
			break;

		case 3:
			game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_TWO].sprite);
			EventWalk(FORWARD, &game.gun_slinger[PLAYER_TWO]);
			break;

		case 4:
			game.gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].cylinder.sprite);
			game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_TWO].sprite);
			EventShoot(STRAIGHT, &game.gun_slinger[PLAYER_TWO]);
			break;

		case 5:
			game.gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].cylinder.sprite);
			game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_TWO].sprite);
			EventShoot(UP, &game.gun_slinger[PLAYER_TWO]);
			break;

		case 6:
			game.gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].cylinder.sprite);
			game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_TWO].sprite);
			EventShoot(DOWN, &game.gun_slinger[PLAYER_TWO]);
			break;

		case 7:
			game.gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].cylinder.sprite);
			EventShoot(RELOAD, &game.gun_slinger[PLAYER_TWO]);
			break;
		default:
			break;
		}

		/*
		CLEAR BULLETS 
		for (i = 0; i < NUM_ROUNDS; i++)
			if (game.gun_slinger[PLAYER_ONE].bullet[i].flag == ON)
				game.gun_slinger[PLAYER_ONE].bullet[i].sprite.bitmap.raster.Alpha(base, &game.gun_slinger[PLAYER_ONE].bullet[i].sprite);
		*/

		/* Check if player 2 is dead and update score */

		if (EventPlayerDead(&game.gun_slinger[PLAYER_TWO]))
		{
			game.gun_slinger[PLAYER_TWO].flag_alive = ALIVE;
			game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].sprite);
			EventUpdateScore(&game.gun_slinger[PLAYER_ONE]);
		}

		if (EventPlayerDead(&game.gun_slinger[PLAYER_ONE]))
		{
			game.gun_slinger[PLAYER_ONE].flag_alive = ALIVE;
			game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].sprite);
			EventUpdateScore(&game.gun_slinger[PLAYER_TWO]);
		}

		EventMoveBullets(&game.gun_slinger[PLAYER_ONE], &game.gun_slinger[PLAYER_TWO]);
		EventMoveBullets(&game.gun_slinger[PLAYER_TWO], &game.gun_slinger[PLAYER_ONE]);

		/*
		PlotChar(base, 80, 16, '0');
		PlotChar(base, 88, 16, '0');

		PlotChar(base, 548, 16, '0');
		PlotChar(base, 552, 16, '0');
		*/

		Render(&game, base);
	}
	return 0;
}

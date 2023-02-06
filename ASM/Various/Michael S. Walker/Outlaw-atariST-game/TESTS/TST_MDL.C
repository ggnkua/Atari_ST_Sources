#include <MODEL.H>
#include <EVENTS.H>
#include <RASTER.H>

#define TEST 1

#if TEST == 1
#include <stdio.h>
#endif

#include <osbind.h>

int main(int argc, char *argv[])
{
	Game game;

	int read_char = -1;
	void *base = Physbase();

	MDLInitGunSlinger(&game);
	while (read_char != 27)
	{
		EventMoveBullets(&game.gun_slinger[PLAYER_ONE], &game.gun_slinger[PLAYER_TWO]);

		if (Cconis() < 0)
		{
			read_char = Cnecin();
			switch (read_char)
			{
			case 119: /* w up */
				EventWalk(UP, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 115: /* s down */
				EventWalk(DOWN, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 97: /* a left */
				EventWalk(LEFT, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 100: /* d right */
				EventWalk(RIGHT, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 54: /* NUMPAD 6 shoot forward */
				EventShoot(STRAIGHT, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 50: /* NUMPAD 2 shoot down */
				EventShoot(DOWN, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 56: /* NUMPAD 8 shoot up */
				EventShoot(UP, &game.gun_slinger[PLAYER_ONE]);
				break;
			case 114: /* r RELOAD */
				EventShoot(RELOAD, &game.gun_slinger[PLAYER_ONE]);
				break;
			default:
#if TEST == 1
				printf("CODE: %d\n", read_char);
#endif
				break;
			}
		}
	}

	return 0;
}

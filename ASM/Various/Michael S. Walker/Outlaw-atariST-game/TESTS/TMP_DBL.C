#include <OUTLAW.H>
#include <INPUT.H>
#include <MODEL.H>
#include <EVENTS.H>
#include <RASTER.H>
#include <RENDERER.H>
#include <SYSCALLS.H>
#include <SCREEN.H>
#include <UTIL.H>
#include <PSG.H>
#include <MUSIC.H>

#include <BITMAP/SCREEN.C>
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

int main(int argc, char *argv[])
{
	Game game;
	long old_ssp;
	int i, n, read_char, flag_music_on, tmp_x, tmp_y;
	uint32_t time_then, time_now, time_elapsed, music_time_then, music_time_now, music_time_elapsed;

	old_ssp = MySuper(0); /* enter privileged mode */
	ScrInit(&game.screen);
	InitGame(&game);
	Render(&game, game.screen.next_buffer);
	InitGame(&game);
	Render(&game, game.screen.next_buffer);

	music_time_now = time_now = GetTime();
	time_then = time_now;

	flag_music_on = 1;
	if (flag_music_on) /* For menu selection later */
	{
		music_time_then = music_time_now;
		StartMusic();
	}

	game.gun_slinger[PLAYER_ONE].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].sprite.x_pos;
	game.gun_slinger[PLAYER_ONE].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].sprite.y_pos;

	game.gun_slinger[PLAYER_TWO].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].sprite.x_pos;
	game.gun_slinger[PLAYER_TWO].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].sprite.y_pos;

	read_char = -1;
	while (read_char != 27)
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

		if (time_elapsed > 4)
		{
			if (CheckInputStatus() < 0) /* check ikbd codes */
			{
				read_char = ReadCharNoEcho();
				switch (read_char)
				{
				case 119: /* w up */
					printf("game.screen.current_fb_index: %d\n", game.screen.current_fb_index);

					tmp_x = game.gun_slinger[PLAYER_ONE].sprite.x_pos;
					tmp_y = game.gun_slinger[PLAYER_ONE].sprite.y_pos;
					game.gun_slinger[PLAYER_ONE].sprite.x_pos = game.gun_slinger[PLAYER_ONE].sprite.last_x[game.screen.current_fb_index];
					game.gun_slinger[PLAYER_ONE].sprite.y_pos = game.gun_slinger[PLAYER_ONE].sprite.last_y[game.screen.current_fb_index];
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_ONE].sprite);

					game.gun_slinger[PLAYER_ONE].sprite.x_pos = tmp_x;
					game.gun_slinger[PLAYER_ONE].sprite.y_pos = tmp_y;

					EventWalk(UP, &game.gun_slinger[PLAYER_ONE]);

					game.gun_slinger[PLAYER_ONE].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].sprite.x_pos;
					game.gun_slinger[PLAYER_ONE].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].sprite.y_pos;
					break;
				case 115: /* s down */
					tmp_x = game.gun_slinger[PLAYER_ONE].sprite.x_pos;
					tmp_y = game.gun_slinger[PLAYER_ONE].sprite.y_pos;
					game.gun_slinger[PLAYER_ONE].sprite.x_pos = game.gun_slinger[PLAYER_ONE].sprite.last_x[game.screen.current_fb_index];
					game.gun_slinger[PLAYER_ONE].sprite.y_pos = game.gun_slinger[PLAYER_ONE].sprite.last_y[game.screen.current_fb_index];
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_ONE].sprite);

					game.gun_slinger[PLAYER_ONE].sprite.x_pos = tmp_x;
					game.gun_slinger[PLAYER_ONE].sprite.y_pos = tmp_y;

					EventWalk(DOWN, &game.gun_slinger[PLAYER_ONE]);

					game.gun_slinger[PLAYER_ONE].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].sprite.x_pos;
					game.gun_slinger[PLAYER_ONE].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].sprite.y_pos;
					break;
				case 97: /* a BACK */
					tmp_x = game.gun_slinger[PLAYER_ONE].sprite.x_pos;
					tmp_y = game.gun_slinger[PLAYER_ONE].sprite.y_pos;
					game.gun_slinger[PLAYER_ONE].sprite.x_pos = game.gun_slinger[PLAYER_ONE].sprite.last_x[game.screen.current_fb_index];
					game.gun_slinger[PLAYER_ONE].sprite.y_pos = game.gun_slinger[PLAYER_ONE].sprite.last_y[game.screen.current_fb_index];
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_ONE].sprite);

					game.gun_slinger[PLAYER_ONE].sprite.x_pos = tmp_x;
					game.gun_slinger[PLAYER_ONE].sprite.y_pos = tmp_y;

					EventWalk(BACK, &game.gun_slinger[PLAYER_ONE]);

					game.gun_slinger[PLAYER_ONE].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].sprite.x_pos;
					game.gun_slinger[PLAYER_ONE].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].sprite.y_pos;
					break;
				case 100: /* d FORWARD */
					tmp_x = game.gun_slinger[PLAYER_ONE].sprite.x_pos;
					tmp_y = game.gun_slinger[PLAYER_ONE].sprite.y_pos;
					game.gun_slinger[PLAYER_ONE].sprite.x_pos = game.gun_slinger[PLAYER_ONE].sprite.last_x[game.screen.current_fb_index];
					game.gun_slinger[PLAYER_ONE].sprite.y_pos = game.gun_slinger[PLAYER_ONE].sprite.last_y[game.screen.current_fb_index];
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_ONE].sprite);

					game.gun_slinger[PLAYER_ONE].sprite.x_pos = tmp_x;
					game.gun_slinger[PLAYER_ONE].sprite.y_pos = tmp_y;

					EventWalk(FORWARD, &game.gun_slinger[PLAYER_ONE]);

					game.gun_slinger[PLAYER_ONE].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].sprite.x_pos;
					game.gun_slinger[PLAYER_ONE].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].sprite.y_pos;
					break;
				case 54: /* NUMPAD 6 SHOOT STRAIGHT */
					EventShoot(STRAIGHT, &game.gun_slinger[PLAYER_ONE]);
					game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.last_x[game.screen.current_fb_index] =
						game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.x_pos;

					game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.last_y[game.screen.current_fb_index] =
						game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.y_pos;
					break;
				case 50: /* NUMPAD 2 SHOOT DOWN */
					EventShoot(DOWN, &game.gun_slinger[PLAYER_ONE]);
					game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.last_x[game.screen.current_fb_index] =
						game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.x_pos;

					game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.last_y[game.screen.current_fb_index] =
						game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.y_pos;
					break;
				case 56: /* NUMPAD 8 SHOOT UP */
					EventShoot(UP, &game.gun_slinger[PLAYER_ONE]);
					game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.last_x[game.screen.current_fb_index] =
						game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.x_pos;

					game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.last_y[game.screen.current_fb_index] =
						game.gun_slinger[PLAYER_ONE].bullet[game.gun_slinger[PLAYER_ONE].current_bullet].sprite.y_pos;
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
				tmp_x = game.gun_slinger[PLAYER_TWO].sprite.x_pos;
				tmp_y = game.gun_slinger[PLAYER_TWO].sprite.y_pos;
				game.gun_slinger[PLAYER_TWO].sprite.x_pos = game.gun_slinger[PLAYER_TWO].sprite.last_x[game.screen.current_fb_index];
				game.gun_slinger[PLAYER_TWO].sprite.y_pos = game.gun_slinger[PLAYER_TWO].sprite.last_y[game.screen.current_fb_index];
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_TWO].sprite);

				game.gun_slinger[PLAYER_TWO].sprite.x_pos = tmp_x;
				game.gun_slinger[PLAYER_TWO].sprite.y_pos = tmp_y;

				EventWalk(UP, &game.gun_slinger[PLAYER_TWO]);

				game.gun_slinger[PLAYER_TWO].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].sprite.x_pos;
				game.gun_slinger[PLAYER_TWO].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].sprite.y_pos;
				break;
			case 1: /* Case DOWN */
				tmp_x = game.gun_slinger[PLAYER_TWO].sprite.x_pos;
				tmp_y = game.gun_slinger[PLAYER_TWO].sprite.y_pos;
				game.gun_slinger[PLAYER_TWO].sprite.x_pos = game.gun_slinger[PLAYER_TWO].sprite.last_x[game.screen.current_fb_index];
				game.gun_slinger[PLAYER_TWO].sprite.y_pos = game.gun_slinger[PLAYER_TWO].sprite.last_y[game.screen.current_fb_index];
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_TWO].sprite);

				game.gun_slinger[PLAYER_TWO].sprite.x_pos = tmp_x;
				game.gun_slinger[PLAYER_TWO].sprite.y_pos = tmp_y;

				EventWalk(DOWN, &game.gun_slinger[PLAYER_TWO]);

				game.gun_slinger[PLAYER_TWO].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].sprite.x_pos;
				game.gun_slinger[PLAYER_TWO].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].sprite.y_pos;
				break;
			case 2: /* case BACK */
				tmp_x = game.gun_slinger[PLAYER_TWO].sprite.x_pos;
				tmp_y = game.gun_slinger[PLAYER_TWO].sprite.y_pos;
				game.gun_slinger[PLAYER_TWO].sprite.x_pos = game.gun_slinger[PLAYER_TWO].sprite.last_x[game.screen.current_fb_index];
				game.gun_slinger[PLAYER_TWO].sprite.y_pos = game.gun_slinger[PLAYER_TWO].sprite.last_y[game.screen.current_fb_index];
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_TWO].sprite);

				game.gun_slinger[PLAYER_TWO].sprite.x_pos = tmp_x;
				game.gun_slinger[PLAYER_TWO].sprite.y_pos = tmp_y;

				EventWalk(BACK, &game.gun_slinger[PLAYER_TWO]);

				game.gun_slinger[PLAYER_TWO].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].sprite.x_pos;
				game.gun_slinger[PLAYER_TWO].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].sprite.y_pos;
				break;
			case 3: /* case FORWARD */
				tmp_x = game.gun_slinger[PLAYER_TWO].sprite.x_pos;
				tmp_y = game.gun_slinger[PLAYER_TWO].sprite.y_pos;
				game.gun_slinger[PLAYER_TWO].sprite.x_pos = game.gun_slinger[PLAYER_TWO].sprite.last_x[game.screen.current_fb_index];
				game.gun_slinger[PLAYER_TWO].sprite.y_pos = game.gun_slinger[PLAYER_TWO].sprite.last_y[game.screen.current_fb_index];
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_TWO].sprite);

				game.gun_slinger[PLAYER_TWO].sprite.x_pos = tmp_x;
				game.gun_slinger[PLAYER_TWO].sprite.y_pos = tmp_y;

				EventWalk(FORWARD, &game.gun_slinger[PLAYER_TWO]);

				game.gun_slinger[PLAYER_TWO].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].sprite.x_pos;
				game.gun_slinger[PLAYER_TWO].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].sprite.y_pos;
				break;
			case 4: /* case SHOOT STRAIGHT */
				EventShoot(STRAIGHT, &game.gun_slinger[PLAYER_TWO]);
				game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.last_x[game.screen.current_fb_index] =
					game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.x_pos;

				game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.last_y[game.screen.current_fb_index] =
					game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.y_pos;
				break;
			case 5: /* case SHOOT DOWN */
				EventShoot(DOWN, &game.gun_slinger[PLAYER_TWO]);
				game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.last_x[game.screen.current_fb_index] =
					game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.x_pos;

				game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.last_y[game.screen.current_fb_index] =
					game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.y_pos;
				break;
			case 6: /* case SHOOT UP */
				EventShoot(UP, &game.gun_slinger[PLAYER_TWO]);
				game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.last_x[game.screen.current_fb_index] =
					game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.x_pos;

				game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.last_y[game.screen.current_fb_index] =
					game.gun_slinger[PLAYER_TWO].bullet[game.gun_slinger[PLAYER_TWO].current_bullet].sprite.y_pos;
				break;
			case 7: /* case RELOAD */
				EventShoot(RELOAD, &game.gun_slinger[PLAYER_TWO]);
				break;
			default:
				break;
			}

			/* check if player 2 is dead and update score */

			if (EventPlayerDead(&game.gun_slinger[PLAYER_TWO]))
			{
				game.gun_slinger[PLAYER_TWO].flag_alive = ALIVE;
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_TWO].sprite);
				EventUpdateScore(&game.gun_slinger[PLAYER_ONE]);
			}

			/* check if player 1 is dead and update score */

			if (EventPlayerDead(&game.gun_slinger[PLAYER_ONE]))
			{
				game.gun_slinger[PLAYER_ONE].flag_alive = ALIVE;
				game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_ONE].sprite);
				EventUpdateScore(&game.gun_slinger[PLAYER_TWO]);
			}

			/* clear all bullets */

			for (i = 0; i <= NUM_ROUNDS; i++)
			{
				if (game.gun_slinger[PLAYER_ONE].bullet[i].flag == ON)
				{
					tmp_x = game.gun_slinger[PLAYER_ONE].bullet[i].sprite.x_pos;
					tmp_y = game.gun_slinger[PLAYER_ONE].bullet[i].sprite.y_pos;

					game.gun_slinger[PLAYER_ONE].bullet[i].sprite.x_pos = game.gun_slinger[PLAYER_ONE].bullet[i].sprite.last_x[game.screen.current_fb_index];
					game.gun_slinger[PLAYER_ONE].bullet[i].sprite.y_pos = game.gun_slinger[PLAYER_ONE].bullet[i].sprite.last_y[game.screen.current_fb_index];

					game.gun_slinger[PLAYER_ONE].bullet[i].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_ONE].bullet[i].sprite);
					game.gun_slinger[PLAYER_ONE].bullet[i].sprite.x_pos = tmp_x;
					game.gun_slinger[PLAYER_ONE].bullet[i].sprite.y_pos = tmp_y;
				}
				if (game.gun_slinger[PLAYER_TWO].bullet[i].flag == ON)
				{
					tmp_x = game.gun_slinger[PLAYER_TWO].bullet[i].sprite.x_pos;
					tmp_y = game.gun_slinger[PLAYER_TWO].bullet[i].sprite.y_pos;

					game.gun_slinger[PLAYER_TWO].bullet[i].sprite.x_pos = game.gun_slinger[PLAYER_TWO].bullet[i].sprite.last_x[game.screen.current_fb_index];
					game.gun_slinger[PLAYER_TWO].bullet[i].sprite.y_pos = game.gun_slinger[PLAYER_TWO].bullet[i].sprite.last_y[game.screen.current_fb_index];

					game.gun_slinger[PLAYER_TWO].bullet[i].sprite.bitmap.raster.Clear(game.screen.next_buffer, &game.gun_slinger[PLAYER_TWO].bullet[i].sprite);
					game.gun_slinger[PLAYER_TWO].bullet[i].sprite.x_pos = tmp_x;
					game.gun_slinger[PLAYER_TWO].bullet[i].sprite.y_pos = tmp_y;
				}
			}

			/* update all bullets */

			EventMoveBullets(&game.gun_slinger[PLAYER_ONE], &game.gun_slinger[PLAYER_TWO]);
			EventMoveBullets(&game.gun_slinger[PLAYER_TWO], &game.gun_slinger[PLAYER_ONE]);

			for (i = 0; i <= NUM_ROUNDS; i++)
			{
				if (game.gun_slinger[PLAYER_ONE].bullet[i].flag == ON)
				{
					game.gun_slinger[PLAYER_ONE].bullet[i].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].bullet[i].sprite.x_pos;
					game.gun_slinger[PLAYER_ONE].bullet[i].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_ONE].bullet[i].sprite.y_pos;
				}

				if (game.gun_slinger[PLAYER_TWO].bullet[i].flag == ON)
				{
					game.gun_slinger[PLAYER_TWO].bullet[i].sprite.last_x[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].bullet[i].sprite.x_pos;
					game.gun_slinger[PLAYER_TWO].bullet[i].sprite.last_y[game.screen.current_fb_index] = game.gun_slinger[PLAYER_TWO].bullet[i].sprite.y_pos;
				}
			}

			Render(&game, game.screen.next_buffer);
			time_then = time_now;
		}
	}
	ScrCleanup(&game.screen);
	MySuper(old_ssp); /* exit privileged mode */
	return 0;
}

uint32_t GetTime(void)
{
	long time_now;
	long *timer = (long *)0x462; /* address of longword auto-inc’ed 70 x per s */

	time_now = *timer;

	return time_now;
}

void InitGame(Game *game)
{
	InitGameBackGround(game);
	InitBullets(game);
	InitScore(game);
	InitP1(&game->gun_slinger[PLAYER_ONE], game->screen.current_fb_index);
	InitP2(&game->gun_slinger[PLAYER_TWO], game->screen.current_fb_index);
}

void InitP1(GunSlinger *gs, int current_frame)
{
	InitP1States(gs);
	InitStartLocation(gs, P1_START_X, P1_START_Y, STANDARD, current_frame);
	InitCylinder(&gs->cylinder, CYL_P1_X_LOC, CYL_P1_Y_LOC);
	EventShoot(RELOAD, gs);
}

void InitP2(GunSlinger *gs, int current_frame)
{
	InitP2States(gs);
	InitStartLocation(gs, P2_START_X, P2_START_Y, INVERTED, current_frame);
	InitCylinder(&gs->cylinder, CYL_P2_X_LOC, CYL_P2_Y_LOC);
	EventShoot(RELOAD, gs);
}

void InitGameBackGround(Game *game)
{
	/* INIT SCREEN STATES */
	game->background.sprite.bitmap.current_image = screen;
	game->background.sprite.bitmap.raster.Draw = PrintScreen;
	game->background.sprite.bitmap.height = (sizeof(screen) / (sizeof screen[0]));

	game->background.sprite.render_flag = ON;
}

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

void InitScore(Game *game)
{
	/* initialize score to zero */

	game->gun_slinger[PLAYER_ONE].score.msd =
		game->gun_slinger[PLAYER_ONE].score.lsd =
			game->gun_slinger[PLAYER_TWO].score.msd =
				game->gun_slinger[PLAYER_TWO].score.lsd = 48; /* 48 base 10 is the character '0' */

	game->gun_slinger[PLAYER_ONE].score.sprite.render_flag = ON;
	game->gun_slinger[PLAYER_TWO].score.sprite.render_flag = ON;
}

void InitP1States(GunSlinger *gs)
{
	gs->sprite.bitmap.stored_images[STATE_DEAD] = p1_dead;
	gs->sprite.bitmap.stored_images[STATE_NORM] = p1_normal;
	gs->sprite.bitmap.stored_images[STATE_SHOOT] = p1_shoot;
	gs->sprite.bitmap.stored_images[STATE_SHOOT_UP] = p1_shoot_up;
	gs->sprite.bitmap.stored_images[STATE_SHOOT_DOWN] = p1_shoot_down;
	gs->sprite.bitmap.stored_images[STATE_WALK] = p1_walk;

	gs->player_state = STATE_NORM;
	gs->sprite.render_flag = ON;

	InitRaster32Lib(&gs->sprite);
}

void InitP2States(GunSlinger *gs)
{
	gs->sprite.bitmap.stored_images[STATE_DEAD] = p2_dead;
	gs->sprite.bitmap.stored_images[STATE_NORM] = p2_normal;
	gs->sprite.bitmap.stored_images[STATE_SHOOT] = p2_shoot;
	gs->sprite.bitmap.stored_images[STATE_SHOOT_UP] = p2_shoot_down;
	gs->sprite.bitmap.stored_images[STATE_SHOOT_DOWN] = p2_shoot_up;
	gs->sprite.bitmap.stored_images[STATE_WALK] = p2_walk;

	gs->player_state = STATE_NORM;
	gs->sprite.render_flag = ON;

	InitRaster32Lib(&gs->sprite);
}

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

	gs->sprite.last_x[current_frame] = gs->sprite.x_pos;
	gs->sprite.last_y[current_frame] = gs->sprite.y_pos;
}

void InitRaster8Lib(Sprite *sp)
{
	sp->bitmap.raster.Alpha = Rast8Alpha;
	sp->bitmap.raster.Clear = Rast8Clear;
	sp->bitmap.raster.Draw = Rast8Draw;
}

void InitRaster32Lib(Sprite *sp)
{
	sp->bitmap.raster.Alpha = Rast32Alpha;
	sp->bitmap.raster.Clear = Rast32Clear;
	sp->bitmap.raster.Draw = Rast32Draw;
}

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

	cyl->sprite.render_flag = ON;
}

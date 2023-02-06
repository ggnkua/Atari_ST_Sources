#include <OUTLAW.H>
#include <INPUT.H> 
#include <MODEL.H>
#include <EVENTS.H>
#include <RASTER.H>
#include <RENDERER.H>

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

#include <osbind.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	int i, n;
	uint32_t time_then, time_now, time_elapsed; 
	Game game;
	int read_char = -1;
	void *base = Physbase();

	InitGame(&game);
	ClearScreen(base);

	EventShoot(RELOAD, &game.gun_slinger[PLAYER_ONE]); /* magic */ 
	
	while (read_char != 27)
	{
		time_now = GetTime();
		time_elapsed = time_now - time_then;
		
		if (time_elapsed > 5) 
		{
			if (CheckInputStatus() < 0) /* check ikbd codes */
			{
				read_char = ReadCharNoEcho();
				switch (read_char)
				{
				case 119: /* w up */
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].sprite);
					EventWalk(UP, &game.gun_slinger[PLAYER_ONE]);
					break;
				case 115: /* s down */
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].sprite);
					EventWalk(DOWN, &game.gun_slinger[PLAYER_ONE]);
					break;
				case 97: /* a left */
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].sprite);
					EventWalk(BACK, &game.gun_slinger[PLAYER_ONE]);
					break;
				case 100: /* d right */
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].sprite);
					EventWalk(FORWARD, &game.gun_slinger[PLAYER_ONE]);
					break;
				case 54: /* NUMPAD 6 shoot forward */
					game.gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].cylinder.sprite);
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].sprite);
					EventShoot(STRAIGHT, &game.gun_slinger[PLAYER_ONE]);
					break;
				case 50: /* NUMPAD 2 shoot down */
					game.gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].cylinder.sprite);
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].sprite);
					EventShoot(DOWN, &game.gun_slinger[PLAYER_ONE]);
					break;
				case 56: /* NUMPAD 8 shoot up */
					game.gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].cylinder.sprite);
					game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].sprite);
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

			/* computer player movement */

			switch (rand() % 200)
			{
			case 0:
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].sprite);
				EventWalk(UP, &game.gun_slinger[PLAYER_TWO]);
				break;

			case 1:
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].sprite);
				EventWalk(DOWN, &game.gun_slinger[PLAYER_TWO]);
				break;

			case 2:
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].sprite);
				EventWalk(BACK, &game.gun_slinger[PLAYER_TWO]);
				break;

			case 3:
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].sprite);
				EventWalk(FORWARD, &game.gun_slinger[PLAYER_TWO]);
				break;

			case 4:
				game.gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].cylinder.sprite);
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].sprite);
				EventShoot(STRAIGHT, &game.gun_slinger[PLAYER_TWO]);
				break;

			case 5:
				game.gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].cylinder.sprite);
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].sprite);
				EventShoot(UP, &game.gun_slinger[PLAYER_TWO]);
				break;

			case 6:
				game.gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].cylinder.sprite);
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].sprite);
				EventShoot(DOWN, &game.gun_slinger[PLAYER_TWO]);
				break;

			case 7:
				game.gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].cylinder.sprite);
				EventShoot(RELOAD, &game.gun_slinger[PLAYER_TWO]);
				break;
			default:
				break;
			}

			/* check if player 2 is dead and update score */

			if (EventPlayerDead(&game.gun_slinger[PLAYER_TWO]))
			{
				game.gun_slinger[PLAYER_TWO].flag_alive = ALIVE;
				game.gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].sprite);
				EventUpdateScore(&game.gun_slinger[PLAYER_ONE]);
			}

			/* check if player 1 is dead and update score */

			if (EventPlayerDead(&game.gun_slinger[PLAYER_ONE]))
			{
				game.gun_slinger[PLAYER_ONE].flag_alive = ALIVE;
				game.gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].sprite);
				EventUpdateScore(&game.gun_slinger[PLAYER_TWO]);
			}


			for (i = 0; i <= NUM_ROUNDS; i++) {		/* clear bullets */ 
				if (game.gun_slinger[PLAYER_ONE].bullet[i].flag == ON)
					game.gun_slinger[PLAYER_ONE].bullet[i].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_ONE].bullet[i].sprite);

				if (game.gun_slinger[PLAYER_TWO].bullet[i].flag == ON)
					game.gun_slinger[PLAYER_TWO].bullet[i].sprite.bitmap.raster.Clear(base, &game.gun_slinger[PLAYER_TWO].bullet[i].sprite);
			}

			EventMoveBullets(&game.gun_slinger[PLAYER_ONE], &game.gun_slinger[PLAYER_TWO]);
			EventMoveBullets(&game.gun_slinger[PLAYER_TWO], &game.gun_slinger[PLAYER_ONE]);

			Render(&game, base);
			time_then = time_now;
		}
	}
	return 0;
}

uint32_t GetTime(void)
{
	long time_now;
	long old_ssp;
	long *timer = (long *)0x462; /* address of longword auto-inc’ed 70 x per s */
	
	old_ssp = Super(0); /* enter privileged mode */
	time_now = *timer;
	Super(old_ssp); 	/* exit privileged mode as soon as possible */

	return time_now; 
}

void InitGame(Game *game)
{ 
	InitGameBackGround(game); 
	InitBullets(game); 
	InitScore(game); 
	InitP1(&game->gun_slinger[PLAYER_ONE]); 
	InitP2(&game->gun_slinger[PLAYER_TWO]); 
}

void InitP1(GunSlinger *gs)
{
	InitP1States(gs); 
	InitStartLocation(gs, P1_START_X, P1_START_Y, STANDARD);
	InitCylinder(&gs->cylinder, CYL_P1_X_LOC, CYL_P1_Y_LOC); 
}

void InitP2(GunSlinger *gs)
{
	InitP2States(gs); 
	InitStartLocation(gs, P2_START_X, P2_START_Y, INVERTED); 
	InitCylinder(&gs->cylinder, CYL_P2_X_LOC, CYL_P2_Y_LOC); 
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

void InitStartLocation(GunSlinger *gs, int x_pos, int y_pos, int orientation)
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

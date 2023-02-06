#include <MODEL.H>
#include <RASTER.H>
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

void MDLInitGameStates(Game *game)
{
	int i;
	MDLInitGunSlinger(game);

	/* INIT SCREEN STATES */
	game->background.sprite.bitmap.current_image = screen;
	game->background.sprite.bitmap.raster.Draw = PrintScreen;
	game->background.sprite.bitmap.height = (sizeof(screen) / (sizeof screen[0]));

	/* INIT PLAYER ONE STATES */
	game->gun_slinger[PLAYER_ONE].sprite.bitmap.stored_images[STATE_DEAD] = p1_dead;
	game->gun_slinger[PLAYER_ONE].sprite.bitmap.stored_images[STATE_NORM] = p1_normal;
	game->gun_slinger[PLAYER_ONE].sprite.bitmap.stored_images[STATE_SHOOT] = p1_shoot;
	game->gun_slinger[PLAYER_ONE].sprite.bitmap.stored_images[STATE_SHOOT_UP] = p1_shoot_up;
	game->gun_slinger[PLAYER_ONE].sprite.bitmap.stored_images[STATE_SHOOT_DOWN] = p1_shoot_down;
	game->gun_slinger[PLAYER_ONE].sprite.bitmap.stored_images[STATE_WALK] = p1_walk;
	game->gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Alpha = Rast32Alpha;
	game->gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Clear = Rast32Clear;
	game->gun_slinger[PLAYER_ONE].sprite.bitmap.raster.Draw = Rast32Draw;
	game->gun_slinger[PLAYER_ONE].player_state = STATE_NORM;

	/* INIT PLAYER TWO STATES */
	game->gun_slinger[PLAYER_TWO].sprite.bitmap.stored_images[STATE_DEAD] = p2_dead;
	game->gun_slinger[PLAYER_TWO].sprite.bitmap.stored_images[STATE_NORM] = p2_normal;
	game->gun_slinger[PLAYER_TWO].sprite.bitmap.stored_images[STATE_SHOOT] = p2_shoot;
	game->gun_slinger[PLAYER_TWO].sprite.bitmap.stored_images[STATE_SHOOT_UP] = p2_shoot_down;
	game->gun_slinger[PLAYER_TWO].sprite.bitmap.stored_images[STATE_SHOOT_DOWN] = p2_shoot_up;
	game->gun_slinger[PLAYER_TWO].sprite.bitmap.stored_images[STATE_WALK] = p2_walk;
	game->gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Alpha = Rast32Alpha;
	game->gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Clear = Rast32Clear;
	game->gun_slinger[PLAYER_TWO].sprite.bitmap.raster.Draw = Rast32Draw;
	game->gun_slinger[PLAYER_TWO].player_state = STATE_NORM;

	/* INIT PLAYER ONE CYLINDERS */

	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.raster.Draw = Rast32Draw;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.raster.Alpha = Rast32Alpha;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.raster.Clear = Rast32Clear;

	game->gun_slinger[PLAYER_ONE].cylinder.sprite.x_pos = 32;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.y_pos = 32;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.x_vel = 0;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.y_vel = 0;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.height = sizeof(cylinder_0) / sizeof cylinder_0[0];

	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.stored_images[CYLINDER_ZERO] = cylinder_0;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.stored_images[CYLINDER_ONE] = cylinder_1;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.stored_images[CYLINDER_TWO] = cylinder_2;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.stored_images[CYLINDER_THREE] = cylinder_3;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.stored_images[CYLINDER_FOUR] = cylinder_4;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.stored_images[CYLINDER_FIVE] = cylinder_5;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.stored_images[CYLINDER_SIX] = cylinder_6;

	game->gun_slinger[PLAYER_ONE].cylinder.sprite.bitmap.current_image = cylinder_6;

	/* INIT PLAYER TWO CYLINDERS */

	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Draw = Rast32Draw;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Alpha = Rast32Alpha;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.raster.Clear = Rast32Clear;

	game->gun_slinger[PLAYER_TWO].cylinder.sprite.x_pos = 570;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.y_pos = 32;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.x_vel = 0;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.y_vel = 0;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.height = sizeof(cylinder_0) / sizeof cylinder_0[0];

	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.stored_images[CYLINDER_ZERO] = cylinder_0;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.stored_images[CYLINDER_ONE] = cylinder_1;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.stored_images[CYLINDER_TWO] = cylinder_2;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.stored_images[CYLINDER_THREE] = cylinder_3;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.stored_images[CYLINDER_FOUR] = cylinder_4;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.stored_images[CYLINDER_FIVE] = cylinder_5;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.stored_images[CYLINDER_SIX] = cylinder_6;

	game->gun_slinger[PLAYER_TWO].cylinder.sprite.bitmap.current_image = cylinder_6;

	game->gun_slinger[PLAYER_ONE].cylinder.state = 6;
	game->gun_slinger[PLAYER_TWO].cylinder.state = 6;

	/* INIT BULLETS */
	for (i = 0; i < NUM_ROUNDS; i++)
	{
		MDLTurnOffBullet(&game->gun_slinger[PLAYER_ONE].bullet[i]);
		game->gun_slinger[PLAYER_ONE].bullet[i].sprite.bitmap.current_image = gs_bullet;
		game->gun_slinger[PLAYER_ONE].bullet[i].sprite.bitmap.raster.Alpha = Rast8Alpha;
		game->gun_slinger[PLAYER_ONE].bullet[i].sprite.bitmap.raster.Clear = Rast8Clear;
		game->gun_slinger[PLAYER_ONE].bullet[i].sprite.bitmap.raster.Draw = Rast8Draw;
		game->gun_slinger[PLAYER_ONE].bullet[i].sprite.bitmap.height = (sizeof(gs_bullet) / (sizeof gs_bullet[0]));

		MDLTurnOffBullet(&game->gun_slinger[PLAYER_TWO].bullet[i]);
		game->gun_slinger[PLAYER_TWO].bullet[i].sprite.bitmap.current_image = gs_bullet;
		game->gun_slinger[PLAYER_TWO].bullet[i].sprite.bitmap.raster.Alpha = Rast8Alpha;
		game->gun_slinger[PLAYER_TWO].bullet[i].sprite.bitmap.raster.Clear = Rast8Clear;
		game->gun_slinger[PLAYER_TWO].bullet[i].sprite.bitmap.raster.Draw = Rast8Draw;
		game->gun_slinger[PLAYER_TWO].bullet[i].sprite.bitmap.height = (sizeof(gs_bullet) / (sizeof gs_bullet[0]));
	}

	/* initialize score to zero */

	game->gun_slinger[PLAYER_ONE].score.msd = game->gun_slinger[PLAYER_ONE].score.lsd = game->gun_slinger[PLAYER_TWO].score.msd = game->gun_slinger[PLAYER_TWO].score.lsd = 48;

	/* RENDER IMAGE FLAGS ON */

	game->background.sprite.render_flag = ON;

	game->gun_slinger[PLAYER_ONE].sprite.render_flag = ON;
	game->gun_slinger[PLAYER_ONE].cylinder.sprite.render_flag = ON;
	game->gun_slinger[PLAYER_ONE].score.sprite.render_flag = ON;

	game->gun_slinger[PLAYER_TWO].sprite.render_flag = ON;
	game->gun_slinger[PLAYER_TWO].cylinder.sprite.render_flag = ON;
	game->gun_slinger[PLAYER_TWO].score.sprite.render_flag = ON;
}

void MDLInitGunSlinger(Game *game)
{
	/* player 1 init */
	game->gun_slinger[PLAYER_ONE].sprite.x_pos = 32;
	game->gun_slinger[PLAYER_ONE].sprite.y_pos = 336;
	game->gun_slinger[PLAYER_ONE].sprite.bitmap.height = 32;
	game->gun_slinger[PLAYER_ONE].sprite.y_vel = game->gun_slinger[PLAYER_ONE].sprite.x_vel = game->gun_slinger[PLAYER_ONE].score.current_score = 0;
	game->gun_slinger[PLAYER_ONE].num_bullets = MAX_ROUNDS;
	game->gun_slinger[PLAYER_ONE].flag_alive = ALIVE;
	game->gun_slinger[PLAYER_ONE].orientation = STANDARD;

	/* player 2 init */
	game->gun_slinger[PLAYER_TWO].sprite.x_pos = 570;
	game->gun_slinger[PLAYER_TWO].sprite.y_pos = 336;
	game->gun_slinger[PLAYER_TWO].sprite.bitmap.height = 32;
	game->gun_slinger[PLAYER_TWO].sprite.y_vel = game->gun_slinger[PLAYER_TWO].sprite.x_vel = game->gun_slinger[PLAYER_TWO].score.current_score = 0;
	game->gun_slinger[PLAYER_TWO].num_bullets = MAX_ROUNDS;
	game->gun_slinger[PLAYER_TWO].flag_alive = ALIVE;
	game->gun_slinger[PLAYER_TWO].orientation = INVERTED;
}

void MDLMoveGunSlinger(GunSlinger *gs)
{
	MDLEnvGunSlingerCollision(gs);

	gs->sprite.x_pos += gs->sprite.x_vel;
	gs->sprite.y_pos += gs->sprite.y_vel;
}

void MDLEnvGunSlingerCollision(GunSlinger *gs)
{
	int x = gs->sprite.x_pos;
	int y = gs->sprite.y_pos;

	MDLPlayerCactusCollision(gs);

	if (x >= SCREEN_LEFT_EDGE)
	{
		if (x >= SCREEN_RIGHT_EDGE - sizeof(gs->sprite.bitmap.current_image))
			if (gs->sprite.x_vel == 32)
				gs->sprite.x_vel = 0;
	}
	else if (gs->sprite.x_vel == -32)
		gs->sprite.x_vel = 0;

	if (y >= SCREEN_TOP_EDGE)
	{
		if (y >= SCREEN_BOTTOM_EDGE - gs->sprite.bitmap.height)
			if (gs->sprite.y_vel == 32)
				gs->sprite.y_vel = 0;
	}
	else if (gs->sprite.y_vel == -32)
		gs->sprite.y_vel = 0;
}

void MDLFireBullet(GunSlinger *gs)
{
	if (gs->num_bullets >= 0 && gs->bullet[gs->num_bullets].flag == OFF)
	{
		gs->current_bullet = gs->num_bullets;
		gs->bullet[gs->current_bullet].flag = ON;
		gs->bullet[gs->current_bullet].sprite.x_pos = gs->sprite.x_pos + (32 * gs->orientation);
		gs->bullet[gs->current_bullet].sprite.y_pos = gs->sprite.y_pos + 16;

		gs->num_bullets--;
	}
	else
		; /* Out of ammo handle */
}

void MDLBulletReload(GunSlinger *gs)
{
	int next_bullet = (gs->num_bullets + 1);
	if (gs->num_bullets < MAX_ROUNDS && gs->bullet[next_bullet].flag == OFF)
	{
		gs->num_bullets++;
		gs->current_bullet = gs->num_bullets;
		gs->bullet[gs->current_bullet].flag = OFF; /* TODO: test redundancy */
	}
	else
		; /* to much ammo handle*/
}

int MDLMoveBullet(Bullet *bullet, GunSlinger *shooter, GunSlinger *target)
{
	int bullet_status;

	MDLBulletCactusCollision(bullet);
	MDLEnvBulletCollision(bullet);
	MDLPlayerBulletCollision(bullet, shooter, target);
	bullet->sprite.x_pos += bullet->sprite.x_vel;
	bullet->sprite.y_pos += bullet->sprite.y_vel;
}

void MDLEnvBulletCollision(Bullet *bullet)
{
	int x = bullet->sprite.x_pos;
	int y = bullet->sprite.y_pos;

	if (x >= SCREEN_LEFT_EDGE)
	{
		if (x >= SCREEN_RIGHT_EDGE)
			MDLTurnOffBullet(bullet);
	}
	else /* Left edge */
		MDLTurnOffBullet(bullet);

	if (y >= SCREEN_TOP_EDGE)
	{
		if (y >= SCREEN_BOTTOM_EDGE + 8)
			bullet->sprite.y_vel = -BULLET_SPEED;
	}
	else
		bullet->sprite.y_vel = BULLET_SPEED;
}

void MDLPlayerBulletCollision(Bullet *bullet, GunSlinger *shooter, GunSlinger *target)
{
	int x0 = target->sprite.x_pos;
	int x1 = target->sprite.x_pos + 32; /* TODO: sizeof */
	int y0 = target->sprite.y_pos;
	int y1 = target->sprite.y_pos + 32; /* TODO: When render complete update to + target->sprite.bitmap.height; */
	int bullet_x = bullet->sprite.x_pos;
	int bullet_y = bullet->sprite.y_pos;

	if ((bullet_x >= x0 && bullet_x <= x1) && (bullet_y >= y0 && bullet_y <= y1))
	{
		MDLTurnOffBullet(bullet);
		target->flag_alive = DEAD;
		MDLIncScore(shooter);
	}
}

void MDLPlayerCactusCollision(GunSlinger *gs)
{
	int player_x = gs->sprite.x_pos;
	int player_y = gs->sprite.y_pos;

	if ((player_x >= BORDER_X0 && player_x <= BORDER_XF) && (player_y >= BORDER_Y0 && player_y <= BORDER_YF))
		if (gs->sprite.x_vel == 32 * gs->orientation)
			gs->sprite.x_vel = 0;
}

void MDLBulletCactusCollision(Bullet *bullet)
{
	int bullet_x = bullet->sprite.x_pos;
	int bullet_y = bullet->sprite.y_pos;

	if ((bullet_x >= CACTUS_X0 && bullet_x <= CACTUS_XF) && (bullet_y >= CACTUS_Y0 && bullet_y <= CACTUS_YF))
		MDLTurnOffBullet(bullet);
}

void MDLTurnOffBullet(Bullet *bullet)
{
	bullet->sprite.x_pos = bullet->sprite.y_pos = bullet->sprite.x_vel = bullet->sprite.y_vel = 0;
	bullet->flag = OFF;
}

void MDLIncScore(GunSlinger *gs)
{
	gs->score.current_score += 1;
}

int MDLGetScore(GunSlinger gs)
{
	return gs.score.current_score;
}

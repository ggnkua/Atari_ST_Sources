#include <MODEL.H>
#include <RASTER.H>

void MDLInitGunSlinger(Game *game)
{
	int i;

	/* player 1 init */
	game->gun_slinger[PLAYER_ONE].sprite.x_pos = 160;
	game->gun_slinger[PLAYER_ONE].sprite.y_pos = 50;
	game->gun_slinger[PLAYER_ONE].sprite.y_vel = game->gun_slinger[PLAYER_ONE].sprite.x_vel = game->gun_slinger[PLAYER_ONE].score.current_score = 0;
	game->gun_slinger[PLAYER_ONE].num_bullets = MAX_ROUNDS;
	game->gun_slinger[PLAYER_ONE].flag_alive = ALIVE;
	game->gun_slinger[PLAYER_ONE].orientation = STANDARD;

	/* player 2 init */
	game->gun_slinger[PLAYER_TWO].sprite.x_pos = 320;
	game->gun_slinger[PLAYER_TWO].sprite.y_pos = 50;
	game->gun_slinger[PLAYER_TWO].sprite.y_vel = game->gun_slinger[PLAYER_TWO].sprite.x_vel = game->gun_slinger[PLAYER_TWO].score.current_score = 0;
	game->gun_slinger[PLAYER_TWO].num_bullets = MAX_ROUNDS;
	game->gun_slinger[PLAYER_TWO].flag_alive = ALIVE;
	game->gun_slinger[PLAYER_TWO].orientation = INVERTED;

	for (i = 0; i < NUM_ROUNDS; i++) /* initialize all bullets */
	{
		MDLTurnOffBullet(&game->gun_slinger[PLAYER_ONE].bullet[i]);
		MDLTurnOffBullet(&game->gun_slinger[PLAYER_TWO].bullet[i]);
	}
}

void MDLMoveGunSlinger(GunSlinger *gs)
{
	gs->sprite.x_pos += gs->sprite.x_vel;
	gs->sprite.y_pos += gs->sprite.y_vel;
	MDLEnvGunSlingerCollision(gs);
}

void MDLEnvGunSlingerCollision(GunSlinger *gs)
{
	int x = gs->sprite.x_pos;
	int y = gs->sprite.y_pos;

	if (x >= SCREEN_LEFT_EDGE)
	{
		if (x >= SCREEN_RIGHT_EDGE)
		{
			gs->sprite.x_pos = SCREEN_RIGHT_EDGE;
			gs->sprite.x_vel = 0;
		}
	}
	else
	{
		gs->sprite.x_pos = SCREEN_LEFT_EDGE;
		gs->sprite.x_vel = 0;
	}

	if (y >= SCREEN_TOP_EDGE)
	{
		if (y >= SCREEN_BOTTOM_EDGE)
		{
			gs->sprite.y_pos = SCREEN_BOTTOM_EDGE;
			gs->sprite.y_vel = 0;
		}
	}
	else
	{
		gs->sprite.y_pos = SCREEN_TOP_EDGE;
		gs->sprite.y_vel = 0;
	}
}

void MDLFireBullet(GunSlinger *gs)
{
	if (gs->num_bullets >= 0 && gs->bullet[gs->num_bullets].flag == OFF)
	{
		gs->current_bullet = gs->num_bullets;
		gs->bullet[gs->current_bullet].flag = ON;
		gs->bullet[gs->current_bullet].sprite.x_pos = gs->sprite.x_pos;
		gs->bullet[gs->current_bullet].sprite.y_pos = gs->sprite.y_pos;

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
		if (y >= SCREEN_BOTTOM_EDGE)
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

	if ((bullet_x == x0 || bullet_x == x1) && (bullet_y == y0 || bullet_y == y1))
	{
		MDLTurnOffBullet(bullet);
		target->flag_alive = DEAD;
		MDLIncScore(shooter);
	}
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

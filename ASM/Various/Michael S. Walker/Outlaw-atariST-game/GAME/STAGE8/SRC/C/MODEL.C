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

#include <MODEL.H>
#include <RASTER.H>

/*-------------------------------------------- MDLMoveGunSlinger -----
|  Function MDLMoveGunSlinger
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void MDLMoveGunSlinger(GunSlinger *gs)
{
	MDLEnvGunSlingerCollision(gs);

	gs->sprite.x_pos += gs->sprite.x_vel;
	gs->sprite.y_pos += gs->sprite.y_vel;
}

/*-------------------------------------------- MDLEnvGunSlingerCollision -----
|  Function MDLEnvGunSlingerCollision
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void MDLEnvGunSlingerCollision(GunSlinger *gs)
{
	int x = gs->sprite.x_pos;
	int y = gs->sprite.y_pos;

	MDLPlayerCactusCollision(gs);

	if (x > SCREEN_LEFT_EDGE)
	{
		if (x > SCREEN_RIGHT_EDGE - 64)
			if (gs->sprite.x_vel == 32)
				gs->sprite.x_vel = 0;
	}
	else if (gs->sprite.x_vel == -32)
		gs->sprite.x_vel = 0;

	if (y > SCREEN_TOP_EDGE)
	{
		if (y >= SCREEN_BOTTOM_EDGE - gs->sprite.bitmap.height)
			if (gs->sprite.y_vel == 32)
				gs->sprite.y_vel = 0;
	}
	else if (gs->sprite.y_vel == -32)
		gs->sprite.y_vel = 0;
}

/*-------------------------------------------- MDLFireBullet -----
|  Function MDLFireBullet
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

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

/*-------------------------------------------- MDLBulletReload -----
|  Function MDLBulletReload
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

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

/*-------------------------------------------- MDLMoveBullet -----
|  Function MDLMoveBullet
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

int MDLMoveBullet(Bullet *bullet, GunSlinger *shooter, GunSlinger *target)
{
	int bullet_status;

	MDLBulletCactusCollision(bullet);
	MDLEnvBulletCollision(bullet);
	MDLPlayerBulletCollision(bullet, shooter, target);
	bullet->sprite.x_pos += bullet->sprite.x_vel;
	bullet->sprite.y_pos += bullet->sprite.y_vel;
}

/*-------------------------------------------- MDLEnvBulletCollision -----
|  Function MDLEnvBulletCollision
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void MDLEnvBulletCollision(Bullet *bullet)
{
	int x = bullet->sprite.x_pos;
	int y = bullet->sprite.y_pos;

	if (x > SCREEN_LEFT_EDGE)
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

/*-------------------------------------------- MDLPlayerBulletCollision -----
|  Function MDLPlayerBulletCollision
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

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

/*-------------------------------------------- MDLPlayerCactusCollision -----
|  Function MDLPlayerCactusCollision
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void MDLPlayerCactusCollision(GunSlinger *gs)
{
	int player_x = gs->sprite.x_pos;
	int player_y = gs->sprite.y_pos;

	/* computer player */

	if (gs->orientation < 0 &&
		player_x >= (BORDER_X0 + 32) &&
		player_x <= (BORDER_XF + 32) &&
		player_y >= BORDER_Y0 &&
		player_y <= BORDER_YF &&
		gs->sprite.x_vel == 32 * gs->orientation)
		gs->sprite.x_vel = 0;

	/* player one */

	if (gs->orientation > 0 &&
		player_x > (BORDER_X0 - 64) &&
		player_y >= BORDER_Y0 &&
		player_y <= BORDER_YF &&
		gs->sprite.x_vel == 32 * gs->orientation)
		gs->sprite.x_vel = 0;
}

/*-------------------------------------------- MDLBulletCactusCollision -----
|  Function MDLBulletCactusCollision
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void MDLBulletCactusCollision(Bullet *bullet)
{
	int bullet_x = bullet->sprite.x_pos;
	int bullet_y = bullet->sprite.y_pos;

	if (bullet_x >= CACTUS_X0 && bullet_x <= CACTUS_XF && bullet_y >= CACTUS_Y0 && bullet_y <= CACTUS_YF)
		MDLTurnOffBullet(bullet);
}

/*-------------------------------------------- MDLTurnOffBullet -----
|  Function MDLTurnOffBullet
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void MDLTurnOffBullet(Bullet *bullet)
{
	bullet->sprite.x_pos = bullet->sprite.y_pos = bullet->sprite.x_vel = bullet->sprite.y_vel = 0;
	bullet->flag = OFF;
}

/*-------------------------------------------- MDLIncScore -----
|  Function MDLIncScore
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void MDLIncScore(GunSlinger *gs)
{
	gs->score.current_score += 1;
}

/*-------------------------------------------- MDLGetScore -----
|  Function MDLGetScore
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

int MDLGetScore(GunSlinger gs)
{
	return gs.score.current_score;
}

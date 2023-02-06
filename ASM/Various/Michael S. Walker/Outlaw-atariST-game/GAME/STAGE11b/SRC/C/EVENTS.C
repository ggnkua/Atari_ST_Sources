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
#include <EVENTS.H>
#include <EFFECTS.H>
#include <INPUT.H>

/*-------------------------------------------- EventCylinderState -----
|  Function EventCylinderState
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void EventCylinderState(GunSlinger *gs)
{
	gs->cylinder.state = gs->num_bullets + 1;
}

/*-------------------------------------------- EventShoot -----
|  Function EventShoot
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void EventShoot(int direction, GunSlinger *gs)
{
	switch (direction)
	{
	case UP:
		if (gs->num_bullets > 0)
			EffectGunShoot();
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = (PLAYER_SPEED * gs->orientation);
		gs->bullet[gs->current_bullet].sprite.y_vel = -BULLET_SPEED;

		gs->player_state = STATE_SHOOT_UP;

		EventCylinderState(gs);
		break;

	case DOWN:
		if (gs->num_bullets > 0)
			EffectGunShoot();
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = (PLAYER_SPEED * gs->orientation);
		gs->bullet[gs->current_bullet].sprite.y_vel = BULLET_SPEED;

		gs->player_state = STATE_SHOOT_DOWN;

		EventCylinderState(gs);
		break;

	case STRAIGHT:
		if (gs->num_bullets > 0)
			EffectGunShoot();
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = (PLAYER_SPEED * gs->orientation);
		gs->bullet[gs->current_bullet].sprite.y_vel = 0;

		gs->player_state = STATE_SHOOT;

		EventCylinderState(gs);
		break;

	case RELOAD:
		EffectReload();
		MDLBulletReload(gs);
		EventCylinderState(gs);
		break;

	default:
		break;
	}
}

/*-------------------------------------------- EventWalk -----
|  Function EventWalk
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void EventWalk(int direction, GunSlinger *gs)
{
	int forward_velocity = gs->orientation * PLAYER_SPEED;
	int backward_velocity = gs->orientation * -PLAYER_SPEED;

	switch (direction)
	{
	case UP:
		gs->player_state = (gs->player_state == STATE_NORM) ? STATE_WALK : STATE_NORM;
		gs->sprite.y_vel = -PLAYER_SPEED;
		gs->sprite.x_vel = 0;
		MDLMoveGunSlinger(gs);
		break;

	case DOWN:
		gs->player_state = (gs->player_state == STATE_NORM) ? STATE_WALK : STATE_NORM;
		gs->sprite.y_vel = PLAYER_SPEED;
		gs->sprite.x_vel = 0;
		MDLMoveGunSlinger(gs);
		break;

	case BACK:
		gs->player_state = (gs->player_state == STATE_NORM) ? STATE_WALK : STATE_NORM;
		gs->sprite.x_vel = backward_velocity;
		gs->sprite.y_vel = 0;
		MDLMoveGunSlinger(gs);
		break;

	case FORWARD:
		gs->player_state = (gs->player_state == STATE_NORM) ? STATE_WALK : STATE_NORM;
		gs->sprite.x_vel = forward_velocity;
		gs->sprite.y_vel = 0;
		MDLMoveGunSlinger(gs);
		break;

	default:
		break;
	}
}

/*-------------------------------------------- EventMoveBullets -----
|  Function EventMoveBullets
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void EventMoveBullets(GunSlinger *shooter, GunSlinger *target)
{
	int i;
	for (i = 0; i < NUM_ROUNDS; i++)
		if (shooter->bullet[i].flag == ON)
		{
			MDLMoveBullet(&shooter->bullet[i], shooter, target);
		}
}

/*-------------------------------------------- EventPlayerDead -----
|  Function EventPlayerDead
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

int EventPlayerDead(GunSlinger *gs)
{
	if (gs->flag_alive == DEAD)
	{
		gs->player_state = STATE_DEAD;
		return 1;
	}
	return 0;
}

/*-------------------------------------------- EventPlayerDead -----
|  Function EventPlayerDead
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

int EventWin(GunSlinger gs)
{
	return (gs.score.current_score == 10);
}

/*-------------------------------------------- EventUpdateScore -----
|  Function EventUpdateScore
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void EventUpdateScore(GunSlinger *shooter)
{
	int temp = shooter->score.current_score;

	shooter->score.lsd = (temp % 10) + 48;
	temp /= 10;
	shooter->score.msd = (temp % 10) + 48;
}

/*-------------------------------------------- EventUpdateMouse -----
|  Function EventUpdateMouse
|
|  Purpose: update mouse x and y
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void EventUpdateMouse(Mouse *mouse)
{
	mouse->sprite.x_pos = g_delta_x;
	mouse->sprite.y_pos = g_delta_y;
	MDLMoveMouse(mouse);
}

/*-------------------------------------------- EventMenuClick -----
|  Function EventMenuClick
|
|  Purpose: update mouse x and y
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void EventMenuClick(Game *game)
{
	int x = game->mouse.sprite.x_pos;
	int y = game->mouse.sprite.y_pos;

	if (g_click == ON)
		if (x > P1_MENU_X_START && x < P1_MENU_X_END)
			if (y > P1_MENU_Y_START && y < P1_MENU_Y_END)
				game->num_players = 1;
			else if (y > P2_MENU_Y_START && y < P2_MENU_Y_END)
				game->num_players = 2;
	g_click = OFF;
}

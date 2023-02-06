#include <MODEL.H>
#include <EVENTS.H>
#include <stdio.h>

void EventCylinderState(GunSlinger *gs)
{
	gs->cylinder.state = gs->num_bullets + 1;
	gs->cylinder.sprite.render_flag = ON;
}

void EventShoot(int direction, GunSlinger *gs)
{
	switch (direction)
	{
	case UP:
		MDLFireBullet(gs);

		gs->bullet[gs->current_bullet].sprite.x_vel = (PLAYER_SPEED * gs->orientation);
		gs->bullet[gs->current_bullet].sprite.y_vel = -BULLET_SPEED;
		gs->bullet[gs->current_bullet].sprite.render_flag = ON;

		gs->player_state = STATE_SHOOT_UP;
		gs->sprite.render_flag = ON;

		EventCylinderState(gs);
		break;

	case DOWN:
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = (PLAYER_SPEED * gs->orientation);
		gs->bullet[gs->current_bullet].sprite.y_vel = BULLET_SPEED;
		gs->bullet[gs->current_bullet].sprite.render_flag = ON;

		gs->player_state = STATE_SHOOT_DOWN;
		gs->sprite.render_flag = ON;

		EventCylinderState(gs);
		break;

	case STRAIGHT:
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = (PLAYER_SPEED * gs->orientation);
		gs->bullet[gs->current_bullet].sprite.y_vel = 0;
		gs->bullet[gs->current_bullet].sprite.render_flag = ON;

		gs->player_state = STATE_SHOOT;
		gs->sprite.render_flag = ON;

		EventCylinderState(gs);
		break;

	case RELOAD:
		MDLBulletReload(gs);
		EventCylinderState(gs);
		break;

	default:
		break;
	}
}

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
		gs->sprite.render_flag = ON;
		break;

	case DOWN:
		gs->player_state = (gs->player_state == STATE_NORM) ? STATE_WALK : STATE_NORM;
		gs->sprite.y_vel = PLAYER_SPEED;
		gs->sprite.x_vel = 0;
		MDLMoveGunSlinger(gs);
		gs->sprite.render_flag = ON;
		break;

	case BACK:
		gs->player_state = (gs->player_state == STATE_NORM) ? STATE_WALK : STATE_NORM;
		gs->sprite.x_vel = backward_velocity;
		gs->sprite.y_vel = 0;
		MDLMoveGunSlinger(gs);
		gs->sprite.render_flag = ON;
		break;

	case FORWARD:
		gs->player_state = (gs->player_state == STATE_NORM) ? STATE_WALK : STATE_NORM;
		gs->sprite.x_vel = forward_velocity;
		gs->sprite.y_vel = 0;
		MDLMoveGunSlinger(gs);
		gs->sprite.render_flag = ON;
		break;

	default:
		break;
	}
}

void EventMoveBullets(GunSlinger *shooter, GunSlinger *target)
{
	int i;
	for (i = 0; i < NUM_ROUNDS; i++)
		if (shooter->bullet[i].flag == ON)
		{
			MDLMoveBullet(&shooter->bullet[i], shooter, target);
			shooter->bullet[i].sprite.render_flag = ON;
		}
}

int EventPlayerDead(GunSlinger *gs)
{
	if (gs->flag_alive == DEAD)
	{
		gs->player_state = STATE_DEAD;
		gs->sprite.render_flag = ON;
		return 1;
	}
	return 0;
}

void EventUpdateScore(GunSlinger *shooter)
{
	int temp = shooter->score.current_score;

	shooter->score.lsd = (temp % 10) + 48;
	temp /= 10;
	shooter->score.msd = (temp % 10) + 48;
	shooter->score.sprite.render_flag = ON;
}

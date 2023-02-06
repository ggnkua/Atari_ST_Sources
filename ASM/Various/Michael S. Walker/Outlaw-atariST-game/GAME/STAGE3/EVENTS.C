#include <MODEL.H>
#include <EVENTS.H>

void EventShoot(int direction, GunSlinger *gs)
{
	int forward_velocity = gs->orientation * PLAYER_SPEED;

	switch (direction)
	{
	case UP:
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = forward_velocity;
		gs->bullet[gs->current_bullet].sprite.y_vel = -BULLET_SPEED;
		break;

	case DOWN:
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = forward_velocity;
		gs->bullet[gs->current_bullet].sprite.y_vel = BULLET_SPEED;
		break;

	case STRAIGHT:
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = forward_velocity;
		break;

	case RELOAD:
		MDLBulletReload(gs);
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
		gs->sprite.y_vel = -PLAYER_SPEED;
		MDLMoveGunSlinger(gs);
		break;

	case DOWN:
		gs->sprite.y_vel = PLAYER_SPEED;
		MDLMoveGunSlinger(gs);
		break;

	case BACK:
		gs->sprite.x_vel = backward_velocity;
		MDLMoveGunSlinger(gs);
		break;

	case FORWARD:
		gs->sprite.x_vel = forward_velocity;
		MDLMoveGunSlinger(gs);
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
			MDLMoveBullet(&shooter->bullet[i], shooter, target);
}

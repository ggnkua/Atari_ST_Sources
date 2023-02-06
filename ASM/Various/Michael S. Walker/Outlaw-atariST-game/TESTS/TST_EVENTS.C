#include <MODEL.H>
#include <EVENTS.H>

#define TESTING 1

#if TESTING == 1
#include <stdio.h>
#endif

void EventShoot(int direction, GunSlinger *gs)
{
	switch (direction)
	{
	case UP:
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = BULLET_SPEED;
		gs->bullet[gs->current_bullet].sprite.y_vel = -BULLET_SPEED;
#if TESTING == 1
		printf("EventShoot.UP!\n");
		printf("CURRENT BULLET IS: %d\ny pos: %d\ny vel: %d\nx pos: %d\nx vel: %d\n", gs->current_bullet, gs->bullet[gs->current_bullet].sprite.y_pos, gs->bullet[gs->current_bullet].sprite.y_vel, gs->bullet[gs->current_bullet].sprite.x_pos, gs->bullet[gs->current_bullet].sprite.x_vel);
#endif /* TESTING */
		break;

	case DOWN:
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = BULLET_SPEED;
		gs->bullet[gs->current_bullet].sprite.y_vel = BULLET_SPEED;
#if TESTING == 1
		printf("EventShoot.DOWN!\n");
		printf("CURRENT BULLET IS: %d\ny pos: %d\ny vel: %d\nx pos: %d\nx vel: %d\n", gs->current_bullet, gs->bullet[gs->current_bullet].sprite.y_pos, gs->bullet[gs->current_bullet].sprite.y_vel, gs->bullet[gs->current_bullet].sprite.x_pos, gs->bullet[gs->current_bullet].sprite.x_vel);
#endif /* TESTING */
		break;

	case STRAIGHT:
		MDLFireBullet(gs);
		gs->bullet[gs->current_bullet].sprite.x_vel = BULLET_SPEED;
#if TESTING == 1
		printf("EventShoot.STRAIGHT!\n");
		printf("CURRENT BULLET IS: %d\ny pos: %d\ny vel: %d\nx pos: %d\nx vel: %d\n", gs->current_bullet, gs->bullet[gs->current_bullet].sprite.y_pos, gs->bullet[gs->current_bullet].sprite.y_vel, gs->bullet[gs->current_bullet].sprite.x_pos, gs->bullet[gs->current_bullet].sprite.x_vel);
#endif /* TESTING */
		break;

	case RELOAD:
		MDLBulletReload(gs);
#if TESTING == 1
		printf("Event.Shoot.RELOAD!\n");
		printf("Reload: %d\n", gs->num_bullets);
#endif /* TESTING */
		break;

	default:
		break;
	}
}

void EventWalk(int direction, GunSlinger *gs)
{
	switch (direction)
	{
	case UP:
		gs->sprite.y_vel = -PLAYER_SPEED;
		MDLMoveGunSlinger(gs);
#if TESTING == 1
		printf("EventWalk.UP!\n");
		printf("y pos: %d\ny vel: %d\nx pos: %d\nx vel: %d\n", gs->sprite.y_pos, gs->sprite.y_vel, gs->sprite.x_pos, gs->sprite.x_vel);
#endif /* TESTING */
		break;
	case DOWN:
		gs->sprite.y_vel = PLAYER_SPEED;
		MDLMoveGunSlinger(gs);
#if TESTING == 1
		printf("EventWalk.DOWN!\n");
		printf("y pos: %d\ny vel: %d\nx pos: %d\nx vel: %d\n", gs->sprite.y_pos, gs->sprite.y_vel, gs->sprite.x_pos, gs->sprite.x_vel);
#endif /* TESTING */
		break;
	case LEFT:
		gs->sprite.x_vel = -PLAYER_SPEED;
		MDLMoveGunSlinger(gs);
#if TESTING == 1
		printf("EventWalk.LEFT!\n");
		printf("y pos: %d\ny vel: %d\nx pos: %d\nx vel: %d\n", gs->sprite.y_pos, gs->sprite.y_vel, gs->sprite.x_pos, gs->sprite.x_vel);
#endif /* TESTING */
		break;
	case RIGHT:
		gs->sprite.x_vel = PLAYER_SPEED;
		MDLMoveGunSlinger(gs);
#if TESTING == 1
		printf("EventWalk.RIGHT!\n");
		printf("y pos: %d\ny vel: %d\nx pos: %d\nx vel: %d\n", gs->sprite.y_pos, gs->sprite.y_vel, gs->sprite.x_pos, gs->sprite.x_vel);
#endif /* TESTING */
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
#if TESTING == 1
			printf("bullet[%d] x=%d y=%d\n", i, shooter->bullet[i].sprite.x_pos, shooter->bullet[i].sprite.y_pos);
			if (target->flag_alive == DEAD)
				printf("PLAYER IS DEAD\n");
#endif
		}
}

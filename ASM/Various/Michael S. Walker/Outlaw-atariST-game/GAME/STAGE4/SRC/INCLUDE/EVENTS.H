#ifndef EVENTS_H
#define EVENTS_H

#define UP 1
#define DOWN 2
#define STRAIGHT 3
#define RELOAD 4

#define BACK 3
#define FORWARD 4

void EventMoveBullets(GunSlinger *shooter, GunSlinger *target);
void EventShoot(int direction, GunSlinger *gs);
void EventWalk(int direction, GunSlinger *gs);
void EventUpdateScore(GunSlinger *shooter);
void EventCylinderState(GunSlinger *gs);
int EventPlayerDead(GunSlinger *gs);

#endif /* EVENTS_H */

#ifndef MODEL_H
#define MODEL_H

#define NUM_ROUNDS 6
#define MAX_ROUNDS (NUM_ROUNDS - 1)
#define MAX_SCORE 10

#define NUM_PLAYERS 2
#define NUM_SPRITE_STATES 10

#define PLAYER_ONE 0
#define PLAYER_TWO 1

#define BULLET_SPEED 16
#define PLAYER_SPEED 32

#define STANDARD 1
#define INVERTED -1

#define ON 1
#define OFF 0

#define ALIVE 1
#define DEAD 0

/* 16 for border */
#define BORDER_WIDTH 16
#define SCREEN_TOP_EDGE (BORDER_WIDTH)
#define SCREEN_LEFT_EDGE (BORDER_WIDTH)
#define SCREEN_RIGHT_EDGE (640 - BORDER_WIDTH)
#define SCREEN_BOTTOM_EDGE (400 - BORDER_WIDTH)

struct _Bitmap;
struct _Sprite;

typedef struct _RasterFunctions
{
	void (*Draw)(const void *, struct _Sprite *);
	void (*Alpha)(const void *, struct _Sprite *);
	void (*Clear)(const void *, struct _Sprite *);
} RasterFunctions;

typedef struct _Bitmap
{
	int height; /* height of current image */
	void *stored_images[NUM_SPRITE_STATES];
	void *current_image;
	RasterFunctions raster;
} Bitmap;

typedef struct _Sprite
{
	int x_vel, y_vel; /* horiz. & vert. displacement per clock tick */
	int x_pos, y_pos; /* position coordinates */
	Bitmap bitmap;
} Sprite;

typedef struct _Bullet
{
	Sprite sprite;
	int flag;
} Bullet;

typedef struct _Cactus
{
	Sprite sprite;
} Cactus;

typedef struct _Score
{
	int current_score;
	Sprite sprite;
} Score;

typedef struct _GunSlinger
{
	int num_bullets, current_bullet, flag_alive, orientation;
	Sprite sprite;
	Bullet bullet[NUM_ROUNDS];
	Score score;
} GunSlinger;

typedef struct _Game
{
	GunSlinger gun_slinger[NUM_PLAYERS];
	Cactus cactus;
} Game;

void MDLEnvGunSlingerCollision(GunSlinger *gs);
void MDLMoveGunSlinger(GunSlinger *gs);
void MDLInitGunSlinger(Game *game);

void MDLEnvBulletCollision(Bullet *bullet);
void MDLBulletReload(GunSlinger *gs);
void MDLFireBullet(GunSlinger *gs);
int MDLMoveBullet(Bullet *bullet, GunSlinger *shooter, GunSlinger *target);

void MDLPlayerBulletCollision(Bullet *bullet, GunSlinger *shooter, GunSlinger *target);
void MDLTurnOffBullet(Bullet *Bullet);
void MDLIncScore(GunSlinger *gs);
int MDLGetScore(GunSlinger gs);

#endif /* MODEL_H */

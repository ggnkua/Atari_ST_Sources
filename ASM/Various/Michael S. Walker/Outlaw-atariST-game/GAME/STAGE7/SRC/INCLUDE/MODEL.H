/*      _    _
       | |  | |	OUTLAW. 
      -| |  | |- 
  _    | |- | |
-| |   | |  | |- 	
 |.|  -| ||/  |
 | |-  |  ___/ 
-|.|   | | |
 |  \_|| |
  \____  |
   |   | |- 
       | |
      -| |
       |_| Michael S. Walker (2020)
*/

#include <SCREEN.H> /* for struct Screen */

#ifndef MODEL_H
#define MODEL_H

#define NUM_ROUNDS 6
#define MAX_ROUNDS (NUM_ROUNDS - 1)
#define MAX_SCORE 10

#define NUM_PLAYERS 2
#define NUM_SPRITE_STATES 10

/* Player index */

#define PLAYER_ONE 0
#define PLAYER_TWO 1

#define BULLET_SPEED 16
#define PLAYER_SPEED 32

/* Player forward direction */

#define STANDARD 1
#define INVERTED -1

#define ON 1
#define OFF 0

/* Is the player Dead or alive ? */

#define ALIVE 1
#define DEAD 0

/* 16 for border (Boundary's) */
#define BORDER_WIDTH 32
#define SCREEN_TOP_EDGE (BORDER_WIDTH)
#define SCREEN_LEFT_EDGE (BORDER_WIDTH)
#define SCREEN_RIGHT_EDGE (640 - BORDER_WIDTH)
#define SCREEN_BOTTOM_EDGE (400 - BORDER_WIDTH)

/* Player States */

#define STATE_DEAD 0
#define STATE_NORM 1
#define STATE_SHOOT 2
#define STATE_SHOOT_UP 3
#define STATE_SHOOT_DOWN 4
#define STATE_WALK 5

/* Cylinder States */

#define CYLINDER_ZERO 0
#define CYLINDER_ONE 1
#define CYLINDER_TWO 2
#define CYLINDER_THREE 3
#define CYLINDER_FOUR 4
#define CYLINDER_FIVE 5
#define CYLINDER_SIX 6

/* Cactus borders for bullet */

#define CACTUS_WIDTH 70
#define CACTUS_LENGTH 240
#define CACTUS_X0 290
#define CACTUS_Y0 75
#define CACTUS_XF (CACTUS_WIDTH + CACTUS_X0)
#define CACTUS_YF (CACTUS_LENGTH + CACTUS_Y0)

/* Cactus borders for player */

#define BORDER_LENGTH_CACTUS 400
#define BORDER_WIDTH_CACTUS 70
#define BORDER_X0 290
#define BORDER_Y0 0
#define BORDER_XF (BORDER_WIDTH_CACTUS + BORDER_X0)
#define BORDER_YF (BORDER_LENGTH_CACTUS + BORDER_Y0)

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
	int last_x[NUM_FRAME_BUFFERS], last_y[NUM_FRAME_BUFFERS]; /* the last x, y coordinates to be plotted */
	int x_vel, y_vel;										  /* horiz. & vert. displacement per clock tick */
	int x_pos, y_pos;										  /* position coordinates */
	int render_flag;										  /* set to 1 if on 0 if off */
	Bitmap bitmap;
} Sprite;

typedef struct _Bullet
{
	Sprite sprite;
	int flag;
} Bullet;

typedef struct _Cylinder
{
	Sprite sprite;
	int state;
} Cylinder;

typedef struct _BackGround
{
	Sprite sprite;
} BackGround;

typedef struct _Score
{
	int current_score;
	char msd; /* most significant digit */
	char lsd; /* least significant digit */
	Sprite sprite;
} Score;

typedef struct _GunSlinger
{
	int num_bullets,	/* number of bullets left */
		current_bullet, /* the current round in chamber */
		flag_alive,		/* is the player dead, or alive ? */
		orientation,	/* player forward orientation */
		player_state;   /* the current state the player is in */
	Cylinder cylinder;
	Bullet bullet[NUM_ROUNDS];
	Score score;
	Sprite sprite;
} GunSlinger;

typedef struct _Game
{
	GunSlinger gun_slinger[NUM_PLAYERS];
	BackGround background;
	Screen screen;
} Game;

void MDLEnvGunSlingerCollision(GunSlinger *gs);
void MDLPlayerCactusCollision(GunSlinger *gs);

void MDLMoveGunSlinger(GunSlinger *gs);

int MDLMoveBullet(Bullet *bullet, GunSlinger *shooter, GunSlinger *target);
void MDLBulletCactusCollision(Bullet *bullet);
void MDLEnvBulletCollision(Bullet *bullet);
void MDLBulletReload(GunSlinger *gs);
void MDLFireBullet(GunSlinger *gs);

void MDLPlayerBulletCollision(Bullet *bullet, GunSlinger *shooter, GunSlinger *target);
void MDLTurnOffBullet(Bullet *Bullet);
void MDLIncScore(GunSlinger *gs);
int MDLGetScore(GunSlinger gs);

#endif /* MODEL_H */

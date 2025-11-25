/* Defines etc. for PUNSSi.
 * PUNSSi (c) 1995 by Eero Tamminen
 */

#define FONT_FILE	"font.dat"
#define PICS_FILE	"objects.dat"
#define BG_FILE		"bg.dat"

/* bitmap sizes */
#define SCREEN_SIZE	32000	/* bytes, 640x400 pixels */
#define PICS_SIZE	10240	/* 640x128 pixels */
#define FONT_SIZE	4096	/* 8x16x256 */
#define SCREEN_W	40	/* screen width words */
#define SCREEN_L	20	/* longs */
#define PICS_L		20

#define RESOLUTION	2
#define DEVICE_0	0
#define DEVICE_1	1

/* Control device (joystick) directions */
#define jUP		1
#define jDOWN		2
#define jLEFT		4
#define jRIGHT		8
#define jBUTTON		128

/* how many bits for fixed point calculations /
 * how many steps for acceleration/decleration.
 */
#define DIGITS		3

/* play area limits in fixed point */
#define SX1	(0   << DIGITS)
#define SY1	(0   << DIGITS)
#define SX2	(640 << DIGITS)
#define SY2	(380 << DIGITS)

/* on which line messages appear
 * (centered) and the height of
 * the font used for them.
 */
#define MSG_LINE	383
/* live/score position offsets */
#define OFF_CLEAR	1
#define OFF_L0	11
#define OFF_S0	15
#define OFF_L1	70
#define OFF_S1	74
#define CLEAR_SCORE \
"Player 1: 0 - 00000                                        Player 2: 0 - 00000"

/* how many and what messages */
#define MESSAGES 2
#define MSG_COPYRIGHT	"PUNSSI (c) 1995 by Eero Tamminen"
#define MSG_HELP	"   FIRE to start, ESC to quit   "
#define MSG_WINNER0	"<- The Winner                   "
#define MSG_LOSER0	"<- Mr. Loser                    "
#define MSG_WINNER1	"                   The Winner ->"
#define MSG_LOSER1	"                    Mr. Loser ->"

/* how many lives players have at the start (1-9) */
#define LIVES	9

/* maximum object speeds in fixed point */
#define MAX_PLAYER	(3 << DIGITS)
#define MIN_PLAYER	 1
#define MAX_DROID	(MAX_PLAYER >> 1)
#define MIN_DROID	 1

#define SLOW_STEPS	16

/* object sizes in pixels */
#define PLAYER	16
#define DROID	8
#define BALL	16
#define GOAL	18	/* we check for being inside! */

/* object starting positions */
#define PLAYER0_X	140
#define PLAYER0_Y	100
#define PLAYER1_X	500
#define PLAYER1_Y	300
#define DROID0_X	500
#define DROID0_Y	200
#define DROID1_X	140
#define DROID1_Y	200
#define BALL_X		320
#define BALL_Y		200
#define GOAL0_X		578
#define GOAL0_Y		38
#define GOAL1_X		40
#define GOAL1_Y		323

/* GAME OBJECT STRUCTURE */
typedef struct {
  long *address;	/* image data address */
  long *background;	/* backup address of the area under the image */
  long *masked;		/* (backround && mask) || image */
  long *mask;		/* image mask data address */
  short w;		/* image width */
  short h;		/* image height */
  short x;		/* position on game */
  short y;
  short x0;		/* position on screen0 */
  short y0;
  short x1;		/* position on screen1 */
  short y1;
  short f_w;		/* position on fixed point */
  short f_h;
  short f_sx;		/* speed, fixed point */
  short f_sy;
  short f_px;		/* position, fixed point */
  short f_py;
  short f_nx;		/* next position, fixed point */
  short f_ny;
  short min;		/* min. speed (increase) */
  short max;		/* max. speed */
} Object;


/* error codes */
#define ERR_MEM		1
#define ERR_SCREEN	2
#define ERR_FILE	3
#define ERR_REZ		4

/* game score events */
#define GAME_START	1
#define GAME_GOAL0	2
#define GAME_GOAL1	3
#define GAME_CRASH0	4
#define GAME_CRASH1	5
#define GAME_OVER	6

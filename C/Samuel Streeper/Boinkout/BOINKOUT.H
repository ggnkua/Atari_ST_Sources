/******* boinkout.h ***************/

/*	You should define one and only one of the following entries as a	*/
/*	non-zero value depending on which compiler you are using.			*/

#define LASER 1				/* 1 if laser c, 0 if other */
#define MWC 0				/* 1 if mark williams c, 0 if other */

#if (LASER)
#define HIDE_MOUSE asm{	dc.w 0xa00a	}
#define SHOW_MOUSE asm{	dc.w 0xa009	}
#else
#define HIDE_MOUSE graf_mouse(M_OFF,0L);
#define SHOW_MOUSE graf_mouse(M_ON,0L);
#endif

#define SIDE_S 0x1e
#define TOP_S 0x1d
#define BOT_S 0x1f

#define TRUE 1
#define FALSE 0

typedef struct { int x,y,w,h;	} RECT;

typedef struct {
	int id;
	int (*ani_funct)();
	int x,y;
	int xspeed, yspeed;
	int array[8];
	int l,t,r,b;		/* redraw region */
	int spin_dir;
	int ball_ht, ball_wid;
	int half_ht, half_wid;
	int ball_num;
	} BALL_STRUCT;

/******* ball id's *********/
#define UNUSED 0
#define BALL 1
#define FUJI 2
#define EYE 3

typedef struct {
	int (*ani_funct)();		/* ptr to the function to do the animation */
	int x,y;				/* position of the animation */
	int frame;				/* the frame number for this animation */
	} ANI_STRUCT;


#define MAX_BALLS 12
#define MAX_ANI 60

#define Blit(a)		xbios(0x40,a)

#define WIDTH 440
#define HEIGHT 362

#define NO_WINDOW (-1)

#define MIN_WIDTH  (113)
#define MIN_HEIGHT (2*gl_hbox + ball_ht + 1)

#define BONUS 500

#define BNORMAL 3
#define BLACKMODE 15

#define LEVELS 36

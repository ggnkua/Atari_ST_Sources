#ifndef _DEF_H
#define _DEF_H

#include <sys/types.h>

#define MEMCONF 	0xff8001	/* MEMORY CONTROLLER */
#define DBASEH		0xff8201	/*  DISPLAY BASE HIGH, LOW */
#define DBASEM  	0xff8203
#define DBASEL  	0xff820d    /* STE only */
#define VCOUNTHI 	0xff8205	/*  DISPLAY COUNTER HIGH, MID, LOW */
#define VCOUNTMID 	0xff8207
#define VCOUNTLOW 	0xff8209
#define SYNCMODE 	0xff820A	/* VIDEO	SYNC MODE */
#define COLOR0		0xff8240	/* ST COLOR PALETTE #0 */
#define SHIFTMD		0xff8260	/* VIDEO	SHIFT MODE (RESOLUTION) */

#define COLREGCOUNT 16
#define LOW_REZ     0
#define MED_REZ     1

/* Error definitions.. move soon */
#define OUT_OF_MEMORY	-1
#define SUCCESS         1

typedef struct System_Restore
{
	u_char vbaseHigh;
	u_char vbaseMed;
	u_char vbaseLow;

	u_char rez;

	u_short palette[16];

}System_Restore;

typedef struct System_screen
{
   u_short *front;
   u_short *back;
   u_short  palette[16];
}System_screen;

typedef enum Screens
{
	ScreenFront,
	ScreenBack
}Screens;




void system_save (System_Restore *system);
void system_restore (System_Restore *system);

void system_screen_show (System_screen *screen,int type);

int system_screen_init (u_char         inRez,
                        u_short       *palette,
                        System_screen *screen);

int system_palette_init(u_short *in);

void system_screen_finalise(System_screen *screen);

typedef struct gfxCtx
{
   u_short *screen;
   u_short  palette[16];
   u_short  width;
   u_short  height;
}gfxCtx;

/* gfx ctx stuff here */
gfxCtx *gfx_ctx_init(u_int width, u_int height);
void gfx_ctx_destroy(gfxCtx *in);

void gfx_ctx_set_palette(gfxCtx *ctx, u_int *palette);
int gfx_ctx_init_file(char *fname, gfxCtx *inCtx);

void gfx_ctx_to_screen(gfxCtx *in, System_screen *screen, int type);

#endif
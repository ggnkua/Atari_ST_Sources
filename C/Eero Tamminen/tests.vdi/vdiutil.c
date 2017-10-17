/*
 * Helper functions for the VDI test-suite
 */
#include <stdio.h>
#include "vdiutil.h"

#ifdef __PUREC__	/* too lazy to make MTOS menubar hack compatible with others */
#include <aes.h>

/* kludges for AHCC and its aes.h header */
# define aes_global _GemParBlk.global
# define MENU_INSTALL	1
# define OBJ_INFO	long

/* menubar kludge for MultiTOS redraws */
#define FONT_W	8
#define FONT_H	16
static OBJECT menu_tree[] = {
	/* next, head, tail, type, flags, state, spec, x, y, w, h */
	{-1, 1, 4, G_IBOX,  NONE,  0,  NULL, 0, 0, 320, 200 }, /* 0: root */
	{ 4, 2, 2, G_BOX,   NONE,  0,  NULL, 0, 0, 320, FONT_H+2 }, /* 1: root/bar */
	{ 1, 3, 3, G_IBOX,  NONE,  0,  NULL, 0, 0, 320, FONT_H   }, /* 2: root/bar/active */
	{ 2,-1,-1, G_TITLE, NONE,  0,  (OBJ_INFO)" Desk ",  0, 0, 6*FONT_W, FONT_H }, /* 3: root/bar/active/title */
	{ 0, 5, 5, G_IBOX,  NONE,  0,  NULL, 0, FONT_H+2, 8*FONT_W, 8*FONT_H }, /* 4: root/dropdowns */
	{ 4, 6, 6, G_BOX,   NONE,  0,  NULL, 0, FONT_H+2, 8*FONT_W, 8*FONT_H }, /* 5: root/dropdowns/box */
	{ 7,-1,-1, G_STRING,NONE  ,0,  (OBJ_INFO)"  About ", 0, 0*FONT_H, 8*FONT_W, FONT_H }, /* 6: root/dropdowns/box/text */
	{ 8,-1,-1, G_STRING,DISABLED,0,(OBJ_INFO)"--", 0, 2*FONT_H, 8*FONT_W, FONT_H }, /* 7: root/dropdowns/box/text */
	{ 9,-1,-1, G_STRING,NONE  ,0,  (OBJ_INFO)"  ", 0, 3*FONT_H, 8*FONT_W, FONT_H }, /* 8: root/dropdowns/box/text */
	{10,-1,-1, G_STRING,NONE  ,0,  (OBJ_INFO)"  ", 0, 4*FONT_H, 8*FONT_W, FONT_H }, /* 9: root/dropdowns/box/text */
	{11,-1,-1, G_STRING,NONE  ,0,  (OBJ_INFO)"  ", 0, 5*FONT_H, 8*FONT_W, FONT_H }, /* 10: root/dropdowns/box/text */
	{12,-1,-1, G_STRING,NONE  ,0,  (OBJ_INFO)"  ", 0, 6*FONT_H, 8*FONT_W, FONT_H }, /* 11: root/dropdowns/box/text */
	{13,-1,-1, G_STRING,NONE  ,0,  (OBJ_INFO)"  ", 0, 7*FONT_H, 8*FONT_W, FONT_H }, /* 12: root/dropdowns/box/text */
	{ 5,-1,-1, G_STRING,LASTOB,0,  (OBJ_INFO)"  ", 0, 8*FONT_H, 8*FONT_W, FONT_H }, /* 13: root/dropdowns/box/text */
};
#endif

short vdi_handle, win_handle;

screen_t screen;


static void clip_enable(int enabled)
{
	short pxyarray[4];
	pxyarray[0] = 0;
	pxyarray[1] = 0;
	pxyarray[2] = screen.w;
	pxyarray[3] = screen.h;
	vs_clip(vdi_handle, enabled, pxyarray);
}

void work_clear(void)
{
	/* because "v_clrwk(vdi_handle);" doesn't work
	 * with fVDI, have to clear screen manually.
	 */
	short pxyarray[4];
	short attrib[5];

	/* this makes it bg colored */
	vqf_attributes(vdi_handle, attrib);
	vswr_mode(vdi_handle, MD_REPLACE);
	vsf_interior(vdi_handle, 0);

	pxyarray[0] = 0;
	pxyarray[1] = 0;
	pxyarray[2] = screen.w;
	pxyarray[3] = screen.h;
	vr_recfl(vdi_handle, pxyarray);

	/* restore interior fill style */
	vsf_interior(vdi_handle, attrib[0]);
	vswr_mode(vdi_handle, attrib[3]);
}

void work_open(void)
{
	static short work_in[12], work_out[57];
	short i, appid;

	appid = appl_init();
	screen.multitos = (aes_global[1] == -1);

	/* open virtual screen workstation (screen) */
	for(i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk(work_in, &vdi_handle, work_out);

	screen.colors = work_out[13];
	screen.w = work_out[0];
	screen.h = work_out[1];

	/* get the number of bitplanes on screen */
	vq_extnd(vdi_handle, 1, work_out);
	screen.planes = work_out[4];

	if (screen.multitos) {
		short x, y, w, h;
		/* create window, otherwise cannot get all events */
		x = 0; y = 0; w = screen.w; h = screen.h;
		win_handle = wind_create(0, x, y, w, h);
		if (win_handle > 0) {
			wind_open(win_handle, x, y, w, h);
		}
	} else {
		/* reserve screen area (in multitasking AES = a no-op),
		 * is really needed only for ACCs as on non-multitos AES
		 * only those can come on top of other applications.
		 */
		form_dial(FMD_START, screen.w>>1, screen.h>>1, 0, 0, 0, 0, screen.w, screen.h);
	}

	/* hide mouse, stop updates */
	graf_mouse(M_OFF, NULL);
	wind_update(BEG_UPDATE);

	/* enable clipping & clear screen */
	clip_enable(1);
	work_clear();
}

void work_close(void)
{
	clip_enable(0);

	wind_update(END_UPDATE);
	graf_mouse(M_ON, NULL);

	if (screen.multitos) {
#if defined(__PUREC__)
		/* create menu, otherwise desktop one won't be redrawn after program exits */
		menu_bar(menu_tree, MENU_INSTALL);
#endif
		if (win_handle > 0) {
			/* remove window */
			wind_close (win_handle);
			wind_delete (win_handle);
		}
	} else {
		/* restore screen area (in multitasking AES = cause WM_REDRAW,
		 * unfortunately this doesn't cause desktop menubar redraw)
		 */
		form_dial(FMD_FINISH, screen.w>>1, screen.h>>1, 0, 0, 0, 0, screen.w, screen.h);
	}

	v_clsvwk(vdi_handle);
	appl_exit();
}

static short get_events(short mask, short low, short hi)
{
	short dummy, key;
	/* wait for (key) input:
	 *  event flags, mbclicks, mbmask, mbstate,
	 *  5x region 1, 5x region 2,
	 *  event buffer, low & high timer value (ms).
	 * output:
	 *  mouse co-ordinate (x,y), mouse buttons, special key and normal key
	 *  states, number of mouse clicks.
	 */
#ifdef __GEMLIB__
	return evnt_multi(mask,
			  0, 0, 0,
			  0, 0, 0, 0, 0,
			  0, 0, 0, 0, 0,
			  NULL, low|(hi<<16),
			  &dummy, &dummy, &dummy, &dummy, &key, &dummy);
#else
	return evnt_multi(mask,
			  0, 0, 0,
			  0, 0, 0, 0, 0,
			  0, 0, 0, 0, 0,
			  NULL, low, hi,
			  &dummy, &dummy, &dummy, &dummy, &key, &dummy);
#endif
}

/* eat buffered keys and wait for a new keypress */
void wait_key(void)
{
	short evnt_m;

	/* remove buffered keys */
	do {
		evnt_m = get_events(MU_KEYBD|MU_TIMER, 1, 0);
	} while (evnt_m & MU_KEYBD);
	get_events(MU_KEYBD, 0, 0);
}

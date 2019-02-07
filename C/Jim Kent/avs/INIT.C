/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */



#include <osbind.h>
#include "flicker.h"


extern char *ainit();
extern WORD sys_cmap[];

WORD contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];
char *aline;
static WORD color_env[16];

WORD *pscreen, *cscreen;  /* buffer, physical, and drawing screens */
WORD *bscreen;	/* buffer screen */
WORD gl_apid = -1;
WORD handle;
WORD gr_handle;
WORD gr_hwchar, gr_hhchar, gr_hwbox, gr_hhbox;
WORD gem_mrez;	/* gem in medium rez? */

static WORD mouse_bx, mouse_by, gem_colr;
static WORD initted_color;
static WORD irez;
WORD screen_bounds[] = { 0, 0, XMAX-1, YMAX-1};

WORD white = 3, black = 0, red = 2, green = 1;

WORD sys_cmap[16] = { 
	0x000,	0x070,	0x700,	0x777,
	0x433,	0x530,	0x653,	0x754,
	0x700,	0x750,	0x670,	0x070,
	0x056,	0x137,	0x607,	0x777,
	};


/* set_for_gem and set_for_jim - functions that let me run at medium rez
   while doing file requestor and file io at whatever rez GEM thinks
   it is - necessary for file requestor to appear ok, and for system
   io error dialogs to be centered etc.
   Thanks to Dave Staugas (of Neochrome) for the necessary magic aline
   peeks and pokes! */
set_for_gem()
{
long i;

#ifdef LATER
wait_penup();
#endif LATER
for (i=0; i<22000; i++)
	;	/* just stall - hey I'm experimenting */
remove_critical();
Setpallete(color_env);	/* restore start-up colors */
hide_mouse();	/* go reset mouse and */
vs_clip(handle, 0, screen_bounds);
gem_rez();		/* screen rez */
Setscreen(pscreen, pscreen, -1);
show_mouse();	/* to what GEM wants */
}

set_for_jim()
{
WORD dummy;
WORD i;

Setpallete(sys_cmap);	/* and now set flicker colors */
hide_mouse();
jim_rez();
vs_clip(handle, 1, screen_bounds);
cross_cursor();
show_mouse();
install_critical();
}

jim_rez()
{
Setscreen( -1L, -1L, 1);
*((WORD *)(aline-692)) = 639;
*((WORD *)(aline-690)) = 199;
*((WORD *)(aline-666)) = 4;
}

gem_rez()
{
if (!gem_mrez)
	{
	Setscreen( -1L, -1L, 0);
	*((WORD *)(aline-692)) = 319;
	*((WORD *)(aline-690)) = 199;
	*((WORD *)(aline-666)) = 16;
	}
}


init_sys()
{
WORD work_in[11];
WORD work_out[57];
WORD i;



save_critical();
if ( (gl_apid = appl_init()) == -1)
	{
	exit(-1);
	}
aline = ainit();


if (!init_mem())
	exit(-2);

/* save initial rez ... we'll see if GEM agrees with this later */
if ( (irez = Getrez()) != 0)
	{
	if (irez != 1)
		{
		puts("AVS can't run on black and white systems, sorry");
		for (i=0; i<60; i++)
			{
			Vsync();
			}
		exit(-3);
		}
	}

get_cmap(color_env);
Setpallete(sys_cmap);
initted_color = 1;

if (!init_pulls())
	return(-4);

/* save mouse wrap-around */
mouse_bx = *((WORD *)(aline-692));
mouse_by = *((WORD *)(aline-690));
/* save # of colors gem thinks exist */
gem_colr = *((WORD *)(aline-666));

gr_handle = graf_handle(&gr_hwchar, &gr_hhchar, &gr_hwbox, &gr_hhbox);
handle = gr_handle;
stuff_words(work_in, 1, 10);
work_in[10] = 2;
v_opnvwk(work_in, &handle, work_out);
if (handle == 0)
	return(-5);
if (work_out[0] == 639)
	{
	gem_mrez = 1;	/* see what GEM thinks rez is in so file-requestor can 
						work */
	}
pscreen = cscreen = (WORD *)Physbase();
if ((bscreen = askmem(32000)) == NULL)
	{
	return(0);
	}

init_fname();
set_for_jim();

cel_mem_alloc = mem_free;	/* "user" memory starts here */

return(1);
}

uninit_sys()
{
WORD dummy;
WORD i;
Vector ourmbvec;

set_for_gem();
/*magic poke to set mouse wrap-around*/
*((WORD *)(aline-692)) = mouse_bx;
*((WORD *)(aline-690)) = mouse_by;
*((WORD *)(aline-666)) = gem_colr;
Setscreen( -1L, -1L, irez);

/*restore palette...*/
if (initted_color)
	Setpallete(color_env);
remove_critical();
if (handle != 0)
	v_clsvwk(handle);
if (gl_apid != -1)
	appl_exit(0);
}


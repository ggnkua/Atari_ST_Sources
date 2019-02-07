

#include <osbind.h>
#include "kamikaze.h"


/* handle on the a-line */
extern char *ainit();
char *aline;

/* colors, and a copy of original to restore on exit */
WORD sys_cmap[16] = { 
	0x333,	0x444,	0x777,	0x000,
	0x555,	0x700,	0x607,	0x410,
	0x273,	0x560,	0x700,	0x361,
	0x500,	0x722,	0x575,	0x070,
	};
static WORD color_env[16];

/* VDI/GEM communications variables */
WORD contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];
WORD gl_apid = -1;
WORD handle;
WORD gr_handle;
WORD gr_hwchar, gr_hhchar, gr_hwbox, gr_hhbox;
WORD gem_mrez;	/* gem in medium rez? */

WORD *pscreen, *cscreen;  /* buffer, physical, and drawing screens */
static WORD mouse_bx, mouse_by, gem_colr;
static WORD initted_color;
static WORD irez;
WORD screen_bounds[] = { 0, 0, 319, 199};

/* set_for_gem and set_for_jim - functions that let me run at low rez
   while doing file requestor and file io at whatever rez GEM thinks
   it is - necessary for file requestor to appear ok, and for system
   io error dialogs to be centered etc.
   Thanks to Dave Staugas (of Neochrome) for the necessary magic aline
   peeks and pokes! */
set_for_gem()
{
WORD i;

wait_penup();
for (i=0; i<22000; i++)
	;	/* just stall - hey I'm experimenting */
Setpallete(color_env);	/* restore start-up colors */
vs_clip(handle, 0, screen_bounds);
gem_rez();		/* screen rez */
}


jim_rez()
{
Setscreen( -1L, -1L, 0);
*((WORD *)(aline-692)) = 319;
*((WORD *)(aline-690)) = 199;
*((WORD *)(aline-666)) = 16;
}

gem_rez()
{
if (gem_mrez)
	{
	Setscreen( -1L, -1L, 1);
	*((WORD *)(aline-692)) = 639;
	*((WORD *)(aline-690)) = 199;
	*((WORD *)(aline-666)) = 4;
	}
}


init_sys()
{
WORD work_in[11];
WORD work_out[57];



if ( (gl_apid = appl_init()) == -1)
	{
	exit(-1);
	}
aline = ainit();
get_cmap(color_env);
Setpallete(sys_cmap);	/* and now set flicker colors */

initted_color = 1;

/* save initial rez ... we'll see if GEM agrees with this later */
if ( (irez = Getrez()) != 0)
	{
	if (irez != 1)
		{
		puts("PULL can't run on black and white systems, sorry");
		exit(-3);
		}
	}

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
	/* poke in initial mouse location (in case off-screen for lo-rez */
	*((WORD *)(aline-602)) = 160;
	*((WORD *)(aline-600)) = 100;
	}
if (!init_mem())
	{
	return(-6);
	}
if (!init_freem())
	{
	puts("Couldn't init freem()");
	return(-7);
	}
jim_rez();
pscreen = cscreen = (WORD *)Physbase();
return(1);
}


uninit_sys()
{
WORD dummy;
WORD i;
Vector ourmbvec;

wait_penup();
for (i=0; i<22000; i++)
	;	/* just stall - hey I'm experimenting */
set_for_gem();
/*magic poke to set mouse wrap-around*/
*((WORD *)(aline-692)) = mouse_bx;
*((WORD *)(aline-690)) = mouse_by;
*((WORD *)(aline-666)) = gem_colr;
Setscreen( -1L, -1L, irez);

/*restore palette...*/
if (initted_color)
	Setpallete(color_env);
if (handle != 0)
	v_clsvwk(handle);
if (gl_apid != -1)
	appl_exit(0);
}


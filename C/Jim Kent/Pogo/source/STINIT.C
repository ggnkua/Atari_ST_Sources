

#include <osbind.h>
#define WORD int
#define COLORS 166


extern char *ainit();

WORD contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];
char *aline;
static WORD color_env[16];
extern WORD *sys_cmap;
WORD in_graphics;
extern WORD *screens[];
extern WORD *cmaps[];

WORD *physcreen;  /* physical screen */
WORD *cscreen;	/* drawing screen */
WORD gl_apid = -1;
WORD handle;
WORD gr_handle;
WORD gr_hwchar, gr_hhchar, gr_hwbox, gr_hhbox;
WORD gem_mrez;	/* gem in medium rez? */

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
to_text()
{
WORD i;

if (in_graphics)
	{
	de_swap();
	in_graphics = 0;
	Setpallete(color_env);	/* restore start-up colors */
	vs_clip(handle, 0, screen_bounds);
	gem_rez();		/* screen rez */
	}
}


to_graphics()
{
WORD dummy;
WORD i;

if (!in_graphics)
	{
	in_graphics = 1;
	Setpallete(sys_cmap);	/* and now set graphics colors */
	jim_rez();
	vs_clip(handle, 1, screen_bounds);
	}
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
if (irez)
	{
	Setscreen( physcreen, physcreen, 1);
	*((WORD *)(aline-692)) = 639;
	*((WORD *)(aline-690)) = 199;
	*((WORD *)(aline-666)) = 4;
	}
}


extern int randseed;

init_sys()
{
WORD work_in[11];
WORD work_out[57];
WORD i;

if ( (gl_apid = appl_init()) == -1)
	{
	exit(-1);
	}
aline = ainit();


/* save initial rez ... we'll see if GEM agrees with this later */
if ( (irez = Getrez()) != 0)
	{
	if (irez != 1)
		{
		puts("POGO only works with color ST's, sorry");
		for (i=0; i<60; i++)
			{
			Vsync();
			}
		exit(-3);
		}
	}

get_cmap(color_env);
initted_color = 1;

/* save mouse wrap-around */
mouse_bx = *((WORD *)(aline-692));
mouse_by = *((WORD *)(aline-690));
/* save # of colors gem thinks exist */
gem_colr = *((WORD *)(aline-666));

gr_handle = graf_handle(&gr_hwchar, &gr_hhchar, &gr_hwbox, &gr_hhbox);
handle = gr_handle;
for (i = 0; i<10; i++)
	work_in[i] = 1;
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
screens[1] = physcreen = cscreen = (WORD *)Physbase();
cmaps[1] = sys_cmap;
randseed = get_clock();
return(1);
}

cleanup()
{
WORD dummy;
WORD i;

use_mouse();
to_text();
/*magic poke to set mouse wrap-around*/
*((WORD *)(aline-692)) = mouse_bx;
*((WORD *)(aline-690)) = mouse_by;
*((WORD *)(aline-666)) = gem_colr;

/*restore palette...*/
if (initted_color)
	Setpallete(color_env);
if (handle != 0)
	v_clsvwk(handle);
if (gl_apid != -1)
	appl_exit(0);
}


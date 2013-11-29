

#include <osbind.h>
#include "flicker.h"

extern clr_d0();

extern char *ainit();
extern pfinit(), pfcleanup(), timebon(), timeboff();
extern WORD sys_cmap[];
extern WORD *ram_screens[MAX_SCREENS];
extern long rd_alloc;
extern long rd_count;

WORD contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];
char *aline;
static WORD color_env[16];

WORD *bscreen, *pscreen, *cscreen;  /* buffer, physical, and drawing screens */
WORD *uscreen;	/* undo screen */
WORD *start_screen;	/* first screen */
WORD *end_screen;	/* end_screen */
WORD *next_screen;
WORD *prev_screen;
WORD gl_apid = -1;
WORD handle;
WORD gr_handle;
WORD gr_hwchar, gr_hhchar, gr_hwbox, gr_hhbox;
WORD gem_mrez;	/* gem in medium rez? */
WORD got_blitter;

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
remove_critical();
Setpallete(color_env);	/* restore start-up colors */
hide_mouse();	/* go reset mouse and */
vs_clip(handle, 0, screen_bounds);
gem_rez();		/* screen rez */
gshow_mouse();	/* to what GEM wants */
Setscreen(pscreen, pscreen, -1);
}

char jimint_status;

nohblanks()
{
if (jimint_status)
	Supexec(timeboff);
}

yeshblanks()
{
if (jimint_status)
	Supexec(timebon);
}


jimints_on()
{
if (!jimint_status)
	{
	Supexec(pfinit);
	jimint_status = 1;
	}
}

jimints_off()
{
if (jimint_status)
	{
	Supexec(pfcleanup);
	Vsync();
	jimint_status = 0;
	}
}

set_for_jim()
{
WORD dummy;
WORD i;

Setpallete(sys_cmap);	/* and now set flicker colors */
ghide_mouse();
jim_rez();
vs_clip(handle, 1, screen_bounds);
show_mouse();
install_critical();
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
WORD i;



save_critical();
got_blitter = ( (_xbios(64, -1) & 3 ) == 3);
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
		puts("Cyber Paint can't run on black and white systems, sorry");
		for (i=0; i<60; i++)
			{
			Vsync();
			}
		exit(-3);
		}
	}

get_cmap(color_env);
copy_words(init_cmap, sys_cmap, COLORS);
put_cmap(sys_cmap);
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
	/* poke in initial mouse location (in case off-screen for lo-rez */
	*((WORD *)(aline-602)) = 160;
	*((WORD *)(aline-600)) = 100;
	}
jim_rez();
pscreen = cscreen = (WORD *)Physbase();

if ((uscreen = askmem(32000)) == NULL)
	return(-6);
if ((start_screen = askmem(32000)) == NULL)
	return(-7);
if ((end_screen = askmem(32000)) == NULL)
	return(-8);
if ((prev_screen = laskmem(2L*32000L)) == NULL)	
	/* prev/next form 64K buffer */
	return(-9);
next_screen = prev_screen+16000;
if ((bscreen = askmem(32000)) == NULL)
	return(-11);
empty_ram_dlt();
zero_screens();
if (!init_input())
	return(-13);
init_fname();
init_menu_colors();
install_critical();
jimints_on();

cel_mem_alloc = mem_free;	/* "user" memory starts here */

return(1);
}

#ifdef SLUFFED
Vector ombvec;
#endif SLUFFED

uninit_sys()
{
WORD dummy;
WORD i;
Vector ourmbvec;

jimints_off();
wait_penup();
for (i=0; i<22000; i++)
	;	/* just stall - hey I'm experimenting */
free_cfont();
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


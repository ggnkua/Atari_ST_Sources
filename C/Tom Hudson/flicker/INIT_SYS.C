

#include <osbind.h>
#include "flicker.h"

extern char *ainit();
extern WORD sys_cmap[];

WORD contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];
char *aline;
static WORD color_env[16];

WORD *bscreen, *pscreen, *cscreen;  /* buffer, physical, and drawing screens */
WORD gl_apid = -1;
WORD handle;
WORD gem_mrez;	/* gem in medium rez? */

static WORD mouse_bx, mouse_by, gem_hicolor;
static WORD initted_color;
static WORD irez;

/* set_for_gem and set_for_jim - functions that let me run at low rez
   while doing file requestor and file io at whatever rez GEM thinks
   it is - necessary for file requestor to appear ok, and for system
   io error dialogs to be centered etc.
   Thanks to Dave Staugas (of Neochrome) for the necessary magic aline
   peeks and pokes! */
set_for_gem()
{
unzoom();		/* don't make GEM deal with zoom */
Setpallete(color_env);	/* restore start-up colors */
hide_mouse();	/* go reset mouse and */
gem_rez();		/* screen rez */
gshow_mouse();	/* to what GEM wants */
}

set_for_jim()
{
Setpallete(sys_cmap);	/* and now set flicker colors */
ghide_mouse();
jim_rez();
show_mouse();
rezoom();
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
put_cmap(sys_cmap);

initted_color = 1;

if (!init_mem())
	exit(-2);

/* save initial rez ... we'll see if GEM agrees with this later */
if ( (irez = Getrez()) != 0)
	{
	if (irez != 1)
		{
		puts("PULL can't run on black and white systems, sorry");
		return(-3);
		}
	}
/* save mouse wrap-around */
mouse_bx = *((WORD *)(aline-692));
mouse_by = *((WORD *)(aline-690));
/* and save GEM's ideas of # of colors */
gem_hicolor = *((WORD *)(aline-666));

v_opnvwk(work_in, &handle, work_out);
if (handle < 0)
	return(-4);

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

if ((screens[0] = alloc(32000)) == NULL)
	return(-5);
copy_screen(cscreen, screens[0]);

if ((bscreen = alloc(32000)) == NULL)
	return(-6);

if (!init_input())
	return(-7);

init_fname();
init_menu_colors();

cel_mem_alloc = mem_free;	/* "user" memory starts here */

return(1);
}

uninit_sys()
{
/* restore pokes for GEM to get back to medium rez maybe... */
*((WORD *)(aline-692)) = mouse_bx;
*((WORD *)(aline-690)) = mouse_by;
*((WORD *)(aline-666)) = gem_hicolor;
Setscreen( -1L, -1L, irez);

/*restore palette...*/
if (initted_color)
	Setpallete(color_env);
if (gl_apid != -1)
	appl_exit();
}


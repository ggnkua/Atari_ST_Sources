
overlay "reader"

#include <osbind.h>
#include "..\\include\\lists.h"
#include "..\\include\\menu.h"

struct slider gauge_sl = 
	{
	"memory usage",1,1,
	};

extern long mem_free;
WORD color_env[16];
#ifdef SLUFFED
WORD mouse_bx, mouse_by;
#endif SLUFFED
extern char *aline;
WORD gl_apid = -1;

static WORD initted_color;

init_sys()
{
register WORD i;


#ifdef DEBUG
printf("init_sys()\n");
lsleep(1);
#endif DEBUG

if ( (gl_apid = appl_init()) == -1)
	{
	puts("ani couldn't open GEM... sorry\n");
	exit(-1);
	}

for (i=0; i<16; i++)
	{
	color_env[i] = Setcolor(i, -1);
	}

initted_color = 1;

if ( Getrez() != 0)
	{
	form_alert(1, 
		"[3][Ani can only run on a|color system in low res][ ok ]");
	exit(0);
	}

if (!init_mem())
	exit(-2);

#ifdef DEBUG
printf("finished init_mem()\n");
lsleep(1);
#endif DEBUG

if (!init_sync())
	return(-2);
#ifdef DEBUG
printf("finished init_sync()\n");
lsleep(1);
#endif DEBUG


if (!init_aline())
	return(-4);
#ifdef DEBUG
printf("finished init_aline()\n");
lsleep(1);
#endif DEBUG

#ifdef RUDE
/*magic poke to set mouse wrap-around*/
mouse_bx = *((WORD *)(aline-692));
mouse_by = *((WORD *)(aline-690));
*((WORD *)(aline-692)) = 319;
*((WORD *)(aline-690)) = 199;
/*poke for init mouse location*/
*((WORD *)(aline-602)) = 40;
*((WORD *)(aline-600)) = 40;
#endif RUDE

if (!init_input())
	exit(-5);

init_pulls();

/*"user" memory space starts now... */
gauge_sl.scale = mem_free;

return(1);
}

ani_cleanup()
{
int i;

desync();

#ifdef RUDE
/*magic poke to set mouse wrap-around*/
*((WORD *)(aline-692)) = mouse_bx;
*((WORD *)(aline-690)) = mouse_by;
#endif RUDE

/*restore palette...*/
if (initted_color)
	for (i=0; i<16; i++)
	Setcolor(i, color_env[i]);
uninit_sync();
if (gl_apid != -1)
	appl_exit();
}


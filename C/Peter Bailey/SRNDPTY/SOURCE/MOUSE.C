/* ==================================================================== */
/*	Serendipity: Mouse driving routines				*/
/* ==================================================================== */

#include	<osbind.h>
#include	"globals.h"

#define	MU_BUTTON	0x0002
#define	MU_TIMER	0x0020


mouse(x,y)
	int	*x,*y;
{
	int	z,lo_time,hi_time,which;

	do {
		timer   = panic ? 3000 : 15000;

		lo_time = (int)(timer & 0xffff);
		hi_time = (int)((timer >> 16) & 0xffff);

		which=evnt_multi((MU_TIMER|MU_BUTTON),1,1,1,
				0,0,0,0,0,0,0,0,0,0,
				0L,lo_time,hi_time,
				x,y,&z,&z,&z,&z);

		if (which & MU_TIMER) {
			if (game_on & panic) {
				say("* TOO SLOW! -- MY TURN *");
				clang_2();  game_on = -1;
				return 0;
			} else {
				if (!help_flag) chivvy();
				}
			}

		} while (!(which & MU_BUTTON));

	return 1;
}


/* -------------------------------------------------------------------- */
/*	Encourage the sucker to do something				*/
/* -------------------------------------------------------------------- */

chivvy()
{
	static char	*jolt[] = {

		"??? HELLO ???",
		"ANYBODY OUT THERE ??",
		"WAKE UP, DOZY !",
		"I'M GETTING BORED WAITING",
		"IS THERE LIFE ON EARTH ?",
		"GO SUCK A PEARDROP",
		"YAWN...ZZZZZZZzzzzzzzzzz........",
		"TICKLE MY BUTTONS",
		"FOR HEAVEN'S SAKE, TALK TO ME !",
		"HO HUM",
		"TEDIUM GETS BORING AFTER A WHILE",
		"WAKE ME UP NEXT SEPTEMBER",
		"...TRIDDLE-DEE-DUM...",
		"CONFUCIUS SAY - \"DON'T QUOTE ME...\""
		};

	static int	n,m;

	do {  m = (Random() & 0xffff) % 14;  } while (m==n);

	say(jolt[n=m]);  bell();
}

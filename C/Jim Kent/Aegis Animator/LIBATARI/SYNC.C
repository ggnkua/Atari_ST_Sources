
overlay "player"

#include <aline.h>
#include <osbind.h>
#include "..\\include\\lists.h"


extern struct bbblock sd_bbb;
extern struct bbblock ftos_bbb;


WORD *s1, *s2, *cscreen;
WORD *gem_screen;
init_sync()
{
/*get first screen from DOS*/
cscreen = s1;
return(1);
}

uninit_sync()
{
if (gem_screen != NULL)
	Setscreen(gem_screen, gem_screen, -1);
}

desync()
{
if ((cscreen = ftos_bbb.d_form = sd_bbb.d_form = s1) != NULL)
Setscreen(s1, s1, -1);
}


#ifdef SLUFFED
presync()
{
Setscreen(s2, s1, -1);
cscreen = ftos_bbb.d_form = sd_bbb.d_form = s2;
}
#endif SLUFFED


sync()
{
register WORD *oscreen;

if ((oscreen = cscreen) == s1)
	cscreen = ftos_bbb.d_form = sd_bbb.d_form = s2;
else	
	cscreen = ftos_bbb.d_form = sd_bbb.d_form = s1;
Setscreen(cscreen, oscreen, -1);
}



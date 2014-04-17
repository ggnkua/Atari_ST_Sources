/* iconwind.h	icon window handler definitions
 *=======================================================================
 * 920610 kbad
 */

#include "windows.h"

#define WINTYPE_ICON	0x49434F4EL	/*ICON*/
#define ICONWIND_W	50
#define ICONWIND_H	42

typedef struct iconwind *ICONWIND;

struct iconwind {
struct wind w;
	UWORD	*icon;
	WORD	colors[2];
	WIND	wind;
};

WORD	iw_new __PROTO((int wsid, int x, int y, char *name,
						UWORD *icon, int fcolor, int bcolor, WIND wind));

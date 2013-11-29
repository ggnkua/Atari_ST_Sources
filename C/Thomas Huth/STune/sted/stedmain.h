/* ****** stedmain.h ****** */

#include <aes.h>
#include <vdi.h>

#include "stunedef.h"
#include "level.h"


/* ** Enable the following define for a restriced editor version: ** */
/*#define RESTRIC_STED*/


extern int vhndl;
extern int deskx, desky, deskw, deskh;
extern int wihndl;
extern GRECT wi;
extern int mausx, mausy, mausk, klicks;
extern int kstate, key;
extern int msgbuf[8];
extern short rwx, rwy;
extern short rww, rwh, r_width, r_height;
extern int newpal[16][3];
extern MFDB scrnmfdb;
extern MFDB offscr;
extern MFDB bodenfdb;
extern MFDB einhfdb;
extern int bipp;
extern int endeflag;
extern SPIELFELD sfeld[128][128];
extern unsigned char acttile;
extern short smodus;
extern short tmodus;
extern GEB_D gebaeude_typ[12];
extern LEVEL_EINTRAG en[];
extern int en_anz;
extern int knete[2];
extern short tech_level;
extern short lvl_type;
extern unsigned long lvlid;

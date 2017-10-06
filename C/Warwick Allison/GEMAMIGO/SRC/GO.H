/* AmiGo Include */
/* MSG types for getinput() */

#ifndef __go_h
#define __go_h

#include "goplayutil.h"

#define INTERSECTIONMSG 1	/* User buttoned an intersection */
#define QUITMSG 2		/* User buttoned QUIT icon */
#define PLAYMSG 3
#define RESTARTMSG 4
#define PASSMSG 5

#define TRUE 1
#define FALSE 0

#define MAXGROUPS 100

#define PLACED 0
#define REMOVED 1

#define numPoints 19
#define maxPoint numPoints - 1

/*-- definitions used when counting up --*/

#define CNT_UNDECIDED	0
#define CNT_BLACK_TERR	1
#define CNT_WHITE_TERR	2
#define CNT_NOONE	3

/*-- macro functions --*/

#define LegalPoint(x,y)		(x>=0 && x<=18 && y>=0 && y<=18)
#define ForeachPoint(a,b)	for(a=0;a<19;a++) for (b=0;b<19;b++)

#ifdef BLACK
#undef BLACK
#endif
#ifdef WHITE
#undef WHITE
#endif
enum bVal {BLACK, WHITE, EMPTY};
typedef enum bVal sType;
struct Group
{
   enum bVal color;	/* The color of the group */
   short code,		/* The code used to mark stones in the group */
         count,		/* The number of stones in the group */
         internal,	/* The number of internal liberties */
         external,	/* The number of external liberties */
	 liberties,	/* The total number of liberties */
         eyes,		/* The number of eyes */
         alive,		/* A judgement of how alive this group is */
         territory;	/* The territory this group controls */
};

struct bRec
{
	enum bVal	Val;	/* What is at this intersection */
	short		xOfs,
			yOfs;
	short		mNum;
	short		GroupNum;	/* What group the stone belongs to */
	short		marked;	/* TRUE or FALSE */
};

#endif

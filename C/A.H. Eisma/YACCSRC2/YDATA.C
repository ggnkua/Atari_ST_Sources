/*
 * 26-Apr-91 (AE)  Moved part of YMAIN data to YDATA because of segment overflow
 *                 for HUGETAB configuration of YACC.
 */

# include <stdlib.h> 
# define y1imp yes
# define y2imp YES
# define y3imp YES
# include "dtxtrn.h" 

/* externals for data that is left behind in YMAIN, but referenced here */

extern struct looksets lkst[ ];
extern struct wset     wsets[ ];
extern struct ntsymb   nontrst[ ];

/* storage for grammar rules */

int                    mem0[ MEMSIZE ];   /* production storage */
int                  * mem      = mem0;
int                    nprod    = 1;      /* number of productions */
int                  * prdptr[ NPROD ];   /* pointers to descriptions of productions */
int                    levprd[ NPROD ];   /* precedence levels for the productions */

/* storage for the actions in the parser */

int                    amem[ ACTSIZE ];   /* action table storage */
int                  * memp     = amem;   /* next free action table position */

/* accumulators for statistics information */

struct wset          * zzcwp    = wsets;
int                    zzgoent  = 0;
int                    zzgobest = 0;
int                    zzacent  = 0;
int                    zzexcp   = 0;
int                    zzclose  = 0;
int                    zzsrconf = 0;
int                  * zzmemsz  = mem0;
int                    zzrrconf = 0;

/* Statics pulled from modules */

int                    peekline;          /* from gettok() */
int                    lastred;           /* the number of the last reduction of a state */

int                    defact[ NSTATES ]; /* the default actions of states */

int                  * ggreed   = lkst[ 0 ].lset;
int                  * pgo      = wsets[ 0 ].ws.lset;
int                  * yypgo    = &nontrst[ 0 ].tvalue;

int                    maxspr   = 0;      /* maximum spread of any entry */
int                    maxoff   = 0;      /* maximum offset into a array */
int                  * pmem     = mem0;
int                  * maxa;
int                    nxdb     = 0;
int                    adb      = 0;


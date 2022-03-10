/*
 *	Announce engine header
 *	(LazyTick project)
 *
 *	Public Domain. May be copied and sold freely.
 */

#define ANNDLEN 	BBSSTR+300 	/* max full announce line len, MUST BE > BBSSTR+ANNSKIP */
#define ANNSKIP		30 			/* indentation */
#define ANNLLEN 	ANNSKIP+45 	/* line len, MUST BE > ANNSKIP */

typedef struct _ticlog {
	char group[BBSSTR];
	char display[ANNDLEN];
	struct _ticlog *next;
} ANNTICK;

void announce_tic(BTICFILE *tic, char *group);
int process_announce(char *group, char *arearad, char *footer);
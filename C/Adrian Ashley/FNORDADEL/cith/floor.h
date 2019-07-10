/*
 * floor.h -- structures and definitions for Fnordadel floors
 *
 * 91Apr29 AA	Extracted from ctdl.h and other places
 */

#ifndef _FLOOR_H
#define _FLOOR_H

/*
 * floor stuff
 */
struct flTab {
    LABEL flName;		/* floor name				*/
    char flGen;			/* floor generation #			*/
    BOOL flInUse;		/* is this floor in use?		*/
} ;

#define LOBBYFLOOR	0	/* generation number and* table index	*/

#endif

/* CLUTCH.H */

#ifndef __CLUTCH

# define __CLUTCH

# include "portab.h"



/* Das Clutchmodul initialisieren */
BOOLEAN CLInitClutch( VOID );


/* Eine Clutchliste initialisieren. Ergebnis: Eine ID <> -1 */
WORD CLInitChain( VOID );


/* Einen Clutch der Gr”že 'clutchsize' anh„ngen */
VOID *CLAddClutch( WORD chain, LONG clutchsize );


/* Einen Clutch l”schen  */
BOOLEAN CLClearClutch( VOID *clutch );


/* Alle Clutches l”schen */
VOID CLClearAllClutches( VOID );


/* Den ersten Clutch erfragen */
VOID *CLGetFirstClutch( WORD chain );


/* Den folgenden Clutch erfragen */
VOID *CLGetNextClutch( WORD chain );



#endif
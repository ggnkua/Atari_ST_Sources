/*********************CLUSTALV.H*********************************************/
/****************************************************************************/

   /*
   Main header file for ClustalV.  Uncomment ONE of the following 4 lines
   depending on which compiler you wish to use.
   */

/* #define VMS 1		VAX VMS */

/*#define MAC 1		 	Think_C for MacIntosh */

#define MSDOS 1	 		/* Turbo C for PC's */

/*#define UNIX 1	 	Ultrix/Decstation or Gnu C for Sun */

/***************************************************************************/
/***************************************************************************/

#include "general.h"

#define MAXNAMES		10	/* Max chars read for seq. names */
#define MAXTITLES		60      /* Title length */
#define FILENAMELEN 	256             /* Max. file name length */
	
#define UNKNOWN   0
#define EMBLSWISS 1
#define PIR 	  2
#define PEARSON   3

#define PAGE_LEN       22   	/* Number of lines of help sent to screen */

#if VMS				/* Defaults for VAX VMS */
#define DIRDELIM ']'		/* Last character before file name in full file specs */
#define MAXLEN		4000	/* Maximum sequence length (including gaps) */
#define MAXN		150     /* Maximum number of sequences */
#define FSIZE	        15000   /* Work space for pairwise alignments */
#define LINELENGTH    	60      /* Output line length */
#define GCG_LINELENGTH 	50      /* Output line length for GCG output */

#elif MAC
#define DIRDELIM ':'
#define MAXLEN		2600
#define MAXN		30
#define FSIZE	        10000
#define LINELENGTH     	50
#define GCG_LINELENGTH 	50

#elif MSDOS
#define DIRDELIM '\\'
#define MAXLEN		1300
#define MAXN		30
#define FSIZE	        5000
#define LINELENGTH     	50
#define GCG_LINELENGTH 	50

#elif UNIX
#define DIRDELIM '/'
#define MAXLEN		4000
#define MAXN		150
#define FSIZE	 	15000
#define LINELENGTH     	60
#define GCG_LINELENGTH 	50
#endif

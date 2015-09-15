/*
	<aes.h>
	This header is "Public Domain".
	(P) 1992 by Markus M. Nick
	
	This header makes it easier to compile sources with both PureC/TurboC 
	and GNU-CC.  Now you needn't include different header files any more.
	
	Please send your comments and suggestions to:
		Markus_Nick@mz.maus.de
*/

#ifndef __AES__

#define	__TCC_COMPAT__ 1
#define	OBSPEC	U_OB_SPEC

extern short _global[];
#define	global	_global

#ifndef cdecl
#define cdecl /**/
#endif

/* this is the sort of MFDB PureC/TurboC supports */

#define	__MFDB__	1

typedef struct
{
	char		*fd_addr;    /* Addrerss of upper left corner of first*/
                                    /* plane of raster area. If NULL then   */
                                    /* MFDB is for a physical device        */
	short		fd_w;	    /* Form Width in Pixels                 */
	short		fd_h;       /* Form Height in Pixels                */
	short		fd_wdwidth; /* Form Width in shorts(fd_w/sizeof(int)*/
	short		fd_stand;   /* Form format 0= device spec 1=standard*/
	short		fd_nplanes; /* Number of memory planes              */
	short		fd_r1;      /* Reserved                             */
	short		fd_r2;      /* Reserved                             */
	short		fd_r3;      /* Reserved                             */
} MFDB;


#include <aesbind.h>

#define __AES__	1
#endif

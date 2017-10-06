/*****************************************************************************/
/*                                                                           */
/* Modul: XRSRCFIX.H                                                         */
/* Datum: 19.10.92                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __XRSRCFIX__
#define __XRSRCFIX__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

#ifndef __MYDIAL__
typedef struct
{
	USERBLK	ublk;
	UWORD	old_type;
} OBBLK;
#endif

typedef struct _xrsrcfix {
		OBBLK   *obblk;
		CICON   *cicon_table;
		WORD    farbtbl[256][32];
		ULONG   farbtbl2[256];
		WORD    is_palette;
		INT16    	rgb_palette[256][4];
		WORD 	num_cib;
	} XRSRCFIX;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

#endif /* __XRSRCFIX__ */


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
	UWORD		old_type;
} OBBLK;
#endif

#ifndef G_CICON
#define G_CICON         33      /* Farbicon-Objekttyp */

typedef struct cicon_data
{
	WORD num_planes;							/* number of planes in the following data          */
	WORD FAR *col_data;						/* pointer to color bitmap in standard form        */
	WORD FAR *col_mask;						/* pointer to single plane mask of col_data        */
	WORD FAR *sel_data;						/* pointer to color bitmap of selected icon        */
	WORD FAR *sel_mask;						/* pointer to single plane mask of selected icon   */
	struct cicon_data *next_res;	/* pointer to next icon for a different resolution */
}	CICON;

typedef struct cicon_blk
{
	ICONBLK monoblk;              /* default monochrome icon                         */
	CICON *mainlist;              /* list of color icons for different resolutions   */
}	CICONBLK;
#endif

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID init_xrsrc _((WORD vdi_handle, OBJECT *object, WORD num_obs, WORD num_cib, WORD palette[][4]));
GLOBAL VOID term_xrsrc _((WORD num_cib));

#endif /* __XRSRCFIX__ */


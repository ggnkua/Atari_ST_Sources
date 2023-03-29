/*****************************************************************************/
/*                                                                           */
/* Modul: XRSRC.H                                                            */
/* Datum: 18.02.92                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __XRSRC__
#define __XRSRC__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

typedef struct
{
  UWORD rsh_vrsn;				/* should be 3														     */
  UWORD rsh_extvrsn;		/* not used, initialised to 'IN' for Interface */
  ULONG rsh_object;
  ULONG rsh_tedinfo;
  ULONG rsh_iconblk; 		/* list of ICONBLKS			  				 	*/
  ULONG rsh_bitblk;
  ULONG rsh_frstr;
  ULONG rsh_string;
  ULONG rsh_imdata;			/* image data					  					*/
  ULONG rsh_frimg;
  ULONG rsh_trindex;
  ULONG rsh_nobs; 			/* counts of various structs 					*/
  ULONG rsh_ntree;
  ULONG rsh_nted;
  ULONG rsh_nib;
  ULONG rsh_nbb;
  ULONG rsh_nstring;
  ULONG rsh_nimages;
  ULONG rsh_rssize;			/* total bytes in resource   */
} RSXHDR;

/****** VARIABLES ************************************************************/

EXTERN WORD xrsrc_array[16];

/****** FUNCTIONS ************************************************************/

EXTERN WORD    xrsrc_load  _((CONST BYTE *re_lpfname, WORD *pglobal));
EXTERN WORD    xrsrc_free  _((WORD *pglobal));
EXTERN WORD    xrsrc_gaddr _((WORD re_gtype, WORD re_gindex, VOID *re_gaddr, WORD *pglobal));
EXTERN WORD    xrsrc_saddr _((WORD re_stype, WORD re_sindex, VOID *re_saddr, WORD *pglobal));
EXTERN WORD    xrsrc_obfix _((OBJECT *re_otree, WORD re_oobject));

EXTERN BOOLEAN init_xrsrc  _((WORD vdi_handle, RECT *desk, WORD gl_wbox, WORD gl_hbox));
EXTERN VOID    term_xrsrc  _((VOID));

#endif /* __XRSRC__ */

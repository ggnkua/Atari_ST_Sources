/*****************************************************************************/
/*                                                                           */
/* Modul: BMENU.H                                                            */
/* Datum: 03/04/90                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __BMENU__
#define __BMENU__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

GLOBAL FULLNAME icn_path;       /* path of icon files */
GLOBAL FILENAME icn_name;       /* name of icon files */

/****** FUNCTIONS ************************************************************/

GLOBAL VOID mdbinfo      _((BASE_SPEC *base_spec));

GLOBAL WORD mnewtable    _((WINDOWP base_window, SYSTABLE *tablep, WORD x, WORD y, WORD *ret_table));
GLOBAL WORD mnewfield    _((WINDOWP base_window, WORD table, SYSCOLUMN *colp, SYSINDEX *inxp, WORD *ret_field));
GLOBAL WORD mnewkey      _((WINDOWP base_window, WORD table, SYSINDEX *inxp, WORD *ret_key));

GLOBAL VOID micons       _((BASE_SPEC *base_spec));
GLOBAL VOID mdbparams    _((BASE_SPEC *base_spec));

#endif /* __BMENU__ */


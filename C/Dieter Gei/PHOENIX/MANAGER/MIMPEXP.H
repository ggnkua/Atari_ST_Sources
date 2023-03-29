/*****************************************************************************
 *
 * Module : MIMPEXP.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.04.94
 *
 *
 * Description: This module defines the import/export dialog box.
 *
 * History:
 * 04.04.94: Parameter loadfile replaced by loadinf in load_impexp
 * 01.09.91: Parameter updt_dialog in load_impexp added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __MIMPEXP__
#define __MIMPEXP__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

GLOBAL IMPEXPCFG impexpcfg;             /* set of import/export parameters */
GLOBAL FULLNAME  exp_path;              /* path of export files */

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_mimpexp _((VOID));
GLOBAL BOOLEAN term_mimpexp _((VOID));

GLOBAL VOID    get_impexp  _((IMPEXPCFG *impexpcfg));
GLOBAL VOID    set_impexp  _((IMPEXPCFG *impexpcfg));
GLOBAL BOOLEAN load_impexp _((BYTE *loadinf, BYTE *loadname, IMPEXPCFG *cfg, BOOLEAN updt_dialog));
GLOBAL BOOLEAN save_impexp _((FILE *savefile, BYTE *savename, IMPEXPCFG *cfg));

GLOBAL VOID    mimpexp     _((VOID));
GLOBAL VOID    mimport     _((DB *db, WORD table, BYTE *filename, BOOLEAN minimize));
GLOBAL VOID    mexport     _((DB *db, WORD table, WORD index, WORD dir, BYTE *filename, BOOLEAN minimize));

#endif /* __MIMPEXP__ */


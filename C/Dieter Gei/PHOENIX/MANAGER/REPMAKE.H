/*****************************************************************************
 *
 * Module : REPMAKE.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 28.07.94
 *
 *
 * Description: This module implements the report definition window.
 *
 * History:
 * 28.07.94: Parameter prn in do_report added
 * 19.03.94: Parameter copies in do_report added
 * 11.08.91: Parameter minimize in do_report added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __REPMAKE__
#define __REPMAKE__

/****** DEFINES **************************************************************/

#define REP_EDIT       0                /* user wants to edit report */
#define REP_OK         1                /* report checking was ok */
#define REP_CANCEL     2                /* user doesn't want to edit report */

#define REP_CMDBEGIN   '{'              /* begin of command */
#define REP_CMDEND     '}'              /* end of command */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_repmake _((VOID));
GLOBAL BOOLEAN term_repmake _((VOID));

GLOBAL WORD    check_report _((DB *db, WORD table, BYTE *report, WORD *cx, WORD *cy, WORD *starttable));
GLOBAL VOID    do_report    _((DB *db, WORD table, WORD inx, WORD dir, BYTE *report, BYTE *filename, WORD device, BOOLEAN minimize, LONG copies, BYTE *prn));

#endif /* __REPMAKE__ */


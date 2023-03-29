/*****************************************************************************
 *
 * Module : BATEXEC.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 23.09.93
 *
 *
 * Description: This module defines the batch process.
 *
 * History:
 * 23.09.93: Function get_parmnames added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __BATEXEC__
#define __BATEXEC__

/****** DEFINES **************************************************************/

#define BATCH_EDIT     0                /* user wants to edit batch */
#define BATCH_OK       1                /* batch checking was ok */
#define BATCH_CANCEL   2                /* user doesn't want to edit batch */

/****** TYPES ****************************************************************/

typedef struct
{
  BYTE  *cmd;                           /* name of command */
  ULONG parms;                          /* parameters for command */
} CMD;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WORD check_batch    _((DB *db, BYTE *batch, WORD *cx, WORD *cy));
GLOBAL VOID do_batch       _((DB *db, BYTE *batch, BYTE *batch_name));
GLOBAL VOID exec_batch     _((DB *db, BYTE *batch_name));
GLOBAL VOID flush_db       _((DB *db));

GLOBAL WORD get_numcmds    _((VOID));
GLOBAL CMD  *get_cmds      _((VOID));
GLOBAL BYTE *get_cmd       _((WORD which, BYTE *cmd));
GLOBAL BYTE *get_parmnames _((BYTE *cmd, BYTE *names));

#endif /* __BATEXE__ */


/*****************************************************************************
 *
 * Module : QBE.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 20.03.94
 *
 *
 * Description: This module defines the query definition window.
 *
 * History:
 * 20.03.93: Parameter saveas added
 * 18.05.91: Parameter sql_name added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __QBE__
#define __QBE__

/****** DEFINES **************************************************************/

#define CLASS_QBE     17                /* Class Query By Example */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_qbe       _((VOID));
GLOBAL BOOLEAN term_qbe       _((VOID));

GLOBAL WINDOWP crt_qbe        _((OBJECT *obj, OBJECT *menu, WORD icon, DB *db, WORD table, BYTE *sql, BYTE *sql_name));

GLOBAL BOOLEAN open_qbe       _((WORD icon, DB *db, WORD table, BYTE *sql, BYTE *sql_name));
GLOBAL BOOLEAN info_qbe       _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_qbe       _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN close_qbe      _((DB *db));

GLOBAL BYTE    *get_qbe       _((WINDOWP window, DB **db, BYTE *sql_name));
GLOBAL VOID    qbe_new        _((VOID));
GLOBAL VOID    qbe_old        _((WINDOWP window));
GLOBAL BOOLEAN qbe_save       _((WINDOWP window, BOOLEAN saveas));
GLOBAL VOID    qbe_execute    _((WINDOWP window));
GLOBAL VOID    qbe_complement _((WINDOWP window));
GLOBAL VOID    qbe_sort       _((WINDOWP window));

#endif /* __QBE__ */


/*****************************************************************************
 *
 * Module : REPORT.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 20.03.94
 *
 *
 * Description: This module defines the report definition window.
 *
 * History:
 * 20.03.93: Parameter saveas added
 * 04.11.93: Using fontdesc
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __REPORT__
#define __REPORT__

/****** DEFINES **************************************************************/

#define CLASS_REPORT  20                /* Class Report Window */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_report    _((VOID));
GLOBAL BOOLEAN term_report    _((VOID));

GLOBAL WINDOWP crt_report     _((OBJECT *obj, OBJECT *menu, WORD icon, DB *db, BYTE *report, BYTE *name, FONTDESC *fontdesc));

GLOBAL BOOLEAN open_report    _((WORD icon, DB *db, BYTE *report, BYTE *name, FONTDESC *fontdesc));
GLOBAL BOOLEAN info_report    _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_report    _((WINDOWP window, WORD icon));

GLOBAL VOID    print_report   _((WINDOWP window));

GLOBAL BOOLEAN close_report   _((DB *db));

GLOBAL VOID    report_new     _((VOID));
GLOBAL VOID    report_old     _((WINDOWP window));
GLOBAL BOOLEAN report_save    _((WINDOWP window, BOOLEAN saveas));
GLOBAL VOID    report_execute _((WINDOWP window));
GLOBAL BOOLEAN rep_exec       _((WINDOWP window, DB *db, WORD table, WORD inx, WORD dir));

#endif /* __REPORT__ */


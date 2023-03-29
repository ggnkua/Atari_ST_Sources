/*****************************************************************************
 *
 * Module : CALC.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 20.03.94
 *
 *
 * Description: This module defines the calc definition window.
 *
 * History:
 * 20.03.93: Parameter saveas added
 * 04.11.93: Using fontdesc
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __CALC__
#define __CALC__

/****** DEFINES **************************************************************/

#define CLASS_CALC  22                  /* Class Calc Window */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_calc    _((VOID));
GLOBAL BOOLEAN term_calc    _((VOID));

GLOBAL WINDOWP crt_calc     _((OBJECT *obj, OBJECT *menu, WORD icon, DB *db, WORD table, BYTE *calc, BYTE *name, FONTDESC *fontdesc));

GLOBAL BOOLEAN open_calc    _((WORD icon, DB *db, WORD table, BYTE *calc, BYTE *name, FONTDESC *fontdesc));
GLOBAL BOOLEAN info_calc    _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_calc    _((WINDOWP window, WORD icon));

GLOBAL VOID    print_calc   _((WINDOWP window));

GLOBAL BOOLEAN close_calc   _((DB *db));

GLOBAL VOID    calc_new     _((VOID));
GLOBAL VOID    calc_old     _((WINDOWP window));
GLOBAL BOOLEAN calc_save    _((WINDOWP window, BOOLEAN saveas));
GLOBAL VOID    calc_execute _((WINDOWP window));
GLOBAL VOID    calc_assign  _((WINDOWP window));
GLOBAL VOID    calc_remove  _((DB *db, WORD table));
GLOBAL BOOLEAN calc_exec    _((WINDOWP window, DB *db, WORD table, WORD inx, WORD dir));

#endif /* __CALC__ */


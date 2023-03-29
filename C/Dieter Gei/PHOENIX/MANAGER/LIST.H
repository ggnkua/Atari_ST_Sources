/*****************************************************************************
 *
 * Module : LIST.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 08.07.95
 *
 *
 * Description: This module defines the list window.
 *
 * History:
 * 08.07.95: CLASS_ALIST added
 * 18.05.94: Function search_dialog made global
 * 23.03.94: Parameter cont in funtion list_search added
 * 10.03.94: Function list_newfont added
 * 08.02.94: Function open_syslist added
 * 04.11.93: Using fontdesc
 * 11.09.93: Variables max_lines and max_columns removed
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __LIST__
#define __LIST__

/****** DEFINES **************************************************************/

#define CLASS_LIST   13                 /* Class List Window */
#define CLASS_QLIST  16                 /* Class Query List */
#define CLASS_RLIST  19                 /* Class Report List */
#define CLASS_CLIST  21                 /* Class Calc List */
#define CLASS_BLIST  23                 /* Class Batch List */
#define CLASS_ALIST  25                 /* Class Account List */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_list     _((VOID));
GLOBAL BOOLEAN term_list     _((VOID));

GLOBAL BOOLEAN icons_list    _((WORD src_obj, WORD dest_obj));
GLOBAL WINDOWP crt_list      _((OBJECT *obj, OBJECT *menu, WORD icon, DB *db, WORD table, WORD inx, WORD dir, WORD cols, WORD *columns, WORD *colwidth, FONTDESC *fontdesc, RECT *size, BYTE *name));

GLOBAL BOOLEAN open_list     _((WORD icon));
GLOBAL BOOLEAN info_list     _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_list     _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN print_list    _((DB *db, WORD table, WORD inx, WORD dir, WORD cols, WORD *columns, WORD *colwidth, WORD device, FONTDESC *fontdesc, RECT *size, BYTE *filename, BOOLEAN minimize));
GLOBAL BOOLEAN close_list    _((DB *db));
GLOBAL BOOLEAN open_syslist  _((DB *db, WORD table, FONTDESC *fontdesc, RECT *size, BOOLEAN minimize));
GLOBAL VOID    updt_lsall    _((DB *db, WORD table, BOOLEAN only_real, BOOLEAN updt_trash));
GLOBAL VOID    updt_lswin    _((WINDOWP window));
GLOBAL VOID    get_listinfo  _((WINDOWP window, ICON_INFO *iconinfo, BYTE *name));
GLOBAL VOID    set_qname     _((WINDOWP window, BYTE *name));
GLOBAL VOID    get_qname     _((WINDOWP window, BYTE *name));
GLOBAL LONG    list_addr     _((WINDOWP window, WORD obj));
GLOBAL VOID    action_list   _((WORD action, ICON_INFO *iconinfo, WINDOWP actwin));
GLOBAL VOID    list_newfont  _((WINDOWP window));
GLOBAL VOID    list_reverse  _((WINDOWP window));
GLOBAL VOID    list_search   _((WINDOWP window, BOOLEAN cont));
GLOBAL VOID    list_remove   _((WINDOWP window));
GLOBAL VOID    list_remsel   _((WINDOWP window));
GLOBAL BOOLEAN search_dialog _((DB *db, WORD table, WORD inx));

#endif /* __LIST__ */


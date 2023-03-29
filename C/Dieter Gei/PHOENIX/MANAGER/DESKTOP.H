/*****************************************************************************
 *
 * Module : DESKTOP.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 22.02.97
 *
 *
 * Description: This module implements the desktop.
 *
 * History:
 * 22.02.97: Function save_desktop added
 * 09.07.95: Account definitions added
 * 04.11.93: Parameter fontsize deleted from fill_virtual
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __DESKTOP__
#define __DESKTOP__

/****** DEFINES **************************************************************/

#if GEM & XGEM
#define CLASS_DESK    DESKWINDOW        /* Class Desktop Window */
#else
#define CLASS_DESK    DESK              /* Class Desktop Window */
#endif

#define OBJ_DISK      3                 /* write tables to disk */
#define OBJ_PRINT     4                 /* print tables */
#define OBJ_EXP       5                 /* export records */
#define OBJ_IMP       6                 /* import records */
#define OBJ_DEL       7                 /* delete records */
#define OBJ_UNDEL     8                 /* undelete records */
#define OBJ_EDIT      9                 /* edit records */
#define OBJ_REP      10                 /* report records */
#define OBJ_CLIP     11                 /* export records to clipboard */
#define OBJ_CALC     12                 /* calculate records */
#define OBJ_ACC      13                 /* account records */

#define FUNCMENUS   1000                /* function key menus */
#define MQNEW       1001
#define MQLIST      1002
#define MRNEW       1003
#define MRLIST      1004
#define MCNEW       1005
#define MCLIST      1006
#define	MBNEW       1007
#define	MBLIST      1008
#define	MANEW       1009
#define	MALIST      1010

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WINDOWP find_desk    _((VOID));
GLOBAL VOID    get_dxywh    _((WORD obj, RECT *border));
GLOBAL VOID    set_func     _((CONST BYTE *keys));
GLOBAL VOID    draw_func    _((VOID));
GLOBAL VOID    draw_key     _((WORD key));
GLOBAL VOID    set_meminfo  _((VOID));
GLOBAL VOID    miconify     _((WINDOWP window));
GLOBAL VOID    miremove     _((VOID));
GLOBAL VOID    morderdesk   _((VOID));
GLOBAL WORD    icon_avail   _((VOID));
GLOBAL VOID    get_invobjs  _((VOID *db, WORD table, SET inv_objs));
GLOBAL VOID    fill_virtual _((VOID *db, WORD table, WORD inx, LONG recs, LONG *recaddr, WORD cols, WORD *columns, WORD *colwidth));
GLOBAL LONG    add_virtual  _((WORD icon, LONG recs, LONG *recaddr));
GLOBAL BOOLEAN tbls_slctd   _((VOID));

GLOBAL VOID    save_desktop _((FILE *file));

GLOBAL WINDOWP crt_desktop  _((OBJECT *obj, OBJECT *menu, WORD icon));

GLOBAL BOOLEAN open_desktop _((WORD icon));
GLOBAL BOOLEAN info_desktop _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_desktop _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN init_desktop _((VOID));
GLOBAL BOOLEAN term_desktop _((VOID));

#endif /* __DESKTOP__ */


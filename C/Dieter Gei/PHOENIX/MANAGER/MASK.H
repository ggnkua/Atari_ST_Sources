/*****************************************************************************
 *
 * Module : MASK.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 21.02.95
 *
 *
 * Description: This module defines the mask window.
 *
 * History:
 * 21.02.95: Function med_first added
 * 07.12.94: Parameter window added to m_varsql2sql
 * 01.12.94: Function m_varsql2sql added
 * 14.05.94: Function mask_search added
 * 02.05.94: MASKINFO added
 * 07.10.93: mfix_iconbar added
 * 06.10.93: Parameter set removed in mset_info
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __MASK__
#define __MASK__

/****** DEFINES **************************************************************/

#define CLASS_MASK 18                 /* Class Mask Window */

/****** TYPES ****************************************************************/

typedef struct
{
  BOOLEAN clear;        /* clear fields after insert of record */
  BOOLEAN fsel;         /* show file select box automatically on entering field */
  BOOLEAN pospopup;     /* position cursor in popup listbox */
  BOOLEAN ask_delete;   /* ask if record should be deleted */
  BOOLEAN play_direct;  /* play blobs containing music on redraw */
  WORD    volume;       /* volume of sound */
} MASKCONFIG;

typedef struct
{
  WORD iconwidth;	/* width of iconbar */
  WORD iconheight;	/* height of iconbar */
  WORD infoheight;	/* height of infobox */
  WORD num_chars;	/* number of characters for combobox */
} MASKINFO;

/****** VARIABLES ************************************************************/

GLOBAL MASKCONFIG mask_config;
GLOBAL MASKINFO   mask_info;

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_mask    _((VOID));
GLOBAL BOOLEAN term_mask    _((VOID));

GLOBAL WINDOWP crt_mask     _((OBJECT *obj, OBJECT *menu, WORD icon, DB *db, WORD table, WORD inx, WORD dir, BYTE *maskname, KEY keyval, LONG address, VOID *db_buffer, RECT *rcSize, BOOL bCalcEntry));

GLOBAL BOOLEAN open_mask    _((WORD icon, DB *db, WORD table, WORD inx, WORD dir, BYTE *maskname, KEY keyval, LONG address, VOID *db_buffer, RECT *rcSize, BOOL bCalcEntry));
GLOBAL BOOLEAN info_mask    _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_mask    _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN close_mask   _((DB *db));
GLOBAL VOID    mmconfig     _((VOID));
GLOBAL VOID    get_mconfig  _((VOID));
GLOBAL VOID    set_mconfig  _((VOID));
GLOBAL WORD    find_index   _((BASE *base, WORD table, WORD col));
GLOBAL WORD    get_inxcols  _((BASE *base, WORD table, WORD inx, WORD *cols));
GLOBAL VOID    print_mask   _((WINDOWP window));
GLOBAL VOID    mmaskreverse _((WINDOWP window));
GLOBAL VOID    mask_search  _((WINDOWP window, BOOLEAN cont));
GLOBAL VOID    mset_info    _((WINDOWP window));
GLOBAL VOID    mset_buffer  _((WINDOWP window, DB *db, WORD table, LONG address));
GLOBAL VOID    mfix_iconbar _((WINDOWP window));
GLOBAL VOID    mjoin        _((WINDOWP window));
GLOBAL VOID    mchange      _((WINDOWP window, BYTE *mask_name));
GLOBAL VOID    med_first    _((WINDOWP window));
GLOBAL VOID    mask_menu    _((WINDOWP window, WORD title, WORD item));
GLOBAL VOID    m_do_undo    _((WINDOWP window, BOOLEAN draw_icons));
GLOBAL BOOLEAN m_varsql2sql _((WINDOWP window, DB *db, BYTE *pVarSql, BYTE *pSql));
GLOBAL VOID    col_popup    _((WINDOWP window, MKINFO *mk, BOOLEAN hide_curs));

#endif /* __MASK__ */


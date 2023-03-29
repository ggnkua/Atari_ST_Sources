/*****************************************************************************/
/*                                                                           */
/* Modul: BCLICK.H                                                           */
/* Datum: 18/01/91                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __BCLICK__
#define __BCLICK__

/****** DEFINES **************************************************************/

#define FRAME         2                 /* distance for box of tables */
#define BOX_LDIST     2                 /* leave this amount of pixels between textlines */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID     b_click      _((WINDOWP window, MKINFO *mk));
GLOBAL VOID     b_unclick    _((WINDOWP window));
GLOBAL VOID     b_get_shadow _((WORD out_handle, WORD wbox, WORD factor, WORD *width, WORD *height));
GLOBAL VOID     b_get_rect   _((WINDOWP window, WORD class, WORD obj, WORD table, RECT *rect, BOOLEAN frame, BOOLEAN shadow));
GLOBAL VOID     b_get_doc    _((BASE_SPEC *base_spec, WORD xfac, WORD yfac, LONG *docw, LONG *doch));
GLOBAL VOID     b_obj_clear  _((WINDOWP window, WORD class, SET objs, RECT *r));
GLOBAL SEL_SPEC b_find_objs  _((WINDOWP window, MKINFO *mk));

#endif /* __BCLICK__ */


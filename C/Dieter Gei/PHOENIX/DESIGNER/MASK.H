/*****************************************************************************/
/*                                                                           */
/* Modul: MASK.H                                                             */
/* Datum: 07/11/90                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __MASK__
#define __MASK__

/****** DEFINES **************************************************************/

#define CLASS_MASK 11                   /* Class mask window */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_mask      _((VOID));
GLOBAL BOOLEAN term_mask      _((VOID));

GLOBAL WINDOWP crt_mask       _((OBJECT *obj, OBJECT *menu, WORD icon, HLPMASK *hlpmask, BASE_SPEC *base_spec, WORD index, BOOLEAN new));

GLOBAL BOOLEAN open_mask      _((WORD icon, HLPMASK *hlpmask, BASE_SPEC *base_spec, WORD index, BOOLEAN new));
GLOBAL BOOLEAN info_mask      _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_mask      _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN close_masks    _((BASE_SPEC *base_spec));
GLOBAL VOID    save_mask      _((WINDOWP window));
GLOBAL VOID    print_mask     _((WINDOWP window));

#endif /* __MASK__ */


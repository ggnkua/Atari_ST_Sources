/*****************************************************************************/
/*                                                                           */
/* Modul: BASE.H                                                             */
/* Datum: 08/11/90                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __BASE__
#define __BASE__

/****** DEFINES **************************************************************/

#define CLASS_BASE 10                   /* Class database window */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_base      _((VOID));
GLOBAL BOOLEAN term_base      _((VOID));

GLOBAL WINDOWP crt_base       _((OBJECT *obj, OBJECT *menu, WORD icon, BYTE *basename, BASE_SPEC *base_spec, LRECT *doc, RECT *work));

GLOBAL BOOLEAN open_base      _((WORD icon, BYTE *basename, BASE_SPEC *base));
GLOBAL BOOLEAN info_base      _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_base      _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN close_bases    _((VOID));
GLOBAL VOID    save_base      _((WINDOWP window));
GLOBAL VOID    print_base     _((WINDOWP window));
GLOBAL VOID    reset_basefont _((WINDOWP window));

#endif /* __BASE__ */


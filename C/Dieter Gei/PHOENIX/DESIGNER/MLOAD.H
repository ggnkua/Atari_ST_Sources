/*****************************************************************************/
/*                                                                           */
/* Modul: MLOAD.H                                                            */
/* Datum: 02/01/91                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __MLOAD__
#define __MLOAD__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN m_new_mask  _((MASK_SPEC *mask_spec));
GLOBAL BOOLEAN m_load_mask _((MASK_SPEC *mask_spec));
GLOBAL BOOLEAN m_save_mask _((MASK_SPEC *mask_spec));
GLOBAL VOID    m_sort_mask _((MASK_SPEC *mask_spec));
GLOBAL VOID    m_wi_title  _((WINDOWP window));

#endif /* __MLOAD__ */


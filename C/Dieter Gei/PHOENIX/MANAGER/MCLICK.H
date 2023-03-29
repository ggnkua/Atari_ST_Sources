/*****************************************************************************
 *
 * Module : MCLICK.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 17.03.97
 *
 *
 * Description: This module defines the clicking inside a mask window.
 *
 * History:
 * 17.03.97: Function mGetPicFilename added
 * 11.03.97: Parameter is_graf added to m_find_obj
 * 21.04.95: Function m_is_editable added
 * 15.03.95: Parameter asked added to m_save_rec
 * 14.03.95: Function m_save_all added
 * 02.03.95: Function m_change_buffer added
 * 27.02.95: Parameter sub added to m_find_obj
 * 12.02.95: Function m_get_mask_spec added
 * 08.02.95: Function m_ed_next added
 * 02.02.95: Parameter bDrawAttributes added to m_all_fields
 * 27.01.95: Function m_calc_sm_attr added
 * 20.01.95: Parameter window changed to mask_spec in all interface functions
 * 18.01.95: Parameter window changed to mask_spec in m_get_rect, m_get_edrect
 * 10.01.95: Return value of m_sm_init changed from BOOL to WORD
 * 05.01.95: Function m_sm_init moved from mutil.h
 * 08.12.94: Parameter is_submask added to m_find_obj
 * 24.11.94: Functions m_all_submasks, m_clr_submasks added
 * 20.11.94: All defines and types moved to MASKOBJ.H which are not only used by MCLICK.C
 * 14.11.94: Type SUBMASK extended with xfac, yfac, xscroll, yscroll, m_text_extent added
 * 18.10.94: Type SUBMASK added
 * 12.10.94: Type PMASK_SPEC added
 * 07.10.94: Definitions for sub masks (MSUBMASK) added
 * 24.08.94: Variable stdbuttons in MASK_SPEC changed to sm_flags
 * 18.08.94: MASK_VERSION, SM_SHOW_INFO, SM_SHOW_MENU added
 * 19.05.94: Function m_search_full added
 * 14.04.94: MF_TRANSPARENT added
 * 07.12.93: #define ALT_CHAR, BUTTON, m_button_key added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __MCLICK__
#define __MCLICK__

/****** DEFINES **************************************************************/

#define DB_ADR(buffer) *(LONG *)buffer

#define SM_ATTR_HSLIDER  1	/* attributes in a submask */
#define SM_ATTR_VSLIDER  2
#define SM_ATTR_RECCOUNT 3

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID       m_init          (VOID);
GLOBAL VOID       m_exit          (VOID);

GLOBAL VOID       m_click         (MASK_SPEC *mask_spec, MKINFO *mk, BOOLEAN button);
GLOBAL VOID       m_unclick       (MASK_SPEC *mask_spec);
GLOBAL BOOL       m_button_key    (MASK_SPEC *mask_spec, MKINFO *mk);
GLOBAL WORD       m_get_rect      (MASK_SPEC *mask_spec, WORD out_handle, WORD class, MOBJECT *mobject, RECT *rect, FATTR *fattr);
GLOBAL RECT       m_get_edrect    (MASK_SPEC *mask_spec, MFIELD *mfield, BOOLEAN absolute);
GLOBAL VOID       m_get_doc       (MASK_SPEC *mask_spec, LONG *docw, LONG *doch);
GLOBAL PMASK_SPEC m_get_mask_spec (MASK_SPEC *mask_spec);
GLOBAL WORD       m_find_obj      (MASK_SPEC *mask_spec, MKINFO *mk, BOOLEAN *in_arrow, BOOLEAN *is_button, BOOLEAN *is_submask, BOOLEAN *is_graf, WORD *sub);
GLOBAL VOID       m_draw_field    (MASK_SPEC *mask_spec, WORD out_handle, MFIELD *mfield, RECT *r, FATTR *fattr, WORD strwidth, WORD edobj);
GLOBAL VOID       m_all_fields    (MASK_SPEC *mask_spec, BOOLEAN draw_submasks, BOOLEAN bDrawAttributes);
GLOBAL VOID       m_all_submasks  (MASK_SPEC *mask_spec);
GLOBAL VOID       m_clr_submasks  (MASK_SPEC *mask_spec);
GLOBAL WORD       m_sm_init       (MASK_SPEC *mask_spec);
GLOBAL WORD       m_edit_obj      (MASK_SPEC *mask_spec, WORD message, WORD wparam, MKINFO *mk);
GLOBAL WORD       m_ed_index      (MASK_SPEC *mask_spec, WORD index, WORD direction, MKINFO *mk);
GLOBAL WORD       m_ed_next       (MASK_SPEC *mask_spec, WORD index, WORD direction);
GLOBAL VOID       m_edopen        (MASK_SPEC *mask_spec);
GLOBAL BOOL       m_ed2field      (MASK_SPEC *mask_spec, WORD index, BOOLEAN draw);
GLOBAL WORD       m_name2picobj   (MASK_SPEC *mask_spec, BYTE *filename);
GLOBAL VOID       m_obj2pos       (MASK_SPEC *mask_spec, WORD obj, RECT *r);
GLOBAL VOID       m_pos2obj       (MASK_SPEC *mask_spec, WORD obj, RECT *r);
GLOBAL VOID       m_exit_pic      (MASK_SPEC *mask_spec, WORD pic);
GLOBAL VOID       m_exit_rec      (MASK_SPEC *mask_spec, WORD null_mode, BOOLEAN rec_unlock, BOOLEAN test_checkboxes);
GLOBAL BOOL       m_save_rec      (MASK_SPEC *mask_spec, WORD *edobj, BOOLEAN ask);
GLOBAL BOOL       m_save_all      (MASK_SPEC *mask_spec, WORD *edobj);
GLOBAL VOID       m_setdirty      (MASK_SPEC *mask_spec, BOOLEAN dirty);
GLOBAL VOID       m_change_buffer (MASK_SPEC *mask_spec);
GLOBAL BOOL       m_vread         (MASK_SPEC *mask_spec, WORD vtable, VOID *buffer, CURSOR *cursor, LONG address, BOOLEAN modify);
GLOBAL VOID       m_draw_cr       (WORD out_handle, WORD x, WORD y, WORD hbox, BOOLEAN selected, WORD color, WORD bk_color, BOOLEAN checkbox);
GLOBAL VOID       m_winame        (MASK_SPEC *mask_spec);
GLOBAL BOOL       m_test_null     (BASE *base, WORD table, WORD field, VOID *buffer, BOOLEAN show_error);
GLOBAL VOID       m_print         (MASK_SPEC *mask_spec);
GLOBAL VOID       m_search_full   (MASK_SPEC *mask_spec, BOOLEAN cont);
GLOBAL VOID       m_text_extent   (WORD vdi_handle, BYTE *text, BOOLEAN incl_effects, WORD *width, WORD *height);
GLOBAL RECT       m_calc_sm_attr  (WORD vdi_handle, SUBMASK *submask, RECT *frame, WORD attr, WORD *h);
GLOBAL BOOLEAN    m_is_editable   (MOBJECT *mobject);
GLOBAL VOID       mGetPicFilename (MASK_SPEC *mask_spec, BYTE *pPicFilename, BYTE *pFilename);

#endif /* __MCLICK__ */


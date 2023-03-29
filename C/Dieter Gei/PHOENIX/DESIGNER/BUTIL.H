/*****************************************************************************/
/*                                                                           */
/* Modul: BUTIL.H                                                            */
/* Datum: 24/11/90                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __BUTIL__
#define __BUTIL__

/****** DEFINES **************************************************************/

#define ERR_ADD_TBL  -1                 /* error in adding table */
#define ERR_ADD_COL  -2                 /* error in adding column */
#define ERR_ADD_INX  -3                 /* error in adding index */
#define ERR_ADD_ICN  -4                 /* error in adding icon */
#define ERR_ADD_LUR  -5                 /* error in adding lookup rule */

#define ERR_DEL_TBL  -1                 /* error in deleting table */
#define ERR_DEL_COL  -2                 /* error in deleting column */
#define ERR_DEL_INX  -3                 /* error in deleting index */
#define ERR_DEL_ICN  -4                 /* error in deleting icon */
#define ERR_NODELINX -5                 /* user selected CANCEL on deleting index */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN is_tunique   _((BASE_SPEC *base_spec, TABLENAME name));
GLOBAL BOOLEAN is_funique   _((BASE_SPEC *base_spec, WORD table, FIELDNAME name));
GLOBAL BOOLEAN is_kunique   _((BASE_SPEC *base_spec, WORD table, FIELDNAME name));

GLOBAL BOOLEAN check_table  _((BASE_SPEC *base_spec, WORD amount));
GLOBAL BOOLEAN check_field  _((BASE_SPEC *base_spec, WORD amount));
GLOBAL BOOLEAN check_key    _((BASE_SPEC *base_spec, WORD amount));
GLOBAL BOOLEAN check_icon   _((BASE_SPEC *base_spec, WORD amount));
GLOBAL BOOLEAN check_lookup _((BASE_SPEC *base_spec, WORD amount));
GLOBAL WORD    check_all    _((BASE_SPEC *base_spec, WORD tables, WORD fields, WORD keys));

GLOBAL WORD    add_table    _((BASE_SPEC *base_spec, TABLENAME name, UWORD flags));
GLOBAL WORD    add_field    _((BASE_SPEC *base_spec, WORD table, SYSCOLUMN *new_column, SYSINDEX *new_index));
GLOBAL WORD    add_key      _((BASE_SPEC *base_spec, WORD table, SYSINDEX *new_index));
GLOBAL WORD    add_icon     _((BASE_SPEC *base_spec, WORD *pmask, WORD *pdata, WORD width, WORD height));
GLOBAL WORD    add_lookup   _((BASE_SPEC *base_spec, WORD reftable, WORD refcolumn, WORD table, WORD column, UWORD flags));

GLOBAL WORD    del_table    _((BASE_SPEC *base_spec, WORD table));
GLOBAL WORD    del_field    _((BASE_SPEC *base_spec, WORD table, WORD field));
GLOBAL WORD    del_key      _((BASE_SPEC *base_spec, WORD table, WORD key));
GLOBAL WORD    del_icon     _((BASE_SPEC *base_spec, WORD number));
GLOBAL VOID    del_rel      _((BASE_SPEC *base_spec, WORD number));
GLOBAL VOID    del_lookup   _((BASE_SPEC *base_spec, WORD number));

GLOBAL BOOLEAN move_field   _((BASE_SPEC *base_spec, WORD table, WORD src, WORD dst));
GLOBAL BOOLEAN move_key     _((BASE_SPEC *base_spec, WORD table, WORD src, WORD dst));
GLOBAL VOID    set_coladr   _((BASE_SPEC *base_spec, WORD table));

#endif /* __BUTIL__ */


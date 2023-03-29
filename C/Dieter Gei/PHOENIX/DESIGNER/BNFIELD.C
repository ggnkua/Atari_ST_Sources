/*****************************************************************************
 *
 * Module : BNFIELD.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 17.08.94
 *
 *
 * Description: This module implements the base new field dialog box.
 *
 * History:
 * 17.08.94: Set REORG flag if new field is index in click_nfield
 * 11.08.94: Set REORG flag if new index len is larger than old index len in chg_field
 * 27.10.93: ListBoxSetComboRect call modified in click_nfield
 * 25.10.93: LBS_DISABLED correctly initialized in set_nfield
 * 20.10.93: Callback routine improved
 * 14.10.93: New 3D listboxes used
 * 08.09.93: set_ptext -> set_str
 * 30.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "controls.h"
#include "dialog.h"
#include "bclick.h"
#include "bformat.h"
#include "butil.h"

#include "export.h"
#include "bnfield.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

typedef struct
{
  WORD      table;
  SYSCOLUMN *colp;
  SYSINDEX  *inxp;
  WINDOWP   base_window;
  WORD      blob_type;
  WORD      form_type;
  WORD      form_num;
  WORD      form_old;
  BOOLEAN   form_sel;
  BOOLEAN   primary;
} NF_SPEC;

typedef struct
{
  WORD button;
  WORD edit;
  WORD diff;
} OBJDATA;

/****** VARIABLES ************************************************************/

LOCAL WORD    exit_obj;		/* will be set for modal dialogue boxes */
LOCAL WORD    new_field;
LOCAL NF_SPEC nf_spec;

LOCAL OBJDATA objdata [NUM_TYPES] =
{
  {NFDTEXT,  NFDTLEN,  1},
  {NFDWORD,  NIL,      0},
  {NFDLONG,  NIL,      0},
  {NFDFLOAT, NIL,      0},
  {NIL,      NIL,      0},
  {NFDDATE,  NIL,      0},
  {NFDTIME,  NIL,      0},
  {NFDTSTAM, NIL,      0},
  {NFDBLOB,  NFDBLEN,  sizeof (LONG)},
  {NFDBLOB,  NFDBLEN,  sizeof (LONG)},
  {NFDBLOB,  NFDBLEN,  sizeof (LONG)},
  {NFDPIC,   NFDPLEN,  sizeof (LONG)},
  {NFDEXTRN, NIL,      1},
  {NFDDBADR, NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0}
}; /* objdata */

/****** FUNCTIONS ************************************************************/

LOCAL LONG    callback      _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    box           _((WINDOWP window, BOOLEAN grow, WINDOWP base_window, WORD class, WORD obj, WORD table));

LOCAL VOID    set_nfield    _((WINDOWP window, NF_SPEC *nf_spec));
LOCAL VOID    open_nfield   _((WINDOWP window));
LOCAL VOID    close_nfield  _((WINDOWP window));
LOCAL VOID    click_nfield  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_nfield    _((WINDOWP window, MKINFO *mk));

LOCAL VOID    chg_field     _((BASE_SPEC *base_spec, WORD table, SYSCOLUMN *new_column, SYSINDEX *new_index));

LOCAL WORD    get_ftype     _((OBJECT *newfield));
LOCAL LONG    get_fsize     _((OBJECT *newfield));
LOCAL UWORD   get_fflags    _((OBJECT *newfield));

LOCAL WORD    get_klen      _((WORD type, LONG size));
LOCAL UWORD   get_kflags    _((OBJECT *newfield));

LOCAL BOOLEAN xget_checkbox _((OBJECT *tree, WORD obj));
LOCAL VOID    set_fobjs     _((WINDOWP window));
LOCAL VOID    blob2str      _((WORD blob, BYTE *s));
LOCAL BOOLEAN search_lookup _((BASE_SPEC *base_spec, WORD *table, WORD *column));

/*****************************************************************************/

GLOBAL WORD mnewfield (base_window, table, colp, inxp, ret_field)
WINDOWP   base_window;
WORD      table;
SYSCOLUMN *colp;
SYSINDEX  *inxp;
WORD      *ret_field;

{
  WINDOWP window;
  WORD    field;
  WORD    ret;
  WORD    object;
  STRING  name;

  if (table < 0) return (NIL);

  if (colp == NULL)
    field = -1;
  else
    field = colp->number;

  if (field < 0)
    object = FNEWFIEL;
  else
    object = FCHGFIEL;

  strcpy (name, FREETXT (object));
  exit_obj  = NIL;
  new_field = FAILURE;

  window = search_window (CLASS_DIALOG, SRCH_ANY, NEWFIELD);

  if (window == NULL)
  {
    form_center (newfield, &ret, &ret, &ret, &ret);
    window = crt_dialog (newfield, NULL, NEWFIELD, name, WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_nfield;
      window->close   = close_nfield;
      window->click   = click_nfield;
      window->key     = key_nfield;
      window->special = (LONG)&nf_spec;
    } /* if */
  } /* if */
  else
    strcpy (window->name, name);

  if (window != NULL)
  {
    window->edit_obj = find_flags (newfield, ROOT, EDITABLE);
    window->edit_inx = NIL;
    window->exit_obj = NIL;

    nf_spec.table       = table;
    nf_spec.colp        = colp;
    nf_spec.inxp        = inxp;
    nf_spec.base_window = base_window;
    nf_spec.blob_type   = TYPE_VARBYTE;

    set_nfield (window, &nf_spec);

    if (! open_dialog (NEWFIELD)) hndl_alert (ERR_NOOPEN);
  } /* if */

  *ret_field = new_field;

  return (exit_obj);
} /* mnewfield */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP window;
  STRING  s;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)FREETXT (FBYTE + index));
    case LBN_DRAWITEM   : break;
    case LBN_SELCHANGE  : ListBoxGetText (tree, obj, index, s);
                          strcpy (get_str (tree, obj), s);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          nf_spec.blob_type = TYPE_VARBYTE + index;
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* callback */

/*****************************************************************************/

LOCAL VOID box (window, grow, base_window, class, obj, table)
WINDOWP window;
BOOLEAN grow;
WINDOWP base_window;
WORD    class;
WORD    obj;
WORD    table;

{
  RECT l, b;

  b_get_rect (base_window, class, obj, table, &l, TRUE, FALSE);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/

LOCAL VOID set_nfield (window, nf_spec)
WINDOWP window;
NF_SPEC *nf_spec;

{
  TABLE_INFO table_info;
  WORD       table, primary;
  WORD       index, abs_inx, field;
  WORD       lu_table, lu_field;
  WORD       obj, type, len;
  UWORD      flags, inx_flags;
  BOOLEAN    is_index;
  STRING     s;
  OBJDATA    *objptr;
  SYSCOLUMN  *colp;
  SYSINDEX   *inxp;
  BASE_SPEC  *base_spec;

  base_spec = (BASE_SPEC *)nf_spec->base_window->special;
  table     = nf_spec->table;
  colp      = nf_spec->colp;
  inxp      = nf_spec->inxp;

  ListBoxSetCallback (newfield, NFBTYPE, callback);
  ListBoxSetStyle (newfield, NFBTYPE, LBS_VSCROLL, FALSE);
  ListBoxSetLeftOffset (newfield, NFBTYPE, gl_wbox / 2);
  ListBoxSetCount (newfield, NFBTYPE, FLONG - FBYTE + 1, NULL);
  ListBoxSetCurSel (newfield, NFBTYPE, 0);

  v_tableinfo (base_spec, table, &table_info);

  if (colp == NULL)
    field = -1;
  else
    field = colp->number;

  strcpy (get_str (newfield, NFTABLE), table_info.name);
  set_str (newfield, NFFIELD,   "");
  set_str (newfield, NFAINDLE,  "");

  objptr = objdata;

  for (type = 0; type < NUM_TYPES; type++, objptr++)
    if (objptr->button != NIL)
    {
      undo_state (newfield, objptr->button, DISABLED);

      if (objptr->edit != NIL)
      {
        set_str (newfield, objdata [type].edit,  "");
        do_flags (newfield, objptr->edit, EDITABLE);
      } /* if */
    } /* if, for */

  ListBoxSetStyle (newfield, NFBTYPE, LBS_DISABLED, FALSE);

  undo_state (newfield, NFAMANDA, DISABLED);
  undo_state (newfield, NFAINDEX, DISABLED);

  set_rbutton (newfield, NFANONE, NFANONE, NFAUNIQU);

  do_state (newfield, NFALOOKU, DISABLED);
  do_state (newfield, NFAPRIMA, DISABLED);
  do_state (newfield, NFAUNIQU, DISABLED);
  do_state (newfield, NFAINDLT, DISABLED);

  undo_flags (newfield, NFAINDLE, EDITABLE);

  primary = find_primary (base_spec, table);

  nf_spec->primary  = primary == FAILURE;
  nf_spec->form_sel = FALSE;

  if (colp == NULL)                             /* it's a new field */
  {
    set_rbutton (newfield, NFDTEXT, NFDTEXT, NFDBLOB);
    set_str (newfield, NFDTLEN, "25");

    for (obj = NFAMANDA; obj <= NFAINDEX; obj++)
      if (OB_TYPE (newfield, obj) == G_USERDEF) set_checkbox (newfield, obj, FALSE);

    undo_flags (newfield, NFOK, DEFAULT);
    do_flags (newfield, NFNEXT, DEFAULT);
    undo_flags (newfield, NFNEXT, HIDETREE);

    do_state (newfield, NFOK, DISABLED);
    do_state (newfield, NFNEXT, DISABLED);

    nf_spec->blob_type = TYPE_VARBYTE;
    nf_spec->form_type = TYPE_CHAR;
    nf_spec->form_num  = nf_spec->form_type;
    nf_spec->form_old  = nf_spec->form_num;

    blob2str (nf_spec->blob_type, s);
    set_str (newfield, NFBTYPE, s);
  } /* if */
  else
  {
    flags     = colp->flags;
    is_index  = (flags & COL_ISINDEX) != 0;
    inx_flags = 0;

    if (is_index)
      if ((inxp == NULL) && (field != FAILURE)) /* try to find an inx pointer */
      {
        index = find_index (base_spec, table, field);
        if (index != FAILURE)
        {
          abs_inx   = absinx (base_spec, table, index);
          inxp      = &base_spec->sysindex [abs_inx];
          inx_flags = inxp->flags;

          if (primary == inxp->number) nf_spec->primary = TRUE;

          len = 0;

          if (HASWILD (inxp->type))
          {
            len = inxp->inxcols.cols [0].len;
            set_word (newfield, NFAINDLE, len);
          } /* if */

          if (len > 0)
          {
            do_flags (newfield, NFAINDLE, EDITABLE);
            undo_state (newfield, NFAINDLT, DISABLED);
          } /* if */
        } /* if */
      } /* if, if */

    set_str (newfield, NFFIELD, colp->name);

    do_flags (newfield, NFOK, DEFAULT);
    undo_flags (newfield, NFNEXT, DEFAULT);
    do_flags (newfield, NFNEXT, HIDETREE);

    undo_state (newfield, NFOK, DISABLED);
    undo_state (newfield, NFNEXT, DISABLED);

    type = colp->type;

    set_rbutton (newfield, objdata [type].button, NFDTEXT, NFDBLOB);

    if (objdata [type].edit != NIL)
    {
      sprintf (s, "%ld", colp->size - objdata [type].diff);
      set_str (newfield, objdata [type].edit, s);
    } /* if */

    nf_spec->blob_type = TYPE_VARBYTE;
    nf_spec->form_type = type;
    nf_spec->form_num  = colp->format;
    nf_spec->form_old  = nf_spec->form_num;

    blob2str (nf_spec->blob_type, s);
    set_str (newfield, NFBTYPE, s);
    if ((TYPE_VARBYTE <= type) && (type <= TYPE_VARLONG)) ListBoxSetCurSel (newfield, NFBTYPE, type - TYPE_VARBYTE);

    set_checkbox (newfield, NFAMANDA, flags & COL_MANDATORY);
    set_checkbox (newfield, NFADEFAU, flags & COL_DEFAULT);
    set_checkbox (newfield, NFAOUT,   flags & COL_OUTPUT);
    set_checkbox (newfield, NFALOOKU, flags & COL_LOOKUP);
    set_checkbox (newfield, NFAINDEX, is_index);

    lu_table = table;
    lu_field = field;

    if (search_lookup (base_spec, &lu_table, &lu_field))
    {
      colp = &base_spec->syscolumn [abscol (base_spec, lu_table, lu_field)];

      if (colp->flags & COL_ISINDEX)
        undo_state (newfield, NFALOOKU, DISABLED);
    } /* if */

    if (table_info.recs > 0)
      do_state (newfield, NFAMANDA, DISABLED);

    if (inx_flags & INX_PRIMARY) set_rbutton (newfield, NFAPRIMA, NFANONE, NFAUNIQU);
    if (inx_flags & INX_UNIQUE)  set_rbutton (newfield, NFAUNIQU, NFANONE, NFAUNIQU);

    if (is_index)
    {
      if (nf_spec->primary)
        undo_state (newfield, NFAPRIMA, DISABLED);

      undo_state (newfield, NFAUNIQU, DISABLED);

    } /* if */

    if (! (flags & (INS_FLAG | MOD_FLAG)))    /* don't let change data type */
    {
      objptr = objdata;

      for (type = 0; type < NUM_TYPES; type++, objptr++)
        if (objptr->button != NIL)
          do_state (newfield, objptr->button, DISABLED);

      ListBoxSetStyle (newfield, NFBTYPE, LBS_DISABLED, TRUE);
    } /* if */
  } /* else */

  set_fobjs (window);
} /* set_nfield */

/*****************************************************************************/

LOCAL VOID open_nfield (window)
WINDOWP window;

{
  WORD    field;
  NF_SPEC *nf_spec;

  nf_spec = (NF_SPEC *)window->special;

  if (nf_spec->colp == NULL)
    field = -1;
  else
    field = nf_spec->colp->number;

  box (window, TRUE, nf_spec->base_window, SEL_FIELD, field, nf_spec->table);
} /* open_nfield */

/*****************************************************************************/

LOCAL VOID close_nfield (window)
WINDOWP window;

{
  WORD    field;
  NF_SPEC *nf_spec;

  nf_spec = (NF_SPEC *)window->special;

  if (nf_spec->colp == NULL)
    field = -1;
  else
    field = nf_spec->colp->number;

  box (window, FALSE, nf_spec->base_window, SEL_FIELD, field, nf_spec->table);
} /* close_nfield */

/*****************************************************************************/

LOCAL VOID click_nfield (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD       table, field, found;
  WORD       keys, index, abs_inx;
  WORD       edit_obj, obj;
  WORD       old_num, form_num, form_type;
  BOOLEAN    fname_changed;
  BOOLEAN    field_unique;
  BOOLEAN    index_unique;
  FIELDNAME  fieldname;
  FIELDNAME  indexname;
  LONGSTR    s;
  BYTE       *p;
  WORD       type;
  LONG       size;
  UWORD      flags, old_kflags;
  WORD       klen;
  UWORD      kflags;
  FIELD_INFO field_info;
  INDEX_INFO index_info;
  SYSTABLE   *systable;
  SYSCOLUMN  new_column;
  SYSCOLUMN  *colp;
  SYSINDEX   new_index;
  SYSINDEX   *inxp;
  SYSTATTR   *systattr;
  NF_SPEC    *nf_spec;
  BASE_SPEC  *base_spec;

  nf_spec     = (NF_SPEC *)window->special;
  base_spec   = (BASE_SPEC *)nf_spec->base_window->special;
  table       = nf_spec->table;
  colp        = nf_spec->colp;
  inxp        = nf_spec->inxp;
  field       = FAILURE;
  index       = FAILURE;
  old_kflags  = 0;

  if (colp != NULL)
    if (colp->number >= 0)
    {
      field = colp->number;
      index = find_index (base_spec, table, field);

      if (index != FAILURE)
      {
        abs_inx    = absinx (base_spec, table, index);
        inxp       = &base_spec->sysindex [abs_inx];
        old_kflags = inxp->flags;
      } /* if */
    } /* if, if */

  set_fobjs (window);

  if ((NFDTEXT <= window->exit_obj) && (window->exit_obj <= NFDBLOB))
  {
    obj = get_rbutton (newfield, NFDTEXT);
    if ((obj != NFDTEXT) && (obj != NFDBLOB) && (obj != NFDPIC)) set_cursor (window, NFFIELD, NIL);
  } /* if */

  switch (window->exit_obj)
  {
    case NFBTYPE  : ListBoxSetComboRect (window->object, window->exit_obj, NULL, FLONG - FBYTE + 1);
                    ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                    ListBoxComboClick (window->object, window->exit_obj, mk);

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case NFFORMAT : form_type = nf_spec->form_type;
                    form_num  = nf_spec->form_num;
                    type      = get_ftype (newfield);

                    if (form_type != type) form_type = form_num = type;

                    old_num  = form_num;
                    form_num = mformat (nf_spec->base_window, FAILURE, form_type, form_num, get_str (newfield, NFFIELD));

                    if (form_num == FAILURE)
                      form_num = old_num;
                    else
                    {
                      nf_spec->form_type = form_type;
                      nf_spec->form_num  = form_num;
                      nf_spec->form_sel  = TRUE;
                    } /* if */

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case NFNEXT   :
    case NFOK     : get_ptext (newfield, NFFIELD, fieldname);

                    p = get_str (newfield, NFFIELD);
                    make_id (fieldname);
                    strcpy (indexname, fieldname);
                    fname_changed = strcmp (fieldname, p) != 0;

                    if (fname_changed)
                    {
                      sprintf (s, alerts [ERR_IDFIELD], fieldname);
                      open_alert (s);
                    } /* if */

                    if (colp != NULL) field = colp->number;

                    type     = get_ftype (newfield);
                    size     = get_fsize (newfield);
                    flags    = get_fflags (newfield);
                    keys     = 0;
                    systattr = &base_spec->systattr [table];

                    strcpy (field_info.name, fieldname);
                    found = v_fieldinfo (base_spec, table, FAILURE, &field_info);
                    field_unique = (found == FAILURE) || (found == field);

                    if (flags & COL_ISINDEX)
                    {
                      klen   = get_klen (type, size);
                      kflags = get_kflags (newfield) | (old_kflags & ~ (INX_PRIMARY | INX_UNIQUE));
                      strcpy (index_info.name, indexname);
                      found        = v_indexinfo (base_spec, table, FAILURE, &index_info);
                      index_unique = (found == FAILURE) || (found == index);
                    } /* if */
                    else
                      index_unique = TRUE;

                    if (! field_unique || ! index_unique)
                    {
                      sprintf (s, alerts [ERR_NOTUNIQUE], fieldname);
                      edit_obj = NFFIELD;

                      open_alert (s);                         /* field name was already used */
                      window->flags &= ~ WI_DLCLOSE;          /* don't close window */
                      undo_state (window->object, window->exit_obj, SELECTED);
                      draw_object (window, window->exit_obj);
                      window->edit_obj = edit_obj;
                      window->edit_inx = NIL;
                      return;
                    } /* if */

                    if (flags & COL_ISINDEX) keys = 1;

                    strcpy (new_column.name, fieldname);
                    new_column.table  = table;
                    new_column.number = field;
                    new_column.type   = type;
                    new_column.size   = size;
                    new_column.flags  = flags;

                    if (nf_spec->form_type == type)
                      new_column.format = nf_spec->form_num;
                    else
                    {
                      new_column.format = new_column.type;

                      if (nf_spec->form_old >= NUM_TYPES)       /* user defined format */
                        if (nf_spec->form_old != new_column.format) hndl_alert (ERR_FORMATLOST);
                    } /* else */

                    mem_set (&new_index, 0, sizeof (SYSINDEX));
                    strcpy (new_index.name, indexname);
                    new_index.type                 = type;
                    new_index.flags                = kflags;
                    new_index.inxcols.size         = sizeof (INXCOL);
                    new_index.inxcols.cols [0].col = field;
                    new_index.inxcols.cols [0].len = klen;

                    if (field < 0)                              /* its's a new field */
                    {
                      switch (check_all (base_spec, 0, 1, keys))
                      {
                        case ERR_ADD_TBL : hndl_alert (ERR_NOTABLES); return;
                        case ERR_ADD_COL : hndl_alert (ERR_NOFIELDS); return;
                        case ERR_ADD_INX : hndl_alert (ERR_NOKEYS);   return;
                      } /* if */

                      field = add_field (base_spec, table, &new_column, &new_index);

                      if (window->exit_obj == NFNEXT)
                      {
                        window->edit_obj = find_flags (newfield, ROOT, EDITABLE);
                        window->edit_inx = NIL;

                        nf_spec->colp = NULL;
                        nf_spec->inxp = NULL;
                        set_nfield (window, nf_spec);
                        window->flags &= ~ WI_DLCLOSE;      /* don't close window */
                        undo_state (window->object, window->exit_obj, SELECTED);
                        set_redraw (window, &window->scroll);
                      } /* if */

                      systable  = &base_spec->systable [table];
                      if ((! base_spec->new) && (systable->recs > 0) && (keys > 0)) base_spec->reorg = TRUE;
                    } /* if */
                    else                                    /* modify field & key */
                      chg_field (base_spec, table, &new_column, &new_index);

                    systattr->flags |= UPD_FLAG;
                    get_tblwh (base_spec, table, &systattr->width, &systattr->height);
                    set_redraw (nf_spec->base_window, &nf_spec->base_window->scroll);
                    base_spec->modified = TRUE;
                    break;
    case NFHELP   : hndl_help (HNEWFIEL);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  new_field = field;
  exit_obj  = window->exit_obj;
} /* click_nfield */

/*****************************************************************************/

LOCAL BOOLEAN key_nfield (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  FIELDNAME fieldname;
  LONG      size;

  switch (window->edit_obj)
  {
    case NFFIELD  :
    case NFDTLEN  :
    case NFDBLEN  :
    case NFDPLEN  : get_ptext (newfield, NFFIELD, fieldname);
                    make_id (fieldname);
                    size = get_fsize (newfield);

                    if (((*fieldname == EOS) || (size < 2)) == ! is_state (newfield, NFOK, DISABLED))
                    {
                      flip_state (newfield, NFOK, DISABLED);
                      draw_object (window, NFOK);
                      flip_state (newfield, NFNEXT, DISABLED);
                      draw_object (window, NFNEXT);
                    } /* if */
                    break;
  } /* switch */

  return (FALSE);
} /* key_nfield */

/*****************************************************************************/

LOCAL VOID chg_field (base_spec, table, new_column, new_index)
BASE_SPEC *base_spec;
WORD      table;
SYSCOLUMN *new_column;
SYSINDEX  *new_index;

{
  WORD      field, index;
  WORD      ret, i;
  WORD      abs_inx;
  WORD      typeref, typerel;
  UWORD     old_flags;
  LONGSTR   s;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;
  SYSINDEX  *sysindex, *inxp;
  SYSREL    *sysrel;
  SYSCOLUMN old_column;

  field     = new_column->number;
  index     = find_index (base_spec, table, field);
  systable  = &base_spec->systable [table];
  syscolumn = &base_spec->syscolumn [abscol (base_spec, table, field)];
  sysindex  = &base_spec->sysindex [absinx (base_spec, table, index)];

  old_column = *syscolumn;

  strcpy (syscolumn->name, new_column->name);
  syscolumn->type   = new_column->type;
  syscolumn->size   = new_column->size;
  syscolumn->format = new_column->format;
  syscolumn->flags  = new_column->flags | (syscolumn->flags & (INS_FLAG | MOD_FLAG)) | UPD_FLAG;

  if (new_column->size != old_column.size) set_coladr (base_spec, table);

  if (old_column.type != syscolumn->type)       /* eventually change key types */
  {
    inxp = &base_spec->sysindex [absinx (base_spec, table, 0)];
    for (i = 0; i < systable->indexes; i++, inxp++)
      inxp->type = get_ktype (base_spec, table, inxp);
  } /* if */

  if ((new_column->flags & COL_ISINDEX) && (old_column.flags & COL_ISINDEX))
  {
    old_flags       = sysindex->flags;
    sysindex->type  = new_index->type;
    sysindex->flags = new_index->flags | (sysindex->flags & ~ (INX_PRIMARY | INX_UNIQUE)) | UPD_FLAG;
    strcpy (sysindex->name, new_index->name);

    if ((sysindex->num_keys > 0) && (new_index->inxcols.cols [0].len > sysindex->inxcols.cols [0].len))
    {
      if ((! base_spec->new) && (systable->recs > 0)) base_spec->reorg = TRUE;

      base_spec->delkeys [base_spec->delkeyptr].table = table;
      base_spec->delkeys [base_spec->delkeyptr].key   = index;
      base_spec->delkeyptr++;
    } /* if */

    sysindex->inxcols.cols [0].len = new_index->inxcols.cols [0].len;

    sysrel = base_spec->sysrel;

    for (i = 0; i < base_spec->num_rels; i++, sysrel++)         /* check type of rels */
    {
      if ((sysrel->reftable == table) && (sysrel->refindex == sysindex->number) ||
          (sysrel->reltable == table) && (sysrel->relindex == sysindex->number))
      {
        abs_inx = absinx (base_spec, sysrel->reftable, sysrel->refindex);
        inxp    = &base_spec->sysindex [abs_inx];
        typeref = inxp->type;

        abs_inx = absinx (base_spec, sysrel->reltable, sysrel->relindex);
        inxp    = &base_spec->sysindex [abs_inx];
        typerel = inxp->type;
        if (typeref != typerel) hndl_alert (ERR_RELTYPE);
      } /* if */
    } /* for */

    if ((old_flags & INX_PRIMARY) && ! (sysindex->flags & INX_PRIMARY))
    {
      sysrel = base_spec->sysrel;

      for (i = 0; i < base_spec->num_rels; i++, sysrel++)
        if ((sysrel->reftable == table) && (sysrel->refindex == sysindex->number)) del_rel (base_spec, i);
    } /* if */
  } /* if */

  if ((new_column->flags & COL_ISINDEX) != (old_column.flags & COL_ISINDEX))
  {
    if (old_column.flags & COL_ISINDEX)         /* was a former index field and must be deleted */
    {
      ret = del_key (base_spec, table, index);

      if (ret == ERR_DEL_INX)
      {
        sprintf (s, alerts [ERR_DELKEY], base_spec->basename, sysindex->name);
        open_alert (s);
        syscolumn->flags |= COL_ISINDEX;
      } /* if */

      if (ret == ERR_NODELINX) syscolumn->flags |= COL_ISINDEX;
    } /* if */
    else                                        /* field is now indexed, so add it */
      if (add_key (base_spec, table, new_index) == ERR_ADD_INX)
      {
        hndl_alert (ERR_NOKEYS);
        syscolumn->flags &= ~ COL_ISINDEX;
      } /* if */
      else
        if ((! base_spec->new) && (systable->recs > 0)) base_spec->reorg = TRUE;
  } /* if */
} /* chg_field */

/*****************************************************************************/

LOCAL WORD get_ftype (newfield)
OBJECT *newfield;

{
  WORD obj;
  WORD type;

  obj = get_rbutton (newfield, NFDTEXT);

  switch (obj)
  {
    case NFDTEXT  : type = TYPE_CHAR;         break;
    case NFDWORD  : type = TYPE_WORD;         break;
    case NFDLONG  : type = TYPE_LONG;         break;
    case NFDFLOAT : type = TYPE_FLOAT;        break;
    case NFDDATE  : type = TYPE_DATE;         break;
    case NFDTIME  : type = TYPE_TIME;         break;
    case NFDTSTAM : type = TYPE_TIMESTAMP;    break;
    case NFDBLOB  : type = nf_spec.blob_type; break;
    case NFDPIC   : type = TYPE_PICTURE;      break;
    case NFDEXTRN : type = TYPE_EXTERN;       break;
    case NFDDBADR : type = TYPE_DBADDRESS;    break;
  } /* switch */

  return (type);
} /* get_ftype */

/*****************************************************************************/

LOCAL LONG get_fsize (newfield)
OBJECT *newfield;

{
  WORD   type;
  LONG   size;
  STRING s;

  type  = get_ftype (newfield);
  s [0] = EOS;

  if (type == TYPE_EXTERN) return ((LONG)MAX_FULLNAME + 1);     /* 128 chars for filename */

  if (objdata [type].edit == NIL)
    size = typesize (type, s);
  else
  {
    get_ptext (newfield, objdata [type].edit, s);
    size = atol (s) + objdata [type].diff;

    if (type == TYPE_VARWORD) size &= 0xFFFFFFFEL;
    if (type == TYPE_VARLONG) size &= 0xFFFFFFFCL;
  } /* else */

  return (size);
} /* get_fsize */

/*****************************************************************************/

LOCAL UWORD get_fflags (newfield)
OBJECT *newfield;

{
  UWORD flags;

  flags = GRANT_ALL;

  if (xget_checkbox (newfield, NFAMANDA)) flags |= COL_MANDATORY;
  if (xget_checkbox (newfield, NFADEFAU)) flags |= COL_DEFAULT;
  if (xget_checkbox (newfield, NFAOUT))   flags |= COL_OUTPUT;
  if (xget_checkbox (newfield, NFAINDEX)) flags |= COL_ISINDEX;
  if (xget_checkbox (newfield, NFALOOKU)) flags |= COL_LOOKUP;

  return (flags);
} /* get_fflags */

/*****************************************************************************/

LOCAL WORD get_klen (type, size)
WORD type;
LONG size;

{
  WORD len;
  LONG lDlgSize;

  switch (type)
  {
    case TYPE_CHAR   :
    case TYPE_CFLOAT :
    case TYPE_EXTERN : size--;       /* don't use closing '\0' */
                       lDlgSize = get_long (newfield, NFAINDLE);
                       if ((lDlgSize == 0) || is_null (TYPE_LONG, &lDlgSize)) lDlgSize = size;
                       len = (SHORT)min (lDlgSize, size);

                       if (len > MAX_KEYSIZE - 2)
                       {
                         len = MAX_KEYSIZE - 2;
                         hndl_alert (ERR_KEYLEN);
                       } /* if */
                       break;
    default          : len = 0;
                       break;
  } /* switch */

  return (len);
} /* get_klen */

/*****************************************************************************/

LOCAL UWORD get_kflags (newfield)
OBJECT *newfield;

{
  WORD  obj;
  UWORD flags;

  obj = get_rbutton (newfield, NFANONE);

  switch (obj)
  {
    case NFANONE  : flags = INX_NONE;    break;
    case NFAPRIMA : flags = INX_PRIMARY; break;
    case NFAUNIQU : flags = INX_UNIQUE;  break;
  } /* switch */

  return (flags);
} /* get_kflags */

/*****************************************************************************/

LOCAL BOOLEAN xget_checkbox (tree, obj)
OBJECT *tree;
WORD   obj;

{
  return (get_checkbox (tree, obj) && ! is_state (tree, obj, DISABLED));
} /* xget_checkbox */

/*****************************************************************************/

LOCAL VOID set_fobjs (window)
WINDOWP window;

{
  BOOLEAN   bHasWild;
  BOOLEAN   index_selected;
  BOOLEAN   flip_pu;            /* index attributes: primary, unique */
  BOOLEAN   mandatory;
  WORD      obj, sType;
  LONG      size;
  FIELDNAME fieldname;

  flip_pu = FALSE;

  index_selected = is_state (newfield, NFAINDEX, SELECTED);
  if (index_selected == is_state (newfield, NFAUNIQU, DISABLED)) flip_pu = TRUE;

  if (flip_pu)
  {
    if (nf_spec.primary)
    {
      flip_state (newfield, NFAPRIMA, DISABLED);
      draw_object (window, NFAPRIMA);
    } /* if */

    flip_state (newfield, NFAUNIQU, DISABLED);
    draw_object (window, NFAUNIQU);
  } /* if */

  sType    = get_ftype (newfield);
  bHasWild = HASWILD (sType);

  if ((index_selected && bHasWild) == ! is_flags (newfield, NFAINDLE, EDITABLE))
  {
    flip_flags (newfield, NFAINDLE, EDITABLE);
    draw_object (window, NFAINDLE);
    flip_state (newfield, NFAINDLT, DISABLED);
    draw_object (window, NFAINDLT);
  } /* if */

  mandatory = index_selected && (get_kflags (newfield) & (INX_PRIMARY | INX_UNIQUE)) != 0;
  if (mandatory)
    if (mandatory == ! is_state (newfield, NFAMANDA, SELECTED))
    {
      flip_state (newfield, NFAMANDA, SELECTED);
      draw_object (window, NFAMANDA);
    } /* if, if */

  mandatory = xget_checkbox (newfield, NFAMANDA);
  if (! mandatory == ! is_state (newfield, NFADEFAU, DISABLED))
  {
    flip_state (newfield, NFADEFAU, DISABLED);
    draw_object (window, NFADEFAU);
  } /* if */

  switch (window->exit_obj)
  {
    case NFDTEXT  : set_cursor (window, NFDTLEN, NIL); break;
    case NFDBLOB  : set_cursor (window, NFDBLEN, NIL); break;
    case NFDPIC   : set_cursor (window, NFDPLEN, NIL); break;
  } /* switch */

  undo_flags (newfield, NFDTLEN, EDITABLE);
  undo_flags (newfield, NFDBLEN, EDITABLE);
  undo_flags (newfield, NFDPLEN, EDITABLE);

  obj = get_rbutton (newfield, NFDTEXT);

  switch (obj)
  {
    case NFDTEXT  : do_flags (newfield, NFDTLEN, EDITABLE); break;
    case NFDBLOB  : do_flags (newfield, NFDBLEN, EDITABLE); break;
    case NFDPIC   : do_flags (newfield, NFDPLEN, EDITABLE); break;
  } /* switch */

  get_ptext (newfield, NFFIELD,  fieldname);
  make_id (fieldname);
  size = get_fsize (newfield);

  if (((*fieldname == EOS) || (size < 2)) == ! is_state (newfield, NFOK, DISABLED))
  {
    flip_state (newfield, NFOK, DISABLED);
    draw_object (window, NFOK);
    flip_state (newfield, NFNEXT, DISABLED);
    draw_object (window, NFNEXT);
  } /* if */
} /* set_fobjs */

/*****************************************************************************/

LOCAL VOID blob2str (blob, s)
WORD blob;
BYTE *s;

{
  switch (blob)
  {
    case TYPE_VARBYTE : strcpy (s, "BYTE"); break;
    case TYPE_VARWORD : strcpy (s, "WORD"); break;
    case TYPE_VARLONG : strcpy (s, "LONG"); break;
    default           : strcpy (s, "????"); break;
  } /* switch */
} /* blob2str */

/*****************************************************************************/

LOCAL BOOLEAN search_lookup (base_spec, table, column)
BASE_SPEC *base_spec;
WORD      *table, *column;

{
  WORD      i;
  SYSLOOKUP *syslookup;

  if (*column == FAILURE) return (FALSE);

  syslookup = base_spec->syslookup;

  for (i = 0; i < base_spec->num_lookups; i++, syslookup++)
    if ((syslookup->table == *table) && (syslookup->column == *column))
    {
      *table  = syslookup->reftable;
      *column = syslookup->refcolumn;

      return (TRUE);
    } /* if, for */

  return (FALSE);
} /* search_lookup */

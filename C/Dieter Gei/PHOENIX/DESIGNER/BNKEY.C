/*****************************************************************************
 *
 * Module : BNKEY.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.01.95
 *
 *
 * Description: This module implements the base new key dialog box.
 *
 * History:
 * 04.01.95: Using new function names of controls module
 * 04.11.93: bk_color WHITE added in calll to ListBoxSetFont
 * 30.10.93: LBS_TOUCHEXIT removed in call to ListBoxSetStyle
 * 29.10.93: Call to mem_move in del_item corrected
 * 23.10.93: New 3D listboxes used
 * 08.09.93: set_ptext -> set_str
 * 30.08.93: Modifications for user defined buttons added
 * 23.08.93: New 3d controls support added
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
#include "butil.h"

#include "export.h"
#include "bnkey.h"

/****** DEFINES **************************************************************/

#define MAX_NAME 16             /* max name length in dialog box */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD     table;
  WINDOWP  base_window;
  WORD     sel_column;
  WORD     sel_index;
  WORD     act_size;
  SYSINDEX new_index;
} NK_SPEC;

/****** VARIABLES ************************************************************/

LOCAL WORD    exit_obj;         /* will be set for modal dialogue boxes */
LOCAL WORD    new_key;
LOCAL NK_SPEC nk_spec;
LOCAL BYTE    *columns;         /* pointer to column names */
LOCAL BYTE    *indexes;         /* pointer to index names */
LOCAL WORD    inx_width;        /* width of index scroll area */

/****** FUNCTIONS ************************************************************/

LOCAL LONG    col_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    inx_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    box           _((WINDOWP window, BOOLEAN grow, WINDOWP base_window, WORD class, WORD obj, WORD table));

LOCAL VOID    set_nkey      _((NK_SPEC *nk_spec));
LOCAL VOID    open_nkey     _((WINDOWP window));
LOCAL VOID    close_nkey    _((WINDOWP window));
LOCAL VOID    click_nkey    _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_nkey      _((WINDOWP window, MKINFO *mk));

LOCAL BOOLEAN is_part       _((WORD col, SYSINDEX *inxp));
LOCAL VOID    set_indexlen  _((WORD type, LONG size));
LOCAL VOID    set_columns   _((BASE_SPEC *base_spec, WORD table, SYSINDEX *inxp));
LOCAL VOID    set_indexes   _((BASE_SPEC *base_spec, WORD table, SYSINDEX *inxp, NK_SPEC *nk_spec));
LOCAL VOID    deselect      _((OBJECT *tree, WORD obj));
LOCAL VOID    del_item      _((OBJECT *tree, WORD obj, BYTE *itemlist, WORD itemsize));
LOCAL VOID    del_keycol    _((SYSINDEX *inxp, WORD item));

LOCAL UWORD   get_kflags   _((VOID));

/*****************************************************************************/

GLOBAL VOID init_newkey ()

{
  inx_width = newkey [NKKEYS].ob_width / gl_wbox;
} /* init_newkey */

/*****************************************************************************/

GLOBAL WORD mnewkey (base_window, table, inxp, ret_key)
WINDOWP  base_window;
WORD     table;
SYSINDEX *inxp;
WORD     *ret_key;

{
  WINDOWP window;
  WORD    index;
  WORD    ret;
  WORD    object;
  STRING  name;

  if (table < 0) return (NIL);

  if (inxp == NULL)
    index = -1;
  else
    index = inxp->number;

  if (index < 0)
    object = FNEWKEY;
  else
    object = FCHGKEY;

  strcpy (name, FREETXT (object));
  exit_obj = NIL;
  new_key  = FAILURE;

  window = search_window (CLASS_DIALOG, SRCH_ANY, NEWKEY);

  if (window == NULL)
  {
    form_center (newkey, &ret, &ret, &ret, &ret);
    window = crt_dialog (newkey, NULL, NEWKEY, name, WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_nkey;
      window->close   = close_nkey;
      window->click   = click_nkey;
      window->key     = key_nkey;
      window->special = (LONG)&nk_spec;
    } /* if */
  } /* if */
  else
    strcpy (window->name, name);

  if (window != NULL)
  {
    window->edit_obj = find_flags (newkey, ROOT, EDITABLE);
    window->edit_inx = NIL;

    nk_spec.table       = table;
    nk_spec.base_window = base_window;
    nk_spec.sel_column  = FAILURE;
    nk_spec.sel_index   = FAILURE;
    nk_spec.act_size    = 0;

    if (inxp == NULL)   /* it's a new index */
    {
      inxp = &nk_spec.new_index;
      mem_set (inxp, 0, sizeof (SYSINDEX));
      inxp->number = FAILURE;
    } /* if */
    else
      nk_spec.new_index = *inxp;

    set_nkey (&nk_spec);

    ListBoxSetSpec (newkey, NKFIELDS, (LONG)window);
    ListBoxSetSpec (newkey, NKKEYS,   (LONG)window);

    if (! open_dialog (NEWKEY)) hndl_alert (ERR_NOOPEN);
  } /* if */

  *ret_key = new_key;

  return (exit_obj);
} /* mnewkey */

/*****************************************************************************/

LOCAL LONG col_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  RECT         r;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)&columns [index * sizeof (FIELDNAME)]);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                          r    = lb_ownerdraw->rc_item;
                          r.w  = 2 * gl_wbox;
                          DrawOwnerIcon (lb_ownerdraw, &r, &col_icon, text, 2);
                          break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* col_callback */

/*****************************************************************************/

LOCAL LONG inx_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  RECT         r;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)&indexes [index * inx_width]);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                          r    = lb_ownerdraw->rc_item;
                          r.w  = 2 * gl_wbox;
                          DrawOwnerIcon (lb_ownerdraw, &r, &mul_icon, text, 2);
                          break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* inx_callback */

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

LOCAL VOID set_nkey (nk_spec)
NK_SPEC *nk_spec;

{
  WORD       table, primary;
  WORD       multi;
  LONG       num_keys, size;
  UWORD      inx_flags;
  TABLE_INFO table_info;
  SYSINDEX   *inxp;
  BASE_SPEC  *base_spec;

  base_spec = (BASE_SPEC *)nk_spec->base_window->special;
  table     = nk_spec->table;
  inxp      = &nk_spec->new_index;
  num_keys  = 0;
  inx_flags = 0;
  multi     = 0;

  if (v_tableinfo (base_spec, table, &table_info) != FAILURE)
  {
    strcpy (get_str (newkey, NKTABLE), table_info.name);

    set_str (newkey, NKINDEX,  "");
    set_str (newkey, NKINDLEN, "");
    set_str (newkey, NKSIZE,   "");

    do_state (newkey, NKFHEAD,  DISABLED);
    do_state (newkey, NKMHEAD,  DISABLED);
    do_state (newkey, NKCOPY,   DISABLED);
    do_state (newkey, NKUPDATE, DISABLED);
    do_state (newkey, NKDELETE, DISABLED);
    do_state (newkey, NKOK,     DISABLED);
    do_state (newkey, NKPRIMAR, DISABLED);

    undo_flags (newkey, NKINDLEN, EDITABLE);

    primary = find_primary (base_spec, table);

    if (primary == FAILURE)
      undo_state (newkey, NKPRIMAR, DISABLED);

    if (inxp->number != FAILURE)
    {
      num_keys  = inxp->num_keys;
      inx_flags = inxp->flags;
      multi     = inxp->inxcols.size / sizeof (INXCOL);
      set_str (newkey, NKINDEX, inxp->name);
      if ((inxp->name [0]) && (multi > 1)) undo_state (newkey, NKOK, DISABLED);

      if (primary == inxp->number)
        undo_state (newkey, NKPRIMAR, DISABLED);
    } /* if */

    if (num_keys == 0)
    {
      undo_state (newkey, NKFHEAD, DISABLED);
      undo_state (newkey, NKMHEAD, DISABLED);
    } /* if */

    set_rbutton (newkey, NKNONE, NKNONE, NKUNIQUE);
    if (inx_flags & INX_PRIMARY) set_rbutton (newkey, NKPRIMAR, NKNONE, NKUNIQUE);
    if (inx_flags & INX_UNIQUE)  set_rbutton (newkey, NKUNIQUE, NKNONE, NKUNIQUE);

    ListBoxSetCallback (newkey, NKFIELDS, col_callback);
    ListBoxSetStyle (newkey, NKFIELDS, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE, TRUE);
    ListBoxSetLeftOffset (newkey, NKFIELDS, gl_wbox / 2);
    ListBoxSetCount (newkey, NKFIELDS, 0, NULL);
    ListBoxSetCurSel (newkey, NKFIELDS, FAILURE);
    ListBoxSetTopIndex (newkey, NKFIELDS, 0);

    ListBoxSetCallback (newkey, NKKEYS, inx_callback);
    ListBoxSetFont (newkey, NKKEYS, FONT_SYSTEM, gl_point, TXT_NORMAL, BLACK, WHITE);
    ListBoxSetStyle (newkey, NKKEYS, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE, TRUE);
    ListBoxSetLeftOffset (newkey, NKKEYS, gl_wbox);
    ListBoxSetCount (newkey, NKKEYS, multi, NULL);
    ListBoxSetCurSel (newkey, NKKEYS, FAILURE);
    ListBoxSetTopIndex (newkey, NKKEYS, 0);

    if ((colors >= 16) && (gl_hbox > 8))
    {
      ListBoxSetStyle (newkey, NKFIELDS, LBS_OWNERDRAW, col_icon.data != NULL);
      ListBoxSetStyle (newkey, NKKEYS,   LBS_OWNERDRAW, mul_icon.data != NULL);
    } /* if */

    size    = sizeof (FIELDNAME);
    columns = mem_alloc (table_info.cols * size);

    if (columns != NULL) set_columns (base_spec, table, inxp);

    size    = inx_width;
    indexes = mem_alloc (MAX_INXCOLS * size);

    if (indexes != NULL) set_indexes (base_spec, table, inxp, nk_spec);
  } /* if */
} /* set_nkey */

/*****************************************************************************/

LOCAL VOID open_nkey (window)
WINDOWP window;

{
  WORD      index, class, obj;
  NK_SPEC   *nk_spec;
  BASE_SPEC *base_spec;

  nk_spec   = (NK_SPEC *)window->special;
  base_spec = (BASE_SPEC *)nk_spec->base_window->special;
  index     = nk_spec->new_index.number;
  class     = inx2obj (base_spec, nk_spec->table, index, &obj);

  box (window, TRUE, nk_spec->base_window, class, obj, nk_spec->table);
} /* open_nkey */

/*****************************************************************************/

LOCAL VOID close_nkey (window)
WINDOWP window;

{
  WORD      index, class, obj;
  NK_SPEC   *nk_spec;
  BASE_SPEC *base_spec;

  mem_free (columns);
  mem_free (indexes);

  nk_spec   = (NK_SPEC *)window->special;
  base_spec = (BASE_SPEC *)nk_spec->base_window->special;
  index     = nk_spec->new_index.number;
  class     = inx2obj (base_spec, nk_spec->table, index, &obj);

  box (window, FALSE, nk_spec->base_window, class, obj, nk_spec->table);
} /* close_nkey */

/*****************************************************************************/

LOCAL VOID click_nkey (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BOOLEAN    dclick, condition;
  WORD       table, field, found;
  WORD       sel_column;
  WORD       sel_index;
  WORD       index, abs_inx;
  WORD       multi, i;
  WORD       typeref, typerel;
  UWORD      old_flags;
  BOOLEAN    index_unique;
  FIELDNAME  indexname;
  FIELD_INFO field_info;
  STRING     indexlen;
  LONG       size;
  WORD       act_size;
  WORD       keysize, max_len;
  LONGSTR    s;
  INDEX_INFO index_info;
  BYTE       *mem, *p;
  SYSTABLE   *systable;
  SYSCOLUMN  *colp;
  SYSINDEX   *sysindex, *inxp;
  SYSTATTR   *systattr;
  SYSREL     *sysrel;
  NK_SPEC    *nk_spec;
  BASE_SPEC  *base_spec;

  nk_spec    = (NK_SPEC *)window->special;
  base_spec  = (BASE_SPEC *)nk_spec->base_window->special;
  table      = nk_spec->table;
  sel_column = nk_spec->sel_column;
  sel_index  = nk_spec->sel_index;
  act_size   = nk_spec->act_size;
  inxp       = &nk_spec->new_index;
  systable   = &base_spec->systable [table];
  systattr   = &base_spec->systattr [table];
  dclick     = FALSE;

  if (inxp->num_keys == 0)
    if (window->exit_obj == NKFIELDS)
    {
      field = ListBoxClick (window->object, window->exit_obj, mk);

      if (field != FAILURE)
      {
        dclick = mk->breturn == 2;
        ListBoxGetText (window->object, window->exit_obj, field, field_info.name);
        sel_column = v_fieldinfo (base_spec, table, FAILURE, &field_info);

        if (sel_column != nk_spec->sel_column)
        {
          set_indexlen (field_info.type, field_info.size - 1);
          draw_object (window, NKINDLEN);
        } /* if */

        sel_index = nk_spec->sel_index = FAILURE;
        deselect (newkey, NKKEYS);
        nk_spec->sel_column = sel_column;
      } /* if */
    } /* if, if */

  if (inxp->num_keys == 0)
    if (window->exit_obj == NKKEYS)
    {
      index = ListBoxClick (window->object, window->exit_obj, mk);

      get_ptext (newkey, NKINDLEN, indexlen);
      if (*indexlen)
      {
        set_str (newkey, NKINDLEN, "");
        draw_object (window, NKINDLEN);
      } /* if */

      if (index != FAILURE)
      {
        sel_index = inxp->inxcols.cols [index].col;
        size      = inxp->inxcols.cols [index].len;
        v_fieldinfo (base_spec, table, sel_index, &field_info);
        set_indexlen (field_info.type, size);
        draw_object (window, NKINDLEN);
      } /* if */

      sel_column = nk_spec->sel_column = FAILURE;
      deselect (newkey, NKFIELDS);
      nk_spec->sel_index = sel_index;
    } /* if, if */

  keysize = 0;
  max_len = 0;
  colp    = NULL;
  multi   = inxp->inxcols.size / sizeof (INXCOL);

  if ((sel_column != FAILURE) || (sel_index != FAILURE))
  {
    if (sel_column != FAILURE) colp = &base_spec->syscolumn [abscol (base_spec, table, sel_column)];
    if (sel_index  != FAILURE) colp = &base_spec->syscolumn [abscol (base_spec, table, sel_index)];
    get_ptext (newkey, NKINDLEN, indexlen);
    keysize = max_len = std_width [colp->type];
    if (keysize == 0) keysize = atoi (indexlen);
    if (max_len == 0) max_len = colp->size - 1;
  } /* if */


  if (((ListBoxGetCurSel (newkey, NKFIELDS) == FAILURE) ||
       (colp == NULL) ||
       (multi >= MAX_INXCOLS) ||
       (keysize > max_len) ||
       (HASWILD (colp->type) && (keysize == 0)) ||
       (act_size + keysize > MAX_KEYSIZE - 2)) == ! is_state (newkey, NKCOPY, DISABLED))
  {
    flip_state (newkey, NKCOPY, DISABLED);
    draw_object (window, NKCOPY);
  } /* if */

  if ((ListBoxGetCurSel (newkey, NKKEYS) == FAILURE) == ! is_state (newkey, NKDELETE, DISABLED))
  {
    flip_state (newkey, NKDELETE, DISABLED);
    draw_object (window, NKDELETE);
  } /* if */

  if (! is_state (newkey, NKCOPY, DISABLED))
    if (dclick) window->exit_obj = NKCOPY;

  if (! is_state (newkey, NKDELETE, DISABLED))
    if (dclick) window->exit_obj = NKDELETE;

  switch (window->exit_obj)
  {
    case NKCOPY   : multi = inxp->inxcols.size / sizeof (INXCOL);
                    get_ptext (newkey, NKINDLEN, indexlen);
                    keysize = atoi (indexlen);
                    inxp->inxcols.cols [multi].col = colp->number;
                    inxp->inxcols.cols [multi].len = keysize;
                    inxp->inxcols.size += sizeof (INXCOL);

                    keysize = std_width [colp->type];
                    if (keysize == 0) keysize = atoi (indexlen);

                    mem       = &indexes [multi * inx_width];
                    *mem      = EOS;
                    *indexlen = EOS;
                    strcpy (field_info.name, colp->name);
                    field_info.name [MAX_NAME] = EOS;
                    sprintf (mem, "%-*s ", MAX_NAME, field_info.name);

                    act_size          += keysize;
                    nk_spec->act_size  = act_size;

                    sprintf (indexlen, "%2d", act_size);
                    set_str (newkey, NKSIZE, indexlen);
                    draw_object (window, NKSIZE);

                    sprintf (indexlen, "%2d", keysize);
                    strcat (mem, indexlen);

                    colp    = NULL;
                    keysize = 0;
                    multi++;

                    ListBoxSetCount (window->object, NKKEYS, multi, NULL);
                    ListBoxSetTopIndex (window->object, NKKEYS, multi);
                    ListBoxRedraw (window->object, NKKEYS);

                    set_str (newkey, NKINDLEN, "");
                    draw_object (window, NKINDLEN);
                    del_item (newkey, NKFIELDS, columns, sizeof (FIELDNAME));
                    nk_spec->sel_column = FAILURE;

                    ListBoxSetCurSel (window->object, NKFIELDS, FAILURE);
                    ListBoxSetTopIndex (window->object, NKFIELDS, 0);
                    ListBoxRedraw (window->object, NKFIELDS);

                    if (! dclick)
                    {
                      undo_state (window->object, window->exit_obj, SELECTED);
                      draw_object (window, window->exit_obj);
                    } /* if */
                    break;
    case NKUPDATE : get_ptext (newkey, NKINDLEN, indexlen);
                    keysize = atoi (indexlen);

                    if (keysize != inxp->inxcols.cols [ListBoxGetCurSel (newkey, NKKEYS)].len)
                    {
                      if (inxp->num_keys > 0) base_spec->reorg = TRUE;
                      inxp->inxcols.cols [ListBoxGetCurSel (newkey, NKKEYS)].len = keysize;
                      set_indexes (base_spec, table, inxp, nk_spec);
                      draw_object (window, NKSIZE);
                      ListBoxRedraw (window->object, NKKEYS);
                    } /* if */

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case NKDELETE : multi--;
                    field   = inxp->inxcols.cols [ListBoxGetCurSel (newkey, NKKEYS)].col;
                    colp    = &base_spec->syscolumn [abscol (base_spec, table, field)];
                    keysize = std_width [colp->type];

                    if (keysize == 0) keysize = inxp->inxcols.cols [ListBoxGetCurSel (newkey, NKKEYS)].len;

                    act_size          -= keysize;
                    nk_spec->act_size  = act_size;

                    sprintf (indexlen, "%2d", act_size);
                    set_str (newkey, NKSIZE, indexlen);
                    draw_object (window, NKSIZE);

                    del_keycol (inxp, ListBoxGetCurSel (window->object, NKKEYS));
                    del_item (newkey, NKKEYS, indexes, inx_width);
                    ListBoxSetCurSel (window->object, NKKEYS, FAILURE);

                    set_columns (base_spec, table, inxp);

                    ListBoxRedraw (window->object, NKKEYS);
                    ListBoxRedraw (window->object, NKFIELDS);

                    if (! dclick)
                    {
                      undo_state (window->object, window->exit_obj, SELECTED);
                      draw_object (window, window->exit_obj);
                    } /* if */
                    break;
    case NKOK     : get_ptext (newkey, NKINDEX, indexname);
                    make_id (indexname);
                    p = get_str (newkey, NKINDEX);
                    if (strcmp (indexname, p) != 0)
                    {
                      sprintf (s, alerts [ERR_IDINDEX], indexname);
                      open_alert (s);
                    } /* if */

                    index = inxp->number;

                    strcpy (index_info.name, indexname);
                    found = v_indexinfo (base_spec, table, FAILURE, &index_info);
                    index_unique = (found == FAILURE) || (found == index);

                    if (! index_unique)
                    {
                      sprintf (s, alerts [ERR_NOTUNIQUE], indexname);
                      open_alert (s);                   /* index name was already used */
                      window->flags &= ~ WI_DLCLOSE;    /* don't close window */
                      undo_state (window->object, window->exit_obj, SELECTED);
                      draw_object (window, window->exit_obj);
                      return;
                    } /* if */

                    old_flags = inxp->flags;
                    strcpy (inxp->name, indexname);
                    inxp->type  = get_ktype (base_spec, table, inxp);
                    inxp->flags = get_kflags () | (old_flags & ~ (INX_PRIMARY | INX_UNIQUE));

                    if (index == FAILURE)               /* is's a new index */
                    {
                      if (! check_key (base_spec, 1))
                      {
                        hndl_alert (ERR_NOKEYS);
                        return;
                      } /* if */

                      index = add_key (base_spec, table, inxp);
                      if ((! base_spec->new) && (systable->recs > 0)) base_spec->reorg = TRUE;
                    } /* if */
                    else                                /* modify old index */
                    {
                      sysrel = base_spec->sysrel;

                      for (i = 0; i < base_spec->num_rels; i++, sysrel++)        /* check type of rels */
                      {
                        if ((sysrel->reftable == table) && (sysrel->refindex == inxp->number) ||
                            (sysrel->reltable == table) && (sysrel->relindex == inxp->number))
                        {
                          abs_inx  = absinx (base_spec, sysrel->reftable, sysrel->refindex);
                          sysindex = &base_spec->sysindex [abs_inx];
                          typeref  = sysindex->type;

                          abs_inx  = absinx (base_spec, sysrel->reltable, sysrel->relindex);
                          sysindex = &base_spec->sysindex [abs_inx];
                          typerel  = sysindex->type;
                          if (typeref != typerel) hndl_alert (ERR_RELTYPE);
                        } /* if */
                      } /* for */

                      if ((old_flags & INX_PRIMARY) && ! (inxp->flags & INX_PRIMARY))
                      {
                        sysrel = base_spec->sysrel;

                        for (i = 0; i < base_spec->num_rels; i++, sysrel++)
                          if ((sysrel->reftable == table) && (sysrel->refindex == inxp->number)) del_rel (base_spec, i);
                      } /* if */

                      inxp->flags |= UPD_FLAG;
                      abs_inx      = absinx (base_spec, table, inxp->number);
                      inxp         = &base_spec->sysindex [abs_inx];
                      *inxp        = nk_spec->new_index;
                    } /* else */

                    get_tblwh (base_spec, table, &systattr->width, &systattr->height);
                    systattr->flags |= UPD_FLAG;

                    set_redraw (nk_spec->base_window, &nk_spec->base_window->scroll);
                    base_spec->modified = TRUE;
                    break;
    case NKHELP   : hndl_help (HNEWKEY);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  condition = (colp == NULL) ||
              (multi >= MAX_INXCOLS) ||
              (keysize > max_len) ||
              (HASWILD (colp->type) && (keysize == 0));

  if (((ListBoxGetCurSel (newkey, NKFIELDS) == FAILURE) ||
       (act_size + keysize > MAX_KEYSIZE - 2) || condition) == ! is_state (newkey, NKCOPY, DISABLED))
  {
    flip_state (newkey, NKCOPY, DISABLED);
    draw_object (window, NKCOPY);
  } /* if */

  condition = condition || ! HASWILD (colp->type);

  if (((ListBoxGetCurSel (newkey, NKKEYS) == FAILURE) || condition) == ! is_state (newkey, NKUPDATE, DISABLED))
  {
    flip_state (newkey, NKUPDATE, DISABLED);
    draw_object (window, NKUPDATE);
  } /* if */

  condition = (colp == NULL) || ! HASWILD (colp->type);

  if (condition == is_flags (newkey, NKINDLEN, EDITABLE))
  {
    flip_flags (newkey, NKINDLEN, EDITABLE);
    if (! is_flags (newkey, NKINDLEN, EDITABLE)) set_cursor (window, NKINDEX, NIL);
  } /* if */

  if ((ListBoxGetCurSel (newkey, NKKEYS) == FAILURE) == ! is_state (newkey, NKDELETE, DISABLED))
  {
    flip_state (newkey, NKDELETE, DISABLED);
    draw_object (window, NKDELETE);
  } /* if */

  get_ptext (newkey, NKINDEX, indexname);
  make_id (indexname);

  if (((*indexname == EOS) || (multi < 2)) == ! is_state (newkey, NKOK, DISABLED))
  {
    flip_state (newkey, NKOK, DISABLED);
    draw_object (window, NKOK);
  } /* if */

  new_key  = index;
  exit_obj = window->exit_obj;
} /* click_nkey */

/*****************************************************************************/

LOCAL BOOLEAN key_nkey (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      multi;
  FIELDNAME name;
  NK_SPEC   *nk_spec;

  nk_spec = (NK_SPEC *)window->special;
  multi   = nk_spec->new_index.inxcols.size / sizeof (INXCOL);

  switch (window->edit_obj)
  {
    case NKINDEX : get_ptext (newkey, NKINDEX, name);
                   make_id (name);

                   if (((*name == EOS) || (multi < 2)) == ! is_state (newkey, NKOK, DISABLED))
                   {
                     flip_state (newkey, NKOK, DISABLED);
                     draw_object (window, NKOK);
                   } /* if */
                   break;
  } /* switch */

  return (FALSE);
} /* key_nkey */

/*****************************************************************************/

LOCAL BOOLEAN is_part (col, inxp)
WORD     col;
SYSINDEX *inxp;

{
  WORD i, multi;

  multi = inxp->inxcols.size / sizeof (INXCOL);

  for (i = 0; i < multi; i++)
    if (inxp->inxcols.cols [i].col == col) return (TRUE);

  return (FALSE);
} /* is_part */

/*****************************************************************************/

LOCAL VOID set_indexlen (type, size)
WORD type;
LONG size;

{
  STRING indexlen;

  *indexlen = EOS;
  size      = min (size, MAX_KEYSIZE - 2);
  if (HASWILD (type)) sprintf (indexlen, "%ld", size);
  set_str (newkey, NKINDLEN, indexlen);
  if (*indexlen != EOS) do_flags (newkey, NKINDLEN, EDITABLE);
} /* set_indexlen */

/*****************************************************************************/

LOCAL VOID set_columns (base_spec, table, inxp)
BASE_SPEC *base_spec;
WORD      table;
SYSINDEX  *inxp;

{
  WORD       i, num_items;
  BYTE       *mem;
  FIELD_INFO field_info;

  num_items = 0;

  for (i = 1, mem = columns; i < base_spec->systable [table].cols; i++)
  {
    v_fieldinfo (base_spec, table, i, &field_info);

    if (! is_part (i, inxp))
    {
      num_items++;
      sprintf (mem, "%s", field_info.name);
      mem += sizeof (FIELDNAME);
    } /* if */
  } /* for */

  ListBoxSetCount (newkey, NKFIELDS, num_items, NULL);
} /* set_columns */

/*****************************************************************************/

LOCAL VOID set_indexes (base_spec, table, inxp, nk_spec)
BASE_SPEC *base_spec;
WORD      table;
SYSINDEX  *inxp;
NK_SPEC   *nk_spec;

{
  WORD       i, len, keysize, num_items;
  STRING     indexlen;
  BYTE       *mem;
  FIELD_INFO field_info;

  keysize   = 0;
  num_items = inxp->inxcols.size / sizeof (INXCOL);

  for (i = 0, mem = indexes; i < num_items; i++)
  {
    *indexlen = EOS;
    v_fieldinfo (base_spec, table, inxp->inxcols.cols [i].col, &field_info);
    field_info.name [MAX_NAME] = EOS;
    sprintf (mem, "%-*s ", MAX_NAME, field_info.name);

    len = std_width [field_info.type];
    if (len == 0) len = inxp->inxcols.cols [i].len;
    sprintf (indexlen, "%2d", len);
    strcat (mem, indexlen);

    keysize += len;
    mem     += inx_width;
  } /* for */

  nk_spec->act_size = keysize;
  sprintf (indexlen, "%2d", keysize);
  set_str (newkey, NKSIZE, indexlen);
} /* set_indexes */

/*****************************************************************************/

LOCAL VOID deselect (tree, obj)
OBJECT *tree;
WORD   obj;

{
  if (ListBoxGetCurSel (tree, obj) != FAILURE)
  {
    ListBoxSetCurSel (tree, obj, FAILURE);
    ListBoxRedraw (tree, obj);
  } /* if */
} /* deselect */

/*****************************************************************************/

LOCAL VOID del_item (tree, obj, itemlist, itemsize)
OBJECT *tree;
WORD   obj;
BYTE   *itemlist;
WORD   itemsize;

{
  WORD item, num_items;
  BYTE *mem;

  num_items = ListBoxGetCount (tree, obj);
  item      = ListBoxGetCurSel (tree, obj);

  if (num_items > 0)
  {
    mem = &itemlist [item * itemsize];
    mem_move (mem, mem + itemsize, (num_items - item) * itemsize);
    num_items--;
    ListBoxSetCount (tree, obj, num_items, NULL);
  } /* if */
} /* del_item */

/*****************************************************************************/

LOCAL VOID del_keycol (inxp, item)
SYSINDEX *inxp;
WORD     item;

{
  WORD   multi, size;
  INXCOL *mem;

  multi = inxp->inxcols.size / sizeof (INXCOL);

  if (multi > 0)
  {
    mem  = &inxp->inxcols.cols [item];
    size = (MAX_INXCOLS - item - 1) * sizeof (INXCOL);
    mem_move (mem, mem + 1, size);
    inxp->inxcols.size -= sizeof (INXCOL);
  } /* if */
} /* del_keycol */

/*****************************************************************************/

LOCAL UWORD get_kflags ()

{
  WORD  obj;
  UWORD flags;

  obj = get_rbutton (newkey, NKNONE);

  switch (obj)
  {
    case NKNONE   : flags = INX_NONE;    break;
    case NKPRIMAR : flags = INX_PRIMARY; break;
    case NKUNIQUE : flags = INX_UNIQUE;  break;
  } /* switch */

  return (flags);
} /* get_kflags */


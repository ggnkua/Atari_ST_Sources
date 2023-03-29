/*****************************************************************************/
/*                                                                           */
/* Modul: BMENU.C                                                            */
/* Datum: 08/04/90                                                           */
/*                                                                           */
/*****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "dbase.h"

#include "root.h"
#include "resource.h"
#include "event.h"
#include "dialog.h"
#include "help.h"
#include "bclick.h"

#include "export.h"
#include "bmenu.h"

/****** DEFINES **************************************************************/

#define MAX_ITEXT   12  /* length of text below icon */
#define MAX_IWIDTH  64  /* icon width */
#define MAX_IHEIGHT 32  /* icon height */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD button;
  WORD edit;
  WORD diff;
} OBJDATA;

/****** VARIABLES ************************************************************/

LOCAL WORD      exit_obj;       /* will be set for modal dialogue boxes */
LOCAL WORD      new_table;
LOCAL WORD      new_field;
LOCAL WORD      new_key;

LOCAL SYSTABLE  *nttablep;
LOCAL WINDOWP   ntwindow;
LOCAL WORD      nt_x;
LOCAL WORD      nt_y;
LOCAL WORD      nt_inum;

LOCAL WORD      nftable;
LOCAL SYSCOLUMN *nffieldp;
LOCAL SYSINDEX  *nfkeyp;
LOCAL WINDOWP   nfwindow;

LOCAL WORD      dinum;
LOCAL BASE_SPEC *icon_spec;
LOCAL BASE_SPEC *param_spec;

LOCAL OBJDATA   objdata [NUM_TYPES] =
{
  {NFDTEXT,  NFDTLEN,  1},
  {NFDWORD,  NIL,      0},
  {NFDLONG,  NIL,      0},
  {NFDFLOAT, NIL,      0},
  {NFDTFLOA, NFDTFLEN, 1},
  {NFDDATE,  NIL,      0},
  {NFDTIME,  NIL,      0},
  {NFDTSTAM, NIL,      0},
  {NFDBYTE,  NFDBLEN,  sizeof (LONG)},
  {NFDPIC,   NFDPLEN,  sizeof (LONG)},
  {NFDEXTRN, NFDELEN,  1},
  {NFDDBADR, NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0},
  {NIL,      NIL,      0}
}; /* objdata */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    box           _((WINDOWP window, BOOLEAN grow, WINDOWP base_window, WORD class, WORD obj, WORD table));

LOCAL VOID    set_dbinfo    _((BASE_SPEC *base_spec));
LOCAL VOID    click_dbinfo  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_dbinfo    _((WINDOWP window, MKINFO *mk));

LOCAL VOID    set_ntable    _((BASE_SPEC *base_spec, SYSTABLE *tablep));
LOCAL VOID    open_ntable   _((WINDOWP window));
LOCAL VOID    close_ntable  _((WINDOWP window));
LOCAL VOID    click_ntable  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_ntable    _((WINDOWP window, MKINFO *mk));

LOCAL VOID    set_nfield    _((BASE_SPEC *base_spec, SYSCOLUMN *colp, SYSINDEX *inxp));
LOCAL VOID    open_nfield   _((WINDOWP window));
LOCAL VOID    close_nfield  _((WINDOWP window));
LOCAL VOID    click_nfield  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_nfield    _((WINDOWP window, MKINFO *mk));

LOCAL VOID    set_icons     _((BASE_SPEC *base_spec));
LOCAL VOID    click_icons   _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_icons     _((WINDOWP window, MKINFO *mk));
LOCAL VOID    check_icn     _((WINDOWP window, WORD new_icon, BOOLEAN draw));

LOCAL VOID    get_params     _((BASE_SPEC *base_spec));
LOCAL VOID    set_params     _((BASE_SPEC *base_spec));
LOCAL VOID    click_params   _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_params     _((WINDOWP window, MKINFO *mk));

LOCAL WORD    get_icolor    _((OBJECT *tree, WORD object));
LOCAL VOID    set_icolor    _((OBJECT *tree, WORD object, WORD color));
LOCAL VOID    set_itext     _((OBJECT *tree, WORD object, BYTE *s));
LOCAL VOID    set_idata     _((OBJECT *tree, WORD object, WORD *mask, WORD *data, WORD width, WORD height));
LOCAL BOOLEAN load_icon     _((BASE_SPEC *base_spec, WORD *mask, WORD *data, WORD *width, WORD *height));

LOCAL VOID    chg_field     _((BASE_SPEC *base_spec, WORD table, SYSCOLUMN *new_column, SYSINDEX *new_index));

LOCAL WORD    get_ftype     _((OBJECT *newfield));
LOCAL LONG    get_fsize     _((OBJECT *newfield));
LOCAL UWORD   get_fflags    _((OBJECT *newfield));

LOCAL WORD    get_klen      _((WORD type, LONG size));
LOCAL UWORD   get_kflags    _((OBJECT *newfield));

LOCAL BOOLEAN xget_checkbox _((OBJECT *tree, WORD obj));
LOCAL VOID    set_fobjs     _((WINDOWP window, LONG indexes));

/*****************************************************************************/

GLOBAL VOID mdbinfo (base_spec)
BASE_SPEC *base_spec;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, DBINFO);

  if (window == NULL)
  {
    form_center (dbinfo, &ret, &ret, &ret, &ret);
    window = crt_dialog (dbinfo, NULL, DBINFO, (BYTE *)freetext [FDBINFO].ob_spec, WI_MODELESS);

    if (window != NULL)
    {
      window->click = click_dbinfo;
      window->key   = key_dbinfo;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = 0;
    window->edit_inx = NIL;

    set_dbinfo (base_spec);

    if (open_dialog (DBINFO))
      set_redraw (window, &window->scroll);
    else
      hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mdbinfo */

/*****************************************************************************/

GLOBAL WORD mnewtable (base_window, tablep, x, y, ret_table)
WINDOWP  base_window;
SYSTABLE *tablep;
WORD     x, y;
WORD     *ret_table;

{
  WINDOWP   window;
  WORD      table;
  WORD      ret;
  WORD      object;
  WORD      wbox, hbox;
  STRING    name;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)base_window->special;

  if (tablep == NULL)
    table = -1;
  else
    table = tablep->table;

  if (table < 0)                        /* new table */
  {
    wbox = base_spec->wbox;
    hbox = base_spec->hbox;

    object = FNEWTBL;

    if ((x < 0) || (y < 0))
    {
      x = (base_window->doc.x * base_window->xfac + base_window->scroll.w / 2) / wbox;
      y = (base_window->doc.y * base_window->yfac + base_window->scroll.h / 2) / hbox;
    } /* if */
    else
    {
      x = (x + base_window->doc.x * base_window->xfac - base_window->scroll.x) / wbox;
      y = (y + base_window->doc.y * base_window->yfac - base_window->scroll.y) / hbox;
    }
  } /* if */
  else
  {
    object = FCHGTBL;

    x = base_spec->systattr [table].x;
    y = base_spec->systattr [table].y;
  } /* else */

  strcpy (name, (BYTE *)freetext [object].ob_spec);

  exit_obj = NIL;
  window   = search_window (CLASS_DIALOG, SRCH_ANY, NEWTABLE);

  if (window == NULL)
  {
    form_center (newtable, &ret, &ret, &ret, &ret);
    window = crt_dialog (newtable, NULL, NEWTABLE, name, WI_MODAL);

    if (window != NULL)
    {
      window->open  = open_ntable;
      window->close = close_ntable;
      window->click = click_ntable;
      window->key   = key_ntable;
    } /* if */
  } /* if */
  else
    strcpy (window->name, name);

  if (window != NULL)
  {
    if ((table < 0) || (table >= NUM_SYSTABLES))
    {
      undo_state (newtable, NTNAME, DISABLED);
      do_flags (newtable, NTTABLE, EDITABLE);
      window->edit_obj = find_flags (newtable, ROOT, EDITABLE);
    } /* if */
    else
    {
      do_state (newtable, NTNAME, DISABLED);
      undo_flags (newtable, NTTABLE, EDITABLE);
      window->edit_obj = NIL;
    } /* else */

    window->edit_inx = NIL;
    nttablep         = tablep;
    ntwindow         = base_window;
    nt_x             = x;
    nt_y             = y;

    set_ntable (base_spec, tablep);

    if (open_dialog (NEWTABLE))
      set_redraw (window, &window->scroll);
    else
      hndl_alert (ERR_NOOPEN);
  } /* if */

  *ret_table = new_table;

  return (exit_obj);
} /* mnewtable */

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

  strcpy (name, (BYTE *)freetext [object].ob_spec);
  exit_obj = NIL;

  window = search_window (CLASS_DIALOG, SRCH_ANY, NEWFIELD);

  if (window == NULL)
  {
    form_center (newfield, &ret, &ret, &ret, &ret);
    window = crt_dialog (newfield, NULL, NEWFIELD, name, WI_MODAL);

    if (window != NULL)
    {
      window->open  = open_nfield;
      window->close = close_nfield;
      window->click = click_nfield;
      window->key   = key_nfield;
    } /* if */
  } /* if */
  else
    strcpy (window->name, name);

  if (window != NULL)
  {
    window->edit_obj = find_flags (newfield, ROOT, EDITABLE);
    window->edit_inx = NIL;
    nftable          = table;
    nffieldp         = colp;
    nfkeyp           = inxp;
    nfwindow         = base_window;

    set_nfield ((BASE_SPEC *)base_window->special, colp, inxp);

    if (open_dialog (NEWFIELD))
      set_redraw (window, &window->scroll);
    else
      hndl_alert (ERR_NOOPEN);
  } /* if */

  *ret_field = new_field;

  return (exit_obj);
} /* mnewfield */

/*****************************************************************************/

GLOBAL WORD mnewkey (base_window, table, inxp, ret_key)
WINDOWP  base_window;
WORD     table;
SYSINDEX *inxp;
WORD     *ret_key;

{
  exit_obj = NIL;


  *ret_key = new_key;

  return (exit_obj);
} /* mnewkey */

/*****************************************************************************/

GLOBAL VOID micons (base_spec)
BASE_SPEC *base_spec;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, DOICONS);

  if (window == NULL)
  {
    form_center (doicons, &ret, &ret, &ret, &ret);
    window = crt_dialog (doicons, NULL, DOICONS, (BYTE *)freetext [FDOICONS].ob_spec, WI_MODAL);

    if (window != NULL)
    {
      window->click = click_icons;
      window->key   = key_icons;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = 0;
    window->edit_inx = NIL;
    icon_spec        = base_spec;

    set_icons (base_spec);

    if (open_dialog (DOICONS))
      set_redraw (window, &window->scroll);
    else
      hndl_alert (ERR_NOOPEN);
  } /* if */
} /* micons */

/*****************************************************************************/

GLOBAL VOID mdbparams (base_spec)
BASE_SPEC *base_spec;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, DBPARAMS);

  if (window == NULL)
  {
    form_center (dbparams, &ret, &ret, &ret, &ret);
    window = crt_dialog (dbparams, NULL, DBPARAMS, (BYTE *)freetext [FDBPARAM].ob_spec, WI_MODAL);

    if (window != NULL)
    {
      window->click = click_params;
      window->key   = key_params;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (dbparams, ROOT, EDITABLE);
      window->edit_inx = NIL;
      param_spec       = base_spec;

      set_params (base_spec);
    } /* if */

    if (! open_dialog (DBPARAMS)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mdbparams */

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

LOCAL VOID set_dbinfo (base_spec)
BASE_SPEC *base_spec;

{
  BASE_INFO *base_info;
  LONG      size, used;
  STRING    s;
  FULLNAME  dbname;
  BYTE      *p;
  WORD      w, perc;

  base_info = base_spec->new ? NULL : &base_spec->base_info;

  if (base_info != NULL)
  {
    p = (BYTE *)freetext [FPERCENT].ob_spec;
    w = dbinfo [DINAME].ob_width / gl_wbox;

    strcpy (dbname, base_spec->basepath);
    strcat (dbname, base_spec->basename);
    dbname [w] = EOS;
    strcpy ((BYTE *)dbinfo [DINAME].ob_spec, dbname);
    strcpy ((BYTE *)dbinfo [DIUSER].ob_spec, base_info->username);

    bin2str (TYPE_TIMESTAMP, &base_info->data_info.created, s);
    s [14] = EOS;
    set_ptext (dbinfo, DICREAT, s);

    bin2str (TYPE_TIMESTAMP, &base_info->data_info.lastuse, s);
    s [14] = EOS;
    set_ptext (dbinfo, DILASTUS, s);

    size = base_info->data_info.file_size / 1024;
    used = base_info->data_info.next_rec / 1024;
    perc = (WORD)(used * 100 / size);

    sprintf ((BYTE *)dbinfo [DIRECSIZ].ob_spec, p, size, 100);
    sprintf ((BYTE *)dbinfo [DIRECUSE].ob_spec, p, used, perc);
    sprintf ((BYTE *)dbinfo [DIRECFRE].ob_spec, p, size - used, 100 - perc);

    size = base_info->tree_info.num_pages / 2;
    used = base_info->tree_info.used_pages / 2;
    perc = (WORD)(used * 100 / size);

    sprintf ((BYTE *)dbinfo [DIINDSIZ].ob_spec, p, size, 100);
    sprintf ((BYTE *)dbinfo [DIINDUSE].ob_spec, p, used, perc);
    sprintf ((BYTE *)dbinfo [DIINDFRE].ob_spec, p, size - used, 100 - perc);
    sprintf ((BYTE *)dbinfo [DIINDCAC].ob_spec, "%ld kb", base_info->tree_info.num_vpages / 2);
    sprintf ((BYTE *)dbinfo [DIINDHIT].ob_spec, "%ld%%", (base_info->tree_info.num_calls == 0) ? 0 : base_info->tree_info.num_hits * 100 / base_info->tree_info.num_calls);
    sprintf ((BYTE *)dbinfo [DIINDCUR].ob_spec, "%d", base_info->tree_info.num_cursors);
/*    strcpy ((BYTE *)dbinfo [DIINDFLU].ob_spec, (BYTE *)freetext [(base_spec->flags & BASE_FLUSH) ? FYES : FNO].ob_spec);*/
  } /* if */
} /* set_dbinfo */

/*****************************************************************************/

LOCAL VOID click_dbinfo (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case DIOK   : break;
    case DIHELP : hndl_help (HDBINFO);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */
} /* click_dbinfo */

/*****************************************************************************/

LOCAL BOOLEAN key_dbinfo (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  click_dbinfo (window, mk);

  return (FALSE);
} /* key_dbinfo */

/*****************************************************************************/

LOCAL VOID set_ntable (base_spec, tablep)
BASE_SPEC *base_spec;
SYSTABLE  *tablep;

{
  WORD       table;
  FULLNAME   dbname;
  STRING     s;
  WORD       w;
  WORD       width, height;
  WORD       *pmask, *pdata;
  ICONBLK    *piconblk;
  SYSICON    *sysicon;

  w = newtable [NTDBNAME].ob_width / gl_wbox;

  strcpy (dbname, base_spec->basepath);
  strcat (dbname, base_spec->basename);
  dbname [w] = EOS;
  strcpy ((BYTE *)newtable [NTDBNAME].ob_spec, dbname);

  if (tablep == NULL)
    table = -1;
  else
    table = tablep->table;

  if (table < 0)                                      /* it's a new table */
  {
    piconblk = (ICONBLK *)dbicons [ITABLE].ob_spec;   /* get a prototype */
    nt_inum  = 0;

    if (tablep == NULL)
    {
      set_ptext (newtable, NTTABLE, "");
      set_checkbox (newtable, NTMTON, FALSE);
      set_itext (newtable, NTICON, piconblk->ib_ptext);
      do_state (newtable, NTOK, DISABLED);
    } /* if */
    else
    {
      set_ptext (newtable, NTTABLE, tablep->name);
      set_checkbox (newtable, NTMTON, tablep->flags & TBL_MTONREL);
      set_itext (newtable, NTICON, tablep->name);
    } /* else */

    set_icolor (newtable, NTICON, BLACK);
    set_idata (newtable, NTICON, piconblk->ib_pmask,
                                 piconblk->ib_pdata,
                                 piconblk->ib_wicon,
                                 piconblk->ib_hicon);
  } /* if */
  else
  {
    if (tablep->icon >= base_spec->new_icon) tablep->icon = 0;

    nt_inum = tablep->icon;
    sysicon = &base_spec->sysicon [nt_inum];
    width   = sysicon->width;
    height  = sysicon->height;
    pmask   = &sysicon->icon.icondef [0];
    pdata   = &sysicon->icon.icondef [(width + 15) / 16 * height];

    set_ptext (newtable, NTTABLE, tablep->name);
    set_checkbox (newtable, NTMTON, tablep->flags & TBL_MTONREL);
    set_icolor (newtable, NTICON, tablep->color);
    set_itext (newtable, NTICON, tablep->name);
    set_idata (newtable, NTICON, pmask, pdata, width, height);
    trans_gimage (newtable, NTICON);
  } /* else */

  undo_state (newtable, NTIDOWN, DISABLED);
  undo_state (newtable, NTIUP,   DISABLED);

  if (nt_inum == 0) do_state (newtable, NTIDOWN, DISABLED);
  if (nt_inum == base_spec->new_icon - 1) do_state (newtable, NTIUP, DISABLED);

  sprintf (s, "%d", nt_inum);
  set_ptext (newtable, NTINUM, s);
} /* set_ntable */

/*****************************************************************************/

LOCAL VOID open_ntable (window)
WINDOWP window;

{
  WORD table;

  if (nttablep == NULL)
    table = -1;
  else
    table = nttablep->table;

  box (window, TRUE, ntwindow, SEL_TABLE, table, table);
} /* open_ntable */

/*****************************************************************************/

LOCAL VOID close_ntable (window)
WINDOWP window;

{
  WORD table;

  if (nttablep == NULL)
    table = -1;
  else
    table = nttablep->table;

  box (window, FALSE, ntwindow, SEL_TABLE, table, table);
} /* close_ntable */

/*****************************************************************************/

LOCAL VOID click_ntable (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      w, h;
  WORD      table;
  UWORD     flags;
  BOOLEAN   name_changed;
  TABLENAME name;
  STRING    s;
  WORD      *pmask, *pdata;
  WORD      width, height;
  SYSTABLE  *systable;
  SYSTATTR  *systattr;
  SYSICON   *sysicon;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)ntwindow->special;
  table     = -1;

  if (nttablep == NULL)
    table = -1;
  else
    table = nttablep->table;

  switch (window->exit_obj)
  {
    case NTOK     : get_ptext (newtable, NTTABLE, name);
                    flags = get_checkbox (newtable, NTMTON) ? TBL_MTONREL : 0;
                    str_upper (name);
                    str_rmchar (name, ':');
                    str_rmchar (name, '*');
                    str_rmchar (name, '?');

                    name_changed = TRUE;

                    if (nttablep != NULL)
                      name_changed = (str_cmp (nttablep->name, name) != 0) || (table < 0);

                    if (name_changed && ! is_tunique (base_spec, name))
                    {
                      hndl_alert (ERR_NOTUNIQUE);       /* table name was already used */
                      window->flags &= ~ WI_DLCLOSE;    /* don't close window */
                      undo_state (window->object, window->exit_obj, SELECTED);
                      draw_object (window, window->exit_obj);
                      return;
                    } /* if */

                    if (table < 0)                      /* build new table */
                    {
                      switch (check_all (base_spec, 1, 1, 1))
                      {
                        case ERR_ADD_TBL : hndl_alert (ERR_NOTABLES); return;
                        case ERR_ADD_COL : hndl_alert (ERR_NOFIELDS); return;
                        case ERR_ADD_INX : hndl_alert (ERR_NOKEYS);   return;
                      } /* if */

                      table = add_table (base_spec, name, flags);
                    } /* if */
                    else                                /* change name of table */
                    {
                      if (table >= NUM_SYSTABLES) strcpy (nttablep->name, name);
                      flags |= nttablep->flags & ~ TBL_MTONREL;
                      nttablep->flags = flags;
                    } /* else */

                    get_tblwh (base_spec, table, &w, &h);
                    systable = &base_spec->systable [table];
                    systattr = &base_spec->systattr [table];

                    systable->color  = get_icolor (newtable, NTICON);
                    systable->icon   = nt_inum;
                    systattr->x      = nt_x;
                    systattr->y      = nt_y;
                    systattr->width  = w;
                    systattr->height = h;

                    set_redraw (ntwindow, &ntwindow->scroll);
                    base_spec->modified = TRUE;
                    break;
    case NTHELP   : hndl_help (HNEWTBL);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case NTIDOWN  :
    case NTIUP    : if (window->exit_obj == NTIDOWN) nt_inum--;
                    if (window->exit_obj == NTIUP)   nt_inum++;

                    if ((nt_inum == 0) == ! is_state (newtable, NTIDOWN, DISABLED))
                      flip_state (newtable, NTIDOWN, DISABLED);

                    if ((nt_inum == base_spec->new_icon - 1) == ! is_state (newtable, NTIUP, DISABLED))
                      flip_state (newtable, NTIUP, DISABLED);

                    sprintf (s, "%d", nt_inum);
                    set_ptext (newtable, NTINUM, s);
                    draw_object (window, NTINUMBO);

                    sysicon = &base_spec->sysicon [nt_inum];
                    width   = sysicon->width;
                    height  = sysicon->height;
                    pmask   = &sysicon->icon.icondef [0];
                    pdata   = &sysicon->icon.icondef [(width + 15) / 16 * height];

                    set_idata (newtable, NTICON, pmask, pdata, width, height);
                    trans_gimage (newtable, NTICON);
                    draw_object (window, NTICNBOX);
                    bstate = 0x0001;     /* wait again for button down */
                    break;
    default       : if ((NTCOLOR0 <= window->exit_obj) && (window->exit_obj <= NTCOLORF))
                    {
                      set_icolor (window->object, NTICON, window->exit_obj - NTCOLOR0);
                      draw_object (window, NTICON);
                    } /* if */
  } /* switch */

  new_table = table;
  exit_obj  = window->exit_obj;
} /* click_ntable */

/*****************************************************************************/

LOCAL BOOLEAN key_ntable (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE *p;

  click_ntable (window, mk);

  switch (window->edit_obj)
  {
    case NTTABLE : p = ((TEDINFO *)newtable [NTTABLE].ob_spec)->te_ptext;
                   if ((*p == EOS) == ! is_state (newtable, NTOK, DISABLED))
                   {
                     flip_state (newtable, NTOK, DISABLED);
                     draw_object (window, NTOK);
                   } /* if */
                   break;
  } /* switch */

  return (FALSE);
} /* key_ntable */

/*****************************************************************************/

LOCAL VOID set_nfield (base_spec, colp, inxp)
BASE_SPEC *base_spec;
SYSCOLUMN *colp;
SYSINDEX  *inxp;

{
  TABLE_INFO table_info;
  FIELDNAME  indexname;
  STRING     indexlen;
  WORD       index, abs_inx, field;
  WORD       obj, type;
  UWORD      inx_flags;
  BOOLEAN    is_index;
  STRING     s;
  OBJDATA    *objptr;

  if (v_tableinfo (base_spec, nftable, &table_info) != FAILURE)
  {
    if (colp == NULL)
      field = -1;
    else
      field = colp->number;

    indexname [0] = EOS;
    indexlen [0]  = EOS;
    strcpy ((BYTE *)newfield [NFTABLE].ob_spec, table_info.name);

    set_ptext (newfield, NFFIELD,   "");
    set_ptext (newfield, NFINDEX,   "");
    set_ptext (newfield, NFINDLEN,  "");

    objptr = objdata;

    for (type = 0; type < NUM_TYPES; type++, objptr++)
      if (objptr->button != NIL)
      {
        do_flags (newfield, objptr->button, SELECTABLE);
        undo_state (newfield, objptr->button + 1, DISABLED);

        if (objptr->edit != NIL)
        {
          set_ptext (newfield, objdata [type].edit,  "");
          do_flags (newfield, objptr->edit, EDITABLE);
        } /* if */
      } /* if, for */

    do_flags (newfield, NFAINDEX, SELECTABLE);
    undo_state (newfield, NFAINDEX + 1, DISABLED);

    undo_flags (newfield, NFINDEX,  EDITABLE);
    undo_flags (newfield, NFINDLEN, EDITABLE);
    undo_flags (newfield, NFAUNIQU, SELECTABLE);
    undo_flags (newfield, NFAIBLAN, SELECTABLE);
    undo_flags (newfield, NFAUPPER, SELECTABLE);

    do_state (newfield, NFINDEXN,     DISABLED);
    do_state (newfield, NFINDEXL,     DISABLED);
    do_state (newfield, NFAUNIQU + 1, DISABLED);
    do_state (newfield, NFAIBLAN + 1, DISABLED);
    do_state (newfield, NFAUPPER + 1, DISABLED);

    do_state (newfield, NFAEDLUT, DISABLED);

    if (colp == NULL)                           /* it's a new field */
    {
      set_rbutton (newfield, NFDTEXT, NFDTEXT, NFDPIC);

      for (obj = NFAMANDA; obj <= NFALOOKU; obj++)
        if (OB_TYPE (newfield, obj) == G_USERDEF) set_checkbox (newfield, obj, FALSE);

      undo_flags (newfield, NFOK, DEFAULT);
      do_flags (newfield, NFNEXT, DEFAULT);

      do_state (newfield, NFOK, DISABLED);
      do_state (newfield, NFNEXT, DISABLED);
    } /* if */
    else
    {
      is_index  = (colp->flags & COL_ISINDEX) != 0;
      inx_flags = 0;

      if (is_index)
      {
        if (inxp == NULL)                       /* get an inx pointer */
        {
          index   = find_index (base_spec, nftable, field);
          abs_inx = absinx (base_spec, nftable, index);
          inxp    = &base_spec->sysindex [abs_inx];
        } /* if */

        inx_flags = inxp->flags;
        strcpy (indexname, inxp->name);
        if (HASWILD (inxp->type)) sprintf (indexlen, "%d", inxp->inxcols.cols [0].len);
      } /* if */

      set_ptext (newfield, NFFIELD,  colp->name);
      set_ptext (newfield, NFINDEX,  indexname);
      set_ptext (newfield, NFINDLEN, indexlen);

      do_flags (newfield, NFOK, DEFAULT);
      undo_flags (newfield, NFNEXT, DEFAULT);

      undo_state (newfield, NFOK, DISABLED);
      undo_state (newfield, NFNEXT, DISABLED);

      type = colp->type;

      set_rbutton (newfield, objdata [type].button, NFDTEXT, NFDPIC);
      if (objdata [type].edit != NIL)
      {
        sprintf (s, "%ld", colp->size - objdata [type].diff);
        set_ptext (newfield, objdata [type].edit, s);
      } /* if */

      switch (colp->type)
      {
        case TYPE_BYTE      : /* index not allowed */
        case TYPE_PICTURE   : undo_flags (newfield, NFAINDEX, SELECTABLE);
                              do_state (newfield, NFAINDEX + 1, DISABLED);
                              break;
      } /* switch */

      set_checkbox (newfield, NFAMANDA, colp->flags & COL_MANDATORY);
      set_checkbox (newfield, NFAOUT,   colp->flags & COL_OUTPUT);
      set_checkbox (newfield, NFANMODI, colp->flags & COL_NMODIFY);
      set_checkbox (newfield, NFAINDEX, is_index);
      set_checkbox (newfield, NFAUNIQU, inx_flags & INX_UNIQUE);
      set_checkbox (newfield, NFAIBLAN, inx_flags & INX_NOBLANKS);
      set_checkbox (newfield, NFAUPPER, inx_flags & INX_UPPERCASE);
      set_checkbox (newfield, NFALOOKU, colp->flags & COL_LOOKUP);

      if (is_state (newfield, NFALOOKU, SELECTED)) undo_state (newfield, NFAEDLUT, DISABLED);

      if (is_index)
      {
        do_flags (newfield, NFINDEX,  EDITABLE);
        undo_state (newfield, NFINDEXN, DISABLED);

        do_flags (newfield, NFAUNIQU, SELECTABLE);
        undo_state (newfield, NFAUNIQU + 1, DISABLED);

        if (inxp->num_keys == 0)
        {
          do_flags (newfield, NFAIBLAN, SELECTABLE);
          do_flags (newfield, NFAUPPER, SELECTABLE);

          undo_state (newfield, NFAIBLAN + 1, DISABLED);
          undo_state (newfield, NFAUPPER + 1, DISABLED);

          if (HASWILD (colp->type))
          {
            do_flags (newfield, NFINDLEN, EDITABLE);
            undo_state (newfield, NFINDEXL, DISABLED);
          } /* if */
        } /* if */
      } /* if */

/* perhaps used later
      if (base_spec->systable [nftable].recs > 0)
*/
        if ((field == 0) || ! (colp->flags & NEW_COL) && (field > 0))   /* don't modify field Address */
        {
          objptr = objdata;

          for (type = 0; type < NUM_TYPES; type++, objptr++)
            if (objptr->button != NIL)
            {
              undo_flags (newfield, objptr->button, SELECTABLE);
              do_state (newfield, objptr->button + 1, DISABLED);
            } /* if, for */
        } /* if, if */
    } /* else */
  } /* if */
} /* set_nfield */

/*****************************************************************************/

LOCAL VOID open_nfield (window)
WINDOWP window;

{
  WORD field;

  if (nffieldp == NULL)
    field = -1;
  else
    field = nffieldp->number;

  box (window, TRUE, nfwindow, SEL_FIELD, field, nftable);
} /* open_nfield */

/*****************************************************************************/

LOCAL VOID close_nfield (window)
WINDOWP window;

{
  WORD field;

  if (nffieldp == NULL)
    field = -1;
  else
    field = nffieldp->number;

  box (window, FALSE, nfwindow, SEL_FIELD, field, nftable);
} /* close_nfield */

/*****************************************************************************/

LOCAL VOID click_nfield (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD       table, field;
  WORD       keys, index, abs_inx;
  LONG       num_indexes;
  BOOLEAN    name_changed;
  FIELDNAME  fieldname;
  FIELDNAME  indexname;
  STRING     indexlen;
  WORD       type;
  LONG       size;
  UWORD      flags;
  WORD       klen, newlen;
  UWORD      kflags;
  SYSCOLUMN  new_column;
  SYSINDEX   new_index;
  SYSINDEX   *inxp;
  SYSTATTR   *systattr;
  BASE_SPEC  *base_spec;

  base_spec   = (BASE_SPEC *)nfwindow->special;
  field       = FAILURE;
  num_indexes = 0;

  if (nffieldp != NULL)
    if (nffieldp->number >= 0)
    {
      index       = find_index (base_spec, nftable, nffieldp->number);
      abs_inx     = absinx (base_spec, nftable, index);
      inxp        = &base_spec->sysindex [abs_inx];
      num_indexes = inxp->num_keys;
    } /* if, if */

  set_fobjs (window, num_indexes);

  switch (window->exit_obj)
  {
    case NFAEDLUT : undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case NFNEXT   :
    case NFOK     : get_ptext (newfield, NFFIELD,  fieldname);
                    get_ptext (newfield, NFINDEX,  indexname);
                    get_ptext (newfield, NFINDLEN, indexlen);

                    name_changed = TRUE;

                    if (nffieldp == NULL)
                      field = -1;
                    else
                    {
                      field        = nffieldp->number;
                      name_changed = (str_cmp (nffieldp->name, fieldname) != 0) || (field < 0);
                    } /* else */

                    table    = nftable;
                    type     = get_ftype (newfield);
                    size     = get_fsize (newfield);
                    flags    = get_fflags (newfield);
                    keys     = 0;
                    klen     = get_klen (type, size);
                    kflags   = get_kflags (newfield);
                    systattr = &base_spec->systattr [table];

                    if (name_changed && ! is_funique (base_spec, table, fieldname))
                    {
                      hndl_alert (ERR_NOTUNIQUE);             /* field name was already used */
                      window->flags &= ~ WI_DLCLOSE;          /* don't close window */
                      undo_state (window->object, window->exit_obj, SELECTED);
                      draw_object (window, window->exit_obj);
                      return;
                    } /* if */

                    if (flags & COL_ISINDEX)
                    {
                      keys   = 1;
                      newlen = atoi (indexlen);
                      if (newlen > 0) klen = min (newlen, klen);
                    } /* if */

                    strcpy (new_column.name, fieldname);
                    new_column.table  = table;
                    new_column.number = field;
                    new_column.type   = type;
                    new_column.size   = size;
                    new_column.flags  = flags;

                    strcpy (new_index.name, indexname);
                    new_index.type                 = type;
                    new_index.flags                = kflags;
                    new_index.inxcols.cols [0].col = field;
                    new_index.inxcols.cols [0].len = klen;

                    if (field < 0)                              /* is's a new field */
                    {
                      switch (check_all (base_spec, 0, 1, keys))
                      {
                        case ERR_ADD_TBL : hndl_alert (ERR_NOTABLES); return;
                        case ERR_ADD_COL : hndl_alert (ERR_NOFIELDS); return;
                        case ERR_ADD_INX : hndl_alert (ERR_NOKEYS);   return;
                      } /* if */

                      field = add_field (base_spec, table, &new_column, &new_index);
                      get_tblwh (base_spec, nftable, &systattr->width, &systattr->height);

                      if (window->exit_obj == NFNEXT)
                      {
                        window->edit_obj = find_flags (newfield, ROOT, EDITABLE);
                        window->edit_inx = NIL;

                        set_nfield (base_spec, NULL, NULL);
                        window->flags &= ~ WI_DLCLOSE;      /* don't close window */
                        undo_state (window->object, window->exit_obj, SELECTED);
                        redraw_window (window, &window->scroll);
                      } /* if */
                    } /* if */
                    else                                    /* modify field & key */
                      chg_field (base_spec, table, &new_column, &new_index);

                    set_redraw (nfwindow, &nfwindow->scroll);
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
  BYTE *p;
  LONG size;

  click_nfield (window, mk);

  switch (window->edit_obj)
  {
    case NFFIELD  :
    case NFDTLEN  :
    case NFDTFLEN :
    case NFDBLEN  :
    case NFDPLEN  :
    case NFDELEN  : p    = ((TEDINFO *)newfield [NFFIELD].ob_spec)->te_ptext;
                    size = get_fsize (newfield);

                    if (((*p == EOS) || (size < 2)) == ! is_state (newfield, NFOK, DISABLED))
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

LOCAL VOID set_icons (base_spec)
BASE_SPEC *base_spec;

{
  FULLNAME dbname;
  STRING   s;
  WORD     w;
  WORD     width, height;
  WORD     *pmask, *pdata;
  SYSICON  *sysicon;

  w = doicons [DDBNAME].ob_width / gl_wbox;

  strcpy (dbname, base_spec->basename);
  dbname [w] = EOS;
  strcpy ((BYTE *)doicons [DDBNAME].ob_spec, dbname);

  dinum   = 0;
  sysicon = base_spec->sysicon;
  width   = sysicon->width;
  height  = sysicon->height;
  pmask   = &sysicon->icon.icondef [0];
  pdata   = &sysicon->icon.icondef [(width + 15) / 16 * height];

  set_idata (doicons, DICON, pmask, pdata, width, height);
  trans_gimage (doicons, DICON);

  undo_state (doicons, DDOWN, DISABLED);
  undo_state (doicons, DUP,   DISABLED);

  if (dinum == 0)
    do_state (doicons, DDELETE, DISABLED);
  else
    undo_state (doicons, DDELETE, DISABLED);

  if (dinum == 0) do_state (doicons, DDOWN, DISABLED);
  if (dinum == base_spec->new_icon - 1) do_state (doicons, DUP, DISABLED);

  sprintf (s, "%d", dinum);
  set_ptext (doicons, DINUM, s);
} /* set_icons */

/*****************************************************************************/

LOCAL VOID click_icons (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  STRING    s;
  WORD      mask [128];
  WORD      data [128];
  WORD      *pmask, *pdata;
  WORD      width, height;
  SYSICON   *sysicon;
  BASE_SPEC *base_spec;

  base_spec = icon_spec;

  switch (window->exit_obj)
  {
    case DOK     : break;
    case DHELP   : hndl_help (HDOICONS);
                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
    case DLOAD   : if (! check_icon (base_spec, 1))
                       hndl_alert (ERR_NOICONS);
                   else
                     if (load_icon (base_spec, mask, data, &width, &height))
                     {
                       dinum = add_icon (base_spec, mask, data, width, height);

                       set_idata (doicons, DICON, mask, data, width, height);
                       trans_gimage (doicons, DICON);

                       check_icn (window, base_spec->new_icon, FALSE);

                       sprintf (s, "%d", dinum);
                       set_ptext (doicons, DINUM, s);
                       set_redraw (window, &window->scroll);
                       base_spec->modified = TRUE;
                     } /* if */

                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
    case DDELETE : if (del_icon (base_spec, dinum) == ERR_DEL_ICN) hndl_alert (ERR_DELICON);
                   if (dinum == base_spec->new_icon) dinum--;

                   check_icn (window, base_spec->new_icon, TRUE);

                   sprintf (s, "%d", dinum);
                   set_ptext (doicons, DINUM, s);

                   sysicon = &base_spec->sysicon [dinum];
                   width   = sysicon->width;
                   height  = sysicon->height;
                   pmask   = &sysicon->icon.icondef [0];
                   pdata   = &sysicon->icon.icondef [(width + 15) / 16 * height];

                   set_idata (doicons, DICON, pmask, pdata, width, height);
                   trans_gimage (doicons, DICON);
                   draw_object (window, DICNBOX);

                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);

                   base_spec->modified = TRUE;
                   break;
    case DDOWN   :
    case DUP     : if (window->exit_obj == DDOWN) dinum--;
                   if (window->exit_obj == DUP)   dinum++;

                   check_icn (window, base_spec->new_icon, TRUE);

                   sprintf (s, "%d", dinum);
                   set_ptext (doicons, DINUM, s);

                   sysicon = &base_spec->sysicon [dinum];
                   width   = sysicon->width;
                   height  = sysicon->height;
                   pmask   = &sysicon->icon.icondef [0];
                   pdata   = &sysicon->icon.icondef [(width + 15) / 16 * height];

                   set_idata (doicons, DICON, pmask, pdata, width, height);
                   trans_gimage (doicons, DICON);
                   draw_object (window, DICNBOX);
                   bstate = 0x0001;     /* wait again for button down */
                   break;
  } /* switch */
} /* click_icons */

/*****************************************************************************/

LOCAL BOOLEAN key_icons (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  click_icons (window, mk);

  return (FALSE);
} /* key_icons */

/*****************************************************************************/

LOCAL VOID check_icn (window, new_icon, draw)
WINDOWP window;
WORD    new_icon;
BOOLEAN draw;

{
  if ((dinum == 0) == ! is_state (doicons, DDELETE, DISABLED))
  {
    flip_state (doicons, DDELETE, DISABLED);
    if (draw) draw_object (window, DDELETE);
  } /* if */

  if ((dinum == 0) == ! is_state (doicons, DDOWN, DISABLED))
    flip_state (doicons, DDOWN, DISABLED);

  if ((dinum == new_icon - 1) == ! is_state (doicons, DUP, DISABLED))
    flip_state (doicons, DUP, DISABLED);

} /* check_icn */

/*****************************************************************************/

LOCAL VOID get_params (base_spec)
BASE_SPEC *base_spec;

{
  STRING s;
  LONG   datasize, treesize;

  datasize = 0;
  treesize = 0;

  get_ptext (dbparams, PDSIZE, s);
  if (*s) sscanf (s, "%ld", &datasize);

  get_ptext (dbparams, PTSIZE, s);
  if (*s) sscanf (s, "%ld", &treesize);

  base_spec->datasize = datasize;
  base_spec->treesize = treesize;

  if (base_spec->new)
  {
    if (get_checkbox (dbparams, PDENCODE))
      base_spec->flags |= DATA_ENCODE;
    else
      base_spec->flags &= ~ DATA_ENCODE;

    if (get_checkbox (dbparams, PTENCODE))
      base_spec->flags |= TREE_ENCODE;
    else
      base_spec->flags &= ~ TREE_ENCODE;
  } /* if */
} /* get_params */

/*****************************************************************************/

LOCAL VOID set_params (base_spec)
BASE_SPEC *base_spec;

{
  FULLNAME dbname;
  WORD     w;
  STRING   s;

  w = dbparams [PBASE].ob_width / gl_wbox;

  strcpy (dbname, base_spec->basepath);
  strcat (dbname, base_spec->basename);
  dbname [w] = EOS;
  strcpy ((BYTE *)dbparams [PBASE].ob_spec, dbname);

  sprintf (s, "%ld", base_spec->datasize);
  set_ptext (dbparams, PDSIZE, s);
  set_checkbox (dbparams, PDENCODE, (base_spec->flags & DATA_ENCODE) != 0);

  sprintf (s, "%ld", base_spec->treesize);
  set_ptext (dbparams, PTSIZE, s);
  set_checkbox (dbparams, PTENCODE, (base_spec->flags & TREE_ENCODE) != 0);

  if (base_spec->new)
  {
    do_flags (dbparams, PDENCODE, SELECTABLE);
    undo_state (dbparams, PDENCODE + 1, DISABLED);

    do_flags (dbparams, PTENCODE, SELECTABLE);
    undo_state (dbparams, PTENCODE + 1, DISABLED);
  } /* if */
  else
  {
    undo_flags (dbparams, PDENCODE, SELECTABLE);
    do_state (dbparams, PDENCODE + 1, DISABLED);

    undo_flags (dbparams, PTENCODE, SELECTABLE);
    do_state (dbparams, PTENCODE + 1, DISABLED);
  } /* else */
} /* set_params */

/*****************************************************************************/

LOCAL VOID click_params (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  LONG  datasize, treesize;
  UWORD flags;

  switch (window->exit_obj)
  {
    case POK   : datasize = param_spec->datasize;
                 treesize = param_spec->treesize;
                 flags    = param_spec->flags;

                 get_params (param_spec);

                 if ((datasize != param_spec->datasize) ||
                     (treesize != param_spec->treesize) ||
                     (flags    != param_spec->flags))
                   param_spec->modified = TRUE;
                 break;
    case PHELP : hndl_help (HDBPARAM);
                 undo_state (window->object, window->exit_obj, SELECTED);
                 draw_object (window, window->exit_obj);
                 break;
  } /* switch */
} /* click_params */

/*****************************************************************************/

LOCAL BOOLEAN key_params (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE      *p1, *p2;
  LONG      datasize, treesize;
  LONG      datafile, treefile;
  BOOLEAN   too_small;
  BASE_INFO base_info;

  click_params (window, mk);

  switch (window->edit_obj)
  {
    case PDSIZE :
    case PTSIZE : p1 = ((TEDINFO *)dbparams [PDSIZE].ob_spec)->te_ptext;
                  p2 = ((TEDINFO *)dbparams [PTSIZE].ob_spec)->te_ptext;

                  too_small = FALSE;
                  datasize  = treesize = 0;

                  if (*p1) sscanf (p1, "%ld", &datasize);
                  if (*p2) sscanf (p2, "%ld", &treesize);

                  if (! param_spec->new)
                  {
                    db_baseinfo (param_spec->base, &base_info);

                    datafile  = base_info.data_info.file_size / 1024;
                    treefile  = base_info.tree_info.num_pages / 2;
                    too_small = (datasize < datafile) || (treesize < treefile);
                  } /* if */

                  if (((*p1 == EOS) || (*p2 == EOS) ||
                       (datasize == 0) || (treesize == 0) || too_small) == ! is_state (dbparams, POK, DISABLED))
                  {
                    flip_state (dbparams, POK, DISABLED);
                    draw_object (window, POK);
                  } /* if */
                  break;
  } /* switch */

  return (FALSE);
} /* key_params */

/*****************************************************************************/

LOCAL WORD get_icolor (tree, object)
OBJECT *tree;
WORD   object;

{
  ICONBLK *piconblk;

  piconblk = (ICONBLK *)tree [object].ob_spec;

  return ((UWORD)piconblk->ib_char >> 12);
} /* get_icolor */

/*****************************************************************************/

LOCAL VOID set_icolor (tree, object, color)
OBJECT *tree;
WORD   object;
WORD   color;

{
  ICONBLK *piconblk;

  piconblk = (ICONBLK *)tree [object].ob_spec;
  piconblk->ib_char = (color << 12) | (piconblk->ib_char & 0xFFF);      /* set color of icon data */
} /* set_icolor */

/*****************************************************************************/

LOCAL VOID set_itext (tree, object, s)
OBJECT *tree;
WORD   object;
BYTE   *s;

{
  ICONBLK *piconblk;

  piconblk = (ICONBLK *)tree [object].ob_spec;
  strncpy (piconblk->ib_ptext, s, MAX_ITEXT);
  piconblk->ib_ptext [MAX_ITEXT] = EOS;
} /* set_itext */

/*****************************************************************************/

LOCAL VOID set_idata (tree, object, mask, data, width, height)
OBJECT *tree;
WORD   object;
WORD   *mask;
WORD   *data;
WORD   width;
WORD   height;

{
  ICONBLK *piconblk;
  WORD    size;

  piconblk = (ICONBLK *)tree [object].ob_spec;
  size     = (width + 15) / 16 * height * 2;

  mem_move (piconblk->ib_pmask, mask, size);
  mem_move (piconblk->ib_pdata, data, size);

  piconblk->ib_xicon = (piconblk->ib_wtext - width) / 2;
  piconblk->ib_yicon = piconblk->ib_ytext - height;
  piconblk->ib_wicon = (width + 15) / 16 * 16;
  piconblk->ib_hicon = height;
} /* set_idata */

/*****************************************************************************/

LOCAL BOOLEAN load_icon (base_spec, pmask, pdata, width, height)
BASE_SPEC *base_spec;
WORD      *pmask, *pdata;
WORD      *width, *height;

{
  BOOLEAN   ok;
  FULLNAME  filename;
  FILE      *file;
  WORD      i, j, l;
  WORD      w, h;
  UWORD     data;
  LONGSTR   s;

  ok = FALSE;

  if (select_file (icn_name, icn_path, (BYTE *)freetext [FICNSUFF].ob_spec, (BYTE *)freetext [FLOADICN].ob_spec, filename))
  {
    busy_mouse ();

    file_split (filename, NULL, icn_path, icn_name, NULL);

    file = fopen (filename, "r");
    ok   = file != NULL;

    if (! ok)
      hndl_alert (ERR_ICONREAD);
    else
    {
      text_rdln (file, s, LONGSTRLEN);
      sscanf (s, "%d,%d", &w, &h);

      w = min (w, MAX_IWIDTH);
      h = min (h, MAX_IHEIGHT);

      *width  = w;
      *height = h;

      w = (w + 15) / 16 * 16;

      text_rdln (file, s, LONGSTRLEN);  /* comment "DATA" */

      for (i = 0; i < h; i++)           /* read DATA */
      {
        text_rdln (file, s, LONGSTRLEN);
        l = strlen (s);
        mem_set (s + l, ' ', LONGSTRLEN - l);
        s [w] = EOS;
        data  = 0;

        for (j = 1; j <= w; j++)
        {
          data <<= 1;
          if (s [j - 1] != ' ') data |= 1;
          if ((j % 16) == 0) *pdata++ = data;
        } /* for */
      } /* for */

      text_rdln (file, s, LONGSTRLEN); /* comment "MASK" */

      for (i = 0; i < h; i++)          /* read MASK */
      {
        text_rdln (file, s, LONGSTRLEN);
        l = strlen (s);
        mem_set (s + l, ' ', LONGSTRLEN - l);
        s [w] = EOS;
        data  = 0;

        for (j = 1; j <= w; j++)
        {
          data <<= 1;
          if (s [j - 1] != ' ') data |= 1;
          if ((j % 16) == 0) *pmask++ = data;
        } /* for */
      } /* for */

      fclose (file);
    } /* if */

    arrow_mouse ();
  } /* if */

  return (ok);
} /* load_icon */

/*****************************************************************************/

LOCAL VOID chg_field (base_spec, table, new_column, new_index)
BASE_SPEC *base_spec;
WORD      table;
SYSCOLUMN *new_column;
SYSINDEX  *new_index;

{
  LONG      diff;
  WORD      field, index;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;
  SYSINDEX  *sysindex;
  SYSCOLUMN old_column;

  field     = new_column->number;
  index     = find_index (base_spec, table, field);
  systable  = &base_spec->systable [table];
  syscolumn = &base_spec->syscolumn [abscol (base_spec, table, field)];
  sysindex  = &base_spec->sysindex [absinx (base_spec, table, index)];

  mem_move (&old_column, syscolumn, sizeof (SYSCOLUMN));

  strcpy (syscolumn->name, new_column->name);
  syscolumn->type  = new_column->type;
  syscolumn->size  = new_column->size;
  syscolumn->flags = new_column->flags | (syscolumn->flags & NEW_COL);

  if (new_column->size != old_column.size)
  {
    diff            = new_column->size + odd (new_column->size) -
                      old_column.size  - odd (old_column.size);
    systable->size += diff;

    while (field < systable->cols)      /* change addresses of all following fields */
    {
      field++;
      syscolumn++;
      syscolumn->addr += diff;
    } /* while */
  } /* if */

  if ((new_column->flags & COL_ISINDEX) && (old_column.flags & COL_ISINDEX))
  {
    if (sysindex->num_keys == 0)
      sysindex->flags = new_index->flags;
    else
      sysindex->flags = new_index->flags | (sysindex->flags & INX_UNIQUE);

    strcpy (sysindex->name, new_index->name);
  } /* if */

  if ((new_column->flags & COL_ISINDEX) != (old_column.flags & COL_ISINDEX))
  {
    if ((! base_spec->new) && (sysindex->num_keys > 0)) base_spec->reorg = TRUE;

    if (old_column.flags & COL_ISINDEX)         /* was a former index field and must be deleted */
      if (del_key (base_spec, table, index) != SUCCESS) hndl_alert (ERR_DELKEY);
    else                                        /* field is now indexed, so add it */
      if (add_key (base_spec, table, new_index) != SUCCESS)
      {
        hndl_alert (ERR_NOKEYS);
        syscolumn->flags &= ~ COL_ISINDEX;
      } /* if */
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
    case NFDTEXT  : type = TYPE_CHAR;      break;
    case NFDWORD  : type = TYPE_WORD;      break;
    case NFDLONG  : type = TYPE_LONG;      break;
    case NFDFLOAT : type = TYPE_FLOAT;     break;
    case NFDTFLOA : type = TYPE_CFLOAT;    break;
    case NFDDATE  : type = TYPE_DATE;      break;
    case NFDTIME  : type = TYPE_TIME;      break;
    case NFDTSTAM : type = TYPE_TIMESTAMP; break;
    case NFDBYTE  : type = TYPE_BYTE;      break;
    case NFDPIC   : type = TYPE_PICTURE;   break;
    case NFDEXTRN : type = TYPE_EXTERN;    break;
    case NFDDBADR : type = TYPE_DBADDRESS; break;
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

  if (objdata [type].edit == NIL)
    size = typesize (type, s);
  else
  {
    get_ptext (newfield, objdata [type].edit, s);
    size = atol (s) + objdata [type].diff;
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
  if (xget_checkbox (newfield, NFAOUT))   flags |= COL_OUTPUT;
  if (xget_checkbox (newfield, NFANMODI)) flags |= COL_NMODIFY;
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

  switch (type)
  {
    case TYPE_CHAR   :
    case TYPE_CFLOAT :
    case TYPE_EXTERN : size--;       /* don't use closing '\0' */
                       len = (WORD)min (size, MAX_KEYSIZE - 2);
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
  UWORD flags;

  flags = 0;

  if (xget_checkbox (newfield, NFAUNIQU)) flags |= INX_UNIQUE;
  if (xget_checkbox (newfield, NFAIBLAN)) flags |= INX_NOBLANKS;
  if (xget_checkbox (newfield, NFAUPPER)) flags |= INX_UPPERCASE;

  return (flags);
} /* get_kflags */

/*****************************************************************************/

LOCAL BOOLEAN xget_checkbox (tree, obj)
OBJECT *tree;
WORD   obj;

{
  return (get_checkbox (tree, obj) && is_flags (tree, obj, SELECTABLE));
} /* xget_checkbox */

/*****************************************************************************/

LOCAL VOID set_fobjs (window, indexes)
WINDOWP window;
LONG    indexes;

{
  BOOLEAN index_disabled;
  BOOLEAN index_selected;
  BOOLEAN index_allowed;
  BOOLEAN flip_uiu;             /* unique, ignore blanks, uppercase */
  BOOLEAN flip_iname;           /* index name */
  BOOLEAN flip_ilen;            /* index length */
  WORD    type;
  LONG    size;
  BYTE    *p;

  flip_uiu       = FALSE;
  flip_iname     = FALSE;
  flip_ilen      = FALSE;
  index_disabled = ! is_flags (newfield, NFAINDEX, SELECTABLE);
  type           = get_ftype (newfield);

  switch (type)
  {
    case TYPE_BYTE    :
    case TYPE_PICTURE : index_allowed = FALSE; break;
    default           : index_allowed = TRUE;  break;
  } /* switch */

  if (! (index_allowed ^ index_disabled))
  {
    flip_flags (newfield, NFAINDEX, SELECTABLE);
    flip_state (newfield, NFAINDEX + 1, DISABLED);
    draw_object (window, NFAINDEX + 1);
  } /* if */

  index_disabled = ! is_flags (newfield, NFAINDEX, SELECTABLE);
  index_selected = is_state (newfield, NFAINDEX, SELECTED) && ! index_disabled;

  if (index_disabled || ! index_selected)
  {
    if (is_flags (newfield, NFAUNIQU, SELECTABLE)) flip_uiu   = TRUE;
    if (is_flags (newfield, NFINDEX,  EDITABLE))   flip_iname = TRUE;
    if (is_flags (newfield, NFINDLEN, EDITABLE))   flip_ilen  = TRUE;
  } /* if */

  if (index_selected)
  {
    if (! is_flags (newfield, NFAUNIQU, SELECTABLE)) flip_uiu   = TRUE;
    if (! is_flags (newfield, NFINDEX,  EDITABLE))   flip_iname = TRUE;
    if (indexes == 0)
      if (HASWILD (type) ^ is_flags (newfield, NFINDLEN, EDITABLE)) flip_ilen = TRUE;
  } /* else */

  if (flip_uiu)
  {
     flip_flags (newfield, NFAUNIQU, SELECTABLE);
     flip_state (newfield, NFAUNIQU + 1, DISABLED);
     draw_object (window, NFAUNIQU + 1);

     if (indexes == 0)
     {
       flip_flags (newfield, NFAIBLAN, SELECTABLE);
       flip_flags (newfield, NFAUPPER, SELECTABLE);
       flip_state (newfield, NFAIBLAN + 1, DISABLED);
       flip_state (newfield, NFAUPPER + 1, DISABLED);

       draw_object (window, NFAIBLAN + 1);
       draw_object (window, NFAUPPER + 1);
     } /* if */
  } /* if */

  if (flip_iname)
  {
     flip_flags (newfield, NFINDEX,  EDITABLE);
     flip_state (newfield, NFINDEXN, DISABLED);
     draw_object (window, NFINDEXN);
  } /* if */

  if (flip_ilen)
  {
     flip_flags (newfield, NFINDLEN, EDITABLE);
     flip_state (newfield, NFINDEXL, DISABLED);
     draw_object (window, NFINDEXL);
  } /* if */

  switch (window->exit_obj)
  {
    case NFDTEXT  : set_cursor (window, NFDTLEN, NIL);  break;
    case NFDTFLOA : set_cursor (window, NFDTFLEN, NIL); break;
    case NFDEXTRN : set_cursor (window, NFDELEN, NIL);  break;
    case NFDBYTE  : set_cursor (window, NFDBLEN, NIL);  break;
    case NFDPIC   : set_cursor (window, NFDPLEN, NIL);  break;

    case NFALOOKU : flip_state (newfield, NFAEDLUT, DISABLED);
                    draw_object (window, NFAEDLUT);
                    break;
  } /* switch */

  p    = ((TEDINFO *)newfield [NFFIELD].ob_spec)->te_ptext;
  size = get_fsize (newfield);

  if (((*p == EOS) || (size < 2)) == ! is_state (newfield, NFOK, DISABLED))
  {
    flip_state (newfield, NFOK, DISABLED);
    draw_object (window, NFOK);
    flip_state (newfield, NFNEXT, DISABLED);
    draw_object (window, NFNEXT);
  } /* if */
} /* set_fobjs */


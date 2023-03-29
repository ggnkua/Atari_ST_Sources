/*****************************************************************************
 *
 * Module : DESKTOP.C
 * Author : Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 26.12.02
 *
 *
 * Description: This module implements the desktop.
 *
 * History:
 * 25.12.02: wi_message wieder entfernt
 * 24.12.02: Function wi_message added for use with OLGA
 * 29.05.02: Auch wenn das clipbrd.acc nicht da ist wird das Icon des Klemmbrett
 *					 auf dem Desktop dargestellt.
 *           mem_free in open_desktop verschoben, damit sollte der Manager
 *					 unter Memory Protection laufen.
 * 01.03.97: Saved desktop window coordinates and sliders are being used
 * 14.02.97: Desktop can be shown in a window
 * 20.06.96: Database names are no longer copied to resource string
 * 06.08.95: Handling of class CLASS_ACCDEF in function wi_drag added
 * 28.07.95: Account drag operations added
 * 09.07.95: Account definitions added
 * 31.12.94: Using new function names of controls module
 * 17.11.94: Color icons supported
 * 09.07.94: Visible table capabilities added
 * 20.03.94: MOPENTBL moved to MEDIT menu
 * 08.02.94: Including of clist.h removed
 * 30.11.93: Problem with doubleclick into DBASE fixed
 * 04.11.93: Using fontdesc
 * 02.11.93: No longer using large stack variables in callback
 * 28.10.93: Always using LBS_OWNERDRAW for comboboxes
 * 10.10.93: Bug in drawing toolbox fixed
 * 07.10.93: Background of dialog box is set according to sys_colors
 * 02.10.93: Multikey bitmap added
 * 27.09.93: Comboboxes and listboxes are owner drawn
 * 16.09.93: CTRL-1 to CTRL-9 and ALT-1 to ALT-9 select tables and indexes respectively
 * 15.09.93: Click in disabled DBASE object problem fixed
 * 13.09.93: Displays with less than 16 colors use checkmarks in listboxes
 * 12.09.93: User table lists can be opened with right mouse button in iconbar
 * 09.09.93: New 3d listbox added
 * 04.09.93: Iconbar added
 * 23.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "accdef.h"
#include "calc.h"
#include "controls.h"
#include "delete.h"
#include "dialog.h"
#include "disk.h"
#include "list.h"
#include "mdbinfo.h"
#include "menu.h"
#include "mfile.h"
#include "mimpexp.h"
#include "minxinfo.h"
#include "mlsconf.h"
#include "mtblinfo.h"
#include "printer.h"
#include "process.h"
#include "report.h"
#include "resource.h"
#include "trash.h"

#include "export.h"
#include "desktop.h"

/****** DEFINES **************************************************************/

#define KIND   (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS  (WI_RESIDENT|WI_MNSCROLL)
#define XFAC   2                        /* X-Faktor */
#define YFAC   2                        /* Y-Faktor */
#define XUNITS 1                        /* X-Einheiten fÅr Scrolling */
#define YUNITS 1                        /* Y-Einheiten fÅr Scrolling */
#define INITX  (1 * gl_wbox)            /* X-Anfangsposition */
#define INITY  (3 * gl_hbox)            /* Y-Anfangsposition */
#define INITW  (desk.x + desk.w - 4 * gl_wbox) /* Anfangsbreite in Pixel */
#define INITH  (desk.y + desk.h - 5 * gl_hbox) /* Anfangshîhe in Pixel */
#define MILLI  0                        /* Millisekunden fÅr Zeitablauf */

#define KEYTEXTSIZE     13              /* Grîûe fÅr Text einer Funktionstaste */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD     scrap_id;
LOCAL BOOLEAN  clipresult;
LOCAL LONGSTR  keytext;
LOCAL RECT     rcDesktop;
LOCAL FUNCINFO iconmenus [] =
{
  {MOPTIONS,  MDESIGNE},
  {MFILE,     MOPEN},
  {MFILE,     MDISK},
  {MFILE,     MPRINT},
  {MPROCESS,  MPEXEC},
  {FUNCMENUS, MQNEW},
  {FUNCMENUS, MRNEW},
  {FUNCMENUS, MCNEW},
  {FUNCMENUS, MBNEW},
  {MEDIT,     MOPENTBL},
  {MEDIT,     MEDITDAT}
};

/****** FUNCTIONS ************************************************************/

LOCAL LONG    db_callback   _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    tbl_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    inx_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    l_iconify     _((WINDOWP window, WORD icon, BYTE *name));
LOCAL VOID    p_iconify     _((WINDOWP window, WORD icon));
LOCAL VOID    remove_icon   _((WORD icon));
LOCAL VOID    draw_dobj     _((WORD obj));
LOCAL BOOLEAN drag_react    _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    drag_objs     _((WINDOWP window, WORD obj, SET objs));
LOCAL VOID    icon_popup    _((WINDOWP window, WORD obj, MKINFO *mk));
LOCAL VOID    fill_select   _((WINDOWP window, SET objs, RECT *area));
LOCAL VOID    invert_objs   _((WINDOWP window, SET objs));
LOCAL VOID    rubber_objs   _((WINDOWP window, MKINFO *mk));
LOCAL VOID    toolbox_click _((WINDOWP window, MKINFO *mk));
LOCAL VOID    iconbar_click _((WINDOWP window, MKINFO *mk));
LOCAL VOID    sort_popup    _((MKINFO *mk));
LOCAL BOOLEAN in_icon       _((WORD mox, WORD moy, ICONBLK *icon, RECT *r));

LOCAL BOOLEAN get_cname     _((BYTE *name));
LOCAL VOID    click_cname   _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_cname     _((WINDOWP window, MKINFO *mk));

LOCAL VOID    update_menu   _((WINDOWP window));
LOCAL VOID    handle_menu   _((WINDOWP window, WORD title, WORD item));
LOCAL VOID    box           _((WINDOWP window, BOOLEAN grow));
LOCAL BOOLEAN wi_test       _((WINDOWP window, WORD action));
LOCAL VOID    wi_open       _((WINDOWP window));
LOCAL VOID    wi_close      _((WINDOWP window));
LOCAL VOID    wi_delete     _((WINDOWP window));
LOCAL VOID    wi_draw       _((WINDOWP window));
LOCAL VOID    wi_arrow      _((WINDOWP window, WORD dir, LONG oldpos, LONG newpos));
LOCAL VOID    wi_snap       _((WINDOWP window, RECT *new, WORD mode));
LOCAL VOID    wi_objop      _((WINDOWP window, SET objs, WORD action));
LOCAL WORD    wi_drag       _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    wi_click      _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_unclick    _((WINDOWP window));
LOCAL BOOLEAN wi_key        _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_timer      _((WINDOWP window));
LOCAL VOID    wi_top        _((WINDOWP window));
LOCAL VOID    wi_untop      _((WINDOWP window));
LOCAL VOID    wi_edit       _((WINDOWP window, WORD action));

/*****************************************************************************/

GLOBAL WINDOWP find_desk ()
{
  return (search_window (class_desk, SRCH_ANY, NIL));
} /* find_desk */

/*****************************************************************************/

GLOBAL VOID get_dxywh (obj, border)
WORD obj;
RECT *border;

{
  get_border (find_desk (), obj, border);
} /* get_dxywh */

/*****************************************************************************/

GLOBAL VOID set_func (keys)
CONST BYTE *keys;

{
  WORD    num, i, obj;
  STRING  key, value;
  WINDOWP desk;
  OBJECT  *desktop;
  BYTE    *p;

  desk = find_desk ();

  if (desk != NULL)
  {
    desktop = desk->object;

    if (desktop != NULL)
      for (num = 1; num <= MAX_FUNC; num++)
      {
        obj = FKEYS + num;

        for (i = 0; (keys [i] != EOS) && (keys [i] != ','); i++);

        strncpy (key, keys, i);
        key [i] = EOS;

        if (strcmp (key, "$") == 0)
        {
          strcpy (value, get_str (desktop, obj));       /* Alter Wert */
          p = strchr (value, '=');

          if (p == NULL)
            key [0] = EOS;
          else
            strcpy (key, p + 1);
        } /* if */

        strcat (key, "        ");

        key [8]  = EOS;                                 /* Maximal 8 Zeichen */
        keys    += i;
        if (*keys != EOS) keys++;

        sprintf (value, "F%d=%s", num, key);
        strcpy (get_str (desktop, obj), value);

        if (i != 0)
          undo_state (desktop, obj, DISABLED);
        else
          do_state (desktop, obj, DISABLED);
      } /* for, if */
  } /* if */
} /* set_func */

/*****************************************************************************/

GLOBAL VOID draw_func ()

{
  draw_dobj (FKEYS);
} /* draw_func */

/*****************************************************************************/

GLOBAL VOID draw_key (key)
WORD key;

{
  WINDOWP desk;
  OBJECT  *desktop;

  desk = find_desk ();

  if (desk != NULL)
  {
    desktop = desk->object;

    if (desktop != NULL)
      if (! is_flags (desktop, FKEYS, HIDETREE))
      {
        hide_mouse ();
        draw_dobj (FKEYS + key);
        show_mouse ();
      } /* if, if */
  } /* if */
} /* draw_key */

/*****************************************************************************/

GLOBAL VOID set_meminfo ()

{
  WINDOWP desk;
  OBJECT  *desktop;
  STRING  m, t, s;
  LONG    avail, total;

#if GEMDOS | MSDOS
  WORD i;
  LONG size;
  VOID *adr [100];

  total = 0;

  for (i = 0; (i < 100) && ((size = Mavail ()) > 0); i++)
  {
    adr [i]  = Malloc (size);
    total   += size;
  }/* for */

  while (i > 0) Mfree (adr [--i]);
#else
  total = mem_avail ();
#endif

  avail = mem_avail ();
  desk  = find_desk ();

  if (desk != NULL)
  {
    desktop = desk->object;

    if ((desktop != NULL) && ! is_flags (desktop, FKEYS, HIDETREE))
    {
      sprintf (m, FREETXT (FMEMORY), (WORD)(avail >> 10));
      sprintf (t, FREETXT (FTOTMEM), (WORD)(total >> 10));
      strcpy (s, get_str (desktop, INFOBOX));

      if (strcmp (s, t) != 0)             /* Es hat sich was getan */
      {
        sprintf (get_str (desktop, INFOBOX), "%s=%s", m, t);
        draw_dobj (INFOBOX);
      } /* if */
    } /* if */
  } /* if */
} /* set_meminfo */

/*****************************************************************************/

GLOBAL VOID miconify (window)
WINDOWP window;

{
  WORD   icon, i;
  STRING name;

  switch (window->class)
  {
    case CLASS_LIST    : icon = icon_avail ();

                         if (icon == NIL)
                           hndl_alert (ERR_NOICON);
                         else
                         {
                           get_qname (window, name);
                           l_iconify (window, icon, name);
                         } /* else */
                         break;
    case CLASS_PROCESS : for (i = IPROCESS, icon = NIL; (i < ITRASH) && (icon == NIL); i++)
                           if (is_flags (desktop, i, HIDETREE)) icon = i;

                         p_iconify (window, icon);
                         break;
  } /* switch */
} /* miconify */

/*****************************************************************************/

GLOBAL VOID miremove ()

{
  WORD i;

  for (i = ITABLE; i < ITRASH; i++)
    if (setin (sel_objs, i)) remove_icon (i);
} /* miremove */

/*****************************************************************************/

GLOBAL VOID morderdesk ()

{
  WORD     i;
  RECT     r;
  WINDOWP  window;
  OBJECT   *obj;
  ICON_POS *pos;

  busy_mouse ();

  window = find_desk ();

  for (i = DTABLES, obj = &desktop [i], pos = icon_pos; i <= FKEYS; i++, obj++, pos++)
  {
    objc_rect (desktop, i, &r, TRUE);

    if ((i == DTABLES) || (i == ICONBAR) || (i >= ITABLE))
      if ((obj->ob_x != pos->x) || (obj->ob_y != pos->y))
      {
        obj->ob_x = pos->x;
        obj->ob_y = pos->y;

        if ((window != NULL) && ! is_flags (desktop, i, HIDETREE))
        {
          do_flags (desktop, i, HIDETREE);

          if (i == FKEYS)
          {
            r.x--;
            r.y--;
            r.w += 2;
            r.h += 2;
          } /* if */

          redraw_window (window, &r);
          if (grow_shrink) graf_mbox (r.w, r.h, r.x, r.y, pos->x, pos->y);
          undo_flags (desktop, i, HIDETREE);

          if (i == FKEYS)
          {
            objc_rect (desktop, i, &r, TRUE);
            r.x--;
            r.y--;
            r.w += 2;
            r.h += 2;
            redraw_window (window, &r);
          } /* if */
          else
            draw_dobj (i);
        } /* if */
      } /* if, if */
  } /* for */

  arrow_mouse ();
} /* morderdesk */

/*****************************************************************************/

GLOBAL WORD icon_avail ()

{
  REG WORD i;

  for (i = ITABLE; i < IPROCESS; i++)
    if (is_flags (desktop, i, HIDETREE)) return (i);

  return (NIL);
} /* icon_avail */

/*****************************************************************************/

GLOBAL VOID get_invobjs (db, table, inv_objs)
VOID *db;
WORD table;
SET  inv_objs;

{
  REG WORD      i;
  REG ICON_INFO *iconinfo;

  setclr (inv_objs);

  for (i = ITABLE, iconinfo = icon_info; i < IPROCESS; i++, iconinfo++)
    if ((iconinfo->db == (DB *)db) &&
        (rtable (iconinfo->table) == rtable (table)) &&
        VTBL (iconinfo->table)) setincl (inv_objs, i);
} /* get_invobjs */

/*****************************************************************************/

GLOBAL VOID fill_virtual (db, table, inx, recs, recaddr, cols, columns, colwidth)
VOID *db;
WORD table, inx;
LONG recs, *recaddr;
WORD cols, *columns, *colwidth;

{
  VTABLE  *vtablep;
  WORD    icon, vtable, diff;
  WINDOWP window;
  MKINFO  mk;
  RECT    r;
  OBJECT  *objp;
  WORD    *lcolumns, *lcolwidth;
  VINDEX  *vindexp;
  STRING  name;

  graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);

  icon = icon_avail ();

  if (icon == NIL)
    hndl_alert (ERR_NOICON);
  else
  {
    if (! get_cname (table_name (db, table, name))) return;

    vtable = new_vtable (db, table, max_records, cols);

    if (vtable != FAILURE)
    {
      vtablep = VTABLEP (vtable);

      if (recs > vtablep->maxrecs) hndl_alert (ERR_VTABLEFULL);
      recs = min (recs, vtablep->maxrecs);
      mem_lmove (vtablep->recaddr, recaddr, recs * sizeof (LONG));
      vtablep->recs = recs;

      lcolumns = (WORD *)mem_alloc (2L * cols * sizeof (WORD));  /* mem_free in module list */

      if (lcolumns == NULL)
      {
        hndl_alert (ERR_NOMEMORY);
        free_vtable (vtable);
      } /* if */
      else
      {
        lcolwidth = lcolumns + cols;

        mem_move (lcolumns, columns, cols * sizeof (WORD));
        mem_move (lcolwidth, colwidth, cols * sizeof (WORD));

        if (VINX (inx))         /* increment virtual index, original could be destroyed */
        {
          vindexp = VINDEXP (inx);
          vindexp->used++;
        } /* if */

        window = crt_list (NULL, NULL, NIL, db, vtable, inx, ASCENDING, cols, lcolumns, lcolwidth, &fontdesc, NULL, NULL);

        if (window == NULL)
        {
          free_vtable (vtable);
          if (VINX (inx)) free_vindex (inx);
        } /* if */
        else
        {
          objp = &desktop [icon];
          objc_rect (desktop, icon, &r, FALSE);
          objp->ob_x += (mk.mox - r.x - objp->ob_width / 2) & 0xFFF8;
          objp->ob_y += (mk.moy - r.y - objp->ob_height / 2) & 0xFFF8;

          diff = desk.x - objp->ob_x;
          if (diff > 0) objp->ob_x += diff;
          diff = desk.x + desk.w - objp->ob_x - objp->ob_width;
          if (diff < 0) objp->ob_x += diff;

          diff = desk.y - objp->ob_y;
          if (diff > 0) objp->ob_y += diff;
          diff = desk.y + desk.h - objp->ob_y - objp->ob_height;
          if (diff < 0) objp->ob_y += diff;

          set_qname (window, name);
          l_iconify (window, icon, name);
        } /* else */
      } /* else */
    } /* if */

    set_meminfo ();
  } /* else */
} /* fill_virtual */

/*****************************************************************************/

GLOBAL LONG add_virtual (vtable, recs, recaddr)
WORD vtable;
LONG recs, *recaddr;

{
  REG LONG   more, i;
  REG VTABLE *vtablep;
  REG LONG   *addr;

  more = 0;

  if (VTBL (vtable))
  {
    vtablep = VTABLEP (vtable);

    if (recs + vtablep->recs > vtablep->maxrecs) hndl_alert (ERR_VTABLEFULL);
    recs = min (recs, vtablep->maxrecs - vtablep->recs);

    for (i = 0, addr = &vtablep->recaddr [vtablep->recs]; i < recs; i++)
      if (in_vtable (vtablep, recaddr [i]) == FAILURE) addr [more++] = recaddr [i];

    vtablep->recs += more;
  } /* if */

  return (more);
} /* add_virtual */

/*****************************************************************************/

GLOBAL BOOLEAN tbls_slctd ()

{
  REG BOOLEAN ok;
  REG WORD    i;

  ok = (sel_window != NULL) && ((sel_window->class == class_desk) || (sel_window->class == CLASS_LIST) || (sel_window->class == CLASS_TRASH));

  if (ok && (sel_window->class == class_desk))
    for (i = ITABLE, ok = FALSE; (i < IPROCESS) && ! ok; i++)
      ok = setin (sel_objs, i);

  return (ok);
} /* tbls_slctd */

/*****************************************************************************/

LOCAL LONG db_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP       window;
  BOOLEAN       visible_part;
  BYTE          *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT          r;
  WORD          i;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : for (i = 0; i < MAX_DB; i++)
                            if (db [i].pos == (WORD)index)
                              return ((LONG)db [i].base->basename);
                          break;
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                            DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? &tooldb_icon : NULL, text, 2);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* db_callback */

/*****************************************************************************/

LOCAL LONG tbl_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  MKINFO       *mk;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)actdb->t_info [actdb->vis_tables [index]].tablename);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          text         = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                          r            = lb_ownerdraw->rc_item;
                          r.w          = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                          DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? &tooltbl_icon : NULL, text, 2);
                          break;
    case LBN_SELCHANGE  : switch_table (actdb, tablenum (actdb, actdb->vis_tables [ListBoxGetCurSel (tree, obj)]));
                          check_tblinfo ();
                          check_inxinfo ();
                          break;
    case LBN_DBLCLK     : mk = p;
                          if (mk->alt || (mk->momask & 0x0002))
                            mtblinfo ();
                          else
                             mopentbl (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, DEV_SCREEN, &fontdesc, NULL, NULL, FALSE, TRUE);
                          break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* tbl_callback */

/*****************************************************************************/

LOCAL LONG inx_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  MKINFO           *mk;
  BYTE             *text;
  LB_OWNERDRAW     *lb_ownerdraw;
  RECT             r;
  T_INFO           *t_info;
  LOCAL INDEX_INFO index_info;
  WORD             num_cols;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)actdb->t_info [actdb->t_inx].i_info [index].indexname);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          text         = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                          r            = lb_ownerdraw->rc_item;
                          r.w          = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                          v_indexinfo (actdb, actdb->table, actdb->t_info [actdb->t_inx].i_info [index].indexnum, &index_info);
                          num_cols = index_info.inxcols.size / sizeof (INXCOL);
                          DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? (num_cols == 1) ? &toolinx_icon : &toolmul_icon : NULL, text, 2);
                          break;
    case LBN_SELCHANGE  : t_info = &actdb->t_info [actdb->t_inx];
                          t_info->index = indexnum (actdb, actdb->t_inx, ListBoxGetCurSel (tree, obj));
                          t_info->i_inx = ListBoxGetCurSel (tree, obj);
                          t_info->first = ListBoxGetTopIndex (tree, obj);
                          check_inxinfo ();
                          break;
    case LBN_DBLCLK     : mk = p;
                          if (mk->alt || (mk->momask & 0x0002))
                            minxinfo ();
                          else
                            mopentbl (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, DEV_SCREEN, &fontdesc, NULL, NULL, FALSE, FALSE);
                          break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* inx_callback */

/*****************************************************************************/

LOCAL VOID l_iconify (window, icon, name)
WINDOWP window;
WORD    icon;
BYTE    *name;

{
  ICON_INFO  *iconinfo;
  ICONBLK    *ib1, *ib2;
  BOOLEAN    virtual;
  TABLE_INFO ti;
  WORD       width, height;
  WORD       *pmask, *pdata;
  SYSICON    *sysicon;
  STRING     s;

  window->flags |= WI_RESIDENT;
  window->icon   = icon;
  iconinfo       = &icon_info [icon - ITABLE];

  get_listinfo (window, iconinfo, (name [0] == EOS) ? name : s);
  str_upper (name);

  virtual = VTBL (iconinfo->table);
  ib1     = (ICONBLK *)get_ob_spec (icons, virtual ? ICLIP : ITBL);
  ib2     = (ICONBLK *)get_ob_spec (desktop, icon);

  ib2->ib_pmask = ib1->ib_pmask;
  ib2->ib_pdata = ib1->ib_pdata;
  ib2->ib_char  = ib1->ib_char;
  ib2->ib_xchar = ib1->ib_xchar;
  ib2->ib_ychar = ib1->ib_ychar;
  ib2->ib_xicon = ib1->ib_xicon;
  ib2->ib_yicon = ib1->ib_yicon;
  ib2->ib_wicon = ib1->ib_wicon;
  ib2->ib_hicon = ib1->ib_hicon;

  if (! virtual)
  {
    v_tableinfo (iconinfo->db, iconinfo->table, &ti);

    if ((iconinfo->db->sysicon != NULL) && (ti.icon >= 0))
    {
      ib2->ib_char = (ti.color << 12) | (ib1->ib_char & 0x0FFF);
      sysicon      = &iconinfo->db->sysicon [ti.icon];
      width        = sysicon->width;
      height       = sysicon->height;
      pmask        = &sysicon->icon.icondef [0];
      pdata        = &sysicon->icon.icondef [(width + 15) / 16 * height];

      set_idata (desktop, icon, pmask, pdata, width, height);
    } /* if */
  } /* if */

  strncpy (ib2->ib_ptext, name, 12);

/* [GS] 5.1f Start: 
	
	if ( strlen (ib2->ib_ptext) < 12 )
	{
		ib2->ib_wtext = strlen (ib2->ib_ptext) * 6 ;
		ib2->ib_xtext = ib2->ib_xicon + (ib2->ib_wicon /2 );		/* Mitte Icon errechnen		*/
		ib2->ib_xtext -= ib2->ib_wtext / 2;
	}

 Ende */

  if (window->opened > 0) close_window (window); /* could be opened just after crt_list */
  undo_flags (desktop, icon, HIDETREE);
  draw_dobj (icon);
} /* l_iconify */

/*****************************************************************************/

LOCAL VOID p_iconify (window, icon)
WINDOWP window;
WORD    icon;

{
  PROC_INF *procp;
  STRING   name;
  ICONBLK  *ib;

  procp = (PROC_INF *)window->special;

  window->flags |= WI_RESIDENT;
  window->icon   = icon;

  if (procp->db == NULL)
    strcpy (name, FREETXT (FSPOOLER));
  else
    table_name (procp->db, procp->table, name);

  if (name [0] == EOS)
  {
    strcpy (name, procp->filename);
    str_upper (name);
  } /* if */

  ib = (ICONBLK *)get_ob_spec (desktop, icon);
  strncpy (ib->ib_ptext, name, 12);

  if (window->opened > 0) close_window (window);
  undo_flags (desktop, icon, HIDETREE);
  draw_dobj (icon);
} /* p_iconify */

/*****************************************************************************/

LOCAL VOID remove_icon (icon)
WORD icon;

{
  WINDOWP deskwin, window;
  RECT    r;

  deskwin = find_desk ();

  if (icon < IPROCESS)
    window = icon_info [icon - ITABLE].window;
  else
  {
    window = search_window (CLASS_PROCESS, SRCH_CLOSED, icon);

    if (window != NULL)
      if (hndl_alert (ERR_ABORTPROCESS) == 2) return;
  } /* else */

  objc_rect (desktop, icon, &r, TRUE);
  do_flags (desktop, icon, HIDETREE);
  undo_state (desktop, icon, SELECTED);
  redraw_window (deskwin, &r);
  setexcl (sel_objs, icon);     /* deleted icon is no longer in selected set */
  if (setcmp (sel_objs, NULL)) sel_window = NULL;
  delete_window (window);
} /* remove_icon */

/*****************************************************************************/

LOCAL VOID draw_dobj (obj)
WORD obj;

{
  draw_object (find_desk (), obj);
} /* draw_dobj */

/*****************************************************************************/

LOCAL BOOLEAN drag_react (src_window, src_obj, dest_window, dest_obj)
WINDOWP src_window;
WORD    src_obj;
WINDOWP dest_window;
WORD    dest_obj;

{
  ICON_INFO *iconinfo;
  FULLNAME  filename;
  WORD      saveformat;

  if ((ITABLE <= src_obj) && (src_obj < IPROCESS))
  {
    iconinfo = &icon_info [src_obj - ITABLE];

    if ((dest_obj == ITRASH) && VTBL (iconinfo->table)) /* remove icon from desktop instead of deleting */
    {
      remove_icon (src_obj);
      return (TRUE);
    } /* if */
    else
      return (icons_list (src_obj, dest_obj));
  } /* if */

  if (src_obj == IDISK)
    return (icons_disk (src_obj, dest_obj));

  if ((src_obj == DTBLLIST) || (src_obj == DINXLIST) || (get_ob_type (desktop, src_obj) == G_BUTTON))
  {
    switch (dest_obj)
    {
      case ITRASH   : delete_list (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, minimize, TRUE);
                      break;
      case IPRINTER : mopentbl (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, DEV_PRINTER, &fontdesc, NULL, NULL, minimize, FALSE);
                      break;
      case IDISK    : mopentbl (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, DEV_DISK, &fontdesc, NULL, NULL, minimize, FALSE);
                      break;
      case ICLIPBRD : strcpy (filename, scrapdir);
                      strcat (filename, "SCRAP.TXT");
                      saveformat            = impexpcfg.asciiformat;
                      impexpcfg.asciiformat = EXASCII;
                      mexport (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, filename, minimize);
                      impexpcfg.asciiformat = saveformat;
                      break;
    } /* switch */

    return (TRUE);
  } /* if */

  return (FALSE);
} /* drag_react */

/*****************************************************************************/

LOCAL VOID drag_objs (window, obj, objs)
WINDOWP window;
WORD    obj;
SET     objs;

{
  RECT      ob, r, bound;
  WORD      mox, moy;
  WORD      i, result, num_objs;
  WORD      dest_obj, d_obj;
  WINDOWP   dest_window;
  WINDOWP   d_window;
  OBJECT    *desktop;
  SET       inv_objs, not_objs;
  BOOLEAN   calcd, ok;
  RECT      all [FKEYS - ITABLE];
  SET       tables;
  WORD      tableobj;
  ICON_INFO *src_inf, *dst_inf;

  if (window != NULL)
  {
    desktop = window->object;

    if (desktop != NULL)
    {
      xywh2rect (desktop->ob_x, desktop->ob_y + desk.y, desktop->ob_width, desktop->ob_height - desk.y, &bound);

      setclr (inv_objs);
      num_objs = 0;

      setclr (tables);
      for (i = ITABLE; i < IPROCESS; i++)
        if (setin (objs, i))
        {
          setincl (tables, i);
          tableobj = i;
        } /* if */

      if (setcard (tables) != 1) tableobj = NIL; /* exactly one table to drag */

      if ((get_ob_type (desktop, obj) == G_ICON) || (get_ob_type (desktop, obj) == G_CICON))
        for (i = ITABLE; i < FKEYS; i++)
        {
          if (i >= ITRASH)
            setincl (inv_objs, i);
          else
            if (i < IPROCESS)                  /* any table */
              if (tableobj != NIL)             /* one table selected */
              {
                src_inf = &icon_info [tableobj - ITABLE];
                dst_inf = &icon_info [i - ITABLE];

                if ((src_inf->db == dst_inf->db) &&
                    (rtable (src_inf->table) == rtable (dst_inf->table)) &&
                    VTBL (src_inf->table) && 
                    VTBL (dst_inf->table)) setincl (inv_objs, i);
              } /* if, if, else */

          if (setin (objs, i)) objc_rect (desktop, i, &all [num_objs++], FALSE);
        } /* for, if */
      else
      {
        if ((obj == DTBLLIST) || (obj == DINXLIST) || (get_ob_type (desktop, obj) == G_BUTTON)) /* a table operation */
        {
          for (i = ITRASH; i < FKEYS; i++) setincl (inv_objs, i);

          if (! (db_acc_table (actdb->base, actdb->table) & GRANT_DELETE) || (actdb->flags & BASE_RDONLY)) setexcl (inv_objs, ITRASH);
          if (! (db_acc_table (actdb->base, actdb->table) & GRANT_SELECT))
          {
            setexcl (inv_objs, IPRINTER);
            setexcl (inv_objs, IDISK);
          } /* if */
        } /* if */

        objc_rect (desktop, obj, &all [num_objs], FALSE);

        if (obj == DTBLLIST)
        {
          all [num_objs].x += 2;
          all [num_objs].y += 2 + (ListBoxGetCurSel (desktop, obj) - ListBoxGetTopIndex (desktop, obj)) * ListBoxGetItemHeight (desktop, obj);
          all [num_objs].w -= 4;
          all [num_objs].h  = ListBoxGetItemHeight (desktop, obj);
        } /* if */
        else
          if (obj == DINXLIST)
          {
            all [num_objs].x += 2;
            all [num_objs].y += 2 + (ListBoxGetCurSel (desktop, obj) - ListBoxGetTopIndex (desktop, obj)) * ListBoxGetItemHeight (desktop, obj);
            all [num_objs].w -= 4;
            all [num_objs].h  = ListBoxGetItemHeight (desktop, obj);
          } /* if */

        num_objs++;
      } /* else */

      setcpy (not_objs, objs);
      setnot (not_objs);
      setand (inv_objs, not_objs);

      set_mouse (FLAT_HAND, NULL);
      drag_boxes (num_objs, all, window, inv_objs, &r, &bound, 8, 8);
      last_mouse ();
      graf_mkstate (&mox, &moy, &result, &result);

      r.w   = r.w / 8 * 8;
      r.h   = r.h / 8 * 8;
      calcd = FALSE;

      for (i = 0; i <= FKEYS; i++)
        if (setin (objs, i))
        {
          objc_rect (desktop, i, &ob, TRUE);

          if (i == DTBLLIST)
          {
            ob.x++;
            ob.y += 1 + (ListBoxGetCurSel (desktop, i) - ListBoxGetTopIndex (desktop, i)) * ListBoxGetItemHeight (desktop, i);
            ob.w -= 2;
            ob.h  = ListBoxGetItemHeight (desktop, i);
          } /* if */
          else
            if (obj == DINXLIST)
            {
              ob.x++;
              ob.y += 1 + (ListBoxGetCurSel (desktop, i) - ListBoxGetTopIndex (desktop, i)) * ListBoxGetItemHeight (desktop, i);
              ob.w -= 2;
              ob.h  = ListBoxGetItemHeight (desktop, i);
            } /* if */

          result = drag_to_window (mox, moy, window, i, &d_window, &d_obj);

          if (! calcd)
          {
            dest_window = d_window;
            dest_obj    = d_obj;
          } /* if */

          calcd = TRUE;                         /* Nur einmal ausrechnen */
          ok    = TRUE;

          if (dest_window != NULL)
          {
            if (dest_window->class == class_desk) result = DRAG_SWIND; /* Ein Fenster kînnte inzwischen geîffnet worden sein */

            switch (dest_window->class)
            {
              case CLASS_TRASH  : ok = drag_react (window, i, dest_window, ITRASH);
                                  break;
              case CLASS_REPORT : if ((i == DTBLLIST) || (i == DINXLIST) || (get_ob_type (desktop, i) == G_BUTTON))
                                  {
                                    ok     = rep_exec (dest_window, actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order);
                                    result = DRAG_OK;
                                  } /* if */
                                  else
                                    if ((ITABLE <= i) && (i < IPROCESS))
                                    {
                                      src_inf = &icon_info [i - ITABLE];
                                      action_list (OBJ_REP, src_inf, dest_window);
                                      result = DRAG_OK;
                                    } /* if, else */
                                  break;
              case CLASS_CALC   : if ((i == DTBLLIST) || (i == DINXLIST) || (get_ob_type (desktop, i) == G_BUTTON))
                                  {
                                    ok     = calc_exec (dest_window, actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order);
                                    result = DRAG_OK;
                                  } /* if */
                                  else
                                    if ((ITABLE <= i) && (i < IPROCESS))
                                    {
                                      src_inf = &icon_info [i - ITABLE];
                                      action_list (OBJ_CALC, src_inf, dest_window);
                                      result = DRAG_OK;
                                    } /* if, else */
                                  break;
              case CLASS_ACCDEF : if ((i == DTBLLIST) || (i == DINXLIST) || (get_ob_type (desktop, i) == G_BUTTON))
                                  {
                                    ok     = AccDefExec (dest_window, actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order);
                                    result = DRAG_OK;
                                  } /* if */
                                  else
                                    if ((ITABLE <= i) && (i < IPROCESS))
                                    {
                                      src_inf = &icon_info [i - ITABLE];
                                      action_list (OBJ_ACC, src_inf, dest_window);
                                      result = DRAG_OK;
                                    } /* if, else */
                                  break;
            } /* switch */
          } /* if */

          switch (result)
          {
            case DRAG_SWIND  : if ((DTABLES <= dest_obj) && (dest_obj < ICONBAR)) dest_obj = DTABLES;
                               if ((ICONBAR <= dest_obj) && (dest_obj < ITABLE)) dest_obj = ICONBAR;
                               if (dest_obj > FKEYS) dest_obj = FKEYS;
                               if (dest_obj == obj) dest_obj = ROOT; /* Auf gleiches Objekt */

                               if ((dest_obj == ROOT) && (i != DTBLLIST) && (i != DINXLIST) && (get_ob_type (desktop, i) != G_BUTTON))   /* Verschieben */
                               {
                                 if ((r.w != 0) || (r.h != 0))
                                 {
                                   desktop [i].ob_x += r.w;
                                   desktop [i].ob_y += r.h;

                                   if (i == FKEYS)
                                   {
                                     ob.x--;
                                     ob.y--;
                                     ob.w += 2;
                                     ob.h += 2;
                                   } /* if */

                                   do_flags (desktop, i, HIDETREE); /* Altes Objekt nicht zeichnen */
                                   redraw_window (window, &ob);

                                   undo_flags (desktop, i, HIDETREE);

                                   if (i == FKEYS)
                                   {
                                     objc_rect (desktop, i, &ob, TRUE);
                                     ob.x--;    /* Innere Funktionstasten haben Rand */
                                     ob.y--;
                                     ob.w += 2;
                                     ob.h += 2;
                                     redraw_window (window, &ob);
                                   } /* if */
                                   else
                                     draw_dobj (i);
                                 } /* if */
                               } /* if */
                               else
                               {
                                 ok = setin (inv_objs, dest_obj);
                                 if (ok) ok = drag_react (window, i, dest_window, dest_obj);
                               } /* else */
                               break;
            case DRAG_SCLASS :
            case DRAG_NOWIND :
            case DRAG_NORCVR :
            case DRAG_NOACTN : ok = FALSE;
                               break;
          } /* switch */

          if (! ok) graf_mbox (ob.w, ob.h, ob.x + r.w, ob.y + r.h, ob.x, ob.y); /* ZurÅckschnalzen */
        } /* if, for */
    } /* if */
  } /* if */
} /* drag_objs */

/*****************************************************************************/

LOCAL VOID icon_popup (window, obj, mk)
WINDOWP window;
WORD    obj;
MKINFO  *mk;

{
  WORD item;
  SET  objs;

  if ((ITABLE <= obj) && (obj < ITRASH))
  {
    item = popup_menu (popups, MICON, 0, 0, MINFOICO, TRUE, mk->momask);

    switch (item)
    {
      case MINFOICO : setclr (objs);
                      setincl (objs, obj);
                      if (window->objop != NULL) (*window->objop) (window, objs, OBJ_INFO);
                      break;
      case MOPENICO : setclr (objs);
                      setincl (objs, obj);
                      if (window->objop != NULL) (*window->objop) (window, objs, OBJ_OPEN);
                      break;
      case MDELICON : remove_icon (obj);
                      break;
    } /* switch */
  } /* if */
} /* icon_popup */

/*****************************************************************************/

LOCAL VOID fill_select (window, objs, area)
WINDOWP window;
SET     objs;
RECT    *area;

{
  REG WORD i;
      RECT r;

  setclr (objs);

  for (i = ITABLE; i < FKEYS; i++)
    if (! is_flags (window->object, i, HIDETREE))
    {
      get_border (window, i, &r);

      if (rc_intersect (area, &r))                                 /* Im Rechteck */
        if (rc_intersect (&window->scroll, &r)) setincl (objs, i); /* Im Workbereich */
    } /* if, for */
} /* fill_select */

/*****************************************************************************/

LOCAL VOID invert_objs (window, objs)
WINDOWP window;
SET     objs;

{
  REG WORD i;

  for (i = 0; i <= SETMAX; i++)
    if (setin (objs, i))
    {
      flip_state (window->object, i, SELECTED);
      draw_object (window, i);
    } /* if, for */
} /* invert_objs */

/*****************************************************************************/

LOCAL VOID rubber_objs (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  RECT r;
  SET  new_objs;

  r.x = mk->mox;
  r.y = mk->moy;

  set_mouse (POINT_HAND, NULL);
  graf_rubbox (r.x, r.y, -r.x, -r.y, &r.w, &r.h);
  last_mouse ();

  if (r.w < 0)
  {
    r.x += r.w;
    r.w  = - r.w;
  } /* if */

  if (r.h < 0)
  {
    r.y += r.h;
    r.h  = - r.h;
  } /* if */

  if (mk->shift)                                /* Auschlieûlich odernd auswÑhlen */
  {
    fill_select (window, new_objs, &r);
    invert_objs (window, new_objs);
    setxor (sel_objs, new_objs);
  } /* if */
  else
    if (mk->ctrl)                               /* ZusÑtzlich auswÑhlen */
    {
      fill_select (window, new_objs, &r);
      setnot (sel_objs);
      setand (new_objs, sel_objs);
      setnot (sel_objs);
      invert_objs (window, new_objs);
      setor (sel_objs, new_objs);
    } /* if */
    else                                        /* AuswÑhlen */
    {
      fill_select (window, sel_objs, &r);
      invert_objs (window, sel_objs);
    } /* else */

  sel_window = setcmp (sel_objs, NULL) ? NULL : window;
} /* rubber_objs */

/*****************************************************************************/

LOCAL VOID toolbox_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD obj, pos;
  SET  objs;
  LONG item;

  obj = objc_find (desktop, ROOT, MAX_DEPTH, mk->mox, mk->moy);

  if (obj == DTBLBOX) obj = DTABLES;            /* handle invisible box just as box itself */

  setclr (objs);
  setincl (objs, obj);

  switch (obj)
  {
    case DTABLES  : if ((mk->breturn == 1) && ((mk->momask & 0x0002) || mk->alt))
                      sort_popup (mk);
                    else
                      if ((mk->breturn == 1) && (mk->mobutton & 0x0001))
                        drag_objs (window, obj, objs);
                    break;
    case DBASE    : if (mk->breturn == 2)
                    {
                      if (! mk->alt && ! (mk->momask & 0x0002))
                        mopendb (NULL, TRUE);
                      else
                        if (actdb != NULL) mdbinfo ();
                    } /* if */
                    else
                      if (num_opendb > 0)
                      {
                        do_state (desktop, obj, SELECTED);
                        draw_win_obj (window, desktop, DBASE);
                        ListBoxSetComboRect (desktop, DBASE, NULL, MAX_DB / 2);
                        ListBoxSetCount (desktop, DBASE, num_opendb, NULL);
                        ListBoxSetCurSel (desktop, DBASE, actdb->pos);

                        if ((item = ListBoxComboClick (desktop, DBASE, mk)) != FAILURE)
                        {
                          pos = (WORD)item;

                          if (pos != actdb->pos)
                          {
                            switch_base (pos);
                            close_trash ();
                            crt_trash (NULL, NULL, ITRASH);
                            check_dbinfo ();
                            check_tblinfo ();
                            check_inxinfo ();
                          } /* if */
                        } /* if */

                        undo_state (desktop, obj, SELECTED);
                        draw_win_obj (window, desktop, DBASE);
                      } /* if, else */
                    break;
    case DTBLLIST :
    case DINXLIST : if (actdb != NULL)
                    {
                      if (ListBoxClick (desktop, obj, mk) != FAILURE)
                        if ((mk->breturn == 1) && (mk->mobutton & 0x0003))
                          drag_objs (window, obj, objs);
                    } /* if */
                    break;
    case DASCEND  :
    case DDESCEND : if (! is_state (desktop, obj, SELECTED))
                    {
                      flip_state (desktop, DASCEND, SELECTED);
                      flip_state (desktop, DDESCEND, SELECTED);
                      draw_object (window, DASCEND);
                      draw_object (window, DDESCEND);
                      sort_order = is_state (desktop, DASCEND, SELECTED) ? ASCENDING : DESCENDING;
                    } /* if */

                    if ((actdb != NULL) && (actdb->tables > 0))
                    {
                      if (mk->breturn == 2) mopentbl (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, DEV_SCREEN, &fontdesc, NULL, NULL, FALSE, FALSE);

                      if ((mk->breturn == 1) && (mk->mobutton & 0x0003))
                      {
                        setclr (objs);
                        setincl (objs, obj);
                        drag_objs (window, obj, objs);
                      } /* if */
                    } /* if */
                    break;
  } /* switch */
} /* toolbox_click */

/*****************************************************************************/

LOCAL VOID iconbar_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD obj, title, item;
  SET  objs;

  obj = objc_find (desktop, ROOT, MAX_DEPTH, mk->mox, mk->moy);

  if (obj == ICONBAR + 1) obj = ICONBAR;        /* handle invisible box just as box itself */

  setclr (objs);
  setincl (objs, obj);

  switch (obj)
  {
    case ICONBAR : if ((mk->breturn == 1) && (mk->mobutton & 0x0001))
                     drag_objs (window, obj, objs);
                   break;
    default      : window_button (window, desktop, obj, mk->breturn);
                   if (is_state (desktop, obj, SELECTED))
                   {
                     title = iconmenus [obj - ICNEW].title;
                     item  = iconmenus [obj - ICNEW].item;

                     if (title == FUNCMENUS)			/* trick to test whether menu is enabled */
                     {
                       title = MHELP;
                       item  = MDBINFO;
                     } /* if */

                     if (! is_state (menu, title, DISABLED) &&
                         ! is_state (menu, item, DISABLED))
                       if (window->hndl_menu != NULL)
                       {
                         switch (obj)
                         {
                           case ICQBE    : title = FUNCMENUS;
                                           item  = (mk->alt || (mk->momask & 0x0002)) ? MQLIST : MQNEW;
                                           break;
                           case ICREPDEF : title = FUNCMENUS;
                                           if (mk->ctrl)
                                             item = (mk->alt || (mk->momask & 0x0002)) ? MRLIST : MRNEW;
                                           else
                                             item = (mk->alt || (mk->momask & 0x0002)) ? MALIST : MANEW;
                                           break;
                           case ICCALDEF : title = FUNCMENUS;
                                           item  = (mk->alt || (mk->momask & 0x0002)) ? MCLIST : MCNEW;
                                           break;
                           case ICBATDEF : title = FUNCMENUS;
                                           item  = (mk->alt || (mk->momask & 0x0002)) ? MBLIST : MBNEW;
                                           break;
                         } /* switch */

                         (*window->hndl_menu) ((window->menu == NULL) ? NULL : window, title, item);
                       } /* if, if */

                     undo_state (desktop, obj, SELECTED);
                     draw_dobj (obj);
                   } /* if */
                   break;
  } /* switch */
} /* iconbar_click */

/*****************************************************************************/

LOCAL VOID sort_popup (mk)
MKINFO *mk;

{
  WORD    item, old, i;
  T_INFO  *t_info;
  BOOLEAN sort;

  sort = (actdb == NULL) ? sort_by_name : actdb->sort_by_name;

  old  = sort ? MSORTNAM : MSORTNUM;
  item = sort ? MSORTNUM : MSORTNAM;

  undo_state (popups, item, CHECKED);
  do_state (popups, old, CHECKED);

  item = popup_menu (popups, MSORTBAS, 0, 0, item, TRUE, mk->momask);

  if ((item != NIL) && (item != old))
  {
    sort_by_name = sort = ! sort;

    undo_state (popups, old, CHECKED);
    do_state (popups, item, CHECKED);

    if (actdb != NULL)
    {
      sort_tables (actdb, sort);

      actdb->sort_by_name = sort;
      actdb->t_inx        = tableinx (actdb, actdb->table);

      for (i = 0, t_info = actdb->t_info; i < actdb->tables; i++, t_info++)
        t_info->i_inx = indexinx (actdb, t_info->tablenum, t_info->index);

      ListBoxSetCurSel (desktop, DTBLLIST, sel_from_inx (actdb, actdb->t_inx));
      ListBoxSetTopIndex (desktop, DTBLLIST, sel_from_inx (actdb, actdb->t_inx));
      ListBoxRedraw (desktop, DTBLLIST);

      t_info = &actdb->t_info [actdb->t_inx];

      ListBoxSetCurSel (desktop, DINXLIST, t_info->i_inx);
      ListBoxSetTopIndex (desktop, DINXLIST, t_info->i_inx);
      ListBoxRedraw (desktop, DINXLIST);
     } /* if */
  } /* if */
} /* sort_popup */

/*****************************************************************************/

LOCAL BOOLEAN in_icon (mox, moy, icon, r)
WORD    mox, moy;
ICONBLK *icon;
RECT    *r;

{
  BOOLEAN ok;
  RECT    r1;

  ok = FALSE;

  if (inside (mox, moy, r))         /* Im gesamten Rechteck */
  {
    r1    = *r;
    r1.x += icon->ib_xicon;
    r1.y += icon->ib_yicon;
    r1.w  = icon->ib_wicon;
    r1.h  = icon->ib_ytext;         /* Bis zum Text, falls Icon kÅrzer */

    ok = inside (mox, moy, &r1);    /* Im Icon */

    if (! ok)                       /* Vielleicht im Text */
    {
      r1    = *r;
      r1.x += icon->ib_xtext;
      r1.y += icon->ib_ytext;
      r1.w  = icon->ib_wtext;
      r1.h  = icon->ib_htext;

      ok = inside (mox, moy, &r1);  /* Im Text */
    } /* if */
  } /* if */

  return (ok);
} /* in_icon */

/*****************************************************************************/

LOCAL BOOLEAN get_cname (name)
BYTE *name;

{
  WINDOWP window;
  WORD    ret;
  BOOLEAN ok;

  clipresult = FALSE;
  window      = search_window (CLASS_DIALOG, SRCH_ANY, CLIPNAME);

  if (window == NULL)
  {
    form_center (clipname, &ret, &ret, &ret, &ret);
    window = crt_dialog (clipname, NULL, CLIPNAME, FREETXT (FCLIPNAM), WI_MODAL);

    if (window != NULL)
    {
      window->click = click_cname;
      window->key   = key_cname;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (clipname, ROOT, EDITABLE);
      window->edit_inx = NIL;

      set_ptext (clipname, CLNAME, name);
      undo_state (clipname, CLOK, DISABLED);
    } /* if */

    if (! open_dialog (CLIPNAME))
    {
      delete_window (window);
      do_state (clipname, CLHELP, DISABLED);
      clipname->ob_spec = (dlg_colors < 16) ? 0x00021100L : 0x00011170L | sys_colors [COLOR_DIALOG];
      clipresult = hndl_dial (clipname, 0, FALSE, TRUE, NULL, &ok) == CLOK;
      clipname->ob_spec = (dlg_colors < 16) ? 0x00001100L : 0x00001170L | sys_colors [COLOR_DIALOG];
      undo_state (clipname, CLHELP, DISABLED);
    } /* if */
  } /* if */

  get_ptext (clipname, CLNAME, name);

  return (clipresult);
} /* get_cname */

/*****************************************************************************/

LOCAL VOID click_cname (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case CLOK   : clipresult = TRUE;
                  break;
    case CLHELP : hndl_help (HCLIPNAM);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */
} /* click_cname */

/*****************************************************************************/

LOCAL BOOLEAN key_cname (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE *p;

  click_cname (window, mk);

  p = get_str (clipname, CLNAME);

  if ((*p == EOS) == ! is_state (clipname, CLOK, DISABLED))
  {
    flip_state (clipname, CLOK, DISABLED);
    draw_object (window, CLOK);
  } /* if */

  return (FALSE);
} /* key_cname */

/*****************************************************************************/
/* Teste Fenster                                                             */
/*****************************************************************************/

LOCAL BOOLEAN wi_test (window, action)
WINDOWP window;
WORD    action;

{
  BOOLEAN ret;

  ret = TRUE;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = FALSE;
                     break;
    case DO_CUT    : ret = FALSE;
                     break;
    case DO_COPY   : ret = FALSE;
                     break;
    case DO_PASTE  : ret = (window == sel_window) && (setin (sel_objs, ITRASH) && (actdb != NULL));
                     break;
    case DO_CLEAR  : ret = (window == sel_window) && tbls_slctd ();
                     break;
    case DO_SELALL : ret = TRUE;
                     break;
    case DO_CLOSE  : ret = TRUE;
                     break;
    case DO_DELETE : ret = TRUE;
                     break;
  } /* switch */

  return (ret);
} /* wi_test */

/*****************************************************************************/
/* Schlieûe Fenster                                                          */
/*****************************************************************************/

LOCAL VOID wi_close (window)
WINDOWP window;

{
  if (! deskacc && (window->menu != NULL))      /* MenÅzeile im Desktop-Fenster */
  {
    done          = TRUE;                       /* Sonst keine MenÅzeile mehr */
    called_by [0] = EOS;                        /* Programm ganz beenden */
  } /* if */
} /* wi_close */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  WORD pxy [4];

  if (window->object == NULL)
  {
    vswr_mode (vdi_handle, MD_REPLACE);         /* Modus = replace */
    vsf_interior (vdi_handle, FIS_PATTERN);     /* Muster */
    vsf_style (vdi_handle, 4);                  /* Desktop-Muster */
    vsf_color (vdi_handle, BLUE);               /* Farbe blau */
    vsf_perimeter (vdi_handle, FALSE);          /* Keine Umrandung */

    rect2array (&window->scroll, pxy);
    v_bar (vdi_handle, pxy);                    /* Scrollbereich mit Muster fÅllen */
  } /* if */
} /* wi_draw */

/*****************************************************************************/
/* Einrasten des Fensters                                                    */
/*****************************************************************************/

LOCAL VOID wi_snap (window, new, mode)
WINDOWP window;
RECT    *new;
WORD    mode;

{
  RECT r, diff;

  wind_get (window->handle, WF_CXYWH, &r.x, &r.y, &r.w, &r.h);

  diff.x = (new->x - r.x) & 0xFFF8;             /* Differenz berechnen */
  diff.y = (new->y - r.y) & 0xFFFE;

  new->x = r.x + diff.x;                        /* Byteposition */
  new->y = r.y + diff.y;                        /* Y immer gerade */

  if (new->y < desk.y) new->y = desk.y + odd (desk.y);
} /* wi_snap */

/*****************************************************************************/
/* Objektoperationen von Fenster                                             */
/*****************************************************************************/

LOCAL VOID wi_objop (window, objs, action)
WINDOWP window;
SET     objs;
WORD    action;

{
  WORD      i;
  BOOLEAN   ok;
  WORD      msgbuf [8];
  LONGSTR   s;
  RECT      r;
  ICON_INFO *iconinfo;

  for (i = 0; i < FKEYS; i++)
    if (setin (objs, i))
      switch (action)
      {
        case OBJ_OPEN  : switch (i)
                         {
                           case ITRASH   : ok = open_trash (i);    break;
                           case IDISK    : ok = open_disk (i);     break;
                           case IPRINTER : ok = open_printer (i);  break;
                           case ICLIPBRD : if ( scrap_id != FAILURE )
                           								 {
	                           								 s [0]      = EOS;
	                                           msgbuf [0] = SCRP_OPEN;
	                                           msgbuf [1] = gl_apid;
	                                           msgbuf [2] = 0;
	                                           msgbuf [3] = strlen (s);
	                                           msgbuf [4] = (WORD)((LONG)s & 0xFFFF);
	                                           msgbuf [5] = (WORD)((LONG)s >> 16);
	
	                                           appl_write (scrap_id, sizeof (msgbuf), msgbuf);
	                                           wind_update (END_UPDATE);
	                                           evnt_mesag (msgbuf);
	                                           while (msgbuf [1] != scrap_id)
	                                           {
	                                             appl_write (gl_apid, sizeof (msgbuf), msgbuf);
	                                             evnt_mesag (msgbuf);
	                                           } /* while */
	                                           wind_update (BEG_UPDATE);
	                                           ok = msgbuf [0] == SCRP_OK;
	                                         }
                                           break;
                         } /* switch */

                         if ((ITABLE <= i) && (i < IPROCESS))
                         {
                           ok = open_list (i);

                           if (ok)
                           {
                             get_border (window, i, &r);
                             do_flags (desktop, i, HIDETREE);
                             redraw_window (window, &r);
                           } /* if */
                         } /* if */

                         if ((IPROCESS <= i) && (i < ITRASH))
                         {
                           ok = open_process (i);

                           if (ok)
                           {
                             get_border (window, i, &r);
                             do_flags (desktop, i, HIDETREE);
                             redraw_window (window, &r);
                           } /* if */
                         } /* if */

                         if (! ok) hndl_alert (ERR_NOOPEN);
                         break;
        case OBJ_INFO  : switch (i)
                         {
                           case ITRASH   : ok = info_trash (NULL, i);         break;
                           case IDISK    : ok = info_disk (NULL, i);          break;
                           case IPRINTER : ok = info_printer (NULL, i);       break;
                           case ICLIPBRD : sprintf (s, alerts [ERR_INFOCLIPBRD], scrapdir);
                                           ok = open_alert (s);
                                           break;
                         } /* switch */

                         if ((ITABLE <= i) && (i < IPROCESS)) ok = info_list (NULL, i);
                         if ((IPROCESS <= i) && (i < ITRASH)) ok = info_process (NULL, i);

                         if (! ok) hndl_alert (ERR_NOINFO);
                         break;
        case OBJ_HELP  : switch (i)
                         {
                           case ITRASH   : ok = hndl_help (HITRASH);  break;
                           case IDISK    : ok = hndl_help (HIDISK);   break;
                           case IPRINTER : ok = hndl_help (HIPRINTE); break;
                           case ICLIPBRD : ok = hndl_help (HICLIP);   break;
                         } /* switch */

                         if ((ITABLE <= i) && (i < IPROCESS))
                         {
                           iconinfo = &icon_info [i - ITABLE];
                           ok       = hndl_help (VTBL (iconinfo->table) ? HITBLCLP : HITABLE);
                         } /* if */

                         if ((IPROCESS <= i) && (i < ITRASH)) ok = hndl_help (HIPROCES);

                         if (! ok) hndl_alert (ERR_NOHELP);
                         break;
        case OBJ_DISK  :
        case OBJ_PRINT :
        case OBJ_EXP   :
        case OBJ_IMP   :
        case OBJ_DEL   :
        case OBJ_EDIT  :
        case OBJ_REP   : action_list (action, &icon_info [i - ITABLE], NULL);
                         break;
      } /* switch, if, for */

  if ((window == sel_window) && ((action == OBJ_OPEN) || (action == OBJ_EDIT))) unclick_window (window);
} /* wi_objop */

/*****************************************************************************/
/* Ziehen in das Fenster                                                     */
/*****************************************************************************/

LOCAL WORD wi_drag (src_window, src_obj, dest_window, dest_obj)
WINDOWP src_window;
WORD    src_obj;
WINDOWP dest_window;
WORD    dest_obj;

{
  if (src_window->handle == dest_window->handle) return (DRAG_SWIND); /* Im gleichen Fenster */
  if (src_window->class == dest_window->class) return (DRAG_SCLASS);  /* Gleiche Fensterart */

  if (desktop != NULL)
    if ((dest_obj != ROOT) && (get_ob_type (desktop, dest_obj) != G_ICON) && (get_ob_type (desktop, dest_obj) != G_CICON))
      return (DRAG_NOACTN);

  if (src_window->class == CLASS_LIST) return (DRAG_OK);
  if (src_window->class == CLASS_ACCDEF) return (DRAG_OK);

  return (DRAG_NOACTN);
} /* wi_drag */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD   obj;
  SET    new_objs;
  OBJECT *desktop;
  RECT   r;

  desktop = window->object;

  if (desktop != NULL)
  {
    obj = objc_find (desktop, ROOT, 2, mk->mox, mk->moy); /* Nur 2 Ebenen */

    if (obj != NIL)
      if ((get_ob_type (desktop, obj) == G_ICON) || (get_ob_type (desktop, obj) == G_CICON))
      {
        get_border (window, obj, &r);
        if (! in_icon (mk->mox, mk->moy, (ICONBLK *)get_ob_spec (desktop, obj), &r)) obj = NIL;
      } /* if, if */

    if (obj >= FKEYS)                           /* Funktionstaste */
    {
      if ((mk->breturn == 1) && (mk->mobutton & 0x0003)) /* Zieh-Operation */
      {
        obj = FKEYS;
        setclr (new_objs);
        setincl (new_objs, obj);
        drag_objs (window, obj, new_objs);
      } /* if */
      else
        if ((obj > FKEYS) && ! is_state (desktop, obj, DISABLED))
        {
          mk->ascii_code = 0;                     /* Funktionstasten haben keinen ASCII-Code */
          mk->scan_code  = F1 + obj - FKEYS - 1;  /* Funktionstaste gedrÅckt */
          mk->kreturn    = (mk->scan_code << 8) | mk->ascii_code;

          key_window (window, mk);                /* Taste fÅr Fenster */
        } /* if, else */
    } /* if */
    else
    {
      if ((obj < ICONBAR) || (obj >= ITABLE))			/* Iconbar deselektiert nicht */
        if (sel_window != window) unclick_window (sel_window);	/* Deselektieren */

      if ((get_ob_type (desktop, obj) == G_ICON) || (get_ob_type (desktop, obj) == G_CICON))
      {
        setclr (new_objs);
        setincl (new_objs, obj);                /* Aktuelles Objekt */

        if (mk->shift)
        {
          invert_objs (window, new_objs);
          setxor (sel_objs, new_objs);
          if (! setin (sel_objs, obj)) obj = NIL; /* Wieder deselektiert */
        } /* if */
        else
        {
          if (! setin (sel_objs, obj))
          {
            unclick_window (window);            /* Alte Objekte lîschen */
            invert_objs (window, new_objs);
          } /* if */

          setor (sel_objs, new_objs);
        } /* else */

        sel_window = setcmp (sel_objs, NULL) ? NULL : window;

        if ((sel_window != NULL) && (obj != NIL))
        {
          if (mk->breturn == 1)
            if ((mk->mobutton & 0x0001) && ! mk->alt) /* Zieh-Operation */
              drag_objs (window, obj, sel_objs);
            else                                /* Pop-Up-MenÅ */
              if ((mk->momask & 0x0002) || mk->alt) icon_popup (window, obj, mk);

          if (mk->breturn == 2)                 /* Doppelklick auf Icon */
          {
            if (window->objop != NULL)
              if (mk->alt || (mk->momask & 0x0002))
                (*window->objop) (sel_window, sel_objs, OBJ_INFO);
              else
                (*window->objop) (sel_window, sel_objs, OBJ_OPEN);
          } /* if */
        } /* if */
      } /* if */
      else
        if ((DTABLES <= obj) && (obj < ICONBAR))
          toolbox_click (window, mk);
        else
          if ((ICONBAR <= obj) && (obj < ITABLE))
            iconbar_click (window, mk);
          else
          {
            if (! (mk->shift || mk->ctrl)) unclick_window (window); /* Deselektieren */
            if ((mk->breturn == 1) && (mk->mobutton & 0x0001))      /* Gummiband-Operation */
              rubber_objs (window, mk);
          } /* else, else, if */
    } /* else */
  } /* if */
  else
    if (sel_window != window) unclick_window (sel_window); /* Deselektieren */
} /* wi_click */

/*****************************************************************************/

LOCAL VOID wi_unclick (window)
WINDOWP window;

{
  if (window->object != NULL) invert_objs (window, sel_objs);
} /* wi_unclick */

/*****************************************************************************/
/* Taste fÅr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOLEAN wi_key (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD   func, obj, i, title, item;
  LONG   index;
  OBJECT *desktop;
  MKINFO key;
  T_INFO *t_info;

  desktop = window->object;

  if (mk->scan_code == INSERT)          /* INSERT entspricht Control-V */
  {
    mk->ascii_code = SYN;
    mk->ctrl       = TRUE;
  } /* if */

  if (mk->scan_code == DELETE)          /* DELETE entspricht Control-X */
  {
    mk->ascii_code = EOT;
    mk->ctrl       = TRUE;
  } /* if */

  if (mk->scan_code == UNDO)            /* UNDO enspricht Control-Z */
  {
    mk->ascii_code = SUB;
    mk->ctrl       = TRUE;
  } /* if */

  if (desktop != NULL)
  {
    if ((2 <= mk->scan_code) && (mk->scan_code <= 11) && mk->ctrl)
    {
      index = mk->scan_code - 2;

      if ((actdb != NULL) && (ListBoxGetCurSel (desktop, DTBLLIST) != index) && (index < ListBoxGetCount (desktop, DTBLLIST)))
      {
        ListBoxSetCurSel (desktop, DTBLLIST, index);
        ListBoxSetTopIndex (desktop, DTBLLIST, index);
        ListBoxRedraw (desktop, DTBLLIST);
        switch_table (actdb, tablenum (actdb, actdb->vis_tables [ListBoxGetCurSel (desktop, DTBLLIST)]));
        check_tblinfo ();
        check_inxinfo ();
      } /* if */

      return (TRUE);
    } /* if */

    if ((ALT_1 <= mk->scan_code) && (mk->scan_code <= ALT_0))
    {
      index = mk->scan_code - ALT_1;

      if ((actdb != NULL) && (ListBoxGetCurSel (desktop, DINXLIST) != index) && (index < ListBoxGetCount (desktop, DINXLIST)))
      {
        ListBoxSetCurSel (desktop, DINXLIST, index);
        ListBoxSetTopIndex (desktop, DINXLIST, index);
        t_info = &actdb->t_info [actdb->t_inx];
        t_info->index = indexnum (actdb, actdb->t_inx, ListBoxGetCurSel (desktop, DINXLIST));
        t_info->i_inx = ListBoxGetCurSel (desktop, DINXLIST);
        t_info->first = ListBoxGetTopIndex (desktop, DINXLIST);
        ListBoxRedraw (desktop, DINXLIST);
        check_inxinfo ();
      } /* if */

      return (TRUE);
    } /* if */

    key = *mk;

    if (key.scan_code == HELP) key.scan_code = F1;

    if (! (key.shift || key.ctrl || key.alt) && (F1 <= key.scan_code) && (key.scan_code <= F10) || (F6 <= key.scan_code) && (key.scan_code <= F9) && ! key.ctrl && ! key.shift)
    {
      func = key.scan_code - F1 + 1;
      obj  = FKEYS + func;              /* Objektnummer der Funktionstaste */

      if (! is_state (desktop, obj, DISABLED))
      {
        do_state (desktop, obj, SELECTED);
        draw_key (func);

        i     = key.scan_code - F1;
        title = funcmenus [i].title;
        item  = funcmenus [i].item;

        if (item != 0)
        {
          if (window->hndl_menu != NULL)
          {
            switch (key.scan_code)
            {
              case F6 : title = FUNCMENUS;
                        item  = key.alt ? MQLIST : MQNEW;
                        break;
              case F7 : title = FUNCMENUS;
                        item  = key.alt ? MALIST : MANEW;
                        break;
              case F8 : title = FUNCMENUS;
                        item  = key.alt ? MCLIST : MCNEW;
                        break;
              case F9 : title = FUNCMENUS;
                        item  = key.alt ? MBLIST : MBNEW;
                        break;
            } /* switch */

            (*window->hndl_menu) ((window->menu == NULL) ? NULL : window, title, item);
          } /* if */
        } /* if */

        undo_state (desktop, obj, SELECTED);
        draw_key (func);
      } /* if */

      return (TRUE);
    } /* if */
  } /* if */

  if (menu_key (window, mk)) return (TRUE);

  return (FALSE);
} /* wi_key */

/*****************************************************************************/
/* Cut/Copy/Paste fÅr Fenster                                                */
/*****************************************************************************/

LOCAL VOID wi_edit (window, action)
WINDOWP window;
WORD    action;

{
  WORD i;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : break;
    case DO_CUT    : break;
    case DO_COPY   : break;
    case DO_PASTE  : undelete_list (actdb, SYS_DELETED, 0, ASCENDING, minimize);
                     break;
    case DO_CLEAR  : for (i = ITABLE; i < IPROCESS; i++)
                       if (setin (sel_objs, i))
                         action_list (OBJ_DEL, &icon_info [i - ITABLE], NULL);
                     break;
    case DO_SELALL : unclick_window (sel_window);
                     for (i = ITABLE; i < ITRASH; i++)
                      if (! is_flags (desktop, i, HIDETREE))
                        setincl (sel_objs, i);
                     invert_objs (window, sel_objs);
                     if (! setcmp (sel_objs, NULL)) sel_window = window;
                     break;
  } /* switch */
} /* wi_edit */

/*****************************************************************************/

GLOBAL VOID save_desktop (file)
FILE *file;

{
  WINDOWP desk;

  desk = find_desk ();

  fprintf (file, "UseDesktopWindow=%d\n", bUseDesktopWindow);
  fprintf (file, "TopDesktopWindow=%d\n", bTopDesktopWindow);
  fprintf (file, "UseDesktopWindowSliders=%d\n", bUseDesktopWindowSliders);

  if (desk != NULL)
  {
    fprintf (file, "DesktopWindowX=%d\n", (class_desk == DESKWINDOW) ? desk->scroll.x : rcDesktop.x);
    fprintf (file, "DesktopWindowY=%d\n", (class_desk == DESKWINDOW) ? desk->scroll.y : rcDesktop.y);
    fprintf (file, "DesktopWindowW=%d\n", (class_desk == DESKWINDOW) ? desk->scroll.w : rcDesktop.w);
    fprintf (file, "DesktopWindowH=%d\n", (class_desk == DESKWINDOW) ? desk->scroll.h : rcDesktop.h);
  } /* if */
} /* save_desktop */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_desktop (obj, menu, icon)
OBJECT *obj, *menu;
WORD   icon;

{
  WINDOWP window;
  WORD    kind_desk, menu_height;

  kind_desk = (class_desk == DESK) ? 0 : KIND;

  if (! deskacc)
    kind_desk &= ~CLOSER;

  if (class_desk == DESKWINDOW)
    if (! bUseDesktopWindowSliders)
      kind_desk &= ~(SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE);

  window = create_window (kind_desk, class_desk);

  if (window != NULL)
  {
    menu_height = (menu != NULL) ? gl_hattr : 0;

    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = desk.w / XFAC;
    window->doc.h     = desk.h / YFAC;
    window->xfac      = XFAC;
    window->yfac      = YFAC;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;

    if (window->class == DESK)                  /* RegulÑrer Desktop */
    {
      window->scroll.x = desk.x;
      window->scroll.y = desk.y;
      window->scroll.w = desk.w;
      window->scroll.h = desk.h;
    } /* if */
    else                                        /* Desktop im Fenster */
    {
      window->scroll.x = INITX - odd (desk.x);
      window->scroll.y = INITY - odd (desk.y);
      window->scroll.w = INITW;
      window->scroll.h = INITH;
      window->scroll   = rcDesktop;
    } /* else */

    window->work.x    = window->scroll.x;
    window->work.y    = window->scroll.y - menu_height;
    window->work.w    = window->scroll.w;
    window->work.h    = window->scroll.h + menu_height;
    window->bg_color  = -1;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = 0;
    window->object    = obj;
    window->menu      = menu;
    window->hndl_menu = hndl_menu;              /* Globaler MenÅ-Handler */
    window->updt_menu = updt_menu;              /* Globaler MenÅ-Updater */
    window->test      = wi_test;
    window->open      = NULL;
    window->close     = wi_close;
    window->delete    = NULL;
    window->draw      = wi_draw;
    window->arrow     = NULL;
    window->snap      = wi_snap;
    window->objop     = wi_objop;
    window->drag      = wi_drag;
    window->click     = wi_click;
    window->unclick   = wi_unclick;
    window->key       = wi_key;
    window->timer     = NULL;
    window->top       = NULL;
    window->untop     = NULL;
    window->edit      = wi_edit;
    window->showinfo  = info_desktop;
    window->showhelp  = help_desktop;

    if (class_desk != DESK)                     /* Desktop im Fenster */
      if (obj != NULL)                          /* Dokument angleichen */
      {                                         /* Muû grîûer werden */
        if (obj->ob_width  > desk.x + desk.w) window->doc.w = obj->ob_width / XFAC;
        if (obj->ob_height > desk.y + desk.h) window->doc.h = obj->ob_height / YFAC;
      } /* if, if */

    if (obj == NULL)
    {
      window->doc.w = 0;                        /* Immer groûe Slider zeigen */
      window->doc.h = 0;
    } /* if */
#if 0
    else
      window->doc.y = window->doc.h - window->scroll.h / window->yfac; /* Unten positionieren */
#endif

    strcpy (window->name, FREETXT (FDESKNAM));  /* Name Deskfenster */
    strcpy (window->info, "");                  /* Infozeile immer leer */
  } /* if */

  return (window);                              /* Fenster zurÅckgeben */
} /* crt_desktop */

/*****************************************************************************/
/* ôffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_desktop (icon)
WORD icon;

{
  BOOLEAN  ok;
  WINDOWP  window;
  OBJECT   *w_menu;
  FULLNAME infname, tmpname;
  WORD     msgbuff [8];
  BYTE     *pInf;

  bUseDesktopWindow = FALSE;
  bTopDesktopWindow = FALSE;

  strcpy (infname, cfg_path);
  strcat (infname, cfg_name);

  if ((pInf = ReadInfFile (infname)) != NULL)
  {
    bUseDesktopWindow        = GetProfileBool (pInf, "Global", "UseDesktopWindow", bUseDesktopWindow);
    bTopDesktopWindow        = GetProfileBool (pInf, "Global", "TopDesktopWindow", bTopDesktopWindow);
    bUseDesktopWindowSliders = GetProfileBool (pInf, "Global", "UseDesktopWindowSliders", bUseDesktopWindowSliders);

    if (bUseDesktopWindow)
      class_desk = DESKWINDOW;

  } /* if */

  rcDesktop.x = GetProfileWord (pInf, "Global", "DesktopWindowX", INITX - odd (desk.x));
  rcDesktop.y = GetProfileWord (pInf, "Global", "DesktopWindowY", INITY - odd (desk.y));
  rcDesktop.w = GetProfileWord (pInf, "Global", "DesktopWindowW", INITW);
  rcDesktop.h = GetProfileWord (pInf, "Global", "DesktopWindowH", INITH);

	if ( pInf != NULL )
		mem_free (pInf);

  w_menu = NULL;

  if (class_desk != DESK)
    if (! menu_fits || deskacc) w_menu = menu;

  window = find_desk ();                /* Suche Desktop */

  if (window == NULL)
  {
    window = crt_desktop (desktop, w_menu, icon);

    strcpy (infname, cfg_path);
    strcat (infname, FREETXT (FDESKNAM));
    str_rmchar (infname, SP);
    strcpy (tmpname, infname);

    strcat (infname, FREETXT (FINFSUFF) + 1);
    strcat (tmpname, FREETXT (FTMPSUFF) + 1);

    if (file_exist (tmpname))
    {
      mload_config (tmpname, FALSE, tail [0] == EOS); /* Lade temporÑre Datei */
      file_remove (tmpname);
    } /* if */
    else
      mload_config (infname, FALSE, tail [0] == EOS); /* Lade regulÑre Datei */
  } /* if */

  ok = window != NULL;

  if (ok)
  {
    if (window->opened == 0)
    {
      if (hide_func)
        do_flags (desktop, FKEYS, HIDETREE);
      else
        undo_flags (desktop, FKEYS, HIDETREE);

      if (hide_iconbar)
        do_flags (desktop, ICONBAR, HIDETREE);
      else
        undo_flags (desktop, ICONBAR, HIDETREE);

      setclr (menus);                   /* Zwinge Funktionstasten einzutragen */
      set_meminfo ();                   /* Speicher anzeigen */
      updt_menu (NULL);                 /* AnfangsmenÅ und Funktionstasten */
      ok = open_window (window);        /* Desktop îffnen */

      if (ok)
      {
        if (! bTopDesktopWindow)
          wind_set (window->handle, WF_BEVENT, TRUE, 0, 0, 0);

        ListBoxSetSpec (desktop, DBASE, (LONG)window);
        ListBoxSetWindowHandle (desktop, DTBLLIST, window->handle);
        ListBoxSetWindowHandle (desktop, DINXLIST, window->handle);
      } /* if */
    } /* if */
    else
      top_window (window);              /* Bringe Desktop nach oben */

    if ((num_opendb == 0) && (tail [0] == EOS)) /* mopendb ("", TRUE);*/
    {
      msgbuff [0] = MN_SELECTED;
      msgbuff [1] = 0;
      msgbuff [2] = 0;
      msgbuff [3] = MFILE;
      msgbuff [4] = MOPEN;
      msgbuff [5] = 0;
      msgbuff [6] = 0;
      msgbuff [7] = 0;

      appl_write (gl_apid, sizeof (msgbuff), msgbuff);
    } /* if */
  } /* if */

  return (ok);
} /* open_desktop */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_desktop (window, icon)
WINDOWP window;
WORD    icon;

{
  about_menu ();

  return (TRUE);
} /* info_desktop */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_desktop (window, icon)
WINDOWP window;
WORD icon;

{
  return (hndl_help (HDESKTOP));
} /* help_desktop */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_desktop ()

{
  WORD i;

  sort_order = is_state (desktop, DASCEND, SELECTED) ? ASCENDING : DESCENDING;
  scrap_id   = appl_find (CLIPBRD);

  for (i = 1; i <= MAX_FUNC; i++)
    set_ob_spec (desktop, FKEYS + i, (LONG)&keytext [(i - 1) * KEYTEXTSIZE]);

  set_ob_spec (desktop, INFOBOX, (LONG)&keytext [MAX_FUNC * KEYTEXTSIZE]);

  ListBoxSetCallback (desktop, DBASE, db_callback);
  ListBoxSetCallback (desktop, DTBLLIST, tbl_callback);
  ListBoxSetCallback (desktop, DINXLIST, inx_callback);
  ListBoxSetStyle (desktop, DBASE, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (desktop, DTBLLIST, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE | LBS_TOUCHEXIT | LBS_MANDATORY | LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (desktop, DINXLIST, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE | LBS_TOUCHEXIT | LBS_MANDATORY | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (desktop, DBASE, gl_wbox / 2);
  ListBoxSetLeftOffset (desktop, DTBLLIST, gl_wbox / 2);
  ListBoxSetLeftOffset (desktop, DINXLIST, gl_wbox / 2);

  return (TRUE);
} /* init_desktop */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_desktop ()

{
  return (TRUE);
} /* term_desktop */

/*****************************************************************************/


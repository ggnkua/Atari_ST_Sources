/*****************************************************************************
 *
 * Module : DESKTOP.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 26.12.02
 *
 *
 * Description: This module implements the desktop.
 *
 * History:
 * 26.12.02: OLGA Teile aus wi_message entfernt
 * 30.05.02: mem_free in open_desktop verschoben, damit sollte der Designer
 *					 unter Memory Protection laufen.
 * 19.03.97: Function save_desktop added, desktop can be shown in a window
 * 19.02.97: Function wi_message added for use with OLGA
 * 21.11.94: Color icons supported
 * 02.05.94: STR128 replaced with FULLNAME
 * 06.09.93: Modifications for 3D-function keys made
 * 01.09.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include <olga.h>
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "base.h"
#include "clipbrd.h"
#include "dialog.h"
#include "event.h"
#include "mask.h"
#include "menu.h"
#include "moptions.h"

#include "export.h"
#include "desktop.h"

/****** DEFINES **************************************************************/

#define KIND   (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS  (WI_RESIDENT)
#define XFAC   2                        /* X-Faktor */
#define YFAC   2                        /* Y-Faktor */
#define XUNITS 1                        /* X-Einheiten fÅr Scrolling */
#define YUNITS 1                        /* Y-Einheiten fÅr Scrolling */
#define INITX  (2 * gl_wbox)            /* X-Anfangsposition */
#define INITY  (6 * gl_hbox)            /* Y-Anfangsposition */
#define INITW  (desk.x + desk.w -  6 * gl_wbox) /* Anfangsbreite in Pixel */
#define INITH  (desk.y + desk.h - 10 * gl_hbox) /* Anfangshîhe in Pixel */
#define MILLI  0                        /* Millisekunden fÅr Zeitablauf */

#define KEYTEXTSIZE     13              /* Grîûe fÅr Text einer Funktionstaste */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL LONGSTR  keytext;
LOCAL RECT     rcDesktop;

/****** FUNCTIONS ************************************************************/

LOCAL VOID    draw_dobj   _((WORD obj));
LOCAL BOOLEAN drag_react  _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    drag_objs   _((WINDOWP window, WORD obj, SET objs));
LOCAL VOID    fill_select _((WINDOWP window, SET objs, RECT *area));
LOCAL VOID    invert_objs _((WINDOWP window, SET objs));
LOCAL VOID    rubber_objs _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN in_icon     _((WORD mox, WORD moy, ICONBLK *icon, RECT *r));

LOCAL VOID    update_menu _((WINDOWP window));
LOCAL VOID    handle_menu _((WINDOWP window, WORD title, WORD item));
LOCAL VOID    box         _((WINDOWP window, BOOLEAN grow));
LOCAL BOOLEAN wi_test     _((WINDOWP window, WORD action));
LOCAL VOID    wi_open     _((WINDOWP window));
LOCAL VOID    wi_close    _((WINDOWP window));
LOCAL VOID    wi_delete   _((WINDOWP window));
LOCAL VOID    wi_draw     _((WINDOWP window));
LOCAL VOID    wi_arrow    _((WINDOWP window, WORD dir, LONG oldpos, LONG newpos));
LOCAL VOID    wi_snap     _((WINDOWP window, RECT *new, WORD mode));
LOCAL VOID    wi_objop    _((WINDOWP window, SET objs, WORD action));
LOCAL WORD    wi_drag     _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    wi_click    _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_unclick  _((WINDOWP window));
LOCAL BOOLEAN wi_key      _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_timer    _((WINDOWP window));
LOCAL VOID    wi_top      _((WINDOWP window));
LOCAL VOID    wi_untop    _((WINDOWP window));
LOCAL VOID    wi_edit     _((WINDOWP window, WORD action));

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
  if (dest_obj == ITRASH)
  {
    clear_clipbrd ((ccp_ext & DO_EXTERNAL) != 0);
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
  RECT    ob, r, bound;
  WORD    mox, moy;
  WORD    i, result, num_objs;
  WORD    dest_obj, d_obj;
  WINDOWP dest_window;
  OBJECT  *desktop;
  SET     inv_objs, not_objs;
  BOOLEAN calcd, ok;
  RECT    all [FKEYS - ITRASH];

  if (window != NULL)
  {
    desktop = window->object;

    if (desktop != NULL)
    {
      xywh2rect (desktop->ob_x, desktop->ob_y + desk.y, desktop->ob_width, desktop->ob_height - desk.y, &bound);

      setclr (inv_objs);
      num_objs = 0;

      if ((get_ob_type (desktop, obj) == G_ICON) || (get_ob_type (desktop, obj) == G_CICON))
        for (i = ITRASH; i < FKEYS; i++)
        {
          setincl (inv_objs, i);
          if (setin (objs, i)) objc_rect (desktop, i, &all [num_objs++], FALSE);
        } /* for */
      else
        objc_rect (desktop, obj, &all [num_objs++], FALSE);

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

          result = drag_to_window (mox, moy, window, i, &dest_window, &d_obj);

          if (! calcd) dest_obj = d_obj;
          calcd = TRUE;                         /* Nur einmal ausrechnen */
          ok    = TRUE;

          switch (result)
          {
            case DRAG_OK     : paste_clipbrd (dest_window, &r, (ccp_ext & DO_EXTERNAL) != 0);
                               break;
            case DRAG_SWIND  : if (dest_obj > FKEYS) dest_obj = FKEYS;
                               if (dest_obj == obj) dest_obj = ROOT; /* Auf gleiches Objekt */

                               if (dest_obj == ROOT)    /* Verschieben */
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
                                 ok = drag_react (window, i, dest_window, dest_obj);
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

LOCAL VOID fill_select (window, objs, area)
WINDOWP window;
SET     objs;
RECT    *area;

{
  REG WORD i;
      RECT r;

  setclr (objs);

  for (i = ITRASH; i < FKEYS; i++)
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
    case DO_UNDO   : ret = FALSE; break;
    case DO_CUT    : ret = FALSE; break;
    case DO_COPY   : ret = FALSE; break;
    case DO_PASTE  : ret = FALSE; break;
    case DO_CLEAR  : ret = (window == sel_window) && (setin (sel_objs, ICLIPBRD));
                     break;
    case DO_SELALL : break;
    case DO_CLOSE  : break;
    case DO_DELETE : break;
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
  BOOLEAN ext, ok;
  WORD    i;

  ext = (action & DO_EXTERNAL) != 0;
  ok  = FALSE;

  for (i = 0; i < FKEYS; i++)
    if (setin (objs, i))
      switch (action)
      {
        case OBJ_OPEN : switch (i)
                        {
			                  	case ITRASH   : break;
        									case ICLIPBRD : ok = TRUE;
                        									if (check_clipbrd (ext))
                         										info_clipbrd (ext);
                                          break;
                        } /* switch */

                        if (! ok) hndl_alert (ERR_NOOPEN);
                        break;
        case OBJ_INFO : switch (i)
                        {
			  									case ITRASH   : break;
                          case ICLIPBRD : ok = TRUE;
                                          info_clipbrd (ext);
                                          break;
                        } /* switch */

                        if (! ok) hndl_alert (ERR_NOINFO);
                        break;
        case OBJ_HELP : switch (i)
                        {
												  case ITRASH   : ok = hndl_help (HTRASH);   break;
			  									case ICLIPBRD : ok = hndl_help (HCLIPBRD); break;
                        } /* switch */

                        if (! ok) hndl_alert (ERR_NOHELP);
                        break;
      } /* switch, if, for */

  if ((window == sel_window) && (action == OBJ_OPEN)) unclick_window (window);
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
  if (src_window->class == CLASS_BASE) return (DRAG_OK);
  if (src_window->class == CLASS_MASK) return (DRAG_OK);

  if (desktop != NULL)
    if ((dest_obj != ROOT) && (get_ob_type (desktop, dest_obj) != G_ICON) && (get_ob_type (desktop, dest_obj) != G_CICON))
      return (DRAG_NOACTN);

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
      if (sel_window != window) unclick_window (sel_window); /* Deselektieren */

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
      {
        if (! (mk->shift || mk->ctrl)) unclick_window (window); /* Deselektieren */
        if ((mk->breturn == 1) && (mk->mobutton & 0x0001))      /* Gummiband-Operation */
          rubber_objs (window, mk);
      } /* else */
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
  WORD    func, obj, i;
  OBJECT  *desktop;
  WINDOWP wind;
  MKINFO  key;

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
    key = *mk;

    if (key.scan_code == HELP) key.scan_code = F1;

    if (! (key.shift || key.ctrl || key.alt) && (F1 <= key.scan_code) && (key.scan_code <= F10))
    {
      func = key.scan_code - F1 + 1;
      obj  = FKEYS + func;		/* Objektnummer der Funktionstaste */

      if (! is_state (desktop, obj, DISABLED))
      {
        do_state (desktop, obj, SELECTED);
        draw_key (func);

        i = key.scan_code - F1;

        if (funcmenus [i].item != 0)
        {
          wind = (window->menu == NULL) ? NULL : window;

          if (window->hndl_menu != NULL)
            (*window->hndl_menu) (wind, funcmenus [i].title, funcmenus [i].item);
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

LOCAL BOOLEAN wi_message (WINDOWP window, WORD *msg)
{
	return (FALSE);
} /* wi_message */

/*****************************************************************************/
/* Cut/Copy/Paste fÅr Fenster                                                */
/*****************************************************************************/

LOCAL VOID wi_edit (window, action)
WINDOWP window;
WORD    action;

{
  BOOLEAN ext;
  WORD    i;

  ext = (action & DO_EXTERNAL) != 0;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : break;
    case DO_CUT    : break;
    case DO_COPY   : break;
    case DO_PASTE  : break;
    case DO_CLEAR  : if (setin (sel_objs, ICLIPBRD)) clear_clipbrd (ext);
                     break;
    case DO_SELALL : unclick_window (sel_window);
                     sel_window = window;
                     for (i = ITRASH; i < FKEYS; i++)
                       if (! is_flags (desktop, i, HIDETREE)) setincl (sel_objs, i);
                     invert_objs (window, sel_objs);
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
    window->message   = wi_message;
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
  FULLNAME infname;
  WORD     msgbuff [8];
  WINDOWP  winds [MAX_GEMWIND];
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
    window = crt_desktop (desktop, w_menu, icon);

  strcpy (infname, app_path);
  strcat (infname, FREETXT (FDESKNAM));
  str_rmchar (infname, SP);
  strcat (infname, FREETXT (FINFSUFF) + 1);

  mload_config (infname, (tail [0] == EOS) && ! deskacc);

  ok = window != NULL;

  if (ok)
  {
    if (window->opened == 0)
    {
      if (hidefunc)
        do_flags (desktop, FKEYS, HIDETREE);
      else
        undo_flags (desktop, FKEYS, HIDETREE);

      setclr (menus);                   /* Zwinge Funktionstasten einzutragen */
      set_meminfo ();                   /* Speicher anzeigen */
      updt_menu (NULL);                 /* AnfangsmenÅ und Funktionstasten */
      ok = open_window (window);        /* Desktop îffnen */

      if (ok)
        if (! bTopDesktopWindow)
          wind_set (window->handle, WF_BEVENT, TRUE, 0, 0, 0);
    } /* if */
    else
      top_window (window);              /* Bringe Desktop nach oben */

    if ((num_windows (CLASS_BASE, SRCH_ANY, winds) == 0) && (tail [0] == EOS))
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
  BOOLEAN ok;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, ABOUT);

  if (window == NULL)
  {
    form_center (about, &ret, &ret, &ret, &ret);
    window = crt_dialog (about, NULL, ABOUT, FREETXT (FABOUT), WI_MODELESS);
  } /* if */

  ok = window != NULL;

  if (ok) ok = open_dialog (ABOUT);

  return (ok);
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

  for (i = 1; i <= MAX_FUNC; i++)
    set_ob_spec (desktop, FKEYS + i, (LONG)&keytext [(i - 1) * KEYTEXTSIZE]);

  set_ob_spec (desktop, INFOBOX, (LONG)&keytext [MAX_FUNC * KEYTEXTSIZE]);

  return (TRUE);
} /* init_desktop */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_desktop ()

{
  return (TRUE);
} /* term_desktop */


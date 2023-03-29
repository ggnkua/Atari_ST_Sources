/*****************************************************************************
 *
 * Module : IMAGE.C
 * Author : Dieter & JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the gem image window.
 *
 * History:
 * 27.01.04: wi_message an neue öbergabe angepasst.
 * 10.03.97: Handling of Olga, wi_click & wi_message added 
 * 31.12.94: Using new function names of controls module
 * 29.03.94: STR128 replaced by FULLNAME
 * 02.11.93: Bit image width isn't restricted to a multiple of 16
 * 30.10.93: New build_img routine used
 * 16.09.93: Struct IMG_HEADER removed
 * 14.09.93: Local function box removed, draw_growbox used instead
 * 13.09.93: Using correct width of a bit image
 * 03.09.93: Function set_redraw called because of smart redraws in wi_snap
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include <olga.h>
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "printer.h"

#include "export.h"
#include "image.h"

/****** DEFINES **************************************************************/

#define KIND   (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS  (WI_CURSKEYS)
#define XFAC   1                        /* X-Faktor */
#define YFAC   1                        /* Y-Faktor */
#define XUNITS 8                        /* X-Einheiten fÅr Scrolling */
#define YUNITS 8                        /* Y-Einheiten fÅr Scrolling */
#define INITX  (2 * gl_wbox)               /* X-Anfangsposition */
#define INITY  (3 * gl_hbox)            /* Y-Anfangsposition */
#define INITW  initw                    /* Anfangsbreite in Pixel */
#define INITH  inith                    /* Anfangshîhe in Pixel */
#define MILLI  0                        /* Millisekunden fÅr Zeitablauf */

#define MIN_WIDTH    (8 * gl_wbox)      /* Kleinste Breite */
#define MIN_HEIGHT   (4 * gl_hbox)      /* Kleinste Hîhe */

/****** TYPES ****************************************************************/

typedef UBYTE HUGE *HUPTR;

typedef struct
{
  FULLNAME filename;
  WORD     planes;
  MFDB     s;
  HUPTR    raster_buf;
  WORD     width, height;
} IMG_INF;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

#if GEMDOS
EXTERN VOID   vdi             _((VOID));
#if TURBO_C
#define v_bit_image do_bit_image
LOCAL  VOID   do_bit_image    _((WORD handle, CONST BYTE *filename,
                                 WORD aspect, WORD x_scale, WORD y_scale,
                                 WORD h_align, WORD v_align, WORD *xy ));
#endif /* TURBO_C */
#endif /* GEMDOS */

LOCAL VOID    flip_word       _((HUPTR adr));
LOCAL BOOLEAN read_bit_image  _((IMG_INF *img_inf));

LOCAL VOID    update_menu     _((WINDOWP window));
LOCAL VOID    handle_menu     _((WINDOWP window, WORD title, WORD item));
LOCAL BOOLEAN wi_test         _((WINDOWP window, WORD action));
LOCAL VOID    wi_open         _((WINDOWP window));
LOCAL VOID    wi_close        _((WINDOWP window));
LOCAL VOID    wi_delete       _((WINDOWP window));
LOCAL VOID    wi_draw         _((WINDOWP window));
LOCAL VOID    wi_arrow        _((WINDOWP window, WORD dir, LONG oldpos, LONG newpos));
LOCAL VOID    wi_snap         _((WINDOWP window, RECT *new, WORD mode));
LOCAL VOID    wi_objop        _((WINDOWP window, SET objs, WORD action));
LOCAL WORD    wi_drag         _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    wi_click        _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_unclick      _((WINDOWP window));
LOCAL BOOLEAN wi_key          _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_timer        _((WINDOWP window));
/* [GS] 5.1d Start: */
LOCAL BOOLEAN wi_message 			_((WINDOWP window, WORD *msg, MKINFO *mk));
/* Ende; alt:
LOCAL BOOLEAN wi_message      _((WINDOWP window, WORD *msg));
*/
LOCAL VOID    wi_top          _((WINDOWP window));
LOCAL VOID    wi_untop        _((WINDOWP window));
LOCAL VOID    wi_edit         _((WINDOWP window, WORD action));

/*****************************************************************************/

#if GEMDOS /* TURBO-C auf ATARI ST kann v_bit_image nicht direkt aufrufen */
#if TURBO_C
LOCAL VOID do_bit_image (handle, filename, aspect, x_scale, y_scale, h_align, v_align, xy)
      WORD handle, aspect, x_scale, y_scale, h_align, v_align;
      WORD *xy;
CONST BYTE *filename;

{
  WORD i;

  for (i = 0; i < 4; i++) ptsin [i] = xy [i];

  intin [0] = aspect;
  intin [1] = x_scale;
  intin [2] = y_scale;
  intin [3] = h_align;
  intin [4] = v_align;

  i = 5;
  while ((intin [i++] = (WORD)(UBYTE)*filename++) != 0);

  contrl [0] = 5;
  contrl [1] = 2;
  contrl [3] = --i;
  contrl [5] = 23;
  contrl [6] = handle;

  vdi ();
} /* do_bit_image */
#endif /* TURBO_C */
#endif /* GEMDOS */

/*****************************************************************************/

GLOBAL VOID print_image (filename)
BYTE *filename;

{
  WORD       xy [4];
  WORD       out_handle;
  DEVINFO    dev_info;
  STRING     filespec;
  STRING     act_path, img_path;
  WORD       act_drive, img_drive;
  FHANDLE    handle;
  LONG       size_header;
  IMG_HEADER *img_header;
  IMG_HEADER header;
  WORD       port;

  port = 0;
  if (! prn_check (port)) return;

  out_handle = open_work (PRINTER, &dev_info);

  if (out_handle > 0)
  {
    handle = file_open (filename, O_RDONLY);

    if (handle < 0)                          /* Datei nicht gefunden */
    {
      file_error (ERR_FILEOPEN, filename);
      return;
    } /* if */
    else
    {
      size_header = sizeof (IMG_HEADER);
      file_read (handle, size_header, &header);
      img_header = &header;
      file_close (handle);

#if I8086
      {
        UBYTE *img_buffer;
        WORD  i, headlen;

        img_buffer = (UBYTE *)&header;
        headlen    = img_header->headlen;
        flip_word ((HUPTR)&headlen);
        for (i = 0; i < headlen; i++) flip_word ((HUPTR)&img_buffer [i * 2]);
      } /* #if */
#endif

      busy_mouse ();
      set_meminfo ();
      get_path (act_path);
      act_drive = get_drive ();

      file_split (filename, &img_drive, img_path, filespec, NULL);
      set_drive (img_drive);
      set_path (img_path);

      xy [0] = 0;
      xy [1] = 0;
      xy [2] = xy [0] + img_header->sl_width - 1;
      xy [3] = xy [1] + img_header->sl_height - 1;

      v_bit_image (out_handle, filespec, 0, 1, 0, 1, 1, xy);

      v_updwk (out_handle);
      close_work (PRINTER, out_handle);
      set_drive (act_drive);
      set_path (act_path);
      set_meminfo ();
      arrow_mouse ();
    } /* else */
  } /* if */
} /* print_image */

/*****************************************************************************/

LOCAL VOID flip_word (adr)
HUPTR adr;

{
  REG UBYTE c;

  c       = adr [0];
  adr [0] = adr [1];
  adr [1] = c;
} /* flip_word */

/*****************************************************************************/

LOCAL BOOLEAN read_bit_image (img_inf)
IMG_INF *img_inf;

{
  BOOLEAN    ok;
  FHANDLE    handle;
  IMG_HEADER *img_header;
  LONG       img_len;
  HUPTR      img_buffer;

  ok     = FALSE;
  handle = file_open (img_inf->filename, O_RDONLY);

  if (handle < 0)                          /* Datei nicht gefunden */
    file_error (ERR_FILEOPEN, img_inf->filename);
  else
  {
    busy_mouse ();

    img_len    = file_length (img_inf->filename);
    img_buffer = (HUPTR)mem_alloc (img_len);

    if (img_buffer == NULL)
      hndl_alert (ERR_NOMEMORY);
    else
    {
      img_header          = (IMG_HEADER *)img_buffer;
      img_len             = file_read (handle, img_len, (VOID FAR *)img_buffer); /* read data */
      img_inf->raster_buf = BuildImg (img_buffer, &img_inf->width, &img_inf->height, &img_inf->planes);

      if (img_inf->raster_buf == NULL)
        hndl_alert (ERR_NOMEMORY);
      else
      {
        ok             = TRUE;
        img_inf->s.mp  = img_inf->raster_buf;
        img_inf->s.fwp = img_header->sl_width;
        img_inf->s.fh  = img_header->sl_height;
        img_inf->s.fww = (img_header->sl_width + 15) / 16;
        img_inf->s.np  = (img_header->planes == 1) ? 1 : planes;
      } /* else */

      mem_free ((VOID *)img_buffer);
      arrow_mouse ();
    } /* else */

    file_close (handle);
    OlgaLink (img_inf->filename, 0);
  } /* else */

  return (ok);
} /* read_bit_image */

/*****************************************************************************/
/* MenÅbehandlung                                                            */
/*****************************************************************************/

LOCAL VOID update_menu (window)
WINDOWP window;

{
} /* update_menu */

/*****************************************************************************/

LOCAL VOID handle_menu (window, title, item)
WINDOWP window;
WORD    title, item;

{
  if (window != NULL)
    menu_normal (window, title, FALSE);         /* Titel invers darstellen */

  if (window != NULL)
    menu_normal (window, title, TRUE);          /* Titel wieder normal darstellen */
} /* handle_menu */

/*****************************************************************************/
/* ôffne Fenster                                                             */
/*****************************************************************************/

LOCAL VOID wi_open (window)
WINDOWP window;

{
  draw_growbox (window, TRUE);
} /* wi_open */

/*****************************************************************************/
/* Schlieûe Fenster                                                          */
/*****************************************************************************/

LOCAL VOID wi_close (window)
WINDOWP window;

{
  draw_growbox (window, FALSE);
} /* wi_close */

/*****************************************************************************/
/* Lîsche Fenster                                                            */
/*****************************************************************************/

LOCAL VOID wi_delete (window)
WINDOWP window;

{
  IMG_INF *img_inf;

  img_inf = (IMG_INF *)window->special;
  OlgaUnlink (img_inf->filename, 0);
  mem_free ((VOID *)img_inf->raster_buf);
  mem_free (img_inf);
  set_meminfo ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  IMG_INF *img_inf;
  MFDB    d;
  RECT    r;
  WORD    pxy [8];
  WORD    index [2];
  WORD    width, height;

  img_inf = (IMG_INF *)window->special;

  pxy [0] = window->doc.x * window->xfac + clip.x - window->scroll.x;
  pxy [1] = window->doc.y * window->yfac + clip.y - window->scroll.y;

  width  = min (img_inf->s.fwp - pxy [0], clip.w);
  width  = max (width, 0);
  height = min (img_inf->s.fh - pxy [1], clip.h);
  height = max (height, 0);

  pxy [2] = pxy [0] + width - 1;
  pxy [3] = pxy [1] + height - 1;
  pxy [4] = clip.x;
  pxy [5] = clip.y;
  pxy [6] = pxy [4] + width - 1;
  pxy [7] = pxy [5] + height - 1;

  index [0] = BLACK;
  index [1] = WHITE;

  d.mp = NULL; /* screen */

  if (window->scroll.w > img_inf->width)
  {
    r   = window->scroll;
    r.x = pxy [6] + 1;
    rc_intersect (&window->scroll, &r);
    rc_intersect (&clip, &r);
    clr_area (&r);
  } /* if */

  if (window->scroll.h > img_inf->height)
  {
    r   = window->scroll;
    r.y = pxy [7] + 1;
    rc_intersect (&window->scroll, &r);
    rc_intersect (&clip, &r);
    clr_area (&r);
  } /* if */

  if ((width > 0) && (height > 0))
    if (img_inf->planes == 1)   /* Quellbild in monochrom zeichnen */
      vrt_cpyfm (vdi_handle, MD_REPLACE, pxy, &img_inf->s, &d, index);
    else                        /* Quellbild in Farbe zeichnen */
      vro_cpyfm (vdi_handle, S_ONLY, pxy, &img_inf->s, &d);
} /* wi_draw */

/*****************************************************************************/
/* Reagiere auf Pfeile                                                       */
/*****************************************************************************/

LOCAL VOID wi_arrow (window, dir, oldpos, newpos)
WINDOWP window;
WORD    dir;
LONG    oldpos, newpos;

{
  LONG delta;

  delta = newpos - oldpos;

  if (dir & HORIZONTAL)         /* Horizontale Pfeile und Schieber */
  {
    if (delta != 0)                             /* Scrolling nîtig */
    {
      window->doc.x = newpos;                   /* Neue Position */

      set_sliders (window, HORIZONTAL, SLPOS);  /* Schieber setzen */
      scroll_window (window, HORIZONTAL, delta * window->xfac);
    } /* if */
  } /* if */
  else                          /* Vertikale Pfeile und Schieber */
  {
    if (delta != 0)                             /* Scrolling nîtig */
    {
      window->doc.y = newpos;                   /* Neue Position */

      set_sliders (window, VERTICAL, SLPOS);    /* Schieber setzen */
      scroll_window (window, VERTICAL, delta * window->yfac);
    } /* if */
  } /* else */
} /* wi_arrow */

/*****************************************************************************/
/* Einrasten des Fensters                                                    */
/*****************************************************************************/

LOCAL VOID wi_snap (window, new, mode)
WINDOWP window;
RECT    *new;
WORD    mode;

{
  RECT r, diff;
  WORD wbox, hbox;
  LONG max_xdoc, max_ydoc;

  wind_get (window->handle, WF_CXYWH, &r.x, &r.y, &r.w, &r.h);

  wbox   = window->xfac;
  hbox   = window->yfac;

  diff.x = (new->x - r.x) / wbox * wbox;        /* Differenz berechnen */
  diff.w = (new->w - r.w) / wbox * wbox;
  diff.h = (new->h - r.h);

  new->x = r.x + diff.x;                        /* Schnelle Position */
  new->w = r.w + diff.w;                        /* Arbeitsbereich einrasten */

  if (mode & SIZED)
  {
    r.w      = (window->scroll.w + diff.w) / wbox; /* Neuer Scrollbereich */
    max_xdoc = window->doc.w - r.w;
    r.h      = (window->scroll.h + diff.h) / hbox;
    max_ydoc = window->doc.h - r.h;

    if (max_xdoc < 0) max_xdoc = 0;
    if (max_ydoc < 0) max_ydoc = 0;

    if (window->doc.x > max_xdoc)               /* Jenseits rechter Bereich */
    {
      set_redraw (window, &window->work);       /* Wegen smart redraw */
      window->doc.x = max_xdoc;
    } /* if */

    if (window->doc.y > max_ydoc)               /* Jenseits unterer Bereich */
    {
      set_redraw (window, &window->work);       /* Wegen smart redraw */
      window->doc.y = max_ydoc;
    } /* if */
  } /* if */
} /* wi_snap */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  FULLNAME szExt;
  IMG_INF  *img_inf;

  if (mk->breturn == 2)	/* Doppelklick startet OlgaServer */
  {
    img_inf = (IMG_INF *)window->special;

    strcpy (szExt, ".");
    file_split (img_inf->filename, NULL, NULL, NULL, &szExt [1]);

    OlgaStartExt (szExt, img_inf->filename);
  } /* if */
} /* wi_click */

/*****************************************************************************/

/* [GS] 5.1d Start */
LOCAL BOOLEAN wi_message (WINDOWP window, WORD *msg, MKINFO *mk)
/* Ende; alt:
LOCAL BOOLEAN wi_message (WINDOWP window, WORD *msg)
*/
{
  BYTE    *pFilename;
  IMG_INF *img_inf;

  if (msg [0] == OLGA_UPDATED)
  {
    if (olga_apid >= 0)		/* search for objects with corresponding filename */
    {
      pFilename = (BYTE *)*(LONG *)(msg + 3);
      img_inf = (IMG_INF *)window->special;

      if (strcmp (pFilename, img_inf->filename) == 0)
      {
        OlgaUnlink (img_inf->filename, 0);
        mem_free ((VOID *)img_inf->raster_buf);
        read_bit_image (img_inf);	/* does OlgaLink again */
        set_redraw (window, &window->scroll);
      } /* if */
    } /* if */

    return (FALSE);	/* let other windows also handle this message */
  } /* if */

  return (FALSE);
} /* wi_message */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_image (obj, menu, icon, filename)
OBJECT *obj, *menu;
WORD   icon;
BYTE   *filename;

{
  WINDOWP  window;
  WORD     menu_height, inx;
  FULLNAME s;
  IMG_INF  *img_inf;
  WORD     initw, inith;

  img_inf = (IMG_INF *)mem_alloc ((LONG)sizeof (IMG_INF));
  if (img_inf == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL); /* zuwenig Speicher */
  } /* if */

  mem_set (img_inf, 0, sizeof (IMG_INF));
  strcpy (img_inf->filename, filename);

  if (! read_bit_image (img_inf))
  {
    mem_free (img_inf);
    return (NULL);
  } /* if */

  initw = min (desk.w - 2 * gl_wattr, img_inf->width);
  inith = min (desk.h - 2 * gl_hattr, img_inf->height);
  initw = max (initw, MIN_WIDTH);
  inith = max (inith, MIN_HEIGHT);

  inx    = num_windows (CLASS_IMAGE, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_IMAGE);

  if (window != NULL)
  {
    menu_height = (menu != NULL) ? gl_hattr : 0;

    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = img_inf->width / XFAC;
    window->doc.h     = img_inf->height / YFAC;
    window->xfac      = XFAC;
    window->yfac      = YFAC;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->scroll.x  = INITX + inx * XFAC;
    window->scroll.y  = INITY + inx * gl_hbox + odd (menu_height);
    window->scroll.w  = INITW;
    window->scroll.h  = INITH;
    window->work.x    = window->scroll.x;
    window->work.y    = window->scroll.y - menu_height;
    window->work.w    = window->scroll.w;
    window->work.h    = window->scroll.h + menu_height;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)img_inf;
    window->object    = obj;
    window->menu      = menu;
    window->hndl_menu = handle_menu;
    window->updt_menu = update_menu;
    window->test      = NULL;
    window->open      = wi_open;
    window->close     = wi_close;
    window->delete    = wi_delete;
    window->draw      = wi_draw;
    window->arrow     = wi_arrow;
    window->snap      = wi_snap;
    window->objop     = NULL;
    window->drag      = NULL;
    window->click     = wi_click;
    window->unclick   = NULL;
    window->key       = NULL;
    window->timer     = NULL;
    window->message   = wi_message;
    window->top       = NULL;
    window->untop     = NULL;
    window->edit      = NULL;
    window->showinfo  = info_image;
    window->showhelp  = help_image;

    if ((strchr (filename, DRIVESEP) == NULL) && (strchr (filename, PATHSEP) == NULL))
      strcpy (s, act_path);
    else
      s [0] = EOS;

    strcat (s, filename);
    sprintf (window->name, " %s ", s);
  } /* if */
  else
  {
    mem_free ((VOID *)img_inf->raster_buf);
    mem_free (img_inf);
  } /* else */

  set_meminfo ();
  return (window);                      /* Fenster zurÅckgeben */
} /* crt_image */

/*****************************************************************************/
/* ôffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_image (icon, filename)
WORD icon;
BYTE *filename;

{
  BOOLEAN ok;
  WINDOWP window;

  if ((icon != NIL) && (window = search_window (CLASS_IMAGE, SRCH_OPENED, icon)) != NULL)
  {
    ok = TRUE;
    top_window (window);
  } /* if */
  else
  {
    if ((window = search_window (CLASS_IMAGE, SRCH_CLOSED, icon)) == NULL)
      window = crt_image (NULL, NULL, icon, filename);

    ok = window != NULL;

    if (ok) ok = open_window (window);
  } /* else */

  return (ok);
} /* open_image */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_image (window, icon)
WINDOWP window;
WORD    icon;

{
  LONGSTR s, d;
  WORD    colors;
  IMG_INF *img_inf;

  if (window != NULL)
  {
    img_inf = (IMG_INF *)window->special;
    colors  = 1L << img_inf->planes;
    strcpy (s, alerts [ERR_INFOIMAGE]);
    sprintf (d, s, img_inf->width, img_inf->height, colors);
    open_alert (d);
  } /* if */

  return (window != NULL);
} /* info_image */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_image (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HIMAGE));
} /* help_image */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_image ()

{
  return (TRUE);
} /* init_image */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_image ()

{
  return (TRUE);
} /* term_image */


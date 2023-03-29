/*****************************************************************************
 *
 * Module : META.C
 * Author : Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the gem metafile window.
 *
 * History:
 * 27.01.04: wi_message an neue öbergabe angepasst.
 * 26.03.97: Handling of V_FTEXT, VST_ARBPT32, VST_SETSIZE32 added
 * 10.03.97: Handling of Olga, wi_click & wi_message added 
 * 29.03.94: STR128 replaced by FULLNAME
 * 28.10.93: Function set_redraw called because of smart redraws in wi_snap
 * 07.10.93: Background of dialog box is set according to sys_colors
 * 14.09.93: Local function box removed, draw_growbox used instead
 * 22.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include <olga.h>
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "desktop.h"
#include "dialog.h"
#include "image.h"
#include "printer.h"
#include "resource.h"

#include "export.h"
#include "meta.h"

/****** DEFINES **************************************************************/

#define KIND   (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS  (WI_CURSKEYS)
#define XFAC   1                        /* X-Faktor */
#define YFAC   1                        /* Y-Faktor */
#define XUNITS 64                       /* X-Einheiten fÅr Scrolling */
#define YUNITS 64                       /* Y-Einheiten fÅr Scrolling */
#define INITX  ( 4 * gl_wbox)           /* X-Anfangsposition */
#define INITY  ( 8 * gl_hbox)           /* Y-Anfangsposition */
#define INITW  (36 * gl_wbox)           /* Anfangsbreite in Pixel */
#define INITH  ( 8 * gl_hbox)           /* Anfangshîhe in Pixel */
#define MILLI  0                        /* Millisekunden fÅr Zeitablauf */

#define V_CLRWK               3  /* Metafile VDI Funktionen */
#define V_UPDWK               4
#define V_ESC                 5
#define V_PLINE               6
#define V_PMARKER             7
#define V_GTEXT               8
#define V_FILLAREA            9
#define V_GDP                11
#define VST_HEIGHT           12
#define VST_ROTATION         13
#define VS_COLOR             14
#define VSL_TYPE             15
#define VSL_WIDTH            16
#define VSL_COLOR            17
#define VSM_TYPE             18
#define VSM_HEIGHT           19
#define VSM_COLOR            20
#define VST_FONT             21
#define VST_COLOR            22
#define VSF_INTERIOR         23
#define VSF_STYLE            24
#define VSF_COLOR            25
#define VSWR_MODE            32
#define VST_ALIGNMENT        39
#define VSF_PERIMETER       104
#define VST_EFFECTS         106
#define VST_POINT           107
#define VSL_ENDS            108
#define VSF_UDPAT           112
#define VSL_UDSTY           113
#define VR_RECFL            114
#define VS_CLIP             129
#define V_FTEXT             241
#define VST_ARBPT32         246
#define VST_SETSIZE32       252

#define V_BAR                 1  /* Metafile VDI GDP Funktionen */
#define V_ARC                 2
#define V_PIESLICE            3
#define V_CIRCLE              4
#define V_ELLIPSE             5
#define V_ELLARC              6
#define V_ELLPIE              7
#define V_RBOX                8
#define V_RFBOX               9
#define V_JUSTIFIED          10

#define V_EXIT_CUR            2 /* Metafile VDI ESC Funktionen */
#define V_ENTER_CUR           3
#define V_FORM_ADV           20
#define V_OUTPUT_WINDOW      21
#define V_CLEAR_DISP_LIST    22
#define V_BIT_IMAGE          23
#define V_ALPHA_TEXT         25
#define V_TOPBOT          18501

#define MIN_BUFFER          256
#define META_BUF            512 /* WORDS, [sizeof (META_HEADER) / 2, 32767] */

/****** TYPES ****************************************************************/

typedef struct meta_header
{
  WORD id;
  WORD headlen;
  WORD version;
  WORD transform;
  WORD min_x;
  WORD min_y;
  WORD max_x;
  WORD max_y;
  WORD pwidth;
  WORD pheight;
  WORD ll_x;
  WORD ll_y;
  WORD ur_x;
  WORD ur_y;
  WORD bit_image;
} META_HEADER;

typedef struct drect
{
  DOUBLE x;
  DOUBLE y;
  DOUBLE w;
  DOUBLE h;
} DRECT;

typedef struct point
{
  WORD x;
  WORD y;
} POINT;

typedef struct
{
  WORD        drive;
  FULLNAME    path;
  FULLNAME    filename;
  FHANDLE     f;
  LONG        fsize;
  LONG        buflen;
  UWORD       *buffer;
  META_HEADER header;
  BOOLEAN     first;
  WORD        device;
  LONG        vdi_calls;
  BOOLEAN     best_fit;
  LRECT       out_device;
  LRECT       dst_pixel;
  LONG        pic_w;
  LONG        pic_h;
} META_INF;

/****** VARIABLES ************************************************************/

LOCAL WORD    out_handle;
LOCAL FHANDLE meta_f;
LOCAL LONG    meta_index;
LOCAL LONG    meta_buflen;
LOCAL UWORD   *meta_buffer;
LOCAL UWORD   help_buffer [MIN_BUFFER];
LOCAL BOOLEAN flip_x, flip_y;
LOCAL LRECT   src;
LOCAL LRECT   dst;
LOCAL DOUBLE  dst_factor;       /* Faktor zum Einpassen */
LOCAL DRECT   aspect_factor;    /* Faktor fÅr Ma·stabstreue */
LOCAL DRECT   src_pixel;
LOCAL POINT   origo;
LOCAL RECT    doc;
LOCAL BOOLEAN best_fit;

/****** FUNCTIONS ************************************************************/

#if GEMDOS | MSDOS | OS2 /* FLEXOS kennt den direkten vdi-Aufruf nicht */
EXTERN VOID   vdi             _((VOID));
#endif

LOCAL VOID    get_screen_info _((META_INF *meta_inf, WORD vdi_handle));
LOCAL VOID    meta_info       _((WINDOWP window));
LOCAL UWORD   flip_word       _((UWORD w));
LOCAL BOOLEAN read_meta       _((META_INF *meta_inf));
LOCAL WORD    fetch_word      _((VOID));
LOCAL BOOLEAN get_code        _((VOID));
LOCAL WORD    new_width       _((WORD width));
LOCAL WORD    new_height      _((WORD height));
LOCAL VOID    transform       _((VOID));
LOCAL VOID    get_header_info _((WINDOWP window));
LOCAL VOID    do_command      _((WORD device));
LOCAL VOID    show_meta       _((WINDOWP window));

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

GLOBAL VOID print_meta (filename)
BYTE *filename;

{
  WINDOW   window;
  META_INF meta_inf;
  DEVINFO  dev_info;
  WORD     port;

  port = 0;
  if (! prn_check (port)) return;

  mem_set (&meta_inf, 0, sizeof (META_INF));
  strcpy (meta_inf.filename, filename);
  meta_inf.device   = PRINTER;
  meta_inf.best_fit = TRUE;

  if (read_meta (&meta_inf))
  {
    out_handle = open_work (PRINTER, &dev_info);

    if (out_handle > 0)
    {
      busy_mouse ();
      vst_load_fonts (out_handle, 0);
      set_meminfo ();

      meta_inf.out_device.x = 0;
      meta_inf.out_device.y = 0;
      meta_inf.out_device.w = dev_info.dev_w;
      meta_inf.out_device.h = dev_info.dev_h;
      meta_inf.dst_pixel.w  = dev_info.pix_w;
      meta_inf.dst_pixel.h  = dev_info.pix_h;

      window.doc.x     = 0;
      window.doc.y     = 0;
      window.doc.w     = 0;
      window.doc.h     = 0;
      window.xfac      = 1;
      window.yfac      = 1;
      window.xunits    = 0;
      window.yunits    = 0;
      window.scroll.x  = meta_inf.out_device.x;
      window.scroll.y  = meta_inf.out_device.y;
      window.scroll.w  = meta_inf.out_device.w;
      window.scroll.h  = meta_inf.out_device.h;
      window.special   = (LONG)&meta_inf;

      show_meta (&window);
      vst_unload_fonts (out_handle, 0);
      close_work (PRINTER, out_handle);
      mem_free (meta_buffer);
      set_meminfo ();
      arrow_mouse ();
    } /* if */
  } /* if */
} /* print_meta */

/*****************************************************************************/

LOCAL VOID get_screen_info (meta_inf, vdi_handle)
META_INF *meta_inf;
WORD     vdi_handle;

{
  WORD work_out [57];
  WORD point;
  WORD char_w, char_h, cell_w, cell_h;
  WORD minADE, maxADE, width;
  WORD distances [5], effects [3];
  LONG pix_w, pix_h;

  vq_extnd (vdi_handle, FALSE, work_out);

  meta_inf->out_device.x = 0;
  meta_inf->out_device.y = 0;
  meta_inf->out_device.w = work_out [0] + 1L;
  meta_inf->out_device.h = work_out [1] + 1L;

  meta_inf->dst_pixel.w = work_out [3];
  meta_inf->dst_pixel.h = work_out [4];

  vst_font (vdi_handle, FONT_SWISS);
  point = vst_point (vdi_handle, 99, &char_w, &char_h, &cell_w, &cell_h);
  vqt_font_info (vdi_handle, &minADE, &maxADE, distances, &width, effects);

  char_h = distances [1] + distances [3] + 1;
  pix_h  = point * 25400L / 72 / char_h;
  pix_w  = pix_h * meta_inf->dst_pixel.w / meta_inf->dst_pixel.h;

  meta_inf->dst_pixel.w = pix_w;
  meta_inf->dst_pixel.h = pix_h;

  vst_font (vdi_handle, FONT_SYSTEM);
} /* get_screen_info */

/*****************************************************************************/

LOCAL VOID meta_info (window)
WINDOWP window;

{
  WORD     page_w, page_h, ret;
  BOOLEAN  ok;
  STRING   s;
  META_INF *meta_inf;


  meta_inf = (META_INF *)window->special;

  get_header_info (window);

  page_w = meta_inf->header.pwidth;
  page_h = meta_inf->header.pheight;
  sprintf (get_str (infmeta, MPAGEW), "%2d.%02d", page_w / 100, page_w % 100);
  sprintf (get_str (infmeta, MPAGEH), "%2d.%02d", page_h / 100, page_h % 100);

  if (meta_inf->best_fit)
  {
    sprintf (get_str (infmeta, MPICW), "%5ld", src.w);
    sprintf (get_str (infmeta, MPICH), "%5ld", src.h);
  } /* if */
  else
  {
    sprintf (get_str (infmeta, MPICW), "%5ld", meta_inf->pic_w);
    sprintf (get_str (infmeta, MPICH), "%5ld", meta_inf->pic_h);
  } /* else */

  sprintf (s, "%lf", src_pixel.w);
  s [6] = EOS;
  strcpy (get_str (infmeta, MPIXW), s);
  sprintf (s, "%lf", src_pixel.h);
  s [6] = EOS;
  strcpy (get_str (infmeta, MPIXH), s);

  sprintf (get_str (infmeta, MORIGOX), "%6d", origo.x);
  sprintf (get_str (infmeta, MORIGOY), "%6d", origo.y);

  sprintf (s, "%lf", dst_factor * aspect_factor.w);
  s [8] = EOS;
  strcpy (get_str (infmeta, MFACTORX), s);
  sprintf (s, "%lf", dst_factor * aspect_factor.h);
  s [8] = EOS;
  strcpy (get_str (infmeta, MFACTORX), s);

  sprintf (get_str (infmeta, MVDICALL), "%8ld", meta_inf->vdi_calls);

  window = search_window (CLASS_DIALOG, SRCH_ANY, INFMETA);

  if (window == NULL)
  {
    form_center (infmeta, &ret, &ret, &ret, &ret);
    window = crt_dialog (infmeta, NULL, INFMETA, FREETXT (FMETAINF), WI_MODAL);
  } /* if */

  if (window != NULL)
    if (! open_dialog (INFMETA))
    {
      delete_window (window);
      infmeta->ob_spec = (dlg_colors < 16) ? 0x00021100L : 0x00011170L | sys_colors [COLOR_DIALOG];
      hndl_dial (infmeta, 0, FALSE, TRUE, NULL, &ok);
      infmeta->ob_spec = (dlg_colors < 16) ? 0x00001100L : 0x00001170L | sys_colors [COLOR_DIALOG];
    } /* if, if */
} /* meta_info */

/*****************************************************************************/

LOCAL UWORD flip_word (w)
UWORD w;

{
  return ((w << 8) | (w >> 8));
} /* flip_word */

/*****************************************************************************/

LOCAL BOOLEAN read_meta (meta_inf)
META_INF *meta_inf;

{
  FHANDLE f;
  BOOLEAN ok;
  LONG    max_buffer;

  busy_mouse ();

  ok = FALSE;
  f  = file_open (meta_inf->filename, O_RDONLY);

  if (f < 0)                          /* Datei nicht gefunden */
    file_error (ERR_FILEOPEN, meta_inf->filename);
  else
  {
    meta_inf->fsize = file_seek (f, 0L, SEEK_END) / 2;
    max_buffer = META_BUF;
#if M68000
    max_buffer = meta_inf->fsize;
#endif
    meta_inf->buflen = max_buffer;
    meta_inf->buffer = (UWORD *)mem_alloc (max_buffer * 2);

    if (meta_inf->buffer == NULL)
    {
      meta_inf->buflen = max_buffer = MIN_BUFFER;
      meta_inf->buffer = help_buffer;
    } /* if */

    file_seek (f, 0L, SEEK_SET); /* Nur Kopf einlesen */
    max_buffer = file_read (f, (LONG)sizeof (META_HEADER), meta_inf->buffer);

#if M68000
    {
      REG LONG i;

      for (i = 0; i < max_buffer / 2; i++) meta_inf->buffer [i] = flip_word (meta_inf->buffer [i]);
    } /* #if */
#endif

    mem_move (&meta_inf->header, meta_inf->buffer, (UWORD)max_buffer);
    meta_inf->f     = f;
    meta_inf->first = TRUE;

    OlgaLink (meta_inf->filename, 0);
    file_split (meta_inf->filename, &meta_inf->drive, meta_inf->path, NULL, NULL);


    ok = TRUE;
  } /* if */

  arrow_mouse ();

  return (ok);
} /* read_meta */

/*****************************************************************************/

LOCAL WORD fetch_word ()

{
  if (meta_index == meta_buflen) /* Puffer fÅllen */
  {
    meta_index = 0;
    if (file_read (meta_f, 2L * meta_buflen, meta_buffer) == 0) return (-1);
  } /* if */

#if M68000
  return (flip_word (meta_buffer [meta_index++]));
#else
  return (meta_buffer [meta_index++]);
#endif
} /* fetch_word */

/*****************************************************************************/

LOCAL BOOLEAN get_code ()

{
  WORD i;
  WORD n_pts, n_int;

  contrl [0] = fetch_word ();
  if (contrl [0] == -1) return (FALSE);

  contrl [1] = fetch_word ();
  contrl [3] = fetch_word ();
  contrl [5] = fetch_word ();
  contrl [6] = out_handle;

  n_pts = contrl [1] * 2;
  n_int = contrl [3];

  for (i = 0; i < n_pts; i++) ptsin [i] = fetch_word ();
  for (i = 0; i < n_int; i++) intin [i] = fetch_word ();

  return (TRUE);
} /* get_code */

/*****************************************************************************/

LOCAL WORD new_width (width)
WORD width;

{
  width = width * dst_factor * aspect_factor.w;
  if (width == 0) width = 1;

  return (width);
} /* new_width */

/*****************************************************************************/

LOCAL WORD new_height (height)
WORD height;

{
  height = height * dst_factor * aspect_factor.h;
  if (height == 0) height = 1;

  return (height);
} /* new_height */

/*****************************************************************************/

LOCAL VOID transform ()

{
  REG WORD    px, py;
  REG WORD    i, x, y;
      WORD    ix, iy;
      WORD    gdp, n;
      BOOLEAN special;

  for (i = 0; i < contrl [1]; i++)
  {
    ix = 2 * i;
    iy = ix + 1;
    px = ptsin [ix];
    py = ptsin [iy];

    if (contrl [0] == V_GDP)
    {
      gdp = contrl [5];
      n   = -1;

      switch (gdp)
      {
        case V_ARC       :
        case V_PIESLICE  : n = 3;  break;
        case V_CIRCLE    : n = 2;  break;
        case V_ELLIPSE   :
        case V_ELLARC    :
        case V_ELLPIE    :
        case V_JUSTIFIED : n = 1;  break;
        case V_BAR       :
        case V_RBOX      :
        case V_RFBOX     : n = -1; break;
      } /* switch */

      special = (i == n); /* Radius, LÑnge */
    } /* if */
    else
    {
      gdp = 0;
      special = FALSE;
    } /* else */

    if (special)
    {
      switch (gdp)
      {
        case V_ARC       :
        case V_PIESLICE  :
        case V_CIRCLE    : px = px * dst.w / src.w; /* Radius */
                           break;
        case V_ELLIPSE   :  /* Transformiere x- und y-Radius */
        case V_ELLARC    :
        case V_ELLPIE    : px = px * dst.w / src.w;
                           py = py * dst.h / src.h;
                           break;
        case V_JUSTIFIED : px = px * dst.w / src.w; /* LÑnge */
                           break;
      } /* switch */
    } /* if */
    else /* Bildschirmpunkte */
    {
      px -= origo.x;
      py -= origo.y;

      x = px * dst.w / src.w;
      y = py * dst.h / src.h;

      if (flip_x)
        px = dst.x + dst.w - x;
      else
        px = dst.x + x;

      if (flip_y)
        py = dst.y + dst.h - y;
      else
        py = dst.y + y;

      if (! best_fit)
      {
        px -= doc.x;
        py -= doc.y;
      } /* if */
    } /* else */

    ptsin [ix] = px;
    ptsin [iy] = py;
  } /* for */
} /* transform */

/*****************************************************************************/

LOCAL VOID get_header_info (window)
WINDOWP window;

{
  META_INF    *meta_inf;
  META_HEADER *meta_header;
  DOUBLE      x_factor, y_factor;
  LRECT       tmp_dst;

  meta_inf        = (META_INF *)window->special;
  meta_header     = &meta_inf->header;
  best_fit        = meta_inf->best_fit;
  src_pixel.w     = meta_inf->dst_pixel.w;
  src_pixel.h     = meta_inf->dst_pixel.h;
  aspect_factor.w = 1.0;
  aspect_factor.h = 1.0;
  dst_factor      = 1.0;
  x_factor        = 1.0;
  y_factor        = 1.0;
  origo.x         = 0;
  origo.y         = 0;

  src.x = 0;
  src.y = 0;
  src.w = 32768L;
  src.h = 32768L;

  dst.x = window->scroll.x;
  dst.y = window->scroll.y;
  dst.w = window->scroll.w;
  dst.h = window->scroll.h;

  if (meta_header->ll_x != 0 ||
      meta_header->ll_y != 0 ||
      meta_header->ur_x != 0 ||
      meta_header->ur_y != 0)
  {
    src.x = min (meta_header->ll_x, meta_header->ur_x);
    src.y = min (meta_header->ll_y, meta_header->ur_y);
    src.w = labs ((LONG)meta_header->ur_x - (LONG)meta_header->ll_x) + 1;
    src.h = labs ((LONG)meta_header->ur_y - (LONG)meta_header->ll_y) + 1;

    if (meta_header->pwidth != 0 || /* page width/height */
        meta_header->pheight != 0)
    {
      src_pixel.w = (DOUBLE)meta_header->pwidth  * 100L / src.w;
      src_pixel.h = (DOUBLE)meta_header->pheight * 100L / src.h;

      aspect_factor.w = src_pixel.w / meta_inf->dst_pixel.w;
      aspect_factor.h = src_pixel.h / meta_inf->dst_pixel.h;
    } /* if */

    meta_header->transform = (meta_header->ll_y > 0) ? RC : NDC;

    origo.x = meta_header->ll_x;

    if (meta_header->transform == NDC)
      origo.y = -meta_header->ll_y;
    else
      origo.y = meta_header->ur_y;
  } /* if */

  if (meta_header->pwidth != 0 || /* page width/height */
      meta_header->pheight != 0)
  {
    tmp_dst.w = meta_header->pwidth  * 100L / meta_inf->dst_pixel.w;
    tmp_dst.h = meta_header->pheight * 100L / meta_inf->dst_pixel.h;

    if (best_fit)
    {
      x_factor = (DOUBLE)dst.w / tmp_dst.w;
      y_factor = (DOUBLE)dst.h / tmp_dst.h;

      dst_factor = min (x_factor, y_factor);

      window->doc.w = 0;
      window->doc.h = 0;

      meta_inf->pic_w = window->doc.w;
      meta_inf->pic_h = window->doc.h;
    } /* if */
    else
    {
      dst.w = tmp_dst.w;
      dst.h = tmp_dst.h;

      doc.x = window->doc.x;
      doc.y = window->doc.y;

      window->doc.w = meta_inf->pic_w = dst.w;
      window->doc.h = meta_inf->pic_h = dst.h;
    } /* else */
  } /* if, if */

  flip_x = FALSE;
  flip_y = meta_header->transform != RC;
} /* get_header_info */

/*****************************************************************************/

LOCAL VOID do_command (device)
WORD device;

{
  WORD  esc;
  ULONG ul;
  RECT  r;

  esc = 0;

  if (contrl [0] == V_ESC) /* Bit-Images nicht direkt auf Bildschirm */
  {
    esc = contrl [5];

    if ((esc == V_BIT_IMAGE) && (device == SCREEN)) esc = -1;
  } /* if */

  switch (contrl [0])
  {
    case V_ESC         :
    case V_PLINE       :
    case V_PMARKER     :
    case V_GTEXT       :
    case V_FTEXT       :
    case V_FILLAREA    :
    case V_GDP         :
    case VR_RECFL      : transform ();
                         break;

    case VST_ARBPT32   :
    case VST_SETSIZE32 : ul = intin [0] * 65536L + intin [1];
                         ul = ul * dst_factor;
                         if (ul == 0) ul = 1;

                         intin [0] = ul >> 16;
                         intin [1] = ul &= 0xFFFF;

                         break;
    case VSL_WIDTH     : ptsin [0] = new_width (ptsin [0]);
                         break;
    case VST_HEIGHT    :
    case VSM_HEIGHT    :
    case V_TOPBOT      : ptsin [1] = new_height (ptsin [1]);
                         break;
    case VST_POINT     : if ((device == SCREEN) && best_fit) /* vst_height benutzen */
                         {
#if GEMDOS | MSDOS | OS2 /* FLEXOS kennt den direkten vdi-Aufruf nicht */
                           vdi (); /* vst_point direkt aufrufen */
#endif

                           contrl [0] = VST_HEIGHT;
                           contrl [1] = 1;
                           contrl [3] = 0;

                           ptsin [0] = 0;
                           ptsin [1] = dst_factor * ptsout [1];
                           if (ptsin [1] == 0) ptsin [1] = 1;
                         } /* if */
                         else
                           intin [0] = dst_factor * intin [0];
                         break;
    case V_CLRWK       : esc = -1;
                         break;
    case VS_CLIP       : transform ();
                         if (device == SCREEN)
                         {
                           array2rect (ptsin, &r);
                           if (rc_intersect (&clip, &r))
                             rect2array (&r, ptsin);		/* Clipping auf Fensterinneres */
                           else
                           {
                             ptsin [0] = ptsin [2] = clip.x;	/* Clipping unendlich klein */
                             ptsin [1] = ptsin [3] = clip.y;
                           } /* else */
                         } /* if */
                         break;
  } /* switch */

#if GEMDOS | MSDOS | OS2 /* FLEXOS kennt den direkten vdi-Aufruf nicht */
  if (esc >= 0) vdi ();
#endif
} /* do_command */

/*****************************************************************************/

LOCAL VOID show_meta (window)
WINDOWP window;

{
  LONG     command;
  META_INF *meta_inf;
  STRING   act_path;
  WORD     act_drive;

  get_header_info (window);
  get_path (act_path);
  act_drive = get_drive ();

  meta_inf    = (META_INF *)window->special;
  meta_f      = meta_inf->f;
  meta_index  = meta_inf->header.headlen;
  meta_buflen = meta_inf->buflen;
  meta_buffer = meta_inf->buffer;

  if ((meta_inf->fsize > meta_inf->buflen) || (meta_inf->first))
  {
    meta_inf->first = FALSE;
    file_seek (meta_f, 0L, SEEK_SET);
    meta_buflen = file_read (meta_f, 2L * meta_buflen, meta_buffer) / 2;
  } /* if */

  command = 0;
  set_drive (meta_inf->drive);
  set_path (meta_inf->path);

  while (get_code ())
  {
    command++;
    do_command (meta_inf->device);
  } /* while */

  meta_inf->vdi_calls = command;
  v_updwk (out_handle);
  set_drive (act_drive);
  set_path (act_path);
} /* show_meta */

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
  META_INF *meta_inf;

  meta_inf = (META_INF *)window->special;
  file_close (meta_inf->f);
  OlgaUnlink (meta_inf->filename, 0);
  mem_free (meta_inf->buffer);
  mem_free (meta_inf);
  set_meminfo ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
/*  if (is_top (window)) set_clip (TRUE, &window->scroll);*/
  clr_scroll (window);
  out_handle = vdi_handle;
  show_meta (window);
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
  RECT     r, diff;
  WORD     wbox, hbox;
  LONG     max_xdoc, max_ydoc;
  LONG     doc_w, doc_h;
  META_INF *meta_inf;

  meta_inf = (META_INF *)window->special;

  wind_get (window->handle, WF_CXYWH, &r.x, &r.y, &r.w, &r.h);

  wbox   = window->xfac;
  hbox   = window->yfac;
  diff.x = (new->x - r.x) & 0xFFF8;             /* Differenz berechnen */
  diff.y = (new->y - r.y) & 0xFFFE;
  diff.w = (new->w - r.w);
  diff.h = (new->h - r.h);

  new->x = r.x + diff.x;                        /* Schnelle Position */
  new->y = r.y + diff.y;                        /* Y immer gerade */

  if (mode & SIZED)
  {
    if (! meta_inf->best_fit)
    {
      doc_w = window->scroll.w + diff.w; /* Fenster darf nicht grîûer... */
      if (doc_w > meta_inf->pic_w) new->w -= doc_w - meta_inf->pic_w;

      doc_h = window->scroll.h + diff.h; /* ...als das Bild werden */
      if (doc_h > meta_inf->pic_h) new->h -= doc_h - meta_inf->pic_h;
    } /* if */

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

    if (meta_inf->best_fit)
      set_redraw (window, &window->scroll);
  } /* if */
} /* wi_snap */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD     item;
  WORD     old_best_fit;
  FULLNAME szExt;
  META_INF *meta_inf;

  meta_inf = (META_INF *)window->special;

  if (sel_window != window) unclick_window (sel_window); /* Deselektieren */

  if (mk->breturn == 2)	/* Doppelklick startet OlgaServer */
  {
    strcpy (szExt, ".");
    file_split (meta_inf->filename, NULL, NULL, NULL, &szExt [1]);

    OlgaStartExt (szExt, meta_inf->filename);

    return;
  } /* if */

  old_best_fit = meta_inf->best_fit;

  menu_icheck (popups, MFULL, ! meta_inf->best_fit);
  menu_icheck (popups, MBESTFIT, meta_inf->best_fit);

  item = popup_menu (popups, METAINFO, 0, 0, MINF, TRUE, mk->momask);

  switch (item)
  {
    case MINF     : meta_info (window); break;
    case MFULL    :
    case MBESTFIT : meta_inf->best_fit = item == MBESTFIT;
                    if (old_best_fit != meta_inf->best_fit)
                    {
                      get_header_info (window);
                      window->doc.x = 0;
                      window->doc.y = 0;
                      set_sliders (window, HORIZONTAL + VERTICAL, SLPOS + SLSIZE);
                      redraw_window (window, &window->scroll);
                    } /* if */
                    break;
  } /* switch */
} /* wi_click */

/*****************************************************************************/

LOCAL VOID wi_unclick (window)
WINDOWP window;

{
} /* wi_unclick */

/*****************************************************************************/
/* Taste fÅr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOLEAN wi_key (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if (mk->ascii_code == ESC)
  {
    set_redraw (window, &window->scroll);
    return (TRUE);
  } /* if */

  return (FALSE);
} /* wi_key */

/*****************************************************************************/

/* [GS] 5.1d Start */
LOCAL BOOLEAN wi_message (WINDOWP window, WORD *msg, MKINFO *mk)
/* Ende; alt:
LOCAL BOOLEAN wi_message (WINDOWP window, WORD *msg)
*/
{
  BYTE     *pFilename;
  META_INF *meta_inf;

  if (msg [0] == OLGA_UPDATED)
  {
    if (olga_apid >= 0)		/* search for objects with corresponding filename */
    {
      pFilename = (BYTE *)*(LONG *)(msg + 3);
      meta_inf = (META_INF *)window->special;

      if (strcmp (pFilename, meta_inf->filename) == 0)
      {
        file_close (meta_inf->f);
        OlgaUnlink (meta_inf->filename, 0);
        mem_free (meta_inf->buffer);
        read_meta (meta_inf);	/* does OlgaLink again */
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

GLOBAL WINDOWP crt_meta (obj, menu, icon, filename)
OBJECT *obj, *menu;
WORD   icon;
BYTE   *filename;

{
  WINDOWP  window;
  WORD     menu_height, inx;
  FULLNAME s;
  META_INF *meta_inf;

  meta_inf = (META_INF *)mem_alloc ((LONG)sizeof (META_INF));
  if (meta_inf == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL); /* zuwenig Speicher */
  } /* if */

  mem_set (meta_inf, 0, sizeof (META_INF));
  strcpy (meta_inf->filename, filename);
  meta_inf->device   = SCREEN;
  meta_inf->best_fit = TRUE;

  if (! read_meta (meta_inf))
  {
    mem_free (meta_inf);
    return (NULL);
  } /* if */

  inx    = num_windows (CLASS_META, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_META);

  if (window != NULL)
  {
    menu_height = (menu != NULL) ? gl_hattr : 0;

    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = 0;
    window->doc.h     = 0;
    window->xfac      = XFAC;
    window->yfac      = YFAC;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->scroll.x  = INITX + inx * gl_wbox;
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
    window->special   = (LONG)meta_inf;
    window->object    = obj;
    window->menu      = menu;
    window->hndl_menu = NULL;
    window->updt_menu = NULL;
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
    window->unclick   = wi_unclick;
    window->key       = wi_key;
    window->timer     = NULL;
    window->message   = wi_message;
    window->top       = NULL;
    window->untop     = NULL;
    window->edit      = NULL;
    window->showinfo  = info_meta;
    window->showhelp  = help_meta;

    get_screen_info (meta_inf, vdi_handle);
    get_header_info (window);

    if ((strchr (filename, DRIVESEP) == NULL) && (strchr (filename, PATHSEP) == NULL))
      strcpy (s, act_path);
    else
      s [0] = EOS;

    strcat (s, filename);
    sprintf (window->name, " %s ", s);

    if (meta_inf->header.bit_image == 1) /* Metadatei enthÑlt Bit-Image */
    {
      inx = strlen (filename);
      while ((filename [inx] != SUFFSEP) && (inx > 0)) inx--;
      filename [inx] = EOS;
      strcat (filename, ".IMG");
      open_image (icon, filename);
    } /* if */
  } /* if */
  else
  {
    file_close (meta_inf->f);
    mem_free (meta_inf->buffer);
    mem_free (meta_inf);
  } /* else */

  set_meminfo ();
  return (window);                      /* Fenster zurÅckgeben */
} /* crt_meta */

/*****************************************************************************/
/* ôffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_meta (icon, filename)
WORD icon;
BYTE *filename;

{
  BOOLEAN  ok;
  WINDOWP  window;
  META_INF *meta_inf;

  if ((icon != NIL) && (window = search_window (CLASS_META, SRCH_OPENED, icon)) != NULL)
  {
    ok = TRUE;
    top_window (window);
  } /* if */
  else
  {
    if ((window = search_window (CLASS_META, SRCH_CLOSED, icon)) == NULL)
      window = crt_meta (NULL, NULL, icon, filename);

    ok = window != NULL;

    if (ok)
    {
      meta_inf = (META_INF *)window->special;
      if (meta_inf->header.bit_image == 1)
        delete_window (window);
      else
        ok = open_window (window);
    } /* if */
  } /* else */

  return (ok);
} /* open_meta */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_meta (window, icon)
WINDOWP window;
WORD    icon;

{
  meta_info (window);
  return (TRUE);
} /* info_meta */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_meta (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HMETA));
} /* help_meta */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_meta ()

{
  return (TRUE);
} /* init_meta */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_meta ()

{
  return (TRUE);
} /* term_meta */


/*****************************************************************************
 *
 * Module : GEMOBJ.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 26.03.97
 *
 *
 * Description: This module implements the metafile object.
 *
 * History:
 * 26.03.97: Handling of V_FTEXT, VST_ARBPT32, VST_SETSIZE32 added
 * 10.03.97: GEM_UPDATE added
 * 07.03.97: Call to OlgaLink added 
 * 01.07.89: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include <olga.h>
#include "global.h"
#include "windows.h"

#include "utility.h"
#include "files.h"

#include "export.h"
#include "gemobj.h"

/****** DEFINES **************************************************************/

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

#define MIN_WBUFFER         256 /* minimum buffer size in words (at least sizeof (META_HEADER) / 2 */
#define MIN_BBUFFER         (2 * MIN_WBUFFER)


/****** TYPES ****************************************************************/

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

/****** VARIABLES ************************************************************/

LOCAL FHANDLE meta_f;
LOCAL LONG    meta_index;
LOCAL LONG    meta_buflen;
LOCAL UWORD   *meta_buffer;
LOCAL UWORD   help_buffer [MIN_WBUFFER];
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

LOCAL WORD    gem_init        _((GEMOBJP gem, WORD mode, VOID *p));
LOCAL WORD    gem_exit        _((GEMOBJP gem));
LOCAL WORD    gem_update      _((GEMOBJP gem));
LOCAL WORD    gem_clear       _((GEMOBJP gem));
LOCAL WORD    gem_draw        _((GEMOBJP gem));
LOCAL WORD    gem_showcurs    _((GEMOBJP gem));
LOCAL WORD    gem_hidecurs    _((GEMOBJP gem));
LOCAL WORD    gem_key         _((GEMOBJP gem));
LOCAL WORD    gem_click       _((GEMOBJP gem));
LOCAL WORD    gem_print       _((GEMOBJP gem, WORD mode, VOID *p));

LOCAL VOID    draw_curs       _((GEMOBJP gem));
LOCAL WORD    print_gem       _((BYTE *filename));
LOCAL VOID    get_screen_info _((GEMOBJP gem));
LOCAL UWORD   flip_word       _((UWORD w));
LOCAL WORD    get_meta        _((GEMOBJP gem));
LOCAL WORD    fetch_word      _((GEMOBJP gem));
LOCAL BOOLEAN get_code        _((GEMOBJP gem));
LOCAL WORD    new_width       _((WORD width));
LOCAL WORD    new_height      _((WORD height));
LOCAL VOID    transform       _((VOID));
LOCAL VOID    get_header_info _((GEMOBJP gem));
LOCAL VOID    do_command      _((WORD device));
LOCAL VOID    show_meta       _((GEMOBJP gem));

#if GEMDOS | MSDOS | OS2 /* FLEXOS kennt den direkten vdi-Aufruf nicht */
EXTERN VOID   vdi             _((VOID));
#endif

/*****************************************************************************/

GLOBAL WORD gem_obj (gemobj, message, wparam, p)
GEMOBJP gemobj;
WORD   message;
WORD   wparam;
VOID   *p;

{
  WORD ret;

  ret = GEM_WRONGMESSAGE;

  switch (message)
  {
    case GEM_INIT       : ret = gem_init (gemobj, wparam, p);  break;
    case GEM_EXIT       : ret = gem_exit (gemobj);             break;
    case GEM_UPDATE     : ret = gem_update (gemobj);           break;
    case GEM_CLEAR      : ret = gem_clear (gemobj);            break;
    case GEM_DRAW       : ret = gem_draw (gemobj);             break;
    case GEM_SHOWCURSOR : ret = gem_showcurs (gemobj);         break;
    case GEM_HIDECURSOR : ret = gem_hidecurs (gemobj);         break;
    case GEM_KEY        : ret = gem_key (gemobj);              break;
    case GEM_CLICK      : ret = gem_click (gemobj);            break;
    case GEM_PRINT      : ret = gem_print (gemobj, wparam, p); break;
  } /* switch */

  return (ret);
} /* gem_obj */

/*****************************************************************************/

LOCAL WORD gem_init (gem, mode, p)
GEMOBJP gem;
WORD    mode;
VOID    *p;

{
  WORD err;

  if (p == NULL) return (GEM_GENERAL);

  gem->doc.x       = 0;
  gem->doc.y       = 0;
  gem->doc.w       = 0;
  gem->doc.h       = 0;
  gem->curs_hidden = TRUE;
  gem->ext_buffer  = NULL;
  gem->device      = SCREEN;
  gem->best_fit    = mode & GEM_BESTFIT;
  gem->flags       = mode;

  strcpy (gem->filename, "");

  if (mode & GEM_FILE)
    strcpy (gem->filename, p);
  else
    gem->ext_buffer = p;

  err = get_meta (gem);

  return (err);
} /* gem_init */

/*****************************************************************************/

LOCAL WORD gem_exit (gem)
GEMOBJP gem;

{
  if (gem->allocated) mem_free ((VOID *)gem->buffer);

  if (gem->flags & GEM_FILE)
  {
    file_close (gem->f);
    OlgaUnlink (gem->filename, 0);
  } /* if */

  return (GEM_OK);
} /* gem_exit */

/*****************************************************************************/

LOCAL WORD gem_update (gem)
GEMOBJP gem;

{
  gem_exit (gem);

  return (get_meta (gem));
} /* gem_exit */

/*****************************************************************************/

LOCAL WORD gem_clear (gem)
GEMOBJP gem;

{
  WORD flags;

  flags = (gem->flags & GEM_BESTFIT) | GEM_FILE;

  gem_exit (gem);
  gem_init (gem, flags, "");

  return (GEM_OK);
} /* gem_clear */

/*****************************************************************************/

LOCAL WORD gem_draw (gem)
GEMOBJP gem;

{
  RECT    r, old_clip;
  WINDOWP window;

  window = gem->window;

  r.x = gem->pos.x - window->doc.x * window->xfac + window->scroll.x;
  r.y = gem->pos.y - window->doc.y * window->yfac + window->scroll.y;
  r.w = gem->pos.w;
  r.h = gem->pos.h;

  if (rc_intersect (&clip, &r))
  {
    old_clip = clip;
    set_clip (TRUE, &r);
    clr_area (&r);
    show_meta (gem);
    set_clip (TRUE, &old_clip);
  } /* if */

  return (GEM_OK);
} /* gem_draw */

/*****************************************************************************/

LOCAL WORD gem_showcurs (gem)
GEMOBJP gem;

{
  draw_curs (gem);

  return (GEM_OK);
} /* gem_showcurs */

/*****************************************************************************/

LOCAL WORD gem_hidecurs (gem)
GEMOBJP gem;

{
  if (gem->curs_hidden) return (GEM_OK);

  draw_curs (gem);
  gem->curs_hidden = TRUE;

  return (GEM_OK);
} /* gem_hidecurs */

/*****************************************************************************/

LOCAL WORD gem_key (gem)
GEMOBJP gem;

{
  return (GEM_CHARNOTUSED);
} /* gem_key */

/*****************************************************************************/

LOCAL WORD gem_click (gem)
GEMOBJP gem;

{
  return (GEM_OK);
} /* gem_click */

/*****************************************************************************/

LOCAL WORD gem_print (gem, mode, p)
GEMOBJP gem;
WORD    mode;
VOID    *p;

{
  if (mode == GEM_FILE) return (print_gem (p));

  return (GEM_OK);
} /* gem_print */

/*****************************************************************************/

LOCAL VOID draw_curs (gem)
GEMOBJP gem;

{
  WORD    xy [10];
  WORD    x, y;
  WINDOWP window;

  hide_mouse ();
  window = gem->window;

  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_XOR);
  vsl_udsty (vdi_handle, 0x5555);
  vsl_type (vdi_handle, USERLINE);

  x = gem->pos.x - window->doc.x * window->xfac + window->scroll.x;
  y = gem->pos.y - window->doc.y * window->yfac + window->scroll.y;

  xy [0] = x;
  xy [1] = y;
  xy [2] = x + gem->pos.w - 1;
  xy [3] = y;
  xy [4] = xy [2];
  xy [5] = y + gem->pos.h - 1;
  xy [6] = x;
  xy [7] = xy [5];
  xy [8] = x;
  xy [9] = y;

  v_pline (vdi_handle, 5, xy);

  show_mouse ();
} /* draw_curs */

/*****************************************************************************/

LOCAL WORD print_gem (filename)
BYTE *filename;

{
  GEMOBJ  gem;
  DEVINFO dev_info;

  mem_set (&gem, 0, sizeof (GEMOBJ));
  strcpy (gem.filename, filename);
  gem.buffer      = NULL;
  gem.ext_buffer  = NULL;
  gem.device      = PRINTER;
  gem.best_fit    = TRUE;

  if (get_meta (&gem) == GEM_OK)
  {
    gem.out_handle = open_work (PRINTER, &dev_info);

    if (gem.out_handle > 0)
    {
      busy_mouse ();
      vst_load_fonts (gem.out_handle, 0);

      gem.out_device.x = 0;
      gem.out_device.y = 0;
      gem.out_device.w = dev_info.dev_w;
      gem.out_device.h = dev_info.dev_h;
      gem.dst_pixel.w  = dev_info.pix_w;
      gem.dst_pixel.h  = dev_info.pix_h;

      gem.pos.x = gem.out_device.x;
      gem.pos.y = gem.out_device.y;
      gem.pos.w = gem.out_device.w;
      gem.pos.h = gem.out_device.h;

      show_meta (&gem);
      v_updwk (gem.out_handle);
      vst_unload_fonts (gem.out_handle, 0);
      close_work (PRINTER, gem.out_handle);
      if (gem.allocated) mem_free (gem.buffer);
      arrow_mouse ();
    } /* if */
  } /* if */

  return (GEM_OK);
} /* print_gem */

/*****************************************************************************/

LOCAL VOID get_screen_info (gem)
GEMOBJP gem;

{
  WORD work_out [57];
  WORD point;
  WORD char_w, char_h, cell_w, cell_h;
  WORD minADE, maxADE, width;
  WORD distances [5], effects [3];
  LONG pix_w, pix_h;

  vq_extnd (vdi_handle, FALSE, work_out);

  gem->out_device.x = 0;
  gem->out_device.y = 0;
  gem->out_device.w = work_out [0] + 1L;
  gem->out_device.h = work_out [1] + 1L;

  gem->dst_pixel.w = work_out [3];
  gem->dst_pixel.h = work_out [4];

  vst_font (vdi_handle, FONT_SWISS);
  point = vst_point (vdi_handle, 99, &char_w, &char_h, &cell_w, &cell_h);
  vqt_font_info (vdi_handle, &minADE, &maxADE, distances, &width, effects);

  char_h = distances [1] + distances [3] + 1;
  pix_h  = point * 25400L / 72 / char_h;
  pix_w  = pix_h * gem->dst_pixel.w / gem->dst_pixel.h;

  gem->dst_pixel.w = pix_w;
  gem->dst_pixel.h = pix_h;

  vst_font (vdi_handle, FONT_SYSTEM);
} /* get_screen_info */

/*****************************************************************************/

LOCAL UWORD flip_word (w)
UWORD w;

{
  return ((w << 8) | (w >> 8));
} /* flip_word */

/*****************************************************************************/

LOCAL WORD get_meta (gem)
GEMOBJP gem;

{
  BOOLEAN dynamic;
  LONG    max_buffer;

  busy_mouse ();

  dynamic = (gem->flags & GEM_FILE);

  if (dynamic)
  {
    gem->fsize = file_length (gem->filename);
    gem->f     = file_open (gem->filename, O_RDONLY);
    if (gem->f < 0) return (GEM_FILENOTFOUND);
  } /* if */

  if (gem->flags & GEM_FILE) OlgaLink (gem->filename, 0);

  max_buffer  = MIN_BBUFFER;
  gem->buffer = NULL;

#if M68000
  if (dynamic)                  /* 68000 has enough memory */
  {
    max_buffer   = gem->fsize;
    gem->bufsize = max_buffer;
    gem->buffer  = (UWORD *)mem_alloc (max_buffer);
  } /* if */
#endif

  gem->allocated = gem->buffer != NULL;

  if (! gem->allocated)         /* take local buffer */
  {
    gem->bufsize = MIN_BBUFFER;
    gem->buffer  = help_buffer;
  } /* if */

  max_buffer = sizeof (META_HEADER);

  if (gem->flags & GEM_FILE)
    max_buffer = file_read (gem->f, max_buffer, gem->buffer);
  else
    mem_move (gem->buffer, gem->ext_buffer, (UWORD)max_buffer);

#if M68000
  {
    REG LONG i;

    for (i = 0; i < max_buffer / 2; i++) gem->buffer [i] = flip_word (gem->buffer [i]);
  } /* if */
#endif

  gem->header = *(META_HEADER *)gem->buffer;
  gem->first  = TRUE;

  get_screen_info (gem);
  get_header_info (gem);

  if (gem->header.bit_image == 1)       /* metafile contains bit image */
  {
    /*open_image (filename);*/
  } /* if */

  arrow_mouse ();

  return (GEM_OK);
} /* get_meta */

/*****************************************************************************/

LOCAL WORD fetch_word (gem)
GEMOBJP gem;

{
  LONG size;

  if (meta_index == meta_buflen)        /* fill buffer */
  {
    meta_index = 0;

    if (gem->flags & GEM_FILE)
    {
      if (file_read (meta_f, 2 * meta_buflen, meta_buffer) == 0) return (-1);
    } /* if */
    else
    {
      size = min (2 * meta_buflen, gem->fsize - gem->ext_bufp);
      if (size <= 0) return (-1);
      mem_move (meta_buffer, gem->ext_buffer + gem->ext_bufp, (UWORD)size);
      gem->ext_bufp += size;
    } /* else */
  } /* if */

#if M68000
  return (flip_word (meta_buffer [meta_index++]));
#else
  return (meta_buffer [meta_index++]);
#endif
} /* fetch_word */

/*****************************************************************************/

LOCAL BOOLEAN get_code (gem)
GEMOBJP gem;

{
  WORD i;
  WORD n_pts, n_int;

  contrl [0] = fetch_word (gem);
  if (contrl [0] == -1) return (FALSE);

  contrl [1] = fetch_word (gem);
  contrl [3] = fetch_word (gem);
  contrl [5] = fetch_word (gem);
  contrl [6] = gem->out_handle;

  n_pts = contrl [1] * 2;
  n_int = contrl [3];

  for (i = 0; i < n_pts; i++) ptsin [i] = fetch_word (gem);
  for (i = 0; i < n_int; i++) intin [i] = fetch_word (gem);

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

LOCAL VOID get_header_info (gem)
GEMOBJP gem;

{
  DOUBLE      x_factor, y_factor;
  LRECT       tmp_dst;
  WINDOWP     window;
  META_HEADER *meta_header;

  window          = gem->window;
  meta_header     = &gem->header;
  best_fit        = gem->best_fit;
  src_pixel.w     = gem->dst_pixel.w;
  src_pixel.h     = gem->dst_pixel.h;
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

  dst.x = gem->pos.x - window->doc.x * window->xfac + window->scroll.x;
  dst.y = gem->pos.y - window->doc.y * window->yfac + window->scroll.y;
  dst.w = gem->pos.w;
  dst.h = gem->pos.h;

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

      aspect_factor.w = src_pixel.w / gem->dst_pixel.w;
      aspect_factor.h = src_pixel.h / gem->dst_pixel.h;
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
    tmp_dst.w = meta_header->pwidth  * 100L / gem->dst_pixel.w;
    tmp_dst.h = meta_header->pheight * 100L / gem->dst_pixel.h;

    if (best_fit)
    {
      x_factor = (DOUBLE)dst.w / tmp_dst.w;
      y_factor = (DOUBLE)dst.h / tmp_dst.h;

      dst_factor = min (x_factor, y_factor);

      gem->pic_w = 0;
      gem->pic_h = 0;
    } /* if */
    else
    {
      dst.w = tmp_dst.w;
      dst.h = tmp_dst.h;

      doc.x = gem->doc.x;
      doc.y = gem->doc.y;

      gem->doc.w = gem->pic_w = dst.w;
      gem->doc.h = gem->pic_h = dst.h;
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

LOCAL VOID show_meta (gem)
GEMOBJP gem;

{
  LONG     command, size;
  LONGSTR  act_path, path;
  WORD     act_drive, drive;

  file_split (gem->filename, &drive, path, NULL, NULL);

  get_header_info (gem);
  get_path (act_path);
  act_drive = get_drive ();

  meta_f      = gem->f;
  meta_index  = gem->header.headlen;
  meta_buflen = gem->bufsize / 2;
  meta_buffer = gem->buffer;

  if ((gem->fsize > gem->bufsize) || (gem->first))
  {
    gem->first    = FALSE;
    gem->ext_bufp = 0;

    if (gem->flags & GEM_FILE)
    {
      file_seek (meta_f, 0L, SEEK_SET);
      meta_buflen = file_read (meta_f, 2 * meta_buflen, meta_buffer) / 2;
    } /* if */
    else
    {
      size = min (2 * meta_buflen, gem->fsize - gem->ext_bufp);
      if (size > 0)
      {
        mem_move (meta_buffer, gem->ext_buffer, (UWORD)size);
        gem->ext_bufp += size;
      } /* if */
    } /* else */
  } /* if */

  command = 0;
  set_drive (drive);
  set_path (path);

  while (get_code (gem))
  {
    command++;
    do_command (gem->device);
  } /* while */

  gem->vdi_calls = command;
  v_updwk (gem->out_handle);
  set_drive (act_drive);
  set_path (act_path);
} /* show_meta */


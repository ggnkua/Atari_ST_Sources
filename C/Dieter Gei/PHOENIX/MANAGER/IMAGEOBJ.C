/*****************************************************************************
 *
 * Module : IMAGEOBJ.C
 * Author : JÅrgen & Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 10.03.97
 *
 *
 * Description: This module implements the bit image object.
 *
 * History:
 * 10.03.97: IMG_UPDATE added
 * 06.03.97: Call to OlgaLink added 
 * 31.12.94: Using new function names of controls module
 * 31.10.93: New build_img routine used
 * 16.09.93: Struct IMG_HEADER removed
 * 13.09.93: Using correct width of a bit image
 * 01.07.89: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include <olga.h>
#include "global.h"
#include "windows.h"

#include "controls.h"
#include "utility.h"
#include "files.h"

#include "export.h"
#include "imageobj.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL WORD img_init       _((IMGOBJP img, WORD mode, VOID *p));
LOCAL WORD img_exit       _((IMGOBJP img));
LOCAL WORD img_update     _((IMGOBJP img));
LOCAL WORD img_clear      _((IMGOBJP img));
LOCAL WORD img_draw       _((IMGOBJP img));
LOCAL WORD img_showcurs   _((IMGOBJP img));
LOCAL WORD img_hidecurs   _((IMGOBJP img));
LOCAL WORD img_key        _((IMGOBJP img, MKINFO *mk));
LOCAL WORD img_click      _((IMGOBJP img));
LOCAL WORD img_print      _((IMGOBJP img, WORD mode, VOID *p));

LOCAL VOID draw_curs      _((IMGOBJP img));
LOCAL WORD print_image    _((BYTE *filename));
LOCAL VOID flip_word      _((HUPTR adr));
LOCAL WORD get_bit_image  _((IMGOBJP img));

#if GEMDOS
#if TURBO_C
#define v_bit_image do_bit_image
LOCAL VOID do_bit_image   _((WORD handle, BYTE *filename,
                             WORD aspect, WORD x_scale, WORD y_scale,
                             WORD h_align, WORD v_align, WORD *xy ));
#endif /* TURBO_C */
#endif /* GEMDOS */

/*****************************************************************************/

GLOBAL WORD image_obj (imgobj, message, wparam, p)
IMGOBJP imgobj;
WORD    message;
WORD    wparam;
VOID    *p;

{
  WORD ret;

  ret = IMG_WRONGMESSAGE;

  switch (message)
  {
    case IMG_INIT       : ret = img_init (imgobj, wparam, p);  break;
    case IMG_EXIT       : ret = img_exit (imgobj);             break;
    case IMG_UPDATE     : ret = img_update (imgobj);           break;
    case IMG_CLEAR      : ret = img_clear (imgobj);            break;
    case IMG_DRAW       : ret = img_draw (imgobj);             break;
    case IMG_SHOWCURSOR : ret = img_showcurs (imgobj);         break;
    case IMG_HIDECURSOR : ret = img_hidecurs (imgobj);         break;
    case IMG_KEY        : ret = img_key (imgobj, p);           break;
    case IMG_CLICK      : ret = img_click (imgobj);            break;
    case IMG_PRINT      : ret = img_print (imgobj, wparam, p); break;
  } /* switch */

  return (ret);
} /* image_obj */

/*****************************************************************************/

LOCAL WORD img_init (img, mode, p)
IMGOBJP img;
WORD    mode;
VOID    *p;

{
  WORD err;

  if (p == NULL) return (IMG_GENERAL);

  img->raster_buf   = NULL;
  img->bufsize      = 0;
  img->curs_hidden  = TRUE;
  img->width        = 0;
  img->height       = 0;
  img->planes       = 0;
  img->flags        = mode;
  img->filename [0] = EOS;

  if (mode == IMG_FILE)
    strcpy (img->filename, p);
  else
    img->buffer = p;

  err = get_bit_image (img);

  return (err);
} /* img_init */

/*****************************************************************************/

LOCAL WORD img_exit (img)
IMGOBJP img;

{
  if (img->raster_buf != NULL) mem_free ((VOID *)img->raster_buf);

  if (img->flags == IMG_FILE)
    if (img->filename [0] != EOS)
      OlgaUnlink (img->filename, 0);

  return (IMG_OK);
} /* img_exit */

/*****************************************************************************/

LOCAL WORD img_update (img)
IMGOBJP img;

{
  img_exit (img);

  return (get_bit_image (img));
} /* img_update */

/*****************************************************************************/

LOCAL WORD img_clear (img)
IMGOBJP img;

{
  img_exit (img);
  img_init (img, IMG_FILE, "");

  return (IMG_OK);
} /* img_clear */

/*****************************************************************************/

LOCAL WORD img_draw (img)
IMGOBJP img;

{
  MFDB    d;
  RECT    r, src, dst, pos;
  WORD    xy [8];
  WORD    index [2];
  WORD    w, h;
  WINDOWP window;

  window = img->window;

  src    = img->pos;
  src.x += window->scroll.x - window->doc.x * window->xfac;
  src.y += window->scroll.y - window->doc.y * window->yfac;
  dst    = src;
  pos    = src;

  r    = clip;
  r.x -= src.x; /* normalize clipping & image to left upper corner */
  r.y -= src.y;
  xywh2rect (0, 0, img->pos.w, img->pos.h, &src);

  rc_intersect (&r, &src);
  rc_intersect (&clip, &dst);

  w = min (img->s.fwp - src.x, src.w);
  w = max (w, 0);
  h = min (img->s.fh  - src.y, src.h);
  h = max (h, 0);

  xy [0] = src.x;
  xy [1] = src.y;
  xy [2] = xy [0] + w - 1;
  xy [3] = xy [1] + h - 1;
  xy [4] = dst.x;
  xy [5] = dst.y;
  xy [6] = xy [4] + w - 1;
  xy [7] = xy [5] + h - 1;

  index [0] = BLACK;
  index [1] = WHITE;

  d.mp = NULL; /* screen */

  if ((src.w > 0) && (src.h > 0) && (w > 0) && (h > 0))
    if (img->planes == 1)       /* draw monochrome picture */
      vrt_cpyfm (vdi_handle, MD_REPLACE, xy, &img->s, &d, index);
    else                        /* draw color picture */
      vro_cpyfm (vdi_handle, S_ONLY, xy, &img->s, &d);

  if (img->pos.w > img->width)  /* clear area not covered by picture */
  {
    r   = pos;
    r.x = xy [6] + 1;
    rc_intersect (&pos, &r);
    rc_intersect (&clip, &r);
    clr_area (&r);
  } /* if */

  if (img->pos.h > img->height)
  {
    r   = pos;
    r.y = xy [7] + 1;
    rc_intersect (&pos, &r);
    rc_intersect (&clip, &r);
    clr_area (&r);
  } /* if */

  return (IMG_OK);
} /* img_draw */

/*****************************************************************************/

LOCAL WORD img_showcurs (img)
IMGOBJP img;

{
  draw_curs (img);

  return (IMG_OK);
} /* img_showcurs */

/*****************************************************************************/

LOCAL WORD img_hidecurs (img)
IMGOBJP img;

{
  if (img->curs_hidden) return (IMG_OK);

  draw_curs (img);
  img->curs_hidden = TRUE;

  return (IMG_OK);
} /* img_hidecurs */

/*****************************************************************************/

LOCAL WORD img_key (img, mk)
IMGOBJP img;
MKINFO  *mk;

{
  if (mk->ascii_code == ESC)
  {
    img_clear (img);
    img_draw (img);

    return (IMG_BUFFERCHANGED);
  } /* if */
  else
    return (IMG_CHARNOTUSED);
} /* img_key */

/*****************************************************************************/

LOCAL WORD img_click (img)
IMGOBJP img;

{
  return (IMG_OK);
} /* img_click */

/*****************************************************************************/

LOCAL WORD img_print (img, mode, p)
IMGOBJP img;
WORD    mode;
VOID    *p;

{
  WORD     ret;
  LONG     size;
  FULLNAME filename;
  FHANDLE  f;

  if (mode == IMG_FILE) return (print_image (p));

  strcpy (filename, "TEMP.IMG");

  f = file_create (filename);

  if (f >= 0)
  {
    size = file_write (f, img->bufsize, img->buffer);
    file_close (f);

    if (size != img->bufsize)
    {
      file_remove (filename);
      return (IMG_GENERAL);
    } /* if */

    ret = print_image (filename);
    file_remove (filename);
  } /* if */
  else
    return (IMG_GENERAL);

  return (ret);
} /* img_print */

/*****************************************************************************/

LOCAL VOID draw_curs (img)
IMGOBJP img;

{
  WORD    xy [10];
  WORD    x, y;
  WINDOWP window;

  hide_mouse ();
  window = img->window;

  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_XOR);
  vsl_udsty (vdi_handle, 0x5555);
  vsl_type (vdi_handle, USERLINE);

  x = img->pos.x - window->doc.x * window->xfac + window->scroll.x;
  y = img->pos.y - window->doc.y * window->yfac + window->scroll.y;

  xy [0] = x;
  xy [1] = y;
  xy [2] = x + img->pos.w - 1;
  xy [3] = y;
  xy [4] = xy [2];
  xy [5] = y + img->pos.h - 1;
  xy [6] = x;
  xy [7] = xy [5];
  xy [8] = x;
  xy [9] = y;

  v_pline (vdi_handle, 5, xy);

  show_mouse ();
} /* draw_curs */

/*****************************************************************************/

LOCAL WORD print_image (filename)
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

  out_handle = open_work (PRINTER, &dev_info);

  if (out_handle > 0)
  {
    handle = file_open (filename, O_RDONLY);

    if (handle < 0) return (IMG_FILENOTFOUND);

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
    arrow_mouse ();
  } /* if */

  return (IMG_OK);
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

LOCAL WORD get_bit_image (img)
IMGOBJP img;

{
  FHANDLE    handle;
  IMG_HEADER *img_header;
  LONG       img_len;
  HUPTR      img_buffer;

  if (img->flags == IMG_FILE)
  {
    if (img->filename [0] == EOS) return (IMG_FILENOTFOUND);
    handle = file_open (img->filename, O_RDONLY);
    if (handle < 0) return (IMG_FILENOTFOUND);
  } /* if */

  busy_mouse ();

  if (img->flags == IMG_FILE)
  {
    img_len    = file_length (img->filename);
    img_buffer = (HUPTR)mem_alloc (img_len);

    if (img_buffer == NULL)
    {
      arrow_mouse ();
      return (IMG_NOMEMORY);
    } /* if */

    img_len = file_read (handle, img_len, (VOID FAR *)img_buffer); /* read data */
    file_close (handle);

    OlgaLink (img->filename, 0);
  } /* if */
  else
    img_buffer = (HUPTR)img->buffer;

  img_header      = (IMG_HEADER *)img_buffer;
  img->raster_buf = BuildImg (img_buffer, &img->width, &img->height, &img->planes);

  if (img->raster_buf == NULL)
  {
    if (img->flags == IMG_FILE) mem_free ((VOID *)img_buffer);
    arrow_mouse ();
    return (IMG_NOMEMORY);
  } /* if */
  else
  {
    img->s.mp  = img->raster_buf;
    img->s.fwp = img_header->sl_width;
    img->s.fh  = img_header->sl_height;
    img->s.fww = (img_header->sl_width + 15) / 16;
    img->s.np  = (img_header->planes == 1) ? 1 : planes;
  } /* else */

  if (img->flags == IMG_FILE) mem_free ((VOID *)img_buffer);

  arrow_mouse ();

  return (IMG_OK);
} /* get_bit_image */

/*****************************************************************************/

#if GEMDOS /* error in TURBO-C on ATARI ST, so use this vdi binding */
#if TURBO_C
EXTERN VOID vdi _((VOID));

LOCAL VOID do_bit_image (handle, filename, aspect, x_scale, y_scale, h_align, v_align, xy)
WORD handle, aspect, x_scale, y_scale, h_align, v_align;
WORD *xy;
BYTE *filename;

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


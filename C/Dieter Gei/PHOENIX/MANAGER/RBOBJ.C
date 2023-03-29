/*****************************************************************************
 *
 * Module : RBOBJ.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 14.12.90
 * Last modification: 16.08.95
 *
 *
 * Description: This module implements a radio button object
 *
 * History:
 * 16.08.95: Drawing 3d added
 * 14.12.90: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"
#include "controls.h"
#include "resource.h"

#include "export.h"
#include "rbobj.h"

/****** DEFINES **************************************************************/

#define RB_CNTRL(mk) ((mk->ascii_code == ESC        ) || \
                      (mk->ascii_code == SP         ) || \
                      (mk->scan_code  == UP         ) && (mk->ascii_code == 0) || \
                      (mk->scan_code  == DOWN       ) && (mk->ascii_code == 0) || \
                      (mk->scan_code  == POS1       ) && (mk->ascii_code == 0) || \
                      (mk->scan_code  == ENDKEY     ) && (mk->ascii_code == 0))

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL WORD rb_init     _((RBOBJP rb, MKINFO *mk));
LOCAL WORD rb_exit     _((RBOBJP rb));
LOCAL WORD rb_clear    _((RBOBJP rb));
LOCAL WORD rb_draw     _((RBOBJP rb));
LOCAL WORD rb_showcurs _((RBOBJP rb));
LOCAL WORD rb_hidecurs _((RBOBJP rb));
LOCAL WORD rb_key      _((RBOBJP rb, MKINFO *mk));
LOCAL WORD rb_click    _((RBOBJP rb, MKINFO *mk));

LOCAL VOID new_sliders _((RBOBJP rb));
LOCAL WORD cx          _((RBOBJP rb));
LOCAL WORD cy          _((RBOBJP rb));
LOCAL WORD cw          _((RBOBJP rb));
LOCAL WORD ch          _((RBOBJP rb));
LOCAL VOID draw_curs   _((RBOBJP rb));
LOCAL VOID draw_rb     _((WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color));
LOCAL VOID draw_old_rb _((WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color));

/*****************************************************************************/

GLOBAL WORD rb_obj (rbobj, message, wparam, mk)
RBOBJP rbobj;
WORD   message;
WORD   wparam;
MKINFO *mk;

{
  WORD ret;

  ret = RB_WRONGMESSAGE;

  switch (message)
  {
    case RB_INIT       : ret = rb_init (rbobj, mk);  break;
    case RB_EXIT       : ret = rb_exit (rbobj);      break;
    case RB_CLEAR      : ret = rb_clear (rbobj);     break;
    case RB_DRAW       : ret = rb_draw (rbobj);      break;
    case RB_SHOWCURSOR : ret = rb_showcurs (rbobj);  break;
    case RB_HIDECURSOR : ret = rb_hidecurs (rbobj);  break;
    case RB_KEY        : ret = rb_key (rbobj, mk);   break;
    case RB_CLICK      : ret = rb_click (rbobj, mk); break;
  } /* switch */

  return (ret);
} /* rb_obj */

/*****************************************************************************/

LOCAL WORD rb_init (rb, mk)
RBOBJP rb;
MKINFO *mk;

{
  rb->cursor      = 0;
  rb->curs_hidden = TRUE;

  if ((mk == NULL) || (mk->breturn == 0)) new_sliders (rb);     /* text was not entered with the mouse */

  return (RB_OK);
} /* rb_init */

/*****************************************************************************/

LOCAL WORD rb_exit (rb)
RBOBJP rb;

{
  return (RB_OK);
} /* rb_exit */

/*****************************************************************************/

LOCAL WORD rb_clear (rb)
RBOBJP rb;

{
  rb_exit (rb);
  rb->selected = FAILURE;
  rb_init (rb, NULL);

  return (RB_OK);
} /* rb_clear */

/*****************************************************************************/

LOCAL WORD rb_draw (rb)
RBOBJP rb;

{
  WORD    i;
  WORD    x, y, w, h;
  RECT    old_clip, r;
  WINDOWP window;

  window = rb->window;

  for (i = 0; i < rb->buttons; i++)
  {
    rect2xywh (&rb->pos, &x, &y, &w, &h);

    x += window->scroll.x - window->doc.x * window->xfac;
    y += window->scroll.y - window->doc.y * window->yfac;
    y += h * i;

    old_clip = clip;
    xywh2rect (x, y, w, h, &r);

    if (rc_intersect (&clip, &r))
    {
      set_clip (TRUE, &r);
      draw_rb (x, y, h, i == rb->selected, rb->color, rb->bk_color);
      set_clip (TRUE, &old_clip);
    } /* if */
  } /* if */

  return (RB_OK);
} /* rb_draw */

/*****************************************************************************/

LOCAL WORD rb_showcurs (rb)
RBOBJP rb;

{
  draw_curs (rb);
  rb->curs_hidden = FALSE;

  return (RB_OK);
} /* rb_showcurs */

/*****************************************************************************/

LOCAL WORD rb_hidecurs (rb)
RBOBJP rb;

{
  if (rb->curs_hidden) return (RB_OK);

  draw_curs (rb);
  rb->curs_hidden = TRUE;

  return (RB_OK);
} /* rb_hidecurs */

/*****************************************************************************/

LOCAL WORD rb_key (rb, mk)
RBOBJP rb;
MKINFO *mk;

{
  WORD ret;

  ret = RB_CHARNOTUSED;

  if (rb->flags & RB_OUTPUT) return (ret);

  hide_mouse ();
  rb_hidecurs (rb);

  if (RB_CNTRL (mk))
  {
    ret = RB_OK;

    if (mk->ascii_code == ' ')
    {
      rb->selected = rb->cursor;
      ret          = RB_BUFFERCHANGED;
      rb_draw (rb);
    } /* if */

    if (mk->ascii_code == ESC)
    {
      rb_clear (rb);
      rb_draw (rb);

      ret = RB_BUFFERCHANGED;
    } /* if */

    if (mk->shift)
      switch (mk->scan_code)
      {
        case UP       : mk->scan_code = POS1;   break;
        case DOWN     :
        case CLR_HOME : mk->scan_code = ENDKEY; break;
      } /* switch, if */

    switch (mk->scan_code)
    {
      case UP     : if (rb->cursor > 0) rb->cursor--;               break;
      case DOWN   : if (rb->cursor < rb->buttons - 1) rb->cursor++; break;
      case POS1   : rb->cursor = 0;                                 break;
      case ENDKEY : rb->cursor = rb->buttons - 1;                   break;
    } /* switch */

    new_sliders (rb);
  } /* if */

  rb_showcurs (rb);
  show_mouse ();

  return (ret);
} /* rb_key */

/*****************************************************************************/

LOCAL WORD rb_click (rb, mk)
RBOBJP rb;
MKINFO *mk;

{
  WORD    x, y;
  WORD    button;
  RECT    r;
  WINDOWP window;

  if (rb->flags & RB_OUTPUT) return (RB_OK);

  window = rb->window;

  x = rb->pos.x - window->doc.x * window->xfac + window->scroll.x;
  y = rb->pos.y - window->doc.y * window->yfac + window->scroll.y;

  button = (mk->moy - y) / rb->pos.h;
  if (button >= rb->buttons) return (RB_OK);
  if (button < 0) button = 0;

  xywh2rect (x, y + button * rb->pos.h, rb->pos.w, rb->pos.h, &r);
  if (inside (mk->mox, mk->moy, &r))
  {
    rb->cursor   = button;
    rb->selected = button;
    rb_draw (rb);
  } /* if */

  new_sliders (rb);

  return (RB_BUFFERCHANGED);
} /* rb_click */

/*****************************************************************************/

LOCAL VOID new_sliders (rb)
RBOBJP rb;

{
  WINDOWP window;
  BOOLEAN do_x, do_y;
  WORD    x, y, xpos, ypos;
  LONG    rel_x, rel_y;
  LONG    div_x, div_y;
  WORD    msgbuff [8];
  WORD    ret, button;

  graf_mkstate (&ret, &ret, &button, &ret); 
  if (button & 0x003) return;

  window = rb->window;

  x = cx (rb) - window->doc.x * window->xfac + window->scroll.x;
  y = cy (rb) - window->doc.y * window->yfac + window->scroll.y;

  do_x = (x < window->scroll.x) || (x + cw (rb) > window->scroll.x + window->scroll.w);
  do_y = (y < window->scroll.y) || (y + ch (rb) > window->scroll.y + window->scroll.h);

  if (do_x || do_y)                             /* if cursor not in window */
  {
    rel_x = cx (rb) - window->scroll.w / 2;     /* cursor will centered in window */
    rel_y = cy (rb) - window->scroll.h / 2;
    div_x = window->doc.w * window->xfac - window->scroll.w;
    div_y = window->doc.h * window->yfac - window->scroll.h;
    xpos  = (rel_x <= 0) ? 0 : (div_x == 0) ? 1000 : (1000 * rel_x) / div_x;
    ypos  = (rel_y <= 0) ? 0 : (div_y == 0) ? 1000 : (1000 * rel_y) / div_y;

    if (xpos > 1000) xpos = 1000;
    if (ypos > 1000) ypos = 1000;

    if (do_x)
    {
      msgbuff [0] = WM_HSLID;
      msgbuff [1] = gl_apid;
      msgbuff [2] = 0;
      msgbuff [3] = window->handle;
      msgbuff [4] = xpos;
      msgbuff [5] = 0;
      msgbuff [6] = 0;
      msgbuff [7] = 0;

      appl_write (gl_apid, sizeof (msgbuff), msgbuff);
    } /* if */

    if (do_y)
    {
      msgbuff [0] = WM_VSLID;
      msgbuff [1] = gl_apid;
      msgbuff [2] = 0;
      msgbuff [3] = window->handle;
      msgbuff [4] = ypos;
      msgbuff [5] = 0;
      msgbuff [6] = 0;
      msgbuff [7] = 0;

      appl_write (gl_apid, sizeof (msgbuff), msgbuff);
    } /* if */
  } /* if */
} /* new_sliders */

/*****************************************************************************/

LOCAL WORD cx (rb)
RBOBJP rb;

{
  return (rb->pos.x);
} /* cx */

/*****************************************************************************/

LOCAL WORD cy (rb)
RBOBJP rb;

{
  return (rb->pos.y + rb->cursor * rb->pos.h);
} /* cy */

/*****************************************************************************/

LOCAL WORD cw (rb)
RBOBJP rb;

{
  return (rb->pos.w);
} /* cw */

/*****************************************************************************/

LOCAL WORD ch (rb)
RBOBJP rb;

{
  return (rb->pos.h);
} /* ch */

/*****************************************************************************/

LOCAL VOID draw_curs (rb)
RBOBJP rb;

{
  WORD    xy [10];
  WORD    x, y;
  WINDOWP window;

  hide_mouse ();
  window = rb->window;

  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_XOR);
  vsl_udsty (vdi_handle, 0x5555);
  vsl_type (vdi_handle, USERLINE);

  x = cx (rb) - window->doc.x * window->xfac + window->scroll.x;
  y = cy (rb) - window->doc.y * window->yfac + window->scroll.y;

  xy [0] = x;
  xy [1] = y;
  xy [2] = x + cw (rb) - 1;
  xy [3] = y;
  xy [4] = xy [2];
  xy [5] = y + ch (rb) - 1;
  xy [6] = x;
  xy [7] = xy [5];
  xy [8] = x;
  xy [9] = y;

  v_pline (vdi_handle, 5, xy);

  show_mouse ();
} /* draw_curs */

/*****************************************************************************/

LOCAL VOID draw_rb (x, y, h, selected, color, bk_color)
WORD    x, y, h;
BOOLEAN selected;
WORD    color;
WORD    bk_color;

{
  RECT     frame;
  FONTDESC fontdesc;

  frame.x = x;
  frame.y = y;
  frame.w = gl_wbox;
  frame.h = h;

  fontdesc.font    = FONT_SYSTEM;
  fontdesc.point   = gl_point;
  fontdesc.effects = TXT_NORMAL;
  fontdesc.color   = color;

  if (h < 13)	/* for compatibility of older masks using a small font */
    draw_old_rb (x, y, h, selected, color, bk_color);
  else
    DrawCheckRadio (vdi_handle, &frame, &clip, NULL, 0, selected ? SELECTED : NORMAL, bk_color, &fontdesc, TRUE);
} /* draw_rb */

/*****************************************************************************/

LOCAL VOID draw_old_rb (WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color)
{
  MFDB   s, d;
  BITBLK *bitblk;
  WORD   obj;
  WORD   pxy [8];
  WORD   index [2];

  if (selected)
    obj = (h >= 12) ? RBHSEL : (h >= 7) ? RB7SEL : RB5SEL;
  else
    obj = (h >= 12) ? RBHNORM : (h >= 7) ? RB7NORM : RB5NORM;

  if (gl_hbox <= 8)     /* low resolution like CGA */
  {
    switch (obj)        /* use same buttons as dialogue boxes */
    {
      case RB7SEL  : obj = RBLSEL;  break;
      case RB7NORM : obj = RBLNORM; break;
    } /* switch */
  } /* if */

  bitblk = (BITBLK *)userimg [obj].ob_spec;

  d.mp  = NULL;                                 /* screen */
  s.mp  = (VOID *)bitblk->bi_pdata;
  s.fwp = bitblk->bi_wb << 3;
  s.fh  = bitblk->bi_hl;
  s.fww = bitblk->bi_wb >> 1;
  s.ff  = FALSE;
  s.np  = 1;

  y += (h - s.fh) / 2;                       /* center box */

  pxy [0] = 0;
  pxy [1] = 0;
  pxy [2] = s.fwp - 1;
  pxy [3] = s.fh - 1;
  pxy [4] = x;
  pxy [5] = y;
  pxy [6] = x + pxy [2];
  pxy [7] = y + pxy [3];

  index [0] = color;
  index [1] = (dlg_colors < 16) ? WHITE : bk_color;

  vrt_cpyfm (vdi_handle, MD_REPLACE, pxy, &s, &d, index);    /* copy it */
} /* draw_old_rb */


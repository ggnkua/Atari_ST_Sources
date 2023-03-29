/*****************************************************************************
 *
 * Module : CBOBJ.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 14.12.90
 * Last modification: 16.08.95
 *
 *
 * Description: This module implements a checkbox object
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
#include "cbobj.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL WORD cb_init     _((CBOBJP cb, WORD value, MKINFO *mk));
LOCAL WORD cb_exit     _((CBOBJP cb));
LOCAL WORD cb_clear    _((CBOBJP cb));
LOCAL WORD cb_draw     _((CBOBJP cb));
LOCAL WORD cb_showcurs _((CBOBJP cb));
LOCAL WORD cb_hidecurs _((CBOBJP cb));
LOCAL WORD cb_key      _((CBOBJP cb, MKINFO *mk));
LOCAL WORD cb_click    _((CBOBJP cb, MKINFO *mk));

LOCAL VOID new_sliders _((CBOBJP cb));
LOCAL VOID draw_curs   _((CBOBJP cb));
LOCAL VOID draw_cb     _((RECT *r, BOOLEAN selected, WORD color, WORD bk_color));

/*****************************************************************************/

GLOBAL WORD cb_obj (cbobj, message, wparam, mk)
CBOBJP cbobj;
WORD   message;
WORD   wparam;
MKINFO *mk;

{
  WORD ret;

  ret = CB_WRONGMESSAGE;

  switch (message)
  {
    case CB_INIT       : ret = cb_init (cbobj, wparam, mk); break;
    case CB_EXIT       : ret = cb_exit (cbobj);             break;
    case CB_CLEAR      : ret = cb_clear (cbobj);            break;
    case CB_DRAW       : ret = cb_draw (cbobj);             break;
    case CB_SHOWCURSOR : ret = cb_showcurs (cbobj);         break;
    case CB_HIDECURSOR : ret = cb_hidecurs (cbobj);         break;
    case CB_KEY        : ret = cb_key (cbobj, mk);          break;
    case CB_CLICK      : ret = cb_click (cbobj, mk);        break;
  } /* switch */

  return (ret);
} /* cb_obj */

/*****************************************************************************/

LOCAL WORD cb_init (cb, value, mk)
CBOBJP cb;
WORD   value;
MKINFO *mk;

{
  cb->selected    = value;
  cb->curs_hidden = TRUE;

  if ((mk == NULL) || (mk->breturn == 0)) new_sliders (cb);     /* text was not entered with the mouse */

  return (CB_OK);
} /* cb_init */

/*****************************************************************************/

LOCAL WORD cb_exit (cb)
CBOBJP cb;

{
  return (CB_OK);
} /* cb_exit */

/*****************************************************************************/

LOCAL WORD cb_clear (cb)
CBOBJP cb;

{
  cb_exit (cb);
  cb_init (cb, FALSE, NULL);

  return (CB_OK);
} /* cb_clear */

/*****************************************************************************/

LOCAL WORD cb_draw (cb)
CBOBJP cb;

{
  RECT    area, old_clip, r;
  WINDOWP window;

  window = cb->window;

  area    = cb->box;
  area.x += window->scroll.x - window->doc.x * window->xfac;
  area.y += window->scroll.y - window->doc.y * window->yfac;

  old_clip  = clip;
  r         = area;

  if (rc_intersect (&clip, &r))
  {
    set_clip (TRUE, &r);
    draw_cb (&area, cb->selected, cb->color, cb->bk_color);
    set_clip (TRUE, &old_clip);
  } /* if */

  return (CB_OK);
} /* cb_draw */

/*****************************************************************************/

LOCAL WORD cb_showcurs (cb)
CBOBJP cb;

{
  draw_curs (cb);
  cb->curs_hidden = FALSE;

  return (CB_OK);
} /* cb_showcurs */

/*****************************************************************************/

LOCAL WORD cb_hidecurs (cb)
CBOBJP cb;

{
  if (cb->curs_hidden) return (CB_OK);

  draw_curs (cb);
  cb->curs_hidden = TRUE;

  return (CB_OK);
} /* cb_hidecurs */

/*****************************************************************************/

LOCAL WORD cb_key (cb, mk)
CBOBJP cb;
MKINFO *mk;

{
  WORD ret;

  ret = CB_CHARNOTUSED;

  if (cb->flags & CB_OUTPUT) return (ret);

  hide_mouse ();
  cb_hidecurs (cb);

  if (mk->ascii_code == ' ')
  {
    cb->selected = ! cb->selected;
    cb_draw (cb);
    ret = CB_BUFFERCHANGED;
    new_sliders (cb);
  } /* if */

  if (mk->ascii_code == ESC)
  {
    cb_clear (cb);
    cb_draw (cb);

    ret = CB_BUFFERCHANGED;
  } /* if */

  cb_showcurs (cb);
  show_mouse ();

  return (ret);
} /* cb_key */

/*****************************************************************************/

LOCAL WORD cb_click (cb, mk)
CBOBJP cb;
MKINFO *mk;

{
  if (cb->flags & CB_OUTPUT) return (CB_OK);

  cb->selected = ! cb->selected;
  cb_draw (cb);

  new_sliders (cb);

  return (CB_BUFFERCHANGED);
} /* cb_click */

/*****************************************************************************/

LOCAL VOID new_sliders (cb)
CBOBJP cb;

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

  window = cb->window;

  x = cb->box.x - window->doc.x * window->xfac + window->scroll.x;
  y = cb->box.y - window->doc.y * window->yfac + window->scroll.y;

  do_x = (x < window->scroll.x) || (x + cb->box.w > window->scroll.x + window->scroll.w);
  do_y = (y < window->scroll.y) || (y + cb->box.h > window->scroll.y + window->scroll.h);

  if (do_x || do_y)                             /* if cursor not in window */
  {
    rel_x = cb->box.x - window->scroll.w / 2;   /* cursor will centered in window */
    rel_y = cb->box.y - window->scroll.h / 2;
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

LOCAL VOID draw_curs (cb)
CBOBJP cb;

{
  WORD    xy [10];
  WORD    x, y;
  WINDOWP window;

  hide_mouse ();
  window = cb->window;

  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_XOR);
  vsl_udsty (vdi_handle, 0x5555);
  vsl_type (vdi_handle, USERLINE);

  x = cb->text.x - window->doc.x * window->xfac + window->scroll.x;
  y = cb->text.y - window->doc.y * window->yfac + window->scroll.y;

  xy [0] = x;
  xy [1] = y;
  xy [2] = x + cb->text.w - 1;
  xy [3] = y;
  xy [4] = xy [2];
  xy [5] = y + cb->text.h - 1;
  xy [6] = x;
  xy [7] = xy [5];
  xy [8] = x;
  xy [9] = y;

  v_pline (vdi_handle, 5, xy);

  show_mouse ();
} /* draw_curs */

/*****************************************************************************/

LOCAL VOID draw_cb (r, selected, color, bk_color)
RECT    *r;
BOOLEAN selected;
WORD    color;
WORD    bk_color;

{
  FONTDESC fontdesc;

  fontdesc.font    = FONT_SYSTEM;
  fontdesc.point   = gl_point;
  fontdesc.effects = TXT_NORMAL;
  fontdesc.color   = color;

  DrawCheckRadio (vdi_handle, r, &clip, NULL, 0, selected ? SELECTED : NORMAL, bk_color, &fontdesc, FALSE);
} /* draw_cb */


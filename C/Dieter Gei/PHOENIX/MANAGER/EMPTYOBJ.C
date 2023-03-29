/*****************************************************************************/
/*                                                                           */
/* Modul: EMPTYOBJ.C                                                         */
/* Datum: 25/02/91                                                           */
/*                                                                           */
/*****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "export.h"
#include "emptyobj.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL WORD eo_init     _((EMPTYOBJP eo, MKINFO *mk));
LOCAL WORD eo_exit     _((EMPTYOBJP eo));
LOCAL WORD eo_clear    _((EMPTYOBJP eo));
LOCAL WORD eo_draw     _((EMPTYOBJP eo));
LOCAL WORD eo_showcurs _((EMPTYOBJP eo));
LOCAL WORD eo_hidecurs _((EMPTYOBJP eo));
LOCAL WORD eo_key      _((EMPTYOBJP eo, MKINFO *mk));
LOCAL WORD eo_click    _((EMPTYOBJP eo, MKINFO *mk));

LOCAL VOID new_sliders _((EMPTYOBJP eo));
LOCAL VOID draw_curs   _((EMPTYOBJP eo));

/*****************************************************************************/

GLOBAL WORD empty_obj (emptyobj, message, wparam, mk)
EMPTYOBJP emptyobj;
WORD      message;
WORD      wparam;
MKINFO    *mk;

{
  WORD ret;

  ret = EO_WRONGMESSAGE;

  switch (message)
  {
    case EO_INIT       : ret = eo_init (emptyobj, mk);  break;
    case EO_EXIT       : ret = eo_exit (emptyobj);      break;
    case EO_CLEAR      : ret = eo_clear (emptyobj);     break;
    case EO_DRAW       : ret = eo_draw (emptyobj);      break;
    case EO_SHOWCURSOR : ret = eo_showcurs (emptyobj);  break;
    case EO_HIDECURSOR : ret = eo_hidecurs (emptyobj);  break;
    case EO_KEY        : ret = eo_key (emptyobj, mk);   break;
    case EO_CLICK      : ret = eo_click (emptyobj, mk); break;
  } /* switch */

  return (ret);
} /* empty_obj */

/*****************************************************************************/

LOCAL WORD eo_init (eo, mk)
EMPTYOBJP eo;
MKINFO    *mk;

{
  eo->curs_hidden = TRUE;

  if ((mk == NULL) || (mk->breturn == 0)) new_sliders (eo);     /* text was not entered with the mouse */

  return (EO_OK);
} /* eo_init */

/*****************************************************************************/

LOCAL WORD eo_exit (eo)
EMPTYOBJP eo;

{
  return (EO_OK);
} /* eo_exit */

/*****************************************************************************/

LOCAL WORD eo_clear (eo)
EMPTYOBJP eo;

{
  eo_exit (eo);
  eo_init (eo, NULL);

  return (EO_OK);
} /* eo_clear */

/*****************************************************************************/

LOCAL WORD eo_draw (eo)
EMPTYOBJP eo;

{
  return (EO_OK);
} /* eo_draw */

/*****************************************************************************/

LOCAL WORD eo_showcurs (eo)
EMPTYOBJP eo;

{
  draw_curs (eo);
  eo->curs_hidden = FALSE;

  return (EO_OK);
} /* eo_showcurs */

/*****************************************************************************/

LOCAL WORD eo_hidecurs (eo)
EMPTYOBJP eo;

{
  if (eo->curs_hidden) return (EO_OK);

  draw_curs (eo);
  eo->curs_hidden = TRUE;

  return (EO_OK);
} /* eo_hidecurs */

/*****************************************************************************/

LOCAL WORD eo_key (eo, mk)
EMPTYOBJP eo;
MKINFO *mk;

{
  new_sliders (eo);

  return (EO_CHARNOTUSED);
} /* eo_key */

/*****************************************************************************/

LOCAL WORD eo_click (eo, mk)
EMPTYOBJP eo;
MKINFO *mk;

{
  new_sliders (eo);

  return (EO_OK);
} /* eo_click */

/*****************************************************************************/

LOCAL VOID new_sliders (eo)
EMPTYOBJP eo;

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

  window = eo->window;

  x = eo->pos.x - window->doc.x * window->xfac + window->scroll.x;
  y = eo->pos.y - window->doc.y * window->yfac + window->scroll.y;

  do_x = (x < window->scroll.x) || (x + eo->pos.w > window->scroll.x + window->scroll.w);
  do_y = (y < window->scroll.y) || (y + eo->pos.h > window->scroll.y + window->scroll.h);

  if (do_x || do_y)                             /* if cursor not in window */
  {
    rel_x = eo->pos.x - window->scroll.w / 2;   /* cursor will centered in window */
    rel_y = eo->pos.y - window->scroll.h / 2;
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

LOCAL VOID draw_curs (eo)
EMPTYOBJP eo;

{
  WORD    xy [10];
  WORD    x, y;
  WINDOWP window;

  hide_mouse ();
  window = eo->window;

  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_XOR);
  vsl_udsty (vdi_handle, 0x5555);
  vsl_type (vdi_handle, USERLINE);

  x = eo->pos.x - window->doc.x * window->xfac + window->scroll.x;
  y = eo->pos.y - window->doc.y * window->yfac + window->scroll.y;

  xy [0] = x;
  xy [1] = y;
  xy [2] = x + eo->pos.w - 1;
  xy [3] = y;
  xy [4] = xy [2];
  xy [5] = y + eo->pos.h - 1;
  xy [6] = x;
  xy [7] = xy [5];
  xy [8] = x;
  xy [9] = y;

  v_pline (vdi_handle, 5, xy);

  show_mouse ();
} /* draw_curs */

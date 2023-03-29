/*****************************************************************************
 *
 * Module : EDITOBJ.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the editor window.
 *
 * History:
 * 29.06.03: ed_copy, ed_cut, ed_past und ed_can_uccpcs unterstÅtzen nun das
 *           externe Klemmbrett
 * 11.05.94: Return ED_BUFFERCHANGED in ed_cut
 * 27.04.94: Cut, copy, paste with functions from GLOBAL.H, ED_GETCLIPBUF, ED_CLEARCLIPBUF deleted
 * 26.04.94: ED_USEPOS in curs_pgup/down added
 * 25.04.94: Function curs_docstart & curs_docend added
 * 22.04.94: Function del_line copies line to clipboard
 * 21.04.94: Cut, copy, paste finished
 * 20.04.94: Message handling of ED_CANUNDO,...,ED_CANSELALL added
 * 19.04.94: Message handling of ED_PASTEBUF, ED_GETCLIPBUF, ED_CLEARCLIPBUF added
 * 29.03.94: Function v_text called with no last parameter
 * 19.08.91: Module finished
 * 01.07.89: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include "global.h"
#include "windows.h"

#include "utility.h"

/* GS 5.1c Start */
#include "menu.h"
/* Ende */

#include "export.h"
#include "editobj.h"

/* GS 5.1c Start: */
#include "clipbrd.h"
#include "files.h"
/* Ende */

/****** DEFINES **************************************************************/

#define MAX_WDOC       255      /* 255 char/line maximum */
#define MAX_LINES    32000      /* max number of lines per document */
#define MAX_ADDLINES   500      /* max number of lines to add within text field */

#define ED_CNTRL(mk)   ((mk->ascii_code == ESC        ) || \
                        (mk->ascii_code == CR         ) || \
                        (mk->ascii_code == HT         ) || \
                        (mk->scan_code  == DELETE     ) || \
                        (mk->scan_code  == BACKSPACE  ) || \
                        (mk->scan_code  == CNTRL_LEFT ) || \
                        (mk->scan_code  == CNTRL_RIGHT) || \
                        (mk->scan_code  == LEFT       ) && (mk->ascii_code == 0) || \
                        (mk->scan_code  == RIGHT      ) && (mk->ascii_code == 0) || \
                        (mk->scan_code  == UP         ) && (mk->ascii_code == 0) || \
                        (mk->scan_code  == DOWN       ) && (mk->ascii_code == 0) || \
                        (mk->scan_code  == PGUP       ) && (mk->ascii_code == 0) || \
                        (mk->scan_code  == PGDOWN     ) && (mk->ascii_code == 0) || \
                        (mk->scan_code  == POS1       ) && (mk->ascii_code == 0) || \
                        (mk->scan_code  == ENDKEY     ) && (mk->ascii_code == 0))

#define IS_NUMERIC(mk) ((mk->ascii_code == '+') || \
                        (mk->ascii_code == '-') || \
                        (mk->ascii_code == '.') || \
                        (mk->ascii_code == ',') || \
                        (mk->ascii_code >= '0') && (mk->ascii_code <= '9'))

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

#if GEMDOS
EXTERN VOID vdi _((VOID));
#endif

LOCAL WORD    ed_init         _((EDOBJP ed, MKINFO *mk));
LOCAL WORD    ed_exit         _((EDOBJP ed));
LOCAL WORD    ed_clear        _((EDOBJP ed));
LOCAL WORD    ed_draw         _((EDOBJP ed));
LOCAL WORD    ed_showcurs     _((EDOBJP ed));
LOCAL WORD    ed_hidecurs     _((EDOBJP ed));
LOCAL WORD    ed_key          _((EDOBJP ed, MKINFO *mk));
LOCAL WORD    ed_click        _((EDOBJP ed, MKINFO *mk));
/* GS 5.1c Start: */
LOCAL WORD    ed_cut          _((EDOBJP ed, WORD ext));
LOCAL WORD    ed_copy         _((EDOBJP ed, WORD ext));
LOCAL WORD    ed_paste        _((EDOBJP ed, WORD ext));
/* Ende; alt:
LOCAL WORD    ed_cut          _((EDOBJP ed));
LOCAL WORD    ed_copy         _((EDOBJP ed));
LOCAL WORD    ed_paste        _((EDOBJP ed));
*/
LOCAL WORD    ed_pastebuf     _((EDOBJP ed, VOID *buffer, BOOLEAN move));
LOCAL WORD    ed_selall       _((EDOBJP ed));
LOCAL WORD    ed_setcurs      _((EDOBJP ed, MKINFO *mk));
LOCAL WORD    ed_up           _((EDOBJP ed, WORD amount));
LOCAL WORD    ed_down         _((EDOBJP ed, WORD amount));
LOCAL WORD    ed_left         _((EDOBJP ed, WORD amount));
LOCAL WORD    ed_right        _((EDOBJP ed, WORD amount));
LOCAL WORD    ed_strlen       _((EDOBJP ed, WORD line));
LOCAL WORD    ed_strwidth     _((EDOBJP ed, WORD line));
LOCAL WORD    ed_getclipbuf   _((EDOBJP ed, BYTE *pBuffer));
LOCAL WORD    ed_clearclipbuf _((VOID));
/* GS 5.1c Start: */
LOCAL WORD    ed_can_uccpcs   _((EDOBJP ed, WORD message, WORD ext));
/* Ende; alt:
LOCAL WORD    ed_can_uccpcs   _((EDOBJP ed, WORD message));	/* can undo, cut, copy, paste, clear, selall */
*/

LOCAL VOID    new_sliders     _((EDOBJP ed));
LOCAL VOID    new_doc         _((EDOBJP ed));
LOCAL LONG    cx              _((EDOBJP ed));
LOCAL LONG    cy              _((EDOBJP ed));
LOCAL BOOLEAN curs_left       _((EDOBJP ed));
LOCAL BOOLEAN curs_right      _((EDOBJP ed));
LOCAL BOOLEAN curs_up         _((EDOBJP ed));
LOCAL BOOLEAN curs_down       _((EDOBJP ed));
LOCAL VOID    curs_pgup       _((EDOBJP ed));
LOCAL VOID    curs_pgdown     _((EDOBJP ed));
LOCAL VOID    curs_pos1       _((EDOBJP ed));
LOCAL VOID    curs_end        _((EDOBJP ed));
LOCAL VOID    curs_docstart   _((EDOBJP ed));
LOCAL VOID    curs_docend     _((EDOBJP ed));
LOCAL VOID    next_word       _((EDOBJP ed));
LOCAL VOID    prev_word       _((EDOBJP ed));
LOCAL VOID    set_curs        _((EDOBJP ed, WORD x, WORD y));
LOCAL BOOLEAN ins_chars       _((EDOBJP ed, BYTE *buffer, BOOLEAN move));
LOCAL BOOLEAN del_char        _((EDOBJP ed, BOOLEAN draw));
LOCAL BOOLEAN del_line        _((EDOBJP ed));
LOCAL VOID    set_lptr        _((EDOBJP ed, WORD start));
LOCAL VOID    draw_from       _((EDOBJP ed, WORD start));
LOCAL BOOLEAN get_line        _((EDOBJP ed, WORD line, BYTE *buffer));
LOCAL BYTE    *next_line      _((WORD width, BYTE *p, BYTE *s, WORD *wbox, WORD *chars, BOOLEAN *cr, BOOLEAN wordbreak));
LOCAL VOID    get_wboxes      _((WORD *boxes, WORD low, WORD high));

/*****************************************************************************/

GLOBAL WORD edit_obj (edobj, message, wparam, p)
EDOBJP edobj;
WORD   message;
WORD   wparam;
VOID   *p;

{
  WORD ret;
/* GS 5.1c Start */
	WORD ext;

	ext = ccp_ext;
/* Ende */

  ret = ED_WRONGMESSAGE;

  switch (message)
  {
    case ED_INIT         : ret = ed_init (edobj, p);             break;
    case ED_EXIT         : ret = ed_exit (edobj);                break;
    case ED_CLEAR        : ret = ed_clear (edobj);               break;
    case ED_DRAW         : ret = ed_draw (edobj);                break;
    case ED_SHOWCURSOR   : ret = ed_showcurs (edobj);            break;
    case ED_HIDECURSOR   : ret = ed_hidecurs (edobj);            break;
    case ED_KEY          : ret = ed_key (edobj, p);              break;
    case ED_CLICK        : ret = ed_click (edobj, p);            break;
/* GS 5.1c Start: */
    case ED_CUT          : ret = ed_cut (edobj, ext);            break;
    case ED_COPY         : ret = ed_copy (edobj, ext);           break;
    case ED_PASTE        : ret = ed_paste (edobj, ext);          break;
/* Ende; alt:
    case ED_CUT          : ret = ed_cut (edobj);                 break;
    case ED_COPY         : ret = ed_copy (edobj);                break;
    case ED_PASTE        : ret = ed_paste (edobj);               break;
*/
    case ED_PASTEBUF     : ret = ed_pastebuf (edobj, p, wparam); break;
    case ED_SELALL       : ret = ed_selall (edobj);              break;
    case ED_SETCURSOR    : ret = ed_setcurs (edobj, p);          break;
    case ED_UP           : ret = ed_up (edobj, wparam);          break;
    case ED_DOWN         : ret = ed_down (edobj, wparam);        break;
    case ED_LEFT         : ret = ed_left (edobj, wparam);        break;
    case ED_RIGHT        : ret = ed_right (edobj, wparam);       break;
    case ED_SELECTED     : ret = edobj->selected;                break;
    case ED_STRLEN       : ret = ed_strlen (edobj, wparam);      break;
    case ED_STRWIDTH     : ret = ed_strwidth (edobj, wparam);    break;
    case ED_CANUNDO      :
    case ED_CANCUT       :
    case ED_CANCOPY      :
    case ED_CANPASTE     :
    case ED_CANCLEAR     :
/* GS 5.1c Start: */
    case ED_CANSELALL    : ret = ed_can_uccpcs (edobj, message, ext); break;	/* can undo, cut, copy, paste, clear, selall */
/* Ende; alt: 
    case ED_CANSELALL    : ret = ed_can_uccpcs (edobj, message); break;	/* can undo, cut, copy, paste, clear, selall */
*/
  } /* switch */

  return (ret);
} /* edit_obj */

/*****************************************************************************/

LOCAL WORD ed_init (ed, mk)
EDOBJP ed;
MKINFO *mk;

{
  BOOLEAN monospaced, cr;
  WORD    err, max_w;
  WORD    i, lines, cols;
  WORD    wchar, hchar;
  WORD    wbox, hbox;
  WORD    minimum, maximum, width;
  WORD    distances [5], effects [3];
  LONG    index;
  LONGSTR s;
  BYTE    *text;

  vst_font (vdi_handle, ed->font);
  vst_point (vdi_handle, ed->point, &wchar, &hchar, &wbox, &hbox);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

  if (ed->flags & ED_WORDBREAK) ed->flags &= ~ ED_AUTOHSCROLL;
  if (ed->font == FONT_SYSTEM) ed->flags |= ED_MONOSPACED;

  ed->bufindex    = 0;
  ed->cx          = 0;
  ed->cy          = 0;
  ed->cell_width  = wbox;
  ed->hbox        = hbox;
  ed->curs_hidden = TRUE;
  ed->selected    = FALSE;
  ed->sel_start   = FAILURE;
  ed->sel_end     = FAILURE;

  for (i = 0; i < 256; i++) ed->wbox [i] = wbox;

  if (! (ed->flags & ED_MONOSPACED)) get_wboxes (ed->wbox, minimum, maximum);

  monospaced = TRUE;

  for (i = minimum; i <= maximum; i++)
    if (ed->wbox [i] != wbox) monospaced = FALSE;

  if (monospaced) ed->flags |= ED_MONOSPACED;

  err = ed_exit (ed);

  text  = ed->text;
  lines = 0;
  cols  = 0;
  max_w = ed->pos.w;

  while (*text != EOS)          /* count lines */
  {
    lines++;
    text = next_line (max_w, text, s, ed->wbox, &i, &cr, ed->flags & ED_WORDBREAK);
    cols = max (cols, strlen (s));
  } /* while */

  if (cr) lines++;
  if (lines == 0) lines = 1;
  if (cols  == 0) cols  = ed->actsize;

  if (lines + MAX_ADDLINES > MAX_LINES) return (ED_2MANYLINES);
  if (lines > 32767 / gl_hbox) err = ED_SHOWLINES;

  ed->lines      = lines;
  ed->cols       = cols;
  ed->max_lines  = lines + MAX_ADDLINES;
  ed->act_line   = 0;
  ed->act_col    = 0;
  ed->line_ptr   = (LONG *)mem_alloc ((LONG)ed->max_lines * sizeof (ed->line_ptr));
  ed->doc.x      = 0;
  ed->doc.y      = 0;
  ed->doc.w      = cols;
  ed->doc.h      = lines;

  if (ed->line_ptr == NULL)
    err = ED_NOMEMORY;
  else
  {
    for (i = 0; i < ed->max_lines; i++) ed->line_ptr [i] = -1;

    text  = ed->text;
    index = 0;
    i     = 0;

    busy_mouse ();

    while (i < lines)           /* set line pointer */
    {
      ed->line_ptr [i++] = index;
      text   = next_line (max_w, text, s, ed->wbox, &cols, &cr, ed->flags & ED_WORDBREAK);
      index += cols;
    } /* while */

    arrow_mouse ();
  } /* else */

  if ((mk == NULL) || (mk->breturn == 0))
  {
    new_doc (ed);
    new_sliders (ed);   /* text was not entered with the mouse */
  } /* if */

  return (err);
} /* ed_init */

/*****************************************************************************/

LOCAL WORD ed_exit (ed)
EDOBJP ed;

{
  if (ed->line_ptr != NULL)
  {
    mem_free (ed->line_ptr);
    ed->line_ptr = NULL;
  } /* if */

  return (ED_OK);
} /* ed_exit */

/*****************************************************************************/

LOCAL WORD ed_clear (ed)
EDOBJP ed;

{
  ed_exit (ed);

  ed->text [0] = EOS;
  ed->actsize  = 0;

  ed_init (ed, NULL);

  return (ED_OK);
} /* ed_clear */

/*****************************************************************************/

LOCAL WORD ed_draw (ed)
EDOBJP ed;

{
  draw_from (ed, ed->doc.y);

  return (ED_OK);
} /* ed_draw */

/*****************************************************************************/

LOCAL WORD ed_showcurs (ed)
EDOBJP ed;

{
  BOOLEAN linecursor;
  WORD    xy [10];
  WORD    x, y;
  WORD    width;
  RECT    old_clip;
  WINDOWP window;

  hide_mouse ();
  window   = ed->window;
  width    = ed->wbox [(UBYTE)ed->text [ed->bufindex]];
  old_clip = clip;
  rc_intersect (&window->scroll, &clip);
  set_clip (TRUE, &clip);

  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_XOR);

  linecursor = FALSE;

  x = ed->pos.x + cx (ed) - window->doc.x * window->xfac + window->scroll.x;
  y = ed->pos.y + cy (ed) - window->doc.y * window->yfac + window->scroll.y;

  if ((cx (ed) + width > ed->pos.w) &&
      (ed->flags & ED_LINEONLAST)) linecursor = TRUE;

  if (linecursor)
  {
    xy [0] = x;
    xy [1] = y;
    xy [2] = x;
    xy [3] = y + ed->hbox - 1;

    v_pline (vdi_handle, 2, xy);        /* line cursor */
  } /* if */
  else
  {
    if (ed->flags & ED_OUTPUT)
    {
      xy [0] = x;
      xy [1] = y;
      xy [2] = xy [0] + width - 1;
      xy [3] = xy [1];
      xy [4] = xy [2];
      xy [5] = xy [1] + ed->hbox - 1;
      xy [6] = xy [0];
      xy [7] = xy [5];
      xy [8] = xy [0];
      xy [9] = xy [1] + 1;

      v_pline (vdi_handle, 5, xy);      /* frame cursor */
    } /* if */
    else
    {
      xy [0] = x;
      xy [1] = y;
      xy [2] = x + width - 1;
      xy [3] = y + ed->hbox - 1;

      vsf_interior (vdi_handle, FIS_SOLID);
      vsf_color (vdi_handle, BLACK);
      vr_recfl (vdi_handle, xy);        /* block cursor */
    } /* else */
  } /* else */

  ed->curs_hidden = FALSE;

  set_clip (TRUE, &old_clip);
  show_mouse ();

  return (ED_OK);
} /* ed_showcurs */

/*****************************************************************************/

LOCAL WORD ed_hidecurs (ed)
EDOBJP ed;

{
  WORD ret;

  if (ed->curs_hidden) return (ED_OK);

  ret             = ed_showcurs (ed);
  ed->curs_hidden = TRUE;

  return (ret);
} /* ed_hidecurs */

/*****************************************************************************/

LOCAL WORD ed_key (ed, mk)
EDOBJP ed;
MKINFO *mk;

{
  BOOLEAN used, ok;
  WORD    ret;
  STRING  s;

  ret  = ED_OK;
  used = FALSE;

  hide_mouse ();
  ed_hidecurs (ed);

  if (ED_CNTRL (mk))
  {
    switch (mk->ascii_code)
    {
      case ESC : if (! (ed->flags & ED_OUTPUT))
                 {
                   ed_clear (ed);
                   ed_draw (ed);

                   ret = ED_BUFFERCHANGED;
                 } /* if */
                 break;
      case HT  : if (! mk->ctrl)
                 {
                   strcpy (s, "        ");
                   if (ins_chars (ed, &s [ed->act_col % 8], TRUE))
                     ret = ED_BUFFERCHANGED;
                   else
                     ret = ED_NOMEMORY;
                 } /* if */
                 else
                   ret = ED_CHARNOTUSED;
                 break;
      case CR  : if (! mk->ctrl && (ed->flags & ED_CRACCEPT) && ! (ed->flags & ED_OUTPUT))
                 {
                   if (ed->actsize + 1 < ed->bufsize)   /* CR + LF */
                   {
                     if (ed->lines < ed->max_lines)
                     {
                       s [0] = CR;
                       s [1] = LF;
                       s [2] = EOS;
                       if (ins_chars (ed, s, TRUE)) ret = ED_BUFFERCHANGED;
                     } /* if */
                     else
                       ret = ED_2MANYLINES;
                   } /* if */
                   else
                     ret = ED_NOMEMORY;
                 } /* if */
                 else
                   ret = ED_CHARNOTUSED;
                 break;
      default  : if (mk->shift)
                   switch (mk->scan_code)
                   {
                     case UP       : mk->scan_code = PGUP;   break;
                     case DOWN     : mk->scan_code = PGDOWN; break;
                     case CLR_HOME : mk->scan_code = ENDKEY; break;
                   } /* switch */

                 switch (mk->scan_code)
                 {
                   case BACKSPACE   : if (! (ed->flags & ED_OUTPUT))
                                        if (curs_left (ed))
                                        {
                                          del_char (ed, TRUE);
                                          ret = ED_BUFFERCHANGED;
                                        } /* if, if */
                                      break;
                   case DELETE      : if (! (ed->flags & ED_OUTPUT))
                                      {
                                        ok = FALSE;

                                        if (mk->ctrl)
                                          ok = del_line (ed);
                                        else
                                          ok = del_char (ed, TRUE);

                                        if (ok) ret = ED_BUFFERCHANGED;
                                      } /* if */
                                      break;
                   case LEFT        : if (mk->shift)
                                        curs_pos1 (ed);
                                      else
                                        curs_left (ed);
                                      break;
                   case RIGHT       : if (mk->shift)
                                        curs_end (ed);
                                      else
                                        curs_right (ed);
                                      break;
                   case PGUP        : curs_pgup (ed);     break;
                   case PGDOWN      : curs_pgdown (ed);   break;
                   case UP          : curs_up (ed);       break;
                   case DOWN        : curs_down (ed);     break;
                   case POS1        : curs_docstart (ed); break;
                   case ENDKEY      : curs_docend (ed);   break;
                   case CNTRL_LEFT  : prev_word (ed);     break;
                   case CNTRL_RIGHT : next_word (ed);     break;
                 } /* switch */
                 break;
    } /* switch */

    used = TRUE;
  } /* if */
  else
  {
    if (iscntrl (mk->ascii_code))
      ret = ED_CHARNOTUSED;
    else
      if (! (ed->flags & ED_OUTPUT))
      {
        if (! (ed->flags & ED_NUMERIC) || IS_NUMERIC (mk))
        {
          s [0] = mk->ascii_code;
          s [1] = EOS;
          if (ins_chars (ed, s, TRUE)) ret = ED_BUFFERCHANGED;
          used = TRUE;
        } /* if */
        else
          ret = ED_CHARNOTUSED;
      } /* if, else */
  } /* else */

  if (used)
  {
    new_doc (ed);
    new_sliders (ed);
  } /* if */

  ed_showcurs (ed);
  show_mouse ();

  return (ret);
} /* ed_key */

/*****************************************************************************/

LOCAL WORD ed_click (ed, mk)
EDOBJP ed;
MKINFO *mk;

{
  WORD    x, y, w, width;
  WORD    line;
  WINDOWP window;

  window = ed->window;

  x = ed->pos.x - window->doc.x * window->xfac + window->scroll.x;
  y = ed->pos.y - window->doc.y * window->yfac + window->scroll.y;

  x    = (mk->mox - x) + ed->doc.x;
  line = (mk->moy - y) / ed->hbox + ed->doc.y;
  if (line >= ed->lines) line = ed->lines - 1;

  if (x < 0) x = 0;
  if (line < 0) line = 0;

  ed->cx       = 0;
  ed->cy       = line * (LONG)ed->hbox;
  ed->act_line = line;
  ed->act_col  = 0;
  ed->bufindex = ed->line_ptr [line];

  width = ed_strwidth (ed, line);
  x     = min (x, width);
  w     = ed->wbox [(UBYTE)ed->text [ed->bufindex]];

  if (x == width)
    curs_end (ed);
  else
    while (ed->cx + w <= x)
    {
      curs_right (ed);
      w = ed->wbox [(UBYTE)ed->text [ed->bufindex]];
    } /* while */

  if ((mk->breturn == 1) && (mk->mobutton & 0x003)) /* drag operation */
    /*beep ()*/; /*drag_objs (window, sel_objs, mk);*/

  new_doc (ed);
  new_sliders (ed);

  return (ED_OK);
} /* ed_click */

/*****************************************************************************/

/* GS 5.1c Start: */
LOCAL WORD ed_cut  ( EDOBJP ed, WORD ext)
/* Ende; alt:
LOCAL WORD ed_cut (ed)
EDOBJP ed;
*/

{
  WORD ret;

/* GS 5.1c Start: */
  ret = ed_copy (ed, ext);
/* Ende; alt:
  ret = ed_copy (ed);
*/

  if (ret == ED_OK)
  {
    ed->sel_start = FAILURE;
    ed->sel_end   = FAILURE;

    hide_mouse ();
    ed_hidecurs (ed);
    ret = ed_clear (ed);
    ed_draw (ed);
    ed_showcurs (ed);
    show_mouse ();

    if (ret == ED_OK) ret = ED_BUFFERCHANGED;
  } /* if */

  return (ret);
} /* ed_cut */

/*****************************************************************************/

/* GS 5.1c Start: */
LOCAL WORD ed_copy  ( EDOBJP ed, WORD ext)
/* Ende; alt:
LOCAL WORD ed_copy (ed)
EDOBJP ed;
*/

{
  CHAR *pClipBuffer;

  if (ed->actsize == 0) return (ED_OK);

/* GS 5.1c Start */

	if ( ext )
	{
		write_to_clipboard ( ed->text, ed->actsize);
	}
	else
	{
/* Ende */
  pClipBuffer = mem_alloc (ed->actsize + 1);	/* including EOS */
  if (pClipBuffer == NULL) return (ED_NOMEMORY);

  strcpy (pClipBuffer, ed->text);
  ClipboardSetData (CF_TXT, pClipBuffer);
  ClipboardSetSize (CF_TXT, ed->actsize + 1);
/* GS 5.1c Start: */
  } /* else, if */
/* Ende */

  return (ED_OK);
} /* ed_copy */

/*****************************************************************************/

/* GS 5.1c Start: */
LOCAL WORD ed_paste  ( EDOBJP ed, WORD ext)
/* Ende; alt:
LOCAL WORD ed_paste (ed)
EDOBJP ed;
*/

{
  WORD  ret, lines;
  LONG  lClipSize, lRestSize, lMoveSize, l;
  EDOBJ ed_old;
  CHAR  *buf, *pClipBuffer;

/* GS 5.1c Start: */
	if ( ext )
	{
		pClipBuffer = read_from_clibboard ();
	}
	else
/* Ende */
	  pClipBuffer = ClipboardGetData (CF_TXT);

  if (pClipBuffer == NULL) return (ED_GENERAL);

  ed_old    = *ed;
/* GS 5.1c Start: */
  if ( ext )
  	lClipSize = strlen ( pClipBuffer );
  else
/* Ende */
	  lClipSize = ClipboardGetSize (CF_TXT) - 1;	/* size without EOS */
  lRestSize = ed->bufsize - ed->bufindex - lClipSize;
  lMoveSize = min (lClipSize, ed->bufsize - ed->bufindex);

  if (lRestSize > 0)	/* move rest of text to the right */
    mem_lmove (&ed->text [ed->bufindex + lClipSize], &ed->text [ed->bufindex], lRestSize);

  ed->actsize = min (ed->actsize + lClipSize, ed->bufsize);
  mem_lmove (&ed->text [ed->bufindex], pClipBuffer, lMoveSize);
  ed->text [ed->actsize] = EOS;

  ret = ed_init (ed, NULL);
  if (ret == ED_OK) ret = ED_BUFFERCHANGED;

  ed->bufindex    = ed_old.bufindex;
  ed->cx          = ed_old.cx;
  ed->cy          = ed_old.cy;
  ed->act_line    = ed_old.act_line;
  ed->act_col     = ed_old.act_col;
  ed->curs_hidden = ed_old.curs_hidden;
  ed->doc.x       = ed_old.doc.x;
  ed->doc.y       = ed_old.doc.y;

  hide_mouse ();
  ed_hidecurs (ed);
  ed_draw (ed);

  lines = 0;
  buf   = pClipBuffer;

  for (l = 0; l < lMoveSize; l++, buf++)
    if (*buf == LF) lines++;

  for (l = 0; l < lMoveSize - lines; l++) curs_right (ed);

  new_doc (ed);
  new_sliders (ed);
  ed_showcurs (ed);
  show_mouse ();

/* GS 5.1c Start: */
	if ( ext )
		mem_free ( pClipBuffer );
/* Ende */

  return (ret);
} /* ed_paste */

/*****************************************************************************/

LOCAL WORD ed_pastebuf (ed, buffer, move)
EDOBJP  ed;
VOID    *buffer;
BOOLEAN move;

{
  WORD ret, lines;
  BYTE *src;

  if (ed->bufindex == ed->bufsize) return (ED_OK);

  src   = buffer;
  lines = 0;

  while (*src)
  {
    if (*src == LF) lines++;
    src++;
  } /* while */

  if (ed->lines + lines > ed->max_lines) return (ED_2MANYLINES);

  if (ins_chars (ed, buffer, move))
    ret = ED_BUFFERCHANGED;
  else
    ret = ED_NOMEMORY;

  new_doc (ed);
  new_sliders (ed);

  return (ret);
} /* ed_pastebuf */

/*****************************************************************************/

LOCAL WORD ed_selall (ed)
EDOBJP ed;

{
  ed->sel_start = 0;
  ed->sel_end   = ed->bufsize;

  return (ED_OK);
} /* ed_selall */

/*****************************************************************************/

LOCAL WORD ed_setcurs (ed, mk)
EDOBJP ed;
MKINFO *mk;

{
  hide_mouse ();
  ed_hidecurs (ed);

  set_curs (ed, mk->mox, mk->moy);

  new_doc (ed);
  new_sliders (ed);

  ed_showcurs (ed);
  show_mouse ();

  return (ED_OK);
} /* ed_setcurs */

/*****************************************************************************/

LOCAL WORD ed_up (ed, amount)
EDOBJP ed;
WORD   amount;

{
  /* scroll text up */
  return (ED_OK);
} /* ed_up */

/*****************************************************************************/

LOCAL WORD ed_down (ed, amount)
EDOBJP ed;
WORD   amount;

{
  /* scroll text down */
  return (ED_OK);
} /* ed_down */

/*****************************************************************************/

LOCAL WORD ed_left (ed, amount)
EDOBJP ed;
WORD   amount;

{
  return (ED_OK);
} /* ed_left */

/*****************************************************************************/

LOCAL WORD ed_right (ed, amount)
EDOBJP ed;
WORD   amount;

{
  return (ED_OK);
} /* ed_right */

/*****************************************************************************/

LOCAL WORD ed_strlen (ed, line)
EDOBJP ed;
WORD   line;

{
  WORD  len;
  BYTE  *text;
  BYTE  *next;

  len = 0;

  text = ed->text + ed->line_ptr [line];
  next = ed->text + ed->line_ptr [line + 1];

  while ((*text != EOS) && (text != next))
  {
    if ((*text != CR) && (*text != LF)) len++;
    text++;
  } /* while */

  return (len);
} /* ed_strlen */

/*****************************************************************************/

LOCAL WORD ed_strwidth (ed, line)
EDOBJP ed;
WORD   line;

{
  WORD  width;
  UBYTE c;
  BYTE  *text;
  BYTE  *next;

  width = 0;

  text = ed->text + ed->line_ptr [line];
  next = ed->text + ed->line_ptr [line + 1];

  while ((*text != EOS) && (text != next))
  {
    c = (UBYTE)*text;
    if ((c != CR) && (c != LF)) width += ed->wbox [c];
    text++;
  } /* while */

  return (width);
} /* ed_strwidth */

/*****************************************************************************/

/* GS 5.1c Start: */
LOCAL WORD ed_can_uccpcs  ( EDOBJP ed, WORD message, WORD ext)
/* Ende; alt:
LOCAL WORD ed_can_uccpcs (ed, message)
EDOBJP ed;
WORD   message;
*/

{
/* GS 5.1c Start: */
	WORD ret;
  FULLNAME scrap;
/* Ende */

  switch (message)
  {
    case ED_CANUNDO   : return (FALSE);
    case ED_CANCUT    : return (ed->text [0] != EOS);
    case ED_CANCOPY   : return (ed->text [0] != EOS);
/* GS 5.1c Start: */
    case ED_CANPASTE  :
    										if ( ext )
    										{
    											ret = scrap_read ( scrap );
    											return ( ((ret & 0x02) == 0x02 ) && (ed->actsize < ed->bufsize));
    										}	
    										else
    	                  	return ((ClipboardGetData (CF_TXT) != NULL) && (ed->actsize < ed->bufsize));
/* Ende; alt: 
    case ED_CANPASTE  : return ((ClipboardGetData (CF_TXT) != NULL) && (ed->actsize < ed->bufsize));
*/
    case ED_CANCLEAR  : return (TRUE);
    case ED_CANSELALL : return (FALSE);
    default           : return (FALSE);
  } /* switch */
} /* ed_can_uccpcs */

/*****************************************************************************/

LOCAL VOID new_sliders (ed)
EDOBJP ed;

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

  window = ed->window;

  x = ed->pos.x + cx (ed) - window->doc.x * window->xfac + window->scroll.x;
  y = ed->pos.y + cy (ed) - window->doc.y * window->yfac + window->scroll.y;

  do_x = (x < window->scroll.x) || (x + ed->cell_width > window->scroll.x + window->scroll.w);
  do_y = (y < window->scroll.y) || (y + ed->hbox       > window->scroll.y + window->scroll.h);

  if (do_x || do_y)                                     /* if cursor not in window */
  {
    rel_x = ed->pos.x + cx (ed) - window->scroll.w / 2; /* cursor will centered in window */
    rel_y = ed->pos.y + cy (ed) - window->scroll.h / 2;
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

LOCAL VOID new_doc (ed)
EDOBJP ed;

{
  WINDOWP window;
  WORD    x, y, amount;
  RECT    r, old_clip;

  window   = ed->window;
  old_clip = clip;

  if (ed->flags & ED_AUTOVSCROLL)
  {
    if (cy (ed) >= ed->pos.h)           /* if cursor is beyond bottom line */
    {
      amount = (cy (ed) - ed->pos.h) / ed->hbox + 1;
      ed->doc.y += amount;

      x = ed->pos.x - window->doc.x * window->xfac + window->scroll.x;
      y = ed->pos.y - window->doc.y * window->yfac + window->scroll.y;

      xywh2rect (x, y, ed->pos.w, ed->pos.h, &r);
      rc_intersect (&window->scroll, &r);
      r.y += ed->hbox;
      r.h -= ed->hbox;

      scroll_area (&r, VERTICAL, ed->hbox);

      set_clip (TRUE, &old_clip);

      if (amount > 1)
        draw_from (ed, ed->doc.y);
      else
        draw_from (ed, ed->act_line);
    } /* if */

    if (cy (ed) < 0)                    /* if cursor is beyond top line */
    {
      amount = (ed->pos.h - cy (ed)) / ed->hbox - 1;
      ed->doc.y -= amount;

      if (ed->doc.y < 0) ed->doc.y = 0;

      if (amount > 1)
        draw_from (ed, ed->doc.y);
      else
      {
        x = ed->pos.x - window->doc.x * window->xfac + window->scroll.x;
        y = ed->pos.y - window->doc.y * window->yfac + window->scroll.y;

        xywh2rect (x, y, ed->pos.w, ed->pos.h, &r);
        rc_intersect (&window->scroll, &r);
        r.h -= ed->hbox;

        scroll_area (&r, VERTICAL, -ed->hbox);

        xywh2rect (x, y, ed->pos.w, ed->hbox, &r);
        rc_intersect (&window->scroll, &r);

        set_clip (TRUE, &r);              /* draw top line only */
        draw_from (ed, ed->act_line);
        set_clip (TRUE, &old_clip);
      } /* else */
    } /* if */
  } /* if */

  if (ed->flags & ED_AUTOHSCROLL)
  {
    amount = 0;

    if (cx (ed) >= ed->pos.w)           /* if cursor is beyond right edge */
    {
      amount = max ((cx (ed) - ed->pos.w) / ed->cell_width + 1, ed->pos.w / ed->cell_width / 2);
      if (amount == 0) amount++;
    } /* if */

    if (cx (ed) < 0)                    /* if cursor is beyond left edge */
    {
      amount = min (cx (ed) / ed->cell_width - 1, - ed->pos.w / ed->cell_width / 2);
    } /* if */

    if (amount != 0)
    {
      ed->doc.x += amount * ed->cell_width;
      if (ed->doc.x < 0) ed->doc.x = 0;

      x = ed->pos.x - window->doc.x * window->xfac + window->scroll.x;
      y = ed->pos.y - window->doc.y * window->yfac + window->scroll.y;

      xywh2rect (x, y, ed->pos.w, ed->pos.h, &r);
      rc_intersect (&window->scroll, &r);
      draw_from (ed, ed->doc.y);
    } /* if */
  } /* if */
} /* new_doc */

/*****************************************************************************/

LOCAL LONG cx (ed)
EDOBJP ed;

{
  return (ed->cx - (LONG)ed->doc.x);
} /* cx */

/*****************************************************************************/

LOCAL LONG cy (ed)
EDOBJP ed;

{
  return (ed->cy - (LONG)ed->doc.y * ed->hbox);
} /* cy */

/*****************************************************************************/

LOCAL BOOLEAN curs_left (ed)
REG EDOBJP ed;

{
  UBYTE c;

  if (ed->bufindex > 0)
  {
    ed->bufindex--;
    ed->act_col--;

    if (ed->line_ptr [ed->act_line] == ed->bufindex + 1)
    {
      ed->act_line--;
      ed->act_col  = ed_strlen (ed, ed->act_line);
      ed->cx       = ed_strwidth (ed, ed->act_line);
      ed->cy      -= ed->hbox;

      if (ed->text [ed->bufindex] == LF) ed->bufindex--;

      c = (UBYTE)ed->text [ed->bufindex];
      if (c != CR)
      {
        ed->act_col--;
        ed->cx -= ed->wbox [c];
      } /* if */
    } /* if */
    else
      ed->cx -= ed->wbox [(UBYTE)ed->text [ed->bufindex]];

    return (TRUE);
  } /* if */
  else
    return (FALSE);
} /* curs_left */

/*****************************************************************************/

LOCAL BOOLEAN curs_right (ed)
REG EDOBJP ed;

{
  BOOLEAN lf;
  BYTE    c;

  if (ed->bufindex < ed->actsize)
  {
    c  = ed->text [ed->bufindex + 1];
    lf = (c == LF) || (ed->line_ptr [ed->act_line + 1] == ed->bufindex + 1);

    if (lf && ! (ed->flags & ED_AUTOVSCROLL))
      if (ed->cy + ed->hbox >= ed->pos.h) return (FALSE);       /* don't move beyond end of object */

    ed->cx += ed->wbox [(UBYTE)ed->text [ed->bufindex]];
    ed->bufindex++;
    ed->act_col++;

    if (lf)
    {
      if (c == LF) ed->bufindex++;
      ed->act_line++;
      ed->act_col  = 0;
      ed->cx       = 0;
      ed->cy      += ed->hbox;
    } /* if */
  } /* if */
  else
    return (FALSE);

  return (TRUE);
} /* curs_right */

/*****************************************************************************/

LOCAL BOOLEAN curs_up (ed)
REG EDOBJP ed;

{
  LONG old_x;
  WORD old_line;

  if (ed->act_line > 0)
  {
    old_x    = ed->cx;
    old_line = ed->act_line;

    while (ed->act_line == old_line) curs_left (ed);
    while (ed->cx > old_x) curs_left (ed);

    return (TRUE);
  } /* if */
  else
    return (FALSE);
} /* curs_up */

/*****************************************************************************/

LOCAL BOOLEAN curs_down (ed)
REG EDOBJP ed;

{
  LONG old_x;
  WORD old_line, old_col;
  WORD len;

  if (! (ed->flags & ED_AUTOVSCROLL))
    if (ed->cy + ed->hbox >= ed->pos.h) /* don't move beyond end of object */
    {
      if (ed->pos.h > ed->hbox) beep ();
      return (FALSE);
    } /* if, if */

  if (ed->act_line + 1 < ed->lines)
  {
    old_x    = ed->cx;
    old_line = ed->act_line;
    old_col  = ed->act_col;
    len      = ed_strlen (ed, ed->act_line + 1);

    while (ed->act_line == old_line) curs_right (ed);

    if (old_col >= len)
      curs_end (ed);
    else
      while ((ed->cx < old_x) && (ed->act_col < len) && curs_right (ed));

    return (TRUE);
  } /* if */
  else
    return (FALSE);
} /* curs_down */

/*****************************************************************************/

LOCAL VOID curs_pgup (ed)
REG EDOBJP ed;

{
  WORD lines;

  if (ed->flags & ED_USEPOS)
    lines = ed->pos.h / ed->hbox;
  else
    lines = ed->window->scroll.h / ed->hbox;

  while ((lines > 0) && curs_up (ed)) lines--;
} /* curs_pgup */

/*****************************************************************************/

LOCAL VOID curs_pgdown (ed)
REG EDOBJP ed;

{
  WORD lines;

  if (ed->flags & ED_USEPOS)
    lines = ed->pos.h / ed->hbox;
  else
    lines = ed->window->scroll.h / ed->hbox;

  while ((lines > 0) && curs_down (ed)) lines--;
} /* curs_pgdown */

/*****************************************************************************/

LOCAL VOID curs_pos1 (ed)
REG EDOBJP ed;

{
  while (ed->cx > 0) curs_left (ed);
} /* curs_pos1 */

/*****************************************************************************/

LOCAL VOID curs_end (ed)
REG EDOBJP ed;

{
  BOOLEAN ok;
  WORD    old_line;

  if (ed->act_line + 1 < ed->lines)
  {
    old_line = ed->act_line;
    ok       = TRUE;

    while ((ed->act_line == old_line) && ok) ok = curs_right (ed);
    if (ok) curs_left (ed);
  } /* if */
  else                          /* single line or last line */
    while (curs_right (ed));
} /* curs_end */

/*****************************************************************************/

LOCAL VOID curs_docstart (ed)
REG EDOBJP ed;

{
  BOOLEAN bRedraw;

  bRedraw = ed->cy >= ed->pos.h;	/* is cursor beyond bottom line? */

  ed_init (ed, NULL);
  if (bRedraw) ed_draw (ed);
} /* curs_docstart */

/*****************************************************************************/

LOCAL VOID curs_docend (ed)
REG EDOBJP ed;

{
  while ((ed->act_line < ed->lines - 1) && curs_down (ed));

  curs_end (ed);
} /* curs_docend */

/*****************************************************************************/

LOCAL VOID next_word (ed)
REG EDOBJP ed;

{
  WORD act_line;

  act_line = ed->act_line;

  while ((ed->text [ed->bufindex] != ' ') && curs_right (ed) && (act_line == ed->act_line));
  while ((ed->text [ed->bufindex] == ' ') && curs_right (ed));
} /* next_word */

/*****************************************************************************/

LOCAL VOID prev_word (ed)
REG EDOBJP ed;

{
  WORD act_line;


  curs_left (ed);
  while ((ed->text [ed->bufindex] == ' ') && curs_left (ed));

  act_line = ed->act_line;

  if (ed->bufindex == 0) return;
  while ((ed->text [ed->bufindex] != ' ') && curs_left (ed) && (act_line == ed->act_line));

  if ((ed->act_line < act_line) ||
      (ed->text [ed->bufindex] == ' ')) curs_right (ed);
} /* prev_word */

/*****************************************************************************/

LOCAL VOID set_curs (ed, x, y)
EDOBJP ed;
WORD   x, y;

{
  WORD w;
  WORD col, line;

  col  = x;
  line = y;

  if (line < 0) line = 0;
  if (line >= ed->lines) line = ed->lines - 1;

  ed->cx       = 0;
  ed->cy       = line * (LONG)ed->hbox;
  ed->act_line = line;
  ed->act_col  = 0;
  ed->bufindex = ed->line_ptr [line];

  w = ed_strlen (ed, line);
  if (col < 0) col = 0;

  if (col >= w)
    curs_end (ed);
  else
    while (col-- > 0) curs_right (ed);
} /* set_curs */

/*****************************************************************************/

LOCAL BOOLEAN ins_chars (ed, buffer, move)
EDOBJP  ed;
BYTE    *buffer;
BOOLEAN move;

{
  WORD    x, y, i, lines, col;
  WORD    wchar, hchar;
  WORD    wbox, hbox;
  WORD    old_width, line;
  RECT    old_clip, r;
  LONG    len, buflen, curs_y, bufindex;
  LONGSTR s, next;
  WINDOWP window;
  BYTE    *dst, *src;

  old_width = ed_strwidth (ed, ed->act_line);
  buflen    = strlen (buffer);

  if (ed->bufindex == ed->bufsize) return (FALSE);
  if (ed->bufsize < buflen) return (FALSE);

  if (ed->actsize + buflen > ed->bufsize)       /* delete last 'buflen' characters */
  {
    ed->actsize -= buflen;

    if (ed->text [ed->actsize] == LF) ed->actsize--;    /* delete also CR */
    if (ed->actsize < 0) return (FALSE);        /* doesn't fit into buffer */

    ed->text [ed->actsize] = EOS;
  } /* if */

  if (ed->actsize + buflen <= ed->bufsize)
  {
    bufindex  = ed->bufindex;
    curs_y    = ed->cy;
    get_line (ed, ed->act_line + 1, next);

    if (ed->flags & ED_WORDBREAK)               /* move back for cursor positioning */
    {
      curs_pos1 (ed);
      curs_left (ed);
    } /* if */

    src = ed->text + bufindex;
    dst = src + buflen;
    len = ed->actsize - bufindex + 1;           /* move also EOS char */
    mem_lmove (dst, src, len);
    mem_lmove (src, buffer, buflen);            /* insert buffer */

    for (len = lines = 0; len < buflen; len++)
      if (buffer [len] == LF) lines++;

    ed->actsize += buflen;
    ed->lines   += lines;
    len          = buflen - lines;

    if ((ed->flags & ED_WORDBREAK) || (lines > 0))
      set_lptr (ed, ed->act_line);
    else                                        /* do it faster */
      for (i = ed->act_line + 1; i < ed->lines; i++) ed->line_ptr [i] += len;

    if (ed->flags & ED_WORDBREAK)               /* move forward to cursor position */
      while ((ed->bufindex < bufindex) && curs_right (ed));

    window = ed->window;

    x = ed->pos.x - window->doc.x * window->xfac + window->scroll.x;
    y = ed->pos.y - window->doc.y * window->yfac + window->scroll.y;

    xywh2rect (x, y, ed->pos.w, ed->pos.h, &r);

    if (rc_intersect (&clip, &r))
    {
      text_default (vdi_handle);
      vst_font (vdi_handle, ed->font);
      vst_point (vdi_handle, ed->point, &wchar, &hchar, &wbox, &hbox);
      vst_color (vdi_handle, ed->color);

      x += cx (ed);
      y += cy (ed);

      old_clip = clip;
      set_clip (TRUE, &r);

      if ((ed->cy != curs_y) || (ed_strwidth (ed, ed->act_line) < old_width))        /* wordbreak has happened */
      {
        line = ed->act_line;

        if (ed->cy != curs_y) line--;
        if (line < 0) line = 0;

        draw_from (ed, line);
      } /* if */
      else
      {
        get_line (ed, ed->act_line, s);
        v_gtext (vdi_handle, x, y, &s [ed->act_col]);

        get_line (ed, ed->act_line + 1, s);
        if ((lines > 0) || (strcmp (s, next) != 0)) draw_from (ed, ed->act_line + 1);
      } /* else */

      set_clip (TRUE, &old_clip);
    } /* if */

    if (move)
      if (lines > 0)
      {
        buffer = buffer + buflen;
        col    = 0;
        while (*buffer-- != LF) col++;

        set_curs (ed, col - 1, ed->act_line + lines);
      } /* if */
      else
        for (len = 0; len < buflen - lines; len++) curs_right (ed);
  } /* if */
  else
  {
    beep ();
    return (FALSE);
  } /* else */

  return (TRUE);
} /* ins_chars */

/*****************************************************************************/

LOCAL BOOLEAN del_char (ed, draw)
EDOBJP  ed;
BOOLEAN draw;

{
  BOOLEAN draw_all;
  WORD    x, y, i;
  WORD    wchar, hchar;
  WORD    wbox, hbox;
  WORD    bl_box, ch_box;
  WORD    line;
  RECT    old_clip, r;
  LONG    len, curs_y, bufindex;
  UBYTE   c;
  LONGSTR s, newnext, next;
  WINDOWP window;
  BYTE    *dst, *src;

  if (ed->bufindex < ed->actsize)
  {
    draw_all = FALSE;
    bufindex = ed->bufindex;
    curs_y   = ed->cy;
    line     = ed->act_line;
    get_line (ed, ed->act_line + 1, next);

    if (ed->flags & ED_WORDBREAK)       /* move back for cursor positioning */
    {
      curs_pos1 (ed);
      curs_left (ed);
    } /* if */

    src = ed->text + bufindex + 1;
    len = ed->actsize - bufindex;
    dst = src - 1;
    c   = (UBYTE)*dst;

    if ((c == CR) || (c == LF))
    {
      draw_all = TRUE;
      src++;
      len--;

      ed->lines--;
      ed->actsize--;
      ed->line_ptr [ed->lines] = -1;
    } /* if */

    mem_lmove (dst, src, len);
    ed->actsize--;

    if ((ed->flags & ED_WORDBREAK) || (c == CR) || (c == LF))
      set_lptr (ed, ed->act_line);
    else                                /* do it faster */
      for (i = ed->act_line + 1; i < ed->lines; i++) ed->line_ptr [i]--;

    if (ed->flags & ED_WORDBREAK)       /* move forward to cursor position */
    {
      while ((ed->bufindex < bufindex) && curs_right (ed));
      if ((c == CR) || (ed->cy < curs_y)) line--;
      if (line < 0) line = 0;
    } /* if */

    window = ed->window;

    x = ed->pos.x - window->doc.x * window->xfac + window->scroll.x;
    y = ed->pos.y - window->doc.y * window->yfac + window->scroll.y;

    xywh2rect (x, y, ed->pos.w, ed->pos.h, &r);

    if (rc_intersect (&clip, &r) && draw)
    {
      text_default (vdi_handle);
      vst_font (vdi_handle, ed->font);
      vst_point (vdi_handle, ed->point, &wchar, &hchar, &wbox, &hbox);
      vst_color (vdi_handle, ed->color);

      x += cx (ed);
      y += cy (ed);

      old_clip = clip;
      set_clip (TRUE, &r);

      get_line (ed, ed->act_line, s);

      bl_box = ed->wbox [' '];
      ch_box = ed->wbox [c];

      while (ch_box > 0)
      {
        strcat (s, " ");
        ch_box -= bl_box;
      } /* while */

      get_line (ed, ed->act_line + 1, newnext);
      if (draw_all || (strcmp (newnext, next) != 0) || (ed->cy != curs_y))
        draw_from (ed, line);
      else
        v_gtext (vdi_handle, x, y, &s [ed->act_col]);

      set_clip (TRUE, &old_clip);
    } /* if */
  } /* if */
  else
    return (FALSE);

  return (TRUE);
} /* del_char */

/*****************************************************************************/

LOCAL BOOLEAN del_line (ed)
EDOBJP ed;

{
  BOOLEAN ok, cr;
  WORD    len;
  LONG    lSize;
  LONGSTR s;
  CHAR    *pClipBuffer;

  ok = FALSE;

  cr = get_line (ed, ed->act_line, s);		/* copy to clipboard */
  if (cr) strcat (s, "\r\n");
  lSize = strlen (s) + 1;			/* including EOS */

  pClipBuffer = mem_alloc (lSize);
  if (pClipBuffer != NULL)
  {
    strcpy (pClipBuffer, s);
    ClipboardSetData (CF_TXT, pClipBuffer);
    ClipboardSetSize (CF_TXT, lSize);
  } /* if */

  curs_pos1 (ed);
  for (len = ed_strlen (ed, ed->act_line); len > 0; len--) ok |= del_char (ed, FALSE);

  if (ed->text [ed->bufindex] == CR) ok |= del_char (ed, FALSE);
  if (ed->text [ed->bufindex] == LF) ok |= del_char (ed, FALSE);

  draw_from (ed, ed->act_line);

  return (ok);
} /* del_line */

/*****************************************************************************/

LOCAL VOID set_lptr (ed, start)
EDOBJP ed;
WORD   start;

{
  BOOLEAN cr;
  WORD    end, lines, i;
  WORD    max_w, cols;
  LONG    index;
  LONGSTR s;
  BYTE    *text;

  ed->line_ptr [0] = 0;

  end       = start - 1;
  index     = ed->line_ptr [start];
  text      = ed->text + index;
  max_w     = ed->pos.w;
  lines     = ed->lines;
  ed->lines = start;

  while (*text != EOS)
  {
    end++;
    ed->lines++;
    ed->line_ptr [end] = index;
    text   = next_line (max_w, text, s, ed->wbox, &cols, &cr, ed->flags & ED_WORDBREAK);
    index += cols;
  } /* while */

  if (cr)
  {
    end++;
    ed->lines++;
    ed->line_ptr [end] = index;
  } /* if */

  if (ed->lines == 0) ed->lines = 1;

  ed->doc.h = ed->lines;

  for (i = end + 1; i < lines; i++) ed->line_ptr [i] = -1;
} /* set_lptr */

/*****************************************************************************/

LOCAL VOID draw_from (ed, start)
EDOBJP ed;
WORD   start;

{
  WORD    i;
  WORD    x, y;
  WORD    wchar, hchar, wbox, hbox;
  RECT    area, old_clip, r;
  LONGSTR line;
  WINDOWP window;

  window = ed->window;

  area    = ed->pos;
  area.x += window->scroll.x - window->doc.x * window->xfac;
  area.y += window->scroll.y - window->doc.y * window->yfac;

  old_clip  = clip;
  r         = area;
  r.y      += (start - ed->doc.y) * ed->hbox;
  r.h      -= (start - ed->doc.y) * ed->hbox;

  if (rc_intersect (&clip, &r))
  {
    set_clip (TRUE, &r);
    rc_intersect (&window->scroll, &r);
    start = (r.y - area.y) / ed->hbox;

    x = area.x - ed->doc.x;             /* x-coordinate for all lines */
    y = area.y + start * ed->hbox;      /* y-coordinate for first line */

    clr_area (&r);                      /* clear from starting line */
    if (start >= ed->lines) return;

    text_default (vdi_handle);
    vst_font (vdi_handle, ed->font);
    vst_point (vdi_handle, ed->point, &wchar, &hchar, &wbox, &hbox);
    vst_color (vdi_handle, ed->color);

    for (i = ed->doc.y + start; (y < clip.y + clip.h) && (i < ed->doc.h); i++, y += ed->hbox)
    {
      get_line (ed, i, line);
/*      line [ed->doc.x + w] = EOS;*/
/*      if (y + window->yfac > clip.y)*/
        if (ed_strwidth (ed, i) > ed->doc.x)
          v_text (vdi_handle, x, y, line);
    } /* for */

    set_clip (TRUE, &old_clip);
  } /* if */
} /* draw_from */

/*****************************************************************************/

LOCAL BOOLEAN get_line (ed, line, buffer)
REG EDOBJP ed;
REG WORD   line;
REG BYTE   *buffer;

{
  BOOLEAN cr;
  WORD    cols;
  BYTE    *text;

  buffer [0] = EOS;

  if (ed->line_ptr [line] == -1) return (FALSE);

  text = ed->text + ed->line_ptr [line];
  text = next_line (ed->pos.w, text, buffer, ed->wbox, &cols, &cr, ed->flags & ED_WORDBREAK);

  return (cr);
} /* get_line */

/*****************************************************************************/

LOCAL BYTE *next_line (width, p, s, wbox, chars, cr, wordbreak)
WORD    width;
WORD    *wbox;
WORD    *chars;
BYTE    *p;
BYTE    *s;
BOOLEAN *cr;
BOOLEAN wordbreak;

{
  WORD  w, i, blank;
  UBYTE c;
  LONG  org;

  w     = 0;
  i     = 0;
  c     = ' ';
  blank = 0;
  org   = (LONG)p;
  *s    = EOS;

  if (wordbreak)
  {
    while (*p && (*p != CR) && (w < width) && (i < LONGSTRLEN))
    {
      c   = (UBYTE)*p;
      *s  = *p;
      w  += wbox [c];

      if (w < width)
      {
        if (c == SP) blank = i;

        p++;
        s++;
        i++;
      } /* if */
    } /* while */

    if ((w >= width) && (blank > 0))
    {
     p -= i - blank - 1;
     s -= i - blank - 1;
    } /* if */
  } /* if */
  else
  {
    while (*p && (*p != CR) && (i < LONGSTRLEN))
    {
      *s++ = *p++;
      i++;
    } /* while */
  } /* else */

  if (*p == CR)
  {
   p   += 2;
   *cr  = TRUE;
  } /* if */
  else
    *cr = FALSE;

  *s     = EOS;
  *chars = (LONG)p - org;

  return (p);
} /* next_line */

/*****************************************************************************/

LOCAL VOID get_wboxes (boxes, low, high)
WORD   *boxes;
WORD   low;
WORD   high;

{
  WORD c;
  WORD cell_width;
  WORD *wboxes;

  wboxes = &boxes [low];

  for (c = low; c <= high; c++, wboxes++)
  {
#if GEMDOS                      /* error in TURBO_C on ATARI ST */
    intin [0]  = c;
    contrl [0] = 117;
    contrl [1] = 0;
    contrl [3] = 1;
    contrl [6] = vdi_handle;

    vdi ();

    cell_width = ptsout [0];
#else
    {
      WORD r;
      vqt_width (vdi_handle, (BYTE)c, &cell_width, &r, &r);
    }
#endif

    *wboxes = cell_width;
  } /* for */

  cell_width = boxes [SP];      /* use blank for undefined control chars */
  wboxes     = boxes;
  for (c = 0; c < ' '; c++) wboxes [c] = cell_width;
} /* get_wboxes */


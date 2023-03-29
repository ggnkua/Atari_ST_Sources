/*****************************************************************************/
/*                                                                           */
/* Modul: POPUP.C                                                            */
/* Datum: 23/04/93                                                           */
/*                                                                           */
/*****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "export.h"
#include "popup.h"

/****** DEFINES **************************************************************/

#define POPUP_SLIDEBAR  1
#define POPUP_PARENT    2
#define POPUP_SLIDER    3
#define POPUP_UP        4
#define POPUP_DOWN      5

#define DRAW_ALL        0
#define DRAW_ITEMS      1
#define DRAW_SLIDERS    2
#define DRAW_SLIDER     3

#define WAIT_CLICK      0
#define WAIT_TRACK      1
#define WAIT_SCROLL     2
#define WAIT_SLIDER     3

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL WORD calc_pos      _((POP pop));
LOCAL WORD calc_size     _((POP pop));
LOCAL LONG calc_first    _((POP pop, WORD slide_value));
LOCAL VOID draw_popup    _((POP pop, WORD which, WORD from, WORD to));
LOCAL LONG find_item     _((POP pop, WORD mox, WORD moy, BOOLEAN scroll, WORD *dir));
LOCAL WORD find_slider   _((POP pop, WORD mox, WORD moy));
LOCAL LONG hndl_keyboard _((POP pop, MKINFO *mk));
LOCAL VOID hndl_slider   _((POP pop, MKINFO *mk, WORD slider));
LOCAL LONG hndl_scroll   _((POP pop, MKINFO *mk, LONG olditem, LONG item));
LOCAL VOID hndl_arrows   _((POP pop, WORD dir, WORD x, WORD y));
LOCAL VOID scroll        _((POP pop, LONG old_pos, LONG new_pos));
LOCAL VOID change_item   _((POP pop, LONG item));
LOCAL WORD slide_box     _((POP pop));
LOCAL VOID draw_box      _((RECT *box));
LOCAL VOID fix_box       _((RECT *box, RECT *bound));

/*****************************************************************************/

GLOBAL BOOLEAN init_popup ()

{
  return (TRUE);
} /* init_popup */

/*****************************************************************************/

GLOBAL BOOLEAN term_popup ()

{
  return (TRUE);
} /* term_popup */

/*****************************************************************************/

GLOBAL LONG hndl_popup (pop, message, s)
POP   pop;
UWORD message;
BYTE  *s;

{
  BOOLEAN    ready;
  REG OBJECT *tree;
  LONG       max_pos;
  WORD       mode, slider;
  MFDB       screen, buffer;
  LONG       item, olditem, selected;
  WORD       dir, ret, diff;
  MKINFO     mk;
  UWORD      event, events;
  RECT       r;
  WORD       act_number;
  MFORM      *act_form;

  tree = pop->tree;

  if (message & POPUP_INIT)
  {
    if (pop->selected >= pop->num_items) pop->selected = pop->num_items - 1;

    pop->vis_items  = pop->height / pop->char_height;
    pop->first_item = pop->selected;
    max_pos         = pop->num_items - pop->vis_items;

    if (pop->first_item > max_pos) pop->first_item = max_pos;
    if (pop->first_item < 0) pop->first_item = 0;

    tree->ob_x      = pop->x;
    tree->ob_y      = pop->y;
    tree->ob_width  = pop->width;
    tree->ob_height = pop->height;

    if (pop->v_slider)
    {
      tree->ob_width += tree [POPUP_SLIDEBAR].ob_width;
      undo_flags (tree, POPUP_SLIDEBAR, HIDETREE);

      tree [POPUP_SLIDEBAR].ob_x      = tree->ob_width - tree [POPUP_SLIDEBAR].ob_width;
      tree [POPUP_SLIDEBAR].ob_height = tree->ob_height;
      tree [POPUP_PARENT].ob_y        = tree [POPUP_SLIDEBAR].ob_y + tree [POPUP_UP].ob_height + 1;
      tree [POPUP_PARENT].ob_height   = tree [POPUP_SLIDEBAR].ob_height - 2 * (tree [POPUP_UP].ob_height + 1);
      tree [POPUP_DOWN].ob_y          = tree [POPUP_SLIDEBAR].ob_height - tree [POPUP_DOWN].ob_height;
      tree [POPUP_SLIDER].ob_height   = calc_size (pop);
      tree [POPUP_SLIDER].ob_y        = calc_pos (pop);
    } /* if */
    else
      do_flags (tree, POPUP_SLIDEBAR, HIDETREE);

    objc_rect (tree, ROOT, &r, FALSE);          /* RÑnder berÅcksichtigen */

    diff = r.x + r.w - (desk.x + desk.w);       /* Rechts heraushÑngend ? */
    if (diff > 0) tree->ob_x -= diff;

    diff = r.y + r.h - (desk.y + desk.h);       /* Unten heraushÑngend ? */
    if (diff > 0)
    {
      objc_rect (tree, ROOT, &r, TRUE);
      tree->ob_y = pop->y_alt - r.h;            /* Alternative wÑhlen */
    } /* if */

    objc_rect (tree, ROOT, &r, FALSE);          /* RÑnder berÅcksichtigen */

    diff = r.x - desk.x;                        /* Links heraushÑngend ? */
    if (diff < 0) tree->ob_x -= diff;

    diff = r.y - desk.y;                        /* Oben heraushÑngend ? */
    if (diff < 0) tree->ob_y -= diff;

    pop->x = tree->ob_x;
    pop->y = tree->ob_y;
  } /* if */

  if (message & POPUP_DRAW)
  {
    act_number = mousenumber;
    act_form   = mouseform;

    graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);
    background (tree, ROOT, TRUE, &screen, &buffer);
    draw_popup (pop, DRAW_ALL, 0, pop->vis_items - 1);

    hide_mouse ();
    (*pop->popfunc) (pop, POPUP_CHANGED, pop->selected, NULL);
    show_mouse ();

    mode = (mk.mobutton & pop->bmsk) ? WAIT_TRACK : WAIT_CLICK;

    s [0]  = EOS;
    item   = selected = pop->selected;
    ready  = FALSE;
    slider = NIL;

    set_mouse (ARROW, NULL);
    wind_update (BEG_MCTRL);                    /* Mauskontrolle Åbernehmen */

    do
    {
      events = MU_BUTTON;

      if (mode == WAIT_CLICK) events |= MU_KEYBD;

      if (mode == WAIT_TRACK)
      {
        events |= MU_M1;
        objc_rect (tree, ROOT, &r, FALSE);
        r.h = (WORD)min (pop->num_items, (LONG)pop->vis_items) * pop->char_height;
        if (pop->v_slider) r.w -= tree [POPUP_SLIDEBAR].ob_width + 1;
      } /* if */

      event = evnt_multi (events,
                          1, pop->bmsk, ~ mk.mobutton & pop->bmsk,
                          FALSE, r.x, r.y, r.w, r.h,
                          0, 0, 0, 0, 0,
                          NULL, 0, 0,
                          &mk.mox, &mk.moy,
                          &mk.momask, &mk.kstate,
                          &mk.kreturn, &mk.breturn);

      graf_mkstate (&ret, &ret, &mk.mobutton, &mk.kstate); /* Werte nach Ereignis */

#if MSDOS
      if (mk.momask == 0x0000) mk.momask = 0x0001;      /* Irgendein Knopf ist linker Knopf */
#endif

      mk.shift  = (mk.kstate & (K_RSHIFT | K_LSHIFT)) != 0;
      mk.ctrl   = (mk.kstate & K_CTRL) != 0;
      mk.alt    = (mk.kstate & K_ALT) != 0;
      olditem   = item;

      if (mode == WAIT_CLICK)
        slider = (event & MU_BUTTON) ? find_slider (pop, mk.mox, mk.moy) : NIL;

      if (slider != NIL)
        mode = WAIT_SLIDER;
      else
        item = find_item (pop, mk.mox, mk.moy, FALSE, &dir);

      if (event & MU_BUTTON)
        switch (mode)
        {
          case WAIT_CLICK  : if (item == NIL)
                             {
                               if (pop->mandatory) item = selected;
                               ready = TRUE;
                             } /* if */
                             else
                               if (mk.mobutton & pop->bmsk)
                                 mode = WAIT_SCROLL;
                               else
                                 ready = TRUE;
                             break;
          case WAIT_TRACK  : mode = WAIT_CLICK;
                             item = olditem;
                             break;
          case WAIT_SCROLL : break;
          case WAIT_SLIDER : mode = WAIT_CLICK;
                             hndl_slider (pop, &mk, slider);
                             break;
        } /* switch, if */

      if (event & MU_KEYBD)
      {
        item = hndl_keyboard (pop, &mk);

        if ((mk.ascii_code == CR) || (mk.ascii_code == ESC) || (mk.scan_code == UNDO)) ready = TRUE;

        if ((mk.ascii_code == ESC) || (mk.scan_code == UNDO))
          if (pop->mandatory) item = selected;
      } /* if */

      if (event & MU_M1)
        if (item != NIL) mode = WAIT_SCROLL;

      if (pop->mandatory)
        if (item == NIL) item = olditem;        /* etwas ist immer ausgewÑhlt */

      if (mode == WAIT_SCROLL)
      {
        item  = hndl_scroll (pop, &mk, olditem, item);
        ready = TRUE;
      } /* if */
      else
        if (event & MU_BUTTON)                  /* nicht bei Tastatur */
          if (olditem != item)
          {
            if (olditem != NIL) change_item (pop, olditem);
            if (item != NIL) change_item (pop, item);
          } /* if, if, else */
    } while (! ready);

    pop->selected = item;

    wind_update (END_MCTRL);                    /* Mauskontrolle wieder abgeben */
    graf_mouse (act_number, act_form);

    background (tree, ROOT, FALSE, &screen, &buffer);

    if (pop->selected != NIL)
    {
      (*pop->popfunc) (pop, POPUP_GETLINE, pop->selected, NULL);
      strcpy (s, pop->itemstr);
    } /* if */
  } /* if */

  return (pop->selected);
} /* hndl_popup */

/*****************************************************************************/

LOCAL WORD calc_pos (pop)
POP pop;

{
  WORD pos;
  LONG max_pos, value;

  max_pos = pop->num_items - pop->vis_items;

  if (max_pos <= 0)
    pos = 0;
  else
    if (pop->num_items < 1000)
    {
      value = (1000L * (LONG)pop->first_item * (pop->tree [POPUP_PARENT].ob_height - pop->tree [POPUP_SLIDER].ob_height)) / max_pos;
      pos   = (WORD)(value / 1000);
      if (value % 1000 >= 500) pos++;
    } /* if */
    else
    {
      value = ((LONG)pop->first_item * (pop->tree [POPUP_PARENT].ob_height - pop->tree [POPUP_SLIDER].ob_height)) / max_pos;
      pos   = (WORD)value;
    } /* else, else */

  return (pos);
} /* calc_pos */

/*****************************************************************************/

LOCAL WORD calc_size (pop)
POP pop;

{
  WORD size;

  size = pop->tree [POPUP_PARENT].ob_height;

  if ((pop->num_items > 0) && (pop->vis_items <= pop->num_items))
    size = (WORD)((size * pop->vis_items) / pop->num_items);

  if (size < gl_hbox) size = gl_hbox;

  return (size);
} /* calc_size */

/*****************************************************************************/

LOCAL LONG calc_first (pop, slide_value)
POP  pop;
WORD slide_value;

{
  LONG first, max_pos;
  LONG value;

  max_pos = pop->num_items - pop->vis_items;

  if (max_pos < 0) max_pos = 0;

  value = max_pos * slide_value;
  first = value / 1000;
  if (value % 1000 >= 500) first++;

  return (first);
} /* calc_first */

/*****************************************************************************/

LOCAL VOID draw_popup (pop, which, from, to)
POP  pop;
WORD which, from, to;

{
  WORD   char_width, char_height, cell_width, cell_height;
  WORD   obj, i, y;
  RECT   r;
  OBJECT *tree;

  tree = pop->tree;

  switch (which)
  {
    case DRAW_ALL     : objc_rect (tree, ROOT, &r, TRUE);
                        obj = ROOT;
                        break;
    case DRAW_ITEMS   : objc_rect (tree, ROOT, &r, FALSE);
                        if (pop->v_slider) r.w -= tree [POPUP_SLIDEBAR].ob_width + 1;
                        r.y += from * pop->char_height;
                        r.h  = (to - from + 1) * pop->char_height;
                        obj  = ROOT;
                        break;
    case DRAW_SLIDERS : objc_rect (tree, POPUP_SLIDEBAR, &r, TRUE);
                        obj = POPUP_SLIDEBAR;
                        break;
    case DRAW_SLIDER  : objc_rect (tree, POPUP_PARENT, &r, TRUE);
                        obj = POPUP_PARENT;
                        break;
  } /* switch */

  hide_mouse ();
  set_clip (TRUE, &r);

  if (which == DRAW_ITEMS)
    clr_area (&r);
  else
    if (pop->v_slider || (which != DRAW_SLIDERS) && (which != DRAW_SLIDER))
      objc_draw (tree, obj, MAX_DEPTH, r.x, r.y, r.w, r.h);

  if ((which == DRAW_ALL) || (which == DRAW_ITEMS))
  {
    objc_rect (tree, ROOT, &r, FALSE);
    if (pop->v_slider) r.w -= tree [POPUP_SLIDEBAR].ob_width + 1;
    set_clip (TRUE, &r);
                        
    text_default (vdi_handle);
    vst_font (vdi_handle, pop->font);
    vst_point (vdi_handle, pop->point, &char_width, &char_height, &cell_width, &cell_height);
    vst_color (vdi_handle, pop->color);

    for (i = 0, y = pop->y; i < pop->vis_items; i++, y += pop->char_height)
      if (pop->first_item + i < pop->num_items)
        if ((from <= i) && (i <= to))
        {
          (*pop->popfunc) (pop, POPUP_GETLINE, pop->first_item + i, NULL);
          v_gtext (vdi_handle, pop->x + pop->x_offset, y + pop->y_offset, pop->itemstr);

          if (pop->first_item + i == pop->selected)
          {
            change_item (pop, pop->selected);
            set_clip (TRUE, &r);                /* change_item setzt clipping */
            vswr_mode (vdi_handle, MD_REPLACE);
          } /* if */
        } /* if, if, for */
  } /* if */

  show_mouse ();
} /* draw_popup */

/*****************************************************************************/

LOCAL LONG find_item (pop, mox, moy, scroll, dir)
POP     pop;
WORD    mox, moy;
BOOLEAN scroll;
WORD    *dir;

{
  LONG   item;
  OBJECT *tree;

  tree = pop->tree;
  item = objc_find (tree, ROOT, MAX_DEPTH, mox, moy);
  *dir = FAILURE;

  if (item >= POPUP_SLIDEBAR)
    item = NIL;
  else
  {
    if (item == ROOT) item = pop->first_item + (moy - pop->y) / pop->char_height;

    if (item >= pop->num_items) item = NIL;

    if (scroll)
      if (moy < tree->ob_y)
      {
        if (pop->first_item > 0) *dir = POPUP_UP;
        if (pop->mandatory) item = max (0, pop->first_item - 1);
      } /* if */
      else
        if (moy >= tree->ob_y + tree->ob_height)
        {
          if (pop->first_item + pop->vis_items < pop->num_items) *dir = POPUP_DOWN;
          if (pop->mandatory) item = min (pop->first_item + pop->vis_items, pop->num_items - 1);
        } /* if, else */
  } /* else */

  return (item);
} /* find_item */

/*****************************************************************************/

LOCAL WORD find_slider (pop, mox, moy)
POP  pop;
WORD mox, moy;

{
  WORD   item;
  OBJECT *tree;

  tree = pop->tree;
  item = objc_find (tree, ROOT, MAX_DEPTH, mox, moy);

  if (item < POPUP_SLIDEBAR)
    item = NIL;
  else
    if (item == POPUP_SLIDEBAR) item = POPUP_PARENT; /* Grenzbereich */

  return (item);
} /* find_slider */

/*****************************************************************************/

LOCAL LONG hndl_keyboard (pop, mk)
POP    pop;
MKINFO *mk;

{
  LONG item, olditem, diff;

  item           = olditem = pop->selected;
  mk->ascii_code = mk->kreturn & 0x00FF;
  mk->scan_code  = mk->kreturn >> 8;

#if GEMDOS
  if ((mk->scan_code >= 71) && (mk->scan_code <= 82) && /* Shift-Pfeile */
      (mk->scan_code != 74) && (mk->scan_code != 78)) mk->ascii_code = 0;
#endif

  mk->kreturn = (mk->scan_code << 8) | mk->ascii_code;

  if (mk->ascii_code == CR) return (pop->selected);
  if ((mk->ascii_code == ESC) || (mk->scan_code == UNDO)) return (NIL);

  if (mk->shift && (mk->ascii_code == 0))
    switch (mk->scan_code)
    {
      case UP       :
      case LEFT     : mk->scan_code = PGUP;   break;
      case RIGHT    :
      case DOWN     : mk->scan_code = PGDOWN; break;
      case CLR_HOME : mk->scan_code = ENDKEY; break;
    } /* switch, if */

  if (mk->ascii_code == 0)
    switch (mk->scan_code)
    {
      case UP     :
      case LEFT   : item--;                     break;
      case RIGHT  :
      case DOWN   : item++;                     break;
      case PGUP   : item -= pop->vis_items - 1; break;
      case PGDOWN : item += pop->vis_items - 1; break;
      case POS1   : item = 0;                   break;
      case ENDKEY : item = pop->num_items - 1;  break;
      default     : return (item);
    } /* switch, if */
  else
    item = (*pop->popfunc) (pop, POPUP_KEYPRESS, pop->selected, mk);

  if (item < 0) item = 0;
  if (item >= pop->num_items) item = pop->num_items - 1;

  diff = item - pop->selected;

  if (diff != 0)
  {
    change_item (pop, pop->selected);

    pop->selected = item;

    if ((pop->first_item <= item) && (item < pop->first_item + pop->vis_items))
      change_item (pop, item);
    else
      if (item < olditem)
        scroll (pop, pop->first_item, item);
      else
        scroll (pop, pop->first_item, item - pop->vis_items + 1);

    hide_mouse ();
    (*pop->popfunc) (pop, POPUP_CHANGED, pop->selected, NULL);
    show_mouse ();
  } /* if */
  else
    if ((pop->selected < pop->first_item) || (pop->selected >= pop->first_item + pop->vis_items))
      if (item < olditem)
        scroll (pop, pop->first_item, item);
      else
        scroll (pop, pop->first_item, item - pop->vis_items + 1);

  return (item);
} /* hndl_keybd */

/*****************************************************************************/

LOCAL VOID hndl_slider (pop, mk, slider)
POP    pop;
MKINFO *mk;
WORD   slider;

{
  do
  {
    hndl_arrows (pop, slider, mk->mox, mk->moy);
    graf_mkstate (&mk->mox, &mk->moy, &mk->mobutton, &mk->kstate);
    slider = find_slider (pop, mk->mox, mk->moy);
  } while (mk->mobutton & pop->bmsk);
} /* hndl_slider */

/*****************************************************************************/

LOCAL LONG hndl_scroll (pop, mk, olditem, item)
POP    pop;
MKINFO *mk;
LONG   olditem, item;

{
  WORD dir;

  if (olditem != item)
  {
    if (olditem != NIL) change_item (pop, olditem);
    if (item != NIL) change_item (pop, item);
  } /* if */

  do
  {
    olditem = item;
    item    = find_item (pop, mk->mox, mk->moy, TRUE, &dir);

    if (pop->mandatory)
      if (item == NIL) item = olditem;          /* etwas ist immer ausgewÑhlt */

    if (olditem != item)
      if (olditem != NIL) change_item (pop, olditem);

    pop->selected = item;
    hndl_arrows (pop, dir, mk->mox, mk->moy);

    if (dir == FAILURE)
      if (olditem != item)
        if (item != NIL) change_item (pop, item);

    graf_mkstate (&mk->mox, &mk->moy, &mk->mobutton, &mk->kstate);
  } while (mk->mobutton & pop->bmsk);

  return (item);
} /* hndl_scroll */

/*****************************************************************************/

LOCAL VOID hndl_arrows (pop, dir, x, y)
POP  pop;
WORD dir, x, y;

{
  LONG new_pos;
  RECT r;

  if (dir != FAILURE)
  {
    new_pos = pop->first_item;

    switch (dir)
    {
      case POPUP_PARENT : objc_rect (pop->tree, POPUP_SLIDER, &r, FALSE);
                          if (y < r.y) 
                            new_pos -= pop->vis_items - 1;
                          else
                            new_pos += pop->vis_items - 1;
                          break;
      case POPUP_SLIDER : new_pos = calc_first (pop, slide_box (pop));
                          break;
      case POPUP_UP     : new_pos--;
                          break;
      case POPUP_DOWN   : new_pos++;
                          break;
    } /* switch */

    scroll (pop, pop->first_item, new_pos);
  } /* if */
} /* hndl_arrows */

/*****************************************************************************/

LOCAL VOID scroll (pop, old_pos, new_pos)
POP  pop;
LONG old_pos, new_pos;

{
  LONG max_pos, delta, old;
  RECT r;

  max_pos = pop->num_items - pop->vis_items;

  if (max_pos < 0) max_pos = 0;

  if (new_pos > max_pos) new_pos = max_pos;
  if (new_pos < 0) new_pos = 0;

  delta = new_pos - old_pos;

  if (delta != 0)
  {
    pop->first_item = new_pos;
    old             = pop->tree [POPUP_SLIDER].ob_y;
    pop->tree [POPUP_SLIDER].ob_y = calc_pos (pop);
    if (old != pop->tree [POPUP_SLIDER].ob_y) draw_popup (pop, DRAW_SLIDER, 0, 0);

    if (labs (delta) >= (LONG)pop->vis_items)
      draw_popup (pop, DRAW_ITEMS, 0, pop->vis_items - 1);
    else
    {
      r.x = pop->x;
      r.y = pop->y;
      r.w = pop->width;
      r.h = pop->height;

      hide_mouse ();

      if (delta > 0)
      {
        r.y += (WORD)(pop->char_height * delta);
        r.h -= (WORD)(pop->char_height * delta);
        scroll_area (&r, VERTICAL, (WORD)(delta * pop->char_height));
        draw_popup (pop, DRAW_ITEMS, (WORD)(pop->vis_items - delta), pop->vis_items - 1);
      } /* if */
      else
      {
        r.h += (WORD)(pop->char_height * delta);
        scroll_area (&r, VERTICAL, (WORD)(delta * pop->char_height));
        draw_popup (pop, DRAW_ITEMS, 0, (WORD)(- delta - 1));
      } /* else */

      show_mouse ();
    } /* else */
  } /* if */
} /* scroll */

/*****************************************************************************/

LOCAL VOID change_item (pop, item)
POP  pop;
LONG item;

{
  RECT r;
  WORD xy [4];

  item -= pop->first_item;

  if ((0 <= item) && (item < pop->vis_items))
  {
    r.x = pop->x;
    r.y = pop->y + (WORD)(item * pop->char_height);
    r.w = pop->width - (pop->v_slider ? 1 : 0);
    r.h = pop->char_height;

    hide_mouse ();
    set_clip (TRUE, &r);
    rect2array (&r, xy);
    vswr_mode (vdi_handle, MD_XOR);
    vsf_interior (vdi_handle, FIS_SOLID);
    vsf_color (vdi_handle, BLACK);
    vr_recfl (vdi_handle, xy);
    show_mouse ();
  } /* if */
} /* change_item */

/*****************************************************************************/

LOCAL WORD slide_box (pop)
POP pop;

{
  LONG   value, maxpos, oldpos, newpos;
  RECT   bound;
  WORD   event, ret;
  WORD   x_offset, y_offset;
  RECT   startbox, box;
  MKINFO mk, start;

  graf_mkstate (&start.mox, &start.moy, &start.mobutton, &start.kstate);
  mk = start;

  objc_rect (pop->tree, POPUP_SLIDER, &startbox, TRUE);
  objc_rect (pop->tree, POPUP_PARENT, &bound, FALSE);

  bound.x--;                    /* "bound" ist nicht outlined */
  bound.y--;
  bound.w += 2;
  bound.h += 2;

  box      = startbox;
  x_offset = y_offset = 0;
  value    = 0;
  maxpos   = bound.h - startbox.h;
  newpos   = pop->first_item;

  line_default (vdi_handle);
  vsl_type (vdi_handle, USERLINE);

  fix_box (&box, &bound);
  draw_box (&box);

  do
  {
    event = evnt_multi (MU_BUTTON | MU_M1,
                        1, start.mobutton, 0x0000,
                        TRUE, mk.mox, mk.moy, 1, 1,
                        0, 0, 0, 0, 0,
                        NULL,
                        0, 0,
                        &mk.mox, &mk.moy,
                        &mk.momask, &mk.kstate,
                        &mk.kreturn, &mk.breturn);

    graf_mkstate (&ret, &ret, &mk.mobutton, &mk.kstate); /* Werte nach Ereignis */

    if (event & MU_M1)
    {
      draw_box (&box);

      x_offset = mk.mox - start.mox;
      y_offset = mk.moy - start.moy;
      box.x    = startbox.x + x_offset;
      box.y    = startbox.y + y_offset;

      fix_box (&box, &bound);

      if (pop->realtime)
      {
        value  = (WORD)((1000L * (box.y - bound.y)) / maxpos);
        oldpos = newpos;
        newpos = calc_first (pop, (WORD)value);

        if (oldpos != newpos)
          scroll (pop, pop->first_item, newpos);
      } /* if */

      draw_box (&box);
    } /* if */
  } while (! (event & MU_BUTTON));

  draw_box (&box);

  return ((WORD)((1000L * (box.y - bound.y)) / maxpos));
} /* slide_box */

/*****************************************************************************/

LOCAL VOID draw_box (box)
RECT *box;

{
  WORD xy [10];

  hide_mouse ();

  xy [0] = box->x;
  xy [1] = box->y;
  xy [2] = xy [0];
  xy [3] = xy [1] + box->h - 1;
  xy [4] = xy [0] + box->w - 1;
  xy [5] = xy [3];
  xy [6] = xy [4];
  xy [7] = xy [1];
  xy [8] = xy [0];
  xy [9] = xy [1];

  set_clip (TRUE, &desk);
  vswr_mode (vdi_handle, MD_XOR);
  vsl_udsty (vdi_handle, 0x5555);

  v_pline (vdi_handle, 5, xy);

  show_mouse ();
} /* draw_box */

/*****************************************************************************/

LOCAL VOID fix_box (box, bound)
RECT *box, *bound;

{
  WORD diff;

  diff = bound->x - box->x;
  if (diff > 0) box->x = bound->x;              /* Links heraushÑngend */

  diff = bound->x + bound->w - (box->x + box->w);
  if (diff < 0) box->x += diff;                 /* Rechts heraushÑngend */

  diff = bound->y - box->y;
  if (diff > 0) box->y = bound->y;              /* Oben heraushÑngend */

  diff = bound->y + bound->h - (box->y + box->h);
  if (diff < 0) box->y += diff;                 /* Unten heraushÑngend */
} /* fix_box */

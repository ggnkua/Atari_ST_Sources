/*****************************************************************************
 *
 * Module : BICONS.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 24.11.93
 *
 *
 * Description: This module implements the base icons dialog box.
 *
 * History:
 * 24.11.93: New file selector box used
 * 08.09.93: set_ptext -> set_str
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "event.h"
#include "dialog.h"
#include "butil.h"

#include "export.h"
#include "bicons.h"

/****** DEFINES **************************************************************/

#define MAX_IWIDTH  64  /* icon width */
#define MAX_IHEIGHT 32  /* icon height */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD      icon;
  BASE_SPEC *base_spec;
} ICON_SPEC;

/****** VARIABLES ************************************************************/

LOCAL ICON_SPEC icon_spec;

/****** FUNCTIONS ************************************************************/

LOCAL VOID set_icons     _((ICON_SPEC *icon_spec));
LOCAL VOID click_icons   _((WINDOWP window, MKINFO *mk));
LOCAL VOID check_state   _((WINDOWP window, WORD icon, WORD new_icon, BOOLEAN draw));
LOCAL VOID fill_icon     _((BASE_SPEC *base_spec, WORD icon));
LOCAL VOID upd_icon      _((BASE_SPEC *base_spec, WORD icon, WORD *mask, WORD *data, WORD width, WORD height));
LOCAL VOID exp_icon      _((BASE_SPEC *base_spec, WORD icon, WORD title));

/*****************************************************************************/

GLOBAL VOID micons (base_spec)
BASE_SPEC *base_spec;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, DOICONS);

  if (window == NULL)
  {
    form_center (doicons, &ret, &ret, &ret, &ret);
    window = crt_dialog (doicons, NULL, DOICONS, FREETXT (FDOICONS), WI_MODAL);

    if (window != NULL)
    {
      window->click   = click_icons;
      window->special = (LONG)&icon_spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = 0;
    window->edit_inx = NIL;

    icon_spec.icon      = 0;
    icon_spec.base_spec = base_spec;

    set_icons (&icon_spec);

    if (! open_dialog (DOICONS)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* micons */

/*****************************************************************************/

GLOBAL BOOLEAN load_icon (pmask, pdata, width, height, title)
WORD      *pmask, *pdata;
WORD      *width, *height;
WORD      title;

{
  BOOLEAN   ok;
  FULLNAME  filename;
  FILE      *file;
  WORD      i, j, l;
  WORD      w, h;
  UWORD     data;
  LONGSTR   s;

  ok = FALSE;

  strcpy (filename, icn_path);
  strcat (filename, icn_name);

  if (get_open_filename (title, NULL, 0L, FFILTER_ICO, NULL, icn_path, FICNSUFF, filename, icn_name))
  {
    busy_mouse ();

    file_split (filename, NULL, icn_path, icn_name, NULL);

    file = fopen (filename, "r");
    ok   = file != NULL;

    if (! ok)
      hndl_alert (ERR_ICONREAD);
    else
    {
      text_rdln (file, s, LONGSTRLEN);
      sscanf (s, "%d,%d", &w, &h);

      w = min (w, MAX_IWIDTH);
      h = min (h, MAX_IHEIGHT);

      *width  = w;
      *height = h;

      w = (w + 15) & 0xFFF0;

      text_rdln (file, s, LONGSTRLEN);  /* comment "DATA" */

      for (i = 0; i < h; i++)           /* read DATA */
      {
        text_rdln (file, s, LONGSTRLEN);
        l = strlen (s);
        mem_set (s + l, ' ', LONGSTRLEN - l);
        s [w] = EOS;
        data  = 0;

        for (j = 1; j <= w; j++)
        {
          data <<= 1;
          if (s [j - 1] != ' ') data |= 1;
          if ((j % 16) == 0) *pdata++ = data;
        } /* for */
      } /* for */

      text_rdln (file, s, LONGSTRLEN);  /* comment "MASK" */

      for (i = 0; i < h; i++)           /* read MASK */
      {
        text_rdln (file, s, LONGSTRLEN);
        l = strlen (s);
        mem_set (s + l, ' ', LONGSTRLEN - l);
        s [w] = EOS;
        data  = 0;

        for (j = 1; j <= w; j++)
        {
          data <<= 1;
          if (s [j - 1] != ' ') data |= 1;
          if ((j % 16) == 0) *pmask++ = data;
        } /* for */
      } /* for */

      fclose (file);
    } /* if */

    arrow_mouse ();
  } /* if */

  return (ok);
} /* load_icon */

/*****************************************************************************/

LOCAL VOID set_icons (icon_spec)
ICON_SPEC *icon_spec;

{
  FULLNAME  dbname;
  STRING    s;
  WORD      w, icon;
  WORD      width, height;
  WORD      *pmask, *pdata;
  SYSICON   *sysicon;
  BASE_SPEC *base_spec;

  base_spec = icon_spec->base_spec;
  icon      = icon_spec->icon;

  w = doicons [DDBNAME].ob_width / gl_wbox;

  strcpy (dbname, base_spec->basename);
  dbname [w] = EOS;
  strcpy (get_str (doicons, DDBNAME), dbname);

  sysicon = base_spec->sysicon;
  width   = sysicon->width;
  height  = sysicon->height;
  pmask   = &sysicon->icon.icondef [0];
  pdata   = &sysicon->icon.icondef [(width + 15) / 16 * height];

  set_idata (doicons, DICON, pmask, pdata, width, height);
  trans_gimage (doicons, DICON);

  undo_state (doicons, DDOWN, DISABLED);
  undo_state (doicons, DUP,   DISABLED);

  if (icon == 0)
    do_state (doicons, DDELETE, DISABLED);
  else
    undo_state (doicons, DDELETE, DISABLED);

  if (icon == 0) do_state (doicons, DDOWN, DISABLED);
  if (icon == base_spec->num_icons - 1) do_state (doicons, DUP, DISABLED);

  sprintf (s, "%d", icon);
  set_str (doicons, DINUM, s);
} /* set_icons */

/*****************************************************************************/

LOCAL VOID click_icons (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  STRING    s;
  WORD      icon, amount;
  WORD      mask [128];
  WORD      data [128];
  WORD      width, height;
  ICON_SPEC *icon_spec;
  BASE_SPEC *base_spec;

  icon_spec = (ICON_SPEC *)window->special;
  base_spec = icon_spec->base_spec;
  icon      = icon_spec->icon;

  switch (window->exit_obj)
  {
    case DOK     : break;
    case DHELP   : hndl_help (HDOICONS);
                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
    case DLOAD   : if (! check_icon (base_spec, 1))
                       hndl_alert (ERR_NOICONS);
                   else
                     if (load_icon (mask, data, &width, &height, FLOADICN))
                     {
                       icon = add_icon (base_spec, mask, data, width, height);

                       set_idata (doicons, DICON, mask, data, width, height);
                       trans_gimage (doicons, DICON);

                       check_state (window, icon, base_spec->num_icons, FALSE);

                       sprintf (s, "%d", icon);
                       set_str (doicons, DINUM, s);
                       set_redraw (window, &window->scroll);
                       base_spec->modified = TRUE;
                     } /* if */

                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
    case DUPDATE : if (load_icon (mask, data, &width, &height, FUPDICN))
                   {
                     upd_icon (base_spec, icon, mask, data, width, height);
                     set_idata (doicons, DICON, mask, data, width, height);
                     trans_gimage (doicons, DICON);

                     check_state (window, icon, base_spec->num_icons, FALSE);

                     set_redraw (window, &window->scroll);
                     base_spec->modified = TRUE;
                   } /* if */

                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
    case DEXPORT : exp_icon (base_spec, icon, FEXPICN);
                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
    case DDELETE : if (del_icon (base_spec, icon) == ERR_DEL_ICN) hndl_alert (ERR_DELICON);
                   if (icon == base_spec->num_icons) icon--;

                   check_state (window, icon, base_spec->num_icons, TRUE);
                   fill_icon (base_spec, icon);
                   draw_object (window, DICNBOX);

                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);

                   base_spec->modified = TRUE;
                   break;
    case DDOWN   :
    case DUP     : if (mk->breturn == 2)
                     amount = 10;
                   else
                     amount = 1;

                   if (window->exit_obj == DDOWN) icon -= amount;
                   if (window->exit_obj == DUP)   icon += amount;

                   if (icon < 0) icon = 0;
                   if (icon >= base_spec->num_icons) icon = base_spec->num_icons - 1;

                   check_state (window, icon, base_spec->num_icons, TRUE);
                   fill_icon (base_spec, icon);
                   draw_object (window, DICNBOX);

                   bclicks = 0x0102;    /* wait again for button down */
                   break;
  } /* switch */

  icon_spec->icon = icon;
} /* click_icons */

/*****************************************************************************/

LOCAL VOID check_state (window, icon, new_icon, draw)
WINDOWP window;
WORD    icon;
WORD    new_icon;
BOOLEAN draw;

{
  if ((icon == 0) == ! is_state (doicons, DDELETE, DISABLED))
  {
    flip_state (doicons, DDELETE, DISABLED);

    if (draw) draw_object (window, DDELETE);
  } /* if */

  if ((icon == 0) == ! is_state (doicons, DDOWN, DISABLED))
    flip_state (doicons, DDOWN, DISABLED);

  if ((icon == new_icon - 1) == ! is_state (doicons, DUP, DISABLED))
    flip_state (doicons, DUP, DISABLED);
} /* check_state */

/*****************************************************************************/

LOCAL VOID fill_icon (base_spec, icon)
BASE_SPEC *base_spec;
WORD      icon;

{
  STRING  s;
  WORD    width, height;
  WORD    *pmask, *pdata;
  SYSICON *sysicon;

  sprintf (s, "%d", icon);
  set_str (doicons, DINUM, s);

  sysicon = &base_spec->sysicon [icon];
  width   = sysicon->width;
  height  = sysicon->height;
  pmask   = &sysicon->icon.icondef [0];
  pdata   = &sysicon->icon.icondef [(width + 15) / 16 * height];

  set_idata (doicons, DICON, pmask, pdata, width, height);
  trans_gimage (doicons, DICON);
} /* fill_icon */

/*****************************************************************************/

LOCAL VOID upd_icon (base_spec, icon, pmask, pdata, width, height)
BASE_SPEC *base_spec;
WORD      icon;
WORD      *pmask;
WORD      *pdata;
WORD      width;
WORD      height;

{
  WORD    words;
  SYSICON *sysicon;

  sysicon = &base_spec->sysicon [icon];
  words   = (width + 15) / 16 * height;

  sysicon->width   = width;
  sysicon->height  = height;
  sysicon->flags  |= UPD_FLAG;

  sysicon->icon.size = words * 4;       /* data & mask in bytes */
  mem_move (&sysicon->icon.icondef [0],     pmask, words * 2);
  mem_move (&sysicon->icon.icondef [words], pdata, words * 2);
} /* upd_icon */

/*****************************************************************************/

LOCAL VOID exp_icon (base_spec, icon, title)
BASE_SPEC *base_spec;
WORD      icon;
WORD      title;

{
  FULLNAME  filename;
  EXT       suffix;
  FILE      *file;
  BOOLEAN   ok;
  WORD      i, j, k, l;
  WORD      words;
  WORD      width, height;
  WORD      *pmask, *pdata;
  UWORD     data;
  SYSICON   *sysicon;
  LONGSTR   s;

  sysicon = &base_spec->sysicon [icon];
  width   = sysicon->width;
  height  = sysicon->height;
  words   = (width + 15) / 16 * height;
  pmask   = &sysicon->icon.icondef [0];
  pdata   = &sysicon->icon.icondef [words];
  words   = (width + 15) / 16;  /* words per scan line */

  ok = TRUE;

  strcpy (filename, icn_path);
  strcat (filename, icn_name);

  if (get_open_filename (title, NULL, 0L, FFILTER_ICO, NULL, icn_path, FICNSUFF, filename, icn_name))
  {
    busy_mouse ();

    file_split (filename, NULL, icn_path, icn_name, suffix);

    strcat (icn_name, FREETXT (FICNSUFF) + 1);
    strcpy (filename, icn_path);
    strcat (filename, icn_name);

    file = fopen (filename, "w");
    ok   = file != NULL;

    if (! ok)
      hndl_alert (ERR_ICONWRITE);
    else
    {
      sprintf (s, "%d,%d (width,height)", width, height);
      ok = text_wrln (file, s);
      text_wrln (file, "DATA");

      for (i = 0; i < height; i++)      /* write DATA */
      {
        *s = EOS;
        l  = 0;

        for (j = 1; j <= words; j++, pdata++)
        {
          data = *pdata;

          for (k = 0; k < 16; k++, l++)
          {
            if (data & 0x8000)
              s [l] = '*';
            else
              s [l] = ' ';

            data <<= 1;
          } /* for */
        } /* for */

        s [l] = EOS;
        text_wrln (file, s);
      } /* for */

      text_wrln (file, "MASK");

      for (i = 0; i < height; i++)      /* write MASK */
      {
        *s = EOS;
        l  = 0;

        for (j = 1; j <= words; j++, pmask++)
        {
          data = *pmask;

          for (k = 0; k < 16; k++, l++)
          {
            if (data & 0x8000)
              s [l] = '*';
            else
              s [l] = ' ';

            data <<= 1;
          } /* for */
        } /* for */

        s [l] = EOS;
        text_wrln (file, s);
      } /* for */

      fclose (file);
    } /* if */

    arrow_mouse ();
  } /* if */
} /* exp_icon */


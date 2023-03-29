/*****************************************************************************
 *
 * Module : MPAGEFRM.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.04.94
 *
 *
 * Description: This module implements the page format dialog box.
 *
 * History:
 * 04.04.94: Using new syntax for inf files
 * 16.11.93: Using new file selector
 * 24.08.93: Bitmap buttons added
 * 20.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "dialog.h"
#include "resource.h"

#include "export.h"
#include "mpagefrm.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL BYTE *szPageLayout = "PageLayout";
LOCAL BYTE symbols [] = "BSPDT";

/****** FUNCTIONS ************************************************************/

LOCAL VOID    click_pageform _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_pageform   _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL BOOLEAN init_mpagefrm ()

{
  set_ptext (pageform, PGHEADL, "");
  set_ptext (pageform, PGHEADC, "");
  set_ptext (pageform, PGHEADR, "");
  set_ptext (pageform, PGFOOTL, "");
  set_ptext (pageform, PGFOOTC, "");
  set_ptext (pageform, PGFOOTR, "");

  get_pageformat (&page_format);

  return (TRUE);
} /* init_mpagefrm */

/*****************************************************************************/

GLOBAL BOOLEAN term_mpagefrm ()

{
  return (TRUE);
} /* term_mpagefrm */

/*****************************************************************************/

GLOBAL VOID get_pageformat (page_format)
PAGE_FORMAT *page_format;

{
  get_ptext (pageform, PGHEADL, page_format->lheader);
  get_ptext (pageform, PGHEADC, page_format->cheader);
  get_ptext (pageform, PGHEADR, page_format->rheader);
  get_ptext (pageform, PGFOOTL, page_format->lfooter);
  get_ptext (pageform, PGFOOTC, page_format->cfooter);
  get_ptext (pageform, PGFOOTR, page_format->rfooter);

  page_format->width       = get_word (pageform, PGWIDTH);
  page_format->length      = get_word (pageform, PGLENGTH);
  page_format->mtop        = get_word (pageform, PGMARTOP);
  page_format->mbottom     = get_word (pageform, PGMARBOT);
  page_format->mheader     = get_word (pageform, PGMARHEA);
  page_format->mfooter     = get_word (pageform, PGMARFOO);
  page_format->mleft       = get_word (pageform, PGMARLEF);
  page_format->formadvance = get_checkbox (pageform, PGFORMAD);
  page_format->colheader   = get_checkbox (pageform, PGCOLHEA);
  page_format->sum         = get_checkbox (pageform, PGSUM);
  page_format->group       = get_word (pageform, PGGROUP);
  page_format->result      = page_format->length -
                             page_format->mtop -
                             page_format->mbottom -
                             page_format->mheader -
                             page_format->mfooter - (page_format->colheader ? 2 : 0);
} /* get_pageformat */

/*****************************************************************************/

GLOBAL VOID set_pageformat (page_format)
PAGE_FORMAT *page_format;

{
  set_ptext (pageform, PGHEADL, page_format->lheader);
  set_ptext (pageform, PGHEADC, page_format->cheader);
  set_ptext (pageform, PGHEADR, page_format->rheader);
  set_ptext (pageform, PGFOOTL, page_format->lfooter);
  set_ptext (pageform, PGFOOTC, page_format->cfooter);
  set_ptext (pageform, PGFOOTR, page_format->rfooter);

  set_word (pageform, PGWIDTH, page_format->width);
  set_word (pageform, PGLENGTH, page_format->length);
  set_word (pageform, PGMARTOP, page_format->mtop);
  set_word (pageform, PGMARBOT, page_format->mbottom);
  set_word (pageform, PGMARHEA, page_format->mheader);
  set_word (pageform, PGMARFOO, page_format->mfooter);
  set_word (pageform, PGMARLEF, page_format->mleft);
  set_checkbox (pageform, PGFORMAD, page_format->formadvance);
  set_checkbox (pageform, PGCOLHEA, page_format->colheader);
  set_checkbox (pageform, PGSUM, page_format->sum);
  set_word (pageform, PGGROUP, page_format->group);

  page_format->result = page_format->length -
                        page_format->mtop -
                        page_format->mbottom -
                        page_format->mheader -
                        page_format->mfooter - (page_format->colheader ? 2 : 0);

  set_word (pageform, PGLINES, page_format->result);

  undo_state (pageform, PGBASE, DISABLED);
  undo_state (pageform, PGSORT, DISABLED);
  undo_state (pageform, PGPAGE, DISABLED);
  undo_state (pageform, PGDATE, DISABLED);
  undo_state (pageform, PGTIME, DISABLED);
  undo_state (pageform, PGOK, DISABLED);
  undo_state (pageform, PGSAVE, DISABLED);
} /* set_pageformat */

/*****************************************************************************/

GLOBAL BOOLEAN load_pageformat (loadinf, loadname, format, updt_dialog)
BYTE        *loadinf, *loadname;
PAGE_FORMAT *format;
BOOLEAN     updt_dialog;

{
  LONGSTR  s;
  BYTE     *pInf;
  FILE     *file;
  FULLNAME filename;
  WINDOWP  window;
  
  filename [0] = EOS;

  if (loadinf != NULL)
    pInf = loadinf;
  else
  {
    if ((loadname != NULL) && (*loadname != EOS))
      strcpy (filename, loadname);
    else
      if (! get_open_filename (FLOADLAY, NULL, 0L, FFILTER_LAY, NULL, cfg_path, FLAYSUFF, filename, NULL))
        return (FALSE);

    pInf = ReadInfFile (filename);

    if (pInf == NULL)
    {
      file_error (ERR_FILEOPEN, filename);
      return (FALSE);
    } /* if */
  } /* else */

  busy_mouse ();

  if (FindSection (pInf, szPageLayout) != NULL)
  {
    GetProfileString (pInf, szPageLayout, "LeftHeader", format->lheader, format->lheader);
    GetProfileString (pInf, szPageLayout, "CenterHeader", format->cheader, format->cheader);
    GetProfileString (pInf, szPageLayout, "RightHeader", format->rheader, format->rheader);
    GetProfileString (pInf, szPageLayout, "LeftFooter", format->lfooter, format->lfooter);
    GetProfileString (pInf, szPageLayout, "CenterFooter", format->cfooter, format->cfooter);
    GetProfileString (pInf, szPageLayout, "RightFooter", format->rfooter, format->rfooter);
    format->width       = GetProfileWord (pInf, szPageLayout, "Width", format->width);
    format->length      = GetProfileWord (pInf, szPageLayout, "Length", format->length);
    format->mtop        = GetProfileWord (pInf, szPageLayout, "Top", format->mtop);
    format->mbottom     = GetProfileWord (pInf, szPageLayout, "Bottom", format->mbottom);
    format->mleft       = GetProfileWord (pInf, szPageLayout, "Left", format->mleft);
    format->mheader     = GetProfileWord (pInf, szPageLayout, "Header", format->mheader);
    format->mfooter     = GetProfileWord (pInf, szPageLayout, "Footer", format->mfooter);
    format->formadvance = GetProfileBool (pInf, szPageLayout, "FormAdvance", format->formadvance);
    format->colheader   = GetProfileBool (pInf, szPageLayout, "ColHeader", format->colheader);
    format->sum         = GetProfileBool (pInf, szPageLayout, "Sum", format->sum);
    format->group       = GetProfileWord (pInf, szPageLayout, "Group", format->group);
  } /* if */
  else
  {
    file = fopen (filename, READ_TXT);

    text_rdln (file, format->lheader, LONGSTRLEN);
    text_rdln (file, format->cheader, LONGSTRLEN);
    text_rdln (file, format->rheader, LONGSTRLEN);
    text_rdln (file, format->lfooter, LONGSTRLEN);
    text_rdln (file, format->cfooter, LONGSTRLEN);
    text_rdln (file, format->rfooter, LONGSTRLEN);
    text_rdln (file, s, LONGSTRLEN);
    sscanf (s, "%3d%4d%3d%3d%3d%3d%2d%2d%2d%3d%3d\n",
               &format->width,
               &format->length,
               &format->mtop,
               &format->mbottom,
               &format->mheader,
               &format->mfooter,
               &format->formadvance,
               &format->colheader,
               &format->sum,
               &format->group,
               &format->mleft);

    fclose (file);
    save_pageformat (NULL, filename, format);	/* save as new format */
  } /* else */

  format->result = format->length -
                   format->mtop -
                   format->mbottom -
                   format->mheader -
                   format->mfooter - (format->colheader ? 2 : 0);

  if (updt_dialog)
  {
    set_pageformat (format);

    window = search_window (CLASS_DIALOG, SRCH_OPENED, PAGEFORM);
    if (window != NULL) set_redraw (window, &window->scroll);
  } /* if */

  if (loadinf == NULL) mem_free (pInf);

  arrow_mouse ();
  return (TRUE);
} /* load_pageformat */

/*****************************************************************************/

GLOBAL BOOLEAN save_pageformat (savefile, savename, format)
FILE        *savefile;
BYTE        *savename;
PAGE_FORMAT *format;

{
  FILE     *file;
  FULLNAME filename;

  filename [0] = EOS;

  if (savefile != NULL)
    file = savefile;
  else
  {
    if (savename != NULL)
      strcpy (filename, savename);
    else
      if (! get_save_filename (FSAVELAY, NULL, 0L, FFILTER_LAY, NULL, cfg_path, FLAYSUFF, filename, NULL))
        return (FALSE);

    file = fopen (filename, WRITE_TXT);

    if (file == NULL)
    {
      file_error (ERR_FILECREATE, filename);
      return (FALSE);
    } /* if */
  } /* else */

  busy_mouse ();

  fprintf (file, "[%s]\n", szPageLayout);
  fprintf (file, "LeftHeader=%s\n", format->lheader);
  fprintf (file, "CenterHeader=%s\n", format->cheader);
  fprintf (file, "RightHeader=%s\n", format->rheader);
  fprintf (file, "LeftFooter=%s\n", format->lfooter);
  fprintf (file, "CenterFooter=%s\n", format->cfooter);
  fprintf (file, "RightFooter=%s\n", format->rfooter);
  fprintf (file, "Width=%d\n", format->width);
  fprintf (file, "Length=%d\n", format->length);
  fprintf (file, "Top=%d\n", format->mtop);
  fprintf (file, "Bottom=%d\n", format->mbottom);
  fprintf (file, "Left=%d\n", format->mleft);
  fprintf (file, "Header=%d\n", format->mheader);
  fprintf (file, "Footer=%d\n", format->mfooter);
  fprintf (file, "FormAdvance=%d\n", format->formadvance);
  fprintf (file, "ColHeader=%d\n", format->colheader);
  fprintf (file, "Sum=%d\n", format->sum);
  fprintf (file, "Group=%d\n", format->group);

  if (savefile == NULL) fclose (file);

  arrow_mouse ();
  return (TRUE);
} /* save_pageformat */

/*****************************************************************************/

GLOBAL VOID mpageformat ()

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, PAGEFORM);

  if (window == NULL)
  {
    form_center (pageform, &ret, &ret, &ret, &ret);
    window = crt_dialog (pageform, NULL, PAGEFORM, FREETXT (FPAGEFOR), wi_modeless);

    if (window != NULL)
    {
      window->click = click_pageform;
      window->key   = key_pageform;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (pageform, ROOT, EDITABLE);
      window->edit_inx = NIL;
      set_pageformat (&page_format);
    } /* if */

    if (! open_dialog (PAGEFORM)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mpageformat */

/*****************************************************************************/

LOCAL VOID click_pageform (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD        obj, lines;
  MKINFO      m;
  PAGE_FORMAT saveformat;
  BYTE        *p2, *p3, *p4, *p5, *p6;

  switch (window->exit_obj)
  {
    case PGBASE   :
    case PGSORT   :
    case PGPAGE   :
    case PGDATE   :
    case PGTIME   : obj = window->exit_obj;
                    mem_set (&m, 0, sizeof (MKINFO));
                    m.ascii_code = m.kreturn = '$';
                    key_window (window, &m);
                    m.ascii_code = m.kreturn = symbols [obj - PGBASE];
                    key_window (window, &m);
                    undo_state (window->object, obj, SELECTED);
                    draw_object (window, obj);
                    break;
    case PGCOLHEA : p2 = get_str (pageform, PGLENGTH);
                    p3 = get_str (pageform, PGMARTOP);
                    p4 = get_str (pageform, PGMARBOT);
                    p5 = get_str (pageform, PGMARHEA);
                    p6 = get_str (pageform, PGMARFOO);

                    lines = atoi (p2) - atoi (p3) - atoi (p4) - atoi (p5) - atoi (p6) - (get_checkbox (pageform, PGCOLHEA) ? 2 : 0);
                    if (lines < 0) lines = 0;
                    set_word (pageform, PGLINES, lines);
                    draw_object (window, PGLINES);

                    if ((lines <= 0) == ! is_state (pageform, PGOK, DISABLED))
                    {
                      flip_state (pageform, PGOK, DISABLED);
                      draw_object (window, PGOK);
                      flip_state (pageform, PGSAVE, DISABLED);
                      draw_object (window, PGSAVE);
                    } /* if */
                    break;
    case PGOK     : get_pageformat (&page_format);
                    break;
    case PGCANCEL : set_pageformat (&page_format);
                    break;
    case PGHELP   : hndl_help (HPAGEFOR);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case PGLOAD   : load_pageformat (NULL, NULL, &saveformat, TRUE);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case PGSAVE   : get_pageformat (&saveformat);
                    save_pageformat (NULL, NULL, &saveformat);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  if ((window->edit_obj > PGFOOTR) == ! is_state (pageform, PGBASE, DISABLED))
  {
    flip_state (pageform, PGBASE, DISABLED);
    flip_state (pageform, PGSORT, DISABLED);
    flip_state (pageform, PGPAGE, DISABLED);
    flip_state (pageform, PGDATE, DISABLED);
    flip_state (pageform, PGTIME, DISABLED);
    draw_object (window, PGBASE);
    draw_object (window, PGSORT);
    draw_object (window, PGPAGE);
    draw_object (window, PGDATE);
    draw_object (window, PGTIME);
  } /* if */
} /* click_pageform */

/*****************************************************************************/

LOCAL BOOLEAN key_pageform (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE *p1, *p2, *p3, *p4, *p5, *p6, *p7;
  WORD lines;

  switch (window->edit_obj)
  {
    case PGWIDTH  :
    case PGLENGTH :
    case PGMARTOP :
    case PGMARBOT :
    case PGMARHEA :
    case PGMARFOO :
    case PGGROUP  : p1 = get_str (pageform, PGWIDTH);
                    p2 = get_str (pageform, PGLENGTH);
                    p3 = get_str (pageform, PGMARTOP);
                    p4 = get_str (pageform, PGMARBOT);
                    p5 = get_str (pageform, PGMARHEA);
                    p6 = get_str (pageform, PGMARFOO);
                    p7 = get_str (pageform, PGGROUP);

                    lines = atoi (p2) - atoi (p3) - atoi (p4) - atoi (p5) - atoi (p6) - (get_checkbox (pageform, PGCOLHEA) ? 2 : 0);

                    if (window->edit_obj != PGGROUP)
                    {
                      if (lines < 0) lines = 0;
                      set_word (pageform, PGLINES, lines);
                      draw_object (window, PGLINES);
                    } /* if */

                    if (((lines <= 0) || (*p1 == EOS) || (*p2 == EOS) || (*p3 == EOS) || (*p4 == EOS) || (*p5 == EOS) || (*p6 == EOS) || (*p7 == EOS)) == ! is_state (pageform, PGOK, DISABLED))
                    {
                      flip_state (pageform, PGOK, DISABLED);
                      draw_object (window, PGOK);
                      flip_state (pageform, PGSAVE, DISABLED);
                      draw_object (window, PGSAVE);
                    } /* if */

                    if (atoi (p7) > MAX_KEYSIZE - 1)
                    {
                      set_word (pageform, PGGROUP, MAX_KEYSIZE - 1);
                      draw_object (window, PGGROUP);
                    } /* if */
                    break;
  } /* switch */

  return (FALSE);
} /* key_pageform */

/*****************************************************************************/


/*****************************************************************************
 *
 * Module : COMMDLG.C
 * Author : Dieter Geiž
 *
 * Creation date    : 11.10.93
 * Last modification: 27.10.02
 *
 *
 * Description: This module implements the common dialog boxes.
 *
 * History:
 * 27.10.02: Dxreaddir und Dreadlabel werden bei der Verwendung der ACSTOS-Lib
 *           ausgeklammert.
 * 15.06.96: Long filename functionality added
 * 27.02.95: Calling get_volume_name only once in GetSystemInfo
 * 31.12.94: Using new function names of controls module
 * 28.07.94: Getting volume names depending on value in SYSTEM.INF
 * 18.07.94: True type capabilities added
 * 17.07.94: Problem with nonexisting icons fixed
 * 04.07.94: Dynamic icons add to static icons instead of replacing them
 * 25.04.94: Definitions for SYSTEM_INF and SYSTEM_DIR moved to GLOBAL.H
 * 02.04.94: Inf file functions moved to global.c
 * 29.03.94: Reading SYSTEM.INF file to get icon suffix information
 * 22.03.94: Reading SYSTEM.INF file to get drive information
 * 21.03.94: Function FontType added
 * 10.03.94: Function FontIsMonospaced added
 * 05.12.93: Function GetPathNameDialog added
 * 30.11.93: Icons with one or two letter suffixes compared correctly in icon_from_suffix
 * 22.11.93: Using multiple suffixes for get_filenames
 * 18.11.93: Using wildcards for suffix comparing
 * 16.11.93: Help button is disabled if help string is NULL
 * 14.11.93: Functions FontNameFromNumber and FontNumberFromName added
 * 05.11.93: Point size box uses tabstops
 * 03.11.93: Parameter wErrNoOpen in InitCommDlg added
 * 02.11.93: No longer using large stack variables in callback
 * 01.11.93: FONT_FLAG_SHOW_SYSTEM added
 * 29.10.93: Type and drive combobox don't have scrollbars if all entries fit
 * 28.10.93: Font is drawn when point size changes
 * 11.10.93: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"

#include "global.h"
#include "windows.h"

#include "appl.h"

#include "files.h"
#include "utility.h"

#include "controls.h"
#include "dialog.h"
#include "editobj.h"
#include "resource.h"

#include "export.h"
#include "commdlg.h"

/****** DEFINES **************************************************************/

#define SECTION_DRIVES		"Drives"
#define SECTION_ICON_MAPPINGS	"IconMappings"

#define MAX_DRIVES		32

#define DRIVE_FLOPPY		0
#define DRIVE_HARD		1
#define DRIVE_CD		2
#define DRIVE_NET		3
#define DRIVE_RAM		4

#define BY_NAME			0
#define BY_TYPE			1
#define BY_DATE			2
#define BY_SIZE			3
#define BY_NOTHING		4
#define MAX_ORDER		5
#define MAX_FONT_ORDER		3

#define MAX_POINTS		64

#define FONT_SWAPSIZE		3072
#define FONT_STRING		"The quick brown fox jumps over the lazy dog"

#ifndef E_OK
#define E_OK			0
#endif

/****** TYPES ****************************************************************/

typedef struct
{
  BYTE  *pszTitle;
  BYTE  *pszHelpID;
  ULONG ulFlags;
  BYTE  *pszFilter;
  LONG  *plFilterIndex;
  BYTE  *pszInitialDir;
  BYTE  *pszDefExt;
  BYTE  *pszFullName;
  BYTE  *pszFileName;
} FILE_PARMS;

typedef struct
{
  BYTE     *pszTitle;
  BYTE     *pszHelpID;
  ULONG    ulFlags;
  WORD     vdi_handle;
  FONTDESC *pFontDesc;
} FONT_PARMS;

typedef struct
{
  WORD     drive;
  WORD     type;
  FILENAME name;
} DRIVE;

typedef struct
{
  char          d_reserved [21];
  unsigned char d_attrib;
  unsigned int  d_time;
  unsigned int  d_date;
  unsigned long d_length;
  char          d_fname [256];		/* reserving space for long file names */
} LDTA;

/****** VARIABLES ************************************************************/

#include "drivesm.h"
#include "drives1.h"
#include "drives4.h"
#include "anym.h"
#include "any1.h"
#include "any4.h"
#include "fontsm.h"
#include "fonts1.h"
#include "fonts4.h"

LOCAL ICON       drives1_icon;		/* monochrome drives icons */
LOCAL ICON       drives4_icon;		/* color drives icons */

LOCAL ICON       any1_icon;		/* monochrome any type icon */
LOCAL ICON       any4_icon;		/* color any type icon */

LOCAL ICON       fonts1_icon;		/* monochrome font icons */
LOCAL ICON       fonts4_icon;		/* color font icons */

LOCAL WORD       err_noopen;		/* error number for "no open" */
LOCAL WORD       num_icon_suffix;	/* number of icon suffixes */
LOCAL ICONSUFFIX *icon_suffix;		/* icons for suffixes */
LOCAL BYTE       *icon_names_dyn;	/* names of suffixes for dynamic icons */
LOCAL WORD       num_icon_suffix_dyn;	/* number of dynamic icon suffixes */
LOCAL ICONSUFFIX *icon_suffix_dyn;	/* dynamic icons for suffixes */
LOCAL WORD       icon_height;		/* max height of user defined icon */
LOCAL WORD       icon_width;		/* max width of user defined icon */
LOCAL FILE_PARMS file_parms;		/* open/save dialog box parameters */
LOCAL DRIVE      drives [MAX_DRIVES];	/* drive specification */
LOCAL WORD       num_drives;		/* number of drives */
LOCAL WORD       num_filters;		/* number of filters */
LOCAL WORD       driveinx;		/* actual drive index */
LOCAL WORD       drive;			/* actual drive */
LOCAL WORD       exit_button;		/* exit button from dialog */
LOCAL WORD       num_chars;		/* number of characters for path string */
LOCAL WORD       num_fl_chars;		/* number of characters for path string in selfile */
LOCAL WORD       num_pt_chars;		/* number of characters for path string in selpath */
LOCAL WORD       num_files;		/* number of files */
LOCAL WORD       num_dirs;		/* number of directories */
LOCAL WORD       num_levels;		/* number of levels */
LOCAL WORD       file_order;		/* file sort order */
LOCAL BYTE       **order_strings;	/* sort order strings */
LOCAL BYTE       **color_strings;	/* color name strings */
LOCAL FILENAME   last_name;		/* last file name */
LOCAL FULLNAME   last_path;		/* last path */
LOCAL FILENAME   filename;		/* actual filename */
LOCAL FULLNAME   path;			/* actual path */
LOCAL FILENAME   suffix;		/* actual search suffix */
LOCAL LDTA       *filenames;		/* file names */
LOCAL LDTA       *pathnames;		/* path names */
LOCAL LDTA       *inxarray;		/* only for qsort */
LOCAL WORD       *fileinx;		/* file indexes */
LOCAL WORD       *pathinx;		/* path indexes */
LOCAL EDOBJ      ed;			/* edit object */
LOCAL BOOLEAN    use_editobj;		/* use edit object */
LOCAL BOOLEAN    lfn;			/* long filenames allowed on volume */

LOCAL WORD       font_order;		/* font sort order */
LOCAL FONT_PARMS font_parms;		/* font dialog box parameters */
LOCAL BOOLEAN    fonts_loaded;		/* fonts already loaded */
LOCAL WORD       num_fonts = 1;		/* number of available fonts */
LOCAL WORD       max_fonts = 1;		/* maximum number of fonts in listbox */
LOCAL WORD       num_points;		/* number of available sizes */
LOCAL WORD       old_point;		/* old actual point size */
LOCAL FONTDESC   fontdesc;		/* actual font descriptor */
LOCAL FONTINFO   *fontinfo;		/* font information table */
LOCAL WORD       *fonts;		/* font indexes */
LOCAL WORD       points [MAX_POINTS];	/* point table of actual font */

LOCAL WORD       name_tabs [] = {0 * 8, 21 * 8};
LOCAL WORD       name_tabstyles [] = {LBT_LEFT, LBT_RIGHT};

LOCAL WORD       size_tabs [] = {4 * 8};
LOCAL WORD       size_tabstyles [] = {LBT_RIGHT};

LOCAL BYTE       *drive_desc [] = {"FD", "HD", "CD", "NET", "RD"};

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN    GetFileNameDialog (BOOLEAN bSave, BYTE *pszTitle, BYTE *pszHelpID, ULONG ulFlags, BYTE *pszFilter, LONG *plFilterIndex, BYTE *pszInitialDir, BYTE *pszDefExt, BYTE *pszFullName, BYTE *pszFileName);

LOCAL VOID       get_file_dialog   (VOID);
LOCAL VOID       set_file_dialog   (VOID);

LOCAL VOID       get_path_dialog   (VOID);
LOCAL VOID       set_path_dialog   (VOID);

LOCAL LONG       names_callback    (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL LONG       dirs_callback     (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL LONG       types_callback    (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL LONG       drives_callback   (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL LONG       order_callback    (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);

LOCAL VOID       draw_file_dialog  (WINDOWP window);
LOCAL VOID       click_file_dialog (WINDOWP window, MKINFO *mk);
LOCAL BOOLEAN    key_file_dialog   (WINDOWP window, MKINFO *mk);

LOCAL VOID       click_path_dialog (WINDOWP window, MKINFO *mk);
LOCAL BOOLEAN    key_path_dialog   (WINDOWP window, MKINFO *mk);

LOCAL VOID       switch_drive      (WINDOWP window, WORD drive, WORD ob_dir, WORD ob_dirs);
LOCAL VOID       switch_path       (WINDOWP window, BYTE *path, WORD ob_dir, WORD ob_dirs);
LOCAL VOID       set_filenamestr   (WINDOWP window, BYTE *filename);

LOCAL VOID       get_filenames     (BYTE *path, BYTE *suffix);
LOCAL VOID       get_pathnames     (BYTE *path);

LOCAL WORD       inx_from_drive    (WORD drive);
LOCAL ICONSUFFIX *icon_from_suffix (BYTE *suffix);
LOCAL WORD       inx_from_suffix   (BYTE *suffix);
LOCAL BYTE       *suffix_from_inx  (WORD inx, BYTE *suffix);
LOCAL BYTE       *desc_from_inx    (WORD inx, BYTE *suffix);
LOCAL VOID       get_volume_name   (WORD drive, BYTE *name);

LOCAL VOID       sort_names        (VOID);
LOCAL VOID       sort_dirs         (VOID);
LOCAL INT        compare_files     (WORD *arg1, WORD *arg2);

LOCAL VOID       get_font_dialog   (VOID);
LOCAL VOID       set_font_dialog   (VOID);

LOCAL LONG       fonts_callback    (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL LONG       sizes_callback    (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL LONG       color_callback    (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);

LOCAL VOID       draw_font         (WINDOWP window);
LOCAL VOID       click_font_dialog (WINDOWP window, MKINFO *mk);
LOCAL BOOLEAN    key_font_dialog   (WINDOWP window, MKINFO *mk);

LOCAL VOID       set_fonttable     (WORD vdi_handle);
LOCAL VOID       set_sizetable     (WORD vdi_handle, WORD font);

LOCAL WORD       inx_from_fontlist (WORD font);
LOCAL WORD       inx_from_font     (WORD font);
LOCAL WORD       inx_from_point    (WORD point);

LOCAL VOID       sort_fonts        (VOID);
LOCAL INT        compare_fonts     (WORD *arg1, WORD *arg2);

LOCAL BOOLEAN    match             (BYTE *suffix, BYTE *filename);
LOCAL BOOLEAN    file_match        (BYTE *s1, BYTE *s2);
LOCAL INT        string_match      (BYTE *s1, BYTE *s2, INT len);

LOCAL VOID       GetSystemInfo     (VOID);
LOCAL WORD       DriveTypeFromDesc (BYTE *pszDesc);
LOCAL BOOLEAN    ReadIcon          (BYTE *pFileName, BYTE *pSuffix, ICONSUFFIX *pIconSuffix);
LOCAL UBYTE      *ReadImage        (BYTE *pFileName);

#ifndef __ACSTOS__
LOCAL LONG       Dxreaddir         (INT len, LONG dirhandle, BYTE *buf, XATTR *xattr, LONG *xr);
LOCAL LONG       Dreadlabel        (CONST BYTE *path, BYTE *label, WORD length);
#endif

LOCAL LDTA       *FGetDta          (VOID);
LOCAL INT        FsFirst           (CONST BYTE *pFileName, INT iAttr);
LOCAL INT        FsNext            (VOID);
LOCAL VOID       FsClose           (VOID);
LOCAL VOID       ModifyFileName    (BYTE *pFileName);
LOCAL VOID       ModifyPathName    (BYTE *pPathName);
LOCAL VOID       ShortenFileName   (BYTE *pFileName);
LOCAL BOOLEAN    IsOldFileName     (CONST BYTE *pFileName);
LOCAL BOOLEAN    SwitchDomain      (INT iDrive);

/*****************************************************************************/

GLOBAL BOOLEAN InitCommDlg (WORD wErrNoOpen, BYTE **ppszOrderByStrings, BYTE **ppszColorStrings, WORD wNumIconSuffix, ICONSUFFIX *pIconSuffix)
{
  WORD i;

  num_drives      = 2;
  driveinx        = 0;
  drive           = act_drv;
  num_fl_chars    = strlen (get_str (selfile, FLDIR));
  num_pt_chars    = strlen (get_str (selpath, PTDIR));
  file_order      = BY_NAME;
  err_noopen      = wErrNoOpen;
  order_strings   = ppszOrderByStrings;
  color_strings   = ppszColorStrings;
  num_icon_suffix = wNumIconSuffix;
  icon_suffix     = pIconSuffix;
  font_order      = BY_NAME;
  use_editobj     = TRUE;

  GetSystemInfo ();

  set_fonttable (vdi_handle);
  strcpy (last_path, act_path);

  for (i = 0, icon_width = 2 * gl_wbox, icon_height = gl_hbox; i < num_icon_suffix; i++)
  {
    icon_width  = max (icon_width, icon_suffix [i].icon1.width);
    icon_width  = max (icon_width, icon_suffix [i].icon4.width);
    icon_height = max (icon_height, icon_suffix [i].icon1.height);
    icon_height = max (icon_height, icon_suffix [i].icon4.height);
  } /* for */

  if (gl_hbox > 8)
  {
    selfile [FLNAMES].ob_height = (selfile [FLNAMES].ob_height - 4) / icon_height * icon_height + 4;
    selfile [FLTYPES].ob_height = max (icon_height + 4, gl_hattr + 2 + odd (gl_hattr));
  } /* if */
  else
  {
    icon_width  = 0;
    icon_height = gl_hbox;
  } /* else */

  ListBoxSetCallback (selfile, FLNAMES, names_callback);
  ListBoxSetStyle (selfile, FLNAMES, LBS_OWNERDRAW, TRUE);
  ListBoxSetTabstops (selfile, FLNAMES, sizeof (name_tabs) / sizeof (WORD), name_tabs, name_tabstyles);
  ListBoxSetCount (selfile, FLNAMES, 0, NULL);
  ListBoxSetCurSel (selfile, FLNAMES, FAILURE);
  ListBoxSetLeftOffset (selfile, FLNAMES, gl_wbox / 2);
  ListBoxSetItemHeight (selfile, FLNAMES, icon_height);

  ListBoxSetCallback (selfile, FLDIRS, dirs_callback);
  ListBoxSetStyle (selfile, FLDIRS, LBS_OWNERDRAW, TRUE);
  ListBoxSetCount (selfile, FLDIRS, 0, NULL);
  ListBoxSetCurSel (selfile, FLDIRS, FAILURE);
  ListBoxSetLeftOffset (selfile, FLDIRS, 0);

  ListBoxSetCallback (selfile, FLTYPES, types_callback);
  ListBoxSetStyle (selfile, FLTYPES, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (selfile, FLTYPES, LBS_VSCROLL, FALSE);
  ListBoxSetCount (selfile, FLTYPES, 0, NULL);
  ListBoxSetCurSel (selfile, FLTYPES, FAILURE);
  ListBoxSetLeftOffset (selfile, FLTYPES, gl_wbox / 2);
  ListBoxSetItemHeight (selfile, FLTYPES, icon_height);

  ListBoxSetCallback (selfile, FLDRIVES, drives_callback);
  ListBoxSetStyle (selfile, FLDRIVES, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (selfile, FLDRIVES, LBS_VSCROLL, FALSE);
  ListBoxSetCount (selfile, FLDRIVES, num_drives, NULL);
  ListBoxSetCurSel (selfile, FLDRIVES, driveinx);
  ListBoxSetLeftOffset (selfile, FLDRIVES, 0);

  ListBoxSetCallback (selfile, FLORDER, order_callback);
  ListBoxSetStyle (selfile, FLORDER, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (selfile, FLORDER, LBS_VSCROLL, FALSE);
  ListBoxSetCount (selfile, FLORDER, MAX_ORDER, NULL);
  ListBoxSetCurSel (selfile, FLORDER, 0);
  ListBoxSetLeftOffset (selfile, FLORDER, gl_wbox / 2);

  ListBoxSetCallback (selpath, PTDIRS, dirs_callback);
  ListBoxSetStyle (selpath, PTDIRS, LBS_OWNERDRAW, TRUE);
  ListBoxSetCount (selpath, PTDIRS, 0, NULL);
  ListBoxSetCurSel (selpath, PTDIRS, FAILURE);
  ListBoxSetLeftOffset (selpath, PTDIRS, 0);

  ListBoxSetCallback (selpath, PTDRIVES, drives_callback);
  ListBoxSetStyle (selpath, PTDRIVES, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (selpath, PTDRIVES, LBS_VSCROLL, FALSE);
  ListBoxSetCount (selpath, PTDRIVES, num_drives, NULL);
  ListBoxSetCurSel (selpath, PTDRIVES, driveinx);
  ListBoxSetLeftOffset (selpath, PTDRIVES, 0);

  ListBoxSetCallback (selpath, PTORDER, order_callback);
  ListBoxSetStyle (selpath, PTORDER, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (selpath, PTORDER, LBS_VSCROLL, FALSE);
  ListBoxSetCount (selpath, PTORDER, MAX_ORDER, NULL);
  ListBoxSetCurSel (selpath, PTORDER, 0);
  ListBoxSetLeftOffset (selpath, PTORDER, gl_wbox / 2);

  ListBoxSetCallback (selfont, FNNAMES, fonts_callback);
  ListBoxSetStyle (selfont, FNNAMES, LBS_OWNERDRAW, TRUE);
  ListBoxSetCount (selfont, FNNAMES, 0, NULL);
  ListBoxSetCurSel (selfont, FNNAMES, FAILURE);
  ListBoxSetLeftOffset (selfont, FNNAMES, gl_wbox / 2);

  ListBoxSetCallback (selfont, FNPOINTS, sizes_callback);
  ListBoxSetStyle (selfont, FNPOINTS, LBS_OWNERDRAW, TRUE);
  ListBoxSetTabstops (selfont, FNPOINTS, sizeof (size_tabs) / sizeof (WORD), size_tabs, size_tabstyles);
  ListBoxSetCount (selfont, FNPOINTS, 0, NULL);
  ListBoxSetCurSel (selfont, FNPOINTS, FAILURE);
  ListBoxSetLeftOffset (selfont, FNPOINTS, gl_wbox / 2);

  ListBoxSetCallback (selfont, FNCOLOR, color_callback);
  ListBoxSetStyle (selfont, FNCOLOR, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (selfont, FNCOLOR, LBS_VSCROLL, FALSE);
  ListBoxSetCount (selfont, FNCOLOR, min (colors, 16), NULL);
  ListBoxSetCurSel (selfont, FNCOLOR, BLACK);
  ListBoxSetLeftOffset (selfont, FNCOLOR, 0);

  ListBoxSetCallback (selfont, FNORDER, order_callback);
  ListBoxSetStyle (selfont, FNORDER, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (selfont, FNORDER, LBS_VSCROLL, FALSE);
  ListBoxSetCount (selfont, FNORDER, MAX_FONT_ORDER, NULL);
  ListBoxSetCurSel (selfont, FNORDER, 0);
  ListBoxSetLeftOffset (selfont, FNORDER, gl_wbox / 2);

  if (gl_hbox > 8)
  {
    BuildIcon (&drives1_icon, drivesm, drives1);
    BuildIcon (&drives4_icon, drivesm, drives4);
    BuildIcon (&any1_icon, anym, any1);
    BuildIcon (&any4_icon, anym, any4);
    BuildIcon (&fonts1_icon, fontsm, fonts1);
    BuildIcon (&fonts4_icon, fontsm, fonts4);
  } /* if */

  return (TRUE);
} /* InitCommDlg */

/*****************************************************************************/

GLOBAL BOOLEAN TermCommDlg (VOID)
{
  WORD i;

  if (gl_hbox > 8)
  {
    FreeIcon (&drives1_icon);
    FreeIcon (&drives4_icon);
    FreeIcon (&any1_icon);
    FreeIcon (&any4_icon);
    FreeIcon (&fonts1_icon);
    FreeIcon (&fonts4_icon);
  } /* if */

  mem_free (fontinfo);
  fontinfo = NULL;

  mem_free (fonts);
  fonts = NULL;

  if (icon_suffix_dyn != NULL)
    for (i = 0; i < num_icon_suffix_dyn; i++)
    {
      FreeIcon (&icon_suffix_dyn [i].icon1);
      FreeIcon (&icon_suffix_dyn [i].icon4);
    } /* for, if */

  mem_free (icon_names_dyn);
  icon_names_dyn = NULL;

  mem_free (icon_suffix_dyn);
  icon_suffix_dyn = NULL;

  return (TRUE);
} /* TermCommDlg */

/*****************************************************************************/

GLOBAL BOOLEAN GetOpenFileNameDialog (BYTE *pszTitle, BYTE *pszHelpID, ULONG ulFlags, BYTE *pszFilter, LONG *plFilterIndex, BYTE *pszInitialDir, BYTE *pszDefExt, BYTE *pszFullName, BYTE *pszFileName)
{
  return (GetFileNameDialog (FALSE, pszTitle, pszHelpID, ulFlags, pszFilter, plFilterIndex, pszInitialDir, pszDefExt, pszFullName, pszFileName));
} /* GetOpenFileNameDialog */

/*****************************************************************************/

GLOBAL BOOLEAN GetSaveFileNameDialog (BYTE *pszTitle, BYTE *pszHelpID, ULONG ulFlags, BYTE *pszFilter, LONG *plFilterIndex, BYTE *pszInitialDir, BYTE *pszDefExt, BYTE *pszFullName, BYTE *pszFileName)
{
  return (GetFileNameDialog (TRUE, pszTitle, pszHelpID, ulFlags, pszFilter, plFilterIndex, pszInitialDir, pszDefExt, pszFullName, pszFileName));
} /* GetSaveFileNameDialog */

/*****************************************************************************/

GLOBAL BOOLEAN GetPathNameDialog (BYTE *pszTitle, BYTE *pszHelpID, ULONG ulFlags, BYTE *pszInitialDir)
{
  WINDOWP window;
  WORD    ret;

  if ((ulFlags & FILE_FLAG_HIDE_HELP) || (pszHelpID == NULL))
    do_flags (selpath, PTHELP, HIDETREE);
  else
    undo_flags (selpath, PTHELP, HIDETREE);

  file_parms.pszTitle      = pszTitle;
  file_parms.pszHelpID     = pszHelpID;
  file_parms.ulFlags       = ulFlags;
  file_parms.pszFilter     = NULL; 
  file_parms.plFilterIndex = NULL;
  file_parms.pszInitialDir = pszInitialDir;
  file_parms.pszDefExt     = NULL;
  file_parms.pszFullName   = NULL;
  file_parms.pszFileName   = NULL;

  exit_button = PTCANCEL;
  num_chars   = num_pt_chars;
  window      = search_window (CLASS_DIALOG, SRCH_ANY, SELPATH);

  if (window == NULL)
  {
    form_center (selpath, &ret, &ret, &ret, &ret);
    window = crt_dialog (selpath, NULL, SELPATH, pszTitle, WI_MODAL);

    if (window != NULL)
    {
      window->click = click_path_dialog;
      window->key   = key_path_dialog;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    ListBoxSetSpec (selpath, PTDIRS, (LONG)window);
    ListBoxSetSpec (selpath, PTDRIVES, (LONG)window);
    ListBoxSetSpec (selpath, PTORDER, (LONG)window);

    if (window->opened == 0)
    {
      strcpy (window->name, pszTitle);
      window->edit_obj = find_flags (selpath, ROOT, EDITABLE);
      window->edit_inx = NIL;
      set_path_dialog ();
    } /* if */

    if (! open_dialog (SELPATH))
      hndl_alert (err_noopen);
    else
    {
      mem_free (filenames);
      filenames = NULL;

      mem_free (pathnames);
      pathnames = NULL;

      mem_free (fileinx);
      fileinx = NULL;

      mem_free (pathinx);
      pathinx = NULL;
    } /* else */
  } /* if */

  return (exit_button == PTOK);
} /* GetPathNameDialog */

/*****************************************************************************/

GLOBAL BOOLEAN GetFontDialog (BYTE *pszTitle, BYTE *pszHelpID, ULONG ulFlags, WORD vdi_handle, FONTDESC *pFontDesc)
{
  WINDOWP window;
  WORD    ret;

  if ((ulFlags & FONT_FLAG_HIDE_HELP) || (pszHelpID == NULL))
    do_flags (selfont, FNHELP, HIDETREE);
  else
    undo_flags (selfont, FNHELP, HIDETREE);

  if (ulFlags & FONT_FLAG_HIDE_EFFECTS)
    do_flags (selfont, FNEFFECT, HIDETREE);
  else
    undo_flags (selfont, FNEFFECT, HIDETREE);

  if (ulFlags & FONT_FLAG_HIDE_COLOR)
  {
    do_flags (selfont, FNCLABEL, HIDETREE);
    do_flags (selfont, FNCOLOR, HIDETREE);
  } /* if */
  else
  {
    undo_flags (selfont, FNCLABEL, HIDETREE);
    undo_flags (selfont, FNCOLOR, HIDETREE);
  } /* else */

  font_parms.pszTitle   = pszTitle;
  font_parms.pszHelpID  = pszHelpID;
  font_parms.vdi_handle = vdi_handle;
  font_parms.ulFlags    = ulFlags;
  font_parms.pFontDesc  = pFontDesc;

  exit_button = FNCANCEL;
  window      = search_window (CLASS_DIALOG, SRCH_ANY, SELFONT);

  if (window == NULL)
  {
    form_center (selfont, &ret, &ret, &ret, &ret);
    window = crt_dialog (selfont, NULL, SELFONT, pszTitle, WI_MODAL);

    if (window != NULL)
    {
      window->draw  = draw_font;
      window->click = click_font_dialog;
      window->key   = key_font_dialog;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    ListBoxSetSpec (selfont, FNNAMES, (LONG)window);
    ListBoxSetSpec (selfont, FNPOINTS, (LONG)window);
    ListBoxSetSpec (selfont, FNCOLOR, (LONG)window);
    ListBoxSetSpec (selfont, FNORDER, (LONG)window);

    if (window->opened == 0)
    {
      strcpy (window->name, pszTitle);
      window->edit_obj = find_flags (selfont, ROOT, EDITABLE);
      window->edit_inx = NIL;
      set_font_dialog ();
    } /* if */

    if (! open_dialog (SELFONT))
      hndl_alert (err_noopen);
  } /* if */

  return (exit_button == FNOK);
} /* GetFontDialog */

/*****************************************************************************/

GLOBAL VOID FontNameFromNumber (BYTE *pszFontName, WORD wFont)
{
  WORD i;

  pszFontName [0] = EOS;

  for (i = 0; i < num_fonts; i++)
    if (fontinfo [i].font == wFont)
      strcpy (pszFontName, fontinfo [i].fontname);
} /* FontNameFromNumber */

/*****************************************************************************/

GLOBAL WORD FontNumberFromName (BYTE *pszFontName)
{
  WORD i;

  for (i = 0; i < num_fonts; i++)
    if (stricmp (fontinfo [i].fontname, pszFontName) == 0)
      return (fontinfo [i].font);

  return (FAILURE);
} /* FontNumberFromName */

/*****************************************************************************/

GLOBAL BOOLEAN FontIsMonospaced (WORD vdi_handle, WORD wFont)
{
  BOOLEAN  mono;
  WORD     i;
  WORD     minimum, maximum, width;
  WORD     extent [8], distances [5], effects [3];
  WORD     w1, w2;
  BYTE     s [2];

  vst_font (vdi_handle, wFont);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

  for (i = max (minimum, 1), mono = TRUE, s [1] = EOS; (i < maximum - 1) && mono; i++)
  {
    s [0] = i;
    vqt_extent (vdi_handle, s, extent);
    w1 = extent [2] - extent [0];

    s [0] = i + 1;
    vqt_extent (vdi_handle, s, extent);
    w2 = extent [2] - extent [0];

    mono = w1 == w2;
  } /* for */

  return (mono);
} /* FontIsMonospaced */

/*****************************************************************************/

GLOBAL WORD FontType (WORD wFont)
{
  WORD type, inx;

  type = GDOS_BITMAPFONT;
  inx  = inx_from_font (wFont);

  if (inx != FAILURE)
    type = fontinfo [inx].type;

  return (type);
} /* FontType */

/*****************************************************************************/

GLOBAL BOOLEAN LoadFonts (WORD vdi_handle)
{
  if (! fonts_loaded && gdos_ok ())
  {
    busy_mouse ();

    num_fonts    = vst_ex_load_fonts (vdi_handle, 0, FONT_SWAPSIZE, 0);
    fonts_loaded = num_fonts > 0;

    if (fonts_loaded)
    {
      num_fonts++;                                      /* add system font */
      set_fonttable (vdi_handle);
    } /* if */
    else
    {
      if (num_fonts < 0) UnloadFonts (vdi_handle);      /* release font memory */
      num_fonts = 1;                                    /* leave system font */
      set_fonttable (vdi_handle);
    } /* else */

    arrow_mouse ();
  } /* if */

  return (fonts_loaded);
} /* LoadFonts */

/*****************************************************************************/

GLOBAL BOOLEAN UnloadFonts (WORD vdi_handle)
{
  if (fonts_loaded && gdos_ok ())
  {
    vst_unload_fonts (vdi_handle, 0);

    num_fonts    = 1;
    fonts_loaded = FALSE;
  } /* if */

  return (fonts_loaded);
} /* UnloadFonts */

/*****************************************************************************/

LOCAL BOOLEAN GetFileNameDialog (BOOLEAN bSave, BYTE *pszTitle, BYTE *pszHelpID, ULONG ulFlags, BYTE *pszFilter, LONG *plFilterIndex, BYTE *pszInitialDir, BYTE *pszDefExt, BYTE *pszFullName, BYTE *pszFileName)
{
  WINDOWP window;
  WORD    ret;

  if ((ulFlags & FILE_FLAG_HIDE_HELP) || (pszHelpID == NULL))
    do_flags (selfile, FLHELP, HIDETREE);
  else
    undo_flags (selfile, FLHELP, HIDETREE);

  file_parms.pszTitle      = pszTitle;
  file_parms.pszHelpID     = pszHelpID;
  file_parms.ulFlags       = ulFlags;
  file_parms.pszFilter     = pszFilter; 
  file_parms.plFilterIndex = plFilterIndex;
  file_parms.pszInitialDir = pszInitialDir;
  file_parms.pszDefExt     = pszDefExt;
  file_parms.pszFullName   = pszFullName;
  file_parms.pszFileName   = pszFileName;

  exit_button = FLCANCEL;
  num_chars   = num_fl_chars;
  window      = search_window (CLASS_DIALOG, SRCH_ANY, SELFILE);

  if (window == NULL)
  {
    form_center (selfile, &ret, &ret, &ret, &ret);
    window = crt_dialog (selfile, NULL, SELFILE, pszTitle, WI_MODAL);

    if (window != NULL)
    {
      if (use_editobj)
        window->draw = draw_file_dialog;

      window->click = click_file_dialog;
      window->key   = key_file_dialog;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    ListBoxSetSpec (selfile, FLNAMES, (LONG)window);
    ListBoxSetSpec (selfile, FLDIRS, (LONG)window);
    ListBoxSetSpec (selfile, FLTYPES, (LONG)window);
    ListBoxSetSpec (selfile, FLDRIVES, (LONG)window);
    ListBoxSetSpec (selfile, FLORDER, (LONG)window);

    if (window->opened == 0)
    {
      strcpy (window->name, pszTitle);
      window->edit_obj = use_editobj ? 0 : find_flags (selfile, ROOT, EDITABLE);
      window->edit_inx = NIL;
      ListBoxSetStyle (selfile, FLNAMES, LBS_DRAWDISABLED, bSave);

      if (use_editobj)
      {
        do_flags (selfile, FLNAME, HIDETREE);
        do_state (selfile, FLNAME, DISABLED);

        selfile [FLNAME].ob_width = selfile [FLNAMES].ob_width - 4;	/* for long filenames */

        xywh2rect (selfile [FLNAME].ob_x, selfile [FLNAME].ob_y, selfile [FLNAME].ob_width, selfile [FLNAME].ob_height, &ed.pos);

        ed.window  = window;
        ed.text    = filename;
#if 0
        ed.bufsize = use_lfn ? sizeof (FULLNAME) - 1 : 12;
#else
        ed.bufsize = sizeof (FULLNAME) - 1;
#endif
        ed.actsize = strlen (filename);
        ed.font    = font_btntext;
        ed.point   = point_btntext;
        ed.color   = BLACK;
        ed.flags   = ED_ALILEFT | ED_AUTOHSCROLL;

        edit_obj (&ed, ED_INIT, 0, NULL);
      } /* if */
      else
      {
        undo_flags (selfile, FLNAME, HIDETREE);
        undo_state (selfile, FLNAME, DISABLED);
      } /* else */

      set_file_dialog ();
    } /* if */

    if (! open_dialog (SELFILE))
      hndl_alert (err_noopen);
    else
    {
      mem_free (filenames);
      filenames = NULL;

      mem_free (pathnames);
      pathnames = NULL;

      mem_free (fileinx);
      fileinx = NULL;

      mem_free (pathinx);
      pathinx = NULL;

      if (use_editobj)
        edit_obj (&ed, ED_EXIT, 0, NULL);
    } /* else */
  } /* if */

  return (exit_button == FLOK);
} /* GetFileNameDialog */

/*****************************************************************************/

LOCAL VOID get_file_dialog (VOID)
{
  SIZE_T len;

  if (file_parms.plFilterIndex != NULL)
    *file_parms.plFilterIndex = ListBoxGetCurSel (selfile, FLTYPES);

  strcpy (filename, use_editobj ? ed.text : get_str (selfile, FLNAME));

  ShortenFileName (filename);

  strcpy (last_name, filename);
  strcpy (last_path, path);

  if ((strchr (filename, SUFFSEP) == NULL) && (file_parms.pszDefExt != NULL))
  {
    len = strlen (filename);

    if (len + 1 + strlen (file_parms.pszDefExt) < MAX_FILENAME)
    {
      filename [len] = SUFFSEP;
      strcpy (filename + len + 1, file_parms.pszDefExt);
    } /* if */
  } /* if */

  if (! lfn)
  {
    str_upper (path);
    str_upper (filename);
  } /* if */

  strcpy (file_parms.pszFullName, path);
  strcat (file_parms.pszFullName, filename);

  if (file_parms.pszFileName != NULL)
    strcpy (file_parms.pszFileName, filename);
} /* get_file_dialog */

/*****************************************************************************/

LOCAL VOID set_file_dialog ()
{
  WORD i;
  LONG index, exact;

  for (i = num_filters = 0; file_parms.pszFilter [i] != EOS; i++)
    if (file_parms.pszFilter [i] == '|')
      num_filters++;

  num_filters /= 2;

  ListBoxSetCount (selfile, FLTYPES, num_filters, NULL);
  ListBoxSetCurSel (selfile, FLTYPES, 0);

  if (file_parms.plFilterIndex != NULL)
    ListBoxSetCurSel (selfile, FLTYPES, *file_parms.plFilterIndex);

  suffix_from_inx ((WORD)ListBoxGetCurSel (selfile, FLTYPES), suffix);

  if (file_parms.pszFullName [0] != EOS)
    file_split (file_parms.pszFullName, NULL, path, filename, NULL);
  else
  {
    strcpy (path, last_path);
    filename [0] = EOS;
  } /* else */

  if ((file_parms.pszInitialDir != NULL) && (file_parms.pszInitialDir [0] != EOS))
    strcpy (path, file_parms.pszInitialDir);

  file_split (path, &drive, NULL, NULL, NULL);
  driveinx = inx_from_drive (drive);

  lfn = SwitchDomain (drive);

  ListBoxSetCount (selfile, FLDRIVES, num_drives, NULL);
  ListBoxSetCurSel (selfile, FLDRIVES, driveinx);

  ModifyPathName (path);
  ModifyFileName (filename);
  ShortenFileName (filename);

  ed.actsize = strlen (filename);

  strncpy (get_str (selfile, FLDIR), path, num_chars);
  strcpy (use_editobj ? ed.text : get_str (selfile, FLNAME), filename);

  if ((*filename == EOS) == ! is_state (selfile, FLOK, DISABLED))
    flip_state (selfile, FLOK, DISABLED);

  busy_mouse ();
  get_filenames (path, suffix);
  get_pathnames (path);
  arrow_mouse ();

  index = (filename [0] == EOS) ? FAILURE : ListBoxFindString (selfile, FLNAMES, 0L, filename);
  exact = (filename [0] == EOS) ? FAILURE : ListBoxFindStringExact (selfile, FLNAMES, 0L, filename);

  ListBoxSetTopIndex (selfile, FLNAMES, index);
  ListBoxSetCurSel (selfile, FLNAMES, (ListBoxGetStyle (selfile, FLNAMES) & LBS_DRAWDISABLED) ? exact : index);
} /* set_file_dialog */

/*****************************************************************************/

LOCAL VOID get_path_dialog (VOID)
{
  strcpy (last_path, path);

  if (! lfn)
    str_upper (path);

  strcpy (file_parms.pszInitialDir, path);
} /* get_path_dialog */

/*****************************************************************************/

LOCAL VOID set_path_dialog ()
{
  WORD     drive;
  FULLNAME fullname;

  if ((file_parms.pszInitialDir != NULL) && (file_parms.pszInitialDir [0] != EOS))
    strcpy (path, file_parms.pszInitialDir);
  else
    strcpy (path, last_path);

  if (path [0] == EOS)
  {
    drive = Dgetdrv ();
    get_dpath (drive, path);
    fullname [0] = 'A' + drive;
    fullname [1] = DRIVESEP;
    strcpy (fullname + 2, path);
    strcpy (path, fullname);
  } /* if */

  file_split (path, &drive, NULL, NULL, NULL);
  driveinx = inx_from_drive (drive);

  lfn = SwitchDomain (drive);

  ListBoxSetCount (selpath, PTDRIVES, num_drives, NULL);
  ListBoxSetCurSel (selpath, PTDRIVES, driveinx);

  ModifyPathName (path);
  strncpy (get_str (selpath, PTDIR), path, num_chars);

  busy_mouse ();
  get_pathnames (path);
  arrow_mouse ();
} /* set_path_dialog */

/*****************************************************************************/

LOCAL LONG names_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP        window;
  LB_OWNERDRAW   *lb_ownerdraw;
  RECT           r;
  BYTE           *text;
  ICON           *icon;
  UINT           date, day, month, year;
  ICONSUFFIX     *pIconSuffix;
  LOCAL FILENAME filename;
  LOCAL LONGSTR  name;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : if (filenames != NULL)
                            return ((LONG)filenames [fileinx [index]].d_fname);
                          else
                            return (0L);
    case LBN_DRAWITEM   : lb_ownerdraw = p;

                          if (index != FAILURE)
                          {
                            switch (file_order)
                            {
                              case BY_DATE : date    = filenames [fileinx [index]].d_date;
                                             day     = date & 0x1F;
                                             date  >>= 5;
                                             month   = date & 0x0F;
                                             date  >>=4;
                                             year    = date;
                                             year   += 80;
                                             sprintf (name, "%s\t%02d.%02d.%02d", filenames [fileinx [index]].d_fname, day, month, year);
                                             break;
                              case BY_SIZE : sprintf (name, "%s\t%ld", filenames [fileinx [index]].d_fname, filenames [fileinx [index]].d_length);
                                             break;
                              default      : strcpy (name, filenames [fileinx [index]].d_fname);
                                             break;
                            } /* switch */

                            text = name;
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (gl_hbox <= 8) ? 0 : icon_width + 4;

                            if (gl_hbox <= 8)
                              icon = NULL;
                            else
                              if ((pIconSuffix = icon_from_suffix (filenames [fileinx [index]].d_fname)) != NULL)
                                icon = (colors < 16) ? &pIconSuffix->icon1 : &pIconSuffix->icon4;
                              else
                                icon = (colors < 16) ? &any1_icon : &any4_icon;

                            DrawOwnerIcon (lb_ownerdraw, &r, icon, text, (icon == NULL) ? ListBoxGetLeftOffset (tree, obj) : 0);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxGetText (tree, obj, index, filename);
                          set_filenamestr (window, filename);
                          if (is_state (window->object, FLOK, DISABLED))
                          {
                            flip_state (window->object, FLOK, DISABLED);
                            draw_object (window, FLOK);
                          } /* if */
                          break;
    case LBN_DBLCLK     : window->exit_obj = FLOK;
                          break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* names_callback */

/*****************************************************************************/

LOCAL LONG dirs_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP        window;
  BOOLEAN        visible_part;
  LB_OWNERDRAW   *lb_ownerdraw;
  RECT           r;
  BYTE           *text, *q;
  WORD           offset, iconcol;
  LOCAL FILENAME filename;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : if (pathnames != NULL)
                            return ((LONG)pathnames [pathinx [index]].d_fname);
                          else
                            return (0L);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            if (gl_hbox <= 8)
                              offset = (WORD)(min (index, num_levels) + 1) * gl_wbox;
                            else
                              offset = (WORD)(min (index, num_levels) + 1) * gl_wbox / 2;

                            iconcol  = (index == num_levels - 1) ? 1 : (index < num_levels - 1) ? 0 : 2;
                            text     = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r        = lb_ownerdraw->rc_item;
                            r.x     += (gl_hbox <= 8) ? 0 : offset;
                            r.w      = (gl_hbox <= 8) ? 0 : drives4_icon.width / 8 + 4;

                            if (gl_hbox <= 8)
                              DrawOwnerMultiIcon (lb_ownerdraw, &r, NULL, text, offset, 1, 8, 0, iconcol);
                            else
                              DrawOwnerMultiIcon (lb_ownerdraw, &r, (colors < 16) ? &drives1_icon : &drives4_icon, text, offset, 1, 8, 0, iconcol);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : if (index >= num_levels)
                          {
                            ListBoxGetText (tree, obj, index, filename);
                            strcat (path, filename);
                            strcat (path, "\\");
                          } /* if */
                          else
                          {
                            for (q = path; index >= 0; index--)
                              q = strchr (q, PATHSEP) + 1;

                            *q = EOS;
                          } /* if */

                          if (tree == selfile)
                            switch_path (window, path, FLDIR, FLDIRS);
                          else
                            switch_path (window, path, PTDIR, PTDIRS);
                          break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* dirs_callback */

/*****************************************************************************/

LOCAL LONG types_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP        window;
  BOOLEAN        visible_part;
  LB_OWNERDRAW   *lb_ownerdraw;
  RECT           r;
  BYTE           *text;
  ICON           *icon;
  ICONSUFFIX     *pIconSuffix;
  LOCAL FILENAME suffix;
  LOCAL STRING   filter;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)desc_from_inx ((WORD)index, filter));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (gl_hbox <= 8) ? 0 : icon_width + 4;

                            if (gl_hbox <= 8)
                              icon = NULL;
                            else
                              if ((pIconSuffix = icon_from_suffix (suffix_from_inx (index, suffix))) != NULL)
                                icon = (colors < 16) ? &pIconSuffix->icon1 : &pIconSuffix->icon4;
                              else
                                icon = (colors < 16) ? &any1_icon : &any4_icon;

                            DrawOwnerIcon (lb_ownerdraw, &r, icon, text, (icon == NULL) ? ListBoxGetLeftOffset (tree, obj) : 0);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* types_callback */

/*****************************************************************************/

LOCAL LONG drives_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  BYTE         *text;
  LOCAL STRING name;
  LOCAL STRING drivestr;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : if (drives [index].name [0] != EOS)
                            sprintf (name, "[%s]", drives [index].name);
                          else
                            name [0] = EOS;
                          sprintf (drivestr, "%c%c %s", (lfn ? 'A' : 'a') + drives [index].drive, DRIVESEP, name);
                          return ((LONG)drivestr);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (gl_hbox <= 8) ? 0 : drives4_icon.width / 8 + 4;

                            if (gl_hbox <= 8)
                              DrawOwnerMultiIcon (lb_ownerdraw, &r, NULL, text, ListBoxGetLeftOffset (tree, obj), 1, 8, 0, drives [index].type + 3);
                            else
                              DrawOwnerMultiIcon (lb_ownerdraw, &r, (colors < 16) ? &drives1_icon : &drives4_icon, text, 0, 1, 8, 0, drives [index].type + 3);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* drives_callback */

/*****************************************************************************/

LOCAL LONG order_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  BYTE         *text;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : if (tree == selfont)
                            switch (index)
                            {
                              case 0 : index = BY_NAME;    break;
                              case 1 : index = BY_TYPE;    break;
                              case 2 : index = BY_NOTHING; break;
                            } /* switch, if */
                          return ((LONG)order_strings [index]);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = 0;
                            DrawOwnerIcon (lb_ownerdraw, &r, NULL, text, ListBoxGetLeftOffset (tree, obj));
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* order_callback */

/*****************************************************************************/

LOCAL VOID draw_file_dialog (WINDOWP window)
{
  edit_obj (&ed, ED_HIDECURSOR, 0, NULL);
  edit_obj (&ed, ED_DRAW, 0, NULL);
  edit_obj (&ed, ED_SHOWCURSOR, 0, NULL);
} /* draw_file_dialog */

/*****************************************************************************/

LOCAL VOID click_file_dialog (WINDOWP window, MKINFO *mk)
{
  WORD     drv;
  LONG     item, i;
  FILENAME filename;
  FULLNAME fullname;
  BYTE     *p;
  LONG     index, exact;
  BOOL     wild;
  RECT     rc;

  set_clip (TRUE, &window->work);

  if (use_editobj)
  {
    objc_rect (window->object, FLNAME, &rc, FALSE);

    if (inside (mk->mox, mk->moy, &rc))
      window->exit_obj = FLNAME;
  } /* if */

  switch (window->exit_obj)
  {
    case FLNAME    : if (use_editobj)
                     {
                       hide_mouse ();
                       edit_obj (&ed, ED_HIDECURSOR, 0, NULL);
                       edit_obj (&ed, ED_CLICK, 0, mk);
                       edit_obj (&ed, ED_SHOWCURSOR, 0, NULL);
                       show_mouse ();
                     } /* if */
                     break;
    case FLNAMES   : ListBoxClick (window->object, window->exit_obj, mk);
                     if (window->exit_obj == FLOK)		/* double clicked on a valid filename */
                     {
                       if (! (ListBoxGetStyle (window->object, FLNAMES) & LBS_DRAWDISABLED))
                         if ((item = ListBoxGetCurSel (window->object, FLNAMES)) != FAILURE)
                           ListBoxGetText (window->object, FLNAMES, item, use_editobj ? ed.text : get_str (window->object, FLNAME));
                       get_file_dialog ();
                       exit_button    = window->exit_obj;
                       window->flags |= WI_DLCLOSE;
                     } /* if */
                     break;
    case FLDIRS    : mk->breturn = 2;				/* fool listbox */
                     ListBoxClick (window->object, window->exit_obj, mk);
                     break;
    case FLTYPES   : ListBoxSetComboRect (window->object, window->exit_obj, NULL, min (6, num_filters));
                     if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                     {
                       p = file_parms.pszFilter;

                       for (i = 0; i < 2 * item; i++)
                         p = strchr (p, '|') + 1;

                       p = strchr (p, '|') + 1;

                       i = 0;
                       while ((*p != EOS) && (*p != '|'))
                         suffix [i++] = *p++;

                       suffix [i] = EOS;

                       busy_mouse ();
                       get_filenames (path, suffix);
                       arrow_mouse ();

                       p       = use_editobj ? ed.text : get_str (window->object, FLNAME);
                       index   = (*p == EOS) ? FAILURE : ListBoxFindString (window->object, FLNAMES, 0L, p);
                       exact   = (*p == EOS) ? FAILURE : ListBoxFindStringExact (window->object, FLNAMES, 0L, p);

                       ListBoxSetTopIndex (window->object, FLNAMES, index);
                       ListBoxSetCurSel (window->object, FLNAMES, (ListBoxGetStyle (window->object, FLNAMES) & LBS_DRAWDISABLED) ? exact : index);
                       ListBoxRedraw (window->object, FLNAMES);
                     } /* if */
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
    case FLDRIVES  : ListBoxSetComboRect (window->object, window->exit_obj, NULL, min (6, num_drives));
                     if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                       if ((WORD)item != driveinx)
                       {
                         driveinx = (WORD)item;
                         drive    = drives [driveinx].drive;
                         switch_drive (window, drive, FLDIR, FLDIRS);
                       } /* if, if */
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
    case FLORDER   : ListBoxSetComboRect (window->object, window->exit_obj, NULL, MAX_ORDER);
                     if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                       if ((WORD)item != file_order)
                       {
                         file_order = (WORD)item;

                         if ((item = ListBoxGetCurSel (window->object, FLNAMES)) != FAILURE)
                           ListBoxGetText (window->object, FLNAMES, item, filename);

                         busy_mouse ();
                         sort_names ();
                         sort_dirs ();
                         arrow_mouse ();

                         if (item != FAILURE)
                           item = ListBoxFindStringExact (window->object, FLNAMES, 0L, filename);
                         ListBoxSetCurSel (window->object, FLNAMES, item);
                         ListBoxSetTopIndex (window->object, FLNAMES, item);
                         ListBoxRedraw (window->object, FLNAMES);
                         ListBoxSetCurSel (window->object, FLDIRS, FAILURE);
                         ListBoxSetTopIndex (window->object, FLDIRS, 0);
                         ListBoxRedraw (window->object, FLDIRS);
                       } /* if, if */
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
    case FLOK      : for (p = use_editobj ? ed.text : get_str (window->object, FLNAME), wild = FALSE; *p != EOS; p++)
                       if ((*p == '?') || (*p == '*'))
                         wild = TRUE;

                     p = use_editobj ? ed.text : get_str (window->object, FLNAME);

                     if (wild)
                     {
                       window->flags &= ~ WI_DLCLOSE;
                       strcpy (suffix, p);
                       i = inx_from_suffix (suffix);
                       busy_mouse ();
                       get_filenames (path, suffix);
                       arrow_mouse ();
                       ListBoxRedraw (window->object, FLNAMES);

                       if (i != FAILURE)
                       {
                         ListBoxSetCurSel (window->object, FLTYPES, i);
                         draw_object (window, FLTYPES);
                         set_filenamestr (window, "");
                       } /* if */
                     } /* if */
                     else
                       if (strcmp (p, "..") == 0)
                       {
                         window->flags &= ~ WI_DLCLOSE;
                         set_filenamestr (window, "");
                         ListBoxSendMessage (window->object, FLDIRS, LBN_DBLCLK, max (num_levels - 2, 0), NULL);
                       } /* if */
                       else
                         if ((strlen (p) > 1) && (p [1] == DRIVESEP))
                         {
                           window->flags &= ~ WI_DLCLOSE;
                           drv      = toupper (p [0]) - 'A';
                           driveinx = inx_from_drive (drv);

                           if (driveinx == FAILURE)
                             driveinx = (WORD)ListBoxGetCurSel (window->object, FLDRIVES);
                           else
                           {
                             set_filenamestr (window, "");
                             ListBoxSetCurSel (window->object, FLDRIVES, driveinx);
                             draw_object (window, FLDRIVES);
                             drive = drv;
                             switch_drive (window, drive, FLDIR, FLDIRS);
                           } /* else */
                         } /* if */
                         else
                         {
                           strcpy (fullname, path);
                           strcat (fullname, p);

                           if (path_exist (fullname))
                           {
                             window->flags &= ~ WI_DLCLOSE;
                             set_filenamestr (window, "");
                             strcat (fullname, "\\");
                             strcpy (path, fullname);
                             switch_path (window, path, FLDIR, FLDIRS);
                           } /* if */
                           else
                           {
                             if (! (ListBoxGetStyle (window->object, FLNAMES) & LBS_DRAWDISABLED))
                               if ((item = ListBoxGetCurSel (window->object, FLNAMES)) != FAILURE)
                                 ListBoxGetText (window->object, FLNAMES, item, use_editobj ? ed.text : get_str (window->object, FLNAME));
                             get_file_dialog ();
                             exit_button = window->exit_obj;
                           } /* else */
                         } /* else, else, else */
                     break;
    case FLCANCEL  : exit_button = window->exit_obj;
                     break;
    case FLHELP    : call_helpfunc (file_parms.pszHelpID);
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
  } /* switch */
} /* click_file_dialog */

/*****************************************************************************/

LOCAL BOOLEAN key_file_dialog (WINDOWP window, MKINFO *mk)
{
  BYTE *p;
  LONG index, exact, old_inx, old_sel;
  WORD ed_obj;

  set_clip (TRUE, &window->work);

  ed_obj = use_editobj ? FLNAME : window->edit_obj;

  switch (ed_obj)
  {
    case FLNAME : if (use_editobj)
                  {
                    edit_obj (&ed, ED_KEY, 0, mk);
                    p = ed.text;
                  } /* if */
                  else
                    p = get_str (window->object, window->edit_obj);

                  if ((*p == EOS) == ! is_state (window->object, FLOK, DISABLED))
                  {
                    flip_state (window->object, FLOK, DISABLED);
                    draw_object (window, FLOK);
                  } /* if */

                  index   = (*p == EOS) ? FAILURE : ListBoxFindString (window->object, FLNAMES, 0L, p);
                  exact   = (*p == EOS) ? FAILURE : ListBoxFindStringExact (window->object, FLNAMES, 0L, p);
                  old_inx = ListBoxGetTopIndex (window->object, FLNAMES);
                  old_sel = ListBoxGetCurSel (window->object, FLNAMES);

                  if ((mk->scan_code == UP) || (mk->scan_code == DOWN))
                    ListBoxKey (window->object, FLNAMES, mk);
                  else
                  {
                    ListBoxSetTopIndex (window->object, FLNAMES, index);
                    ListBoxSetCurSel (window->object, FLNAMES, (ListBoxGetStyle (window->object, FLNAMES) & LBS_DRAWDISABLED) ? exact : index);

                    if ((old_inx != ListBoxGetTopIndex (window->object, FLNAMES)) || (old_sel != ListBoxGetCurSel (window->object, FLNAMES)))
                      ListBoxRedraw (window->object, FLNAMES);
                  } /* else */
                  break;
  } /* switch */

  return (FALSE);
} /* key_file_dialog */

/*****************************************************************************/

LOCAL VOID click_path_dialog (WINDOWP window, MKINFO *mk)
{
  LONG item;

  switch (window->exit_obj)
  {
    case PTDIRS    : mk->breturn = 2;				/* fool listbox */
                     ListBoxClick (window->object, window->exit_obj, mk);
                     break;
    case PTDRIVES  : ListBoxSetComboRect (window->object, window->exit_obj, NULL, min (6, num_drives));
                     if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                       if ((WORD)item != driveinx)
                       {
                         driveinx = (WORD)item;
                         drive    = drives [driveinx].drive;
                         switch_drive (window, drive, PTDIR, PTDIRS);
                       } /* if, if */
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
    case PTORDER   : ListBoxSetComboRect (window->object, window->exit_obj, NULL, MAX_ORDER);
                     if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                       if ((WORD)item != file_order)
                       {
                         file_order = (WORD)item;

                         busy_mouse ();
                         sort_dirs ();
                         arrow_mouse ();

                         ListBoxSetCurSel (window->object, PTDIRS, FAILURE);
                         ListBoxSetTopIndex (window->object, PTDIRS, 0);
                         ListBoxRedraw (window->object, PTDIRS);
                       } /* if, if */
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
    case PTOK      : get_path_dialog ();
                     exit_button = window->exit_obj;
                     break;
    case PTCANCEL  : exit_button = window->exit_obj;
                     break;
    case PTHELP    : call_helpfunc (file_parms.pszHelpID);
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
  } /* switch */
} /* click_path_dialog */

/*****************************************************************************/

LOCAL BOOLEAN key_path_dialog (WINDOWP window, MKINFO *mk)
{
  return (FALSE);
} /* key_path_dialog */

/*****************************************************************************/

LOCAL VOID switch_drive (WINDOWP window, WORD drive, WORD ob_dir, WORD ob_dirs)
{
  FULLNAME fullname;
  BYTE     *p;
  LONG     index, exact;

  lfn = SwitchDomain (drive);

  Dsetdrv (drive);
  get_dpath (drive, path);
  fullname [0] = 'A' + drive;
  fullname [1] = DRIVESEP;
  strcpy (fullname + 2, path);
  strcpy (path, fullname);
  busy_mouse ();
  if (window->object == selfile) get_filenames (path, suffix);
  get_pathnames (path);
  arrow_mouse ();
  ModifyPathName (path);
  strncpy (get_str (window->object, ob_dir), path, num_chars);
  draw_object (window, ob_dir);

  if (window->object == selfile) 
  {
    p       = use_editobj ? ed.text : get_str (window->object, FLNAME);
    index   = (*p == EOS) ? FAILURE : ListBoxFindString (window->object, FLNAMES, 0L, p);
    exact   = (*p == EOS) ? FAILURE : ListBoxFindStringExact (window->object, FLNAMES, 0L, p);

    ListBoxSetTopIndex (window->object, FLNAMES, index);
    ListBoxSetCurSel (window->object, FLNAMES, (ListBoxGetStyle (window->object, FLNAMES) & LBS_DRAWDISABLED) ? exact : index);
    ListBoxRedraw (window->object, FLNAMES);
  } /* if */

  ListBoxRedraw (window->object, ob_dirs);
} /* switch_drive */

/*****************************************************************************/

LOCAL VOID switch_path (WINDOWP window, BYTE *path, WORD ob_dir, WORD ob_dirs)
{
  BYTE *p;
  LONG index, exact;

  busy_mouse ();
  if (window->object == selfile) get_filenames (path, suffix);
  get_pathnames (path);
  arrow_mouse ();
  strncpy (get_str (window->object, ob_dir), path, num_chars);
  draw_object (window, ob_dir);

  if (window->object == selfile) 
  {
    p       = use_editobj ? ed.text : get_str (window->object, FLNAME);
    index   = (*p == EOS) ? FAILURE : ListBoxFindString (window->object, FLNAMES, 0L, p);
    exact   = (*p == EOS) ? FAILURE : ListBoxFindStringExact (window->object, FLNAMES, 0L, p);

    ListBoxSetTopIndex (window->object, FLNAMES, index);
    ListBoxSetCurSel (window->object, FLNAMES, (ListBoxGetStyle (window->object, FLNAMES) & LBS_DRAWDISABLED) ? exact : index);
    ListBoxRedraw (window->object, FLNAMES);
  } /* if */

  ListBoxRedraw (window->object, ob_dirs);
} /* switch_path */

/*****************************************************************************/

LOCAL VOID set_filenamestr (WINDOWP window, BYTE *filename)
{
  MKINFO mk;

  if (use_editobj)
  {
    mk.mox = 256;
    mk.moy = 0;

    edit_obj (&ed, ED_EXIT, 0, NULL);
    strcpy (ed.text, filename);
    ed.actsize = strlen (filename);
    edit_obj (&ed, ED_INIT, 0, NULL);
    set_clip (TRUE, NULL);
    edit_obj (&ed, ED_HIDECURSOR, 0, NULL);
    edit_obj (&ed, ED_DRAW, 0, NULL);
    edit_obj (&ed, ED_SHOWCURSOR, 0, NULL);
    edit_obj (&ed, ED_SETCURSOR, 0, &mk);
  } /* if */
  else
  {
    strcpy (get_str (window->object, FLNAME), filename);
    draw_object (window, FLNAME);
    set_cursor (window, FLNAME, NIL);
  } /* else */
} /* set_filenamestr */

/*****************************************************************************/

LOCAL VOID get_filenames (BYTE *path, BYTE *suffix)
{
  LDTA     *dta;
  BOOLEAN  multiple;
  FULLNAME fullname;

  dta       = FGetDta ();
  num_files = 0;
  drive     = drives [driveinx].drive;
  multiple  = strpbrk (suffix, ";, ") != NULL;

  Dsetdrv (drive);
  set_path (path);
  strcpy (fullname, suffix);
  if (multiple) strcpy (fullname, "*.*");

  if (FsFirst (fullname, 0) == 0)
  {
    if (! multiple || match (suffix, dta->d_fname))
      num_files++;

    while (FsNext () == 0)
      if (! multiple || match (suffix, dta->d_fname))
        num_files++;
  } /* if */

  FsClose ();

  if (lfn)
    multiple = TRUE;				/* with long file names you cannot use the GEMDOS match code, do as with multiple suffixes */

  mem_free (filenames);
  filenames = NULL;

  mem_free (fileinx);
  fileinx = NULL;

  if (num_files > 0)
    if (((filenames = mem_alloc (num_files * sizeof (LDTA))) == NULL) || ((fileinx = mem_alloc (num_files * sizeof (WORD))) == NULL))
    {
      mem_free (filenames);
      filenames = NULL;

      mem_free (fileinx);
      fileinx = NULL;

      num_files = 0;
    } /* if */
    else
    {
      num_files = 0;

      if (FsFirst (fullname, 0) == 0)
      {
        if (! multiple || match (suffix, dta->d_fname))
        {
          filenames [num_files] = *dta;
          ModifyFileName (filenames [num_files].d_fname);
          fileinx [num_files] = num_files;
          num_files++;
        } /* if */

        while (FsNext () == 0)
          if (! multiple || match (suffix, dta->d_fname))
          {
            filenames [num_files] = *dta;
            ModifyFileName (filenames [num_files].d_fname);
            fileinx [num_files] = num_files;
            num_files++;
          } /* if, while */
      } /* if */

      FsClose ();
    } /* else, if */

  ListBoxSetCount (selfile, FLNAMES, num_files, NULL);
  ListBoxSetCurSel (selfile, FLNAMES, FAILURE);
  ListBoxSetTopIndex (selfile, FLNAMES, 0);
  sort_names ();
} /* get_filenames */

/*****************************************************************************/

LOCAL VOID get_pathnames (BYTE *path)
{
  LDTA     *dta;
  WORD     i;
  FULLNAME fullname;
  BYTE     *p;
  BYTE     pathsep [2];

  dta         = FGetDta ();
  num_dirs    = num_levels = 0;
  drive       = drives [driveinx].drive;
  pathsep [0] = PATHSEP;
  pathsep [1] = EOS;

  Dsetdrv (drive);
  set_path (path);

  if (FsFirst ("*.*", FA_SUBDIR) == 0)
  {
    if ((dta->d_attrib & FA_SUBDIR) && (strcmp (dta->d_fname, ".") != 0) && (strcmp (dta->d_fname, "..") != 0))
      num_dirs++;

    while (FsNext () == 0)
      if ((dta->d_attrib & FA_SUBDIR) && (strcmp (dta->d_fname, ".") != 0) && (strcmp (dta->d_fname, "..") != 0))
        num_dirs++;
  } /* if */

  FsClose ();

  for (i = 0; path [i] != EOS; i++)
    if (path [i] == PATHSEP)
      num_levels++;

  num_dirs += num_levels;

  mem_free (pathnames);
  pathnames = NULL;

  mem_free (pathinx);
  pathinx = NULL;

  if (num_dirs > 0)
    if (((pathnames = mem_alloc (num_dirs * sizeof (LDTA))) == NULL) || ((pathinx = mem_alloc (num_dirs * sizeof (WORD))) == NULL))
    {
      mem_free (pathnames);
      pathnames = NULL;

      mem_free (pathinx);
      pathinx = NULL;

      num_dirs = 0;
    } /* if */
    else
    {
      num_dirs = 0;

      strcpy (fullname, path);

      for (p = strtok (fullname, pathsep); p != NULL; p = strtok (NULL, pathsep))
      {
        strcpy (pathnames [num_dirs].d_fname, p);
        ModifyFileName (pathnames [num_dirs].d_fname);

        if (num_dirs == 0)
          strcat (pathnames [num_dirs].d_fname, pathsep);

        pathinx [num_dirs] = num_dirs;
        num_dirs++;
      } /* for */

      if (FsFirst ("*.*", FA_SUBDIR) == 0)
      {
        if ((dta->d_attrib & FA_SUBDIR) && (strcmp (dta->d_fname, ".") != 0) && (strcmp (dta->d_fname, "..") != 0))
        {
          pathnames [num_dirs] = *dta;
          ModifyFileName (pathnames [num_dirs].d_fname);
          pathinx [num_dirs] = num_dirs;
          num_dirs++;
        } /* if */

        while (FsNext () == 0)
          if ((dta->d_attrib & FA_SUBDIR) && (strcmp (dta->d_fname, ".") != 0) && (strcmp (dta->d_fname, "..") != 0))
          {
            pathnames [num_dirs] = *dta;
            ModifyFileName (pathnames [num_dirs].d_fname);
            pathinx [num_dirs] = num_dirs;
            num_dirs++;
          } /* if, while */
      } /* if */

      FsClose ();
    } /* else, if */

  ListBoxSetCount (selfile, FLDIRS, num_dirs, NULL);
  ListBoxSetCurSel (selfile, FLDIRS, FAILURE);
  ListBoxSetTopIndex (selfile, FLDIRS, 0);

  ListBoxSetCount (selpath, PTDIRS, num_dirs, NULL);
  ListBoxSetCurSel (selpath, PTDIRS, FAILURE);
  ListBoxSetTopIndex (selpath, PTDIRS, 0);

  sort_dirs ();
} /* get_pathnames */

/*****************************************************************************/

LOCAL WORD inx_from_drive (WORD drive)
{
  WORD i;

  for (i = 0; i < num_drives; i++)
    if (drives [i].drive == drive)
      return (i);

  return (FAILURE);
} /* inx_from_drive */

/*****************************************************************************/

LOCAL ICONSUFFIX *icon_from_suffix (BYTE *suffix)
{
  ICONSUFFIX *icon;
  WORD       inx;
  BYTE       *p, *q;
  LONGSTR    s;

  if ((p = strrchr (suffix, SUFFSEP)) != NULL)
    p++;
  else
    p = suffix;

  for (inx = 0, icon = icon_suffix_dyn; inx < num_icon_suffix_dyn; inx++, icon++)
  {
    strcpy (s, icon->suffix);

    for (q = strtok (s, ";, "); q != NULL; q = strtok (NULL, ";, "))
    {
      if (string_match (q, p, MAX_EXT) == 0)
        return (icon);
    } /* for */
  } /* for */

  for (inx = 0, icon = icon_suffix; inx < num_icon_suffix; inx++, icon++)
  {
    strcpy (s, icon->suffix);

    for (q = strtok (s, ";, "); q != NULL; q = strtok (NULL, ";, "))
    {
      if (string_match (q, p, MAX_EXT) == 0)
        return (icon);
    } /* for */
  } /* for */

  return (NULL);
} /* icon_from_suffix */

/*****************************************************************************/

LOCAL WORD inx_from_suffix (BYTE *suffix)
{
  WORD     inx, i;
  BYTE     *p;
  FULLNAME suff;

  for (inx = 0, p = file_parms.pszFilter; (p != NULL) && (*p != EOS); inx++)
  {
    p = strchr (p, '|');

    if (p != NULL)
    {
      p++;
      i = 0;
      while ((*p != EOS) && (*p != '|'))
        suff [i++] = *p++;

      suff [i] = EOS;

      if (*p != EOS)
        p++;

      if (stricmp (suffix, suff) == 0)
        return (inx);
    } /* if */
  } /* for */

  return (FAILURE);
} /* inx_from_suffix */

/*****************************************************************************/

LOCAL BYTE *suffix_from_inx (WORD inx, BYTE *suffix)
{
  WORD i;
  BYTE *p;

  p = file_parms.pszFilter;

  for (i = 0; i < 2 * inx; i++)
    p = strchr (p, '|') + 1;

  p = strchr (p, '|') + 1;

  i = 0;
  while ((*p != EOS) && (*p != '|'))
    suffix [i++] = *p++;

  suffix [i] = EOS;

  return (suffix);
} /* suffix_from_inx */

/*****************************************************************************/

LOCAL BYTE *desc_from_inx (WORD inx, BYTE *desc)
{
  WORD i;
  BYTE *p;

  p = file_parms.pszFilter;

  for (i = 0; i < 2 * inx; i++)
    p = strchr (p, '|') + 1;

  i = 0;
  while ((*p != EOS) && (*p != '|'))
    desc [i++] = *p++;

  desc [i] = EOS;

  return (desc);
} /* desc_from_inx */

/*****************************************************************************/

LOCAL VOID get_volume_name (WORD drive, BYTE *name)
{
  LDTA *dta;
  WORD drv;

  drv = Dgetdrv ();
  Dsetdrv (drive);
  set_path ("\\");

  name [0] = EOS;

  lfn = SwitchDomain (drive);
  dta = FGetDta ();

  if (lfn)
  {
    BYTE path [4];

    path [0] = 'A' + drive;
    path [1] = DRIVESEP;
    path [2] = PATHSEP;
    path [3] = EOS;

    Dreadlabel (path, name, sizeof (FULLNAME));
    ModifyFileName (name);
  } /* if */
  else
  {
    if (Fsfirst ("*.*", FA_VOLUME) == 0)
    {
      strcpy (name, dta->d_fname);
      ModifyFileName (name);
    } /* if */
  } /* else */

  Dsetdrv (drv);
} /* get_volume_name */

/*****************************************************************************/

LOCAL VOID sort_names (VOID)
{
  inxarray = filenames;
  qsort ((VOID *)fileinx, (SIZE_T)ListBoxGetCount (selfile, FLNAMES), sizeof (WORD), compare_files);
} /* sort_names */

/*****************************************************************************/

LOCAL VOID sort_dirs (VOID)
{
  WORD old;

  inxarray = pathnames;
  old      = file_order;

  if (file_order == BY_SIZE)			/* directories have no size */
    file_order = BY_NAME;

  qsort ((VOID *)&pathinx [num_levels], (SIZE_T)ListBoxGetCount (selfile, FLDIRS) - num_levels, sizeof (WORD), compare_files);

  file_order = old;
} /* sort_dirs */

/*****************************************************************************/

LOCAL INT compare_files (WORD *arg1, WORD *arg2)
{
  INT  cmp;
  LDTA *dta1, *dta2;
  BYTE *p1, *p2;

  dta1 = &inxarray [*arg1];
  dta2 = &inxarray [*arg2];

  switch (file_order)
  {
    case BY_NAME    : return (stricmp (dta1->d_fname, dta2->d_fname));
    case BY_TYPE    : p1 = strrchr (dta1->d_fname, SUFFSEP);
                      p2 = strrchr (dta2->d_fname, SUFFSEP);
                      if (p1 == NULL)
                        if (p2 == NULL)
                          return (stricmp (dta1->d_fname, dta2->d_fname));
                        else
                          return (-1);
                      else
                        if (p2 == NULL)
                          return (1);
                        else
                          if ((cmp = stricmp (p1, p2)) != 0)
                            return (cmp);
                          else
                            return (stricmp (dta1->d_fname, dta2->d_fname));
    case BY_DATE    : if (dta1->d_date != dta2->d_date)
                        return ((INT)dta2->d_date - (INT)dta1->d_date);
                      else
                        return ((INT)dta2->d_time - (INT)dta1->d_time);
    case BY_SIZE    : return (dta1->d_length > dta2->d_length ? -1 : dta1->d_length < dta2->d_length ? 1 : 0);
    case BY_NOTHING : return (*arg1 - *arg2);
    default         : return (0);
  } /* switch */
} /* compare_files */

/*****************************************************************************/

LOCAL VOID get_font_dialog (VOID)
{
  *font_parms.pFontDesc = fontdesc;
} /* get_font_dialog */

/*****************************************************************************/

LOCAL VOID set_font_dialog ()
{
  WORD     index;
  FONTNAME fontname;
  BYTE     s [6];

  fontdesc = *font_parms.pFontDesc;

  set_sizetable (font_parms.vdi_handle, fontdesc.font);

  for (index = max_fonts = 0; index < num_fonts; index++)
    if (((font_parms.ulFlags & (FONT_FLAG_SHOW_MONO | FONT_FLAG_SHOW_PROP | FONT_FLAG_SHOW_VECTOR | FONT_FLAG_SHOW_SYSTEM)) == 0) ||
         (font_parms.ulFlags & FONT_FLAG_SHOW_MONO) && fontinfo [index].mono ||
         (font_parms.ulFlags & FONT_FLAG_SHOW_PROP) && ! fontinfo [index].mono ||
         (font_parms.ulFlags & FONT_FLAG_SHOW_VECTOR) && (fontinfo [index].type != GDOS_BITMAPFONT) ||
         (font_parms.ulFlags & FONT_FLAG_SHOW_SYSTEM) && (fontinfo [index].font == FONT_SYSTEM))
      fonts [max_fonts++] = index;

  sort_fonts ();

  index = inx_from_fontlist (fontdesc.font);

  ListBoxSetCount (selfont, FNNAMES, max_fonts, NULL);
  ListBoxSetCurSel (selfont, FNNAMES, index);
  ListBoxSetTopIndex (selfont, FNNAMES, index);
  ListBoxGetText (selfont, FNNAMES, index, fontname);
  strcpy (get_str (selfont, FNNAME), fontname);

  old_point = fontdesc.point;
  index     = inx_from_point (fontdesc.point);

  ListBoxSetCount (selfont, FNPOINTS, num_points, NULL);
  ListBoxSetCurSel (selfont, FNPOINTS, index);
  ListBoxSetTopIndex (selfont, FNPOINTS, index);

  sprintf (s, "%d", fontdesc.point);
  strcpy (get_str (selfont, FNPOINT), s);

  ListBoxSetCurSel (selfont, FNCOLOR, fontdesc.color);
  ListBoxSetTopIndex (selfont, FNCOLOR, fontdesc.color);

  set_checkbox (selfont, FNTHICK, fontdesc.effects & TXT_THICKENED);
  set_checkbox (selfont, FNLIGHT, fontdesc.effects & TXT_LIGHT);
  set_checkbox (selfont, FNSKEWED, fontdesc.effects & TXT_SKEWED);
  set_checkbox (selfont, FNUNDER, fontdesc.effects & TXT_UNDERLINED);
  set_checkbox (selfont, FNOUTLN, fontdesc.effects & TXT_OUTLINED);
} /* set_font_dialog */

/*****************************************************************************/

LOCAL LONG fonts_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP        window;
  LB_OWNERDRAW   *lb_ownerdraw;
  RECT           r;
  WORD           col;
  BYTE           *text;
  ICON           *icon;
  LOCAL FONTNAME fontname;
  LOCAL BYTE     s [6];

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)fontinfo [fonts [index]].fontname);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (gl_hbox <= 8) ? 0 : fonts4_icon.width / 4 + 4;
                            icon = (gl_hbox <= 8) ? NULL : (colors < 16) ? &fonts1_icon : &fonts4_icon;
                            col  = (fontinfo [fonts [index]].type == GDOS_TRUETYPEFONT) ? 3 : (fontinfo [fonts [index]].type == GDOS_VECTORFONT) ? 2 : fontinfo [fonts [index]].mono ? 0 : 1;
                            DrawOwnerMultiIcon (lb_ownerdraw, &r, icon, text, (icon == NULL) ? ListBoxGetLeftOffset (tree, obj) : 0, 1, 4, 0, col);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxGetText (tree, obj, index, fontname);
                          strcpy (get_str (tree, FNNAME), fontname);
                          draw_object (window, FNNAME);
                          set_cursor (window, FNNAME, NIL);
                          fontdesc.font = fontinfo [fonts [index]].font;
                          set_sizetable (font_parms.vdi_handle, fontdesc.font);
                          ListBoxSetCount (tree, FNPOINTS, num_points, NULL);

                          if ((index = inx_from_point (fontdesc.point)) != FAILURE)
                            fontdesc.point = points [index];

                          ListBoxSetCurSel (tree, FNPOINTS, index);
                          ListBoxSetTopIndex (tree, FNPOINTS, index);
                          ListBoxRedraw (tree, FNPOINTS);

                          if (index != FAILURE)
                          {
                            ListBoxGetText (tree, FNPOINTS, ListBoxGetCurSel (tree, FNPOINTS), s);
                            strcpy (get_str (tree, FNPOINT), s);
                            draw_object (window, FNPOINT);
                          } /* if */

                          if (((*get_str (window->object, FNNAME) == EOS) || (*get_str (window->object, FNPOINT) == EOS) || (ListBoxGetCurSel (window->object, FNNAMES) == FAILURE)) == ! is_state (window->object, FNOK, DISABLED))
                          {
                            flip_state (window->object, FNOK, DISABLED);
                            draw_object (window, FNOK);
                          } /* if */

                          draw_font (window);
                          break;
    case LBN_DBLCLK     : window->exit_obj = FNOK;
                          break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* fonts_callback */

/*****************************************************************************/

LOCAL LONG sizes_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  BYTE         *text;
  LOCAL BYTE   s [6];
  LOCAL BYTE   size [6];

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : sprintf (size, "%d", points [index]);
                          return ((LONG)size);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = 0;
                            DrawOwnerIcon (lb_ownerdraw, &r, NULL, text, ListBoxGetLeftOffset (tree, obj));
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxGetText (tree, obj, index, s);
                          strcpy (get_str (tree, FNPOINT), s);
                          draw_object (window, FNPOINT);
                          set_cursor (window, FNPOINT, NIL);
                          fontdesc.point = points [index];

                          if (((*get_str (window->object, FNNAME) == EOS) || (*get_str (window->object, FNPOINT) == EOS) || (ListBoxGetCurSel (window->object, FNNAMES) == FAILURE)) == ! is_state (window->object, FNOK, DISABLED))
                          {
                            flip_state (window->object, FNOK, DISABLED);
                            draw_object (window, FNOK);
                          } /* if */

                          draw_font (window);
                          break;
    case LBN_DBLCLK     : window->exit_obj = FNOK;
                          break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* sizes_callback */

/*****************************************************************************/

LOCAL LONG color_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  BYTE         *text;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)color_strings [index]);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.x++;
                            r.y++;
                            r.w  = 2 * gl_wbox;
                            r.h -= 2;

                            r.x++;
                            if (visible_part) r.y++;
                            r.w -= 2;
                            if (visible_part) r.h -= 2;
                            DrawOwnerColor (lb_ownerdraw, &r, (WORD)index, text, 2);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          fontdesc.color = (WORD)index;
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* color_callback */

/*****************************************************************************/

LOCAL VOID draw_font (WINDOWP window)
{
  LOCAL WORD wchar, hchar, wbox, hbox, inx;
  LOCAL WORD x, y, w, h, xdiff, ydiff;
  LOCAL WORD minimum, maximum, width;
  LOCAL WORD extent [8], distances [5], effects [3];
  LOCAL RECT r, old_clip;
  LOCAL BYTE *text;

  hide_mouse ();

  text = FONT_STRING;
  inx  = inx_from_font (fontdesc.font);

  text_default (vdi_handle);
  vst_font (vdi_handle, fontdesc.font);

  if ((inx != FAILURE) && (fontinfo [inx].type == GDOS_BITMAPFONT))
    vst_point (vdi_handle, fontdesc.point, &wchar, &hchar, &wbox, &hbox);
  else
    vst_arbpt (vdi_handle, fontdesc.point, &wchar, &hchar, &wbox, &hbox);

  vst_color (vdi_handle, fontdesc.color);
  vst_effects (vdi_handle, fontdesc.effects);
  vqt_extent (vdi_handle, text, extent);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

  wbox = extent [2] - extent [0] + effects [2];
  hbox = extent [5] - extent [3];

  objc_offset (window->object, FNSAMPLE, &x, &y);
  w = window->object [FNSAMPLE].ob_width;
  h = window->object [FNSAMPLE].ob_height;

  if (OB_STATE (window->object, FNSAMPLE) & IS_ROUNDBORDER)
  {
    x += 6;
    y += 6;
    w -= 12;
    h -= 12;
  } /* if */

  xywh2rect (x, y, w, h, &r);

  xdiff = w - wbox;
  if (xdiff < 0) xdiff = 0;

  ydiff = h - hbox;
  if (ydiff < 0) ydiff = 0;

  if (is_top (window))
    set_clip (TRUE, &r);

  if (rc_intersect (&clip, &r))
  {
    old_clip = clip;
    set_clip (TRUE, &r);
    vswr_mode (vdi_handle, MD_REPLACE);
    objc_draw (window->object, ROOT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

    vswr_mode (vdi_handle, MD_TRANS);

    if (ListBoxGetCurSel (window->object, FNNAMES) != FAILURE)
      v_gtext (vdi_handle, x + xdiff / 2, y + ydiff / 2, text);

    set_clip (TRUE, &old_clip);
  } /* if */

  show_mouse ();
} /* draw_font */

/*****************************************************************************/

LOCAL VOID click_font_dialog (WINDOWP window, MKINFO *mk)
{
  LONG     item;
  FONTNAME fontname;

  switch (window->exit_obj)
  {
    case FNNAMES  :
    case FNPOINTS : ListBoxClick (window->object, window->exit_obj, mk);
                    if (window->exit_obj == FNOK)		/* double clicked on a list box string */
                    {
                      get_font_dialog ();
                      exit_button    = window->exit_obj;
                      window->flags |= WI_DLCLOSE;
                    } /* if */
                    break;
    case FNTHICK  : fontdesc.effects ^= TXT_THICKENED;
                    draw_font (window);
                    break;
    case FNLIGHT  : fontdesc.effects ^= TXT_LIGHT;
                    draw_font (window);
                    break;
    case FNSKEWED : fontdesc.effects ^= TXT_SKEWED;
                    draw_font (window);
                    break;
    case FNUNDER  : fontdesc.effects ^= TXT_UNDERLINED;
                    draw_font (window);
                    break;
    case FNOUTLN  : fontdesc.effects ^= TXT_OUTLINED;
                    draw_font (window);
                    break;
    case FNCOLOR  : ListBoxSetComboRect (window->object, window->exit_obj, NULL, min (colors, 16));
                    if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                    {
                      fontdesc.color = (WORD)item;
                      draw_font (window);
                    } /* if */
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case FNORDER  : ListBoxSetComboRect (window->object, window->exit_obj, NULL, MAX_FONT_ORDER);
                    if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                    {
                      switch (item)
                      {
                        case 0 : item = BY_NAME;    break;
                        case 1 : item = BY_TYPE;    break;
                        case 2 : item = BY_NOTHING; break;
                      } /* switch */

                      if ((WORD)item != font_order)
                      {
                        font_order = (WORD)item;

                        if ((item = ListBoxGetCurSel (window->object, FNNAMES)) != FAILURE)
                          ListBoxGetText (window->object, FNNAMES, item, fontname);

                        busy_mouse ();
                        sort_fonts ();
                        arrow_mouse ();

                        if (item != FAILURE)
                          item = ListBoxFindStringExact (window->object, FNNAMES, 0L, fontname);

                        ListBoxSetCurSel (window->object, FNNAMES, item);
                        ListBoxSetTopIndex (window->object, FNNAMES, item);
                        ListBoxRedraw (window->object, FNNAMES);
                      } /* if */
                    } /* if */
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case FNOK     : get_font_dialog ();
                    exit_button = window->exit_obj;
                    break;
    case FNCANCEL : exit_button = window->exit_obj;
                    break;
    case FNHELP   : call_helpfunc (font_parms.pszHelpID);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_font_dialog */

/*****************************************************************************/

LOCAL BOOLEAN key_font_dialog (WINDOWP window, MKINFO *mk)
{
  BYTE *p;
  LONG index, old_inx, old_sel;
  BYTE s [6];

  switch (window->edit_obj)
  {
    case FNNAME  : p       = get_str (window->object, window->edit_obj);
                   index   = (*p == EOS) ? FAILURE : ListBoxFindString (window->object, FNNAMES, 0L, p);
                   old_inx = ListBoxGetTopIndex (window->object, FNNAMES);
                   old_sel = ListBoxGetCurSel (window->object, FNNAMES);

                   if ((mk->scan_code == UP) || (mk->scan_code == DOWN))
                     ListBoxKey (window->object, FNNAMES, mk);
                   else
                   {
                     ListBoxSetTopIndex (window->object, FNNAMES, index);
                     ListBoxSetCurSel (window->object, FNNAMES, index);

                     if ((old_inx != ListBoxGetTopIndex (window->object, FNNAMES)) || (old_sel != ListBoxGetCurSel (window->object, FNNAMES)))
                       ListBoxRedraw (window->object, FNNAMES);

                     if ((index != FAILURE) && (index != old_sel))
                     {
                        fontdesc.font = fontinfo [fonts [index]].font;
                        set_sizetable (font_parms.vdi_handle, fontdesc.font);
                        ListBoxSetCount (window->object, FNPOINTS, num_points, NULL);

                        if ((index = inx_from_point (fontdesc.point)) != FAILURE)
                          fontdesc.point = points [index];

                        ListBoxSetCurSel (window->object, FNPOINTS, index);
                        ListBoxSetTopIndex (window->object, FNPOINTS, index);
                        ListBoxRedraw (window->object, FNPOINTS);

                        if (index != FAILURE)
                        {
                          ListBoxGetText (window->object, FNPOINTS, ListBoxGetCurSel (window->object, FNPOINTS), s);
                          strcpy (get_str (window->object, FNPOINT), s);
                          draw_object (window, FNPOINT);
                        } /* if */
                      } /* if */

                      if (index != old_sel)
                        draw_font (window);
                   } /* else */
                   break;
    case FNPOINT : p = get_str (window->object, window->edit_obj);

                   if (*p == EOS)
                   {
                     fontdesc.point = 0;
                     index          = FAILURE;
                   } /* if */
                   else
                   {
                     fontdesc.point = atoi (p);
                     sprintf (s, "%d", fontdesc.point);
                     index = ListBoxFindStringExact (window->object, FNPOINTS, 0L, s);
                   } /* else */

                   old_inx = ListBoxGetTopIndex (window->object, FNPOINTS);
                   old_sel = ListBoxGetCurSel (window->object, FNPOINTS);

                   if ((mk->scan_code == UP) || (mk->scan_code == DOWN))
                     ListBoxKey (window->object, FNPOINTS, mk);
                   else
                   {
                     ListBoxSetTopIndex (window->object, FNPOINTS, index);
                     ListBoxSetCurSel (window->object, FNPOINTS, index);

                     if ((old_inx != ListBoxGetTopIndex (window->object, FNPOINTS)) || (old_sel != ListBoxGetCurSel (window->object, FNPOINTS)))
                       ListBoxRedraw (window->object, FNPOINTS);

                     if ((index != FAILURE) && (index != old_sel))
                       fontdesc.point = points [index];
                   } /* else */

                   if (old_point != fontdesc.point)
                   {
                     draw_font (window);
                     old_point = fontdesc.point;
                   } /* if */
                   break;
  } /* switch */

  if (((*get_str (window->object, FNNAME) == EOS) || (*get_str (window->object, FNPOINT) == EOS) || (ListBoxGetCurSel (window->object, FNNAMES) == FAILURE)) == ! is_state (window->object, FNOK, DISABLED))
  {
    flip_state (window->object, FNOK, DISABLED);
    draw_object (window, FNOK);
  } /* if */

  return (FALSE);
} /* key_font_dialog */

/*****************************************************************************/

LOCAL VOID set_fonttable (WORD vdi_handle)
{
/* [GS] 5.1f Start */
	WORD font_format, flags;
/* Ende */
  WORD     font, inx;
  FONTNAME fontname;

  busy_mouse ();

  mem_free (fontinfo);
  fontinfo = NULL;

  mem_free (fonts);
  fonts = NULL;

  fontinfo = mem_alloc (num_fonts * sizeof (FONTINFO));
  fonts    = mem_alloc (num_fonts * sizeof (WORD));

  if ((fontinfo == NULL) || (fonts == NULL))
  {
    mem_free (fontinfo);
    fontinfo = NULL;

    mem_free (fonts);
    fonts = NULL;

    num_fonts = 0;
  } /* if */
  else
    for (inx = 0; inx < num_fonts; inx++)
    {
      fontname [MAX_FONTNAME] = EOS;
/* [GS] 5.1f Start */
			if ( nvdi_version >=0x0302 )
				font = vqt_ext_name ( vdi_handle, inx + 1, fontname, &font_format, &flags );
			else
      {
      	font = vqt_name (vdi_handle, inx + 1, fontname);
      	flags = -1;
      }
/* Ende; alt:
      font                    = vqt_name (vdi_handle, inx + 1, fontname);
*/

      strncpy (fontinfo [inx].fontname, fontname, MAX_FONTNAME);
      fontinfo [inx].fontname [MAX_FONTNAME] = EOS;

      if ((fontinfo [inx].fontname [0] == EOS) || (font == FONT_SYSTEM))
        strcpy (fontinfo [inx].fontname, "System");

      fontinfo [inx].font = font;
      fontinfo [inx].type = (fontname [MAX_FONTNAME] == '\001') ? GDOS_VECTORFONT : (fontname [MAX_FONTNAME] == '\002') ? GDOS_TRUETYPEFONT : GDOS_BITMAPFONT;
/* [GS] 5.1f Start */
			if ( flags > -1 )
	      fontinfo [inx].mono = (flags & 0x01) ? TRUE : FALSE;
			else
/* Ende  */
	      fontinfo [inx].mono = FontIsMonospaced (vdi_handle, font);
      fonts [inx]         = inx;
    } /* for, else */

  arrow_mouse ();
} /* set_fonttable */

/*****************************************************************************/

LOCAL VOID set_sizetable (WORD vdi_handle, WORD font)
{
  WORD point, new_point;
  WORD char_w, char_h, cell_w, cell_h;
  SET  size;

  setclr (size);
  vst_font (vdi_handle, font);
  new_point = SETMAX + 1;

  do
  {
    point     = --new_point;
    new_point = vst_point (vdi_handle, point, &char_w, &char_h, &cell_w, &cell_h);
    setincl (size, new_point);
  } while (new_point <= point);

  for (point = num_points = 0; (point <= SETMAX) && (num_points < MAX_POINTS); point++)
    if (setin (size, point))
      points [num_points++] = point;
} /* set_sizetable */

/*****************************************************************************/

LOCAL WORD inx_from_fontlist (WORD font)
{
  WORD i;

  for (i = 0; i < max_fonts; i++)
    if (fontinfo [fonts [i]].font == font)
      return (i);

  return (FAILURE);
} /* inx_from_fontlist */

/*****************************************************************************/

LOCAL WORD inx_from_font (WORD font)
{
  WORD i;

  for (i = 0; i < num_fonts; i++)
    if (fontinfo [i].font == font)
      return (i);

  return (FAILURE);
} /* inx_from_font */

/*****************************************************************************/

LOCAL WORD inx_from_point (WORD point)
{
  WORD i;

  for (i = 0; i < num_points; i++)
    if (points [i] == point)
      return (i);

  return (FAILURE);
} /* inx_from_point */

/*****************************************************************************/

LOCAL VOID sort_fonts (VOID)
{
  qsort ((VOID *)fonts, (SIZE_T)max_fonts, sizeof (WORD), compare_fonts);
} /* sort_fonts */

/*****************************************************************************/

LOCAL INT compare_fonts (WORD *arg1, WORD *arg2)
{
  INT      cmp;
  FONTINFO *f1, *f2;

  f1 = &fontinfo [*arg1];
  f2 = &fontinfo [*arg2];

  switch (font_order)
  {
    case BY_NAME    : return (stricmp (f1->fontname, f2->fontname));
    case BY_TYPE    : if ((cmp = f2->type - f1->type) != 0)
                        return (cmp);
                      else
                        if ((cmp = f1->mono - f2->mono) != 0)
                          return (cmp);
                        else
                          return (stricmp (f1->fontname, f2->fontname));
    case BY_NOTHING : return (*arg1 - *arg2);
    default         : return (0);
  } /* switch */
} /* compare_fonts */

/*****************************************************************************/

LOCAL BOOLEAN match (BYTE *suffix, BYTE *filename)
{
  FULLNAME suffixes;
  BYTE     *p;

  strcpy (suffixes, suffix);

  for (p = strtok (suffixes, ";, "); p != NULL; p = strtok (NULL, ";, "))
    if (file_match (p, filename))
      return (TRUE);

  return (FALSE);
} /* match */

/******************************************************************************/

LOCAL BOOLEAN file_match (BYTE *s1, BYTE *s2)
{
  FULLNAME name1, name2, ext1, ext2;
  BYTE     *p;

  if ((p = strchr (s1, '.')) == NULL)
  {
    strcpy (name1, s1);
    ext1 [0] = EOS;
  } /* if */
  else
  {
    *p = EOS;
    strcpy (name1, s1);
    strcpy (ext1, p + 1);
    *p = '.';
  } /* else */

  if ((p = strchr (s2, '.')) == NULL)
  {
    strcpy (name2, s2);
    ext2 [0] = EOS;
  } /* if */
  else
  {
    *p = EOS;
    strcpy (name2, s2);
    strcpy (ext2, p + 1);
    *p = '.';
  } /* else */

  return ((string_match (name1, name2, MAX_FILENAME) == 0) && (string_match (ext1, ext2, MAX_EXT) == 0));
} /* file_match */

/******************************************************************************/

LOCAL INT string_match (BYTE *s1, BYTE *s2, INT len)
{
  REG INT l1, l2, i;
  REG INT c1, c2;

  l1 = strlen (s1);
  l2 = strlen (s2);

  for (i = 0; i < len; i++)
  {
    c1 = (i < l1) ? ch_upper (s1 [i]) : ' ';
    c2 = (i < l2) ? ch_upper (s2 [i]) : ' ';

    if (c1 == WILD_CHARS)
      return (0);

    if (c1 == WILD_CHAR)
      c1 = c2;

    if (c1 != c2)
      return (c1 - c2);
  } /* for */

  return (0);
} /* string_match */

/*****************************************************************************/

LOCAL VOID GetSystemInfo (VOID)
{
  WORD       drv, driveinx, num_mappings;
  LONG       drivemap, num_bytes;
  BYTE       *pInf, *p, *q, *pNames;
  BYTE       s [2], ch;
  LONGSTR    szLine;
  ICONSUFFIX *pSuff;
  FULLNAME   filename;
  BOOLEAN    get_name;

  get_name = system_inf == NULL;	/* default action */
  drivemap = Dsetdrv (Dgetdrv ());

  for (drv = 0, num_drives = 0; drv < MAX_DRIVES; drv++)
    if (drivemap & (1L << drv))
    {
      drives [num_drives].drive    = drv;
      drives [num_drives].type     = drv < 2 ? DRIVE_FLOPPY : DRIVE_HARD;
      drives [num_drives].name [0] = EOS;

      if (get_name)
        if (drv >= 2)
          get_volume_name (drv, drives [num_drives].name);

      num_drives++;
    } /* if, for */

  if ((pInf = system_inf) != NULL)
  {
    get_name = GetProfileBool (system_inf, "System", "GetVolumeNames", TRUE);

    if (FindSection (pInf, SECTION_DRIVES) != NULL)		/* read drive descriptions from inf file */
      for (ch = 'A', s [0] = ch, s [1] = EOS; ch <= 'Z'; ch++, s [0] = ch)
      {
        GetKeyVal (pInf, SECTION_DRIVES, s, szLine, sizeof (szLine));

        if (szLine [0] != EOS)
        {
          drv      = ch - 'A';
          driveinx = inx_from_drive (drv);

          if (driveinx != FAILURE)
          {
            drives [driveinx].drive    = drv;
            drives [driveinx].type     = DriveTypeFromDesc (szLine);
            drives [driveinx].name [0] = EOS;

            if (get_name)
              if (drives [driveinx].type != DRIVE_FLOPPY)
                get_volume_name (drv, drives [driveinx].name);
          } /* if */
        } /* if */
      } /* for, if */

    if ((gl_hbox > 8) && ((p = FindSection (pInf, SECTION_ICON_MAPPINGS)) != NULL))
    {
      num_bytes    = 0;
      num_mappings = 0;

      while ((p = GetNextLine (p, szLine, sizeof (szLine))) != NULL)
        if (szLine [0] != EOS)
          if ((q = strchr (szLine, '=')) != NULL)
          {
            *q         = EOS;
            num_bytes += strlen (szLine) + 1;
            num_mappings++;
          } /* if, if, while */

      icon_names_dyn  = mem_alloc (num_bytes);
      icon_suffix_dyn = mem_alloc (num_mappings * sizeof (ICONSUFFIX));

      if ((icon_names_dyn != NULL) && (icon_suffix_dyn != NULL))
      {
        pNames       = icon_names_dyn;
        pSuff        = icon_suffix_dyn;
        num_mappings = 0;
        p            = FindSection (pInf, SECTION_ICON_MAPPINGS);

        while ((p = GetNextLine (p, szLine, sizeof (szLine))) != NULL)
          if (szLine [0] != EOS)
            if ((q = strchr (szLine, '=')) != NULL)
            {
              strcpy (filename, SYSTEM_DIR);
              strcat (filename, q + 1);
              *q = EOS;

              strcpy (pNames, szLine);

              if (ReadIcon (filename, pNames, pSuff))
              {
                pNames += strlen (szLine) + 1;
                pSuff++;
                num_mappings++;
              } /* if */
            } /* if, if, while */

        num_icon_suffix_dyn = num_mappings;
      } /* if */
    } /* if */
  } /* if */
} /* GetSystemInfo */

/*****************************************************************************/

LOCAL WORD DriveTypeFromDesc (BYTE *pszDesc)
{
  WORD i;

  for (i = DRIVE_FLOPPY; i <= DRIVE_RAM; i++)
    if (strcmpi (drive_desc [i], pszDesc) == 0)
      return (i);

  return (DRIVE_FLOPPY);
} /* DriveTypeFromDesc */

/*****************************************************************************/

LOCAL BOOLEAN ReadIcon (BYTE *pFileName, BYTE *pSuffix, ICONSUFFIX *pIconSuffix)
{
  BOOLEAN  ok;
  FULLNAME filename;
  UBYTE    *mask, *data1, *data4;

  ok = TRUE;

  strcpy (filename, pFileName);
  strcat (filename, "m.img");

  mask = ReadImage (filename);

  strcpy (filename, pFileName);
  strcat (filename, "1.img");

  data1 = ReadImage (filename);

  strcpy (filename, pFileName);
  strcat (filename, "4.img");

  data4 = ReadImage (filename);

  pIconSuffix->suffix  = pSuffix;
  ok                  &= BuildIcon (&pIconSuffix->icon1, mask, data1);
  ok                  &= BuildIcon (&pIconSuffix->icon4, mask, data4);

  mem_free (mask);
  mem_free (data1);
  mem_free (data4);

  return (ok && (data1 != NULL) && (data4 != NULL));
} /* ReadIcon */

/*****************************************************************************/

LOCAL UBYTE *ReadImage (BYTE *pFileName)
{
  UBYTE *buffer;
  HFILE handle;
  LONG  len;

  buffer = NULL;
  handle = file_open (pFileName, O_RDONLY);

  if (handle >= 0)
  {
    len = file_length (pFileName);

    if ((buffer = mem_alloc (len)) != NULL)
      if (file_read (handle, len, buffer) != len)
      {
        mem_free (buffer);
        buffer = NULL;
      } /* if, if */

    file_close (handle);
  } /* if */

  return (buffer);
} /* ReadImage */

/*****************************************************************************/

LOCAL LONG     hDir = FAILURE;
LOCAL FULLNAME szMatchFileName;
LOCAL INT      iFileAttr;
LOCAL LDTA     dta;

#ifndef __ACSTOS__
/*****************************************************************************/

LOCAL LONG Dxreaddir (INT len, LONG dirhandle, BYTE *buf, XATTR *xattr, LONG *xr)
{
  return (gemdos (0x142, len, dirhandle, buf, xattr, xr));
} /* Dxreaddir */

/*****************************************************************************/

LOCAL LONG Dreadlabel (CONST BYTE *path, BYTE *label, WORD length)
{
  return (gemdos (338, path, label, length));
} /* Dreadlabel */
#endif

/*****************************************************************************/

LOCAL LDTA *FGetDta (VOID)
{
  return (lfn ? &dta : (LDTA *)Fgetdta ());
} /* FGetDta */

/*****************************************************************************/

LOCAL INT FsFirst (CONST BYTE *pFileName, INT iAttr)
{
  INT      iResult;
  FULLNAME szFileName;
  BYTE     *p;
  XATTR    xattr;
  LONG     xr;

  if (lfn)
  {
    strcpy (szMatchFileName, pFileName);

    iResult   = FAILURE;
    iFileAttr = iAttr;
    p         = szFileName + sizeof (LONG);
    hDir      = Dopendir (".", 0);

    if (hDir >= 0)
      while (Dxreaddir (sizeof (szFileName), hDir, szFileName, &xattr, &xr) == E_OK)
        if ((iFileAttr == 0) && ! (xattr.attr & (FA_VOLUME | FA_SUBDIR)) || (iFileAttr & xattr.attr))
        {
          iResult      = 0;
          dta.d_attrib = xattr.attr;
          dta.d_time   = xattr.mtime;
          dta.d_date   = xattr.mdate;
          dta.d_length = xattr.size;
          strcpy (dta.d_fname, p);
          break;
        } /* if, while, if */
  } /* if */
  else
    iResult = Fsfirst (pFileName, iAttr);

  return (iResult);
} /* FsFirst */

/*****************************************************************************/

LOCAL INT FsNext (VOID)
{
  INT      iResult;
  FULLNAME szFileName;
  BYTE     *p;
  XATTR    xattr;
  LONG     xr;

  if (lfn)
  {
    iResult = FAILURE;
    p       = szFileName + sizeof (LONG);

    if (hDir >= 0)
      while (Dxreaddir (sizeof (szFileName), hDir, szFileName, &xattr, &xr) == E_OK)
        if ((iFileAttr == 0) && ! (xattr.attr & (FA_VOLUME | FA_SUBDIR)) || (iFileAttr & xattr.attr))
        {
          iResult      = 0;
          dta.d_attrib = xattr.attr;
          dta.d_time   = xattr.mtime;
          dta.d_date   = xattr.mdate;
          dta.d_length = xattr.size;
          strcpy (dta.d_fname, p);
          break;
        } /* if, while, if */
  } /* if */
  else
    iResult = Fsnext ();

  return (iResult);
} /* FsNext */

/*****************************************************************************/

LOCAL VOID FsClose (VOID)
{
  if (lfn)
  {
    Dclosedir (hDir);
    hDir = FAILURE;
  } /* if */
} /* FsClose */

/*****************************************************************************/

LOCAL VOID ModifyFileName (BYTE *pFileName)
{
  if (*pFileName != EOS)
    if (lfn)
    {
      if (IsOldFileName (pFileName))
        str_lower (pFileName + 1);
    } /* if */
    else
      str_lower (pFileName);
} /* ModifyFileName */

/*****************************************************************************/

LOCAL VOID ModifyPathName (BYTE *pPathName)
{
  FULLNAME szPathName;
  FULLNAME szResult;
  BYTE     szPathSep [2];
  BYTE     *p;

  if (*pPathName != EOS)
    if (lfn)
    {
      szPathSep [0] = PATHSEP;
      szPathSep [1] = EOS;
      szResult [0]  = EOS;

      strcpy (szPathName, pPathName);

      for (p = strtok (szPathName, szPathSep); p != NULL; p = strtok (NULL, szPathSep))
      {
        ModifyFileName (p);
        strcat (szResult, p);
        strcat (szResult, szPathSep);
      } /* for */

      strcpy (pPathName, szResult);
    } /* if */
    else
      str_lower (pPathName);
} /* ModifyPathName */

/*****************************************************************************/

LOCAL VOID ShortenFileName (BYTE *pFileName)
{
  BYTE     *p;
  FILENAME szFileName;
  EXT      szExt;

  if (! lfn)
    if ((p = strchr (pFileName, SUFFSEP)) == NULL)
      pFileName [8] = EOS;
    else
    {
      *p = EOS;
      strcpy (szFileName, pFileName);
      strcpy (szExt, p + 1);

      szFileName [8] = EOS;
      szExt [3]      = EOS;

      sprintf (pFileName, "%s%c%s", szFileName, SUFFSEP, szExt);
    } /* else, if */
} /* ShortenFilename */

/*****************************************************************************/

LOCAL BOOLEAN IsOldFileName (CONST BYTE *pFileName)
{
  FULLNAME szFileName, szUpperFileName;
  EXT      szExt, szUpperExt;
  BYTE     *p;

  strcpy (szFileName, pFileName);

  if ((p = strchr (szFileName, '.')) == NULL)
    szExt [0] = EOS;
  else
  {
    *p = EOS;
    strcpy (szExt, p + 1);
  } /* else */

  strcpy (szUpperFileName, szFileName);
  str_upper (szUpperFileName);

  strcpy (szUpperExt, szExt);
  str_upper (szUpperExt);

  return ((strlen (szFileName) <= 8) && (strlen (szExt) <= 3) && (strcmp (szFileName, szUpperFileName) == 0) && (strcmp (szExt, szUpperExt) == 0));
} /* IsOldFileName */

/******************************************************************************/

LOCAL BOOLEAN SwitchDomain (INT iDrive)
{
  BOOLEAN bLFN;
  LONG    lErr;
  BYTE    szDrive [4];

  szDrive [0] = 'A' + iDrive;
  szDrive [1] = DRIVESEP;
  szDrive [2] = PATHSEP;
  szDrive [4] = EOS;

  lErr = Dpathconf (szDrive, 3);
  bLFN = (lErr != -32) && (Dpathconf (szDrive, 5) != 2);

  return (bLFN);
} /* SwitchDomain */

/******************************************************************************/


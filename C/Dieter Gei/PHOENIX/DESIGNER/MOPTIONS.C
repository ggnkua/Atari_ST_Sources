/*****************************************************************************
 *
 * Module : MOPTIONS.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the config & params dialog box and load/save config.
 *
 * History:
 * 29.06.03: ccp_ext wird erst nachdem Setzen des Menhacken ver„ndert.
 * 05.12.02: Beim Auslesen des Config Dialog wird das Temp-Verzeichnis nicht
 *           automatisch in Grossbuchtaben gewandelt.
 * 19.03.97: Call to save_desktop added, variables cfg_path, cfg_name moved to root.h
 * 15.11.95: Don't show error in mload_config if fopen doesn't work
 * 31.10.95: Using new syntax for inf files
 * 02.05.94: Format of first fprintf in msave_config corrected
 * 07.03.94: Test on eof in text_rdln in mload_config added
 * 21.02.94: Loading and saving of use_std_fs moved to user interface section
 * 16.12.93: GetPathNameDialog used to get path name
 * 24.11.93: New file selector box used
 * 20.11.93: Loading and saving of use_std_fs added, old mselfont.h replaced with CommDlg functions
 * 18.11.93: GetFontDialog used instead of mselfont
 * 16.11.93: Draw font name and size if font selected
 * 04.11.93: LoadFonts and UnloadFOnts in CommDlg used
 * 24.10.93: Error in mload_config fixed in format string
 * 16.10.93: Fix desktop pattern for monochrome added
 * 14.10.93: Vesioning added, loading/saving of user interface added
 * 11.10.93: Dialog mconfmore deleted
 * 03.10.93: Keyboard interface for comboboxes improved
 * 27.09.93: Loading and saving of variables color_desktop, pattern_desktop and use_3d added
 * 24.09.93: New dialog mconfmore added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"
#include "root.h"

#include "commdlg.h"
#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "menu.h"
#include "mfile.h"
#include "resource.h"
#include "base.h"
#include "mask.h"

#include "export.h"
#include "moptions.h"

/****** DEFINES **************************************************************/

#define CRYPT(pass, l)  (0xE5 ^ pass [l] ^ (0x10 + l))
#define FONTNAME_LENGTH 32		/* see resource file */
#define MAX_PATH        40		/* see resource file */

#define VERSION		"4.0"		/* version number */
#define OLD_VERSION	"PHOENIX 3.5"	/* version number for old INF files */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL BYTE *szGlobal        = "Global";
LOCAL BYTE *szOpenParms     = "OpenParms";
LOCAL BYTE *szConfig        = "Config";
LOCAL BYTE *szUserInterface = "UserInterface";
LOCAL BYTE *szDesktopIcons  = "DesktopIcons";
LOCAL BYTE *szOpenDbs       = "OpenDbs";

/****** FUNCTIONS ************************************************************/

LOCAL VOID    get_config     (VOID);
LOCAL VOID    set_config     (VOID);
LOCAL VOID    click_config   (WINDOWP window, MKINFO *mk);
LOCAL BOOLEAN key_config     (WINDOWP window, MKINFO *mk);

LOCAL VOID    get_params     (VOID);
LOCAL VOID    set_params     (VOID);
LOCAL VOID    click_params   (WINDOWP window, MKINFO *mk);
LOCAL BOOLEAN key_params     (WINDOWP window, MKINFO *mk);

LOCAL BOOLEAN any_ed_empty   (OBJECT *tree, WORD start, WORD end);
LOCAL VOID    set_font       (WORD font, WORD point);
LOCAL BOOLEAN exist_path     (BYTE *dir);
LOCAL WORD    get_dbworksize (VOID);
LOCAL WORD    get_mworksize  (VOID);

LOCAL BOOLEAN read_old_inf   (FILE *file, BOOLEAN load_base);

/*****************************************************************************/

GLOBAL BOOLEAN init_moptions ()

{
  set_str (config, CTMPDIR, "");
  set_str (config, CICNDIR, app_path);
  set_str (config, CPICDIR, app_path);
  set_str (config, CEXPDIR, app_path);
  set_str (config, CDBDIR,  app_path);

  get_config ();
  get_params ();

  g_xgrid = get_word (selgrid, MGRIDX);
  g_ygrid = get_word (selgrid, MGRIDY);

  work_spec.tables  = ADD_TABLES;
  work_spec.columns = ADD_COLUMNS;
  work_spec.indexes = ADD_INDEXES;
  work_spec.rels    = ADD_RELS;
  work_spec.users   = ADD_USERS;
  work_spec.icons   = ADD_ICONS;
  work_spec.formats = ADD_FORMATS;
  work_spec.lookups = ADD_LOOKUPS;
  work_spec.masks   = ADD_MASKS;
  work_spec.pics    = MAX_PICS;

  strcpy (cfg_path, app_path);
  strcpy (cfg_name, FREETXT (FDESKNAM));
  str_rmchar (cfg_name, SP);
  strcat (cfg_name, FREETXT (FINFSUFF) + 1);

  return (TRUE);
} /* init_moptions */

/*****************************************************************************/

GLOBAL BOOLEAN term_moptions ()

{
  return (TRUE);
} /* term_moptions */

/*****************************************************************************/

GLOBAL BOOLEAN mload_config (filename, load_base)
BYTE    *filename;
BOOLEAN load_base;

{
  BOOLEAN   ok, old, read_inf;
  WORD      i;
  WORD      x, y, xmax, ymax;
  WORD      result, button;
  STRING    version;
  LONGSTR   s;
  RECT      work;
  LRECT     doc;
  FULLNAME  inf_name, basename, name;
  EXT       suffix;
  FONTNAME  fontname;
  BASE_INFO base_info;
  BASE_SPEC base_spec;
  WINDOWP   window;
  BYTE      *p, *q;
  FILE      *file;
  BYTE      *pInf;

  ok       = TRUE;
  read_inf = FALSE;

  if (filename [0] == EOS)
  {
    strcpy (inf_name, cfg_path);
    strcat (inf_name, cfg_name);
  } /* if */
  else
    strcpy (inf_name, filename);

  if ((filename [0] != EOS) || (get_open_filename (FLOADCFG, NULL, 0L, FFILTER_INF, NULL, cfg_path, FINFSUFF, inf_name, cfg_name)))
  {
    busy_mouse ();

    file = fopen (inf_name, READ_TXT);
    ok   = file != NULL;

    if (ok)
    {
      if (load_base) close_all (TRUE, FALSE);

      text_rdln (file, version, STRLEN);

      if ((strncmp (version, "PHOENIX", 7) != 0) || (strcmp (version, OLD_VERSION) > 0))
      {
        old = FALSE;

        if (strcmp (version, "[Global]") == 0)
          read_inf = TRUE;
        else
          hndl_alert (ERR_INFVERSION);
      } /* if */
      else
      {
        old = TRUE;
        read_old_inf (file, load_base);
      } /* if */

      fclose (file);

      if (old)
        msave_config (inf_name);
    } /* else */

    if (read_inf)
      if ((pInf = ReadInfFile (inf_name)) != NULL)
      {
/* GS 5.1c Start */
        ccp_ext = GetProfileWord (pInf, szGlobal, "UseGEMClipboard", ccp_ext);
/* Ende; alt:
        ccp_ext = GetProfileWord (pInf, szGlobal, "UseGEMClipboard", ccp_ext) * DO_EXTERNAL;
*/
        GetProfileString (pInf, szGlobal, "FontName", "System", fontname);
        g_point = GetProfileWord (pInf, szGlobal, "FontSize", g_point);
        g_xgrid = GetProfileWord (pInf, szGlobal, "GridX", g_xgrid);
        g_ygrid = GetProfileWord (pInf, szGlobal, "GridY", g_ygrid);

        if ((g_font = FontNumberFromName (fontname)) == FAILURE) g_font = FONT_SYSTEM;

        menu_icheck (menu, MTOCLIP, ccp_ext);
/* GS 5.1c Start */
				ccp_ext *= DO_EXTERNAL;
/* Ende */

        opencfg.cursors   = GetProfileWord (pInf, szOpenParms, "Cursors", opencfg.cursors);
        opencfg.treeflush = GetProfileBool (pInf, szOpenParms, "TreeFlush", opencfg.treeflush);
        opencfg.dataflush = GetProfileBool (pInf, szOpenParms, "DataFlush", opencfg.dataflush);
        opencfg.mode      = GetProfileWord (pInf, szOpenParms, "Mode", opencfg.mode) + BSINGLE;
        opencfg.rdonly    = GetProfileBool (pInf, szOpenParms, "ReadOnly", opencfg.rdonly);
        opencfg.mode = BSINGLE;

        set_opencfg ();

        blinkrate   = GetProfileWord (pInf, szConfig, "Blinkrate", blinkrate);
        ring_bell   = GetProfileBool (pInf, szConfig, "ErrorBeep", ring_bell);
        grow_shrink = GetProfileBool (pInf, szConfig, "Grow/Shrink", grow_shrink);
        autosave    = GetProfileBool (pInf, szConfig, "AutoSave", autosave);
        print2meta  = GetProfileBool (pInf, szConfig, "PrintToMetafile", print2meta);
        use_fonts   = GetProfileBool (pInf, szConfig, "UseExternalFonts", use_fonts);
        autoexp     = GetProfileBool (pInf, szConfig, "AutoExport", autoexp);
        hidefunc    = GetProfileBool (pInf, szConfig, "HideFunctionKeys", hidefunc);
        unixdb      = GetProfileBool (pInf, szConfig, "UnixDb", unixdb);
        doc_width   = GetProfileBool (pInf, szConfig, "DocumentWidth", doc_width);
        doc_height  = GetProfileBool (pInf, szConfig, "DocumentHeight", doc_height);
        win_width   = GetProfileBool (pInf, szConfig, "WindowWidth", win_width);
        win_height  = GetProfileBool (pInf, szConfig, "WindowHeight", win_height);

        GetProfileString (pInf, szConfig, "TempDir", tmpdir, tmpdir);
        GetProfileString (pInf, szConfig, "IconPath", icn_path, icn_path);
        GetProfileString (pInf, szConfig, "PicturePath", pic_path, pic_path);
        GetProfileString (pInf, szConfig, "ExportPath", exp_path, exp_path);
        GetProfileString (pInf, szConfig, "DatabasePath", db_path, db_path);

        work_spec.tables  = GetProfileWord (pInf, szConfig, "AddTables", work_spec.tables);
        work_spec.columns = GetProfileWord (pInf, szConfig, "AddColumns", work_spec.columns);
        work_spec.indexes = GetProfileWord (pInf, szConfig, "AddIndexes", work_spec.indexes);
        work_spec.rels    = GetProfileWord (pInf, szConfig, "AddRelations", work_spec.rels);
        work_spec.users   = GetProfileWord (pInf, szConfig, "AddUsers", work_spec.users);
        work_spec.icons   = GetProfileWord (pInf, szConfig, "AddIcons", work_spec.icons);
        work_spec.formats = GetProfileWord (pInf, szConfig, "AddFormats", work_spec.formats);
        work_spec.lookups = GetProfileWord (pInf, szConfig, "AddLookups", work_spec.lookups);
        work_spec.masks   = GetProfileWord (pInf, szConfig, "AddMasks", work_spec.masks);
        work_spec.pics    = GetProfileWord (pInf, szConfig, "AddPictures", work_spec.pics);

        if (! exist_path (tmpdir)) strcpy (tmpdir, app_path);
        if (! exist_path (icn_path)) strcpy (icn_path, app_path);
        if (! exist_path (pic_path)) strcpy (pic_path, app_path);
        if (! exist_path (exp_path)) strcpy (exp_path, app_path);
        if (! exist_path (db_path)) strcpy (db_path, app_path);

        if (use_fonts)
          LoadFonts (vdi_handle);
        else
          UnloadFonts (vdi_handle);

        set_config ();

        use_3d            = GetProfileBool (pInf, szUserInterface, "Use3D", use_3d);
        dlg_round_borders = GetProfileBool (pInf, szUserInterface, "RoundBorders", dlg_round_borders);
        use_std_fs        = GetProfileBool (pInf, szUserInterface, "UseStandardFileSelector", use_std_fs);
        dlg_checkbox      = GetProfileWord (pInf, szUserInterface, "CheckboxSymbol", dlg_checkbox);
        dlg_radiobutton   = GetProfileWord (pInf, szUserInterface, "RadioButtonSymbol", dlg_radiobutton);
        dlg_arrow         = GetProfileWord (pInf, szUserInterface, "ArrowSymbol", dlg_arrow);
        btn_round_borders = GetProfileWord (pInf, szUserInterface, "ButtonRoundBorders", btn_round_borders);
        btn_shadow_width  = GetProfileWord (pInf, szUserInterface, "ButtonShadowWidth", btn_shadow_width);
        color_desktop     = GetProfileWord (pInf, szUserInterface, "DesktopColor", color_desktop);
        pattern_desktop   = GetProfileWord (pInf, szUserInterface, "DesktopPattern", pattern_desktop);
        sys_colors [0]    = GetProfileWord (pInf, szUserInterface, "ColorHighlight", sys_colors [0]);
        sys_colors [1]    = GetProfileWord (pInf, szUserInterface, "ColorHighlightText", sys_colors [1]);
        sys_colors [2]    = GetProfileWord (pInf, szUserInterface, "ColorDisabled", sys_colors [2]);
        sys_colors [3]    = GetProfileWord (pInf, szUserInterface, "ColorBtnFace", sys_colors [3]);
        sys_colors [4]    = GetProfileWord (pInf, szUserInterface, "ColorBtnHighlight", sys_colors [4]);
        sys_colors [5]    = GetProfileWord (pInf, szUserInterface, "ColorBtnShadow", sys_colors [5]);
        sys_colors [6]    = GetProfileWord (pInf, szUserInterface, "ColorBtnText", sys_colors [6]);
        sys_colors [7]    = GetProfileWord (pInf, szUserInterface, "ColorScrollBar", sys_colors [7]);
        sys_colors [8]    = GetProfileWord (pInf, szUserInterface, "ColorDialog", sys_colors [8]);

        xmax = desk.w - desktop [FKEYS].ob_width - 4;
        ymax = (desk.h - desktop [FKEYS].ob_height) & 0xFFF8;

        GetProfileString (pInf, szDesktopIcons, "FunctionKeys", "", s);
        sscanf (s, "%5d%5d\n", &x, &y);

        desktop [FKEYS].ob_x = desk.x + min (x, xmax);
        desktop [FKEYS].ob_y = desk.y + min (y, ymax);

        xmax  = desk.w - desktop [ITRASH].ob_width;
        ymax  = (desk.h - desktop [ITRASH].ob_height) & 0xFFF8;
        ymax += odd (desk.y);

        for (i = ITRASH; i < FKEYS; i++)
        {
          sprintf (name, "Icon%d", i - ITRASH + 1);
          GetProfileString (pInf, szDesktopIcons, name, "", s);
          sscanf (s, "%5d%5d\n", &x, &y);

          desktop [i].ob_x = desk.x + min (x, xmax);
          desktop [i].ob_y = desk.y + min (y, ymax);
        } /* for */

        if (hidefunc)
          do_flags (desktop, FKEYS, HIDETREE);
        else
          undo_flags (desktop, FKEYS, HIDETREE);

        dlg_colors = use_3d ? colors : 2;

        switch_trees_3d ();

        if ((colors == 2) && (pattern_desktop == 7))
          pattern_desktop = 4;

        desktop->ob_spec = (desktop->ob_spec & 0xFFFFFF80L) | color_desktop | (pattern_desktop << 4);

        for (i = 0; i < MAX_GEMWIND - 1; i++)     /* read database windows */
        {
          sprintf (name, "DB%d", i + 1);
          GetProfileString (pInf, szOpenDbs, name, "", s);

          if (*s && load_base)
          {
            mem_set (&base_spec, 0, sizeof (BASE_SPEC));

            base_spec.new         = FALSE;
            base_spec.datasize    = 0;
            base_spec.treesize    = 0;
            base_spec.first_table = NUM_SYSTABLES;
            base_spec.show_short  = TRUE;

            q  = s;
            p  = strchr (q, ',');
            *p = EOS;
            strcpy (basename, q);

            file_split (basename, NULL, db_path, db_name, suffix);

            strcpy (base_spec.basepath, db_path);
            strcpy (base_spec.basename, db_name);
            strcat (db_name, FREETXT (FDATSUFF) + 1);

            q  = p + 2;
            p  = strchr (q, ',');
            *p = EOS;
            strcpy (base_spec.username, q);

            q  = p + 2;
            p  = strchr (q, ',');
            *p = EOS;
            strcpy (base_spec.password, q);

            sscanf (p + 2, "%ld, %ld, %d, %d, %04x, %d, %d, %d, %ld, %ld, %ld, %ld, %d, %d, %d, %d, %d\n",
                    &base_spec.treecache,
                    &base_spec.datacache,
                    &base_spec.rdonly,
                    &base_spec.cursors,
                    &base_spec.oflags,
                    &base_spec.show_full,
                    &base_spec.font,
                    &base_spec.point,
                    &doc.x, &doc.y, &doc.w, &doc.h,
                    &work.x, &work.y, &work.w, &work.h,
                    &base_spec.show_short);

            base_spec.base = open_db (basename, base_spec.oflags, base_spec.datacache, base_spec.treecache, base_spec.cursors, base_spec.username, base_spec.password, &result);

            if ((result == SUCCESS) || (result == DB_DNOTCLOSED))
            {
              if (result == DB_DNOTCLOSED) dberror (result, base_spec.basename);

              if (base_spec.base->datainf->page0.reorg)
              {
                sprintf (s, alerts [ERR_REORG], base_spec.basename);
                open_alert (s);
              } /* if */

              db_baseinfo (base_spec.base, &base_info);
              base_spec.datasize = base_info.data_info.file_size / 1024;
              base_spec.treesize = base_info.tree_info.num_pages / 2;

              if (work.x < 0) work.x = 0;         /* correction if used in other resoultion */
              if (work.y < 2 * gl_hattr) work.y = 2 * gl_hattr;
              if (work.w > desk.w - gl_wattr) work.w = desk.w - 2 * gl_wattr;
              if (work.h > desk.h - gl_hattr) work.h = desk.h - 2 * gl_hattr;

              window = crt_base (NULL, basemenu, NIL, basename, &base_spec, &doc, &work);

              ok = window != NULL;

              if (ok)
              {
                ok = open_window (window);
                if (! ok) error (1, NOWINDOW, NIL, NULL);
              } /* if */
              else
                close_db (&base_spec);
            } /* if */
            else
            {
              if (result == DB_DNOOPEN)   /* database not there... */
              {                           /* ...so open new one */
                strcpy (basename, "");
                open_base (NIL, basename, NULL);
              } /* if */
              else
              {
                if (result != DB_DNOLOCK) button = dberror (result, base_spec.basename);

                if ((result == DB_CPASSWORD) && (button == 1) ||
                    (result == ERR_NOMEMRETRY) && (button == 1))
                {
                  opencfg.datacache = base_spec.datacache;
                  opencfg.treecache = base_spec.treecache;
                  opencfg.rdonly    = base_spec.rdonly;
                  opencfg.cursors   = base_spec.cursors;
                  opencfg.dataflush = (base_spec.oflags & DATA_FLUSH) != 0;
                  opencfg.treeflush = (base_spec.oflags & TREE_FLUSH) != 0;
                  opencfg.mode      = BSINGLE;

                  set_opencfg ();
                  mopendb (basename, FALSE);
                } /* if */
              } /* if */
            } /* else */
          } /* if */
        } /* for */

        mem_free (pInf);
        set_meminfo ();
      } /* if, if */

    arrow_mouse ();
  } /* if */

  for (i = ITRASH; i < FKEYS; i++) undo_flags (desktop, i, HIDETREE);

  window = find_desk ();
  if (window != NULL) set_redraw (window, &window->scroll);

  return (ok);
} /* mload_config */

/*****************************************************************************/

GLOBAL BOOLEAN msave_config (filename)
BYTE *filename;

{
  BOOLEAN    ok;
  FULLNAME  inf_name;
  FONTNAME  fontname;
  FILE      *file;
  WORD      i;
  WORD      num_opendb;
  PASSWORD  password;
  WINDOWP   winds [MAX_GEMWIND];
  WINDOWP   window;
  BASE_SPEC *base_spec;

  ok = TRUE;

  if (filename [0] == EOS)
  {
    strcpy (inf_name, cfg_path);
    strcat (inf_name, cfg_name);
  } /* if */
  else
    strcpy (inf_name, filename);

  if ((filename [0] != EOS) || (get_save_filename (FSAVECFG, NULL, 0L, FFILTER_INF, NULL, cfg_path, FINFSUFF, inf_name, cfg_name)))
  {
    busy_mouse ();

    file = fopen (inf_name, WRITE_TXT);
    ok   = file != NULL;

    if (! ok)
      file_error (ERR_FILECREATE, inf_name);
    else
    {
      FontNameFromNumber (fontname, g_font);

      fprintf (file, "[%s]\n", szGlobal);
      fprintf (file, "Version=%s\n", VERSION);
      fprintf (file, "UseGEMClipboard=%d\n", ccp_ext / DO_EXTERNAL);
      fprintf (file, "FontName=%s\n", fontname);
      fprintf (file, "FontSize=%d\n", g_point);
      fprintf (file, "GridX=%d\n", g_xgrid);
      fprintf (file, "GridY=%d\n", g_ygrid);
      save_desktop (file);

      fprintf (file, "\n[%s]\n", szOpenParms);
      fprintf (file, "Cursors=%d\n", opencfg.cursors);
      fprintf (file, "TreeFlush=%d\n", opencfg.treeflush);
      fprintf (file, "DataFlush=%d\n", opencfg.dataflush);
      fprintf (file, "Mode=%d\n", opencfg.mode - BSINGLE);
      fprintf (file, "ReadOnly=%d\n", opencfg.rdonly);

      fprintf (file, "\n[%s]\n", szConfig);
      fprintf (file, "Blinkrate=%d\n", blinkrate);
      fprintf (file, "ErrorBeep=%d\n", ring_bell);
      fprintf (file, "Grow/Shrink=%d\n", grow_shrink);
      fprintf (file, "AutoSave=%d\n", autosave);
      fprintf (file, "PrintToMetafile=%d\n", print2meta);
      fprintf (file, "UseExternalFonts=%d\n", use_fonts);
      fprintf (file, "AutoExport=%d\n", autoexp);
      fprintf (file, "HideFunctionKeys=%d\n", hidefunc);
      fprintf (file, "UnixDb=%d\n", unixdb);
      fprintf (file, "DocumentWidth=%d\n", doc_width);
      fprintf (file, "DocumentHeight=%d\n", doc_height);
      fprintf (file, "WindowWidth=%d\n", win_width);
      fprintf (file, "WindowHeight=%d\n", win_height);

      fprintf (file, "TempDir=%s\n", tmpdir);
      fprintf (file, "IconPath=%s\n", icn_path);
      fprintf (file, "PicturePath=%s\n", pic_path);
      fprintf (file, "ExportPath=%s\n", exp_path);
      fprintf (file, "DatabasePath=%s\n", db_path);

      fprintf (file, "AddTables=%d\n", work_spec.tables);
      fprintf (file, "AddColumns=%d\n", work_spec.columns);
      fprintf (file, "AddIndexes=%d\n", work_spec.indexes);
      fprintf (file, "AddRelations=%d\n", work_spec.rels);
      fprintf (file, "AddUsers=%d\n", work_spec.users);
      fprintf (file, "AddIcons=%d\n", work_spec.icons);
      fprintf (file, "AddFormats=%d\n", work_spec.formats);
      fprintf (file, "AddLookups=%d\n", work_spec.lookups);
      fprintf (file, "AddMasks=%d\n", work_spec.masks);
      fprintf (file, "AddPictures=%d\n", work_spec.pics);

      fprintf (file, "\n[%s]\n", szUserInterface);
      fprintf (file, "Use3D=%d\n", use_3d);
      fprintf (file, "RoundBorders=%d\n", dlg_round_borders);
      fprintf (file, "UseStandardFileSelector=%d\n", use_std_fs);
      fprintf (file, "CheckboxSymbol=%d\n", dlg_checkbox);
      fprintf (file, "RadioButtonSymbol=%d\n", dlg_radiobutton);
      fprintf (file, "ArrowSymbol=%d\n", dlg_arrow);
      fprintf (file, "ButtonRoundBorders=%d\n", btn_round_borders);
      fprintf (file, "ButtonShadowWidth=%d\n", btn_shadow_width);
      fprintf (file, "DesktopColor=%d\n", color_desktop);
      fprintf (file, "DesktopPattern=%d\n", pattern_desktop);
      fprintf (file, "ColorHighlight=%d\n", sys_colors [0]);
      fprintf (file, "ColorHighlightText=%d\n", sys_colors [1]);
      fprintf (file, "ColorDisabled=%d\n", sys_colors [2]);
      fprintf (file, "ColorBtnFace=%d\n", sys_colors [3]);
      fprintf (file, "ColorBtnHighlight=%d\n", sys_colors [4]);
      fprintf (file, "ColorBtnShadow=%d\n", sys_colors [5]);
      fprintf (file, "ColorBtnText=%d\n", sys_colors [6]);
      fprintf (file, "ColorScrollBar=%d\n", sys_colors [7]);
      fprintf (file, "ColorDialog=%d\n", sys_colors [8]);

      fprintf (file, "\n[%s]\n", szDesktopIcons);
      fprintf (file, "FunctionKeys=%d %d\n", desktop [FKEYS].ob_x - desk.x, desktop [FKEYS].ob_y - desk.y);

      for (i = ITRASH; i < FKEYS; i++)
        fprintf (file, "Icon%d=%d %d\n", i - ITRASH + 1, desktop [i].ob_x - desk.x, desktop [i].ob_y - desk.y);

      num_opendb = num_windows (CLASS_BASE, SRCH_OPENED, winds);

      fprintf (file, "\n[%s]\n", szOpenDbs);

      for (i = num_opendb - 1; i >= 0; i--)
      {
        window    = winds [i];
        base_spec = (BASE_SPEC *)window->special;

        strcpy (password, "");

        fprintf (file, "DB%d=%s%s, %s, %s, %ld, %ld, %d, %d, %04x, %d, %d, %d, %ld, %ld, %ld, %ld, %d, %d, %d, %d, %d\n",
                 num_opendb - i,
                 base_spec->basepath,
                 base_spec->basename,
                 base_spec->username,
                 password,
                 base_spec->treecache,
                 base_spec->datacache,
                 base_spec->rdonly,
                 base_spec->cursors,
                 base_spec->oflags,
                 base_spec->show_full,
                 base_spec->font,
                 base_spec->point,
                 window->doc.x,
                 window->doc.y,
                 window->doc.w,
                 window->doc.h,
                 window->work.x,
                 window->work.y,
                 window->work.w,
                 window->work.h,
                 base_spec->show_short);
      } /* for */

      fclose (file);
    } /* else */

    arrow_mouse ();
  } /* if */

  return (ok);
} /* msave_config */

/*****************************************************************************/

GLOBAL VOID mconfig ()

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, CONFIG);

  if (window == NULL)
  {
    form_center (config, &ret, &ret, &ret, &ret);
    window = crt_dialog (config, NULL, CONFIG, FREETXT (FCONFIG), WI_MODELESS);

    if (window != NULL)
    {
      window->click = click_config;
      window->key   = key_config;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (config, ROOT, EDITABLE);
      window->edit_inx = NIL;
      set_config ();
    } /* if */

    if (! open_dialog (CONFIG)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mconfig */

/*****************************************************************************/

GLOBAL VOID mparams ()

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, PARAMS);

  if (window == NULL)
  {
    form_center (params, &ret, &ret, &ret, &ret);
    window = crt_dialog (params, NULL, PARAMS, FREETXT (FPARAMS), WI_MODELESS);

    if (window != NULL)
    {
      window->click = click_params;
      window->key   = key_params;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (params, ROOT, EDITABLE);
      window->edit_inx = NIL;
      set_params ();
    } /* if */

    if (! open_dialog (PARAMS)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mparams */

/*****************************************************************************/

LOCAL VOID get_config ()

{
  WORD    inx, i;
  LONGSTR s, tmp;
  RECT    border;
  BYTE    sep [2];
  BYTE    *env;
  WINDOWP window;
  WINDOWP winds [MAX_GEMWIND];

  strcpy (tmpdir, get_str (config, CTMPDIR));
  sep [0] = PATHSEP;
  sep [1] = EOS;
  if (*tmpdir)
    if (tmpdir [strlen (tmpdir) - 1] != PATHSEP) strcat (tmpdir, sep);

  if (! exist_path (tmpdir))
  {
    env = getenv ("TEMP");
    if (env == NULL) env = getenv ("TMP");
    if (env == NULL) env = app_path;
    strcpy (tmp, env);
    if (tmp [strlen (tmp) - 1] != PATHSEP) strcat (tmp, sep);

    sprintf (s, alerts [ERR_TMPDIR], tmpdir, tmp);
    open_alert (s);
    strcpy (tmpdir, tmp);
  } /* if */

  strcpy (icn_path, get_str (config, CICNDIR));
  strcpy (pic_path, get_str (config, CPICDIR));
  strcpy (exp_path, get_str (config, CEXPDIR));
  strcpy (db_path,  get_str (config, CDBDIR));

  blinkrate   = get_word (config, CBLINK);
  ring_bell   = get_checkbox (config, CBEEP);
  grow_shrink = get_checkbox (config, CGROW);
  autosave    = get_checkbox (config, CAUTO);
  print2meta  = get_checkbox (config, CMETA);
  use_fonts   = get_checkbox (config, CUSEFONT);
  autoexp     = get_checkbox (config, CEXPORT);
  hidefunc    = get_checkbox (config, CFUNCS);
  unixdb      = get_checkbox (config, CUNIX);

  if (use_fonts)
  {
    LoadFonts (vdi_handle);

    inx = num_windows (CLASS_BASE, SRCH_ANY, winds);

    for (i = 0; i < inx; i++)
    {
      reset_basefont (winds [i]);
      set_redraw (winds [i], &winds [i]->scroll);
    } /* for */

    inx = num_windows (CLASS_MASK, SRCH_ANY, winds);
    for (i = 0; i < inx; i++) set_redraw (winds [i], &winds [i]->scroll);
  } /* if */
  else
  {
    UnloadFonts (vdi_handle);

    inx = num_windows (CLASS_BASE, SRCH_ANY, winds);

    for (i = 0; i < inx; i++)
    {
      reset_basefont (winds [i]);
      set_redraw (winds [i], &winds [i]->scroll);
    } /* for */

    inx = num_windows (CLASS_MASK, SRCH_ANY, winds);
    for (i = 0; i < inx; i++) set_redraw (winds [i], &winds [i]->scroll);
  } /* else */

  if (hidefunc != is_flags (desktop, FKEYS, HIDETREE))
  {
    flip_flags (desktop, FKEYS, HIDETREE);
    window = find_desk ();

    if (window != NULL)
    {
      get_border (window, FKEYS, &border);
      set_redraw (window, &border);
    } /* if */
  } /* if */

  set_meminfo ();
} /* get_config */

/*****************************************************************************/

LOCAL VOID set_config ()

{
  BYTE sep [2];

  sep [0] = PATHSEP;
  sep [1] = EOS;

  if (*tmpdir)
    if (tmpdir [strlen (tmpdir) - 1] != PATHSEP) strcat (tmpdir, sep);
  str_upper (tmpdir);

  set_str (config, CTMPDIR, tmpdir);
  set_str (config, CICNDIR, icn_path);
  set_str (config, CPICDIR, pic_path);
  set_str (config, CEXPDIR, exp_path);
  set_str (config, CDBDIR,  db_path);

  set_word (config, CBLINK, blinkrate);

  set_checkbox (config, CBEEP,    ring_bell);
  set_checkbox (config, CGROW,    grow_shrink);
  set_checkbox (config, CAUTO,    autosave);
  set_checkbox (config, CMETA,    print2meta);
  set_checkbox (config, CUSEFONT, use_fonts);
  set_checkbox (config, CEXPORT,  autoexp);
  set_checkbox (config, CFUNCS,   hidefunc);
  set_checkbox (config, CUNIX,    unixdb);

  if (any_ed_empty (config, CBLINK, COK) == ! is_state (config, COK, DISABLED)) flip_state (config, COK, DISABLED);
} /* set_config */

/*****************************************************************************/

LOCAL VOID click_config (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  FULLNAME path;
  BYTE     *p;

  switch (window->exit_obj)
  {
    case CTMPDIR - 1 :
    case CICNDIR - 1 :
    case CPICDIR - 1 :
    case CEXPDIR - 1 :
    case CDBDIR  - 1 : window->exit_obj++;

    case CTMPDIR     :
    case CICNDIR     :
    case CPICDIR     :
    case CEXPDIR     :
    case CDBDIR      : if (mk->breturn == 2)
                       {
                         p = get_str (config, window->exit_obj);
                         strcpy (path, p);

                         if (GetPathNameDialog (FREETXT (FSELPATH), get_str (helpinx, HSELFILE), 0L, path))
                         {
                           path [MAX_PATH] = EOS;
                           strcpy (p, path);
                           set_redraw (window, &window->scroll);
                         } /* if, if */
                       } /* if */
                       break;
    case COK         : get_config ();
                       break;
    case CCANCEL     : set_config ();
                       break;
    case CHELP       : hndl_help (HCONFIG);
                       undo_state (window->object, window->exit_obj, SELECTED);
                       draw_object (window, window->exit_obj);
                       break;
  } /* switch */
} /* click_config */

/*****************************************************************************/

LOCAL BOOLEAN key_config (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->edit_obj)
  {
    case CBLINK   : if (any_ed_empty (config, CBLINK, COK) == ! is_state (config, COK, DISABLED))
                    {
                      flip_state (config, COK, DISABLED);
                      draw_object (window, COK);
                    } /* if */
                    break;
  } /* switch */

  return (FALSE);
} /* key_config */

/*****************************************************************************/

LOCAL VOID get_params ()

{
  work_spec.tables  = get_word (params, PTABLES);
  work_spec.columns = get_word (params, PFIELDS);
  work_spec.indexes = get_word (params, PKEYS);
  work_spec.rels    = get_word (params, PRELS);
  work_spec.users   = get_word (params, PUSERS);
  work_spec.icons   = get_word (params, PICONS);
  work_spec.formats = get_word (params, PFORMATS);
  work_spec.lookups = get_word (params, PLOOKUPS);
  work_spec.masks   = get_word (params, PMASKS);
  work_spec.pics    = get_word (params, PPICS);

  doc_width  = get_word (params, PDOCW);
  doc_height = get_word (params, PDOCH);
  win_width  = get_word (params, PWINW);
  win_height = get_word (params, PWINH);
} /* get_params */

/*****************************************************************************/

LOCAL VOID set_params ()

{
  WORD size;

  set_word (params, PTABLES,  work_spec.tables);
  set_word (params, PFIELDS,  work_spec.columns);
  set_word (params, PKEYS,    work_spec.indexes);
  set_word (params, PRELS,    work_spec.rels);
  set_word (params, PUSERS,   work_spec.users);
  set_word (params, PICONS,   work_spec.icons);
  set_word (params, PFORMATS, work_spec.formats);
  set_word (params, PLOOKUPS, work_spec.lookups);
  set_word (params, PMASKS,   work_spec.masks);
  set_word (params, PPICS,    work_spec.pics);

  size = get_dbworksize ();
  set_word (params, PDUSAGE, size);
  if ((size == -1) == ! is_state (params, PDTXT, DISABLED)) flip_state (params, PDTXT, DISABLED);

  size = get_mworksize ();
  set_word (params, PMUSAGE, size);
  if ((size == -1) == ! is_state (params, PMTXT, DISABLED)) flip_state (params, PMTXT, DISABLED);

  set_font (g_font, g_point);
  set_word (params, PDOCW, doc_width);
  set_word (params, PDOCH, doc_height);
  set_word (params, PWINW, win_width);
  set_word (params, PWINH, win_height);

  if (any_ed_empty (params, ROOT, POK) == ! is_state (params, POK, DISABLED)) flip_state (params, POK, DISABLED);
} /* set_params */

/*****************************************************************************/

LOCAL VOID click_params (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  FONTDESC fontdesc;

  switch (window->exit_obj)
  {
    case POK     : get_params ();
                   break;
    case PCANCEL : set_params ();
                   break;
    case PHELP   : hndl_help (HPARAMS);
                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
    case PFONT   : fontdesc.font    = g_font;
                   fontdesc.point   = g_point;
                   fontdesc.effects = TXT_NORMAL;
                   fontdesc.color   = BLACK;

                   if (GetFontDialog (FREETXT (FFONT), get_str (helpinx, HSELFONT), FONT_FLAG_HIDE_EFFECTS | FONT_FLAG_HIDE_COLOR | FONT_FLAG_SHOW_ALL, vdi_handle, &fontdesc))
                   {
                     g_font  = fontdesc.font;
                     g_point = fontdesc.point;

                     set_font (g_font, g_point);
                     draw_object (window, PDOCFONT);
                     draw_object (window, PDOCPOIN);
                   } /* if */

                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
  } /* switch */
} /* click_params */

/*****************************************************************************/

LOCAL BOOLEAN key_params (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD   size;
  STRING s;

  switch (window->edit_obj)
  {
    case PTABLES  :
    case PFIELDS  :
    case PKEYS    :
    case PRELS    :
    case PUSERS   :
    case PICONS   :
    case PFORMATS :
    case PLOOKUPS :
    case PMASKS   :
    case PPICS    : if (window->edit_obj == PPICS)
                    {
                      size = get_mworksize ();
                      sprintf (s, "%-3d", size);
                      set_str (params, PMUSAGE, s);
                      draw_object (window, PMUSAGE);

                      if ((size == -1) == ! is_state (params, PMTXT, DISABLED))
                      {
                        flip_state (params, PMTXT, DISABLED);
                        draw_object (window, PMTXT);
                      } /* if */
                    } /* if */
                    else
                    {
                      size = get_dbworksize ();
                      sprintf (s, "%-3d", size);
                      set_str (params, PDUSAGE, s);
                      draw_object (window, PDUSAGE);

                      if ((size == -1) == ! is_state (params, PDTXT, DISABLED))
                      {
                        flip_state (params, PDTXT, DISABLED);
                        draw_object (window, PDTXT);
                      } /* if */
                    } /* else */
                    /* no break */
    case PDOCW    :
    case PDOCH    : if (any_ed_empty (params, ROOT, POK) == ! is_state (params, POK, DISABLED))
                    {
                      flip_state (params, POK, DISABLED);
                      draw_object (window, POK);
                    } /* if */
                    break;
  } /* switch */

  return (FALSE);
} /* key_params */

/*****************************************************************************/

LOCAL BOOLEAN any_ed_empty (tree, start, end)
OBJECT *tree;
WORD   start;
WORD   end;

{
  WORD obj;
  BYTE *p;

  obj = start;

  for (obj = start; obj <= end; obj++)
    if (is_flags (tree, obj, EDITABLE) &&
       ((OB_TYPE (tree, obj) == G_FTEXT) || (OB_TYPE (tree, obj) == G_FBOXTEXT)))
    {
      p = get_str (tree, obj);
      if (*p == EOS) return (TRUE);
    } /* if, for */

  return (FALSE);
} /* any_ed_empty */

/*****************************************************************************/

LOCAL VOID set_font (font, point)
WORD font, point;

{
  STRING s, name;

  FontNameFromNumber (name, font);
  name [FONTNAME_LENGTH] = EOS;

  sprintf (s, "%s", name);
  set_str (params, PDOCFONT, s);

  sprintf (s, "%d", point);
  set_str (params, PDOCPOIN, s);
} /* set_font */

/*****************************************************************************/

LOCAL BOOLEAN exist_path (dir)
BYTE *dir;

{
#if GEMDOS
  WORD     drive;
  FULLNAME path;

  if (*dir == EOS) return (TRUE);

  file_split (dir, &drive, path, NULL, NULL);

  if ((strlen (path) > 1) && ! path_exist (dir)) return (FALSE);

  return (TRUE);
#else
  return (path_exist (dir));
#endif
} /* exist_path */

/*****************************************************************************/

LOCAL WORD get_dbworksize ()

{
  LONG      size;
  WORK_SPEC work_spec;

  if (any_ed_empty (params, PTABLES, PMASKS)) return (-1);

  work_spec.tables  = get_word (params, PTABLES);
  work_spec.columns = get_word (params, PFIELDS);
  work_spec.indexes = get_word (params, PKEYS);
  work_spec.rels    = get_word (params, PRELS);
  work_spec.users   = get_word (params, PUSERS);
  work_spec.icons   = get_word (params, PICONS);
  work_spec.formats = get_word (params, PFORMATS);
  work_spec.lookups = get_word (params, PLOOKUPS);
  work_spec.masks   = get_word (params, PMASKS);

  if (any_ed_empty (params, PTABLES, PMASKS)) return (-1);

  work_spec.tables  += NUM_SYSTABLES;
  work_spec.formats += NUM_TYPES;

  size = work_spec.tables  * (LONG)sizeof (SYSTABLE)  +
         work_spec.columns * (LONG)sizeof (SYSCOLUMN) +
         work_spec.indexes * (LONG)sizeof (SYSINDEX)  +
         work_spec.rels    * (LONG)sizeof (SYSREL)    +
         work_spec.users   * (LONG)sizeof (SYSUSER)   +
         work_spec.icons   * (LONG)sizeof (SYSICON)   +
         work_spec.tables  * (LONG)sizeof (SYSTATTR)  +
         work_spec.formats * (LONG)sizeof (SYSFORMAT) +
         work_spec.lookups * (LONG)sizeof (SYSLOOKUP) +
         work_spec.masks   * (LONG)sizeof (HLPMASK)   +
         work_spec.tables  * (LONG)sizeof (SYSPTR)    +
         sizeof (BASE_SPEC);

  return ((WORD)(size / 1024));
} /* get_dbworksize */

/*****************************************************************************/

LOCAL WORD get_mworksize ()

{
  LONG size;

  if (any_ed_empty (params, PPICS, PPICS)) return (-1);

  size = (LONG)get_word (params, PPICS) * sizeof (PICOBJ) + sizeof (MASK_SPEC);

  return ((WORD)(size / 1024));
} /* get_mworksize */

/*****************************************************************************/

LOCAL BOOLEAN read_old_inf (FILE *file, BOOLEAN load_base)
{
  BOOLEAN   ok;
  WORD      i, num;
  WORD      x, y, xmax, ymax;
  WORD      result, button;
  STRING    version;
  LONGSTR   s;
  RECT      work;
  LRECT     doc;
  FULLNAME  basename;
  EXT       suffix;
  BASE_INFO base_info;
  BASE_SPEC base_spec;
  WINDOWP   window;
  BYTE      *p, *q;

  ok = TRUE;

  if (ok)
  {
    if (load_base) close_all (TRUE, FALSE);

    text_rdln (file, version, STRLEN);

    if ((strncmp (version, "PHOENIX", 7) != 0) || (strcmp (version, VERSION) > 0))
      hndl_alert (ERR_INFVERSION);
    else
    {
      text_rdln (file, s, LONGSTRLEN);
      sscanf (s, "%d%2d%2d%2d%2d%4d%4d%3d%3d%4d%3d%2d%2d%2d%5d%5d%\n",
              &blinkrate,
              &ring_bell,
              &grow_shrink,
              &autosave,
              &print2meta,
              &doc_width,
              &doc_height,
              &g_xgrid,
              &g_ygrid,
              &g_font,
              &g_point,
              &autoexp,
              &hidefunc,
              &unixdb,
              &win_width,
              &win_height);

      text_rdln (file, s, LONGSTRLEN);
      sscanf (s, "%4d%4d%4d%4d%4d%4d%4d%4d%4d%4d\n",
              &work_spec.tables,
              &work_spec.columns,
              &work_spec.indexes,
              &work_spec.rels,
              &work_spec.users,
              &work_spec.icons,
              &work_spec.formats,
              &work_spec.lookups,
              &work_spec.masks,
              &work_spec.pics);

      text_rdln (file, s, LONGSTRLEN);
      sscanf (s, "%2d%2d%2d%2d%2d%3d%2d%2d\n", &use_3d, &dlg_round_borders, &dlg_checkbox, &dlg_radiobutton, &dlg_arrow, &color_desktop, &pattern_desktop, &use_std_fs);

      text_rdln (file, s, LONGSTRLEN);
      sscanf (s, "%3d", &num);
      for (i = 0; i < min (num, MAX_SYSCOLORS); i++)
        sscanf (&s [3 * (i + 1)], "%3d", &sys_colors [i]);

      text_rdln (file, s, LONGSTRLEN);
      sscanf (s, "%3d%2d%2d%2d%2d\n", &opencfg.cursors, &opencfg.treeflush, &opencfg.dataflush, &opencfg.mode, &opencfg.rdonly);
      opencfg.mode = BSINGLE;
      set_opencfg ();

      text_rdln (file, s, LONGSTRLEN);
      sscanf (s, "%d%3d\n", &ccp_ext, &use_fonts);
/* GS 5.1c Start */
      menu_icheck (menu, MTOCLIP, ccp_ext);
      ccp_ext = DO_EXTERNAL * ccp_ext;
/* Ende ; alt:
      ccp_ext = DO_EXTERNAL * ccp_ext;
      menu_icheck (menu, MTOCLIP, ccp_ext);
*/

      if (use_fonts)
        LoadFonts (vdi_handle);
      else
        UnloadFonts (vdi_handle);

      xmax = desk.w - desktop [FKEYS].ob_width - 4;
      ymax = (desk.h - desktop [FKEYS].ob_height) & 0xFFF8;

      text_rdln (file, s, LONGSTRLEN);
      sscanf (s, "%5d%5d\n", &x, &y);

      desktop [FKEYS].ob_x = desk.x + min (x, xmax);
      desktop [FKEYS].ob_y = desk.y + min (y, ymax);

      xmax  = desk.w - desktop [ITRASH].ob_width;
      ymax  = (desk.h - desktop [ITRASH].ob_height) & 0xFFF8;
      ymax += odd (desk.y);

      for (i = ITRASH; i < FKEYS; i++)
      {
        text_rdln (file, s, LONGSTRLEN);
        sscanf (s, "%5d%5d\n", &x, &y);

        desktop [i].ob_x = desk.x + min (x, xmax);
        desktop [i].ob_y = desk.y + min (y, ymax);
      } /* for */

      if (hidefunc)
        do_flags (desktop, FKEYS, HIDETREE);
      else
        undo_flags (desktop, FKEYS, HIDETREE);

      dlg_colors = use_3d ? colors : 2;

      switch_trees_3d ();

      if ((colors == 2) && (pattern_desktop == 7))
        pattern_desktop = 4;

      desktop->ob_spec = (desktop->ob_spec & 0xFFFFFF80L) | color_desktop | (pattern_desktop << 4);

      text_rdln (file, tmpdir, MAX_FULLNAME);
      text_rdln (file, icn_path, MAX_FULLNAME);
      text_rdln (file, pic_path, MAX_FULLNAME);
      text_rdln (file, exp_path, MAX_FULLNAME);
      text_rdln (file, db_path, MAX_FULLNAME);

      if (! exist_path (tmpdir)) strcpy (tmpdir, app_path);
      if (! exist_path (icn_path)) strcpy (icn_path, app_path);
      if (! exist_path (pic_path)) strcpy (pic_path, app_path);
      if (! exist_path (exp_path)) strcpy (exp_path, app_path);
      if (! exist_path (db_path)) strcpy (db_path, app_path);

      set_config ();

      for (i = 0; i < MAX_GEMWIND - 1; i++)     /* read database windows */
      {
        if (! text_rdln (file, s, LONGSTRLEN)) *s = EOS;

        if (load_base && *s)
        {
          mem_set (&base_spec, 0, sizeof (BASE_SPEC));

          base_spec.new         = FALSE;
          base_spec.datasize    = 0;
          base_spec.treesize    = 0;
          base_spec.first_table = NUM_SYSTABLES;
          base_spec.show_short  = TRUE;

          q  = s;
          p  = strchr (q, ',');
          *p = EOS;
          strcpy (basename, q);

          file_split (basename, NULL, db_path, db_name, suffix);

          strcpy (base_spec.basepath, db_path);
          strcpy (base_spec.basename, db_name);
          strcat (db_name, FREETXT (FDATSUFF) + 1);

          q  = p + 2;
          p  = strchr (q, ',');
          *p = EOS;
          strcpy (base_spec.username, q);

          q  = p + 2;
          p  = strchr (q, ',');
          *p = EOS;
          strcpy (base_spec.password, q);

          sscanf (p + 2, "%ld, %ld, %d, %d, %04x, %d, %d, %d, %ld, %ld, %ld, %ld, %d, %d, %d, %d, %d\n",
                  &base_spec.datacache,
                  &base_spec.treecache,
                  &base_spec.rdonly,
                  &base_spec.cursors,
                  &base_spec.oflags,
                  &base_spec.show_full,
                  &base_spec.font,
                  &base_spec.point,
                  &doc.x, &doc.y, &doc.w, &doc.h,
                  &work.x, &work.y, &work.w, &work.h,
                  &base_spec.show_short);

          base_spec.base = open_db (basename, base_spec.oflags, base_spec.datacache, base_spec.treecache, base_spec.cursors, base_spec.username, base_spec.password, &result);

          if ((result == SUCCESS) || (result == DB_DNOTCLOSED))
          {
            if (result == DB_DNOTCLOSED) dberror (result, base_spec.basename);

            if (base_spec.base->datainf->page0.reorg)
            {
              sprintf (s, alerts [ERR_REORG], base_spec.basename);
              open_alert (s);
            } /* if */

            db_baseinfo (base_spec.base, &base_info);
            base_spec.datasize = base_info.data_info.file_size / 1024;
            base_spec.treesize = base_info.tree_info.num_pages / 2;

            if (work.x < 0) work.x = 0;         /* correction if used in other resoultion */
            if (work.y < 2 * gl_hattr) work.y = 2 * gl_hattr;
            if (work.w > desk.w - gl_wattr) work.w = desk.w - 2 * gl_wattr;
            if (work.h > desk.h - gl_hattr) work.h = desk.h - 2 * gl_hattr;

            window = crt_base (NULL, basemenu, NIL, basename, &base_spec, &doc, &work);

            ok = window != NULL;

            if (ok)
            {
              ok = open_window (window);
              if (! ok) error (1, NOWINDOW, NIL, NULL);
            } /* if */
            else
              close_db (&base_spec);
          } /* if */
          else
          {
            if (result == DB_DNOOPEN)   /* database not there... */
            {                           /* ...so open new one */
              strcpy (basename, "");
              open_base (NIL, basename, NULL);
            } /* if */
            else
            {
              if (result != DB_DNOLOCK) button = dberror (result, base_spec.basename);

              if ((result == DB_CPASSWORD) && (button == 1) ||
                  (result == ERR_NOMEMRETRY) && (button == 1))
              {
                opencfg.datacache = base_spec.datacache;
                opencfg.treecache = base_spec.treecache;
                opencfg.rdonly    = base_spec.rdonly;
                opencfg.cursors   = base_spec.cursors;
                opencfg.dataflush = (base_spec.oflags & DATA_FLUSH) != 0;
                opencfg.treeflush = (base_spec.oflags & TREE_FLUSH) != 0;
                opencfg.mode      = BSINGLE;

                set_opencfg ();
                mopendb (basename, FALSE);
              } /* if */
            } /* if */
          } /* else */
        } /* if */
      } /* for */
    } /* else */
  } /* if */

  for (i = ITRASH; i < FKEYS; i++) undo_flags (desktop, i, HIDETREE);

  window = find_desk ();
  if (window != NULL) set_redraw (window, &window->scroll);

  return (ok);
} /* read_old_inf */

/*****************************************************************************/


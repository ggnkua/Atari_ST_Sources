/*****************************************************************************
 *
 * Module : MLSCONF.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the load/save configuration.
 *
 * History:
 * 08.09.04: Saving TabSize added
 * 22.01.04: Saving property coordinates added
 * 25.06.03: Neuer Parameter "ToolBoxSize" fr die Gr”že der Toolbox.
 * 23.06.03: ccp_ext wird erst nachdem Setzen des Menhacken ver„ndert.
 * 21.12.02: Statt minimize wird minimize_process benutzt
 * 22.02.97: Saving of desktop coordinates added
 * 14.02.97: Saving of bUseDesktopWindow and bTopDesktopWindow added
 * 18.07.95: Loading and saving of show_raster and use_raster added
 * 05.06.95: VERSION updated to 4.0
 * 31.01.95; Loading and saving of warn_table added
 * 09.07.94: Font information is checked after call to LoadFonts
 * 24.05.94: Loading and saving of btn_round_borders and btn_shadow_width added
 * 03.04.94: Using new syntax for inf files
 * 13.03.94: Loading and saving of show_info, fontdesc.color, and fontdesc.effects added
 * 05.03.94: Loading and saving of show_top, show_left, show_pattern and fontdesc.font added
 * 19.11.93: Using new file selector
 * 14.11.93: Loading and saving of use_std_fs added
 * 04.11.93: LoadFonts and UnloadFonts in CommDlg used
 * 30.10.93: ERR_INFVERSION added in mload_config
 * 14.10.93: File is close correctly if if version conflict in mload_config
 * 07.10.93: Loading and saving of max_datacache and max_treecache added
 * 05.10.93: Loading and saving of user interface variables changed
 * 19.09.93: Variable pattern_desktop modified if only two colors available
 * 15.09.93: Loading and saving of variable use_3d added
 * 14.09.93: Loading and saving of variables color_desktop and pattern_desktop added
 * 13.09.93: Component mpos renamed to pos
 * 11.09.93: Loading and saving of max_record removed
 * 29.08.93: Loading and saving of iconbar added
 * 22.08.93: Radio buttons are zero-based saved
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "batexec.h"
#include "commdlg.h"
#include "desktop.h"
#include "dialog.h"
#include "list.h"
#include "mask.h"
#include "mconfig.h"
#include "mdbinfo.h"
#include "mimpexp.h"
#include "minxinfo.h"
#include "menu.h"
#include "mfile.h"
#include "mtblinfo.h"
#include "mpagefrm.h"
#include "printer.h"
/* [GS] 5.1d Start: */
#include "property.h"
/* Ende */
#include "reorg.h"
#include "resource.h"
#include "trash.h"

#include "export.h"
#include "mlsconf.h"

/****** DEFINES **************************************************************/

#define VERSION		"4.0"			/* version number */
#define OLD_VERSION	"PHOENIX 3.5"		/* version number for old inf files */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL BYTE *szGlobal        = "Global";
LOCAL BYTE *szOpenParms     = "OpenParms";
LOCAL BYTE *szConfig        = "Config";
LOCAL BYTE *szUserInterface = "UserInterface";
LOCAL BYTE *szMaskConfig    = "MaskConfig";
LOCAL BYTE *szDesktopIcons  = "DesktopIcons";
/* [GS] 5.1d Start */
LOCAL BYTE *szAccount  			= "Account";
/* Ende */
LOCAL BYTE *szOpenDbs       = "OpenDbs";

/****** FUNCTIONS ************************************************************/

LOCAL VOID    read_old_inf        (FILE *file, BOOLEAN load_dbs, BYTE *version);
LOCAL BOOLEAN load_old_prncfg     (FILE *loadfile, BYTE *loadname, PRNCFG *cfg, BOOLEAN updt_dialog);
LOCAL BOOLEAN load_old_impexp     (FILE *loadfile, BYTE *loadname, IMPEXPCFG *cfg, BOOLEAN updt_dialog);
LOCAL BOOLEAN load_old_pageformat (FILE *loadfile, BYTE *loadname, PAGE_FORMAT *format, BOOLEAN updt_dialog);

/*****************************************************************************/

GLOBAL BOOLEAN init_mlsconf ()

{
  BYTE *p;
  WORD l;

  strcpy (cfg_path, app_path);
  strcpy (cfg_name, FREETXT (FDESKNAM));
  str_rmchar (cfg_name, SP);

  p = getenv ("PHOENIX");       /* different INF-files for multiuser */
  if (p != NULL)
  {
    strcpy (cfg_path, p);
    l = strlen (cfg_path);

    if (l > 0)
      if (cfg_path [l - 1] != PATHSEP)
      {
        cfg_path [l]     = PATHSEP;
        cfg_path [l + 1] = EOS;
      } /* if, if */
  } /* if */

  strcat (cfg_name, FREETXT (FINFSUFF) + 1);

  return (TRUE);
} /* init_mlsconf */

/*****************************************************************************/

GLOBAL BOOLEAN term_mlsconf ()

{
  return (TRUE);
} /* term_mlsconf */

/*****************************************************************************/

GLOBAL BOOLEAN mload_config (filename, show_error, load_dbs)
BYTE    *filename;
BOOLEAN show_error, load_dbs;

{
  BOOLEAN  ok, old, read_inf;
  FULLNAME inf_name, name;
  FILE     *file;
  WORD     i, num, obj;
  WORD     x, y, xmax, ymax;
  WORD     result, button;
  DB_SPEC  dbs;
  STRING   version;
  LONGSTR  s;
  BYTE     *p, *q;
  WINDOWP  winds [MAX_GEMWIND];
  FONTNAME fontname;
  FULLNAME basepath;
  FILENAME basename;
  EXT      ext;
  BYTE     *pInf;

  ok       = TRUE;
  read_inf = FALSE;

  if (filename [0] == EOS)
  {
    strcpy (inf_name, cfg_path);
    strcat (inf_name, cfg_name);
  } /* if */
  else
    strcpy (inf_name, filename);

  if ((filename [0] != EOS) || (get_open_filename (FLOADINF, NULL, 0L, FFILTER_INF, NULL, cfg_path, FINFSUFF, inf_name, cfg_name)))
  {
    if (load_dbs)
      if (! check_close ())
        return (TRUE);

    busy_mouse ();

    file = fopen (inf_name, READ_TXT);
    ok   = file != NULL;

    if (! ok)
    {
      if (show_error) file_error (ERR_FILEOPEN, inf_name);
    } /* if */
    else
    {
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
        read_old_inf (file, load_dbs, version);
      } /* if */

      fclose (file);

      if (old)
        msave_config (inf_name, show_error, load_dbs);
    } /* else */

    if (read_inf)
      if ((pInf = ReadInfFile (inf_name)) != NULL)
      {
        if (load_dbs)
          while (num_opendb > 0)
            mclosedb ();

        sort_order       = GetProfileWord (pInf, szGlobal, "SortOrder", sort_order);
        sort_by_name     = GetProfileBool (pInf, szGlobal, "SortByName", sort_by_name);
        show_raster      = GetProfileBool (pInf, szGlobal, "ShowRaster", show_raster);
        use_raster       = GetProfileBool (pInf, szGlobal, "UseRaster", use_raster);
/* [GS] 5.1c Start */
        ccp_ext          = GetProfileWord (pInf, szGlobal, "UseGEMClipboard", ccp_ext);
/* Ende; alt:
        ccp_ext          = GetProfileWord (pInf, szGlobal, "UseGEMClipboard", ccp_ext) * DO_EXTERNAL;
*/
        GetProfileString (pInf, szGlobal, "FontName", "System", fontname);
        fontdesc.point   = GetProfileWord (pInf, szGlobal, "FontSize", fontdesc.point);
        fontdesc.color   = GetProfileWord (pInf, szGlobal, "FontColor", fontdesc.color);
        fontdesc.effects = GetProfileWord (pInf, szGlobal, "FontEffects", fontdesc.effects);

        menu_icheck (menu, MTOCLIP, ccp_ext);
/* [GS] 5.1c Start */
				ccp_ext *= DO_EXTERNAL;
/* Ende */
        menu_icheck (menu, MSHOWRST, show_raster);
        menu_icheck (menu, MRASTER, use_raster);

        obj = (sort_order == ASCENDING) ? DASCEND : DDESCEND;
        set_rbutton (desktop, obj, DASCEND, DDESCEND);

        GetProfileString (pInf, szOpenParms, "OpenPath", open_path, name);
        opencfg.cursors   = GetProfileWord (pInf, szOpenParms, "Cursors", opencfg.cursors);
        opencfg.treeflush = GetProfileBool (pInf, szOpenParms, "TreeFlush", opencfg.treeflush);
        opencfg.dataflush = GetProfileBool (pInf, szOpenParms, "DataFlush", opencfg.dataflush);
        opencfg.mode      = GetProfileWord (pInf, szOpenParms, "Mode", opencfg.mode) + BSINGLE;
        opencfg.rdonly    = GetProfileBool (pInf, szOpenParms, "ReadOnly", opencfg.rdonly);

        if (load_dbs)
          strcpy (open_path, name);

        set_opencfg ();

        GetProfileString (pInf, szConfig, "TempDir", tmpdir, tmpdir);
        blinkrate     = GetProfileWord (pInf, szConfig, "Blinkrate", blinkrate);
/* [GS] 5.1e Start */
        TabSize       = GetProfileWord (pInf, szConfig, "TabSize", TabSize);
/* Ende */
        ring_bell     = GetProfileBool (pInf, szConfig, "ErrorBeep", ring_bell);
        proc_beep     = GetProfileBool (pInf, szConfig, "ProcBeep", proc_beep);
        grow_shrink   = GetProfileBool (pInf, szConfig, "Grow/Shrink", grow_shrink);
        autosave      = GetProfileBool (pInf, szConfig, "AutoSave", autosave);
        use_fonts     = GetProfileBool (pInf, szConfig, "UseExternalFonts", use_fonts);
        hide_func     = GetProfileBool (pInf, szConfig, "HideFunctionKeys", hide_func);
        hide_iconbar  = GetProfileBool (pInf, szConfig, "HideIconBar", hide_iconbar);
        show_queried  = GetProfileBool (pInf, szConfig, "ShowQueried", show_queried);
        use_calc      = GetProfileBool (pInf, szConfig, "UseCalc", use_calc);
        minimize_process = GetProfileBool (pInf, szConfig, "Minimize", minimize_process);
        warn_table    = GetProfileBool (pInf, szConfig, "WarnTable", warn_table);
        show_grid     = GetProfileBool (pInf, szConfig, "ShowGrid", show_grid);
        show_info     = GetProfileBool (pInf, szConfig, "ShowInfo", show_info);
        show_top      = GetProfileBool (pInf, szConfig, "ShowTop", show_top);
        show_left     = GetProfileBool (pInf, szConfig, "ShowLeft", show_left);
        show_pattern  = GetProfileBool (pInf, szConfig, "ShowPattern", show_pattern);
        max_treecache = GetProfileLong (pInf, szConfig, "MaxTreeCache", max_treecache);
        max_datacache = GetProfileLong (pInf, szConfig, "MaxDataCache", max_datacache);

        if (max_datacache == -1L)
          set_null (TYPE_LONG, &max_datacache);

        if (max_treecache == -1L)
          set_null (TYPE_LONG, &max_treecache);

        if (use_fonts)
        {
          LoadFonts (vdi_handle);
          set_meminfo ();
        } /* if */
        else
          UnloadFonts (vdi_handle);

        if ((fontdesc.font = FontNumberFromName (fontname)) == FAILURE)
          fontdesc.font = FONT_SYSTEM;

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

        mask_config.clear       = GetProfileBool (pInf, szMaskConfig, "Clear", mask_config.clear);
        mask_config.fsel        = GetProfileBool (pInf, szMaskConfig, "AutomaticFileSelector", mask_config.fsel);
        mask_config.pospopup    = GetProfileBool (pInf, szMaskConfig, "PositionInListbox", mask_config.pospopup);
        mask_config.ask_delete  = GetProfileBool (pInf, szMaskConfig, "ConfirmDelete", mask_config.ask_delete);
        mask_config.play_direct = GetProfileBool (pInf, szMaskConfig, "PlayImmediately", mask_config.play_direct);
        mask_config.volume      = GetProfileWord (pInf, szMaskConfig, "Volume", mask_config.volume);

        set_mconfig ();

        load_prncfg (pInf, NULL, &prncfg, TRUE);
        load_impexp (pInf, NULL, &impexpcfg, TRUE);
        load_pageformat (pInf, NULL, &page_format, TRUE);

        xmax = desk.w - desktop [DTABLES].ob_width;
        ymax = desk.h - desktop [DTABLES].ob_height;

        GetProfileString (pInf, szDesktopIcons, "ToolBox", "", s);
        sscanf (s, "%d %d", &x, &y);
        desktop [DTABLES].ob_x = desk.x + min (x, xmax);
        desktop [DTABLES].ob_y = desk.y + min (y, ymax);

/* [GS] 5.1c Start */
        GetProfileString (pInf, szDesktopIcons, "ToolBoxSize", "", s);
        if ( s[0] != EOS )
        {
        	sscanf (s, "%d %d", &x, &y);
        	if ( x >= 144 && x <= 288 )
        	{
        		desktop [DTABLES].ob_width = x;
        		desktop [DTBLBOX].ob_width = x;
        		x -=32;
        		desktop [DBASE].ob_width = x;
        		desktop [DTBLLIST].ob_width = x;
        		desktop [DINXLIST].ob_width = x;
        	}
        }
/* Ende */

        xmax = desk.w - desktop [ICONBAR].ob_width;
        ymax = desk.h - desktop [ICONBAR].ob_height;

        GetProfileString (pInf, szDesktopIcons, "IconBar", "", s);
        sscanf (s, "%d %d", &x, &y);
        desktop [ICONBAR].ob_x = desk.x + min (x, xmax);
        desktop [ICONBAR].ob_y = desk.y + min (y, ymax);

        xmax = desk.w - desktop [FKEYS].ob_width - 4;
        ymax = (desk.h - desktop [FKEYS].ob_height) & 0xFFF8;

        GetProfileString (pInf, szDesktopIcons, "FunctionKeys", "", s);
        sscanf (s, "%d %d\n", &x, &y);
        desktop [FKEYS].ob_x = desk.x + min (x, xmax);
        desktop [FKEYS].ob_y = desk.y + min (y, ymax);

        xmax  = desk.w - desktop [ITABLE].ob_width;
        ymax  = (desk.h - desktop [ITABLE].ob_height) & 0xFFF8;
        ymax += odd (desk.y);

        for (i = ITABLE; i < FKEYS; i++)
        {
          sprintf (name, "Icon%d", i - ITABLE + 1);
          GetProfileString (pInf, szDesktopIcons, name, "", s);
          sscanf (s, "%d %d\n", &x, &y);
          desktop [i].ob_x = desk.x + min (x, xmax);
          desktop [i].ob_y = desk.y + min (y, ymax);
        } /* for */

        if (hide_func)
          do_flags (desktop, FKEYS, HIDETREE);
        else
          undo_flags (desktop, FKEYS, HIDETREE);

        if (hide_iconbar)
          do_flags (desktop, ICONBAR, HIDETREE);
        else
          undo_flags (desktop, ICONBAR, HIDETREE);

        dlg_colors = use_3d ? colors : 2;

        switch_trees_3d ();

        if ((colors == 2) && (pattern_desktop == 7))
          pattern_desktop = 4;

        desktop->ob_spec = (desktop->ob_spec & 0xFFFFFF80L) | color_desktop | (pattern_desktop << 4);

        num = num_windows (NIL, SRCH_OPENED, winds);
        for (i = 0; i < num; i++)
          set_redraw (winds [i], &winds [i]->work);

/* [GS] 5.1d Start */
        GetProfileString (pInf, szAccount, "PropertyPos", "-10000 -1 -1 -1", s);
       	sscanf (s, "%d %d %d %d", &PropertyPos.x,	&PropertyPos.y,
       							&PropertyPos.w, &PropertyPos.h );
/* Ende */

        for (i = 0; i < MAX_DB; i++)
        {
          sprintf (name, "DB%d", i + 1);
          GetProfileString (pInf, szOpenDbs, name, "", s);

          if (*s && load_dbs)
          {
            q  = s;
            p  = strchr (q, ',');
            *p = EOS;
            strcpy (dbs.filename, q);

            q  = p + 2;
            p  = strchr (q, ',');
            *p = EOS;
            strcpy (dbs.username, q);
            strcpy (dbs.password, "");          /* don't use password */

            dbs.num_cursors = opencfg.cursors;  /* use standard number of cursors */

            sscanf (p + 2, "%ld, %ld, %04x, %d\n",
                    &dbs.treecache,
                    &dbs.datacache,
                    &dbs.flags,
                    &dbs.sort_by_name);

            file_split (dbs.filename, NULL, basepath, basename, ext);

open:       result = open_db (dbs.filename, dbs.flags, dbs.datacache, dbs.treecache, dbs.num_cursors, dbs.username, dbs.password, dbs.sort_by_name);

            if ((result == SUCCESS) || (result == DB_DNOTCLOSED))
            {
              if ((result == DB_DNOTCLOSED) || (actdb->base->datainf->page0.reorg) || (actdb->base->datainf->page0.version < DB_VERSION))
              {
                sprintf (s, alerts [ERR_REORG], actdb->base->basename);

                if ((result == DB_DNOTCLOSED) && (dberror (basename, result) == 1) || (result != DB_DNOTCLOSED) && (open_alert (s) == 1))
                {
                  close_db ();
                  reorganizer (&dbs);
                  goto open;
                } /* if */
              } /* if */

              close_trash ();
              crt_trash (NULL, NULL, ITRASH);
              check_dbinfo ();
              check_tblinfo ();
              check_inxinfo ();
              set_meminfo ();

              strcpy (exp_path, actdb->base->basepath);

              strcpy (inf_name, actdb->base->basepath);
              strcat (inf_name, actdb->base->basename);
              strcat (inf_name, FREETXT (FINFSUFF) + 1);
              if (file_exist (inf_name)) mload_config (inf_name, TRUE, FALSE);
              exec_batch (actdb, NULL);
            } /* if */
            else
            {
              if (result == ERR_SAMEBASE)
                button = file_error (result, basename);
              else
                if (result != DB_DNOLOCK) button = dberror (basename, result);

              if ((result == DB_CPASSWORD) && (button == 1) ||
                  (result == ERR_NOMEMRETRY) && (button == 1))
              {
                strcpy (opencfg.username, dbs.username);

                opencfg.treecache = dbs.treecache;
                opencfg.datacache = dbs.datacache;
                opencfg.treeflush = (dbs.flags & TREE_FLUSH) != 0;
                opencfg.dataflush = (dbs.flags & DATA_FLUSH) != 0;
                opencfg.cursors   = dbs.num_cursors;
                opencfg.rdonly    = (dbs.flags & BASE_RDONLY) != 0;
                opencfg.mode      = (dbs.flags & BASE_MULUSER) ? BMULUSER : (dbs.flags & BASE_MULTASK) ? BMULTASK : BSINGLE;

                set_opencfg ();
                mopendb (dbs.filename, FALSE);
              } /* if */
            } /* else */
          } /* if */
        } /* for */

        mem_free (pInf);
        set_meminfo ();
      } /* if, if */

    arrow_mouse ();
  } /* if */

  for (i = DTABLES; i <= FKEYS; i++)
  {
    icon_pos [i - DTABLES].x = desktop [i].ob_x;
    icon_pos [i - DTABLES].y = desktop [i].ob_y;
  } /* for */

  return (ok);
} /* mload_config */

/*****************************************************************************/

GLOBAL BOOLEAN msave_config (filename, show_error, save_dbs)
BYTE    *filename;
BOOLEAN show_error, save_dbs;

{
  BOOLEAN   ok;
  FULLNAME  inf_name;
  FILE      *file;
  WORD      i;
  DB        *dbp;
  DB_SPEC   dbs;
  BASE_INFO base_info;
  LONG      max_data_cache, max_tree_cache;
  FONTNAME  fontname;

  ok = TRUE;

  if (filename [0] == EOS)
  {
    strcpy (inf_name, cfg_path);
    strcat (inf_name, cfg_name);
  } /* if */
  else
    strcpy (inf_name, filename);

  if ((filename [0] != EOS) || (get_save_filename (FSAVEINF, NULL, 0L, FFILTER_INF, NULL, cfg_path, FINFSUFF, inf_name, cfg_name)))
  {
    busy_mouse ();

    file = fopen (inf_name, WRITE_TXT);
    ok   = file != NULL;

    if (! ok)
    {
      if (show_error) file_error (ERR_FILECREATE, inf_name);
    } /* if */
    else
    {
      max_data_cache = (is_null (TYPE_LONG, &max_datacache)) ? -1L : max_datacache;
      max_tree_cache = (is_null (TYPE_LONG, &max_treecache)) ? -1L : max_treecache;

      FontNameFromNumber (fontname, fontdesc.font);

      fprintf (file, "[%s]\n", szGlobal);
      fprintf (file, "Version=%s\n", VERSION);
      fprintf (file, "SortOrder=%d\n", sort_order);
      fprintf (file, "SortByName=%d\n", sort_by_name);
      fprintf (file, "ShowRaster=%d\n", show_raster);
      fprintf (file, "UseRaster=%d\n", use_raster);
      fprintf (file, "UseGEMClipboard=%d\n", ccp_ext / DO_EXTERNAL);
      fprintf (file, "FontName=%s\n", fontname);
      fprintf (file, "FontSize=%d\n", fontdesc.point);
      fprintf (file, "FontColor=%d\n", fontdesc.color);
      fprintf (file, "FontEffects=%d\n", fontdesc.effects);
      save_desktop (file);

      fprintf (file, "\n[%s]\n", szOpenParms);
      fprintf (file, "OpenPath=%s\n", open_path);
      fprintf (file, "Cursors=%d\n", opencfg.cursors);
      fprintf (file, "TreeFlush=%d\n", opencfg.treeflush);
      fprintf (file, "DataFlush=%d\n", opencfg.dataflush);
      fprintf (file, "Mode=%d\n", opencfg.mode - BSINGLE);
      fprintf (file, "ReadOnly=%d\n", opencfg.rdonly);

      fprintf (file, "\n[%s]\n", szConfig);
      fprintf (file, "TempDir=%s\n", tmpdir);
      fprintf (file, "Blinkrate=%d\n", blinkrate);
/* [GS] 5.1e Start */
      fprintf (file, "TabSize=%d\n", TabSize);
/* Ende */
      fprintf (file, "ErrorBeep=%d\n", ring_bell);
      fprintf (file, "ProcBeep=%d\n", proc_beep);
      fprintf (file, "Grow/Shrink=%d\n", grow_shrink);
      fprintf (file, "AutoSave=%d\n", autosave);
      fprintf (file, "UseExternalFonts=%d\n", use_fonts);
      fprintf (file, "HideFunctionKeys=%d\n", hide_func);
      fprintf (file, "HideIconBar=%d\n", hide_iconbar);
      fprintf (file, "ShowQueried=%d\n", show_queried);
      fprintf (file, "UseCalc=%d\n", use_calc);

      fprintf (file, "Minimize=%d\n", minimize_process);

      fprintf (file, "WarnTable=%d\n", warn_table);
      fprintf (file, "ShowGrid=%d\n", show_grid);
      fprintf (file, "ShowInfo=%d\n", show_info);
      fprintf (file, "ShowTop=%d\n", show_top);
      fprintf (file, "ShowLeft=%d\n", show_left);
      fprintf (file, "ShowPattern=%d\n", show_pattern);
      fprintf (file, "MaxTreeCache=%ld\n", max_tree_cache);
      fprintf (file, "MaxDataCache=%ld\n", max_data_cache);

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

      fprintf (file, "\n[%s]\n", szMaskConfig);
      fprintf (file, "Clear=%d\n", mask_config.clear);
      fprintf (file, "AutomaticFileSelector=%d\n", mask_config.fsel);
      fprintf (file, "PositionInListbox=%d\n", mask_config.pospopup);
      fprintf (file, "ConfirmDelete=%d\n", mask_config.ask_delete);
      fprintf (file, "PlayImmediately=%d\n", mask_config.play_direct);
      fprintf (file, "Volume=%d\n", mask_config.volume);

      fprintf (file, "\n");
      save_prncfg (file, NULL, &prncfg);
      fprintf (file, "\n");
      save_impexp (file, NULL, &impexpcfg);
      fprintf (file, "\n");
      save_pageformat (file, NULL, &page_format);

      fprintf (file, "\n[%s]\n", szDesktopIcons);
      fprintf (file, "ToolBox=%d %d\n", desktop [DTABLES].ob_x - desk.x, desktop [DTABLES].ob_y - desk.y);
/* [GS] 5.1c Start */
      fprintf (file, "ToolBoxSize=%d %d\n", desktop [DTABLES].ob_width , desktop [DTABLES].ob_height );
/* Ende */
      fprintf (file, "IconBar=%d %d\n", desktop [ICONBAR].ob_x - desk.x, desktop [ICONBAR].ob_y - desk.y);
      fprintf (file, "FunctionKeys=%d %d\n", desktop [FKEYS].ob_x - desk.x, desktop [FKEYS].ob_y - desk.y);

      for (i = ITABLE; i < FKEYS; i++)
        fprintf (file, "Icon%d=%d %d\n", i - ITABLE + 1, desktop [i].ob_x - desk.x, desktop [i].ob_y - desk.y);

/* [GS] 5.1d Start: */
      fprintf (file, "\n[%s]\n", szAccount);
      fprintf (file, "PropertyPos=%d %d %d %d\n",	PropertyPos.x,
      								PropertyPos.y, PropertyPos.w, PropertyPos.h );
/* Ende */
      if (save_dbs)
      {
        fprintf (file, "\n[%s]\n", szOpenDbs);

        for (i = num_opendb - 1; i >= 0; i--)
        {
          for (dbp = db; dbp->pos != i; dbp++); /* search for the appropriate database */

          db_baseinfo (dbp->base, &base_info);

          strcpy (dbs.filename, base_info.basepath);
          strcat (dbs.filename, base_info.basename);
          strcpy (dbs.username, base_info.username);
          strcpy (dbs.password, "");    /* don't save password */

          dbs.flags        = dbp->flags;
          dbs.treecache    = base_info.tree_info.num_vpages / 2;
          dbs.datacache    = base_info.data_info.cache_size / 1024L;
          dbs.num_cursors  = base_info.tree_info.num_cursors;
          dbs.sort_by_name = dbp->sort_by_name;

          fprintf (file, "DB%d=%s, %s, %ld, %ld, %04x, %d\n",
                         num_opendb - i,
                         dbs.filename,
                         dbs.username,
                         dbs.treecache,
                         dbs.datacache,
                         dbs.flags,
                         dbs.sort_by_name);
        } /* for */
      } /* if */

      fclose (file);
    } /* else */

    arrow_mouse ();
  } /* if */

  return (ok);
} /* msave_config */

/*****************************************************************************/

LOCAL VOID read_old_inf (FILE *file, BOOLEAN load_dbs, BYTE *version)
{
  FULLNAME inf_name, name;
  WORD     i, num, obj;
  WORD     x, y, xmax, ymax;
  WORD     result, button;
  DB_SPEC  dbs;
  LONGSTR  s;
  BYTE     *p, *q;
  WINDOWP  winds [MAX_GEMWIND];
  FULLNAME basepath;
  FILENAME basename;
  EXT      ext;

        if (load_dbs)
          while (num_opendb > 0)
            mclosedb ();

        text_rdln (file, s, LONGSTRLEN);
        if (load_dbs) strcpy (open_path, s);

        text_rdln (file, tmpdir, MAX_FULLNAME);
        text_rdln (file, s, LONGSTRLEN);

        sscanf (s, "%d %d %d %d %d %d %d %d %d %d %d %d %ld %ld\n",
                   &blinkrate, &ring_bell, &grow_shrink, &autosave, &use_fonts, &hide_func, &hide_iconbar, &show_queried, &show_grid, &use_calc, &proc_beep, &minimize_process, &max_datacache, &max_treecache);
        if (max_datacache == -1L)
          set_null (TYPE_LONG, &max_datacache);

        if (max_treecache == -1L)
          set_null (TYPE_LONG, &max_treecache);

        if (strcmp (version + 8, "3.1") >= 0)
        {
          text_rdln (file, s, LONGSTRLEN);
          sscanf (s, "%d %d %d %d %d\n", &show_grid, &show_info, &show_top, &show_left, &show_pattern);
        } /* if */

        text_rdln (file, s, LONGSTRLEN);
        sscanf (s, "%d%2d%2d%2d%2d%3d%2d%2d\n", &use_3d, &dlg_round_borders, &dlg_checkbox, &dlg_radiobutton, &dlg_arrow, &color_desktop, &pattern_desktop, &use_std_fs);

        text_rdln (file, s, LONGSTRLEN);
        sscanf (s, "%3d", &num);
        for (i = 0; i < min (num, MAX_SYSCOLORS); i++)
          sscanf (&s [3 * (i + 1)], "%3d", &sys_colors [i]);

        if (use_fonts)
        {
          LoadFonts (vdi_handle);
          set_meminfo ();
        } /* if */
        else
          UnloadFonts (vdi_handle);

        set_config ();

        text_rdln (file, s, LONGSTRLEN);
        sscanf (s, "%d %d %d %d %d %d\n", &mask_config.clear, &mask_config.fsel, &mask_config.pospopup, &mask_config.play_direct, &mask_config.volume, &mask_config.ask_delete);
        set_mconfig ();

        text_rdln (file, s, LONGSTRLEN);
        sscanf (s, "%d %d %d %d %d %04u\n", &fontdesc.point, &sort_by_name, &ccp_ext, &sort_order, &fontdesc.color, &fontdesc.effects);

        if (strcmp (version + 8, "3.1") >= 0)
        {
          text_rdln (file, s, LONGSTRLEN);

          if ((fontdesc.font = FontNumberFromName (s)) == FAILURE)
            fontdesc.font = FONT_SYSTEM;
        } /* if */

        if (fontdesc.point < 8)			/* old inf-files */
          switch (fontdesc.point)
          {
            case 0 : fontdesc.point =  8; break;
            case 1 : fontdesc.point =  9; break;
            case 2 : fontdesc.point = 10; break;
            case 3 : fontdesc.point = 16; break;
            case 4 : fontdesc.point = 18; break;
            case 5 : fontdesc.point = 20; break;
            case 6 : fontdesc.point = 40; break;
          } /* switch, if */

/* [GS] 5.1c Start : */
        menu_icheck (menu, MTOCLIP, ccp_ext);
        ccp_ext *= DO_EXTERNAL;
/* Ende; alt:
        ccp_ext *= DO_EXTERNAL;
        menu_icheck (menu, MTOCLIP, ccp_ext);
*/
        obj = (sort_order == ASCENDING) ? DASCEND : DDESCEND;
        set_rbutton (desktop, obj, DASCEND, DDESCEND);

        text_rdln (file, s, LONGSTRLEN);
        sscanf (s, "%3d%2d%2d%2d%2d\n", &opencfg.cursors, &opencfg.treeflush, &opencfg.dataflush, &opencfg.mode, &opencfg.rdonly);
        opencfg.mode += BSINGLE;
        set_opencfg ();

        text_rdln (file, s, MAX_FULLNAME);
        strcpy (name, drv_path);
        strcat (name, drv_name);
        if (strcmp (s, name) != 0) load_driver (s);

        load_old_prncfg (file, NULL, &prncfg, TRUE);
        load_old_impexp (file, NULL, &impexpcfg, TRUE);
        load_old_pageformat (file, NULL, &page_format, TRUE);

        xmax = desk.w - desktop [DTABLES].ob_width;
        ymax = desk.h - desktop [DTABLES].ob_height;

        text_rdln (file, s, LONGSTRLEN);
        sscanf (s, "%5d%5d\n", &x, &y);
        desktop [DTABLES].ob_x = desk.x + min (x, xmax);
        desktop [DTABLES].ob_y = desk.y + min (y, ymax);

        xmax = desk.w - desktop [ICONBAR].ob_width;
        ymax = desk.h - desktop [ICONBAR].ob_height;

        text_rdln (file, s, LONGSTRLEN);
        sscanf (s, "%5d%5d\n", &x, &y);
        desktop [ICONBAR].ob_x = desk.x + min (x, xmax);
        desktop [ICONBAR].ob_y = desk.y + min (y, ymax);

        xmax = desk.w - desktop [FKEYS].ob_width - 4;
        ymax = (desk.h - desktop [FKEYS].ob_height) & 0xFFF8;

        text_rdln (file, s, LONGSTRLEN);
        sscanf (s, "%5d%5d\n", &x, &y);
        desktop [FKEYS].ob_x = desk.x + min (x, xmax);
        desktop [FKEYS].ob_y = desk.y + min (y, ymax);

        xmax  = desk.w - desktop [ITABLE].ob_width;
        ymax  = (desk.h - desktop [ITABLE].ob_height) & 0xFFF8;
        ymax += odd (desk.y);

        for (i = ITABLE; i < FKEYS; i++)
        {
          text_rdln (file, s, LONGSTRLEN);
          sscanf (s, "%5d%5d\n", &x, &y);
          desktop [i].ob_x = desk.x + min (x, xmax);
          desktop [i].ob_y = desk.y + min (y, ymax);
        } /* for */

        if (hide_func)
          do_flags (desktop, FKEYS, HIDETREE);
        else
          undo_flags (desktop, FKEYS, HIDETREE);

        if (hide_iconbar)
          do_flags (desktop, ICONBAR, HIDETREE);
        else
          undo_flags (desktop, ICONBAR, HIDETREE);

        dlg_colors = use_3d ? colors : 2;

        switch_trees_3d ();

        if ((colors == 2) && (pattern_desktop == 7))
          pattern_desktop = 4;

        desktop->ob_spec = (desktop->ob_spec & 0xFFFFFF80L) | color_desktop | (pattern_desktop << 4);

        num = num_windows (NIL, SRCH_OPENED, winds);
        for (i = 0; i < num; i++)
          set_redraw (winds [i], &winds [i]->work);

        for (i = 0; i < MAX_DB; i++)
        {
          text_rdln (file, s, LONGSTRLEN);

          if (*s && load_dbs)
          {
            q  = s;
            p  = strchr (q, ',');
            *p = EOS;
            strcpy (dbs.filename, q);

            q  = p + 2;
            p  = strchr (q, ',');
            *p = EOS;
            strcpy (dbs.username, q);

            q  = p + 2;
            p  = strchr (q, ',');
            *p = EOS;
            strcpy (dbs.password, "");  /* don't use password */

            dbs.datacache = 0;

            sscanf (p + 2, "%ld, %d, %04x, %d, %ld\n",
                    &dbs.treecache,
                    &dbs.num_cursors,
                    &dbs.flags,
                    &dbs.sort_by_name,
                    &dbs.datacache);

            file_split (dbs.filename, NULL, basepath, basename, ext);

open:       result = open_db (dbs.filename, dbs.flags, dbs.datacache, dbs.treecache, dbs.num_cursors, dbs.username, dbs.password, dbs.sort_by_name);

            if ((result == SUCCESS) || (result == DB_DNOTCLOSED))
            {
              if ((result == DB_DNOTCLOSED) || (actdb->base->datainf->page0.reorg) || (actdb->base->datainf->page0.version < DB_VERSION))
              {
                sprintf (s, alerts [ERR_REORG], actdb->base->basename);

                if ((result == DB_DNOTCLOSED) && (dberror (basename, result) == 1) || (result != DB_DNOTCLOSED) && (open_alert (s) == 1))
                {
                  close_db ();
                  reorganizer (&dbs);
                  goto open;
                } /* if */
              } /* if */

              close_trash ();
              crt_trash (NULL, NULL, ITRASH);
              check_dbinfo ();
              check_tblinfo ();
              check_inxinfo ();
              set_meminfo ();

              strcpy (exp_path, actdb->base->basepath);

              strcpy (inf_name, actdb->base->basepath);
              strcat (inf_name, actdb->base->basename);
              strcat (inf_name, FREETXT (FINFSUFF) + 1);
              if (file_exist (inf_name)) mload_config (inf_name, TRUE, FALSE);
              exec_batch (actdb, NULL);
            } /* if */
            else
            {
              if (result == ERR_SAMEBASE)
                button = file_error (result, basename);
              else
                if (result != DB_DNOLOCK) button = dberror (basename, result);

              if ((result == DB_CPASSWORD) && (button == 1) ||
                  (result == ERR_NOMEMRETRY) && (button == 1))
              {
                strcpy (opencfg.username, dbs.username);

                opencfg.treecache = dbs.treecache;
                opencfg.datacache = dbs.datacache;
                opencfg.treeflush = (dbs.flags & TREE_FLUSH) != 0;
                opencfg.dataflush = (dbs.flags & DATA_FLUSH) != 0;
                opencfg.cursors   = dbs.num_cursors;
                opencfg.rdonly    = (dbs.flags & BASE_RDONLY) != 0;
                opencfg.mode      = (dbs.flags & BASE_MULUSER) ? BMULUSER : (dbs.flags & BASE_MULTASK) ? BMULTASK : BSINGLE;

                set_opencfg ();
                mopendb (dbs.filename, FALSE);
              } /* if */
            } /* else */
          } /* if */
        } /* for */

        set_meminfo ();
} /* read_old_inf */

/*****************************************************************************/

LOCAL BOOLEAN load_old_prncfg (loadfile, loadname, cfg, updt_dialog)
FILE    *loadfile;
BYTE    *loadname;
PRNCFG  *cfg;
BOOLEAN updt_dialog;

{
  LONGSTR  s;
  FILE     *file;
  FULLNAME filename;
  WINDOWP  window;
  
  filename [0] = EOS;

  if (loadfile != NULL)
    file = loadfile;
  else
  {
    if ((loadname != NULL) && (*loadname != EOS))
      strcpy (filename, loadname);
    else
      if (! get_open_filename (FLOADPRN, NULL, 0L, FFILTER_PRN, NULL, cfg_path, FPRNSUFF, filename, NULL))
        return (FALSE);

    file = fopen (filename, READ_TXT);

    if (file == NULL)
    {
      file_error (ERR_FILEOPEN, filename);
      return (FALSE);
    } /* if */
  } /* else */

  busy_mouse ();

  text_rdln (file, cfg->control, LONGSTRLEN);
  text_rdln (file, cfg->filename, LONGSTRLEN);
  text_rdln (file, s, LONGSTRLEN);
  sscanf (s, "%3d%2d%2d%2d%2d%2d%2d%2d%3d%3d %ld %ld\n",
             &cfg->face,
             &cfg->condensed,
             &cfg->micro,
             &cfg->expanded,
             &cfg->italic,
             &cfg->emphasized,
             &cfg->nlq,
             &cfg->spool,
             &cfg->port,
             &cfg->lspace,
             &cfg->events_ps,
             &cfg->bytes_pe);

  cfg->face   += PPICA;
  cfg->port   += PFILE;
  cfg->lspace += PLSPACE6;

  if (updt_dialog)
  {
    set_prncfg (cfg);

    window = search_window (CLASS_DIALOG, SRCH_OPENED, CFGPRN);
    if (window != NULL) set_redraw (window, &window->scroll);
  } /* if */

  if (loadfile == NULL) fclose (file);

  arrow_mouse ();
  return (TRUE);
} /* load_old_prncfg */

/*****************************************************************************/

LOCAL BOOLEAN load_old_impexp (loadfile, loadname, cfg, updt_dialog)
FILE      *loadfile;
BYTE      *loadname;
IMPEXPCFG *cfg;
BOOLEAN   updt_dialog;

{
  LONGSTR  s;
  FILE     *file;
  FULLNAME filename;
  WINDOWP  window;

  filename [0] = EOS;

  if (loadfile != NULL)
    file = loadfile;
  else
  {
    if ((loadname != NULL) && (*loadname != EOS))
      strcpy (filename, loadname);
    else
      if (! get_open_filename (FLOADIMP, NULL, 0L, FFILTER_IMP, NULL, cfg_path, FIMPSUFF, filename, NULL))
        return (FALSE);

    file = fopen (filename, READ_TXT);

    if (file == NULL)
    {
      file_error (ERR_FILEOPEN, filename);
      return (FALSE);
    } /* if */
  } /* else */

  busy_mouse ();

  text_rdln (file, cfg->recsep, LONGSTRLEN);
  text_rdln (file, cfg->colsep, LONGSTRLEN);
  text_rdln (file, cfg->txtsep, LONGSTRLEN);
  text_rdln (file, cfg->decimal, LONGSTRLEN);
  text_rdln (file, s, LONGSTRLEN);
  sscanf (s, "%d %d %d %d\n", &cfg->asciiformat, &cfg->colname, &cfg->dateformat, &cfg->mode);
  cfg->asciiformat += EXBINARY;
  cfg->dateformat  += EXDDMMYY;
  cfg->mode        += EXINSERT;

  if (updt_dialog)
  {
    set_impexp (cfg);

    window = search_window (CLASS_DIALOG, SRCH_OPENED, IMEXPARM);
    if (window != NULL) set_redraw (window, &window->scroll);
  } /* if */

  if (loadfile == NULL) fclose (file);

  arrow_mouse ();
  return (TRUE);
} /* load_old_impexp */

/*****************************************************************************/

LOCAL BOOLEAN load_old_pageformat (loadfile, loadname, format, updt_dialog)
FILE        *loadfile;
BYTE        *loadname;
PAGE_FORMAT *format;
BOOLEAN     updt_dialog;

{
  LONGSTR  s;
  FILE     *file;
  FULLNAME filename;
  WINDOWP  window;
  
  filename [0] = EOS;

  if (loadfile != NULL)
    file = loadfile;
  else
  {
    if ((loadname != NULL) && (*loadname != EOS))
      strcpy (filename, loadname);
    else
      if (! get_open_filename (FLOADLAY, NULL, 0L, FFILTER_LAY, NULL, cfg_path, FLAYSUFF, filename, NULL))
        return (FALSE);

    file = fopen (filename, READ_TXT);

    if (file == NULL)
    {
      file_error (ERR_FILEOPEN, filename);
      return (FALSE);
    } /* if */
  } /* else */

  busy_mouse ();

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

  if (loadfile == NULL) fclose (file);

  arrow_mouse ();
  return (TRUE);
} /* load_old_pageformat */

/*****************************************************************************/


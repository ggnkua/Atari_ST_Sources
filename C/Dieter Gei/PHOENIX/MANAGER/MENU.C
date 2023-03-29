/*****************************************************************************
 *
 * Module : MENU.C
 * Author : Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 14.12.02
 *
 *
 * Description: This module implements the initialization and termination functions.
 *
 * History:
 * 14.12.02: Der MenÅeintrag 'GEM-Klemmbrett wird nicht mehr gelîscht
 * 30.10.02: In hndl_menu Bearbeitung der SubmenÅs fÅr MPNEW und MPLIST
 * 15.06.02: Im Info-Dialog wird das Datum und die Version eingetragen
 * 03.03.97: Account has it's own menu
 * 23.02.97: Group menu is being deleted
 * 01.01.97: Account definition window can be printed directly
 * 30.12.96: Account preview window can be printed
 * 21.12.96: Account definition window can be executed even if an object is selected there
 * 09.10.96: Cache can be written when either data or index cache is used
 * 19.06.96: Radio buttons for process selection corrected
 * 16.06.96: Using strcmpi for comparing file names
 * 20.05.96: Function hndl_ap_term added
 * 26.11.95: Menu MPAGEMRG deleted
 * 10.10.95: Menus MFOREGND and MBACKGND added
 * 28.07.95: Executing of account added
 * 23.07.95: Saving of account added
 * 18.07.95: Account menus added
 * 09.07.95: AccDef menus added
 * 24.04.95: MREMSEL is no longer activated if mask window is on top
 * 24.05.94: Searching possibility for mask windows added
 * 23.03.94: Menu MCONT added
 * 20.03.94: Menu MSAVE added
 * 15.03.94: Function hndl_va_start added
 * 14.03.94: Actual database will be reorganized
 * 10.03.94: Function list_newfont called
 * 22.02.94: Allow all fonts in GetFontDialog
 * 08.02.94: Including of blist etc. removed
 * 16.11.93: Disabled or hidden help button is no longer activated
 * 13.11.93: Call to userinterface_dialog modified
 * 04.11.93: New font dialog used
 * 04.10.93: User interface menu added
 * 02.10.93: Import and export possibilites with process definition windows added
 * 16.09.93: QBE functions no longer called, are handled with iconbar in qbe window
 * 14.09.93: Local function box removed, draw_growbox used instead
 * 13.09.93: ERR_QUITPROGRAM removed
 * 25.08.93: Menu FILE.CLOSE can no longer be called if no window is open
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "accdef.h"
#include "accprev.h"
#include "batch.h"
#include "batexec.h"
#include "calc.h"
#include "commdlg.h"
#include "delete.h"
#include "desktop.h"
#include "dialog.h"
#include "disk.h"
#include "edit.h"
#include "imageobj.h"
#include "list.h"
#include "mask.h"
#include "mchngpss.h"
#include "mconfig.h"
#include "mdbinfo.h"
#include "mimpexp.h"
#include "minxinfo.h"
#include "mfile.h"
#include "mlockscr.h"
#include "mlsconf.h"
#include "mpagefrm.h"
#include "mtblinfo.h"
#include "printer.h"
#include "process.h"
#include "qbe.h"
#include "reorg.h"
#include "report.h"
#include "resource.h"
#include "shell.h"
#include "sql.h"
#include "trash.h"
#include "userintr.h"
#include "version.h"

#include "export.h"
#include "menu.h"

/****** DEFINES **************************************************************/

#ifndef OUTPUT
#define OUTPUT      0                   /* TRUE, wenn dies ein Ausgabeprogramm ist */
#endif

#define GEM_OUTPUT  "OUTPUT.APP"        /* Name des GEM-Output Programms */

#define DELETE_MENU(obj) {i = obj; while (menu [i].ob_next > i) menu [++i].ob_y -= gl_hbox; menu [menu [i].ob_next].ob_height -= gl_hbox; objc_delete (menu, obj);}

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/* [GS] 5.2 old
LOCAL IMGOBJ img_logo;                  /* Logo fÅr About-Box */

#include "manager1.h"
#include "manager4.h"
*/

/****** FUNCTIONS ************************************************************/

LOCAL VOID    mmoreinfo     (VOID);

LOCAL VOID    draw_about    (WINDOWP window);
LOCAL VOID    open_about    (WINDOWP window);
LOCAL VOID    close_about   (WINDOWP window);
LOCAL VOID    click_about   (WINDOWP window, MKINFO *mk);
LOCAL BOOLEAN info_about    (WINDOWP window, WORD icon);

LOCAL VOID    mproc         (BOOLEAN new);
LOCAL VOID    click_newproc (WINDOWP window, MKINFO *mk);
LOCAL VOID    click_lstproc (WINDOWP window, MKINFO *mk);
LOCAL VOID    click_submenu_proc ( WORD item, BOOLEAN new );
LOCAL VOID    do_reorg      (VOID);

/*****************************************************************************/

GLOBAL VOID about_menu (VOID)
{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, ABOUT);

  if (window == NULL)
  {
    form_center (about, &ret, &ret, &ret, &ret);
    window = crt_dialog (about, NULL, ABOUT, FREETXT (FABOUT), WI_MODELESS);

    if (window != NULL)
    {
      window->open     = open_about;
      window->close    = close_about;
      window->draw     = draw_about;
      window->click    = click_about;
      window->showinfo = info_about;

/* [GS] 5.2 old
      do_flags (about, ALOGO, HIDETREE);
*/
    } /* if */
  } /* if */

  if (window != NULL)
    if (! open_dialog (ABOUT))
      hndl_alert (ERR_NOOPEN);
} /* about_menu */

/*****************************************************************************/

LOCAL VOID mmoreinfo (VOID)
{
  WINDOWP window;
  WORD    ret;
  BOOLEAN ok;

  window = search_window (CLASS_DIALOG, SRCH_ANY, MOREINFO);

  if (window == NULL)
  {
    form_center (moreinfo, &ret, &ret, &ret, &ret);
    moreinfo->ob_x += gl_wbox;
    moreinfo->ob_y += gl_hbox;
    window = crt_dialog (moreinfo, NULL, MOREINFO, FREETXT (FMOREINF), WI_MODELESS);
  } /* if */

  if (window != NULL)
    if (! open_dialog (MOREINFO))
    {
      delete_window (window);
      about->ob_spec = 0x00021100L;
      hndl_dial (moreinfo, 0, FALSE, TRUE, NULL, &ok);
      about->ob_spec = 0x00001100L;
    } /* if, if */
} /* mmoreinfo */

/*****************************************************************************/

LOCAL VOID open_about (WINDOWP window)
{
	BYTE str[30];
/* [GS] 5.2 old
  WORD    ret;
  IMGOBJP img;
  OBJECT  *obj;
*/

  draw_growbox (window, TRUE);

	strcpy ( str, MANAGER_VERSION );
	strcat ( str, ", " );
	strcat ( str, __DATE__ );
	set_str ( about , AVERSION, str );

/* [GS] 5.2 old
  img = &img_logo;
  obj = &about [ALOGO];

  img->window    = window;
  ret            = image_obj (img, IMG_INIT, IMG_MEM, (colors < 16) ? manager1 : manager4);
  img->bufsize   = sizeof ((colors < 16) ? manager1 : manager4);
  obj->ob_width  = img->width;
  obj->ob_height = img->height;

  xywh2rect ((about->ob_width - img->width) / 2, obj->ob_y, img->width, img->height, &img->pos);

  if (ret == IMG_NOMEMORY)
    hndl_alert (ERR_NOMEMORY);

  if (about->ob_height < img->height)
    about->ob_height = img->height;
*/
  set_meminfo ();
} /* open_about */

/*****************************************************************************/

LOCAL VOID close_about (WINDOWP window)
{
  draw_growbox (window, FALSE);

/* [GS] 5.2 old
  image_obj (&img_logo, IMG_EXIT, IMG_MEM, NULL);
*/

  set_meminfo ();
} /* close_about */

/*****************************************************************************/

LOCAL VOID draw_about (WINDOWP window)
{
/* [GS] 5.2 old
  image_obj (&img_logo, IMG_DRAW, 0, NULL);
*/
} /* draw_about */

/*****************************************************************************/

LOCAL VOID click_about (WINDOWP window, MKINFO *mk)
{
  if (window->exit_obj == AINFO)
  {
    undo_state (window->object, window->exit_obj, SELECTED);
    draw_object (window, window->exit_obj);
    mmoreinfo ();
  } /* if */
} /* click_about */

/*****************************************************************************/

LOCAL BOOLEAN info_about (WINDOWP window, WORD icon)
{
  mmoreinfo ();

  return (TRUE);
} /* info_about */

/*****************************************************************************/

LOCAL VOID mproc (BOOLEAN new)
{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, NEWPROC);

  if (window == NULL)
  {
    form_center (newproc, &ret, &ret, &ret, &ret);
    window = crt_dialog (newproc, NULL, NEWPROC, FREETXT (new ? FNEWPROC : FLSTPROC), WI_MODAL);
  } /* if */

  if (window != NULL)
  {
    strcpy (window->name, FREETXT (new ? FNEWPROC : FLSTPROC));
    window->click = new ? click_newproc : click_lstproc;

    if (window->opened == 0)
      set_rbutton (newproc, NPQUERY, NPQUERY, NPREPORT);

    if (! open_dialog (NEWPROC)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mproc */

/*****************************************************************************/

LOCAL VOID click_newproc (WINDOWP window, MKINFO *mk)
{
  if ((NPQUERY <= window->exit_obj) && (window->exit_obj < NPOK))
    if (mk->breturn == 2)
    {
      window->exit_obj  = NPOK;
      window->flags    |= WI_DLCLOSE;
    } /* if, if */

  switch (window->exit_obj)
  {
    case NPOK     : switch (get_rbutton (newproc, NPQUERY))
                    {
                      case NPQUERY  : qbe_new ();    break;
                      case NPREPORT : report_new (); break;
                      case NPCALC   : calc_new ();   break;
                      case NPBATCH  : batch_new ();  break;
                      case NPACC    : AccDefNew ();  break;
                    } /* switch */
                    break;
    case NPCANCEL : break;
    case NPHELP   : hndl_help (HNEWPROC);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_newproc */

/*****************************************************************************/

LOCAL VOID click_lstproc (WINDOWP window, MKINFO *mk)
{
  if ((NPQUERY <= window->exit_obj) && (window->exit_obj < NPOK))
    if (mk->breturn == 2)
    {
      window->exit_obj  = NPOK;
      window->flags    |= WI_DLCLOSE;
    } /* if, if */

  switch (window->exit_obj)
  {
    case NPOK     : switch (get_rbutton (newproc, NPQUERY))
                    {
                      case NPQUERY  : open_syslist (actdb, SYS_QUERY,   &fontdesc, NULL, FALSE); break;
                      case NPREPORT : open_syslist (actdb, SYS_REPORT,  &fontdesc, NULL, FALSE); break;
                      case NPCALC   : open_syslist (actdb, SYS_CALC,    &fontdesc, NULL, FALSE); break;
                      case NPBATCH  : open_syslist (actdb, SYS_BATCH,   &fontdesc, NULL, FALSE); break;
                      case NPACC    : open_syslist (actdb, SYS_ACCOUNT, &fontdesc, NULL, FALSE); break;
                    } /* switch */
                    break;
    case NPCANCEL : break;
    case NPHELP   : hndl_help (HLSTPROC);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_lstproc */

/*****************************************************************************/

LOCAL VOID click_submenu_proc ( WORD item, BOOLEAN new )
{
	switch ( item )
	{
		case NPMENUQBE_NEW:
			if ( new )
				qbe_new ();
			else
				open_syslist (actdb, SYS_QUERY,   &fontdesc, NULL, FALSE);
		break;
		case NPMENUACC_NEW:
			if ( new )
				AccDefNew ();
			else
				open_syslist (actdb, SYS_ACCOUNT,   &fontdesc, NULL, FALSE);
		break;
		case NPMENUCALC_NEW:
			if ( new )
				calc_new ();
			else
				open_syslist (actdb, SYS_CALC,   &fontdesc, NULL, FALSE);
		break;
		case NPMWENUBATCH_NEW:
			if ( new )
				batch_new ();
			else
				open_syslist (actdb, SYS_BATCH,   &fontdesc, NULL, FALSE);
		break;
		case NPMENUREPORT_NEW:
			if ( new )
				report_new ();
			else
				open_syslist (actdb, SYS_REPORT,   &fontdesc, NULL, FALSE);
		break;
	} /* switch */
} /* click_submenu_proc */

/*****************************************************************************/

LOCAL VOID do_reorg (VOID)
{
  DB       *savedb;
  DB_SPEC  dbs;
  WORD     result;
  FULLNAME inf_name;

  if ((actdb == NULL) || proc_used (actdb))
    reorganizer (NULL);
  else
  {
    savedb = actdb;			/* save pointer to actual database */

    strcpy (dbs.filename, actdb->base->basepath);
    strcat (dbs.filename, actdb->base->basename);
    strcpy (dbs.username, actdb->base->username);
    strcpy (dbs.password, actdb->password);

    dbs.flags        = actdb->base->datainf->flags | actdb->base->treeinf->flags;
    dbs.treecache    = actdb->base->treeinf->num_vpages / 2;
    dbs.datacache    = actdb->base->datainf->cache_size / 1024;
    dbs.num_cursors  = actdb->base->treeinf->num_cursors;
    dbs.sort_by_name = actdb->sort_by_name;

    mclosedb ();			/* close actual database */

    if (savedb != actdb)		/* database has been closed successfully */
    {
      reorganizer (&dbs);

      result = open_db (dbs.filename, dbs.flags, dbs.datacache, dbs.treecache, dbs.num_cursors, dbs.username, dbs.password, dbs.sort_by_name);

      if (result == SUCCESS)
      {
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

        if (file_exist (inf_name))
          mload_config (inf_name, TRUE, FALSE);

        exec_batch (actdb, NULL);
      } /* if */
    } /* if */
  } /* else */
} /* do_reorg */

/*****************************************************************************/
/* MenÅ-Verarbeitung                                                         */
/*****************************************************************************/

GLOBAL VOID updt_menu (WINDOWP window)
{
  WORD      i;
  SET       after;
  LONGSTR   s;
  WINDOWP   top;
  BOOLEAN   ccp, db_ok, v_selected, toplist, topmask, v_top, topproc, listproc;
  ICON_INFO iconinfo;

  if (menu_ok && updtmenu)
  {
    top        = find_top ();
    ccp        = (top != NULL) && (top->test != NULL) && (top->edit != NULL);
    db_ok      = (actdb != NULL) && (actdb->tables > 0);
    v_selected = (sel_window != NULL) && ((sel_window->class == CLASS_LIST) || (sel_window->class == class_desk));
    toplist    = v_top = (top != NULL) && (top->class == CLASS_LIST);
    topmask    = (top != NULL) && (top->class == CLASS_MASK);
    topproc    = (top != NULL) && ((top->class == CLASS_QBE) || (top->class == CLASS_REPORT) || (top->class == CLASS_CALC) || (top->class == CLASS_BATCH) || (top->class == CLASS_ACCDEF));
    listproc   = (sel_window != NULL) && ((sel_window->subclass == CLASS_QLIST) || (sel_window->subclass == CLASS_RLIST) || (sel_window->subclass == CLASS_CLIST) || (sel_window->subclass == CLASS_BLIST) || (sel_window->subclass == CLASS_ALIST));

    if (v_selected)
      if (sel_window->class == CLASS_LIST)
      {
        get_listinfo (sel_window, &iconinfo, s);
        v_selected = VTBL (iconinfo.table);
      } /* if */
      else
        for (i = ITABLE, v_selected = FALSE; (i < ITRASH) && ! v_selected; i++)
          v_selected = setin (sel_objs, i);

    if (toplist)
    {
      get_listinfo (top, &iconinfo, s);
      v_top = VTBL (iconinfo.table);
      if (v_top) v_top = num_keys (iconinfo.db, iconinfo.table, FAILURE) != 0;
    } /* if */

    menu_enable (menu, MOPEN,    (num_opendb < MAX_DB) || (sel_window != NULL)) ;
    menu_enable (menu, MCLOSE,   any_open (FALSE, TRUE, FALSE));
    menu_enable (menu, MCLOSEDB, (actdb != NULL) && ! proc_used (actdb));
    menu_enable (menu, MSAVE,    db_ok && topproc && ! (actdb->flags & BASE_RDONLY));
    menu_enable (menu, MSAVEAS,  db_ok && topproc && ! (actdb->flags & BASE_RDONLY));
    menu_enable (menu, MEXPORT,  db_ok);
    menu_enable (menu, MIMPORT,  db_ok && ! (actdb->flags & BASE_RDONLY));
    menu_enable (menu, MDISK,    db_ok);
    menu_enable (menu, MPRINT,   db_ok || (top != NULL) && ((top->class == CLASS_EDIT) || (top->class == CLASS_MASK)  || (top->class == CLASS_REPORT) || (top->class == CLASS_BATCH) || (top->class == CLASS_ACCDEF) || (top->class == CLASS_ACCPREV)));
    menu_enable (menu, MQUIT,    num_processes == 0);

    menu_enable (menu, MUNDO,    ccp && (*top->test) (top, DO_UNDO   | ccp_ext));
    menu_enable (menu, MCUT,     ccp && (*top->test) (top, DO_CUT    | ccp_ext));
    menu_enable (menu, MCOPY,    ccp && (*top->test) (top, DO_COPY   | ccp_ext));
    menu_enable (menu, MPASTE,   ccp && (*top->test) (top, DO_PASTE  | ccp_ext));
    menu_enable (menu, MCLEAR,   ccp && (*top->test) (top, DO_CLEAR  | ccp_ext));
    menu_enable (menu, MSELALL,  ccp && (*top->test) (top, DO_SELALL | ccp_ext));
    menu_enable (menu, MSEARCH,  toplist || topmask);
    menu_enable (menu, MCONT,    toplist || topmask);
    menu_enable (menu, MICONIFY, (top != NULL) && ((top->class == CLASS_LIST) || (top->class == CLASS_PROCESS)));
    menu_enable (menu, MOPENTBL, db_ok);
    menu_enable (menu, MEDITDAT, db_ok);
    menu_enable (menu, MREMOVE,  v_selected);
    menu_enable (menu, MREMSEL,  v_top);
    menu_enable (menu, MEMPTYTR, actdb != NULL);

    menu_enable (menu, MPNEW,    db_ok);
    menu_enable (menu, MPLIST,   db_ok);
    menu_enable (menu, MPEXEC,   db_ok && (topproc || listproc));
    menu_enable (menu, MPASSIGN, db_ok && ((top->class == CLASS_CALC) || (sel_window != NULL) && (sel_window->subclass == CLASS_CLIST)));
    menu_enable (menu, MPREMOVE, db_ok && (actdb->t_info [actdb->t_inx].calccode.size != 0));

    menu_enable (menu, MACCHDR,  db_ok && (top->class == CLASS_ACCDEF));
    menu_enable (menu, MPAGEHDR, db_ok && (top->class == CLASS_ACCDEF));
    menu_enable (menu, MFOREGND, db_ok && (top->class == CLASS_ACCDEF) && (sel_window != NULL));
    menu_enable (menu, MBACKGND, db_ok && (top->class == CLASS_ACCDEF) && (sel_window != NULL));
    menu_enable (menu, MGROUP,   db_ok && (top->class == CLASS_ACCDEF));

    menu_enable (menu, MLOADCNF, num_processes == 0);

    menu_enable (menu, MFLUSH,   (actdb != NULL) && ! (actdb->flags & (BASE_MULUSER | BASE_MULTASK | BASE_RDONLY)) && ((actdb->flags & BASE_FLUSH) != BASE_FLUSH));
    menu_enable (menu, MLOCKSCR, (actdb != NULL) && lockable && (actdb->password [0] != EOS));
    menu_enable (menu, MCHNGPSS, (actdb != NULL) && lockable && ! (actdb->flags & BASE_RDONLY));
    menu_enable (menu, MREVERSE, (top != NULL) && ((top->class == CLASS_LIST) || (top->class == CLASS_MASK)));

    menu_enable (menu, MDESIGNE, (num_processes == 0) && ! deskacc);
    menu_enable (menu, MPROGRAM, (num_processes == 0) && ! deskacc);

    menu_enable (menu, MDBINFO,  actdb != NULL);
    menu_enable (menu, MTBLINFO, db_ok);
    menu_enable (menu, MINXINFO, db_ok);

    menu_check (menu, MACCHDR, (top->class == CLASS_ACCDEF) && AccDefHasAccHeader (top));
    menu_check (menu, MPAGEHDR, (top->class == CLASS_ACCDEF) && AccDefHasPageHeader (top));

    setclr (after);

    for (i = 0; i < 10; i++)
      if ((funcmenus [i].item == 0) ||
          is_state (menu, funcmenus [i].title, DISABLED) ||
          is_state (menu, funcmenus [i].item, DISABLED))
        setexcl (after, i);
      else
        setincl (after, i);

    setxor (menus, after);

    if (! setcmp (menus, NULL))         /* Es hat sich etwas geÑndert */
    {
      for (i = 0, *s = EOS; i < 10; i++)
      {
#ifdef VER_4_2
        if (setin (after, i)) strcat (s, (i == 6) ? "REPORT" : FREETXT (FM1 + i));
#else
        if (setin (after, i)) strcat (s, FREETXT (FM1 + i));
#endif
        strcat (s, ",");
      } /* for */

      set_func (s);
      hide_mouse ();

      for (i = 0; i < 10; i++)
        if (setin (menus, i)) draw_key (i + 1);

      show_mouse ();
    } /* if */

    setcpy (menus, after);
  } /* if */

  updtmenu = TRUE;      /* MenÅs immer auf neuesten Stand bringen */
} /* updt_menu */

/*****************************************************************************/

GLOBAL VOID hndl_menu (WINDOWP window, WORD title, WORD item)
{
  WINDOWP top;
  BOOLEAN to_clip;
  WORD    obj;
  MKINFO  mk;
	OBJECT **submenu_tree;

  if (title != FUNCMENUS)
  {
    if (is_state (menu, title, DISABLED) ||     /* Accessory kînnte Nachricht geschickt haben */
        is_state (menu, item, DISABLED)) return;

    menu_normal (window, title, FALSE);         /* Titel invers darstellen */
  } /* if */

  top = find_top ();

  switch (title)
  {
    case MDESK    : if (item == MABOUT) about_menu ();
                    break;
    case MFILE    : switch (item)
                    {
                      case MOPEN    : if (sel_window == NULL)
                                        mopendb (NULL, TRUE);
                                      else
                                        if (sel_window->objop != NULL) (*sel_window->objop) (sel_window, sel_objs, OBJ_OPEN);
                                      break;
                      case MCLOSE   : if (any_open (FALSE, TRUE, FALSE))
                                        close_top ();
                                      break;
                      case MCLOSEDB : mclosedb ();
                                      break;
                      case MSAVE    : switch (top->class)
                                      {
                                        case CLASS_QBE    : qbe_save (top, FALSE);    break;
                                        case CLASS_REPORT : report_save (top, FALSE); break;
                                        case CLASS_CALC   : calc_save (top, FALSE);   break;
                                        case CLASS_BATCH  : batch_save (top, FALSE);  break;
                                        case CLASS_ACCDEF : AccDefSave (top, FALSE);  break;
                                      } /* switch */
                                      break;
                      case MSAVEAS  : switch (top->class)
                                      {
                                        case CLASS_QBE    : qbe_save (top, TRUE);    break;
                                        case CLASS_REPORT : report_save (top, TRUE); break;
                                        case CLASS_CALC   : calc_save (top, TRUE);   break;
                                        case CLASS_BATCH  : batch_save (top, TRUE);  break;
                                        case CLASS_ACCDEF : AccDefSave (top, TRUE);  break;
                                      } /* switch */
                                      break;
                      case MEXPORT  : if (! tbls_slctd ())
                                        if ((top != NULL) && (top->hndl_menu != NULL) && ((top->class == CLASS_QBE) || (top->class == CLASS_REPORT) || (top->class == CLASS_CALC) || (top->class == CLASS_BATCH)))
                                          (*top->hndl_menu) (top, title, item);
                                        else
                                          mexport (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, NULL, minimize);
                                      else
                                        (*sel_window->objop) (sel_window, sel_objs, OBJ_EXP);
                                      break;
                      case MIMPORT  : if (! tbls_slctd ())
                                        if ((top != NULL) && (top->hndl_menu != NULL) && ((top->class == CLASS_QBE) || (top->class == CLASS_REPORT) || (top->class == CLASS_CALC) || (top->class == CLASS_BATCH)))
                                          (*top->hndl_menu) (top, title, item);
                                        else
                                          mimport (actdb, actdb->table, NULL, minimize);
                                      else
                                        (*sel_window->objop) (sel_window, sel_objs, OBJ_IMP);
                                      break;
                      case MDISK    : if (! tbls_slctd ())
                                        mopentbl (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, DEV_DISK, &fontdesc, NULL, NULL, minimize, FALSE);
                                      else
                                        (*sel_window->objop) (sel_window, sel_objs, OBJ_DISK);
                                      break;
                      case MPRINT   : if (! tbls_slctd () || (top != NULL) && ((top->class == CLASS_ACCDEF) || (top->class == CLASS_ACCPREV)))
                                        if ((top != NULL) && ((top->class == CLASS_EDIT) || (top->class == CLASS_MASK) || (top->class == CLASS_REPORT) || (top->class == CLASS_BATCH) || (top->class == CLASS_ACCDEF) || (top->class == CLASS_ACCPREV)))
                                          switch (top->class)
                                          {
                                            case CLASS_EDIT    : print_edit (top);   break;
                                            case CLASS_MASK    : print_mask (top);   break;
                                            case CLASS_REPORT  : print_report (top); break;
                                            case CLASS_BATCH   : print_batch (top);  break;
                                            case CLASS_ACCDEF  : AccDefPrint (top);  break;
                                            case CLASS_ACCPREV : AccPrevPrint (top); break;
                                          } /* switch, if */
                                        else
                                          mopentbl (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, DEV_PRINTER, &fontdesc, NULL, NULL, minimize, FALSE);
                                      else
                                        if ((sel_window != NULL) && (sel_window->subclass == CLASS_ALIST))
                                          AccDefPrint (NULL);
                                        else
                                          (*sel_window->objop) (sel_window, sel_objs, OBJ_PRINT);
                                      break;
#ifdef ASK_FOR_QUIT
                      case MQUIT    : if ((num_opendb == 0) || (hndl_alert (ERR_QUITPROGRAM) == 1))
#else
                      case MQUIT    :
#endif
                                      {
                                        done = check_close ();

                                        if (done) called_by [0] = EOS; /* Programm ganz beenden */
                                      } /* if */
                                      break;
                    } /* switch */
                    break;
    case MEDIT    : switch (item)
                    {
                      case MUNDO    : (*top->edit) (top, DO_UNDO   | ccp_ext);
                                      break;
                      case MCUT     : (*top->edit) (top, DO_CUT    | ccp_ext);
                                      break;
                      case MCOPY    : (*top->edit) (top, DO_COPY   | ccp_ext);
                                      break;
                      case MPASTE   : (*top->edit) (top, DO_PASTE  | ccp_ext);
                                      break;
                      case MCLEAR   : (*top->edit) (top, DO_CLEAR  | ccp_ext);
                                      break;
                      case MSELALL  : (*top->edit) (top, DO_SELALL | ccp_ext);
                                      break;
                      case MSEARCH  : switch (top->class)
                                      {
                                        case CLASS_LIST   : list_search (top, FALSE); break;
                                        case CLASS_MASK   : mask_search (top, FALSE); break;
                                      } /* switch */
                                      break;
                      case MCONT    : switch (top->class)
                                      {
                                        case CLASS_LIST   : list_search (top, TRUE); break;
                                        case CLASS_MASK   : mask_search (top, TRUE); break;
                                      } /* switch */
                                      break;
                      case MICONIFY : miconify (top);
                                      break;
                      case MCYCLEWI : cycle_window ();
                                      break;
                      case MOPENTBL : mopentbl (actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, DEV_SCREEN, &fontdesc, NULL, NULL, FALSE, TRUE);
                                      break;
                      case MEDITDAT : if (! tbls_slctd ())
                                        open_mask (NIL, actdb, actdb->table, actdb->t_info [actdb->t_inx].index, sort_order, "", NULL, 0L, NULL, NULL, FALSE);
                                      else
                                        (*sel_window->objop) (sel_window, sel_objs, OBJ_EDIT);
                                      break;
                      case MREMOVE  : if (sel_window->class == CLASS_LIST)
                                        list_remove (sel_window);
                                      else
                                        miremove ();
                                      break;
                      case MREMSEL  : list_remsel (top);
                                      break;
                      case MEMPTYTR : delete_list (actdb, SYS_DELETED, 0, ASCENDING, minimize, TRUE);
                                      break;
                      case MTOCLIP  : to_clip = ccp_ext == 0;
                                      menu_check (menu, item, to_clip);
                                      ccp_ext = to_clip ? DO_EXTERNAL : 0;
                                      break;
                    } /* switch */
                    break;
    case MPROCESS :
    								submenu_tree = (OBJECT **) &menu_pipe[5];

    								if ( *submenu_tree == newprocmenu_new )
											click_submenu_proc ( item, TRUE );

    								if ( *submenu_tree == newprocmenu_list )
											click_submenu_proc ( item, FALSE );

										switch ( item )
                    {
                      case MPNEW    : mproc (TRUE);
                                      break;
                      case MPLIST   : mproc (FALSE);
                                      break;
                      case MPEXEC   : if (sel_window != NULL)
                                        switch (sel_window->subclass)
                                        {
                                          case CLASS_QLIST : qbe_execute (NULL);
                                                             break;
                                          case CLASS_RLIST : report_execute (NULL);
                                                             break;
                                          case CLASS_CLIST : calc_execute (NULL);
                                                             break;
                                          case CLASS_BLIST : batch_execute (NULL);
                                                             break;
                                          case CLASS_ALIST : AccDefExecute (NULL); 
                                                             break;
                                          default          : if (sel_window->class == CLASS_ACCDEF)
                                                               AccDefExecute (sel_window);
                                                             break;
                                        } /* switch, if */
                                      else
                                        switch (top->class)
                                        {
                                          case CLASS_QBE    : qbe_execute (top);
                                                              break;
                                          case CLASS_REPORT : if (! tbls_slctd ())
                                                                report_execute (top);
                                                              else
                                                                (*sel_window->objop) (sel_window, sel_objs, OBJ_REP);
                                                              break;
                                          case CLASS_CALC   : if (! tbls_slctd ())
                                                                calc_execute (top);
                                                              else
                                                                (*sel_window->objop) (sel_window, sel_objs, OBJ_CALC);
                                                              break;
                                          case CLASS_BATCH  : batch_execute (top);
                                                              break;
                                          case CLASS_ACCDEF : if (! tbls_slctd ())
                                                                AccDefExecute (top);
                                                              else
                                                                (*sel_window->objop) (sel_window, sel_objs, OBJ_ACC);
                                                               break;
                                        } /* switch, else */
                                      break;
                      case MPASSIGN : calc_assign (top);
                                      break;
                      case MPREMOVE : calc_remove (actdb, actdb->table);
                                      break;
                    } /* switch */
                    break;
    case MACCOUNT : switch (item)
                    {
                      case MACCHDR  : AccDefFlipAccHeader (top);
                                      menu_check (menu, item, AccDefHasAccHeader (top));
                                      break;
                      case MPAGEHDR : AccDefFlipPageHeader (top);
                                      menu_check (menu, item, AccDefHasPageHeader (top));
                                      break;
                      case MFOREGND : AccDefToForeground (top);
                                      break;
                      case MBACKGND : AccDefToBackground (top);
                                      break;
                      case MSHOWRST : show_raster = ! show_raster;
                                      menu_check (menu, item, show_raster);
                                      AccDefFlipRaster ();
                                      break;
                      case MRASTER  : use_raster = ! use_raster;
                                      menu_check (menu, item, use_raster);
                                      break;
                      case MGROUP   : break;
                    } /* switch */
                    break;
    case MPARAMS  : switch (item)
                    {
                      case MCONFIG  : mconfig ();
                                      break;
                      case MLOADCNF : mload_config ("", TRUE, TRUE);
                                      break;
                      case MSAVECNF : msave_config ("", TRUE, TRUE);
                                      break;
                      case MMCONFIG : mmconfig ();
                                      break;
                      case MIMPEXP  : mimpexp ();
                                      break;
                      case MSETPRN  : if (! open_printer (IPRINTER)) hndl_alert (ERR_NOOPEN);
                                      break;
                      case MQUEUE   : if (! open_queue (NIL)) hndl_alert (ERR_NOOPEN);
                                      break;
                      case MPAGEFOR : mpageformat ();
                                      break;
                      case MFONT    : if ((top != NULL) && (top->class == CLASS_LIST))
                                        list_newfont (top);
                                      else
                                        GetFontDialog (FREETXT (FFONT), get_str (helpinx, HFONT), 0L, vdi_handle, &fontdesc);
                                      break;
                      case MUSERINT : userinterface_dialog (FREETXT (FUSERINTR), get_str (helpinx, HUSERINT));
                                      break;
                    } /* switch */
                    break;
    case MOPTIONS : switch (item)
                    {
                      case MDESIGNE : call_designer ();
                                      break;
                      case MREORG   : do_reorg ();
                                      break;
                      case MPROGRAM : call_program ();
                                      break;
                      case MFLUSH   : flush_db (actdb);
                                      break;
                      case MLOCKSCR : mlockscreen (actdb);
                                      break;
                      case MCHNGPSS : mchangepass ();
                                      break;
                      case MREVERSE : if (top->class == CLASS_LIST)
                                        list_reverse (top);
                                      else
                                        mmaskreverse (top);
                                      break;
                      case MORDERDE : morderdesk ();
                                      break;
                    } /* switch */
                    break;
    case MHELP    : switch (item)
                    {
                      case MHELPCXT : if ((top == NULL) || (top->opened == 0))
                                        hndl_alert (ERR_NOHELP);
                                      else
                                        if (top->flags & (WI_MODAL | WI_MODELESS))
                                        {
                                          obj = find_flags (top->object, ROOT, HELP_FLAG);

                                          if ((obj == NIL) || is_state (top->object, obj, DISABLED) || is_flags (top->object, obj, HIDETREE))
                                            hndl_alert (ERR_NOHELP);
                                          else
                                          {
                                            top->exit_obj = obj;
                                            do_state (top->object, obj, SELECTED);
                                            draw_object (top, obj);
                                            mem_set (&mk, 0, sizeof (mk));
                                            if (top->click != NULL) (*top->click) (top, &mk);
                                          } /* else */
                                        } /* if */
                                        else
                                          if (sel_window != NULL)
                                          {
                                            if (sel_window->objop != NULL)
                                              (*sel_window->objop) (sel_window, sel_objs, OBJ_HELP);
                                          } /* if */
                                          else
                                            if ((top->showhelp == NULL) || ! (*top->showhelp) (top, NIL)) hndl_alert (ERR_NOHELP);
                                      break;
                      case MHELPINX : hndl_help (HINDEX);
                                      break;
                      case MHELPCON : hndl_help (HCONTENT);
                                      break;
                      case MHELPOBJ : break;
                      case MINFO    : if (sel_window != NULL)
                                      {
                                        if (sel_window->objop != NULL)
                                          (*sel_window->objop) (sel_window, sel_objs, OBJ_INFO);
                                      } /* if */
                                      else
                                        if ((top == NULL) || (top->opened == 0))
                                          about_menu ();
                                        else
                                          if ((top->showinfo == NULL) || ! (*top->showinfo) (top, NIL)) hndl_alert (ERR_NOINFO);
                                      break;
                      case MDBINFO  : mdbinfo ();
                                      break;
                      case MTBLINFO : mtblinfo ();
                                      break;
                      case MINXINFO : minxinfo ();
                                      break;
                    } /* switch */
                    break;
    case FUNCMENUS: switch (item)
                    {
                      case MQNEW  : qbe_new ();
                                    break;
                      case MQLIST : open_syslist (actdb, SYS_QUERY, &fontdesc, NULL, FALSE);
                                    break;
                      case MRNEW  : report_new ();
                                    break;
                      case MRLIST : open_syslist (actdb, SYS_REPORT, &fontdesc, NULL, FALSE);
                                    break;
                      case MCNEW  : calc_new ();
                                    break;
                      case MCLIST : open_syslist (actdb, SYS_CALC, &fontdesc, NULL, FALSE);
                                    break;
                      case MBNEW  : batch_new ();
                                    break;
                      case MBLIST : open_syslist (actdb, SYS_BATCH, &fontdesc, NULL, FALSE);
                                    break;
#ifdef VER_4_2
                      case MANEW  : report_new ();
                                    break;
                      case MALIST : open_syslist (actdb, SYS_REPORT, &fontdesc, NULL, FALSE);
                                    break;
#else
                      case MANEW  : AccDefNew ();
                                    break;
                      case MALIST : open_syslist (actdb, SYS_ACCOUNT, &fontdesc, NULL, FALSE);
                                    break;
#endif
                    } /* switch */
                    break;
  } /* switch */

  if (title != FUNCMENUS)
    menu_normal (window, title, TRUE);          /* Titel wieder normal darstellen */
} /* hndl_menu */

/*****************************************************************************/

GLOBAL VOID hndl_va_start (BYTE *filename)
{
  EXT ext;

  file_split (filename, NULL, NULL, NULL, ext);

  if ((strcmpi (ext, FREETXT (FINDSUFF) + 2) == 0) ||
      (strcmpi (ext, FREETXT (FDATSUFF) + 2) == 0))
     mopendb (filename, TRUE);
} /* hndl_va_start */

/*****************************************************************************/

GLOBAL VOID hndl_ap_term (WORD caller_apid, WORD reason)
{
  WORD msg [8];

  done = check_close ();

  if (done)
    called_by [0] = EOS;		/* Programm ganz beenden */
  else
  {
    msg [0] = AP_TFAIL;
    msg [1] = FAILURE;

    shel_write (SHW_AESSEND, 0, 0, (BYTE *)msg, NULL);
  } /* else */
} /* hndl_ap_term */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_menu (VOID)
{
  WORD title, menubox, i;
  WORD ddiff;
  RECT mbox, tbox;

  funcmenus [0].title = MHELP;            /* MenÅs der Funktionstasten */
  funcmenus [0].item  = MHELPCXT;

  funcmenus [1].title = MFILE;
  funcmenus [1].item  = MOPEN;

  funcmenus [2].title = MFILE;
  funcmenus [2].item  = MCLOSE;

  funcmenus [3].title = MFILE;
  funcmenus [3].item  = MCLOSEDB;

  funcmenus [4].title = MEDIT;
  funcmenus [4].item  = MICONIFY;

  funcmenus [5].title = MHELP;	          /* Wird Abfrage îffnen */
  funcmenus [5].item  = MDBINFO;

  funcmenus [6].title = MHELP;            /* Wird Bericht îffnen */
  funcmenus [6].item  = MDBINFO;

  funcmenus [7].title = MHELP;	          /* Wird Rechnen îffnen */
  funcmenus [7].item  = MDBINFO;

  funcmenus [8].title = MHELP;	          /* Wird Batch îffnen */
  funcmenus [8].item  = MDBINFO;

  funcmenus [9].title = MEDIT;
  funcmenus [9].item  = MEDITDAT;

  setclr (menus);                         /* Keine MenÅs auf Funktionstasten */

  menu_ok   = (menu != NULL);
  menu_fits = FALSE;
  ccp_ext   = (menu_ok && is_state (menu, MTOCLIP, CHECKED)) ? DO_EXTERNAL : 0;

  if (menu_ok) menu_fits = menu [THEACTIVE].ob_x + menu [THEACTIVE].ob_width <= desk.w;
  if ((class_desk == DESK) && menu_ok && ! menu_fits) class_desk = DESKWINDOW; /* MenÅzeile im Fenster */

  if (menu_ok && menu_fits)
  {
    menubox = menu [ROOT].ob_tail;
    menubox = menu [menubox].ob_head;
    title   = THEFIRST;

    do
    {
      objc_rect (menu, menubox, &mbox, FALSE);
      objc_rect (menu, title, &tbox, FALSE);

      ddiff = mbox.x + mbox.w + gl_wbox - (desk.x + desk.w);  /* Differenz zum Desktop (gl_wbox wegen OUTLINED) */

      if (ddiff > 0) menu [menubox].ob_x -= ddiff;      /* Hing rechts heraus */

      menubox = menu [menubox].ob_next;                 /* NÑchstes Drop-Down-MenÅ */
      title   = menu [title].ob_next;                   /* NÑchster Titel */
    } while (title != THEACTIVE);
  } /* if */

  if (deskacc)
  {
    menu_enable (menu, MDESIGNE, FALSE);
    menu_enable (menu, MREORG, FALSE);
    menu_enable (menu, MPROGRAM, FALSE);
  } /* if */

  DELETE_MENU (MHELPOBJ);

  DELETE_MENU (MGROUP - 1);
  DELETE_MENU (MGROUP);

  return (TRUE);
} /* init_menu */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_menu (VOID)
{
  return (TRUE);
} /* term_menu */

/*****************************************************************************/


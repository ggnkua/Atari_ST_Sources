/*****************************************************************************
 *
 * Module : MENU.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 01.11.02
 *
 *
 * Description: This module implements the menu functions.
 *
 * History:
 * 01.11.02: Im Info-Dialog wird das Datum und die Version eingetragen
 * 12.06.96: Function hndl_ap_term added
 * 23.03.94: Function hndl_va_start added
 * 28.02.94: MASCEXP added
 * 19.11.93: Call to userinterface_dialog modified
 * 10.10.93: #include mselfont deleted
 * 25.10.93: Test if BASE_RDONLY in updt_menu added
 * 11.10.93: User interface menu added
 * 17.09.93: New images for about logo changed
 * 01.07.89: Creation of body
 *****************************************************************************/


#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "bload.h"
#include "base.h"
#include "desktop.h"
#include "dialog.h"
#include "imageobj.h"
#include "mask.h"
#include "mfile.h"
#include "moptions.h"
#include "resource.h"
#include "userintr.h"
#include "version.h"

#include "export.h"
#include "menu.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL IMGOBJ img_logo;                  /* logo for about box */

/* [GS] 5.2 old:
#include "designr1.h"
#include "designr4.h"
*/

/****** FUNCTIONS ************************************************************/

LOCAL VOID    mabout      _((VOID));
LOCAL VOID    minfo       _((VOID));

LOCAL VOID    draw_about  _((WINDOWP window));
LOCAL VOID    open_about  _((WINDOWP window));
LOCAL VOID    close_about _((WINDOWP window));
LOCAL VOID    click_about _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN info_about  _((WINDOWP window, WORD icon));

/*****************************************************************************/

LOCAL VOID mabout ()

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

/* [GS] 5.2 old:
      do_flags (about, ALOGO, HIDETREE);
*/
    } /* if */
  } /* if */

  if (window != NULL)
    if (! open_dialog (ABOUT))
      hndl_alert (ERR_NOOPEN);
} /* mabout */

/*****************************************************************************/

LOCAL VOID minfo ()

{
  WINDOWP window;
  WORD    ret;
  BOOLEAN ok;

  window = search_window (CLASS_DIALOG, SRCH_ANY, MOREINFO);

  if (window == NULL)
  {
    form_center (moreinfo, &ret, &ret, &ret, &ret);
    moreinfo->ob_x += 2 * gl_wbox;
    moreinfo->ob_y += 1 * gl_hbox;
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
} /* minfo */

/*****************************************************************************/

LOCAL VOID open_about (window)
WINDOWP window;

{
	BYTE str[30];
/* [GS] 5.2 old:
  WORD    ret;
  IMGOBJP img;
  OBJECT  *obj;
*/

  draw_growbox (window, TRUE);

	strcpy ( str, DESIGNER_VERSION );
	strcat ( str, ", " );
	strcat ( str, __DATE__ );
	set_str ( about , AVERSION, str );

/* [GS] 5.2 old:
  img = &img_logo;
  obj = &about [ALOGO];

  img->window    = window;
  ret            = image_obj (img, IMG_INIT, IMG_MEM, (colors < 16) || (colors > 256) ? designr1 : designr4);
  img->bufsize   = sizeof ((colors < 16) || (colors > 256) ? designr1 : designr4);
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

LOCAL VOID close_about (window)
WINDOWP window;

{
  draw_growbox (window, FALSE);

/* [GS] 5.2 old:
  image_obj (&img_logo, IMG_EXIT, IMG_MEM, NULL);
*/

  set_meminfo ();
} /* close_about */

/*****************************************************************************/

LOCAL VOID draw_about (window)
WINDOWP window;

{
/* [GS] 5.2 old:
  image_obj (&img_logo, IMG_DRAW, 0, NULL);
*/
} /* draw_about */

/*****************************************************************************/

LOCAL VOID click_about (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if (window->exit_obj == AINFO)
  {
    undo_state (window->object, window->exit_obj, SELECTED);
    draw_object (window, window->exit_obj);
    minfo ();
  } /* if */
} /* click_about */

/*****************************************************************************/

LOCAL BOOLEAN info_about (window, icon)
WINDOWP window;
WORD    icon;

{
  minfo ();

  return (TRUE);
} /* info_about */

/*****************************************************************************/
/* menu handling                                                             */
/*****************************************************************************/

GLOBAL VOID updt_menu (window)
WINDOWP window;

{
  WORD      i;
  SET       after;
  LONGSTR   s;
  WINDOWP   top;
  BOOLEAN   ccp;
  BOOLEAN   bm_top;     /* base or mask window ist top */
  BOOLEAN   save, save_as, abort;
  BOOLEAN   export, import;
  BASE_SPEC *base_spec;
  MASK_SPEC *mask_spec;

  if (menu_ok && updtmenu)
  {
    bm_top  = FALSE;
    save    = FALSE;
    save_as = FALSE;
    abort   = FALSE;
    export  = FALSE;
    import  = TRUE;
    top     = find_top ();

    switch (top->class)
    {
      case CLASS_BASE : base_spec = (BASE_SPEC *)top->special;
                        export    = ! base_spec->new && ! base_spec->modified;
                        bm_top    = TRUE;
                        abort     = base_spec->modified && ! base_spec->new;
                        if (base_spec->modified && ! base_spec->untitled) save = TRUE;
                        if (base_spec->new) save_as = TRUE;
                        if (! base_spec->new && (base_spec->base->datainf->flags & BASE_RDONLY)) save = FALSE;
                        break;
      case CLASS_MASK : bm_top    = TRUE;
                        mask_spec = (MASK_SPEC *)top->special;
                        if (mask_spec->modified) save = TRUE;
                        if (! mask_spec->new && (mask_spec->base_spec->base->datainf->flags & BASE_RDONLY)) save = FALSE;
                        save_as = FALSE;
                        break;
    } /* switch */

    ccp = (top != NULL) && (top->test != NULL) && (top->edit != NULL);

    menu_enable (menu, MCLOSE,   any_open (FALSE, TRUE, FALSE));
    menu_enable (menu, MSAVE,    save);
    menu_enable (menu, MSAVEAS,  save_as);
    menu_enable (menu, MABORT,   abort);
    menu_enable (menu, MEXPORT,  export);
    menu_enable (menu, MIMPORT,  import);
    menu_enable (menu, MASCEXP,  export);
    menu_enable (menu, MPRINT,   bm_top && gdos_ok ());
    menu_enable (menu, MUNDO,    ccp && (*top->test) (top, DO_UNDO   | ccp_ext));
    menu_enable (menu, MCUT,     ccp && (*top->test) (top, DO_CUT    | ccp_ext));
    menu_enable (menu, MCOPY,    ccp && (*top->test) (top, DO_COPY   | ccp_ext));
    menu_enable (menu, MPASTE,   ccp && (*top->test) (top, DO_PASTE  | ccp_ext));
    menu_enable (menu, MCLEAR,   ccp && (*top->test) (top, DO_CLEAR  | ccp_ext));
    menu_enable (menu, MSELALL,  ccp && (*top->test) (top, DO_SELALL | ccp_ext));

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
        if (setin (after, i)) strcat (s, FREETXT (FM1 + i));
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

GLOBAL VOID hndl_menu (window, title, item)
WINDOWP window;
WORD    title, item;

{
  WINDOWP   top;
  BOOLEAN   to_clip;
  WORD      obj;
  MKINFO    mk;
  FULLNAME  s;
  BASE_SPEC *base_spec;
  MASK_SPEC *mask_spec;

  if (is_state (menu, title, DISABLED) ||       /* Accessory kînnte Nachricht geschickt haben */
      is_state (menu, item, DISABLED)) return;

  menu_normal (window, title, FALSE);           /* Titel invers darstellen */

  top = find_top ();

  switch (title)
  {
    case MDESK    : if (item == MABOUT) mabout ();
                    break;
    case MFILE    : switch (item)
                    {
                      case MNEW    : mnewdb ();
                                     break;
                      case MOPEN   : if (sel_window == NULL)
                                        mopendb ("", TRUE);
                                     else
                                       if (sel_window->objop != NULL) (*sel_window->objop) (sel_window, sel_objs, OBJ_OPEN);
                                     break;
                      case MCLOSE  : close_top ();
                                     break;
                      case MSAVE   : unclick_window (sel_window);
                                     switch (top->class)
                                     {
                                       case CLASS_BASE : save_base (top); break;
                                       case CLASS_MASK : save_mask (top); break;
                                     } /* switch */
                                     break;
                      case MSAVEAS : unclick_window (sel_window);
                                     switch (top->class)
                                     {
                                       case CLASS_BASE : if (msave_as (top)) save_base (top); break;
                                       case CLASS_MASK : break;
                                     } /* switch */
                                     break;
                      case MABORT  : unclick_window (sel_window);
                                     switch (top->class)
                                     {
                                       case CLASS_BASE : base_spec        = (BASE_SPEC *)top->special;
                                                         base_spec->abort = TRUE;
                                                         save_base (top);
                                                         break;
                                       case CLASS_MASK : mask_spec        = (MASK_SPEC *)top->special;
                                                         mask_spec->abort = TRUE;
                                                         save_mask (top);
                                                         break;
                                     } /* switch */
                                     break;
                      case MEXPORT : mexport ((BASE_SPEC *)top->special, NULL);
                                     break;
                      case MIMPORT : mimport ();
                                     break;
                      case MASCEXP : mascexp ((BASE_SPEC *)top->special, NULL);
                                     break;
                      case MPRINT  : switch (top->class)
                                     {
                                       case CLASS_BASE : print_base (top); break;
                                       case CLASS_MASK : print_mask (top); break;
                                     } /* switch */
                                     break;
                      case MQUIT   : strcpy (s, app_path);
                                     strcat (s, FREETXT (FDESKNAM));
                                     str_rmchar (s, SP);
                                     strcat (s, FREETXT (FINFSUFF) + 1);
                                     if (autosave) msave_config (s);

                                     if (close_bases ())
                                     {
                                       done          = TRUE;
                                       called_by [0] = EOS;     /* terminate programm */
                                     } /* if */
                                     break;
                    } /* switch */
                    break;
    case MEDIT    : switch (item)
                    {
                      case MUNDO    : (*top->edit) (top, DO_UNDO   | ccp_ext); break;
                      case MCUT     : (*top->edit) (top, DO_CUT    | ccp_ext); break;
                      case MCOPY    : (*top->edit) (top, DO_COPY   | ccp_ext); break;
                      case MPASTE   : (*top->edit) (top, DO_PASTE  | ccp_ext); break;
                      case MCLEAR   : (*top->edit) (top, DO_CLEAR  | ccp_ext); break;
                      case MSELALL  : (*top->edit) (top, DO_SELALL | ccp_ext); break;
                      case MCYCLEWI : cycle_window ();                         break;
                      case MTOCLIP  : to_clip = ccp_ext == 0;
                                      menu_check (menu, MTOCLIP, to_clip);
                                      ccp_ext = to_clip ? DO_EXTERNAL : 0;
                                      break;
                    } /* switch */
                    break;
    case MOPTIONS : switch (item)
                    {
                      case MCONFIG  : mconfig ();
                                      break;
                      case MPARAMS  : mparams ();
                                      break;
                      case MLOADCFG : if (! mload_config ("", TRUE)) hndl_alert (ERR_LOADCONFIG);
                                      break;
                      case MSAVECFG : if (! msave_config ("")) hndl_alert (ERR_SAVECONFIG);
                                      break;
                      case MUSERINT : userinterface_dialog (FREETXT (FUSERINTR), get_str (helpinx, HUSERINT));
                                      break;
                    } /* switch */
    case MHELP    : switch (item)
                    {
                      case MHELPCXT : if ((top == NULL) || (top->opened == 0))
                                        hndl_alert (ERR_NOHELP);
                                      else
                                        if (top->flags & (WI_MODAL | WI_MODELESS))
                                        {
                                          obj = find_flags (top->object, ROOT, HELP_FLAG);

                                          if (obj != NIL)
                                          {
                                            top->exit_obj = obj;
                                            do_state (top->object, obj, SELECTED);
                                            draw_object (top, obj);
                                            mem_set (&mk, 0, sizeof (mk));
                                            if (top->click != NULL) (*top->click) (top, &mk);
                                          } /* if */
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
                                          mabout ();
                                        else
                                          if ((top->showinfo == NULL) || ! (*top->showinfo) (top, NIL)) hndl_alert (ERR_NOINFO);
                                      break;
                    } /* switch */
                    break;
  } /* switch */

  menu_normal (window, title, TRUE);            /* Titel wieder normal darstellen */
} /* hndl_menu */

/*****************************************************************************/

GLOBAL VOID hndl_va_start (BYTE *filename)
{
  EXT ext;

  file_split (filename, NULL, NULL, NULL, ext);

  if ((strcmp (ext, FREETXT (FINDSUFF) + 2) == 0) ||
      (strcmp (ext, FREETXT (FDATSUFF) + 2) == 0))
     mopendb (filename, TRUE);
} /* hndl_va_start */

/*****************************************************************************/

GLOBAL VOID hndl_ap_term (WORD caller_apid, WORD reason)
{
  WORD msg [8];

  done = close_bases ();

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

GLOBAL BOOLEAN init_menu ()

{
  WORD   title, menubox, i;
  WORD   ddiff;
  RECT   mbox, tbox;

  funcmenus [0].title = MHELP;            /* MenÅs der Funktionstasten */
  funcmenus [0].item  = MHELPCXT;

  funcmenus [1].title = MFILE;
  funcmenus [1].item  = MOPEN;

  funcmenus [2].title = MFILE;
  funcmenus [2].item  = MCLOSE;

  funcmenus [3].title = MHELP;
  funcmenus [3].item  = MINFO;

  funcmenus [4].title = MOPTIONS;
  funcmenus [4].item  = MCONFIG;

  funcmenus [5].title = MOPTIONS;
  funcmenus [5].item  = MPARAMS;

  funcmenus [6].title = MFILE;
  funcmenus [6].item  = MNEW;

  funcmenus [7].title = MFILE;
  funcmenus [7].item  = MSAVE;

  funcmenus [8].title = MFILE;
  funcmenus [8].item  = MABORT;

  funcmenus [9].title = MFILE;
  funcmenus [9].item  = MQUIT;

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

  i = MHELPOBJ;
  while (menu [i].ob_next > i) menu [++i].ob_y -= gl_hbox;
  menu [menu [i].ob_next].ob_height -= gl_hbox;
  objc_delete (menu, MHELPOBJ);

  return (TRUE);
} /* init_menu */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_menu ()

{
  return (TRUE);
} /* term_menu */


/*****************************************************************************
 *
 * Module : BACCESS.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.01.95
 *
 *
 * Description: This module implements the base access dialog box.
 *
 * History:
 * 04.01.95: Using new function names of controls module
 * 15.04.94: Readonly and show systables functionality added
 * 30.10.93: LBS_TOUCHEXIT removed in call to ListBoxSetStyle
 * 25.10.93: Error in set_access removed
 * 20.10.93: Callback routines improved
 * 14.10.93: New 3D listboxes used
 * 06.09.93: set_ptext -> set_str
 * 30.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "butil.h"

#include "export.h"
#include "baccess.h"

/****** DEFINES **************************************************************/

#define GRANT_COLS (GRANT_SELECT | GRANT_INSERT | GRANT_UPDATE)

/****** TYPES ****************************************************************/

typedef struct
{
  BASE_SPEC *base_spec;
  WORD      *t_flags;
  WORD      *c_flags;
  LONG      *del_adr;
  SYSUSER   *sysuser;
  BOOL      bReadOnly;
  WORD      num_users;
  BOOL      bShowSysTables;
} AC_SPEC;

/****** VARIABLES ************************************************************/

LOCAL WORD    exit_obj;		/* will be set for modal dialogue boxes */
LOCAL WORD    del_inx;		/* users that go into delete list */
LOCAL WORD    sFirstTable;	/* number of table which should be shown first */
LOCAL STRING  szName;		/* used for callback functions */
LOCAL AC_SPEC ac_spec;

/****** FUNCTIONS ************************************************************/

LOCAL LONG    usr_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    tbl_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    col_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));

LOCAL VOID    set_access    _((WINDOWP window));
LOCAL VOID    open_access   _((WINDOWP window));
LOCAL VOID    close_access  _((WINDOWP window));
LOCAL VOID    click_access  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_access    _((WINDOWP window, MKINFO *mk));

LOCAL VOID    set_buttons   _((WINDOWP window));
LOCAL VOID    set_flags     _((WINDOWP window, WORD user, WORD table, WORD column));
LOCAL VOID    get_flags     _((WINDOWP window, WORD user, WORD table, WORD column));
LOCAL VOID    put_flags     _((WINDOWP window, WORD user));
LOCAL VOID    del_user      _((AC_SPEC *ac_spec, WORD index));
LOCAL WORD    get_tflags    _((VOID));
LOCAL WORD    get_cflags    _((VOID));
LOCAL WORD    col_obj       _((UWORD flags));
LOCAL BOOLEAN xget_checkbox _((OBJECT *tree, WORD obj));
LOCAL BOOLEAN user_exists   _((AC_SPEC *ac_spec, BYTE *username));

/*****************************************************************************/

GLOBAL VOID maccess (base_spec)
BASE_SPEC *base_spec;

{
  WINDOWP window;
  WORD    ret, user;
  LONG    size;
  BYTE    *buffer;

  exit_obj = ACCANCEL;
  del_inx  = 0;
  window   = search_window (CLASS_DIALOG, SRCH_ANY, BACCESS);

  if (window == NULL)
  {
    form_center (baccess, &ret, &ret, &ret, &ret);
    window = crt_dialog (baccess, NULL, BACCESS, FREETXT (FACCESS), WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_access;
      window->close   = close_access;
      window->click   = click_access;
      window->key     = key_access;
      window->special = (LONG)&ac_spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (baccess, ROOT, EDITABLE);
    window->edit_inx = NIL;

    size    = (base_spec->num_tables + base_spec->num_columns) * sizeof (WORD);
    size   += base_spec->max_users * sizeof (LONG);
    size   += base_spec->max_users * sizeof (SYSUSER);
    buffer  = mem_alloc (size);
    if (buffer == NULL)
    {
      hndl_alert (ERR_NOMEMORY);
      return;
    } /* if */

    ac_spec.base_spec      = base_spec;
    ac_spec.t_flags        = (WORD *)buffer; buffer += base_spec->num_tables  * sizeof (WORD);
    ac_spec.c_flags        = (WORD *)buffer; buffer += base_spec->num_columns * sizeof (WORD);
    ac_spec.del_adr        = (LONG *)buffer; buffer += base_spec->max_users   * sizeof (LONG);
    ac_spec.sysuser        = (SYSUSER *)buffer;
    ac_spec.num_users      = base_spec->num_users;
    ac_spec.bShowSysTables = FALSE;

    sFirstTable = ac_spec.bShowSysTables ? SYS_TABLE : NUM_SYSTABLES;

    set_access (window);
    set_meminfo ();

    ListBoxSetSpec (baccess, BAUSERS,  (LONG)window);
    ListBoxSetSpec (baccess, BATABLES, (LONG)window);
    ListBoxSetSpec (baccess, BAFIELDS, (LONG)window);

    if (! open_dialog (BACCESS))
      hndl_alert (ERR_NOOPEN);
    else
      if (exit_obj == ACOK)
      {
        base_spec->num_users = ac_spec.num_users;
        base_spec->modified  = TRUE;
        mem_lmove (base_spec->sysuser, ac_spec.sysuser, (LONG)base_spec->num_users * sizeof (SYSUSER));

        base_spec->sysuser->flags &= ~USER_READONLY;	/* user user must not have read only rights */

        for (user = 0; user < base_spec->max_users; user++)
          if (ac_spec.del_adr [user] != 0)
          {
            if (base_spec->delptr == MAX_DEL) hndl_alert (ERR_DELUSER);

            base_spec->delobjs [base_spec->delptr].table   = SYS_USER;
            base_spec->delobjs [base_spec->delptr].address = ac_spec.del_adr [user];
            base_spec->delptr++;
          } /* if, for */
      } /* if, else */

    mem_free (ac_spec.t_flags);
    set_meminfo ();
  } /* if */
} /* maccess */

/*****************************************************************************/

LOCAL LONG usr_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  RECT         r;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  AC_SPEC      *ac_spec;

  window    = (WINDOWP)ListBoxGetSpec (tree, obj);
  ac_spec   = (AC_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)ac_spec->sysuser [index].name);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                          r    = lb_ownerdraw->rc_item;
                          r.w  = 2 * gl_wbox;
                          DrawOwnerIcon (lb_ownerdraw, &r, &usr_icon, text, 2);
                          break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* usr_callback */

/*****************************************************************************/

LOCAL LONG tbl_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WORD         table;
  WINDOWP      window;
  RECT         r;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  SYSTABLE     *systable;
  BASE_SPEC    *base_spec;
  AC_SPEC      *ac_spec;

  window    = (WINDOWP)ListBoxGetSpec (tree, obj);
  ac_spec   = (AC_SPEC *)window->special;
  base_spec = (BASE_SPEC *)ac_spec->base_spec;
  table     = index + sFirstTable;
  systable  = &base_spec->systable [table];

  switch (msg)
  {
    case LBN_GETITEM    : if (ac_spec->bShowSysTables && (index < NUM_SYSTABLES))
                            sprintf (szName, "SYSTEM.%s", FREETXT (FTABLES + index));
                          else
                            strcpy (szName, systable->name);

                          return ((LONG)szName);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                          r    = lb_ownerdraw->rc_item;
                          r.w  = 2 * gl_wbox;
                          DrawOwnerIcon (lb_ownerdraw, &r, &tbl_icon, text, 2);
                          break;
    case LBN_SELCHANGE  : ListBoxSetCount (baccess, BAFIELDS, systable->cols - 1, NULL);	/* don't use field "DbAddress" */
                          ListBoxSetCurSel (baccess, BAFIELDS, 0);
                          ListBoxSetTopIndex (baccess, BAFIELDS, 0);
                          ListBoxRedraw (baccess, BAFIELDS);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* tbl_callback */

/*****************************************************************************/

LOCAL LONG col_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WORD         table, abs_col;
  WINDOWP      window;
  RECT         r;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  BASE_SPEC    *base_spec;
  AC_SPEC      *ac_spec;
  SYSCOLUMN    *syscolumn;
 
  window    = (WINDOWP)ListBoxGetSpec (tree, obj);
  ac_spec   = (AC_SPEC *)window->special;
  base_spec = (BASE_SPEC *)ac_spec->base_spec;
  table     = ListBoxGetCurSel (baccess, BATABLES) + sFirstTable;
  abs_col   = abscol (base_spec, table, index + 1);	/* don't use field "DbAddress" */
  syscolumn = &base_spec->syscolumn [abs_col];

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)syscolumn->name);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                          r    = lb_ownerdraw->rc_item;
                          r.w  = 2 * gl_wbox;
                          DrawOwnerIcon (lb_ownerdraw, &r, &col_icon, text, 2);
                          break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* col_callback */

/*****************************************************************************/

LOCAL VOID set_access (window)
WINDOWP window;

{
  WORD       table, w;
  FULLNAME   dbname;
  SYSTABLE   *systable;
  BASE_SPEC  *base_spec;
  AC_SPEC    *ac_spec;

  ac_spec   = (AC_SPEC *)window->special;
  base_spec = (BASE_SPEC *)ac_spec->base_spec;

  mem_lmove (ac_spec->sysuser, base_spec->sysuser, (LONG)ac_spec->num_users * sizeof (SYSUSER));
  mem_set (ac_spec->del_adr, 0, base_spec->max_users * sizeof (LONG));

  strcpy (dbname, base_spec->basepath);
  strcat (dbname, base_spec->basename);
  w          = baccess [ADBNAME].ob_width / gl_wbox;
  dbname [w] = EOS;
  strcpy (get_str (baccess, ADBNAME), dbname);

  set_str (baccess, AUSER,  "");

  table    = sFirstTable;
  systable = &base_spec->systable [table];

  ListBoxSetCallback (baccess, BAUSERS, usr_callback);
  ListBoxSetStyle (baccess, BAUSERS, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE, TRUE);
  ListBoxSetLeftOffset (baccess, BAUSERS, gl_wbox / 2);
  ListBoxSetCount (baccess, BAUSERS, ac_spec->num_users, NULL);
  ListBoxSetCurSel (baccess, BAUSERS, (ac_spec->num_users > 0) ? 0 : FAILURE);
  ListBoxSetTopIndex (baccess, BAUSERS, 0);

  ListBoxSetCallback (baccess, BATABLES, tbl_callback);
  ListBoxSetStyle (baccess, BATABLES, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE, TRUE);
  ListBoxSetLeftOffset (baccess, BATABLES, gl_wbox / 2);
  ListBoxSetCount (baccess, BATABLES, base_spec->num_tables - table, NULL);
  ListBoxSetCurSel (baccess, BATABLES, 0);
  ListBoxSetTopIndex (baccess, BATABLES, 0);

  ListBoxSetCallback (baccess, BAFIELDS, col_callback);
  ListBoxSetStyle (baccess, BAFIELDS, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE, TRUE);
  ListBoxSetLeftOffset (baccess, BAFIELDS, gl_wbox / 2);
  ListBoxSetCount (baccess, BAFIELDS, systable->cols - 1, NULL);	/* don't use field "DbAddress" */
  ListBoxSetCurSel (baccess, BAFIELDS, 0);
  ListBoxSetTopIndex (baccess, BAFIELDS, 0);

  if ((colors >= 16) && (gl_hbox > 8))
  {
    ListBoxSetStyle (baccess, BAUSERS,  LBS_OWNERDRAW, usr_icon.data != NULL);
    ListBoxSetStyle (baccess, BATABLES, LBS_OWNERDRAW, tbl_icon.data != NULL);
    ListBoxSetStyle (baccess, BAFIELDS, LBS_OWNERDRAW, col_icon.data != NULL);
  } /* if */

  set_buttons (window);
  set_flags (window, (ac_spec->num_users > 0) ? 0 : FAILURE, table, 1);
} /* set_access */

/*****************************************************************************/

LOCAL VOID open_access (window)
WINDOWP window;

{
  draw_growbox (window, TRUE);
} /* open_access */

/*****************************************************************************/

LOCAL VOID close_access (window)
WINDOWP window;

{
  draw_growbox (window, FALSE);
} /* close_access */

/*****************************************************************************/

LOCAL VOID click_access (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  USERNAME username;

  BOOLEAN   setflags;
  WORD      user, table, column;
  WORD      old_user, old_table, old_column;
  LONGSTR   s, last_used;
  FORMAT    format;
  TIMESTAMP *lu;
  SYSTABLE  *systable;
  SYSUSER   *sysuser;
  BASE_SPEC *base_spec;
  AC_SPEC   *ac_spec;

  ac_spec   = (AC_SPEC *)window->special;
  base_spec = (BASE_SPEC *)ac_spec->base_spec;
  setflags  = FALSE;

  user   = old_user   = ListBoxGetCurSel (baccess, BAUSERS);
  table  = old_table  = ListBoxGetCurSel (baccess, BATABLES) + sFirstTable;
  column = old_column = ListBoxGetCurSel (baccess, BAFIELDS) + 1;	/* dont't use field "DbAddress" */

  switch (window->exit_obj)
  {
    case BAUSERS  :
    case BATABLES :
    case BAFIELDS : if (ListBoxClick (window->object, window->exit_obj, mk) != FAILURE)
                    {
                      get_flags (window, user, table, column);			/* get flags from old user */

                      user   = ListBoxGetCurSel (baccess, BAUSERS);		/* user, table or column may have been modified */
                      table  = ListBoxGetCurSel (baccess, BATABLES) + sFirstTable;
                      column = ListBoxGetCurSel (baccess, BAFIELDS) + 1;	/* dont't use field "DbAddress" */

                      if ((user != old_user) || (table != old_table) || (column != old_column)) setflags = TRUE;
                    } /* if */
                    break;
    case AUINSERT : if (ac_spec->num_users < base_spec->max_users)
                    {
                      get_ptext (baccess, AUSER, username);

                      if (user_exists (ac_spec, username))
                      {
                        sprintf (s, alerts [ERR_USEREXISTS], username);
                        open_alert (s);
                      } /* if */
                      else
                      {
                        set_str (baccess, AUSER, "");
                        draw_object (window, AUSER);

                        user    = ac_spec->num_users++;
                        sysuser = &ac_spec->sysuser [user];
                        mem_set (sysuser, 0, sizeof (SYSUSER));
                        strcpy (sysuser->name, username);
                        set_null (TYPE_TIMESTAMP, &sysuser->lastuse);
                        set_null (TYPE_VARWORD, &sysuser->access);
                        sysuser->flags |= INS_FLAG;

                        ListBoxSetCount (baccess, BAUSERS, ac_spec->num_users, NULL);
                        ListBoxRedraw (baccess, BAUSERS);
                      } /* else */
                    } /* if */
                    else
                      hndl_alert (ERR_NOUSERS);

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case AUDELETE : del_user (ac_spec, user);

                    setflags = TRUE;

                    ListBoxSetCount (baccess, BAUSERS, ac_spec->num_users, NULL);
                    ListBoxSetCurSel (baccess, BAUSERS, FAILURE);
                    ListBoxRedraw (baccess, BAUSERS);

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case AUUPDATE : get_ptext (baccess, AUSER, username);
                    set_str (baccess, AUSER, "");
                    draw_object (window, AUSER);

                    sysuser = &ac_spec->sysuser [user];
                    strcpy (sysuser->name, username);
                    strcpy (sysuser->pass, "");
                    sysuser->flags |= UPD_FLAG;

                    ListBoxRedraw (baccess, BAUSERS);

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case AUINFO   : sysuser = &ac_spec->sysuser [user];
                    lu      = &sysuser->lastuse;

                    if (is_null (TYPE_TIMESTAMP, lu))
                      strcpy (last_used, "-");
                    else
                    {
                      bin2str (TYPE_TIMESTAMP, lu, last_used);
                      build_format (TYPE_TIMESTAMP, FREETXT (FSTDDATE), format);
                      str2format (TYPE_TIMESTAMP, last_used, format);
                    } /* else */

                    sprintf (s, alerts [ERR_USERINFO], sysuser->name, sysuser->count, last_used);
                    open_alert (s);

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case ATSYSTAB : get_flags (window, user, table, column);
                    ac_spec->bShowSysTables = xget_checkbox (baccess, ATSYSTAB);
                    sFirstTable = ac_spec->bShowSysTables ? SYS_TABLE : NUM_SYSTABLES;
                    systable    = &base_spec->systable [sFirstTable];
                    set_flags (window, user, sFirstTable, 0);

                    ListBoxSetCurSel (baccess, BATABLES, 0);
                    ListBoxSetCurSel (baccess, BAFIELDS, 0);
                    ListBoxSetTopIndex (baccess, BATABLES, 0);
                    ListBoxSetTopIndex (baccess, BAFIELDS, 0);
                    ListBoxSetCount (baccess, BATABLES, base_spec->num_tables - sFirstTable, NULL);
                    ListBoxSetCount (baccess, BAFIELDS, systable->cols - 1, NULL);	/* don't use field "DbAddress" */
                    ListBoxRedraw (baccess, BATABLES);
                    ListBoxRedraw (baccess, BAFIELDS);
                    break;
    case ACOK     : get_flags (window, user, table, column);
                    break;
    case ACHELP   : hndl_help (HACCESS);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  set_buttons (window);
  if (setflags) set_flags (window, user, table, column);

  exit_obj = window->exit_obj;
} /* click_access */

/*****************************************************************************/

LOCAL BOOLEAN key_access (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->edit_obj)
  {
    case AUSER : set_buttons (window); break;
  } /* switch */

  exit_obj = window->exit_obj;

  return (FALSE);
} /* key_access */

/*****************************************************************************/

LOCAL VOID set_buttons (window)
WINDOWP window;

{
  USERNAME username;

  get_ptext (baccess, AUSER, username);
  make_id (username);

  if ((*username == EOS) == ! is_state (baccess, AUINSERT, DISABLED))
  {
    flip_state (baccess, AUINSERT, DISABLED);
    draw_object (window, AUINSERT);
  } /* if */

  if (((*username == EOS) || (ListBoxGetCurSel (baccess, BAUSERS) == FAILURE)) == ! is_state (baccess, AUUPDATE, DISABLED))
  {
    flip_state (baccess, AUUPDATE, DISABLED);
    draw_object (window, AUUPDATE);
  } /* if */

  if ((ListBoxGetCurSel (baccess, BAUSERS) == FAILURE) == ! is_state (baccess, AUDELETE, DISABLED))
  {
    flip_state (baccess, AUDELETE, DISABLED);
    draw_object (window, AUDELETE);

    flip_state (baccess, AUINSERT, DISABLED);
    draw_object (window, AUINSERT);

    flip_state (baccess, ATSELECT, DISABLED);
    flip_state (baccess, ATINSERT, DISABLED);
    flip_state (baccess, ATUPDATE, DISABLED);
    flip_state (baccess, ATDELETE, DISABLED);

    flip_state (baccess, AFNONE,   DISABLED);
    flip_state (baccess, AFSELECT, DISABLED);
    flip_state (baccess, AFINSERT, DISABLED);
    flip_state (baccess, AFUPDATE, DISABLED);

    draw_object (window, ATSELECT);
    draw_object (window, ATINSERT);
    draw_object (window, ATUPDATE);
    draw_object (window, ATDELETE);

    draw_object (window, AFNONE);
    draw_object (window, AFSELECT);
    draw_object (window, AFINSERT);
    draw_object (window, AFUPDATE);
  } /* if */

  if ((ListBoxGetCurSel (baccess, BAUSERS) == 0) == ! is_state (baccess, AUREADON, DISABLED))	/* super user #0 must not set read only flag */
    flip_state (baccess, AUREADON, DISABLED);
} /* set_buttons */

/*****************************************************************************/

LOCAL VOID set_flags (window, user, table, column)
WINDOWP window;
WORD    user;
WORD    table;
WORD    column;

{
  WORD      *listp;
  WORD      tbl, col;
  WORD      tflags, cflags;
  LONG      size;
  WORD      *flags;
  SYSUSER   *sysuser;
  BASE_SPEC *base_spec;
  AC_SPEC   *ac_spec;

  ac_spec   = (AC_SPEC *)window->special;
  base_spec = (BASE_SPEC *)ac_spec->base_spec;
  size      = 0;

  flags = ac_spec->t_flags;
  for (tbl = 0; tbl < base_spec->num_tables; tbl++) flags [tbl] = GRANT_ALL;

  flags = ac_spec->c_flags;
  for (col = 0; col < base_spec->num_columns; col++) flags [col] = GRANT_ALL;

  if (user != NIL)
  {
    sysuser = &ac_spec->sysuser [user];
    size    = sysuser->access.size / sizeof (WORD);
    listp   = sysuser->access.list;

    ac_spec->bReadOnly = (sysuser->flags & USER_READONLY) != 0;
  } /* if */
  else
    ac_spec->bReadOnly = FALSE;

  while (size > 0)
  {
    tbl = *listp++;                             /* get table access flags */
    size--;
    ac_spec->t_flags [tbl] = *listp;

    listp++;
    size--;

    while ((*listp != -1) && (size > 0))        /* get column access flags */
    {
      col = *listp++;
      size--;

      ac_spec->c_flags [abscol (base_spec, tbl, col)] = *listp;

      listp++;
      size--;
    } /* while */

    listp++;
    size--;
  } /* while */

  if (user == NIL)
  {
    tflags = GRANT_NOTHING;
    cflags = GRANT_NOTHING;
  } /* if */
  else
  {
    tflags = ac_spec->t_flags [table];
    cflags = ac_spec->c_flags [abscol (base_spec, table, column)];
  } /* else */

  set_checkbox (baccess, AUREADON, ac_spec->bReadOnly);
  draw_object (window, AUREADON);

  set_checkbox (baccess, ATSELECT, tflags & GRANT_SELECT);
  set_checkbox (baccess, ATINSERT, tflags & GRANT_INSERT);
  set_checkbox (baccess, ATUPDATE, tflags & GRANT_UPDATE);
  set_checkbox (baccess, ATDELETE, tflags & GRANT_DELETE);
  set_checkbox (baccess, ATSYSTAB, ac_spec->bShowSysTables);

  draw_object (window, ATSELECT);
  draw_object (window, ATINSERT);
  draw_object (window, ATUPDATE);
  draw_object (window, ATDELETE);
  draw_object (window, ATSYSTAB);

  set_rbutton (baccess, col_obj (cflags), AFNONE, AFUPDATE);

  draw_object (window, AFNONE);
  draw_object (window, AFSELECT);
  draw_object (window, AFINSERT);
  draw_object (window, AFUPDATE);
} /* set_flags */

/*****************************************************************************/

LOCAL VOID get_flags (window, user, table, column)
WINDOWP window;
WORD    user;
WORD    table;
WORD    column;

{
  WORD      abs_col;
  BASE_SPEC *base_spec;
  AC_SPEC   *ac_spec;

  if (user == NIL) return;

  ac_spec   = (AC_SPEC *)window->special;
  base_spec = (BASE_SPEC *)ac_spec->base_spec;
  abs_col   = abscol (base_spec, table, column);

  ac_spec->t_flags [table]   = get_tflags ();
  ac_spec->c_flags [abs_col] = get_cflags ();
  ac_spec->bReadOnly         = xget_checkbox (baccess, AUREADON);

  put_flags (window, user);
} /* get_flags */

/*****************************************************************************/

LOCAL VOID put_flags (window, user)
WINDOWP window;
WORD    user;

{
  BOOLEAN   col_grant;
  WORD      table, col, abs_col;
  WORD      t_flag;
  LONG      size;
  WORD      *listp;
  WORD      *flags;
  SYSTABLE  *systable;
  SYSUSER   *sysuser;
  BASE_SPEC *base_spec;
  AC_SPEC   *ac_spec;

  if (user == NIL) return;

  ac_spec   = (AC_SPEC *)window->special;
  base_spec = (BASE_SPEC *)ac_spec->base_spec;
  sysuser   = &ac_spec->sysuser [user];
  listp     = sysuser->access.list;
  size      = 0;

  for (table = 0; table < base_spec->num_tables; table++)
  {
    t_flag    = ac_spec->t_flags [table];
    *listp++  = table;
    *listp++  = t_flag;
    size     += 2;

    systable  = &base_spec->systable [table];
    abs_col   = abscol (base_spec, table, 1);   /* don't use field "DbAddress" */
    flags     = &ac_spec->c_flags [abs_col];
    col_grant = FALSE;

    for (col = 1; col < systable->cols; col++, flags++)
    {
      *flags &= GRANT_COLS;

      if (*flags != GRANT_COLS)
      {
        col_grant = TRUE;
        *listp++  = col;
        *listp++  = *flags;
        size     += 2;
      } /* if */
    } /* if */

    if (col_grant || (t_flag != GRANT_ALL))
    {
      *listp++ = -1;
      size++;
    } /* if */
    else                                        /* cancel grant to table */
    {
      listp -= 2;
      size  -= 2;
    } /* if, else */
  } /* for */

  sysuser->access.size  = size * sizeof (WORD);
  sysuser->flags       |= UPD_FLAG;

  if (ac_spec->bReadOnly)
    sysuser->flags |= USER_READONLY;
  else
    sysuser->flags &= ~USER_READONLY;
} /* put_flags */

/*****************************************************************************/

LOCAL VOID del_user (ac_spec, index)
AC_SPEC *ac_spec;
WORD    index;

{
  SYSUSER *sysuser;

  sysuser = &ac_spec->sysuser [index];

  if (sysuser->flags & MOD_FLAG)        /* put into delete list */
    ac_spec->del_adr [del_inx++] = sysuser->address;

  ac_spec->num_users--;
  mem_lmove (sysuser, sysuser + 1, (LONG)sizeof (SYSUSER) * (ac_spec->num_users - index));
} /* del_user */

/*****************************************************************************/

LOCAL WORD get_tflags ()

{
  UWORD flags;

  flags = GRANT_NOTHING;

  if (xget_checkbox (baccess, ATSELECT)) flags |= GRANT_SELECT;
  if (xget_checkbox (baccess, ATINSERT)) flags |= GRANT_INSERT;
  if (xget_checkbox (baccess, ATUPDATE)) flags |= GRANT_UPDATE;
  if (xget_checkbox (baccess, ATDELETE)) flags |= GRANT_DELETE;

  return (flags);
} /* get_tflags */

/*****************************************************************************/

LOCAL WORD get_cflags ()

{
  WORD  obj;
  UWORD flags;

  flags = GRANT_NOTHING;
  obj   = get_rbutton (baccess, AFNONE);

  switch (obj)
  {
    case AFUPDATE : flags |= GRANT_UPDATE;
    case AFINSERT : flags |= GRANT_INSERT;
    case AFSELECT : flags |= GRANT_SELECT;
  } /* switch */

  return (flags);
} /* get_cflags */

/*****************************************************************************/

LOCAL WORD col_obj (flags)
UWORD flags;

{
  if (flags & GRANT_UPDATE) return (AFUPDATE);
  if (flags & GRANT_INSERT) return (AFINSERT);
  if (flags & GRANT_SELECT) return (AFSELECT);

  return (AFNONE);
} /* col_obj */

/*****************************************************************************/

LOCAL BOOLEAN xget_checkbox (tree, obj)
OBJECT *tree;
WORD   obj;

{
  return (get_checkbox (tree, obj) && ! is_state (tree, obj, DISABLED));
} /* xget_checkbox */

/*****************************************************************************/

LOCAL BOOLEAN user_exists (ac_spec, username)
AC_SPEC *ac_spec;
BYTE    *username;

{
  WORD     i;
  USERNAME user, tmp;
  SYSUSER  *sysuser;

  strcpy (user, username);
  str_ascii (user);
  str_upper (user);

  sysuser = ac_spec->sysuser;

  for (i = 0; i < ac_spec->num_users; i++, sysuser++)
  {
    strcpy (tmp, sysuser->name);
    str_ascii (tmp);
    str_upper (tmp);

    if (strcmp (user, tmp) == 0) return (TRUE);
  } /* for */

  return (FALSE);
} /* user_exists */

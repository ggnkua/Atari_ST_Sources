/*****************************************************************************
 *
 * Module : BFORMAT.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 30.10.93
 *
 *
 * Description: This module implements the base format dialog box.
 *
 * History:
 * 30.10.93: LBS_TOUCHEXIT removed in call to ListBoxSetStyle
 * 27.10.93: Errors in callback removed
 * 20.10.93: Callback routine improved
 * 14.10.93: New 3D listboxes used
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
#include "controls.h"
#include "dialog.h"
#include "bclick.h"

#include "export.h"
#include "bformat.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

typedef struct
{
  WINDOWP   base_window;
  WORD      table;
  WORD      field;
  WORD      type;
  WORD      number;
  BYTE      *name;
} FORMAT_SPEC;

typedef struct
{
  FORMATSTR format;             /* format string */
  WORD      index;              /* index number */
} F_INFO;                       /* format info for given format */

/****** VARIABLES ************************************************************/

LOCAL WORD        form_num;     /* format number on dialog exit */
LOCAL FORMAT_SPEC format_spec;  /* holds specific information */
LOCAL F_INFO      *f_info;      /* pointer to format info */

/****** FUNCTIONS ************************************************************/

LOCAL LONG    callback     _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    box          _((WINDOWP window, BOOLEAN grow, WINDOWP base_window, WORD class, WORD obj, WORD table));

LOCAL VOID    set_format   _((FORMAT_SPEC *format_spec));
LOCAL VOID    open_format  _((WINDOWP window));
LOCAL VOID    close_format _((WINDOWP window));
LOCAL VOID    click_format _((WINDOWP window, MKINFO *mk));

LOCAL VOID    set_objs     _((WINDOWP window));
LOCAL BOOLEAN check_format _((BASE_SPEC *base_spec, WORD amount));
LOCAL WORD    add_format   _((BASE_SPEC *base_spec, FORMAT_SPEC *format_spec));
LOCAL VOID    del_format   _((BASE_SPEC *base_spec, WORD number));
LOCAL VOID    upd_format   _((BASE_SPEC *base_spec, WORD index));
LOCAL WORD    set_lformats _((BASE_SPEC *base_spec, WORD type, WORD index));
LOCAL WORD    exist        _((BASE_SPEC *base_spec, BYTE *format, WORD type));
LOCAL WORD    used         _((BASE_SPEC *base_spec, WORD number));

/*****************************************************************************/

GLOBAL WORD mformat (base_window, table, field, number, name)
WINDOWP  base_window;
WORD     table;
WORD     field;
WORD     number;
BYTE     *name;

{
  WINDOWP window;
  WORD    ret;

  form_num = FAILURE;
  window   = search_window (CLASS_DIALOG, SRCH_ANY, FORMATS);

  if (window == NULL)
  {
    form_center (formats, &ret, &ret, &ret, &ret);
    window = crt_dialog (formats, NULL, FORMATS, FREETXT (FFORMAT), WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_format;
      window->close   = close_format;
      window->click   = click_format;
      window->special = (LONG)&format_spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (formats, ROOT, EDITABLE);
    window->edit_inx = NIL;

    format_spec.base_window = base_window;
    format_spec.table       = table;
    format_spec.field       = field;
    format_spec.number      = number;
    format_spec.name        = name;

    set_format (&format_spec);

    ListBoxSetSpec (formats, FLISTBOX, (LONG)window);

    if (! open_dialog (FORMATS)) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (form_num);
} /* mformat */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WORD        abs_col, number;
  WINDOWP     window;
  BYTE        *format;
  FORMAT_SPEC *format_spec;
  SYSCOLUMN   *syscolumn;
  BASE_SPEC   *base_spec;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);
                          
  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)&f_info [index].format);
    case LBN_DRAWITEM   : break;
    case LBN_SELCHANGE  : set_str (formats, FNEW, f_info [index].format);
                          draw_object (window, FNEW);
                          break;
    case LBN_DBLCLK     : format_spec = (FORMAT_SPEC *)window->special;
                          base_spec   = (BASE_SPEC *)format_spec->base_window->special;
                          format      = get_str (formats, FNEW);

                          if (*format != EOS)
                          {
                            number = exist (base_spec, format, format_spec->type);
                            if (number == FAILURE) number = add_format (base_spec, format_spec);

                            if (number == FAILURE)
                              hndl_alert (ERR_NOFORMATS);
                            else
                            {
                              if (format_spec->table != FAILURE)
                              {
                                abs_col   = abscol (base_spec, format_spec->table, format_spec->field);
                                syscolumn = &base_spec->syscolumn [abs_col];

                                syscolumn->format   = number;
                                syscolumn->flags   |= UPD_FLAG;
                              } /* else */

                              base_spec->modified = TRUE;
                              form_num            = number;
                            } /* else */
                          } /* if */
                          break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* callback */

/*****************************************************************************/

LOCAL VOID box (window, grow, base_window, class, obj, table)
WINDOWP window;
BOOLEAN grow;
WINDOWP base_window;
WORD    class;
WORD    obj;
WORD    table;

{
  RECT l, b;

  if (obj != FAILURE)
    b_get_rect (base_window, class, obj, table, &l, TRUE, FALSE);
  else
    xywh2rect (0, 0, 0, 0, &l);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/

LOCAL VOID set_format (format_spec)
FORMAT_SPEC *format_spec;

{
  WORD       table, field, act_format;
  WORD       abs_col, size, ftype;
  STRING     type;
  FIELDNAME  name;
  SYSCOLUMN  *syscolumn;
  BASE_SPEC  *base_spec;

  base_spec  = (BASE_SPEC *)format_spec->base_window->special;
  table      = format_spec->table;
  field      = format_spec->field;
  name [0]   = EOS;

  if (format_spec->name != NULL) strcpy (name, format_spec->name);

  if (table == FAILURE)
  {
    ftype      = field;
    act_format = format_spec->number;
  } /* if */
  else
  {
    abs_col    = abscol (base_spec, table, field);
    syscolumn  = &base_spec->syscolumn [abs_col];
    ftype      = syscolumn->type;
    act_format = syscolumn->format;
    strcpy (name, syscolumn->name);
  } /* else */

  format_spec->type = ftype;

  str_type (ftype, type);
  strcpy (get_str (formats, FNAME), name);
  strcpy (get_str (formats, FTYPE), type);
  set_str (formats, FNEW, "");

  size   = sizeof (F_INFO);
  f_info = (F_INFO *)mem_alloc ((LONG)base_spec->max_formats * size);

  ListBoxSetCallback (formats, FLISTBOX, callback);
  ListBoxSetStyle (formats, FLISTBOX, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE, TRUE);
  ListBoxSetLeftOffset (formats, FLISTBOX, gl_wbox / 2);
  ListBoxSetCount (formats, FLISTBOX, 0, NULL);
  ListBoxSetCurSel (formats, FLISTBOX, FAILURE);
  ListBoxSetTopIndex (formats, FLISTBOX, 0);

  if (f_info != NULL)
    set_lformats (base_spec, format_spec->type, act_format);

  set_objs (search_window (CLASS_DIALOG, SRCH_ANY, FORMATS));
} /* set_format */

/*****************************************************************************/

LOCAL VOID open_format (window)
WINDOWP window;

{
  FORMAT_SPEC *spec;

  spec = (FORMAT_SPEC *)window->special;

  box (window, TRUE, spec->base_window, SEL_FIELD, spec->field, spec->table);
} /* open_format */

/*****************************************************************************/

LOCAL VOID close_format (window)
WINDOWP window;

{
  FORMAT_SPEC *spec;

  mem_free (f_info);
  spec = (FORMAT_SPEC *)window->special;

  box (window, FALSE, spec->base_window, SEL_FIELD, spec->field, spec->table);
} /* close_format */

/*****************************************************************************/

LOCAL VOID click_format (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD        index;
  WORD        number;
  WORD        button, count;
  LONGSTR     s;
  F_INFO      *finfo;
  FORMAT_SPEC *format_spec;
  BASE_SPEC   *base_spec;

  format_spec = (FORMAT_SPEC *)window->special;
  base_spec   = (BASE_SPEC *)format_spec->base_window->special;
  index       = ListBoxGetCurSel (formats, FLISTBOX);

  switch (window->exit_obj)
  {
    case FLISTBOX : index = ListBoxClick (window->object, window->exit_obj, mk);
                    if ((mk->breturn == 2) && (index != FAILURE))
                      window->flags |= WI_DLCLOSE;
                    break;
    case FUPDATE  : finfo  = &f_info [index];
                    number = finfo->index;
                    count  = used (base_spec, number);
                    button = 1;			/* OK, delete */

                    if (count > 0)
                    {
                      sprintf (s, alerts [ERR_FORMATUSED], count);
                      button = open_alert (s);
                    } /* if */

                    if (button == 1) upd_format (base_spec, index);
                    break;
    case FDELETE  : finfo  = &f_info [index];
                    number = finfo->index;
                    count  = used (base_spec, number);
                    button = 1;			/* OK, delete */

                    if (count > 0)
                    {
                      sprintf (s, alerts [ERR_FORMATUSED], count);
                      button = open_alert (s);
                    } /* if */

                    if (button == 1)
                    {
                      del_format (base_spec, number);
                      set_lformats (base_spec, format_spec->type, FAILURE);
                      ListBoxRedraw (formats, FLISTBOX);

                      set_str (formats, FNEW, "");
                      draw_object (window, FNEW);
                    } /* if */

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case FOK      : ListBoxSendMessage (formats, FLISTBOX, LBN_DBLCLK, ListBoxGetCurSel (formats, FLISTBOX), NULL);
                    break;
    case FHELP    : hndl_help (HFORMAT);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  set_objs (window);
} /* click_format */

/*****************************************************************************/

LOCAL VOID set_objs (window)
WINDOWP window;

{
  WORD item;
  BYTE *p;

  item = ListBoxGetCurSel (formats, FLISTBOX);

  p = get_str (formats, FNEW);

  if (((item == FAILURE) || (*p == EOS)) == ! is_state (formats, FUPDATE, DISABLED))
  {
    flip_state (formats, FUPDATE, DISABLED);
    draw_object (window, FUPDATE);
  } /* if */

  if ((item <= 0) == ! is_state (formats, FDELETE, DISABLED))
  {
    flip_state (formats, FDELETE, DISABLED);
    draw_object (window, FDELETE);
  } /* if */
} /* set_objs */

/*****************************************************************************/

LOCAL BOOLEAN check_format (base_spec, amount)
BASE_SPEC *base_spec;
WORD      amount;

{
  return (base_spec->num_formats + amount <= base_spec->max_formats);
} /* check_format */

/*****************************************************************************/

LOCAL WORD add_format (base_spec, format_spec)
BASE_SPEC   *base_spec;
FORMAT_SPEC *format_spec;

{
  WORD      number;
  STRING    s;
  BYTE      *format;
  SYSFORMAT *sysformat;

  number = FAILURE;
  format = get_str (formats, FNEW);
  strcpy (s, format);
  str_upper (s);
  if (strcmp (s, FREETXT (FNULL)) == 0) strcpy (format, "");

  if (check_format (base_spec, 1))
  {
    sysformat = &base_spec->sysformat [base_spec->num_formats];
    number    = base_spec->num_formats++;

    strcpy (sysformat->format, format);
    sysformat->address = 0;
    sysformat->number  = number;
    sysformat->type    = format_spec->type;
    sysformat->flags   = INS_FLAG;

    base_spec->modified = TRUE;
  } /* if */

  return (number);
} /* add_format */

/*****************************************************************************/

LOCAL VOID del_format (base_spec, number)
BASE_SPEC *base_spec;
WORD      number;

{
  WORD      format, column;
  SYSCOLUMN *syscolumn;
  SYSFORMAT *sysformat;

  sysformat = &base_spec->sysformat [number];

  if (sysformat->flags & MOD_FLAG)      /* put into delete list */
  {
    if (base_spec->delptr == MAX_DEL)
    {
      hndl_alert (ERR_DELFORMAT);
      return;
    } /* if */

    base_spec->delobjs [base_spec->delptr].table   = SYS_FORMAT;
    base_spec->delobjs [base_spec->delptr].address = sysformat->address;
    base_spec->delptr++;
  } /* if */

  ListBoxSetCurSel (formats, FLISTBOX, FAILURE);
  syscolumn = base_spec->syscolumn;

  for (column = 0; column < base_spec->num_columns; column++, syscolumn++)
  {
    if (syscolumn->format == number) syscolumn->format = syscolumn->type;  /* set to standard format */
    if (syscolumn->format >  number) syscolumn->format--;
    syscolumn->flags |= UPD_FLAG;
  } /* for */

  base_spec->num_formats--;
  mem_lmove (sysformat, sysformat + 1, (LONG)sizeof (SYSFORMAT) * (base_spec->num_formats - number));

  sysformat = base_spec->sysformat;
  for (format = 0; format < base_spec->num_formats; format++, sysformat++)
  {
    sysformat->number  = format;
    sysformat->flags  |= UPD_FLAG;
  } /* for */

  sysformat->number = FAILURE;

  base_spec->modified = TRUE;
} /* del_format */

/*****************************************************************************/

LOCAL VOID upd_format (base_spec, index)
BASE_SPEC *base_spec;
WORD      index;

{
  STRING    s;
  BYTE      *p;
  F_INFO    *finfo;
  SYSFORMAT *sysformat;

  p         = get_str (formats, FNEW);
  finfo     = &f_info [index];
  sysformat = &base_spec->sysformat [finfo->index];

  strcpy (s, p);
  str_upper (s);
  if (strcmp (s, FREETXT (FNULL)) == 0) strcpy (p, "");
  strcpy (sysformat->format, p);

  sysformat->flags    |= UPD_FLAG;
  base_spec->modified  = TRUE;
} /* upd_format */

/*****************************************************************************/

LOCAL WORD set_lformats (base_spec, type, index)
BASE_SPEC *base_spec;
WORD      type;
WORD      index;

{
  WORD      i, number, num_items;
  STRING    format;
  SYSFORMAT *sysformat;
  F_INFO    *finfo;

  num_items  = 0;
  number     = 0;
  sysformat  = base_spec->sysformat;
  finfo      = f_info;

  for (i = 0; i < base_spec->num_formats; i++, sysformat++)
    if ((sysformat->type == type) && (sysformat->number != FAILURE))
    {
      num_items++;
      strcpy (format, sysformat->format);
      if (*format == EOS) strcpy (format, FREETXT (FNULL));

      if (i == index)
      {
        number = num_items - 1;
        set_str (formats, FNEW, format);
      } /* if */

      sprintf (finfo->format, "%s", format);
      finfo->index = i;
      finfo++;
    } /* if, for */

  ListBoxSetCount (formats, FLISTBOX, num_items, NULL);
  ListBoxSetCurSel (formats, FLISTBOX, number);
  ListBoxSetTopIndex (formats, FLISTBOX, number);

  return (number);
} /* set_lformats */

/*****************************************************************************/

LOCAL WORD exist (base_spec, format, type)
BASE_SPEC *base_spec;
BYTE      *format;
WORD      type;

{
  WORD      i;
  STRING    s, t;
  SYSFORMAT *sysformat;

  sysformat = base_spec->sysformat;
  strcpy (s, format);
  strcpy (t, format);
  str_upper (t);
  if (strcmp (t, FREETXT (FNULL)) == 0) *s = EOS;

  for (i = 0; i < base_spec->num_formats; i++, sysformat++)
    if (sysformat->type == type)
      if (strcmp (sysformat->format, s) == 0) return (i);

  return (FAILURE);
} /* exist */

/*****************************************************************************/

LOCAL WORD used (base_spec, number)
BASE_SPEC *base_spec;
WORD      number;

{
  WORD      i, count;
  SYSCOLUMN *syscolumn;

  count     = 0;
  syscolumn = base_spec->syscolumn;

  for (i = 0; i < base_spec->num_columns; i++, syscolumn++)
    if (syscolumn->format == number) count++;

  return (count);
} /* used */


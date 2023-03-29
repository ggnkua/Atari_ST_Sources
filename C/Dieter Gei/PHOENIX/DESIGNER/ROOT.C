/*****************************************************************************
 *
 * Module : ROOT.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 17.07.90
 * Last modification: 25.12.02
 *
 *
 * Description: This module implements the dependant functions for all modules.
 *
 * History:
 * 25.12.02: Die Varibale bShowDebugInfo wird nicht mehr in appl_help ermittelt sondern
 *					 global.
 * 04.11.02: temp_name gibt ab sofort den komplette Pfad zurÅck
 * 23.06.02: Hilfeseite an ST Guide wird im globalen Speicher Åbergeben
 * 27.03.97: Debug output for ST Guide added
 * 12.03.97: Functions vm_pagesize & vm_coords removed
 * 11.03.97: ST Guide used as help database
 * 16.06.96: str_upper deleted in open_db
 * 04.01.95: Using new function names of controls module
 * 21.02.94: Initialization of use_std_fs removed
 * 20.11.93: Initialization of use_std_fs added
 * 19.11.93: Functions get_open_filename, get_save_filename added
 * 11.11.93: commdlg.h included
 * 04.11.93: Functions load_fonts and unload_fonts removed
 * 28.10.93: nitialization cal_icon added
 * 24.10.93: Initialization of tbl_icon etc. added in init_root
 * 13.10.93: db_open_cache in open_db used
 * 11.10.93: Initialization of variables color_desktop and pattern_desktop moved to global.c
 * 27.09.93: Initialization of variables color_desktop, pattern_desktop and use_3d added
 * 06.09.93: show_message modified
 * 20.08.93: get_str and set_str deleted
 * 17.07.90: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"
#include "commdlg.h"
#include "controls.h"
#include "dialog.h"
#include "help.h"
#include "resource.h"

#include "gemobj.h"     /* only used by mask and mclick modules */
#include "imageobj.h"

#include "export.h"
#include "root.h"

/****** DEFINES **************************************************************/

#define FONT_SWAPSIZE 3072              /* 3072 * 16 = 48 KByte font swapping */

#define VM_PAGESIZE 0
#define VM_COORDS   1

#define MAX_RDIGITS 16                  /* max length of floats */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

#include "tooltbl.h"
#include "tooltblm.h"
#include "toolcol.h"
#include "toolcolm.h"
#include "toolinx.h"
#include "toolinxm.h"
#include "toolmul.h"
#include "toolmulm.h"
#include "toolcal.h"
#include "toolcalm.h"
#include "maskicn.h"
#include "maskicnm.h"
#include "user.h"
#include "userm.h"

LOCAL FILENAME tmpname;         /* temporary file name */
LOCAL WORD     tmpnum = 0;      /* temporary number */
LOCAL BOOLEAN  fonts_loaded;    /* fonts already loaded? */

LOCAL WORD     stdwidth [NUM_TYPES]   = {0, 6, 11, 2 * MAX_RDIGITS + 2, 0, 8, 12, 20, 11, 11, 11, 11, 0, 11, -1, -1, -1, -1, -1, -1};
LOCAL WORD     diff_table [NUM_TYPES] = {1, 0, 0, 0, 1, 0, 0, 0, sizeof (LONG), sizeof (LONG), sizeof (LONG), sizeof (LONG), 1, 0, 0, 0, 0, 0, 0, 0};


/****** FUNCTIONS ************************************************************/

LOCAL  BOOLEAN appl_help  _((BYTE *helpmsg));
EXTERN VOID    vdi        _((VOID));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_root ()

{
  WORD     sys_point;
  WORD     wchar, hchar, wbox, hbox;
  FILENAME name;
  BYTE     *p;

  set_helpfunc (appl_help);

  for (sys_point = 8; sys_point <= 10; sys_point++)
  {
    vst_point (vdi_handle, sys_point, &wchar, &hchar, &wbox, &hbox);
    if (hbox == gl_hbox) break; /* point size of system font */
  } /* for */

  num_fonts       = 1;		/* system font always available */
  fonts_loaded    = FALSE;
  g_font          = FONT_SYSTEM;
  g_point         = sys_point;
  autosave        = TRUE;
  hidefunc        = FALSE;
  std_width       = stdwidth;
  desktop->ob_spec = (desktop->ob_spec & 0xFFFFFF80L) | color_desktop | (pattern_desktop << 4);

  sel.class = SEL_NONE;
  sel.table = FAILURE;
  sel.field = FAILURE;
  sel.key   = FAILURE;

  strcpy (name, FREETXT (FNOTITLE));
  strcat (name, FREETXT (FDATSUFF) + 1);

  strcpy (db_path, app_path);
  strcpy (db_name, name);

  strcpy (icn_path, app_path);
  strcpy (icn_name, "");

  strcpy (pic_path, app_path);
  strcpy (pic_name, "");

  strcpy (exp_path, app_path);
  strcpy (exp_name, "");

  strcpy (tmpdir, app_path);

  p = FREETXT (FSEP);
  init_conv (NULL, NULL, p [0], p [1]);

  if ((colors >= 16) && (gl_hbox > 8))
  {
    BuildIcon (&tbl_icon, tooltblm, tooltbl);
    BuildIcon (&col_icon, toolcolm, toolcol);
    BuildIcon (&inx_icon, toolinxm, toolinx);
    BuildIcon (&mul_icon, toolmulm, toolmul);
    BuildIcon (&cal_icon, toolcalm, toolcal);
    BuildIcon (&msk_icon, maskicnm, maskicn);
    BuildIcon (&usr_icon, userm, user);
  } /* if */

  return (TRUE);
} /* init_root */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_root ()

{
  UnloadFonts (vdi_handle);

  return (TRUE);
} /* term_root */

/*****************************************************************************/

GLOBAL WORD file_error (errornum, filename)
WORD errornum;
BYTE *filename;

{
  LONGSTR s;

  sprintf (s, alerts [errornum], filename);

  return (open_alert (s));
} /* file_error */

/*****************************************************************************/

GLOBAL WORD dberror (errornum, basename)
WORD errornum;
BYTE *basename;

{
  STRING  name;
  LONGSTR s;

  sprintf (name, FREETXT (FDATABAS), basename);
  sprintf (s, alerts [errornum], name);
  return (open_alert (s));
} /* dberror */

/*****************************************************************************/

GLOBAL WORD dbtest (base)
BASE *base;

{
  WORD ret, result;

  ret    = 0;
  result = db_status (base);

  if (result != SUCCESS) ret = dberror (result, base->basename);

  return (ret);
} /* dbtest */

/*****************************************************************************/

GLOBAL BASE *open_db (filename, flags, datacache, treecache, num_cursors, username, password, result)
FULLNAME filename;
UWORD    flags;
LONG     datacache;
LONG     treecache;
WORD     num_cursors;
BYTE     *username;
BYTE     *password;
WORD     *result;

{
  BOOLEAN  ok;
  WORD     res;
  RECT     r;
  MFDB     screen, buf;
  LONGSTR  s;
  FILENAME basename;
  FULLNAME basepath;
  EXT      ext;
  BASE     *base;

  res = SUCCESS;

  file_split (filename, NULL, basepath, basename, ext);
  sprintf (s, "%s%s%s", basepath, basename, FREETXT (FDATSUFF) + 1);

  if (! file_exist (s))
  {
    *result = DB_DNOOPEN;
    return (NULL);
  } /* if */

  sprintf (s, FREETXT (FOPEN), filename);
  init_message (MFILE, &r, &screen, &buf, s);

  busy_mouse ();
  base = db_open_cache (basename, basepath, flags | BASE_SUPER, datacache, treecache, num_cursors, username, password);
  ok   = (base != NULL);
  res  = db_status (base);

  if (! ok)
    if (res == DB_NOMEMORY) res = ERR_NOMEMRETRY;

  arrow_mouse ();
  exit_message (&r, &screen, &buf);
  *result = res;

  return (base);
} /* open_db */

/*****************************************************************************/

GLOBAL VOID close_db (base_spec)
BASE_SPEC *base_spec;

{
  if (base_spec->base != NULL) db_close (base_spec->base);
  base_spec->base = NULL;
} /* close_db */

/*****************************************************************************/

GLOBAL BOOLEAN make_maskfile (base_spec)
BASE_SPEC *base_spec;

{
  WORD     i;
  FULLNAME filename;
  BOOLEAN  ok;
  HLPMASK  *mask;

  strcpy (base_spec->fmask_name, "");

  strcpy (filename, temp_name (NULL));

  base_spec->fmask = file_create (filename);

  ok   = base_spec->fmask >= 0;
  mask = base_spec->sysmask;

  if (ok)
  {
    for (i = 0; i < base_spec->max_masks; i++, mask++) mask->findex = FAILURE;
    strcpy (base_spec->fmask_name, filename);
  } /* if */

  return (ok);
} /* make_maskfile */

/*****************************************************************************/

GLOBAL VOID del_maskfile (base_spec)
BASE_SPEC *base_spec;

{
  if (base_spec->fmask >= 0)
  {
    file_close (base_spec->fmask);
    file_remove (base_spec->fmask_name);
  } /* if */
} /* del_maskfile */

/*****************************************************************************/

GLOBAL BOOLEAN hndl_help (helpindex)
WORD helpindex;

{
  return (appl_help (get_str (helpinx, helpindex)));
} /* hndl_help */

/*****************************************************************************/

GLOBAL BOOLEAN appl_help (helpmsg)
BYTE *helpmsg;

{
  WORD     msg [8];
  LONGSTR  sz;

  sprintf (global_mem1, "%s%s%s %s", app_path, FREETXT (FHELPBAS), ".hyp", helpmsg);

  if (bShowDebugInfo)
  {
    sprintf (sz, "[0][Hilfe-Debug-Ausgabe||Pfad: %s|Datei: %s.hyp|Index: %s][~OK][0|1|1|0][]", app_path, FREETXT (FHELPBAS), helpmsg);
    open_alert (sz);
  } /* if */

  if (st_guide_apid >= 0)
  {
    msg [0] = VA_START;
    msg [1] = gl_apid;
    msg [2] = 0;
    msg [3] = (UWORD)((LONG)global_mem1 >> 16);
    msg [4] = (UWORD)((LONG)global_mem1 & 0xFFFFL);
    msg [5] = 0;
    msg [6] = 0;
    msg [7] = 0;

    appl_write (st_guide_apid, sizeof (msg), msg);

    return (TRUE);
  } /* if */
  else
    return (open_help (FREETXT (FHELPBAS), app_path, helpmsg));
} /* appl_help */

/*****************************************************************************/

GLOBAL WORD v_tableinfo (base_spec, table, table_info)
BASE_SPEC  *base_spec;
WORD       table;
TABLE_INFO *table_info;

{
  SYSTABLE  *tablep;
  BOOLEAN   found;
  TABLENAME tablename;
  TABLENAME sysname;

  if (! base_spec->in_memory)
    table = db_tableinfo (base_spec->base, table, table_info);
  else
  {
    if (table == FAILURE)                       /* search for name */
    {
      found  = FALSE;
      table  = SYS_TABLE;
      tablep = base_spec->systable;
      strcpy (tablename, table_info->name);
      str_upper (tablename);
      str_rmchar (tablename, ' ');

      while (! found && (table < base_spec->num_tables))
      {
        strcpy (sysname, tablep->name);
        str_upper (sysname);
        str_rmchar (sysname, ' ');
        found = strcmp (sysname, tablename) == 0;

        if (! found)
        {
          table++;
          tablep++;
        } /* if */
      } /* while */

      if (! found) table = FAILURE;
    } /* if */

    if (table != FAILURE)
    {
      tablep = &base_spec->systable [table];

      strcpy (table_info->name, tablep->name);
      table_info->recs     = tablep->recs;
      table_info->cols     = tablep->cols;
      table_info->indexes  = tablep->indexes;
      table_info->size     = tablep->size;
      table_info->color    = tablep->color;
      table_info->icon     = tablep->icon;
      table_info->children = tablep->children;
      table_info->parents  = tablep->parents;
      table_info->flags    = tablep->flags;
    } /* if */
  } /* else */

  return (table);
} /* v_tableinfo */

/*****************************************************************************/

GLOBAL WORD v_fieldinfo (base_spec, table, field, field_info)
BASE_SPEC   *base_spec;
WORD        table;
WORD        field;
FIELD_INFO *field_info;

{
  BOOLEAN   found;
  WORD      abs_col;
  SYSTABLE  *tablep;
  SYSCOLUMN *colp;
  FIELDNAME fieldname;
  FIELDNAME sysname;

  if (! base_spec->in_memory)
    field = db_fieldinfo (base_spec->base, table, field, field_info);
  else
  {
    tablep = &base_spec->systable [table];

    if (field == FAILURE)                       /* get field name */
    {
      found   = FALSE;
      field   = 0;
      abs_col = abscol (base_spec, table, field);
      colp    = &base_spec->syscolumn [abs_col];
      strcpy (fieldname, field_info->name);
      str_upper (fieldname);
      str_rmchar (fieldname, ' ');

      while (! found && (field < tablep->cols))
      {
        strcpy (sysname, colp->name);
        str_upper (sysname);
        str_rmchar (sysname, ' ');
        found = strcmp (sysname, fieldname) == 0;

        if (! found)
        {
          field++;
          colp++;
        } /* if */
      } /* while */

      if (! found) field = FAILURE;
    } /* if */

    if (field != FAILURE)
    {
      abs_col = abscol (base_spec, table, field);
      colp    = &base_spec->syscolumn [abs_col];

      strcpy (field_info->name, colp->name);
      field_info->type   = colp->type;
      field_info->addr   = colp->addr;
      field_info->size   = colp->size;
      field_info->format = colp->format;
      field_info->flags  = colp->flags;
    } /* if */
  } /* else */

  return (field);
} /* v_field_info */

/*****************************************************************************/

GLOBAL WORD v_indexinfo (base_spec, table, inx, index_info)
BASE_SPEC  *base_spec;
WORD       table;
WORD       inx;
INDEX_INFO *index_info;

{
  BOOLEAN   found;
  WORD      abs_inx;
  WORD      num_cols, i;
  SYSTABLE  *tablep;
  SYSCOLUMN *colp;
  SYSINDEX  *inxp;
  FIELDNAME indexname;
  FIELDNAME sysname;
  INXCOL    *inxcolp;
  BYTE      *p;

  if (! base_spec->in_memory)
    return (db_indexinfo (base_spec->base, table, inx, index_info));
  else
  {
    tablep = &base_spec->systable [table];

    if (inx == FAILURE)                         /* get index name */
    {
      found   = FALSE;
      inx     = 0;
      abs_inx = absinx (base_spec, table, inx);
      inxp    = &base_spec->sysindex [abs_inx];
      strcpy (indexname, index_info->name);
      str_upper (indexname);
      str_rmchar (indexname, ' ');

      while (! found && (inx < tablep->indexes))
      {
        strcpy (sysname, inxp->name);
        str_upper (sysname);
        str_rmchar (sysname, ' ');
        found = strcmp (sysname, indexname) == 0;

        if (! found)
        {
          inx++;
          inxp++;
        } /* if */
      } /* while */

      if (! found) inx = FAILURE;
    } /* if */

    if (inx != FAILURE)
    {
      abs_inx = absinx (base_spec, table, inx);
      inxp    = &base_spec->sysindex [abs_inx];

      strcpy (index_info->name, inxp->name);
      index_info->indexname [0] = EOS;
      index_info->type          = inxp->type;
      index_info->root          = inxp->root;
      index_info->num_keys      = inxp->num_keys;
      index_info->flags         = inxp->flags;
      mem_move (&index_info->inxcols, &inxp->inxcols, sizeof (INXCOLS));

      num_cols = inxp->inxcols.size / sizeof (INXCOL);
      inxcolp  = inxp->inxcols.cols;
      p        = index_info->indexname;

      for (i = 0; i < num_cols; i++, inxcolp++)
      {
        colp = &base_spec->syscolumn [abscol (base_spec, table, inxcolp->col)];

        if (strlen (p) + strlen (colp->name) <= MAX_INDEXNAME)
        {
          strcat (p, colp->name);
          strcat (p, ",");
        } /* if */
      } /* for */

      p [strlen (p) - 1] = EOS;         /* delete trailing ',' */
    } /* if */
  } /* else */

  return (inx);
} /* v_indexinfo */

/*****************************************************************************/

GLOBAL VOID fill_sysptr (base_spec)
BASE_SPEC *base_spec;

{
  SYSTABLE *systable;
  SYSPTR   *sysptr;
  WORD     tables;
  WORD     i, col, inx;

  systable = base_spec->systable;
  sysptr   = base_spec->sysptr;
  tables   = base_spec->num_tables;

  for (i = col = inx = 0; i < tables; i++, systable++, sysptr++)
  {
    sysptr->column = col;
    sysptr->index  = inx;

    col += systable->cols;
    inx += systable->indexes;
  } /* for */
} /* fill_sysptr */

/*****************************************************************************/

GLOBAL WORD get_ktype (base_spec, table, inxp)
BASE_SPEC *base_spec;
WORD      table;
SYSINDEX  *inxp;

{
  WORD      multi;
  WORD      type1, type2;
  WORD      col;
  SYSCOLUMN *colp;

  multi = inxp->inxcols.size / sizeof (INXCOL);

  col   = inxp->inxcols.cols [0].col;
  colp  = &base_spec->syscolumn [abscol (base_spec, table, col)];
  type1 = colp->type;

  if (multi == 1) return (type1);

  if (multi == 2)
  {
    col   = inxp->inxcols.cols [1].col;
    colp  = &base_spec->syscolumn [abscol (base_spec, table, col)];
    type2 = colp->type;

    if ((type1 == TYPE_WORD) && (type2 == TYPE_WORD)) return (TYPE_LONG);
  } /* if */


  return (TYPE_CHAR);
} /* get_ktype */

/*****************************************************************************/

GLOBAL VOID get_tblwh (base_spec, table, width, height)
BASE_SPEC *base_spec;
WORD      table;
WORD      *width;
WORD      *height;

{
  WORD       field, len;
  WORD       index, multi_index;
  WORD       w, h;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  INDEX_INFO index_info;

  v_tableinfo (base_spec, table, &table_info);
  multi_index = 0;

  len = 2 + LEN_TYPE + (base_spec->show_short ? 0 : LEN_SIZE);  /* ' ' + "*" */
  w   = strlen (table_info.name) + 1;                           /* at least 1 blank */

  for (field = 1; field < table_info.cols; field++)             /* don't use field address */
    if (v_fieldinfo (base_spec, table, field, &field_info) != FAILURE)
      w = max (w, strlen (field_info.name) + len);

  for (index = 0; index < table_info.indexes; index++)
    if (v_indexinfo (base_spec, table, index, &index_info) != FAILURE)
      if (index_info.inxcols.size / sizeof (INXCOL) > 1)        /* multi key */
      {
        multi_index++;
        w = max (w, strlen (index_info.name + 2));              /* ' ' +  "*" */
      } /* if */

  h = table_info.cols - 1 + multi_index + 1;                    /* 1 line for the table name */
  if (h == 0) h = 1;                                            /* at least the table name */

  *width  = w;
  *height = h;
} /* get_tblwh */

/*****************************************************************************/

GLOBAL VOID size2str (field_info, s)
FIELD_INFO *field_info;
BYTE       *s;

{
  WORD diff;

  diff = diff_table [field_info->type];

  if (diff == 0)
    strcpy (s, "-"/*FREETXT (FFIX)*/);
  else
    sprintf (s, "%ld", field_info->size - diff);
} /* size2str */

/*****************************************************************************/

GLOBAL WORD abscol (base_spec, table, col)
BASE_SPEC *base_spec;
WORD      table, col;

{
  return (base_spec->sysptr [table].column + col);
} /* abscol */

/*****************************************************************************/

GLOBAL WORD absinx (base_spec, table, inx)
BASE_SPEC *base_spec;
WORD      table, inx;

{
  return (base_spec->sysptr [table].index + inx);
} /* absinx */

/*****************************************************************************/

GLOBAL WORD find_index (base_spec, table, col)
BASE_SPEC *base_spec;
WORD      table;
WORD      col;

{
  WORD       index;
  TABLE_INFO table_info;
  INDEX_INFO index_info;

  v_tableinfo (base_spec, table, &table_info);

  for (index = 0; index < table_info.indexes; index++)
    if (v_indexinfo (base_spec, table, index, &index_info) != FAILURE)
      if ((index_info.inxcols.size / sizeof (INXCOL) == 1) &&   /* single key field */
          (index_info.inxcols.cols [0].col == col)) return (index);

  return (FAILURE);
} /* find_index */

/*****************************************************************************/

GLOBAL WORD find_multikey (base_spec, table, inx)
BASE_SPEC *base_spec;
WORD      table;
WORD      inx;

{
  WORD     abs_inx;
  WORD     key, j, multi;
  WORD     indexes;
  SYSINDEX *inxp;

  abs_inx = absinx (base_spec, table, 0);
  inxp    = &base_spec->sysindex [abs_inx];
  indexes = base_spec->systable [table].indexes;
  key     = -1;

  for (j = 0; j < indexes; j++, inxp++)
  {
    multi = inxp->inxcols.size / sizeof (INXCOL);
    if (multi > 1) key++;
    if (key == inx) return (j);
  } /* for */

  return (FAILURE);
} /* find_multikey */

/*****************************************************************************/

GLOBAL inx2obj (base_spec, table, inx, obj)
BASE_SPEC *base_spec;
WORD      table;
WORD      inx;
WORD      *obj;

{
  WORD     abs_inx;
  WORD     multi, key, j;
  SYSINDEX *inxp;

  abs_inx = absinx (base_spec, table, inx);
  inxp    = &base_spec->sysindex [abs_inx];
  multi   = inxp->inxcols.size / sizeof (INXCOL);

  if (multi == 1)
  {
    *obj = inxp->inxcols.cols [0].col;
    return (SEL_FIELD);
  } /* if */
  else
  {
    abs_inx = absinx (base_spec, table, 0);
    inxp    = &base_spec->sysindex [abs_inx];
    j       = -1;

    for (key = 0; key <= inx; key++, inxp++)
    {
      multi = inxp->inxcols.size / sizeof (INXCOL);
      if (multi > 1) j++;
    } /* for */

    *obj = j;
    return (SEL_KEY);
  } /* else */
} /* inx2obj */

/*****************************************************************************/

GLOBAL WORD find_primary (base_spec, table)
BASE_SPEC *base_spec;
WORD      table;

{
  WORD     abs_inx;
  WORD     key;
  WORD     indexes;
  SYSINDEX *inxp;

  abs_inx = absinx (base_spec, table, 0);
  inxp    = &base_spec->sysindex [abs_inx];
  indexes = base_spec->systable [table].indexes;

  for (key = 0; key < indexes; key++, inxp++)
    if (inxp->flags & INX_PRIMARY) return (key);

  return (FAILURE);
} /* find_primary */

/*****************************************************************************/

GLOBAL VOID set_idata (tree, object, mask, data, width, height)
OBJECT *tree;
WORD   object;
WORD   *mask;
WORD   *data;
WORD   width;
WORD   height;

{
  ICONBLK *piconblk;
  WORD    size;

  piconblk = (ICONBLK *)tree [object].ob_spec;
  size     = (width + 15) / 16 * height * 2;

  mem_move (piconblk->ib_pmask, mask, size);
  mem_move (piconblk->ib_pdata, data, size);

  piconblk->ib_xicon = (piconblk->ib_wtext - width) / 2;
  piconblk->ib_yicon = piconblk->ib_ytext - height;
  piconblk->ib_wicon = (width + 15) & 0xFFF0;
  piconblk->ib_hicon = height;
} /* set_idata */

/*****************************************************************************/

GLOBAL WORD get_word (tree, object)
OBJECT *tree;
WORD   object;

{
  WORD   i;
  BYTE   *p;

  p = get_str (tree, object);
  str2bin (TYPE_WORD, p, &i);

  return (i);
} /* get_word */

/*****************************************************************************/

GLOBAL LONG get_long (tree, object)
OBJECT *tree;
WORD   object;

{
  LONG   l;
  BYTE   *p;

  p = get_str (tree, object);
  str2bin (TYPE_LONG, p, &l);

  return (l);
} /* get_long */

/*****************************************************************************/

GLOBAL VOID set_word (tree, object, value)
OBJECT *tree;
WORD   object;
WORD   value;

{
  STRING s;

  bin2str (TYPE_WORD, &value, s);
  set_str (tree, object, s);
} /* set_word */

/*****************************************************************************/

GLOBAL VOID set_long (tree, object, value)
OBJECT *tree;
WORD   object;
LONG   value;

{
  STRING s;

  bin2str (TYPE_LONG, &value, s);
  set_str (tree, object, s);
} /* set_long */

/*****************************************************************************/

GLOBAL VOID init_message (menuobj, r, screen, buffer, title)
WORD menuobj;
RECT *r;
MFDB *screen, *buffer;
BYTE *title;

{
  RECT d;
  WORD w;
  BYTE *name;

  if (menuobj != NIL)
    objc_rect (menu, menuobj, r, TRUE);
  else
    xywh2rect (0, 0, 0, 0, r);

  w    = empty [EACTION].ob_width / gl_wbox;
  name = get_str (empty, EACTION);
  strncpy (name, title, w);
  name [w] = EOS;
  set_str (empty, ENAME, "");

  opendial (empty, FALSE, r, screen, buffer);
  form_center (empty, &d.x, &d.y, &d.w, &d.h);
  empty->ob_x = max (0, empty->ob_x & 0x7FF8);
  objc_draw (empty, ROOT, MAX_DEPTH, d.x, d.y, d.w, d.h);
} /* init_message */

/*****************************************************************************/

GLOBAL VOID exit_message (r, screen, buffer)
RECT *r;
MFDB *screen, *buffer;

{
  closedial (empty, FALSE, r, screen, buffer);
} /* exit_message */

/*****************************************************************************/

GLOBAL VOID show_message (num, rwindex, index)
WORD num;
WORD rwindex;
WORD index;

{
  RECT    r;
  WORD    w;
  LONGSTR s;

  if (num > 0)
  {
    hide_mouse ();

    if (rwindex != FAILURE)
      sprintf (s, FREETXT (rwindex), FREETXT (index));
    else
      sprintf (s, FREETXT (index));

    objc_rect (empty, ENAME, &r, FALSE);
    w     = empty [ENAME].ob_width / gl_wbox;
    s [w] = EOS;
    set_str (empty, ENAME, s);
    objc_draw (empty, ENAME, MAX_DEPTH, r.x, r.y, r.w, r.h);

    show_mouse ();
  } /* if */
} /* show_message */

/*****************************************************************************/

GLOBAL BYTE *temp_name (s)
BYTE *s;

{
  BYTE *p;
  FILENAME filename;

  p      = (s == NULL) ? tmpname : s;

/* GS 5.1 Start: */
  do
  {
	  tmpnum = (tmpnum + 1) % 1000;

	  sprintf (filename, "APP%d%03d.TMP", gl_apid, tmpnum);

    strcpy (p, tmpdir);
    strcat (p, filename);
  } while (file_exist (p));

/* Ende alt: 
  tmpnum = (tmpnum + 1) % 1000;

  sprintf (p, "APPL%d%03d.TMP", gl_apid, tmpnum);
*/

  return (p);
} /* temp_name */

/*****************************************************************************/

GLOBAL BOOLEAN sel_file (name, path, suffix, label, filename)
BYTE *name, *path;
WORD suffix, label;
BYTE *filename;

{
  fs_button = 0; /* in case there's no more memory for fsel_input */

  do
  {
    select_file (name, path, FREETXT (suffix), FREETXT (label), filename);
  } while ((fs_button != 0) && (*fs_sel == EOS));

 return (fs_button != 0);
} /* sel_file */

/*****************************************************************************/

GLOBAL BOOLEAN get_open_filename (WORD wTitle, BYTE *pszHelpID, ULONG ulFlags, WORD wFilter, LONG *plFilterIndex, BYTE *pszInitialDir, WORD wDefExt, BYTE *pszFullName, BYTE *pszFileName)
{
  BOOLEAN  ok;
  FILENAME filename;
  FULLNAME path;

  if (pszHelpID == NULL)
    pszHelpID = get_str (helpinx, HSELFILE);

  if (use_std_fs)
  {
    file_split (pszFullName, NULL, path, filename, NULL);

    if (pszInitialDir != NULL)
      strcpy (path, pszInitialDir);

    ok = sel_file (filename, path, (wDefExt == FAILURE) ? FALLSUFF : wDefExt, wTitle, pszFullName);
  } /* if */
  else
    ok = GetOpenFileNameDialog (FREETXT (wTitle), pszHelpID, ulFlags, FREETXT (wFilter), plFilterIndex, pszInitialDir, (wDefExt == FAILURE) ? NULL : FREETXT (wDefExt) + 2, pszFullName, pszFileName);

  if (ok)
  {
    file_split (pszFullName, NULL, path, pszFileName, NULL);

    if (pszInitialDir != NULL)
      strcpy (pszInitialDir, path);
  } /* if */

  return (ok);
} /* get_open_filename */

/*****************************************************************************/

GLOBAL BOOLEAN get_save_filename (WORD wTitle, BYTE *pszHelpID, ULONG ulFlags, WORD wFilter, LONG *plFilterIndex, BYTE *pszInitialDir, WORD wDefExt, BYTE *pszFullName, BYTE *pszFileName)
{
  BOOLEAN  ok;
  FILENAME filename;
  FULLNAME path;

  if (pszHelpID == NULL)
    pszHelpID = get_str (helpinx, HSELFILE);

  if (use_std_fs)
  {
    file_split (pszFullName, NULL, path, filename, NULL);

    if (pszInitialDir != NULL)
      strcpy (path, pszInitialDir);

    ok = sel_file (filename, path, (wDefExt == FAILURE) ? FALLSUFF : wDefExt, wTitle, pszFullName);
  } /* if */
  else
    ok = GetSaveFileNameDialog (FREETXT (wTitle), pszHelpID, ulFlags, FREETXT (wFilter), plFilterIndex, pszInitialDir, (wDefExt == FAILURE) ? NULL : FREETXT (wDefExt) + 2, pszFullName, pszFileName);

  if (ok)
  {
    file_split (pszFullName, NULL, path, pszFileName, NULL);

    if (pszInitialDir != NULL)
      strcpy (pszInitialDir, path);
  } /* if */

  return (ok);
} /* get_save_filename */

/*****************************************************************************/

GLOBAL VOID make_id (name)
REG BYTE *name;

{
  REG UBYTE *src, *dst;
  REG UBYTE c;

  str_rmchar (name, ' ');

  src = dst = (UBYTE *)name;
  c   = ch_ascii (*src);
  c   = ch_upper (c);

  if (! (('A' <= c) && (c <= 'Z')))     /* must start with any letter */
  {
    *src = EOS;
    return;
  } /* if */

  while (*src)
  {
    c = ch_ascii (*src);
    c = ch_upper (c);

    if (('A' <= c) && (c <= 'Z') ||
        ('0' <= c) && (c <= '9') ||
        (c == '_'))
      *dst++ = *src++;
    else
      src++;
  } /* while */

  *dst = EOS;
} /* make_id */

/*****************************************************************************/

GLOBAL VOID device_info (vdi_handle, devinfo)
WORD    vdi_handle;
DEVINFO *devinfo;

{
  WORD work_out [57];
  WORD point;
  WORD char_w, char_h, cell_w, cell_h;
  WORD minimum, maximum, width;
  WORD distances [5], effects [3];
  LONG pix_w, pix_h;

  vq_extnd (vdi_handle, FALSE, work_out);

  devinfo->dev_w = work_out [0] + 1L;
  devinfo->dev_h = work_out [1] + 1L;
  devinfo->pix_w = work_out [3];
  devinfo->pix_h = work_out [4];

  vst_font (vdi_handle, FONT_SWISS);
  point = vst_point (vdi_handle, 99, &char_w, &char_h, &cell_w, &cell_h);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

  char_h = distances [1] + distances [3] + 1;
  pix_h  = point * 25400L / 72 / char_h;
  pix_w  = pix_h * devinfo->pix_w / devinfo->pix_h;

  devinfo->pix_w = pix_w;
  devinfo->pix_h = pix_h;
} /* device_info */

/*****************************************************************************/


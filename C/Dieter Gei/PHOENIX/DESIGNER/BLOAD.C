/*****************************************************************************
 *
 * Module : BLOAD.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 08.08.02
 *
 *
 * Description: This module implements the load/save database functions.
 *
 * History:
 * 08.08.02: Ausgabefelder werden nicht automatisch auf MT_UNDERLINED gesetzt.
 * 22.09.95: Creating of std_mask for SYS_ACCOUNT added to std_mask
 * 23.07.95: SM_SHOW_3D added to std_mask
 * 18.08.94: SM_SHOW_INFO and SM_SHOW_MENU added to std_mask
 * 11.08.94: INX_DIRTY flag reset if indexes has been updated in b_save_base
 * 25.10.93: Test on BASE_RDONLY in b_save_base added
 * 06.09.93: Modifications in init_message, show_message made
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "dialog.h"
#include "butil.h"
#include "mclick.h"
#include "mfile.h"

#include "export.h"
#include "bload.h"

/****** DEFINES **************************************************************/

#define QUERY_TEXT 2    /* field number of text within table SYSQUERY */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL SYSICON default_icon =
{0L, 0, 32, 31, {(32 + 15) / 16 * 31 * 4,       /* bytes = (width + 15) / 16 * height * 4 (data & mask in bytes) */
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE,
                 0x7FFF, 0xFFFE, 0x0000, 0x0000,
                 0x0000, 0x0000,

                 0x7FFF, 0xFFFE, 0x4200, 0x8202,
                 0x5AFE, 0xBAFA, 0x4200, 0x8202,
                 0x7FFF, 0xFFFE, 0x4200, 0x8202,
                 0x4200, 0x8202, 0x4200, 0x8202,
                 0x6AAA, 0xAAAA, 0x4200, 0x8202,
                 0x4200, 0x8202, 0x4200, 0x8202,
                 0x6AAA, 0xAAAA, 0x4200, 0x8202,
                 0x4200, 0x8202, 0x4200, 0x8202,
                 0x6AAA, 0xAAAA, 0x4200, 0x8202,
                 0x4200, 0x8202, 0x4200, 0x8202,
                 0x6AAA, 0xAAAA, 0x4200, 0x8202,
                 0x4200, 0x8202, 0x4200, 0x8202,
                 0x6AAA, 0xAAAA, 0x4200, 0x8202,
                 0x4200, 0x8202, 0x4200, 0x8202,
                 0x7FFF, 0xFFFE, 0x0000, 0x0000,
                 0x0000, 0x0000}
}; /* SYSICON */

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN read_table     _((BASE *base, WORD table, WORD inx, VOID *buffer, WORD recsize, WORD num, WORD text1, WORD text2));
LOCAL BOOLEAN read_masks     _((BASE_SPEC *base_spec));
LOCAL WORD    get_recs       _((BASE_SPEC *base_spec, WORD table));

LOCAL BOOLEAN hndl_table     _((BASE *base, SYSTABLE  *systable));
LOCAL BOOLEAN hndl_column    _((BASE *base, SYSCOLUMN *syscolumn));
LOCAL BOOLEAN hndl_index     _((BASE *base, SYSINDEX  *sysindex));
LOCAL BOOLEAN hndl_rel       _((BASE *base, SYSREL    *sysrel));
LOCAL BOOLEAN hndl_user      _((BASE *base, SYSUSER   *sysuser));
LOCAL BOOLEAN hndl_icon      _((BASE *base, SYSICON   *sysicon));
LOCAL BOOLEAN hndl_tattr     _((BASE *base, SYSTATTR  *systattr));
LOCAL BOOLEAN hndl_format    _((BASE *base, SYSFORMAT *sysformat));
LOCAL BOOLEAN hndl_lookup    _((BASE *base, SYSLOOKUP *syslookup));
LOCAL BOOLEAN hndl_mask      _((BASE *base, HLPMASK   *hlpmask, FHANDLE f));

LOCAL BOOLEAN std_mask       _((BASE_SPEC *base_spec, WORD table, BYTE *tablename));
LOCAL WORD    addfield       _((BASE_SPEC *base_spec, SYSMASK *sysmask, WORD table, WORD field, WORD font, WORD point, RECT *r, WORD *strinx));
LOCAL WORD    add_mskobject  _((SYSMASK *sysmask, MFIELD *mfield, BYTE *s1, BYTE *s2, BYTE *s3, WORD field, WORD *strinx));
LOCAL VOID    ins_def_tattr  _((BASE_SPEC *base_spec, WORD tables, WORD tattrs));
LOCAL VOID    ins_def_format _((BASE_SPEC *base_spec, BOOLEAN into_base));
LOCAL BOOLEAN del_trash      _((BASE *base));

/*****************************************************************************/

GLOBAL BOOLEAN b_new_base (base_spec)
BASE_SPEC *base_spec;

{
  LONG     size;
  LONG     size_tables;
  LONG     size_columns;
  LONG     size_indexes;
  LONG     size_rels;
  LONG     size_users;
  LONG     size_icons;
  LONG     size_tattrs;
  LONG     size_formats;
  LONG     size_lookups;
  LONG     size_masks;
  LONG     size_sysptrs;
  WORD     i;
  BYTE     *buffer;
  SYSTABLE *systable;

  /* watch for special handling for masks */

  base_spec->max_tables  = work_spec.tables + NUM_SYSTABLES;
  base_spec->max_columns = work_spec.columns;
  base_spec->max_indexes = work_spec.indexes;
  base_spec->max_rels    = work_spec.rels;
  base_spec->max_users   = work_spec.users;
  base_spec->max_icons   = work_spec.icons;
  base_spec->max_tattrs  = work_spec.tables + NUM_SYSTABLES;
  base_spec->max_formats = work_spec.formats + NUM_TYPES;
  base_spec->max_lookups = work_spec.lookups;
  base_spec->max_masks   = work_spec.masks;

  size_tables  = base_spec->max_tables  * (LONG)sizeof (SYSTABLE);
  size_columns = base_spec->max_columns * (LONG)sizeof (SYSCOLUMN);
  size_indexes = base_spec->max_indexes * (LONG)sizeof (SYSINDEX);
  size_rels    = base_spec->max_rels    * (LONG)sizeof (SYSREL);
  size_users   = base_spec->max_users   * (LONG)sizeof (SYSUSER);
  size_icons   = base_spec->max_icons   * (LONG)sizeof (SYSICON);
  size_tattrs  = base_spec->max_tattrs  * (LONG)sizeof (SYSTATTR);
  size_formats = base_spec->max_formats * (LONG)sizeof (SYSFORMAT);
  size_lookups = base_spec->max_lookups * (LONG)sizeof (SYSLOOKUP);
  size_masks   = base_spec->max_masks   * (LONG)sizeof (HLPMASK);
  size_sysptrs = base_spec->max_tables  * (LONG)sizeof (SYSPTR);

  size = size_tables + size_columns + size_indexes + size_rels    + size_users +
         size_icons  + size_tattrs  + size_formats + size_lookups + size_masks +
         size_sysptrs;

  buffer = (BYTE *)mem_alloc (size);
  if (buffer == NULL) return (FALSE);

  mem_lset (buffer, 0, size);

  base_spec->systable  = (SYSTABLE  *)buffer; buffer += size_tables;
  base_spec->syscolumn = (SYSCOLUMN *)buffer; buffer += size_columns;
  base_spec->sysindex  = (SYSINDEX  *)buffer; buffer += size_indexes;
  base_spec->sysrel    = (SYSREL    *)buffer; buffer += size_rels;
  base_spec->sysuser   = (SYSUSER   *)buffer; buffer += size_users;
  base_spec->sysicon   = (SYSICON   *)buffer; buffer += size_icons;
  base_spec->systattr  = (SYSTATTR  *)buffer; buffer += size_tattrs;
  base_spec->sysformat = (SYSFORMAT *)buffer; buffer += size_formats;
  base_spec->syslookup = (SYSLOOKUP *)buffer; buffer += size_lookups;
  base_spec->sysmask   = (HLPMASK   *)buffer; buffer += size_masks;
  base_spec->sysptr    = (SYSPTR    *)buffer; buffer += size_sysptrs;

  base_spec->first_table = NUM_SYSTABLES;
  base_spec->num_tables  = NUM_SYSTABLES;
  base_spec->num_tattrs  = NUM_SYSTABLES;
  base_spec->num_formats = NUM_TYPES;
  base_spec->num_icons   = 1;

  base_spec->sysicon [0]        = default_icon;
  base_spec->sysicon [0].flags |= INS_FLAG;

  ins_def_format (base_spec, FALSE);

  systable = base_spec->systable;

  for (i = SYS_TABLE; i < NUM_SYSTABLES; i++, systable++)
  {
    strcpy (systable->name, "SYS_DUMMY");
    systable->address = 0;
    systable->table   = i;
    systable->recs    = 0;
    systable->cols    = 0;
    systable->size    = 0;
    systable->indexes = 0;
    systable->flags   = GRANT_NOTHING;
  } /* for */

  fill_sysptr (base_spec);

  return (TRUE);
} /* b_new_base */

/*****************************************************************************/

GLOBAL WORD b_load_base (base_spec)
BASE_SPEC *base_spec;

{
  BOOLEAN   ok, new;
  WORD      table, status;
  WORD      tables, tattrs, formats;
  WORD      i;
  LONG      size;
  LONG      size_tables;
  LONG      size_columns;
  LONG      size_indexes;
  LONG      size_rels;
  LONG      size_users;
  LONG      size_icons;
  LONG      size_tattrs;
  LONG      size_formats;
  LONG      size_lookups;
  LONG      size_masks;
  LONG      size_sysptrs;
  RECT      r;
  MFDB      screen, buf;
  USERNAME  user, tmp;
  PASSWORD  pass;
  LONGSTR   s;
  FULLNAME  filename;
  BYTE      *buffer, *p;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;
  SYSINDEX  *sysindex;

  /* watch for special handling for masks */

  base_spec->in_memory = FALSE;

  if (get_recs (base_spec, SYS_ICON) == 0)      /* insert default icon */
  {
    db_insert (base_spec->base, SYS_ICON, &default_icon, &status);
    dbtest (base_spec->base);
  } /* if */

  tables  = get_recs (base_spec, SYS_TABLE);
  tattrs  = get_recs (base_spec, SYS_TATTR);
  formats = get_recs (base_spec, SYS_FORMAT);

  if (tattrs < tables)                          /* insert default table attributes */
    ins_def_tattr (base_spec, tables, tattrs);

  if (formats == 0) ins_def_format (base_spec, TRUE);

  base_spec->num_tables  = get_recs (base_spec, SYS_TABLE);
  base_spec->num_columns = get_recs (base_spec, SYS_COLUMN);
  base_spec->num_indexes = get_recs (base_spec, SYS_INDEX);
  base_spec->num_rels    = get_recs (base_spec, SYS_REL);
  base_spec->num_users   = get_recs (base_spec, SYS_USER);
  base_spec->num_icons   = get_recs (base_spec, SYS_ICON);
  base_spec->num_tattrs  = get_recs (base_spec, SYS_TATTR);
  base_spec->num_formats = get_recs (base_spec, SYS_FORMAT);
  base_spec->num_lookups = get_recs (base_spec, SYS_LOOKUP);
  base_spec->num_masks   = get_recs (base_spec, SYS_MASK);

  base_spec->max_tables  = base_spec->num_tables  + work_spec.tables;
  base_spec->max_columns = base_spec->num_columns + work_spec.columns;
  base_spec->max_indexes = base_spec->num_indexes + work_spec.indexes;
  base_spec->max_rels    = base_spec->num_rels    + work_spec.rels;
  base_spec->max_users   = base_spec->num_users   + work_spec.users;
  base_spec->max_icons   = base_spec->num_icons   + work_spec.icons;
  base_spec->max_tattrs  = base_spec->num_tattrs  + work_spec.tables;
  base_spec->max_formats = base_spec->num_formats + work_spec.formats;
  base_spec->max_lookups = base_spec->num_lookups + work_spec.lookups;
  base_spec->max_masks   = base_spec->num_masks   + work_spec.masks;

  size_tables  = base_spec->max_tables  * (LONG)sizeof (SYSTABLE);
  size_columns = base_spec->max_columns * (LONG)sizeof (SYSCOLUMN);
  size_indexes = base_spec->max_indexes * (LONG)sizeof (SYSINDEX);
  size_rels    = base_spec->max_rels    * (LONG)sizeof (SYSREL);
  size_users   = base_spec->max_users   * (LONG)sizeof (SYSUSER);
  size_icons   = base_spec->max_icons   * (LONG)sizeof (SYSICON);
  size_tattrs  = base_spec->max_tattrs  * (LONG)sizeof (SYSTATTR);
  size_formats = base_spec->max_formats * (LONG)sizeof (SYSFORMAT);
  size_lookups = base_spec->max_lookups * (LONG)sizeof (SYSLOOKUP);
  size_masks   = base_spec->max_masks   * (LONG)sizeof (HLPMASK);
  size_sysptrs = base_spec->max_tables  * (LONG)sizeof (SYSPTR);

  size = size_tables + size_columns + size_indexes + size_rels    + size_users +
         size_icons  + size_tattrs  + size_formats + size_lookups + size_masks +
         size_sysptrs;

  buffer = (BYTE *)mem_alloc (size);
  if (buffer == NULL) return (ERR_NOMEMORY);

  base_spec->memsize = size;

  mem_lset (buffer, 0, size);

  base_spec->systable  = (SYSTABLE  *)buffer; buffer += size_tables;
  base_spec->syscolumn = (SYSCOLUMN *)buffer; buffer += size_columns;
  base_spec->sysindex  = (SYSINDEX  *)buffer; buffer += size_indexes;
  base_spec->sysrel    = (SYSREL    *)buffer; buffer += size_rels;
  base_spec->sysuser   = (SYSUSER   *)buffer; buffer += size_users;
  base_spec->sysicon   = (SYSICON   *)buffer; buffer += size_icons;
  base_spec->systattr  = (SYSTATTR  *)buffer; buffer += size_tattrs;
  base_spec->sysformat = (SYSFORMAT *)buffer; buffer += size_formats;
  base_spec->syslookup = (SYSLOOKUP *)buffer; buffer += size_lookups;
  base_spec->sysmask   = (HLPMASK   *)buffer; buffer += size_masks;
  base_spec->sysptr    = (SYSPTR    *)buffer; buffer += size_sysptrs;

  ok = TRUE;

  mem_lmove (base_spec->systable,  base_spec->base->systable,  (LONG)base_spec->num_tables  * sizeof (SYSTABLE));
  mem_lmove (base_spec->syscolumn, base_spec->base->syscolumn, (LONG)base_spec->num_columns * sizeof (SYSCOLUMN));
  mem_lmove (base_spec->sysindex,  base_spec->base->sysindex,  (LONG)base_spec->num_indexes * sizeof (SYSINDEX));

  sprintf (filename, "%s%s", base_spec->basepath, base_spec->basename);
  sprintf (s, FREETXT (FOPEN), filename);
  init_message (NIL, &r, &screen, &buf, s);

  ok = ok && read_table (base_spec->base, SYS_REL,    1, base_spec->sysrel,    sizeof (SYSREL),    base_spec->num_rels,    FREAD, FRELS);
  ok = ok && read_table (base_spec->base, SYS_USER,   0, base_spec->sysuser,   sizeof (SYSUSER),   base_spec->num_users,   FREAD, FUSERS);
  ok = ok && read_table (base_spec->base, SYS_ICON,   1, base_spec->sysicon,   sizeof (SYSICON),   base_spec->num_icons,   FREAD, FICONS);
  ok = ok && read_table (base_spec->base, SYS_TATTR,  1, base_spec->systattr,  sizeof (SYSTATTR),  base_spec->num_tattrs,  FREAD, FTATTRIB);
  ok = ok && read_table (base_spec->base, SYS_FORMAT, 1, base_spec->sysformat, sizeof (SYSFORMAT), base_spec->num_formats, FREAD, FFORMATS);
  ok = ok && read_table (base_spec->base, SYS_LOOKUP, 1, base_spec->syslookup, sizeof (SYSLOOKUP), base_spec->num_lookups, FREAD, FLOOKUPS);

  show_message (base_spec->num_masks, FREAD, FMASKS);
  ok = ok && read_masks (base_spec);

  exit_message (&r, &screen, &buf);

  if (! ok)
  {
    mem_free (buffer);
    return (ERR_NOMEMORY);
  } /* if */

  fill_sysptr (base_spec);

  db_baseinfo (base_spec->base, &base_spec->base_info);
  base_spec->reorg      = base_spec->base->datainf->page0.reorg;
  base_spec->cflags     = base_spec->base->datainf->page0.flags;
  base_spec->cflags    |= base_spec->base->treeinf->page0.flags;
  base_spec->delptr     = 0;
  base_spec->delkeyptr  = 0;

  new = TRUE;

  for (i = 0; i < base_spec->num_tables;  i++) base_spec->systable [i].flags  &= ~ DESIGNER_FLAGS;
  for (i = 0; i < base_spec->num_columns; i++) base_spec->syscolumn [i].flags &= ~ DESIGNER_FLAGS;
  for (i = 0; i < base_spec->num_indexes; i++) base_spec->sysindex [i].flags  &= ~ DESIGNER_FLAGS;
  for (i = 0; i < base_spec->num_rels;    i++) base_spec->sysrel [i].flags    &= ~ DESIGNER_FLAGS;
  for (i = 0; i < base_spec->num_users;   i++) base_spec->sysuser [i].flags   &= ~ DESIGNER_FLAGS;
  for (i = 0; i < base_spec->num_icons;   i++) base_spec->sysicon [i].flags   &= ~ DESIGNER_FLAGS;
  for (i = 0; i < base_spec->num_tattrs;  i++) base_spec->systattr [i].flags  &= ~ DESIGNER_FLAGS;
  for (i = 0; i < base_spec->num_formats; i++) base_spec->sysformat [i].flags &= ~ DESIGNER_FLAGS;
  for (i = 0; i < base_spec->num_lookups; i++) base_spec->syslookup [i].flags &= ~ DESIGNER_FLAGS;
  for (i = 0; i < base_spec->num_masks;   i++) base_spec->sysmask [i].flags   &= ~ DESIGNER_FLAGS;

  for (table = SYS_CALC; table < tables; table++)
    if (base_spec->systable [table].recs > 0) new = FALSE;

  base_spec->new = new;

  if (new)
  {
    for (i = 0; i < base_spec->num_tables;  i++) base_spec->systable [i].flags  |= INS_FLAG;
    for (i = 0; i < base_spec->num_columns; i++) base_spec->syscolumn [i].flags |= INS_FLAG;
    for (i = 0; i < base_spec->num_indexes; i++) base_spec->sysindex [i].flags  |= INS_FLAG;
    for (i = 0; i < base_spec->num_rels;    i++) base_spec->sysrel [i].flags    |= INS_FLAG;
    for (i = 0; i < base_spec->num_users;   i++) base_spec->sysuser [i].flags   |= INS_FLAG;
    for (i = 0; i < base_spec->num_icons;   i++) base_spec->sysicon [i].flags   |= INS_FLAG;
    for (i = 0; i < base_spec->num_tattrs;  i++) base_spec->systattr [i].flags  |= INS_FLAG;
    for (i = 0; i < base_spec->num_formats; i++) base_spec->sysformat [i].flags |= INS_FLAG;
    for (i = 0; i < base_spec->num_lookups; i++) base_spec->syslookup [i].flags |= INS_FLAG;
  } /* if */
  else
  {
    systable = &base_spec->systable [NUM_SYSTABLES];

    for (table = NUM_SYSTABLES; table < tables; table++, systable++)
    {
      sysindex = &base_spec->sysindex [absinx (base_spec, table, 0)];
      for (i = 0; i < systable->indexes; i++, sysindex++) sysindex->flags |= MOD_FLAG;

      if (systable->recs == 0)
      {
        systable->flags |= MOD_FLAG;

        syscolumn = &base_spec->syscolumn [abscol (base_spec, table, 0)];
        for (i = 0; i < systable->cols; i++, syscolumn++) syscolumn->flags |= MOD_FLAG;
      } /* if */
    } /* for */

    for (i = 0; i < base_spec->num_rels;    i++) base_spec->sysrel [i].flags    |= MOD_FLAG;
    for (i = 0; i < base_spec->num_users;   i++) base_spec->sysuser [i].flags   |= MOD_FLAG;
    for (i = 0; i < base_spec->num_icons;   i++) base_spec->sysicon [i].flags   |= MOD_FLAG;
    for (i = 0; i < base_spec->num_tattrs;  i++) base_spec->systattr [i].flags  |= MOD_FLAG;
    for (i = 0; i < base_spec->num_formats; i++) base_spec->sysformat [i].flags |= MOD_FLAG;
    for (i = 0; i < base_spec->num_lookups; i++) base_spec->syslookup [i].flags |= MOD_FLAG;
    for (i = 0; i < base_spec->num_masks;   i++) base_spec->sysmask [i].flags   |= MOD_FLAG;
  } /* else */

  for (i = 0; i < base_spec->num_tattrs;  i++)
    get_tblwh (base_spec, i, &base_spec->systattr [i].width, &base_spec->systattr [i].height);

  if (new) close_db (base_spec);

  base_spec->first_table = NUM_SYSTABLES;

#ifdef PHOENIX
{
  WORD ret;
  WORD mstate, kstate;

  graf_mkstate (&ret, &ret, &mstate, &kstate);
  if (kstate == K_ALT) base_spec->first_table = SYS_TABLE;
}
#endif

  if (base_spec->num_users > 0) /* superuser must be first user */
  {
    strcpy (user, base_spec->username);
    strcpy (pass, base_spec->password);
    str_upper (user);
    str_upper (pass);

    for (p = user; *p; p++) *p += 1;
    for (p = pass; *p; p++) *p += 1;

#ifdef PHOENIX
    if ((strcmp (user, "EH0KH") == 0) &&                     /* DG/JG */
        (strcmp (pass, "%QIPFOJY%") == 0)) return (SUCCESS); /* $PHOENIX$ */
#endif

    strcpy (user, base_spec->username);
    str_ascii (user);
    str_upper (user);

    strcpy (tmp, base_spec->sysuser [0].name);
    str_ascii (tmp);
    str_upper (tmp);

    if (strcmp (user, tmp) != 0)
    {
      mem_free (buffer);
      return (ERR_SUPERUSER);
    } /* if */
  } /* if */

  return (SUCCESS);
} /* b_load_base */

/*****************************************************************************/

GLOBAL BOOLEAN b_save_base (window)
WINDOWP window;

{
  BOOLEAN    ok, mode, bUpd;
  WORD       i, result, status, table;
  WORD       w, button;
  WORD       start_table;
  WORD       start_column;
  WORD       start_index;
  LONG       datasize, treesize;
  LONGSTR    s, str;
  RECT       r;
  MFDB       screen, buffer;
  SET        tables;
  TABLE_INFO table_info;
  DELSPEC    *delptr;
  DELKEY     *delkey;
  BASE       *base;
  SYSTABLE   *systable;
  SYSCOLUMN  *syscolumn;
  SYSINDEX   *sysindex;
  SYSINDEX   *orgindex;
  SYSREL     *sysrel;
  SYSUSER    *sysuser;
  SYSICON    *sysicon;
  SYSTATTR   *systattr;
  SYSFORMAT  *sysformat;
  SYSLOOKUP  *syslookup;
  HLPMASK    *sysmask;
  BASE_SPEC  *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  if (! base_spec->modified) return (TRUE);
  if (! base_spec->new)
    if (base_spec->base->datainf->flags & BASE_RDONLY) return (TRUE);

  busy_mouse ();

  init_message (MFILE, &r, &screen, &buffer, "");
  objc_rect (empty, EACTION, &r, FALSE);
  w  = empty [EACTION].ob_width / gl_wbox;

  ok = TRUE;

  if (base_spec->new)
  {
    sprintf (str, "%s%s", base_spec->basepath, base_spec->basename);
    sprintf (s, FREETXT (FCREATE), str);
    s [w] = EOS;
    set_str (empty, EACTION, s);
    objc_draw (empty, EACTION, MAX_DEPTH, r.x, r.y, r.w, r.h);

    base_spec->base = db_create (base_spec->basename,
                                 base_spec->basepath,
                                 base_spec->cflags | BASE_SUPER,
                                 base_spec->datasize,
                                 base_spec->treesize);

    if (base_spec->base == NULL) return (FALSE);

    base_spec->in_memory = FALSE;
    ins_def_tattr (base_spec, NUM_SYSTABLES, 0);
    base_spec->in_memory = TRUE;
  } /* if */
  else
  {
    datasize = base_spec->base_info.data_info.file_size / 1024;
    treesize = base_spec->base_info.tree_info.num_pages / 2;

    sprintf (str, "%s%s", base_spec->basepath, base_spec->basename);
    sprintf (s, FREETXT (FEXPAND), str);
    s [w] = EOS;

    if ((datasize != base_spec->datasize) || (treesize != base_spec->treesize))
    {
      set_str (empty, EACTION, s);
      objc_draw (empty, EACTION, MAX_DEPTH, r.x, r.y, r.w, r.h);

      result = db_expand (base_spec->base, base_spec->datasize, base_spec->treesize);
      dbtest (base_spec->base);

      if (result != SUCCESS)
      {
        if (result == -1) sprintf (s, alerts [ERR_DATAEXPAND], base_spec->basepath, base_spec->basename);
        if (result == -2) sprintf (s, alerts [ERR_TREEEXPAND], base_spec->basepath, base_spec->basename);

        open_alert (s);
      } /* if */
    } /* if */

    sprintf (s, FREETXT (FSAVE), str);
    s [w] = EOS;
    set_str (empty, EACTION, s);
    objc_draw (empty, EACTION, MAX_DEPTH, r.x, r.y, r.w, r.h);

    delkey = base_spec->delkeys;
    delptr = base_spec->delobjs;

    for (i = 0; ok && (i < base_spec->delkeyptr); i++, delkey++) /* kill specified trees */
      ok = db_killtree (base_spec->base, delkey->table, delkey->key);

    for (i = 0; ok && (i < base_spec->delptr); i++, delptr++) /* delete specified objects */
      if (delptr->address > 0) ok = db_delete (base_spec->base, delptr->table, delptr->address, &status);

    if (! ok)
      dbtest (base_spec->base);
    else
      if (base_spec->del_trash)
      {
        v_tableinfo (base_spec, SYS_DELETED, &table_info);
        if (table_info.recs > 0) 
        {
          show_message (table_info.recs > 0, FDELOBJ, FDELETED);
          ok = del_trash (base_spec->base);
        } /* if */
      } /* if, else */

    if (ok) base_spec->base->datainf->page0.reorg = base_spec->reorg;
  } /* else */

  if (ok)
  {
    base = base_spec->base;
    ok   = base != NULL;
  } /* if */

  if (ok)
  {
    start_table  = NUM_SYSTABLES;
    start_column = base_spec->sysptr [NUM_SYSTABLES - 1].column;
    start_index  = base_spec->sysptr [NUM_SYSTABLES - 1].index;

    systable  = &base_spec->systable [start_table];
    syscolumn = &base_spec->syscolumn [start_column];
    sysindex  = &base_spec->sysindex [start_index];
    sysrel    = &base_spec->sysrel [0];
    sysuser   = &base_spec->sysuser [0];
    sysicon   = &base_spec->sysicon [0];
    systattr  = &base_spec->systattr [start_table];
    sysformat = &base_spec->sysformat [0];
    syslookup = &base_spec->syslookup [0];
    sysmask   = &base_spec->sysmask [0];
    orgindex  = &base->sysindex [start_index];	/* used to set back INX_DIRTY flag */

    if (unixdb)
    {
      for (i = start_table; i < base_spec->num_tables; i++, systable++) set_coladr (base_spec, i);

      systable = &base_spec->systable [start_table];
    } /* if */

    show_message (base_spec->num_tables - start_table, FWRITE, FTABLES);
    for (i = start_table; i < base_spec->num_tables; i++, systable++)
      ok = hndl_table (base, systable) && ok;

    show_message (base_spec->num_columns - start_column, FWRITE, FCOLUMNS);
    for (i = start_column; i < base_spec->num_columns; i++, syscolumn++)
      ok = hndl_column (base, syscolumn) && ok;

    show_message (base_spec->num_indexes - start_index, FWRITE, FINDEXES);
    for (i = start_index; i < base_spec->num_indexes; i++, sysindex++, orgindex++)
    {
      bUpd = (sysindex->flags & UPD_FLAG) && (i < base->sysinxs);
      if (bUpd)					/* if key was deleted via db_killtree above get new root and num_keys values */
      {
        sysindex->root     = orgindex->root;
        sysindex->num_keys = orgindex->num_keys;
      } /* if */

      ok = hndl_index (base, sysindex) && ok;

      if (bUpd) orgindex->flags &= ~ INX_DIRTY;	/* index was just updated in hndl_index so ignore index cache */
    } /* for */

    show_message (base_spec->num_rels, FWRITE, FRELS);
    for (i = 0; i < base_spec->num_rels; i++, sysrel++)
      ok = hndl_rel (base, sysrel) && ok;

    show_message (base_spec->num_users, FWRITE, FUSERS);
    for (i = 0; i < base_spec->num_users; i++, sysuser++)
      ok = hndl_user (base, sysuser) && ok;

    show_message (base_spec->num_icons, FWRITE, FICONS);
    for (i = 0; i < base_spec->num_icons; i++, sysicon++)
      ok = hndl_icon (base, sysicon) && ok;

    show_message (base_spec->num_tattrs, FWRITE, FTATTRIB);
    for (i = start_table; i < base_spec->num_tattrs; i++, systattr++)
      ok = hndl_tattr (base, systattr) && ok;

    show_message (base_spec->num_formats, FWRITE, FFORMATS);
    for (i = 0; i < base_spec->num_formats; i++, sysformat++)
      ok = hndl_format (base, sysformat) && ok;

    show_message (base_spec->num_lookups, FWRITE, FLOOKUPS);
    for (i = 0; i < base_spec->num_lookups; i++, syslookup++)
      ok = hndl_lookup (base, syslookup) && ok;

    setclr (tables);
    show_message (base_spec->num_masks, FWRITE, FMASKS);
    for (i = 0; i < base_spec->num_masks; i++, sysmask++)
    {
      strcpy (table_info.name, sysmask->tablename);
      table = v_tableinfo (base_spec, FAILURE, &table_info);
      if (table != FAILURE) setincl (tables, table);
      ok = hndl_mask (base, sysmask, base_spec->fmask) && ok;
    } /* for */

    if (! setin (tables, SYS_CALC))    ok = std_mask (base_spec, SYS_CALC,    FREETXT (FCALCS))    && ok;
    if (! setin (tables, SYS_QUERY))   ok = std_mask (base_spec, SYS_QUERY,   FREETXT (FQUERIES))  && ok;
    if (! setin (tables, SYS_REPORT))  ok = std_mask (base_spec, SYS_REPORT,  FREETXT (FREPORTS))  && ok;
    if (! setin (tables, SYS_BATCH))   ok = std_mask (base_spec, SYS_BATCH,   FREETXT (FBATCHES))  && ok;
    if (! setin (tables, SYS_ACCOUNT)) ok = std_mask (base_spec, SYS_ACCOUNT, FREETXT (FACCOUNTS)) && ok;

    mode = set_alert (TRUE);            /* alert boxes as dialog boxes */

    for (table = base_spec->first_table; table < base_spec->num_tables; table++)
      if (! setin (tables, table))
      {
        v_tableinfo (base_spec, table, &table_info);
        if (table_info.cols > 1)
        {
          if (table >= NUM_SYSTABLES)
          {
            sprintf (s, alerts [ERR_STDMASK], table_info.name);
            button = open_alert (s);
          } /* if */
          else
            button = 1;

          if (button == 1) ok = std_mask (base_spec, table, NULL) && ok;
        } /* if */
      } /* if, for */

    set_alert (mode);                   /* restore old mode */

    if (ok)
    {
      base_spec->modified  = FALSE;
      base_spec->show_star = FALSE;

      b_wi_title (window);
    } /* if */
  } /* if */

  arrow_mouse ();
  exit_message (&r, &screen, &buffer);

  if (ok && base_spec->reorg)
  {
    sprintf (s, alerts [ERR_REORG], base_spec->basename);
    open_alert (s);
  } /* if */

  if (ok && autoexp && ! base_spec->new)
  {
    strcpy (s, base_spec->basepath);
    strcat (s, base_spec->basename);
    mexport (base_spec, s);
  } /* if */

  return (ok);
} /* b_save_base */

/*****************************************************************************/

GLOBAL VOID b_wi_title (window)
WINDOWP window;

{
  STRING    s;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  if (base_spec->modified)
    strcpy (window->name, " *");
  else
    strcpy (window->name, " ");

  sprintf (s, "%s%s ", base_spec->basepath, base_spec->basename);
  strcat (window->name, s);
  wind_set (window->handle, WF_NAME, ADR (window->name), 0, 0);
} /* b_wi_title */

/*****************************************************************************/

LOCAL BOOLEAN read_table (base, table, inx, bufp, recsize, num, text1, text2)
BASE *base;
WORD table;
WORD inx;
VOID *bufp;
WORD recsize;
WORD num;
WORD text1, text2;

{
  BYTE   *buffer;
  LONG   steps;
  CURSOR *cursor;

  show_message (num, text1, text2);

  buffer = (BYTE *)bufp;
  steps  = 1;
  cursor = db_newcursor (base);
  dbtest (base);

  if (cursor != NULL)
  {
    if (db_initcursor (base, table, inx, ASCENDING, cursor))
      while (db_movecursor (base, cursor, steps))
      {
        if (db_read (base, table, buffer, cursor, 0L, FALSE)) buffer += recsize;
        dbtest (base);
      } /* while */

    db_freecursor (base, cursor);
    return (TRUE);
  } /* if */
  else
    return (FALSE);
} /* read_table */

/*****************************************************************************/

LOCAL BOOLEAN read_masks (base_spec)
BASE_SPEC *base_spec;

{
  BOOLEAN ok;
  LONG    steps;
  SYSMASK *sysmask;
  HLPMASK *hlpmask;
  CURSOR  *cursor;

  sysmask = (SYSMASK *)mem_alloc ((LONG)sizeof (SYSMASK));
  if (sysmask == NULL) return (FALSE);

  steps   = 1;
  cursor  = db_newcursor (base_spec->base);
  hlpmask = base_spec->sysmask;
  ok      = cursor != NULL;

  dbtest (base_spec->base);

  if (ok)
  {
    if (db_initcursor (base_spec->base, SYS_MASK, 1, ASCENDING, cursor))
      while (db_movecursor (base_spec->base, cursor, steps))
      {
        if (db_read (base_spec->base, SYS_MASK, sysmask, cursor, 0L, FALSE))
        {
          strcpy (hlpmask->device, sysmask->device);
          strcpy (hlpmask->name, sysmask->name);
          strcpy (hlpmask->tablename, sysmask->tablename);
          strcpy (hlpmask->calcentry, sysmask->calcentry);
          strcpy (hlpmask->calcexit, sysmask->calcexit);
          hlpmask->address = sysmask->address;
          hlpmask->findex  = FAILURE;
          hlpmask->flags   = sysmask->flags;
          hlpmask->version = sysmask->version;
          hlpmask->x       = sysmask->x;
          hlpmask->y       = sysmask->y;
          hlpmask->w       = sysmask->w;
          hlpmask->h       = sysmask->h;
          hlpmask->bkcolor = sysmask->bkcolor;

          hlpmask++;
        } /* if */

        dbtest (base_spec->base);
      } /* while */

    db_freecursor (base_spec->base, cursor);
  } /* if */

  mem_free (sysmask);

  return (ok);
} /* read_mask */

/*****************************************************************************/

LOCAL WORD get_recs (base_spec, table)
BASE_SPEC *base_spec;
WORD      table;

{
  TABLE_INFO table_info;

  if (v_tableinfo (base_spec, table, &table_info) != FAILURE)
    return ((WORD)table_info.recs);
  else
    return (0);
} /* get_recs */

/*****************************************************************************/

LOCAL BOOLEAN hndl_table (base, systable)
BASE     *base;
SYSTABLE *systable;

{
  BOOLEAN ok;
  WORD    status;

  ok = TRUE;

  if (systable->flags & INS_FLAG)
  {
    systable->flags &= ~ DESIGNER_FLAGS;
    ok = db_insert (base, SYS_TABLE, systable, &status);
  } /* if */
  else
    if (systable->flags & UPD_FLAG)
    {
      systable->flags &= ~ DESIGNER_FLAGS;
      ok = db_update (base, SYS_TABLE, systable, &status);
    } /* if, else */

  dbtest (base);

  return (ok);
} /* hndl_table */

/*****************************************************************************/

LOCAL BOOLEAN hndl_column (base, syscolumn)
BASE      *base;
SYSCOLUMN *syscolumn;

{
  BOOLEAN ok;
  WORD    status;

  ok = TRUE;

  if (syscolumn->flags & INS_FLAG)
  {
    syscolumn->flags &= ~ DESIGNER_FLAGS;
    ok = db_insert (base, SYS_COLUMN, syscolumn, &status);
  } /* if */
  else
    if (syscolumn->flags & UPD_FLAG)
    {
      syscolumn->flags &= ~ DESIGNER_FLAGS;
      ok = db_update (base, SYS_COLUMN, syscolumn, &status);
    } /* if, else */

  dbtest (base);

  return (ok);
} /* hndl_column */

/*****************************************************************************/

LOCAL BOOLEAN hndl_index (base, sysindex)
BASE     *base;
SYSINDEX *sysindex;

{
  BOOLEAN ok;
  WORD    status;

  ok = TRUE;

  if (sysindex->flags & INS_FLAG)
  {
    sysindex->flags &= ~ DESIGNER_FLAGS;
    ok = db_insert (base, SYS_INDEX, sysindex, &status);
  } /* if */
  else
    if (sysindex->flags & UPD_FLAG)
    {
      sysindex->flags &= ~ DESIGNER_FLAGS;
      ok = db_update (base, SYS_INDEX, sysindex, &status);
    } /* if, else */

  dbtest (base);

  return (ok);
} /* hndl_index */

/*****************************************************************************/

LOCAL BOOLEAN hndl_rel (base, sysrel)
BASE    *base;
SYSREL  *sysrel;

{
  BOOLEAN ok;
  WORD    status;

  ok = TRUE;

  if (sysrel->flags & DEL_FLAG)
  {
    sysrel->flags &= ~ DESIGNER_FLAGS;
    ok = db_delete (base, SYS_REL, sysrel->address, &status);
  } /* if */
  else
    if (sysrel->flags & INS_FLAG)
    {
      sysrel->flags &= ~ DESIGNER_FLAGS;
      ok = db_insert (base, SYS_REL, sysrel, &status);
    } /* if, else */
    else
      if (sysrel->flags & UPD_FLAG)
      {
        sysrel->flags &= ~ DESIGNER_FLAGS;
        ok = db_update (base, SYS_REL, sysrel, &status);
      } /* if, else */

  dbtest (base);

  return (ok);
} /* hndl_rel */

/*****************************************************************************/

LOCAL BOOLEAN hndl_user (base, sysuser)
BASE    *base;
SYSUSER *sysuser;

{
  BOOLEAN ok;
  WORD    status;

  ok = TRUE;

  if (sysuser->flags & INS_FLAG)
  {
    sysuser->flags &= ~ DESIGNER_FLAGS;
    ok = db_insert (base, SYS_USER, sysuser, &status);
  } /* if */
  else
    if (sysuser->flags & UPD_FLAG)
    {
      sysuser->flags &= ~ DESIGNER_FLAGS;
      ok = db_update (base, SYS_USER, sysuser, &status);
    } /* if, else */

  dbtest (base);

  return (ok);
} /* hndl_user */

/*****************************************************************************/

LOCAL BOOLEAN hndl_icon (base, sysicon)
BASE    *base;
SYSICON *sysicon;

{
  BOOLEAN ok;
  WORD    status;

  ok = TRUE;

  if (sysicon->flags & INS_FLAG)
  {
    sysicon->flags &= ~ DESIGNER_FLAGS;
    ok = db_insert (base, SYS_ICON, sysicon, &status);
  } /* if */
  else
    if (sysicon->flags & UPD_FLAG)
    {
      sysicon->flags &= ~ DESIGNER_FLAGS;
      ok = db_update (base, SYS_ICON, sysicon, &status);
    } /* if, else */

  dbtest (base);

  return (ok);
} /* hndl_icon */

/*****************************************************************************/

LOCAL BOOLEAN hndl_tattr (base, systattr)
BASE     *base;
SYSTATTR *systattr;

{
  BOOLEAN ok;
  WORD    status;

  ok = TRUE;

  if (systattr->flags & INS_FLAG)
  {
    systattr->flags &= ~ DESIGNER_FLAGS;
    ok = db_insert (base, SYS_TATTR, systattr, &status);
  } /* if */
  else
    if (systattr->flags & UPD_FLAG)
    {
      systattr->flags &= ~ DESIGNER_FLAGS;
      ok = db_update (base, SYS_TATTR, systattr, &status);
    } /* if, else */

  dbtest (base);

  return (ok);
} /* hndl_tattr */

/*****************************************************************************/

LOCAL BOOLEAN hndl_format (base, sysformat)
BASE      *base;
SYSFORMAT *sysformat;

{
  BOOLEAN ok;
  WORD    status;

  ok = TRUE;

  if (sysformat->flags & INS_FLAG)
  {
    sysformat->flags &= ~ DESIGNER_FLAGS;
    ok = db_insert (base, SYS_FORMAT, sysformat, &status);
  } /* if */
  else
    if (sysformat->flags & UPD_FLAG)
    {
      sysformat->flags &= ~ DESIGNER_FLAGS;
      ok = db_update (base, SYS_FORMAT, sysformat, &status);
    } /* if, else */

  dbtest (base);

  return (ok);
} /* hndl_format */

/*****************************************************************************/

LOCAL BOOLEAN hndl_lookup (base, syslookup)
BASE      *base;
SYSLOOKUP *syslookup;

{
  BOOLEAN ok;
  WORD    status;

  ok = TRUE;

  if (syslookup->flags & DEL_FLAG)
  {
    syslookup->flags &= ~ DESIGNER_FLAGS;
    ok = db_delete (base, SYS_LOOKUP, syslookup->address, &status);
  } /* if */
  else
    if (syslookup->flags & INS_FLAG)
    {
      syslookup->flags &= ~ DESIGNER_FLAGS;
      ok = db_insert (base, SYS_LOOKUP, syslookup, &status);
    } /* if, else */
    else
      if (syslookup->flags & UPD_FLAG)
      {
        syslookup->flags &= ~ DESIGNER_FLAGS;
        ok = db_update (base, SYS_LOOKUP, syslookup, &status);
      } /* if, else */

  dbtest (base);

  return (ok);
} /* hndl_lookup */

/*****************************************************************************/

LOCAL BOOLEAN hndl_mask (base, hlpmask, f)
BASE      *base;
HLPMASK   *hlpmask;
FHANDLE   f;

{
  BOOLEAN ok;
  WORD    status;
  LONG    offset;
  SYSMASK *sysmask;

  if (hlpmask->flags == 0) return (TRUE);

  sysmask = (SYSMASK *)mem_alloc ((LONG)sizeof (SYSMASK));
  if (sysmask == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (FALSE);
  } /* if */

  ok = TRUE;

  if (hlpmask->findex != FAILURE)
  {
    offset = hlpmask->findex * (LONG)sizeof (SYSMASK);
    ok     = file_seek (f, offset, SEEK_SET) == offset;
  } /* if */

  if (ok)
    if (hlpmask->flags & DEL_FLAG)
    {
      hlpmask->flags &= ~ DESIGNER_FLAGS;
      ok = db_delete (base, SYS_MASK, hlpmask->address, &status);
    } /* if, if */
    else
      if (hlpmask->flags & INS_FLAG)
      {
        file_read (f, (LONG)sizeof (SYSMASK), sysmask);
        hlpmask->flags &= ~ DESIGNER_FLAGS;
        sysmask->flags &= ~ DESIGNER_FLAGS;
        ok = db_insert (base, SYS_MASK, sysmask, &status);
      } /* if, else */
      else
        if (hlpmask->flags & UPD_FLAG)
        {
          file_read (f, (LONG)sizeof (SYSMASK), sysmask);
          hlpmask->flags &= ~ DESIGNER_FLAGS;
          sysmask->flags &= ~ DESIGNER_FLAGS;
          ok = db_update (base, SYS_MASK, sysmask, &status);
        } /* if, else */

  mem_free (sysmask);

  dbtest (base);

  return (ok);
} /* hndl_mask */

/*****************************************************************************/

LOCAL BOOLEAN std_mask (base_spec, table, tablename)
BASE_SPEC *base_spec;
WORD      table;
BYTE      *tablename;

{
  BOOLEAN    ok, in_memory;
  WORD       font, point;
  WORD       x, width, end, i, num_obj;
  WORD       obj_size, str_size, size;
  WORD       status, result, strinx;
  WORD       wchar, hchar, wbox, hbox;
  BYTE       device [2];
  RECT       ob;
  STRING     name;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  BYTE       *d;
  WORD       *objs;
  WORD       *sizep;
  SYSMASK    *sysmask;

  sysmask = (SYSMASK *)mem_alloc ((LONG)sizeof (SYSMASK));
  if (sysmask == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (FALSE);
  } /* if */

  ok        = TRUE;
  in_memory = base_spec->in_memory;

  if (table < NUM_SYSTABLES) base_spec->in_memory = FALSE;

  db_fillnull (base_spec->base, SYS_MASK, sysmask);
  v_tableinfo (base_spec, table, &table_info);

  if (tablename == NULL)
    strcpy (name, table_info.name);
  else
  {
    strcpy (name, "SYSTEM.");
    strcat (name, tablename);
  } /* if */

  device [0] = MASK_SCREEN;
  device [1] = EOS;
  strcpy (sysmask->device, device);
  strcpy (sysmask->name, name);
  strcpy (sysmask->tablename, table_info.name);
  strcpy (sysmask->username, "");
  sysmask->flags   |= SM_SHOW_ICONS | SM_SHOW_INFO | SM_SHOW_MENU | SM_SHOW_3D;
  sysmask->version  = MASK_VERSION;

  if (sysmask->flags & SM_SHOW_3D) sysmask->bkcolor = Color32FromIndex (DWHITE);

  result   = SUCCESS;
  ob.x     = 0;                                 /* starting at upper left corner of boxes */
  ob.y     = gl_hbox / 2;
  ob.w     = 0;
  ob.h     = 0;
  x        = ob.x;
  width    = 0;
  end      = table_info.cols;
  num_obj  = end - 1;                           /* don't use field address */
  strinx   = num_obj * sizeof (MOBJECT);
  d        = sysmask->mask.buffer;
  font     = FONT_SYSTEM;
  point    = gl_point;

  vst_font (vdi_handle, font);
  vst_point (vdi_handle, point, &wchar, &hchar, &wbox, &hbox);

  for (i = 1; i < end; i++)
  {
    v_fieldinfo (base_spec, table, i, &field_info);
    width = max (width, strlen (field_info.name));
  } /* for */

  for (i = 1; ok && (i < end); i++)
  {
    v_fieldinfo (base_spec, table, i, &field_info);
    ob.x      = x + (width - strlen (field_info.name)) * wbox;
    result    = addfield (base_spec, sysmask, table, i, font, point, &ob, &strinx);
    ok        = result == SUCCESS;

    switch (result)
    {
      case ERR_NOOBJECTS  : hndl_alert (ERR_NOOBJECTS);
                            break;
      case ERR_UNKNOWNOBJ : hndl_alert (ERR_UNKNOWNOBJ);
                            break;
    } /* switch */
  } /* for */

  obj_size = num_obj * sizeof (MOBJECT);
  str_size = strinx - obj_size;
  size     = (obj_size + str_size + 1) & 0xFFFE;        /* must be even */
  sizep    = (WORD *)(d + size);
  objs     = (WORD *)(d + size + sizeof (WORD));
  *objs    = num_obj;
  *sizep   = str_size;

  sysmask->mask.size = size + 2 * sizeof (WORD);        /* 2 extra words info */

  ok = ok && db_insert (base_spec->base, SYS_MASK, sysmask, &status);

  mem_free (sysmask);
  dbtest (base_spec->base);

  base_spec->in_memory = in_memory;

  return (ok);
} /* std_mask */

/*****************************************************************************/

LOCAL WORD addfield (base_spec, sysmask, table, field, font, point, r, strinx)
BASE_SPEC *base_spec;
SYSMASK   *sysmask;
WORD      table;
WORD      field;
WORD      font;
WORD      point;
RECT      *r;
WORD      *strinx;

{
  WORD       x, y, w, h, diff;
  WORD       wchar, hchar;
  WORD       wbox, hbox;
  WORD       type;
  LONG       lower, upper, maxw;
  UWORD      flags;
  TABLENAME  table_name;
  FIELDNAME  field_name;
  STRING     label_name;
  MFIELD     mfield;
  TABLE_INFO table_info;
  FIELD_INFO field_info;

  v_tableinfo (base_spec, table, &table_info);
  v_fieldinfo (base_spec, table, field, &field_info);

  x = r->x;
  y = r->y;

  if (x < 0) x = 0;
  if (y < 0) y = 0;

  type = field_info.type;
  w    = std_width [field_info.type];
  h    = 1;

  if (IS_BLOB (type) || IS_PICTURE (type))      /* default for pictures etc. */
  {
    w = 40;
    h = 10;
  } /* if */
  else
    if (w == 0)                                 /* default for strings etc. */
    {
      maxw = field_info.size - 1;               /* don't use EOS */
      if (maxw > 32767) maxw = 32767;
      w = maxw;

      if (w > 60)
      {
        h = w / 40 + 1;
        w = 40;
        if (h > 25) h = 25;                     /* 25 lines max default */
      } /* if */
    } /* if */
    else                                        /* numbers etc... use format */
      w = strlen (base_spec->sysformat [field_info.format].format);

  set_null (TYPE_LONG, &lower);
  set_null (TYPE_LONG, &upper);

  vst_font (vdi_handle, font);
  vst_point (vdi_handle, point, &wchar, &hchar, &wbox, &hbox);

  diff  = max (3 * hbox / 2, hbox + 2 * EDIT_FRAME + 2);        /* min 2 distance to next field */
  diff  = (diff + 1) & 0xFFFE;                                  /* use only even numbers */
  r->y += diff + hbox * (h - 1);

  type  = MT_OUTLINED;
  if (h > 1) type = MT_OUTLINED;
  flags = MF_STDLABEL;
  if ((font == FONT_SYSTEM) && (point == gl_point) && (wchar == gl_wchar)) flags |= MF_SYSTEMFONT;

  if ((table == SYS_QUERY) && (field == QUERY_TEXT)) flags |= MF_WORDBREAK;

  strcpy (table_name, table_info.name);
  strcpy (field_name, field_info.name);
  strcpy (label_name, "");

  mfield.class      = M_FIELD;
  mfield.x          = x * M_XUNITS / gl_wbox;
  mfield.y          = y * M_YUNITS / gl_hbox;
  mfield.w          = w;
  mfield.h          = h;
  mfield.table_name = FAILURE;      /* will be set in add_mskobject */
  mfield.field_name = FAILURE;      /* will be set in add_mskobject */
  mfield.label_name = FAILURE;      /* will be set in add_mskobject */
  mfield.font       = font;
  mfield.point      = point;
  mfield.color      = BLACK;
  mfield.lower      = lower;
  mfield.upper      = upper;
  mfield.type       = type;
  mfield.extra      = FAILURE;
  mfield.flags      = flags;

  return (add_mskobject (sysmask, &mfield, table_name, field_name, label_name, field - 1, strinx));
} /* addfield */

/*****************************************************************************/

LOCAL WORD add_mskobject (sysmask, mfield, s1, s2, s3, field, strinx)
SYSMASK *sysmask;
MFIELD  *mfield;
BYTE    *s1;
BYTE    *s2;
BYTE    *s3;
WORD    *strinx;
WORD    field;

{
  WORD    size;
  MOBJECT *buffer, *mobject;

  size    = sizeof (MOBJECT);
  mobject = (MOBJECT *)mfield;

  if (s1 != NULL) size += strlen (s1) + 1;      /* EOS */
  if (s2 != NULL) size += strlen (s2) + 1;      /* EOS */
  if (s3 != NULL) size += strlen (s3) + 1;      /* EOS */
  if (*strinx + size > MAX_MASK) return (ERR_NOOBJECTS);

  switch (mfield->class)
  {
    case M_FIELD : mfield->table_name = *strinx;
                   strcpy (&sysmask->mask.buffer [*strinx], s1);
                   *strinx += strlen (s1) + 1;

                   mfield->field_name = *strinx;
                   strcpy (&sysmask->mask.buffer [*strinx], s2);
                   *strinx += strlen (s2) + 1;

                   mfield->label_name = *strinx;
                   strcpy (&sysmask->mask.buffer [*strinx], s3);
                   *strinx += strlen (s3) + 1;
                   break;
    default      : return (ERR_UNKNOWNOBJ);
  } /* switch */

  m_snap_obj (NULL, mobject, M_XUNITS, M_YUNITS / 2);
  buffer = (MOBJECT *)sysmask->mask.buffer;
  buffer [field] = *mobject;

  return (SUCCESS);
} /* add_mskobject */

/*****************************************************************************/

LOCAL VOID ins_def_tattr (base_spec, tables, tattrs)
BASE_SPEC *base_spec;
WORD      tables;
WORD      tattrs;

{
  WORD     x, y, width, height, max_h;
  WORD     table, status;
  BOOLEAN  ok;
  SYSTATTR tattr;

  x     = 2;                                    /* leave two characters at left edge */
  y     = 1;                                    /* leave one character at top */
  max_h = 0;
  ok    = TRUE;

  for (table = tattrs; ok && (table < tables); table++)
  {
    get_tblwh (base_spec, table, &width, &height);

    tattr.address = 0;
    tattr.table   = table;
    tattr.x       = x;                          /* coordinates are in wbox/hbox units */
    tattr.y       = y;                          /* leave one character at top */
    tattr.width   = width;
    tattr.height  = height;
    tattr.flags   = 0;

    ok    = db_insert (base_spec->base, SYS_TATTR, &tattr, &status);
    max_h = max (max_h, height + 1);
    x    += width + 2;

    dbtest (base_spec->base);

    if ((table + 1) % 10 == 0)                  /* max 10 tables per line */
    {
      y    += max_h;
      x     = 2;
      max_h = 0;
    } /* if */
  } /* for */
} /* ins_def_tattr */

/*****************************************************************************/

LOCAL VOID ins_def_format (base_spec, into_base)
BASE_SPEC *base_spec;
BOOLEAN   into_base;

{
  WORD      i, status;
  BOOLEAN   ok;
  STRING    format;
  SYSFORMAT sysformat, *formatp;

  ok      = TRUE;
  formatp = base_spec->sysformat;

  for (i = 0; ok && (i < NUM_TYPES); i++, formatp++)
  {
    strcpy (format, get_str (stdforma, STDSTRIN + i + 1));
    format [MAX_FORMATSTR - 1] = EOS;
    if (strcmp (format, "NULL") == 0) format [0] = EOS;

    sysformat.address = 0;
    sysformat.number  = i;
    sysformat.type    = i;
    sysformat.flags   = 0;
    strcpy (sysformat.format, format);

    if (into_base)
    {
      ok = db_insert (base_spec->base, SYS_FORMAT, &sysformat, &status);
      dbtest (base_spec->base);
    } /* if */
    else
    {
      sysformat.flags |= INS_FLAG;
      *formatp = sysformat;
    } /* else */
  } /* for */
} /* ins_def_format */

/*****************************************************************************/

LOCAL BOOLEAN del_trash (base)
BASE *base;

{
  BOOLEAN ok;
  WORD    status;
  LONG    address;
  CURSOR  *cursor;

  cursor = db_newcursor (base);
  dbtest (base);

  ok = cursor != NULL;

  if (ok)
  {
    if (db_initcursor (base, SYS_DELETED, 0, ASCENDING, cursor))
      while (ok && db_movecursor (base, cursor, 1L))
      {
        if ((address = db_readcursor (base, cursor, NULL)) != 0)
        {
          if (db_reclock (base, address)) ok = db_delete (base, SYS_DELETED, address, &status);
          dbtest (base);
        } /* if */

        dbtest (base);
      } /* while */

    db_freecursor (base, cursor);
  } /* if */

  return (ok);
} /* del_trash */

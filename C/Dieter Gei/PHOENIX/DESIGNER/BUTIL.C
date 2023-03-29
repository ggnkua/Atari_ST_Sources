/*****************************************************************************/
/*                                                                           */
/* Modul: BUTIL.C                                                            */
/* Datum: 08/04/93                                                           */
/*                                                                           */
/*****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "dialog.h"

#include "export.h"
#include "butil.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID del_acc_table _((BASE_SPEC *base_spec, WORD table));
LOCAL VOID del_acc_field _((BASE_SPEC *base_spec, WORD table, WORD field));

/*****************************************************************************/

GLOBAL BOOLEAN is_tunique (base_spec, name)
BASE_SPEC *base_spec;
TABLENAME name;

{
  TABLE_INFO table_info;

  strcpy (table_info.name, name);       /* search for unique name */
  return (v_tableinfo (base_spec, FAILURE, &table_info) == FAILURE);
} /* is_tunique */

/*****************************************************************************/

GLOBAL BOOLEAN is_funique (base_spec, table, name)
BASE_SPEC *base_spec;
WORD      table;
TABLENAME name;

{
  FIELD_INFO field_info;

  strcpy (field_info.name, name);       /* search for unique name */
  return (v_fieldinfo (base_spec, table, FAILURE, &field_info) == FAILURE);
} /* is_funique */

/*****************************************************************************/

GLOBAL BOOLEAN is_kunique (base_spec, table, name)
BASE_SPEC *base_spec;
WORD      table;
TABLENAME name;

{
  INDEX_INFO index_info;

  strcpy (index_info.name, name);       /* search for unique name */
  return (v_indexinfo (base_spec, table, FAILURE, &index_info) == FAILURE);
} /* is_kunique */

/*****************************************************************************/

GLOBAL BOOLEAN check_table (base_spec, amount)
BASE_SPEC *base_spec;
WORD      amount;

{
  return (base_spec->num_tables + amount <= base_spec->max_tables);
} /* check_table */

/*****************************************************************************/

GLOBAL BOOLEAN check_field (base_spec, amount)
BASE_SPEC *base_spec;
WORD      amount;

{
  return (base_spec->num_columns + amount <= base_spec->max_columns);
} /* check_field */

/*****************************************************************************/

GLOBAL BOOLEAN check_key (base_spec, amount)
BASE_SPEC *base_spec;
WORD      amount;

{
  return (base_spec->num_indexes + amount <= base_spec->max_indexes);
} /* check_key */

/*****************************************************************************/

GLOBAL BOOLEAN check_icon (base_spec, amount)
BASE_SPEC *base_spec;
WORD      amount;

{
  return (base_spec->num_icons + amount <= base_spec->max_icons);
} /* check_icon */

/*****************************************************************************/

GLOBAL BOOLEAN check_lookup (base_spec, amount)
BASE_SPEC *base_spec;
WORD      amount;

{
  return (base_spec->num_lookups + amount <= base_spec->max_lookups);
} /* check_rel */

/*****************************************************************************/

GLOBAL WORD check_all (base_spec, tables, fields, keys)
BASE_SPEC *base_spec;
WORD      tables;
WORD      fields;
WORD      keys;

{
  if (! check_table (base_spec, tables)) return (ERR_ADD_TBL);
  if (! check_field (base_spec, fields)) return (ERR_ADD_COL);
  if (! check_key   (base_spec, keys))   return (ERR_ADD_INX);

  return (SUCCESS);
} /* check_all */

/*****************************************************************************/

GLOBAL WORD add_table (base_spec, name, flags)
BASE_SPEC *base_spec;
TABLENAME name;
UWORD     flags;

{
  WORD      table;
  SYSTABLE  *systable;
  SYSTATTR  *systattr;
  SYSCOLUMN new_column;
  SYSINDEX  new_index;

  table = ERR_ADD_TBL;

  if (check_all (base_spec, 1, 1, 1) == SUCCESS)
  {
    base_spec->num_tattrs++;
    table     = base_spec->num_tables++;
    systable  = &base_spec->systable [table];
    systattr  = &base_spec->systattr [table];
    flags    &= ~DESIGNER_FLAGS;

    memset (systable, 0, sizeof (SYSTABLE));
    strcpy (systable->name, name);
    systable->table = table;
    systable->color = BLACK;
    systable->flags = GRANT_ALL | INS_FLAG | flags;

    systattr->address = 0;
    systattr->table   = table;
    systattr->flags   = INS_FLAG;

    fill_sysptr (base_spec);

    strcpy (new_column.name, "DbAddress");	/* add field "DbAddress" */
    new_column.type   = TYPE_DBADDRESS;
    new_column.size   = sizeof (LONG);
    new_column.format = TYPE_DBADDRESS;
    new_column.flags  = GRANT_ALL | COL_ISINDEX;

    strcpy (new_index.name, FREETXT (FSEQUENT));
    new_index.type                 = TYPE_DBADDRESS;
    new_index.flags                = 0;
    new_index.inxcols.cols [0].len = 0;

    add_field (base_spec, table, &new_column, &new_index);

    base_spec->modified = TRUE;
  } /* if */

  return (table);
} /* add_table */

/*****************************************************************************/

GLOBAL WORD add_field (base_spec, table, new_column, new_index)
BASE_SPEC *base_spec;
WORD      table;
SYSCOLUMN *new_column;
SYSINDEX  *new_index;

{
  WORD      number;
  WORD      abs_col;
  UWORD     flags;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;

  number   = ERR_ADD_COL;
  systable = &base_spec->systable [table];
  flags    = new_column->flags & ~ DESIGNER_FLAGS;

#if MSDOS
  if (systable->size + new_column->size > 65535L) return (ERR_ADD_COL);
#endif

  if (check_field (base_spec, 1))
  {
    if (flags & COL_ISINDEX)
    {
      new_index->inxcols.size         = 1 * sizeof (INXCOL);    /* single key field */
      new_index->inxcols.cols [0].col = systable->cols;
      number = add_key (base_spec, table, new_index);
      if (number < 0) return (number);
    } /* if */

    number    = systable->cols;
    abs_col   = abscol (base_spec, table, number);
    syscolumn = &base_spec->syscolumn [abs_col];

    mem_lmove (syscolumn + 1, syscolumn, (LONG)sizeof (SYSCOLUMN) * (base_spec->num_columns - abs_col));
    base_spec->num_columns++;
    systable->cols++;

    strcpy (syscolumn->name, new_column->name);
    syscolumn->address = 0;
    syscolumn->table   = table;
    syscolumn->number  = number;
    syscolumn->type    = new_column->type;
    syscolumn->addr    = systable->size;
    syscolumn->size    = new_column->size;
    syscolumn->format  = new_column->format;
    syscolumn->flags   = flags | INS_FLAG;

    fill_sysptr (base_spec);

    set_coladr (base_spec, table);
    base_spec->modified = TRUE;
  } /* if */

  return (number);
} /* add_field */

/*****************************************************************************/

GLOBAL WORD add_key (base_spec, table, new_index)
BASE_SPEC *base_spec;
WORD      table;
SYSINDEX  *new_index;

{
  WORD     number;
  WORD     key;
  UWORD    flags;
  SYSTABLE *systable;
  SYSINDEX *sysindex;

  number = ERR_ADD_INX;
  flags  = new_index->flags & ~ DESIGNER_FLAGS;

  if (check_key (base_spec, 1))
  {
    systable = &base_spec->systable [table];
    number   = systable->indexes;
    key      = absinx (base_spec, table, systable->indexes);
    sysindex = &base_spec->sysindex [key];

    mem_lmove (sysindex + 1, sysindex, (LONG)sizeof (SYSINDEX) * (base_spec->num_indexes - key));
    base_spec->num_indexes++;
    systable->indexes++;
    systable->flags |= UPD_FLAG;

    strcpy (sysindex->name, new_index->name);
    sysindex->address  = 0;
    sysindex->table    = table;
    sysindex->number   = number;
    sysindex->type     = new_index->type;
    sysindex->root     = 0;
    sysindex->num_keys = 0;
    sysindex->flags    = flags | INS_FLAG;

    mem_move (&sysindex->inxcols, &new_index->inxcols, sizeof (INXCOLS));

    fill_sysptr (base_spec);

    base_spec->modified = TRUE;
  } /* if */

  return (number);
} /* add_key */

/*****************************************************************************/

GLOBAL WORD add_icon (base_spec, pmask, pdata, width, height)
BASE_SPEC *base_spec;
WORD      *pmask;
WORD      *pdata;
WORD      width;
WORD      height;

{
  WORD    number;
  WORD    words;
  SYSICON *sysicon;

  number = ERR_ADD_ICN;

  if (check_icon (base_spec, 1))
  {
    sysicon = &base_spec->sysicon [base_spec->num_icons];
    number  = base_spec->num_icons++;
    words   = (width + 15) / 16 * height;

    sysicon->address = 0;
    sysicon->number  = number;
    sysicon->width   = width;
    sysicon->height  = height;
    sysicon->flags   = INS_FLAG;

    sysicon->icon.size = words * 4;       /* data & mask in bytes */
    mem_move (&sysicon->icon.icondef [0],     pmask, words * 2);
    mem_move (&sysicon->icon.icondef [words], pdata, words * 2);

    base_spec->modified = TRUE;
  } /* if */

  return (number);
} /* add_icon */

/*****************************************************************************/

GLOBAL WORD add_lookup (base_spec, reftable, refcolumn, table, column, flags)
BASE_SPEC *base_spec;
WORD      reftable, refcolumn;
WORD      table, column;
UWORD     flags;

{
  WORD      number;
  SYSLOOKUP *syslookup;

  number  = ERR_ADD_LUR;
  flags  &= ~ DESIGNER_FLAGS;

  if (check_lookup (base_spec, 1))
  {
    syslookup = &base_spec->syslookup [base_spec->num_lookups];
    number    = base_spec->num_lookups++;

    syslookup->table     = table;
    syslookup->column    = column;
    syslookup->reftable  = reftable;
    syslookup->refcolumn = refcolumn;
    syslookup->flags     = flags | INS_FLAG;

    base_spec->modified = TRUE;
  } /* if */

  return (number);
} /* add_lookup */

/*****************************************************************************/

GLOBAL WORD del_table (base_spec, table)
BASE_SPEC *base_spec;
WORD      table;

{
  WORD      i;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;
  SYSINDEX  *sysindex;
  SYSREL    *sysrel;
  SYSTATTR  *systattr;
  SYSLOOKUP *syslookup;

  systable = &base_spec->systable [table + 1];

  for (i = table + 1; i < base_spec->num_tables; i++, systable++)       /* all following tables must be empty */
    if (systable->recs > 0) return (ERR_DEL_TBL);

  systable = &base_spec->systable [table];
  systattr = &base_spec->systattr [table];

  if (systable->flags & (INS_FLAG | MOD_FLAG))
  {
    /* delete indexes and columns backwards */
    while (systable->indexes > 0) del_key (base_spec, table, systable->indexes - 1);
    while (systable->cols > 0) del_field (base_spec, table, systable->cols - 1);

    del_acc_table (base_spec, table);

    sysrel = base_spec->sysrel;
    for (i = 0; i < base_spec->num_rels; i++, sysrel++)
      if ((sysrel->reftable == table) || (sysrel->reltable == table)) del_rel (base_spec, i);

    syslookup = base_spec->syslookup;
    for (i = 0; i < base_spec->num_lookups; i++, syslookup++)
      if ((syslookup->table == table) || (syslookup->reftable == table)) del_lookup (base_spec, i);

    if (systable->flags & MOD_FLAG)
    {
      if (base_spec->delptr  + 1 == MAX_DEL) return (ERR_DEL_TBL);

      base_spec->del_trash = TRUE;

      base_spec->delobjs [base_spec->delptr].table   = SYS_TABLE;
      base_spec->delobjs [base_spec->delptr].address = systable->address;
      base_spec->delptr++;

      base_spec->delobjs [base_spec->delptr].table   = SYS_TATTR;
      base_spec->delobjs [base_spec->delptr].address = systattr->address;
      base_spec->delptr++;
    } /* if */

    base_spec->num_tables--;
    base_spec->num_tattrs--;
    mem_lmove (systable, systable + 1, (LONG)sizeof (SYSTABLE) * (base_spec->num_tables - table));
    mem_lmove (systattr, systattr + 1, (LONG)sizeof (SYSTATTR) * (base_spec->num_tattrs - table));

    fill_sysptr (base_spec);
    base_spec->modified = TRUE;

    systable = &base_spec->systable [table];
    systattr = &base_spec->systattr [table];

    for (i = table; i < base_spec->num_tables; i++, systable++, systattr++)
    {
      systable->table  = i;
      systable->flags |= UPD_FLAG;

      systattr->table  = i;
      systattr->flags |= UPD_FLAG;
    } /* for */

    syscolumn = base_spec->syscolumn;

    for (i = 0; i < base_spec->num_columns; i++, syscolumn++)
      if (syscolumn->table > table)
      {
        syscolumn->table--;
        syscolumn->flags |= UPD_FLAG;
      } /* if, for */

    sysindex = base_spec->sysindex;

    for (i = 0; i < base_spec->num_indexes; i++, sysindex++)
      if (sysindex->table > table)
      {
        sysindex->table--;
        sysindex->flags |= UPD_FLAG;
      } /* if, for */

    sysrel = base_spec->sysrel;

    for (i = 0; i < base_spec->num_rels; i++, sysrel++)
      if ((sysrel->insrule > 0) || (sysrel->delrule > 0) || (sysrel->updrule > 0))
      {
        if (sysrel->reftable > table) sysrel->reftable--;
        if (sysrel->reltable > table) sysrel->reltable--;
        sysrel->flags |= UPD_FLAG;
      } /* if, for */

    syslookup = base_spec->syslookup;

    for (i = 0; i < base_spec->num_lookups; i++, syslookup++)
    {
      if (syslookup->table    > table) syslookup->table--;
      if (syslookup->reftable > table) syslookup->reftable--;
      syslookup->flags |= UPD_FLAG;
    } /* if, for */

    return (SUCCESS);
  } /* if */
  else
    return (ERR_DEL_TBL);
} /* del_table */

/*****************************************************************************/

GLOBAL WORD del_field (base_spec, table, field)
BASE_SPEC *base_spec;
WORD      table;
WORD      field;

{
  WORD      abs_col, abs_inx;
  WORD      key, i, cols;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;
  SYSINDEX  *sysindex;
  SYSLOOKUP *syslookup;

  abs_col   = abscol (base_spec, table, field);
  systable  = &base_spec->systable [table];
  syscolumn = &base_spec->syscolumn [abs_col];

  if (syscolumn->flags & (INS_FLAG | MOD_FLAG))
  {
    if (syscolumn->flags & MOD_FLAG)
    {
      if (base_spec->delptr == MAX_DEL) return (ERR_DEL_COL);

      base_spec->delobjs [base_spec->delptr].table   = SYS_COLUMN;
      base_spec->delobjs [base_spec->delptr].address = syscolumn->address;
      base_spec->delptr++;
    } /* if */

    if (syscolumn->flags & COL_ISINDEX)
    {
      key = find_index (base_spec, table, field);
      if (key == FAILURE) return (ERR_DEL_INX);
      if (del_key (base_spec, table, key) != SUCCESS) return (ERR_DEL_INX);
    } /* if */

    abs_inx  = absinx (base_spec, table, systable->indexes - 1);
    sysindex = &base_spec->sysindex [abs_inx];

    for (key = systable->indexes - 1; key >= 0; key--, sysindex--)
    {
      cols = sysindex->inxcols.size / sizeof (INXCOL);

      for (i = 0; i < cols; i++)
        if (sysindex->inxcols.cols [i].col == field)            /* delete this key */
        {
          del_key (base_spec, table, key);
          break;
        } /* if */
        else
          if (sysindex->inxcols.cols [i].col > field)           /* adjust cols from indexes */
          {
            sysindex->inxcols.cols [i].col--;
            sysindex->flags |= UPD_FLAG;
          } /* else, for */
    } /* for */

    del_acc_field (base_spec, table, field);

    syslookup = base_spec->syslookup;

    for (i = 0; i < base_spec->num_lookups; i++, syslookup++)   /* delete ref & rel columns */
      if ((syslookup->table    == table) && (syslookup->column    == field) ||
          (syslookup->reftable == table) && (syslookup->refcolumn == field)) del_lookup (base_spec, i);

    syslookup = base_spec->syslookup;

    for (i = 0; i < base_spec->num_lookups; i++, syslookup++)   /* sort column numbers */
    {
      if ((syslookup->table    == table) && (syslookup->column    > field)) syslookup->column--;
      if ((syslookup->reftable == table) && (syslookup->refcolumn > field)) syslookup->refcolumn--;
      syslookup->flags |= UPD_FLAG;
    } /* if, for */

    systable->cols--;
    systable->flags |= UPD_FLAG;
    base_spec->num_columns--;
    mem_lmove (syscolumn, syscolumn + 1, (LONG)sizeof (SYSCOLUMN) * (base_spec->num_columns - abs_col));

    set_coladr (base_spec, table);
    fill_sysptr (base_spec);
    base_spec->modified = TRUE;

    return (SUCCESS);
  } /* if */
  else
    return (ERR_DEL_COL);
} /* del_field */

/*****************************************************************************/

GLOBAL WORD del_key (base_spec, table, key)
BASE_SPEC *base_spec;
WORD      table;
WORD      key;

{
  WORD      abs_inx, index;
  WORD      abs_col, col;
  WORD      button, i, multi;
  LONGSTR   s;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;
  SYSINDEX  *sysindex;
  SYSREL    *sysrel;

  abs_inx   = absinx (base_spec, table, key);
  sysindex  = &base_spec->sysindex [abs_inx];
  multi     = sysindex->inxcols.size / sizeof (INXCOL);
  col       = sysindex->inxcols.cols [0].col;
  abs_col   = abscol (base_spec, table, col);
  syscolumn = &base_spec->syscolumn [abs_col];
  systable  = &base_spec->systable [table];

  if (sysindex->num_keys > 0)
  {
    sprintf (s, alerts [ERR_WDELKEY], systable->name, sysindex->name);
    button = open_alert (s);
    if (button == 2) return (ERR_NODELINX);
  } /* if */

  if (sysindex->flags & MOD_FLAG)       /* delete index from database at save time */
  {
    if (base_spec->delptr    == MAX_DEL) return (ERR_DEL_INX);
    if (base_spec->delkeyptr == MAX_DEL) return (ERR_DEL_INX);

    if (sysindex->num_keys > 0)
    {
      base_spec->delkeys [base_spec->delkeyptr].table = table;
      base_spec->delkeys [base_spec->delkeyptr].key   = key;
      base_spec->delkeyptr++;
    } /* if */

    base_spec->delobjs [base_spec->delptr].table   = SYS_INDEX;
    base_spec->delobjs [base_spec->delptr].address = sysindex->address;
    base_spec->delptr++;
  } /* if */

  sysrel = base_spec->sysrel;

  for (i = 0; i < base_spec->num_rels; i++, sysrel++)   /* delete ref & rel indexes */
    if ((sysrel->reftable == table) && (sysrel->refindex == key) ||
        (sysrel->reltable == table) && (sysrel->relindex == key)) del_rel (base_spec, i);

  sysrel = base_spec->sysrel;

  for (i = 0; i < base_spec->num_rels; i++, sysrel++)   /* sort index numbers */
    if ((sysrel->insrule > 0) || (sysrel->delrule > 0) || (sysrel->updrule > 0))
    {
      if ((sysrel->reftable == table) && (sysrel->refindex > key)) sysrel->refindex--;
      if ((sysrel->reltable == table) && (sysrel->relindex > key)) sysrel->relindex--;
      sysrel->flags |= UPD_FLAG;
    } /* if, for */

  systable->indexes--;
  systable->flags |= UPD_FLAG;

  if (multi == 1)
  {
    syscolumn->flags &= ~ COL_ISINDEX;
    syscolumn->flags |= UPD_FLAG;
  } /* if */

  base_spec->num_indexes--;
  mem_lmove (sysindex, sysindex + 1, (LONG)sizeof (SYSINDEX) * (base_spec->num_indexes - abs_inx));

  fill_sysptr (base_spec);
  base_spec->modified = TRUE;

  abs_inx  = absinx (base_spec, table, 0);
  sysindex = &base_spec->sysindex [abs_inx];

  for (index = 0; index < systable->indexes; index++, sysindex++)
  {
    sysindex->number  = index;
    sysindex->flags  |= UPD_FLAG;
  } /* for */

  return (SUCCESS);
} /* del_key */

/*****************************************************************************/

GLOBAL WORD del_icon (base_spec, number)
BASE_SPEC *base_spec;
WORD      number;

{
  WORD     table, icon;
  SYSTABLE *systable;
  SYSICON  *sysicon;

  systable = base_spec->systable;
  sysicon  = &base_spec->sysicon [number];

  if (sysicon->flags & MOD_FLAG)        /* put into delete list */
  {
    if (base_spec->delptr == MAX_DEL) return (ERR_DEL_ICN);

    base_spec->delobjs [base_spec->delptr].table   = SYS_ICON;
    base_spec->delobjs [base_spec->delptr].address = sysicon->address;
    base_spec->delptr++;
  } /* if */

  for (table = 0; table < base_spec->num_tables; table++, systable++)
  {
    if (systable->icon == number) systable->icon = 0; /* set to standard icon */
    if (systable->icon >  number) systable->icon--;
    systable->flags |= UPD_FLAG;
  } /* for */

  base_spec->num_icons--;
  mem_lmove (sysicon, sysicon + 1, (LONG)sizeof (SYSICON) * (base_spec->num_icons - number));

  sysicon = base_spec->sysicon;
  for (icon = 0; icon < base_spec->num_icons; icon++, sysicon++)
  {
    sysicon->number  = icon;
    sysicon->flags  |= UPD_FLAG;
  } /* for */

  base_spec->modified = TRUE;

  return (SUCCESS);
} /* del_icon */

/*****************************************************************************/

GLOBAL VOID del_rel (base_spec, number)
BASE_SPEC *base_spec;
WORD      number;

{
  WORD     flags;
  WORD     ref_table, rel_table;
  SYSTABLE *reftable, *reltable;
  SYSREL   *sysrel;

  sysrel = &base_spec->sysrel [number];

  if (sysrel->flags & MOD_FLAG)
    flags = sysrel->flags | DEL_FLAG;
  else
    flags = 0;

  ref_table = sysrel->reftable;
  rel_table = sysrel->reltable;

  reftable = &base_spec->systable [ref_table];
  reltable = &base_spec->systable [rel_table];

  sysrel->reftable = -1;
  sysrel->refindex = -1;
  sysrel->reltable = -1;
  sysrel->relindex = -1;
  sysrel->insrule  = 0;
  sysrel->delrule  = 0;
  sysrel->updrule  = 0;
  sysrel->flags    = flags;

  reftable->children--;
  reltable->parents--;

  reftable->flags |= UPD_FLAG;
  reltable->flags |= UPD_FLAG;

  base_spec->modified = TRUE;
} /* del_rel */

/*****************************************************************************/

GLOBAL VOID del_lookup (base_spec, number)
BASE_SPEC *base_spec;
WORD      number;

{
  WORD      flags;
  SYSLOOKUP *syslookup;

  syslookup = &base_spec->syslookup [number];

  if (syslookup->flags & MOD_FLAG)
    flags = syslookup->flags | DEL_FLAG;
  else
    flags = 0;

  syslookup->table     = -1;
  syslookup->column    = -1;
  syslookup->reftable  = -1;
  syslookup->refcolumn = -1;
  syslookup->flags     = flags;

  base_spec->modified = TRUE;
} /* del_lookup */

/*****************************************************************************/

GLOBAL BOOLEAN move_field (base_spec, table, src, dst)
BASE_SPEC *base_spec;
WORD      table;
WORD      src;
WORD      dst;

{
  WORD      abs_col;
/*  SYSTABLE  *systable;*/
  SYSCOLUMN *src_column, *dst_column;

  if ((table == FAILURE) || (src == FAILURE) || (dst == FAILURE)) return (FALSE);

/*  systable   = &base_spec->systable [table];*/
  abs_col    = abscol (base_spec, table, src);
  src_column = &base_spec->syscolumn [abs_col];
  abs_col    = abscol (base_spec, table, dst);
  dst_column = &base_spec->syscolumn [abs_col];

  if (! (src_column->flags & (INS_FLAG | MOD_FLAG))) return (FALSE);
  if (! (dst_column->flags & (INS_FLAG | MOD_FLAG))) return (FALSE);

  /*syscolumn, sysindex(wo key vorkommt), sysrel(if index), syslookup „ndern */

  return (FALSE);
} /* move_field */

/*****************************************************************************/

GLOBAL BOOLEAN move_key (base_spec, table, src, dst)
BASE_SPEC *base_spec;
WORD      table;
WORD      src;
WORD      dst;

{
  if ((table == FAILURE) || (src == FAILURE) || (dst == FAILURE)) return (FALSE);

  return (FALSE);
} /* move_key */

/*****************************************************************************/

GLOBAL VOID set_coladr (base_spec, table)
BASE_SPEC *base_spec;
WORD      table;

{
  WORD      i, abs_col;
  LONG      addr;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;

  abs_col          = abscol (base_spec, table, 0);
  systable         = &base_spec->systable [table];
  syscolumn        = &base_spec->syscolumn [abs_col];
  systable->size   = 0;
  systable->flags |= UPD_FLAG;

  for (i = 0; i < systable->cols; i++, syscolumn++)   /* adjust column numbers & addresses */
  {
    addr = systable->size;

    if (unixdb)
      if ((syscolumn->type != TYPE_CHAR) &&
          (syscolumn->type != TYPE_WORD) &&
          (syscolumn->type != TYPE_EXTERN)) addr = ((addr + 3) / 4) * 4;

    syscolumn->number = i;
    syscolumn->addr   = addr;
    systable->size    = syscolumn->addr + syscolumn->size + odd (syscolumn->size);
    syscolumn->flags |= UPD_FLAG;
  } /* for */
} /* set_coladr */

/*****************************************************************************/

LOCAL VOID del_acc_table (base_spec, table)
BASE_SPEC *base_spec;
WORD      table;

{
  WORD    user, diff;
  WORD    size;
  WORD    *listp, *srcp;
  SYSUSER *sysuser;

  sysuser = base_spec->sysuser;

  for (user = 0; user < base_spec->num_users; user++, sysuser++)
  {
    size  = sysuser->access.size / sizeof (WORD);
    listp = sysuser->access.list;

    if (size == 0) continue;

    while ((*listp != table) && (size > 0))                     /* search table */
    {
      while (*listp != -1)                                      /* skip table & field access */
      {
        listp += 2;
        size  -= 2;
      } /* while */

      listp++;
      size--;
    } /* while */

    if (*listp == table)
    {
      diff = 0;
      srcp = listp;

      while (*srcp != -1)                                       /* skip table & field access */
      {
        srcp += 2;
        size -= 2;
        diff += 2;
      } /* while */

      srcp++;
      size--;
      diff++;

      mem_move (listp, srcp, size * sizeof (WORD));

      while (size > 0)
      {
        *listp -= 1;                                            /* decrement all other table numbers */

        while (*listp != -1)                                    /* skip table & field access */
        {
          listp += 2;
          size  -= 2;
        } /* while */

        listp++;
        size--;
      } /* while */

      sysuser->access.size -= diff * sizeof (WORD);
      sysuser->flags       |= UPD_FLAG;
    } /* if */
  } /* for */
} /* del_acc_table */

/*****************************************************************************/

LOCAL VOID del_acc_field (base_spec, table, field)
BASE_SPEC *base_spec;
WORD      table;
WORD      field;

{
  WORD    user;
  WORD    size;
  WORD    *listp;
  SYSUSER *sysuser;

  sysuser = base_spec->sysuser;

  for (user = 0; user < base_spec->num_users; user++, sysuser++)
  {
    size  = sysuser->access.size / sizeof (WORD);
    listp = sysuser->access.list;

    if (size == 0) continue;

    while ((*listp != table) && (size > 0))                     /* search table */
    {
      while (*listp != -1)                                      /* skip table & field access */
      {
        listp += 2;
        size  -= 2;
      } /* while */

      listp++;
      size--;
    } /* while */

    if ((*listp == table) && (size > 0))
    {
      listp += 2;
      size  -= 2;

      while ((*listp != field) && (size > 0) && (*listp != -1)) /* search field */
      {
        listp += 2;
        size  -= 2;
      } /* while */

      if (*listp == field)
      {
        size -= 2;
        mem_move (listp, listp + 2, size * sizeof (WORD));

        while (*listp != -1)
        {
          *listp -= 1;                                          /* decrement all other fields of this table */
          listp  += 2;
        } /* while */

        sysuser->access.size -= 2 * sizeof (WORD);
        sysuser->flags       |= UPD_FLAG;
      } /* if */
    } /* if */
  } /* for */
} /* del_acc_field */

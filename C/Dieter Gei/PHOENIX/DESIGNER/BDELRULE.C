/*****************************************************************************/
/*                                                                           */
/* Modul: BDELRULE.C                                                         */
/* Datum: 04/12/90                                                           */
/*                                                                           */
/*****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "butil.h"
#include "export.h"
#include "bdelrule.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN do_rules _((BASE_SPEC *base_spec, WORD class, SET objs, BOOLEAN test_only));

/*****************************************************************************/

GLOBAL VOID mdelrules (base_spec, class, objs)
BASE_SPEC *base_spec;
WORD      class;
SET       objs;

{
  do_rules (base_spec, class, objs, FALSE);
} /* mdelrules */

/*****************************************************************************/


GLOBAL BOOLEAN mtestrules (base_spec, class, objs)
BASE_SPEC *base_spec;
WORD      class;
SET       objs;

{
  return (do_rules (base_spec, class, objs, TRUE));
} /* mdelrules */

/*****************************************************************************/

LOCAL BOOLEAN do_rules (base_spec, class, objs, test_only)
BASE_SPEC *base_spec;
WORD      class;
SET       objs;
BOOLEAN   test_only;

{
  WORD      table, key;
  WORD      abs_col;
  WORD      i, rule;
  WORD      end;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;
  SYSREL    *sysrel;
  SYSLOOKUP *syslookup;

  table    = sel.table;
  systable = &base_spec->systable [table];

  switch (class)
  {
    case SEL_TABLE : end = base_spec->num_tables; break;
    case SEL_FIELD : end = systable->cols;        break;
    case SEL_KEY   : end = systable->indexes;     break;
    default        : end = NIL;                   break;
  } /* switch */

  if (base_spec->show_rels)
  {
    for (i = end - 1; i >= 0; i--)
      if (setin (objs, i))
      {
        switch (class)
        {
          case SEL_TABLE : sysrel = base_spec->sysrel;
                           for (rule = 0; rule < base_spec->num_rels; rule++, sysrel++)
                             if ((sysrel->reftable == i) || (sysrel->reltable == i))
                             {
                               if (test_only) return (TRUE);
                               del_rel (base_spec, rule);
                             } /* if, for */
                           break;
          case SEL_FIELD : sysrel    = base_spec->sysrel;
                           abs_col   = abscol (base_spec, table, i);
                           syscolumn = &base_spec->syscolumn [abs_col];

                           if (syscolumn->flags & COL_ISINDEX)
                           {
                             key = find_index (base_spec, table, i);

                             for (rule = 0; rule < base_spec->num_rels; rule++, sysrel++)
                               if ((sysrel->reftable == table) && (sysrel->refindex == key) ||
                                   (sysrel->reltable == table) && (sysrel->relindex == key))
                               {
                                 if (test_only) return (TRUE);
                                 del_rel (base_spec, rule);
                               } /* if, for */
                           } /* if */
                           break;
          case SEL_KEY   : sysrel = base_spec->sysrel;
                           key    = find_multikey (base_spec, table, i);

                           for (rule = 0; rule < base_spec->num_rels; rule++, sysrel++)
                             if ((sysrel->reftable == table) && (sysrel->refindex == key) ||
                                 (sysrel->reltable == table) && (sysrel->relindex == key))
                             {
                               if (test_only) return (TRUE);
                               del_rel (base_spec, rule);
                             } /* if, for */
                           break;
        } /* switch */
      } /* if, for */
  } /* if */
  else                  /* lookup rules are shown */
  {
    for (i = end - 1; i >= 0; i--)
      if (setin (objs, i))
      {
        switch (class)
        {
          case SEL_TABLE : syslookup = base_spec->syslookup;
                           for (rule = 0; rule < base_spec->num_lookups; rule++, syslookup++)
                             if ((syslookup->table == i) || (syslookup->reftable == i))
                             {
                               if (test_only) return (TRUE);
                               del_lookup (base_spec, rule);
                             } /* if, for */
                           break;
          case SEL_FIELD : syslookup = base_spec->syslookup;
                           abs_col   = abscol (base_spec, table, i);
                           syscolumn = &base_spec->syscolumn [abs_col];

                           for (rule = 0; rule < base_spec->num_lookups; rule++, syslookup++)
                             if ((syslookup->table    == table) && (syslookup->column    == i) ||
                                 (syslookup->reftable == table) && (syslookup->refcolumn == i))
                             {
                               if (test_only) return (TRUE);
                               del_lookup (base_spec, rule);
                             } /* if, for */
                           break;
        } /* switch */
      } /* if, for */
  } /* else */

  return (FALSE);
} /* do_rules */

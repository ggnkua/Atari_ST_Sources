/*****************************************************************************
 *
 * Module : BRULES.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 29.09.94
 *
 *
 * Description: This module implements the base rules dialog box.
 *
 * History:
 * 29.09.94: REL_11, REL_1N handling added
 * 15.09.94: OK button is always enabled
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

#include "export.h"
#include "brules.h"

/****** DEFINES **************************************************************/

#define MAX_TITLE 50    /* max length of title in resource */

/****** TYPES ****************************************************************/

typedef struct
{
  WINDOWP base_window;
  WORD    relinx;
  WORD    ins_rule, del_rule, upd_rule;
  WORD    ref_table, ref_index;
  WORD    rel_table, rel_index;
} REL_SPEC;

/****** VARIABLES ************************************************************/

LOCAL REL_SPEC rel_spec;

/****** FUNCTIONS ************************************************************/

LOCAL VOID    set_rules     _((REL_SPEC *rel_spec));
LOCAL VOID    click_rules   _((WINDOWP window, MKINFO *mk));

LOCAL WORD    find_rule     _((BASE_SPEC *base_spec, WORD ref_table, WORD ref_index, WORD rel_table, WORD rel_index, WORD *ins_rule, WORD *del_rule, WORD *upd_rule));
LOCAL BOOLEAN check_rel     _((BASE_SPEC *base_spec, WORD amount));
LOCAL BOOLEAN hndl_rule     _((BASE_SPEC *base_spec, WORD rule, WORD ref_table, WORD ref_index, WORD rel_table, WORD rel_index, WORD ins_rule, WORD del_rule, WORD upd_rule, UWORD flags));

/*****************************************************************************/

GLOBAL VOID b_rules (base_window, ref_table, ref_index, rel_table, rel_index)
WINDOWP base_window;
WORD    ref_table, ref_index;
WORD    rel_table, rel_index;

{
  WORD     ret;
  WINDOWP  window;

  window = search_window (CLASS_DIALOG, SRCH_ANY, RELRULES);

  if (window == NULL)
  {
    form_center (relrules, &ret, &ret, &ret, &ret);
    window = crt_dialog (relrules, NULL, RELRULES, FREETXT (FDELRULE), WI_MODAL);

    if (window != NULL)
    {
      window->click   = click_rules;
      window->special = (LONG)&rel_spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (relrules, ROOT, EDITABLE);
      window->edit_inx = NIL;

      rel_spec.base_window = base_window;
      rel_spec.relinx      = FAILURE;
      rel_spec.ins_rule    = REL_NONE;
      rel_spec.del_rule    = REL_NONE;
      rel_spec.upd_rule    = REL_NONE;
      rel_spec.ref_table   = ref_table;
      rel_spec.ref_index   = ref_index;
      rel_spec.rel_table   = rel_table;
      rel_spec.rel_index   = rel_index;

      set_rules (&rel_spec);
    } /* if */

    if (! open_dialog (RELRULES)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* b_rules */

/*****************************************************************************/

LOCAL VOID set_rules (rel_spec)
REL_SPEC *rel_spec;

{
  WORD      relinx, rel_type;
  WORD      ins_rule, del_rule, upd_rule;
  WORD      ref_table, ref_index;
  WORD      rel_table, rel_index;
  WORD      abs_ref, abs_rel;
  LONGSTR   title;
  SYSINDEX  *ref, *rel;
  SYSREL    *sysrel;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)rel_spec->base_window->special;

  ref_table = rel_spec->ref_table;
  ref_index = rel_spec->ref_index;
  rel_table = rel_spec->rel_table;
  rel_index = rel_spec->rel_index;
  rel_type  = R1N;

  relinx = find_rule (base_spec, ref_table, ref_index, rel_table, rel_index, &ins_rule, &del_rule, &upd_rule);

  if (relinx == FAILURE)
  {
    ins_rule = REL_NONE;
    del_rule = REL_NONE;
    upd_rule = REL_NONE;

    do_state (relrules, RDELETE, DISABLED);
  } /* if */
  else
  {
    sysrel = &base_spec->sysrel [relinx];
    if (sysrel->flags & REL_11) rel_type = R11;

    undo_state (relrules, RDELETE, DISABLED);
  } /* else */

  rel_spec->relinx   = relinx;
  rel_spec->ins_rule = ins_rule;
  rel_spec->del_rule = del_rule;
  rel_spec->upd_rule = upd_rule;

  abs_ref = absinx (base_spec, ref_table, ref_index);
  abs_rel = absinx (base_spec, rel_table, rel_index);

  ref = &base_spec->sysindex [abs_ref];
  rel = &base_spec->sysindex [abs_rel];

  sprintf (title, "%s.%s -> %s.%s",
           base_spec->systable [ref_table].name,
           ref->name,
           base_spec->systable [rel_table].name,
           rel->name);

  title [MAX_TITLE] = EOS;
  strcpy (get_str (relrules, RREF), title);

  switch (ins_rule)
  {
    case REL_NONE       : ins_rule = RINONE;   break;
    case REL_RESTRICTED : ins_rule = RIRESTRI; break;
  } /* switch */

  switch (del_rule)
  {
    case REL_NONE       : del_rule = RDNONE;   break;
    case REL_RESTRICTED : del_rule = RDRESTRI; break;
    case REL_CASCADED   : del_rule = RDCASCAD; break;
    case REL_SETNULL    : del_rule = RDSETNUL; break;
  } /* switch */

  switch (upd_rule)
  {
    case REL_NONE       : upd_rule = RUNONE;   break;
    case REL_RESTRICTED : upd_rule = RURESTRI; break;
    case REL_CASCADED   : upd_rule = RUCASCAD; break;
    case REL_SETNULL    : upd_rule = RUSETNUL; break;
  } /* switch */

  set_rbutton (relrules, ins_rule, RINONE, RIRESTRI);
  set_rbutton (relrules, del_rule, RDNONE, RDSETNUL);
  set_rbutton (relrules, upd_rule, RUNONE, RUSETNUL);
  set_rbutton (relrules, rel_type, R11, R1N);
} /* set_rules */

/*****************************************************************************/

LOCAL VOID click_rules (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      ins_rule, del_rule, upd_rule;
  UWORD     flags;
  REL_SPEC  *rel_spec;
  SYSREL    *sysrel;
  BASE_SPEC *base_spec;

  rel_spec  = (REL_SPEC *)window->special;
  base_spec = (BASE_SPEC *)rel_spec->base_window->special;

  switch (get_rbutton (relrules, RINONE))
  {
    case RINONE   : ins_rule = REL_NONE;       break;
    case RIRESTRI : ins_rule = REL_RESTRICTED; break;
  } /* switch */

  switch (get_rbutton (relrules, RDNONE))
  {
    case RDNONE   : del_rule = REL_NONE;       break;
    case RDRESTRI : del_rule = REL_RESTRICTED; break;
    case RDCASCAD : del_rule = REL_CASCADED;   break;
    case RDSETNUL : del_rule = REL_SETNULL;    break;
  } /* switch */

  switch (get_rbutton (relrules, RUNONE))
  {
    case RUNONE   : upd_rule = REL_NONE;       break;
    case RURESTRI : upd_rule = REL_RESTRICTED; break;
    case RUCASCAD : upd_rule = REL_CASCADED;   break;
    case RUSETNUL : upd_rule = REL_SETNULL;    break;
  } /* switch */

  switch (get_rbutton (relrules, R11))
  {
    case R11 : flags = REL_11; break;
    case R1N : flags = REL_1N; break;
  } /* switch */

  switch (window->exit_obj)
  {
    case ROK     : if (rel_spec->relinx == FAILURE)
                      flags |= INS_FLAG;
                   else
                   {
                     sysrel  = &base_spec->sysrel [rel_spec->relinx];
                     flags  |= sysrel->flags & ~ (REL_11 | REL_1N);
                     flags  |= UPD_FLAG;
                   } /* else */

                   if (! hndl_rule (base_spec,
                                    rel_spec->relinx,
                                    rel_spec->ref_table,
                                    rel_spec->ref_index,
                                    rel_spec->rel_table,
                                    rel_spec->rel_index,
                                    ins_rule, del_rule, upd_rule, flags)) hndl_alert (ERR_NORULES);

                   set_redraw (rel_spec->base_window, &rel_spec->base_window->scroll);
                   break;
    case RDELETE : if (rel_spec->relinx != FAILURE)
                   {
                     sysrel = &base_spec->sysrel [rel_spec->relinx];

                     if (sysrel->flags & MOD_FLAG)
                       flags = sysrel->flags | DEL_FLAG;
                     else
                       flags = 0;

                     if (! hndl_rule (base_spec,
                                      rel_spec->relinx,
                                      rel_spec->ref_table,
                                      rel_spec->ref_index,
                                      rel_spec->rel_table,
                                      rel_spec->rel_index,
                                      0, 0, 0, flags)) hndl_alert (ERR_NORULES);

                     set_redraw (rel_spec->base_window, &rel_spec->base_window->scroll);
                   } /* if */
                   break;
    case RHELP   : hndl_help (HRELRULE);
                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
  } /* switch */
} /* click_rules */

/*****************************************************************************/

LOCAL WORD find_rule (base_spec, ref_table, ref_index, rel_table, rel_index, ins_rule, del_rule, upd_rule)
BASE_SPEC *base_spec;
WORD      ref_table, ref_index;
WORD      rel_table, rel_index;
WORD      *ins_rule, *del_rule, *upd_rule;

{
  WORD   i;
  SYSREL *sysrel;

  sysrel = base_spec->sysrel;

  for (i = 0; i < base_spec->num_rels; i++, sysrel++)
    if (sysrel->flags & MOD_FLAG)
    {
      if (! (sysrel->flags & DEL_FLAG)    &&
          (sysrel->reftable == ref_table) &&
          (sysrel->refindex == ref_index) &&
          (sysrel->reltable == rel_table) &&
          (sysrel->relindex == rel_index))
      {
        *ins_rule = sysrel->insrule;
        *del_rule = sysrel->delrule;
        *upd_rule = sysrel->updrule;

        return (i);
      } /* if */
    } /* if */
    else
    {
      if ((sysrel->flags & INS_FLAG)      &&
          (sysrel->reftable == ref_table) &&
          (sysrel->refindex == ref_index) &&
          (sysrel->reltable == rel_table) &&
          (sysrel->relindex == rel_index))
      {
        *ins_rule = sysrel->insrule;
        *del_rule = sysrel->delrule;
        *upd_rule = sysrel->updrule;

        return (i);
      } /* if */
    } /* if */

  return (FAILURE);
} /* find_rule */

/*****************************************************************************/

LOCAL BOOLEAN check_rel (base_spec, amount)
BASE_SPEC *base_spec;
WORD      amount;

{
  return (base_spec->num_rels + amount <= base_spec->max_rels);
} /* check_rel */

/*****************************************************************************/

LOCAL BOOLEAN hndl_rule (base_spec, rule, ref_table, ref_index, rel_table, rel_index, ins_rule, del_rule, upd_rule, flags)
BASE_SPEC *base_spec;
WORD      rule;
WORD      ref_table, ref_index;
WORD      rel_table, rel_index;
WORD      ins_rule, del_rule, upd_rule;
UWORD     flags;

{
  WORD     abs_inx;
  SYSTABLE *reftable, *reltable;
  SYSINDEX *sysindex;
  SYSREL   *sysrel;

  if (check_rel (base_spec, 1) || (rule != FAILURE))
  {
    abs_inx  = absinx (base_spec, rel_table, rel_index);
    sysindex = &base_spec->sysindex [abs_inx];

    sysindex->flags |= UPD_FLAG;

    if ((flags & DEL_FLAG) || (flags == 0))
      sysindex->flags &= ~ INX_FOREIGN;
    else
      sysindex->flags |= INX_FOREIGN;

    reftable = &base_spec->systable [ref_table];
    reltable = &base_spec->systable [rel_table];

    if (rule == FAILURE)
    {
      sysrel = &base_spec->sysrel [base_spec->num_rels];
      base_spec->num_rels++;
    } /* if */
    else
      sysrel = &base_spec->sysrel [rule];

    sysrel->reftable = ref_table;
    sysrel->refindex = ref_index;
    sysrel->reltable = rel_table;
    sysrel->relindex = rel_index;
    sysrel->insrule  = ins_rule;
    sysrel->delrule  = del_rule;
    sysrel->updrule  = upd_rule;
    sysrel->flags    = flags;

    if (rule == FAILURE)
    {
      reftable->children++;
      reltable->parents++;
    } /* if */

    if ((flags & DEL_FLAG) || (flags == 0))
    {
      reftable->children--;
      reltable->parents--;
    } /* if */

    reftable->flags |= UPD_FLAG;
    reltable->flags |= UPD_FLAG;

    base_spec->modified = TRUE;

    return (TRUE);
  } /* if */

  return (FALSE);
} /* hndl_rule */


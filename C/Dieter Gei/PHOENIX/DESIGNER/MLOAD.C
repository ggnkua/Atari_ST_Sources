/*****************************************************************************
 *
 * Module : MLOAD.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 12.06.02
 *
 *
 * Description: This module implements the load/save mask functions.
 *
 * History:
 * 12.06.02: m_load_mask: Bei Linen wird nicht mehr die Koordinaten X2 (w) und
 *           Y2 (h) ver„ndert.
 * 22.03.94: A mask can now be saved without objects
 * 21.09.94: Handling of M_SUBMASK added
 * 19.08.94: MASK_VERSION set in m_save_mask
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "dialog.h"
#include "resource.h"
#include "mclick.h"

#include "export.h"
#include "mload.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

/*****************************************************************************/

GLOBAL BOOLEAN m_new_mask (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN   ok;
  LONG      size, offset;
  SYSMASK   *sysmask;
  BASE_SPEC *base_spec;

  base_spec = mask_spec->base_spec;
  sysmask   = &mask_spec->mask;

  mem_set (sysmask, 0, sizeof (SYSMASK));
  mask_spec->findex = base_spec->imask++;

  offset = mask_spec->findex * (LONG)sizeof (SYSMASK);
  ok     = file_seek (base_spec->fmask, offset, SEEK_SET) == offset;
  size   = file_write (base_spec->fmask, (LONG)sizeof (SYSMASK), sysmask);

  if (ok && (size == sizeof (SYSMASK))) return (TRUE);

  return (FALSE);
} /* m_new_mask */

/*****************************************************************************/

GLOBAL BOOLEAN m_load_mask (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN   ok;
  LONG      size, offset;
  WORD      strinx;
  WORD      diff, obj;
  WORD      *objs;
  WORD      *strsize;
  BYTE      *p;
  MFIELD    *mfield;
  MTEXT     *mtext;
  MGRAF     *mgraf;
  MBUTTON   *mbutton;
  MSUBMASK  *msubmask;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  BASE_SPEC *base_spec;

  base_spec = mask_spec->base_spec;
  sysmask   = &mask_spec->mask;
  p         = sysmask->mask.buffer;

  if (mask_spec->findex == FAILURE)
  {
    ok = db_read (base_spec->base, SYS_MASK, sysmask, 0L, sysmask->address, FALSE);
    dbtest (base_spec->base);
    if (! ok) return (FALSE);

    mask_spec->findex = base_spec->imask++;

    offset = mask_spec->findex * (LONG)sizeof (SYSMASK);
    ok     = file_seek (base_spec->fmask, offset, SEEK_SET) == offset;
    size   = file_write (base_spec->fmask, (LONG)sizeof (SYSMASK), sysmask);
  } /* if */
  else
  {
    offset = mask_spec->findex * (LONG)sizeof (SYSMASK);
    ok     = file_seek (base_spec->fmask, offset, SEEK_SET) == offset;
    size   = file_read (base_spec->fmask, (LONG)sizeof (SYSMASK), sysmask);
  } /* else */

  if (ok && (size == sizeof (SYSMASK)))
  {
    objs    = (WORD *)(p + sysmask->mask.size - sizeof (WORD));
    strsize = (WORD *)(p + sysmask->mask.size - 2 * sizeof (WORD));
    strinx  = *objs * sizeof (MOBJECT);

    mask_spec->str      = MAX_MASK - *strsize;
    mask_spec->objs     = *objs;
    mask_spec->max_objs = mask_spec->str / sizeof (MOBJECT);

    mem_move (p + mask_spec->str, p + strinx, *strsize);

    diff    = mask_spec->str - mask_spec->objs * sizeof (MOBJECT);
    mobject = (MOBJECT *)sysmask->mask.buffer;

    for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
    {
      mfield = &mobject->mfield;

			if (mfield->class != M_LINE )
			{
      	if (mfield->w <= 0) mfield->w = 8;        /* so you can grab the object with the mouse */
      	if (mfield->h <= 0) mfield->h = 8;
			}

      switch (mfield->class)
      {
        case M_FIELD   : mfield = &mobject->mfield;
                         mfield->table_name += diff;
                         mfield->field_name += diff;
                         mfield->label_name += diff;

                         if (IS_CHECKBOX (mfield->type) || IS_RBUTTON (mfield->type))
                           if (mfield->extra >= 0) mfield->extra += diff;
                         break;
        case M_TEXT    : mtext = &mobject->mtext;
                         mtext->text += diff;
                         break;
        case M_GRAF    : mgraf = &mobject->mgraf;
                         mgraf->filename += diff;
                         break;
        case M_BUTTON  : mbutton = &mobject->mbutton;
                         mbutton->text  += diff;
                         mbutton->param += diff;
                         break;
        case M_SUBMASK : msubmask = &mobject->msubmask;
                         msubmask->SourceObject += diff;
                         msubmask->LinkMaster   += diff;
                         msubmask->LinkChild    += diff;
                         break;
      } /* switch */
    } /* for */

    return (TRUE);
  } /* if */

  return (FALSE);
} /* m_load_mask */

/*****************************************************************************/

GLOBAL BOOLEAN m_save_mask (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN   ok;
  LONG      offset;
  WORD      size, index;
  WORD      diff, obj;
  WORD      obj_size;
  WORD      str_size;
  WORD      *objs;
  WORD      *sizep;
  BYTE      *s, *d;
  HLPMASK   *hlpmask;
  MFIELD    *mfield;
  MTEXT     *mtext;
  MGRAF     *mgraf;
  MBUTTON   *mbutton;
  MSUBMASK  *msubmask;
  MOBJECT   *mobject;
  SYSMASK   *sysmask, *buffer;
  BASE_SPEC *base_spec;

  if (! mask_spec->modified) return (TRUE);

  buffer = (SYSMASK *)mem_alloc ((LONG)sizeof (SYSMASK));
  if (buffer == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (FALSE);
  } /* if */

  base_spec = mask_spec->base_spec;
  sysmask   = &mask_spec->mask;
  s         = sysmask->mask.buffer;
  d         = buffer->mask.buffer;

  sysmask->version = MASK_VERSION;	/* set new version number */

  if (mask_spec->printer_mask) m_sort_mask (mask_spec);

  offset = mask_spec->findex * (LONG)sizeof (SYSMASK);
  ok     = file_seek (base_spec->fmask, offset, SEEK_SET) == offset;

  if (ok)
  {
    obj_size = mask_spec->objs * sizeof (MOBJECT);
    str_size = MAX_MASK - mask_spec->str;
    diff     = mask_spec->str - obj_size;
    mobject  = (MOBJECT *)sysmask->mask.buffer;

    for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
    {
      mfield = &mobject->mfield;

      switch (mfield->class)
      {
        case M_FIELD   : mfield = &mobject->mfield;
                         mfield->table_name -= diff;
                         mfield->field_name -= diff;
                         mfield->label_name -= diff;

                         if (IS_CHECKBOX (mfield->type) || IS_RBUTTON (mfield->type))
                           if (mfield->extra != FAILURE) mfield->extra -= diff;
                         break;
        case M_TEXT    : mtext = &mobject->mtext;
                         mtext->text -= diff;
                         break;
        case M_GRAF    : mgraf = &mobject->mgraf;
                         mgraf->filename -= diff;
                         break;
        case M_BUTTON  : mbutton = &mobject->mbutton;
                         mbutton->text  -= diff;
                         mbutton->param -= diff;
                         break;
        case M_SUBMASK : msubmask = &mobject->msubmask;
                         msubmask->SourceObject -= diff;
                         msubmask->LinkMaster   -= diff;
                         msubmask->LinkChild    -= diff;
                         break;
      } /* switch */
    } /* for */

    index = mask_spec->new ? base_spec->num_masks++ : mask_spec->mindex;
    base_spec->sysmask [index].findex = mask_spec->findex;
    base_spec->modified = TRUE;

    *buffer = *sysmask;
    mem_set (d, 0, MAX_MASK);

    mem_move (d, s, obj_size);
    mem_move (d + obj_size, s + mask_spec->str, str_size);

    size   = (obj_size + str_size + 1) & 0xFFFE;        /* must be even */
    sizep  = (WORD *)(d + size);
    objs   = (WORD *)(d + size + sizeof (WORD));
    *objs  = mask_spec->objs;
    *sizep = str_size;

    buffer->mask.size = size + 2 * sizeof (WORD);       /* 2 extra words info */
    size  = file_write (base_spec->fmask, (LONG)sizeof (SYSMASK), buffer);

    ok       = size == sizeof (SYSMASK);
    mobject  = (MOBJECT *)sysmask->mask.buffer;

    for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
    {
      mfield = &mobject->mfield;

      switch (mfield->class)
      {
        case M_FIELD   : mfield = &mobject->mfield;
                         mfield->table_name += diff;
                         mfield->field_name += diff;
                         mfield->label_name += diff;

                         if (IS_CHECKBOX (mfield->type) || IS_RBUTTON (mfield->type))
                           if (mfield->extra != FAILURE) mfield->extra += diff;
                         break;
        case M_TEXT    : mtext = &mobject->mtext;
                         mtext->text += diff;
                         break;
        case M_GRAF    : mgraf = &mobject->mgraf;
                         mgraf->filename += diff;
                         break;
        case M_BUTTON  : mbutton = &mobject->mbutton;
                         mbutton->text  += diff;
                         mbutton->param += diff;
                         break;
        case M_SUBMASK : msubmask = &mobject->msubmask;
                         msubmask->SourceObject += diff;
                         msubmask->LinkMaster   += diff;
                         msubmask->LinkChild    += diff;
                         break;
      } /* switch */
    } /* for */

    if (ok)
    {
      hlpmask = &base_spec->sysmask [index];

      if (mask_spec->new)
      {
        mem_set (hlpmask, 0, sizeof (HLPMASK));
        sysmask->flags |= INS_FLAG;
      } /* if */
      else
        sysmask->flags |= UPD_FLAG;

      strcpy (hlpmask->name, sysmask->name);
      strcpy (hlpmask->tablename, sysmask->tablename);
      strcpy (hlpmask->calcentry, sysmask->calcentry);
      strcpy (hlpmask->calcexit, sysmask->calcexit);
      hlpmask->device [0] = sysmask->device [0];
      hlpmask->findex     = mask_spec->findex;
      hlpmask->flags      = sysmask->flags;
      hlpmask->version    = sysmask->version;
      hlpmask->x          = sysmask->x;
      hlpmask->y          = sysmask->y;
      hlpmask->w          = sysmask->w;
      hlpmask->h          = sysmask->h;
      hlpmask->bkcolor    = sysmask->bkcolor;
    } /* if */
  } /* if */

  mem_free (buffer);

  return (ok);
} /* m_save_mask */

/*****************************************************************************/

GLOBAL VOID m_sort_mask (mask_spec)
MASK_SPEC *mask_spec;

{
  WORD    objs, i, j;
  MFIELD  *mfield, *mfield1;
  MOBJECT *mobject, x;
  SYSMASK *sysmask;

  sysmask = &mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;
  objs    = mask_spec->objs;

  for (i = 1; i < objs; i++)                    /* bubble sort */
    for (j = objs - 1; j > i - 1; j--)
    {
      mfield  = &mobject [j].mfield;
      mfield1 = &mobject [j - 1].mfield;

      if (mfield1->x > mfield->x)
      {
        x               = mobject [j - 1];
        mobject [j - 1] = mobject [j];
        mobject [j]     = x;
      } /* if */
    } /* for, for */

  for (i = 1; i < objs; i++)                    /* bubble sort */
    for (j = objs - 1; j > i - 1; j--)
    {
      mfield  = &mobject [j].mfield;
      mfield1 = &mobject [j - 1].mfield;

      if (mfield1->y > mfield->y)
      {
        x               = mobject [j - 1];
        mobject [j - 1] = mobject [j];
        mobject [j]     = x;
      } /* if */
    } /* for, for */
} /* m_sort_mask */

/*****************************************************************************/

GLOBAL VOID m_wi_title (window)
WINDOWP window;

{
  WORD      obj;
  STRING    s;
  SYSMASK   *sysmask;
  BASE_SPEC *base_spec;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  base_spec = mask_spec->base_spec;
  sysmask   = &mask_spec->mask;

  if (mask_spec->modified)
    strcpy (window->name, " *");
  else
    strcpy (window->name, " ");

  obj = (mask_spec->printer_mask) ? FPRNMASK : FSCRMASK;
  sprintf (s, "%s: %s.%s ", FREETXT (obj), base_spec->basename, sysmask->name);
  strcat (window->name, s);
  wind_set (window->handle, WF_NAME, ADR (window->name), 0, 0);
} /* m_wi_title */

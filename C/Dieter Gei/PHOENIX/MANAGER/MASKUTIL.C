/*****************************************************************************
 *
 * Module : MASKUTIL.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 02.11.02
 *
 *
 * Description: This module implements some utility functions for a mask window.
 *
 * History:
 * 02.11.02: In mu_sel_ext wird der Dateiname nicht mehr in Grožbuchstaben gewandelt.
 * 19.03.97: Parameter act_obj aded to mu_grafimp
 * 18.03.97: Parameter filename evaluated in mu_textimp, RedrawObj added
 * 13.03.97: Parameter filename added to graf & text im/export
 * 16.06.96: strcmp replaced by stricmp in mu_grafimp
 * 15.03.95: Call to set_meminfo in mu_crt_spec deleted
 * 28.02.95: Variable act_obj, act_sub, last_obj initialized in mu_crt_spec
 * 08.02.95: Variable sub initialized in mu_ed_init
 * 01.02.95: Handling of M_SUBMASK added in mu_ed_init
 * 27.01.95: Parameter window changed to mask_spec in all mask functions
 * 23.01.95: Parameter bGetFirstRec added in mu_crt_spec
 * 05.01.95: Functions mu_sm_init & sm2sql moved to mclick.c
 * 04.01.95: Adding '' to szMasterIndex in sm2sql
 * 21.12.94: SBS_NO3DBORDER added in mu_sm_init
 * 15.12.94: Handling of scroll bar added in mu_sm_init
 * 12.12.94: Searching for record with specified address in mu_crt_spec
 * 08.12.94: Variable submask->obj initialized in mu_sm_init
 * 01.12.94: Function sm2sql completed
 * 29.11.94: Call to vst_effects added in mu_sm_init
 * 21.11.94: Initializing of act_line added in mu_sm_init
 * 18.11.94: Calls to v_movecursor and m_vread only if root mask changed in mu_crt_spec
 * 14.11.94: Function mu_sm_init extended with doc and xfac, yfac, xscroll, yscroll added
 * 18.10.94: Freeing memory of columns in submask added in mu_free
 * 12.10.94: Handling for sub masks added in mu_free, mu_sm_init added
 * 11.10.94: Function mu_crt_spec added, x, y added in mu_ed_init
 * 27.08.94: Handling of SM_SHOW_INFO & SM_SHOW_MENU added in mu_load
 * 25.06.94: pCalcEntry & pCalcExit dynamic memory allocation error corrected in crt_mask
 * 02.05.94: Error in mu_change regarding icon bar corrected
 * 21.04.94: ED_PASTE replaced by ED_PASTEBUF
 * 07.12.93: Button handling for keyboard interface added in mask_ed_init
 * 18.11.93: Using new file selector
 * 08.10.93: Extra parameter in mset_info removed
 * 17.09.93: New list boxes in join dialog box added by Dieter Geiž
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "cbobj.h"
#include "controls.h"
#include "rbobj.h"
#include "editobj.h"
#include "emptyobj.h"
#include "gemobj.h"
#include "imageobj.h"

#include "desktop.h"
#include "dialog.h"
#include "mask.h"
#include "maskobj.h"
#include "mclick.h"
#include "resource.h"
#include "select.h"
#include "sql.h"

#include "export.h"
#include "maskutil.h"

/****** DEFINES **************************************************************/

#define INX_MASKNAME  1
#define INX_TABLENAME 2

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL FULLNAME ext_path;        /* path of external files to get */
LOCAL FILENAME ext_name;        /* name of external files to get */
LOCAL FULLNAME graf_path;       /* path of pictures to import/export */
LOCAL FILENAME graf_name;       /* name of pictures to import/export */
LOCAL FULLNAME blob_path;       /* path of blobs to import/export */
LOCAL FILENAME blob_name;       /* name of blobs to import/export */
LOCAL FULLNAME text_path;       /* path of text to import/export */
LOCAL FILENAME text_name;       /* name of text to import/export */

/****** FUNCTIONS ************************************************************/

LOCAL WORD search_user   _((DB *db, CURSOR *cursor, SYSMASK *sysmask, BYTE *username));
LOCAL VOID search_lookup _((SYSLOOKUP *syslookup, WORD num_lus, WORD *table, WORD *field));
LOCAL BOOL LoadCalc      _((DB *db, SHORT sTable, CHAR *pCalcName, CALCCODE *pCalcCode));
LOCAL VOID RedrawObj     _((MASK_SPEC *mask_spec, WORD wObj));

LOCAL LONG si_callback   _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG dt_callback   _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG di_callback   _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID set_join      _((MASK_SPEC *mask_spec));
LOCAL VOID click_join    _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL VOID mu_init ()

{
  strcpy (ext_path, act_path);
  ext_name [0] = EOS;

  strcpy (graf_path, act_path);
  graf_name [0] = EOS;

  strcpy (blob_path, act_path);
  blob_name [0] = EOS;

  strcpy (text_path, act_path);
  text_name [0] = EOS;
} /* mu_init */

/*****************************************************************************/

GLOBAL WORD mu_load (mask_spec, device, name)
MASK_SPEC *mask_spec;
BYTE      device;
BYTE      *name;

{
  WORD       inx, err;
  LONG       size;
  TABLE_INFO table_info;
  CURSOR     cursor;
  WORD       *objs;
  BYTE       *p;
  SYSMASK    *sysmask;
  DB         *db;

  size = sizeof (SYSMASK);
  db   = mask_spec->db;

  sysmask = mem_alloc (size);
  if (sysmask == NULL) return (ERR_NOMEMORY);

  p = sysmask->mask.buffer;

  v_tableinfo (db, mask_spec->table, &table_info);
  mem_set (sysmask, 0, sizeof (SYSMASK));
  sysmask->device [0] = device;
  strcpy (sysmask->name, name);
  strcpy (sysmask->tablename, table_info.name);

  if (sysmask->name [0] == EOS)
    inx = INX_TABLENAME;
  else
    inx = INX_MASKNAME;

  if (inx == INX_TABLENAME)
  {
    if (! db_search (db->base, SYS_MASK, inx, ASCENDING, &cursor, sysmask, 0L))
    {
      mem_free (sysmask);
      return (ERR_NOMASK);
    } /* if */

    err = search_user (db, &cursor, sysmask, db->base->username);
    if (err == ERR_NOUSERMASK)  /* try again, empty user */
    {
      strcpy (sysmask->tablename, table_info.name);

      err = search_user (db, &cursor, sysmask, "");
      if (err != SUCCESS)
      {
        mem_free (sysmask);
        return (err);
      } /* if */
    } /* if */
    else
      if (err != SUCCESS)
      {
        mem_free (sysmask);
        return (err);
      } /* if, else */
  } /* else */
  else
  {
    if (! db_search (db->base, SYS_MASK, inx, ASCENDING, &cursor, sysmask, 0L))
    {
      mem_free (sysmask);
      return (ERR_NOMASK);
    } /* if */

    if (! db_read (db->base, SYS_MASK, sysmask, &cursor, 0L, FALSE))
    {
      mem_free (sysmask);
      return (ERR_NOMASK);
    } /* if */

    if ((sysmask->username [0] != EOS) &&
        (strcmp (db->base->username, sysmask->username) != 0))
    {
      mem_free (sysmask);
      return (ERR_NOUSERMASK);
    } /* if */
  } /* else */

  objs = (WORD *)(p + sysmask->mask.size - sizeof (WORD));
  mask_spec->objs = *objs;

  strcpy (mask_spec->maskname, sysmask->name);

  if (sysmask->version < 1)				/* set default values for old masks */
    sysmask->flags |= SM_SHOW_INFO | SM_SHOW_MENU;	/* correct handling of these flags added in masks created with version 1 and later */

  mask_spec->mask = sysmask;

  return (SUCCESS);
}  /* mu_load */

/*****************************************************************************/

GLOBAL VOID mu_free (mask_spec, free_spec)
MASK_SPEC *mask_spec;
BOOLEAN   free_spec;

{
  WORD    i, sub;
  PICOBJ  *picobj;
  SUBMASK *submask;

  submask = mask_spec->Submask;

  for (sub = 0; sub < MAX_SUBMASKS; sub++, submask++)
    if (submask->pMaskSpec != NULL)
    {
      mu_free (submask->pMaskSpec, free_spec);
      if (submask->columns != NULL) mem_free (submask->columns);
      ScrollBar_Delete (submask->hsb);
      submask->pMaskSpec = NULL;
      submask->columns   = NULL;
      submask->hsb       = NULL;
    } /* if */

  picobj = mask_spec->spicobj;

  for (i = 0; i < mask_spec->spicobjs; i++, picobj++)
    switch (picobj->type)
    {
      case PIC_META  : gem_obj (&picobj->pic.gem, GEM_EXIT, 0, NULL);   break;
      case PIC_IMAGE : image_obj (&picobj->pic.img, IMG_EXIT, 0, NULL); break;
      case PIC_IFF   :                                                  break;
      case PIC_TIFF  :                                                  break;
    } /* switch, for */

  picobj = mask_spec->dpicobj;

  for (i = 0; i < mask_spec->dpicobjs; i++, picobj++)
    if (! (picobj->flags & PIC_INVALID))
      switch (picobj->type)
      {
        case PIC_META  : gem_obj (&picobj->pic.gem, GEM_EXIT, 0, NULL);   break;
        case PIC_IMAGE : image_obj (&picobj->pic.img, IMG_EXIT, 0, NULL); break;
        case PIC_IFF   :                                                  break;
        case PIC_TIFF  :                                                  break;
      } /* switch, if, for */

  m_exit_rec (mask_spec, FALSE, TRUE, FALSE);

  if (free_spec)
  {
    if (VTBL (mask_spec->table)) free_vtable (mask_spec->table);
    if (VINX (mask_spec->inx)) free_vindex (mask_spec->inx);
    db_freecursor (mask_spec->db->base, mask_spec->cursor);
  } /* if */

  mem_free (mask_spec->mask);
  mem_free (mask_spec->ed_field);
  if (free_spec) mem_free (mask_spec);
} /* mu_free */

/*****************************************************************************/

GLOBAL MASK_SPEC *mu_crt_spec (WINDOWP window, MASK_SPEC *pParentSpec, DB *db, WORD table, WORD inx, WORD dir, BYTE *maskname, KEY keyval, LONG address, VOID *db_buffer, BOOL bCalcEntry, WORD x, WORD y, BOOLEAN bGetFirstRec)
{
  BOOLEAN    ok;
  WORD       err, i;
  LONG       size, size1, size2, size3, size4, size5, size6, size7;
  LONG       addr;
  LONGSTR    s;
  TABLE_INFO table_info;
  PICOBJ     *picobj;
  BYTE       *buffer;
  VTABLE     *vtablep;
  VINDEX     *vindexp;
  MASK_SPEC  *mask_spec;

  size = sizeof (MASK_SPEC);

  v_tableinfo (db, table, &table_info);
  size += table_info.size;

  mask_spec = (MASK_SPEC *)mem_alloc (size);
  if (mask_spec == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  mem_set (mask_spec, 0, sizeof (MASK_SPEC));
  strcpy (mask_spec->maskname, maskname);

  mask_spec->db             = db;
  mask_spec->table          = table;
  mask_spec->inx            = inx;
  mask_spec->dir            = dir;
  mask_spec->act_obj        = -1;
  mask_spec->clear_buffered = FALSE;
  mask_spec->buf_dirty      = FALSE;
  mask_spec->asterisk       = FALSE;
  mask_spec->modify         = TRUE;
  mask_spec->buffer         = (BYTE *)mask_spec + sizeof (MASK_SPEC);
  mask_spec->pParentSpec    = pParentSpec;

  db_beg_trans (db->base, FALSE);
  err = mu_load (mask_spec, MASK_SCREEN, maskname);
  db_end_trans (db->base);

  if (err != SUCCESS)
  {
    switch (err)
    {
      case ERR_NOMEMORY   :
      case ERR_NOMASK     : hndl_alert (err);
                            break;
      case ERR_NOUSERMASK : sprintf (s, alerts [err], db->base->username);
                            open_alert (s);
                            break;
    } /* switch */

    mem_free (mask_spec);
    return (NULL);
  } /* if */

  mask_spec->edobjs = mu_ed_init (mask_spec, 0, 0);

  size1 = mask_spec->edobjs   * sizeof (EDFIELD);
  size2 = mask_spec->buttons  * sizeof (BUTTON);
  size3 = mask_spec->spicobjs * sizeof (PICOBJ);
  size4 = mask_spec->dpicobjs * sizeof (PICOBJ);
  size5 = mask_spec->calcobjs * sizeof (CALCOBJ);
  size6 = 0;
  size7 = 0;

  if (mask_spec->mask->w == 0) set_null (TYPE_WORD, &mask_spec->mask->w);
  if (mask_spec->mask->h == 0) set_null (TYPE_WORD, &mask_spec->mask->h);

  if (mask_spec->mask->calcentry [0] == (CHAR)0x80) mask_spec->mask->calcentry [0] = EOS;	/* kill courious value from older versions */
  if (mask_spec->mask->calcentry [0] != EOS) size6 += sizeof (CALCCODE);
  if (mask_spec->mask->calcexit  [0] != EOS) size7 += sizeof (CALCCODE);

  buffer = (BYTE *)mem_alloc (size1 + size2 + size3 + size4 + size5 + size6 + size7);

  if (buffer == NULL)
  {
    mem_free (mask_spec);
    return (NULL);
  } /* if */

  mask_spec->ed_field   = (EDFIELD *)buffer;
  mask_spec->button     = (BUTTON *)(buffer + size1);
  mask_spec->spicobj    = (PICOBJ *)(buffer + size1 + size2);
  mask_spec->dpicobj    = (PICOBJ *)(buffer + size1 + size2 + size3);
  mask_spec->calcobj    = (CALCOBJ *)(buffer + size1 + size2 + size3 + size4);
  mask_spec->pCalcEntry = (CALCCODE *)(buffer + size1 + size2 + size3 + size4 + size5);
  mask_spec->pCalcExit  = (CALCCODE *)(buffer + size1 + size2 + size3 + size4 + size5 + size6);
  mask_spec->edobjs     = mu_ed_init (mask_spec, x, y);
  mask_spec->cursor     = db_newcursor (db->base);

  if (mask_spec->cursor == NULL)
  {
    hndl_alert (ERR_NOCURSOR);
    mem_free (mask_spec->mask);
    mem_free (mask_spec->ed_field);
    mem_free (mask_spec);
    return (NULL);
  } /* if */

  if (mask_spec->mask->calcentry [0] == EOS)
    mask_spec->pCalcEntry = NULL;
  else
    if (! LoadCalc (db, table, mask_spec->mask->calcentry, mask_spec->pCalcEntry))
    {
      mask_spec->pCalcEntry = NULL;
      sprintf (s, alerts [ERR_CALCENTRY], mask_spec->mask->calcentry);
      open_alert (s);
    } /* if, else */

  if (mask_spec->mask->calcexit [0] == EOS)
    mask_spec->pCalcExit = NULL;
  else
    if (! LoadCalc (db, table, mask_spec->mask->calcexit, mask_spec->pCalcExit))
    {
      mask_spec->pCalcExit = NULL;
      sprintf (s, alerts [ERR_CALCEXIT], mask_spec->mask->calcexit);
      open_alert (s);
    } /* if, else */

  db_fillnull (db->base, rtable (table), mask_spec->buffer);

  if (VTBL (table))     /* increment virtual table, original could be destroyed */
  {
    vtablep = VTABLEP (table);
    vtablep->used++;
  } /* if */

  if (VINX (inx))       /* increment virtual index, original could be destroyed */
  {
    vindexp = VINDEXP (inx);
    vindexp->used++;
  } /* if */

  if (v_initcursor (mask_spec->db, mask_spec->table, mask_spec->inx, mask_spec->dir, mask_spec->cursor))
  {
    ok = FALSE;

    if ((keyval != NULL) || (db_buffer != NULL))
    {
      if (keyval != NULL)
      {
        db_keysearch (db->base, rtable (table), inx, dir, mask_spec->cursor, keyval, address);
        ok = TRUE;
      } /* if */

      if (db_buffer != NULL)	/* set key values into corresponding fields */
        mem_lmove (mask_spec->buffer, db_buffer, table_info.size);
    } /* if */
    else
    {
      if (address == 0)
        ok = (bGetFirstRec) ? v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)dir) : TRUE;
      else
      {
        addr = 0;
        ok   = TRUE;

        while ((addr != address) && ok)		/* search for record with specified database address */
        {
          ok   = v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)dir);
          addr = v_readcursor (mask_spec->db, mask_spec->cursor, NULL);
        } /* while */
      } /* else */
    } /* else */

    if (ok && bGetFirstRec)	/* root mask and 'submasks as mask' reads first record, 'submasks as table' read them at draw time */
    {
      if (db_acc_table (db->base, rtable (table)) & GRANT_SELECT)
        ok = m_vread (mask_spec, mask_spec->table, mask_spec->buffer, mask_spec->cursor, 0L, TRUE);

      if (! ok)
      {
        mu_free (mask_spec, TRUE);
        return (NULL);
      } /* if */
    } /* if */
  } /* if */
  else
    if (db_buffer != NULL)      /* set key values into corresponding fields */
      mem_lmove (mask_spec->buffer, db_buffer, table_info.size);

  if ((mask_spec->pCalcEntry != NULL) && bCalcEntry)
  {
    err = v_execute (mask_spec->db, mask_spec->table, mask_spec->pCalcEntry, mask_spec->buffer, 0L, NULL);
    if (err != SUCCESS) hndl_alert (err);
  } /* if */

  if (mask_spec->edobjs > 0)
    mask_spec->act_obj = 0;
  else
  {
    mu_free (mask_spec, TRUE);
    return (NULL);
  } /* else */

  mask_spec->act_obj  = FAILURE;	/* no act_obj so far */
  mask_spec->act_sub  = FAILURE;	/* act_sub is edit index for root mask */
  mask_spec->last_obj = FAILURE;

  mask_spec->sm_flags = mask_spec->mask->flags;
  mask_spec->window   = window;

  picobj = mask_spec->dpicobj;
  for (i = 0; i < mask_spec->dpicobjs; i++, picobj++) picobj->flags = PIC_INVALID;

  return (mask_spec);
} /* mu_crt_spec */

/*****************************************************************************/

GLOBAL VOID mu_change (MASK_SPEC *mask_spec, BYTE *mask_name)
{
  BOOLEAN    ok, found, dirty, modify;
  WORD       num_masks, num, menu_height;
  WORD       err, i;
  WORD       table, inx, dir;
  WORD       ob_height;
  LONG       size1, size2, size3, size4, size5, size6, size7;
  LONGSTR    s;
  CURSOR     cursor, *pcursor;
  SEL_SPEC   sel_spec;
  TABLE_INFO table_info;
  DB         *db;
  BYTE       *itemlist, *p;
  BYTE       *buffer;
  PICOBJ     *picobj;
  SYSMASK    *sysmask;
  BASE       *base;
  WINDOWP    window;

  window = mask_spec->window;
  db     = mask_spec->db;
  base   = db->base;

  db_tableinfo (base, SYS_MASK, &table_info);
  num_masks = (WORD)table_info.recs;
  itemlist  = mem_alloc ((LONG)num_masks * (sizeof (FIELDNAME)));

  if (itemlist == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return;
  } /* if */

  sysmask = mem_alloc ((LONG)sizeof (SYSMASK));
  if (sysmask == NULL)
  {
    mem_free (itemlist);
    hndl_alert (ERR_NOMEMORY);
    return;
  } /* if */

  set_meminfo ();
  busy_mouse ();

  db_tableinfo (base, rtable (mask_spec->table), &table_info);
  db_initcursor (base, SYS_MASK, 1, ASCENDING, &cursor);

  for (i = num = 0, ok = TRUE, p = itemlist; (i < num_masks) && ok && db_movecursor (base, &cursor, 1L); i++)
  {
    ok = db_read (base, SYS_MASK, sysmask, &cursor, 0L, FALSE);
    if (ok &&
       (sysmask->device [0] == MASK_SCREEN) &&
       (strcmp (table_info.name, sysmask->tablename) == 0) &&
       ((sysmask->username [0] == EOS) || (strcmp (base->username, sysmask->username) == 0)))
    {
      strcpy (p, sysmask->name);
      num++;
      p += sizeof (FIELDNAME);
     } /* if */
  } /* while */

  arrow_mouse ();

  if (mask_name [0] == EOS)
  {
    sel_spec.title      = FREETXT (FMCHANGE);
    sel_spec.itemlist   = itemlist;
    sel_spec.itemsize   = sizeof (FIELDNAME) ;
    sel_spec.num_items  = num;
    sel_spec.boxtitle   = FREETXT (FMLIST);
    sel_spec.helpinx    = HMCHANGE;
    strcpy (sel_spec.selection, "");

    ok = selection (&sel_spec);
  } /* if */
  else
    strcpy (sel_spec.selection, mask_name);

  if (ok)
  {
    busy_mouse ();
    found = FALSE;

    strcpy (sysmask->name, sel_spec.selection);
    sysmask->device [0] = MASK_SCREEN;
    sysmask->device [1] = EOS;

    if (sysmask->name [0] != EOS)
    {
      found = db_search (base, SYS_MASK, 1, ASCENDING, &cursor, sysmask, 0L);
      ok    = db_status (base) == SUCCESS;
    } /* if */

    if (ok && found) ok = db_read (base, SYS_MASK, sysmask, &cursor, 0L, FALSE);

    mem_free (sysmask);
    mem_free (itemlist);

    dbtest (mask_spec->db);

    if (ok && found)
    {
      m_edit_obj (mask_spec, MO_EXIT, 0, NULL);
      mu_free (mask_spec, FALSE);
      table   = mask_spec->table;
      inx     = mask_spec->inx;
      dir     = mask_spec->dir;
      pcursor = mask_spec->cursor;
      dirty   = mask_spec->buf_dirty;
      modify  = mask_spec->modify;

      mem_set (mask_spec, 0, sizeof (MASK_SPEC));
      strcpy (mask_spec->maskname, sel_spec.selection);

      mask_spec->db        = db;
      mask_spec->table     = table;
      mask_spec->inx       = inx;
      mask_spec->dir       = dir;
      mask_spec->cursor    = pcursor;
      mask_spec->window    = window;
      mask_spec->act_obj   = FAILURE;	/* no act_obj so far */
      mask_spec->act_sub   = FAILURE;	/* act_sub is edit index for root mask */
      mask_spec->last_obj  = FAILURE;
      mask_spec->buf_dirty = dirty;
      mask_spec->modify    = modify;
      mask_spec->buffer    = (BYTE *)mask_spec + sizeof (MASK_SPEC);

      db_beg_trans (db->base, FALSE);
      err = mu_load (mask_spec, MASK_SCREEN, sel_spec.selection);
      db_end_trans (db->base);

      if (err != SUCCESS)
      {
        switch (err)
        {
          case ERR_NOMEMORY   :
          case ERR_NOMASK     : hndl_alert (err);
                                break;
          case ERR_NOUSERMASK : sprintf (s, alerts [err], base->username);
                                open_alert (s);
                                break;
        } /* switch */

        close_window (window);
        return;
      } /* if */

      mask_spec->edobjs = mu_ed_init (mask_spec, 0, 0);

      if (mask_spec->edobjs > 0)
        mask_spec->act_obj = 0;
      else
      {
        hndl_alert (ERR_NOOPEN);
        close_window (window);
        return;
      } /* else */

      size1 = mask_spec->edobjs   * sizeof (EDFIELD);
      size2 = mask_spec->buttons  * sizeof (BUTTON);
      size3 = mask_spec->spicobjs * sizeof (PICOBJ);
      size4 = mask_spec->dpicobjs * sizeof (PICOBJ);
      size5 = mask_spec->calcobjs * sizeof (CALCOBJ);
      size6 = 0;
      size7 = 0;

      if (mask_spec->mask->w == 0) set_null (TYPE_WORD, &mask_spec->mask->w);
      if (mask_spec->mask->h == 0) set_null (TYPE_WORD, &mask_spec->mask->h);

      if (mask_spec->mask->calcentry [0] == (CHAR)0x80) mask_spec->mask->calcentry [0] = EOS;	/* kill courious value from older versions */
      if (mask_spec->mask->calcentry [0] != EOS) size6 += sizeof (CALCCODE);
      if (mask_spec->mask->calcexit  [0] != EOS) size7 += sizeof (CALCCODE);

      buffer = (BYTE *)mem_alloc (size1 + size2 + size3 + size4 + size5 + size6 + size7);

      if (buffer == NULL)
      {
        hndl_alert (ERR_NOMEMORY);
        close_window (window);
        return;
      } /* if */

      mask_spec->ed_field   = (EDFIELD *)buffer;
      mask_spec->button     = (BUTTON *)(buffer + size1);
      mask_spec->spicobj    = (PICOBJ *)(buffer + size1 + size2);
      mask_spec->dpicobj    = (PICOBJ *)(buffer + size1 + size2 + size3);
      mask_spec->calcobj    = (CALCOBJ *)(buffer + size1 + size2 + size3 + size4);
      mask_spec->pCalcEntry = (CALCCODE *)(buffer + size1 + size2 + size3 + size4 + size5);
      mask_spec->pCalcExit  = (CALCCODE *)(buffer + size1 + size2 + size3 + size4 + size5 + size6);
      mask_spec->edobjs     = mu_ed_init (mask_spec, 0, 0);
      mask_spec->sm_flags   = mask_spec->mask->flags;

      if (mask_spec->mask->calcentry [0] == EOS)
        mask_spec->pCalcEntry = NULL;
      else
        if (! LoadCalc (db, table, mask_spec->mask->calcentry, mask_spec->pCalcEntry))
        {
          mask_spec->pCalcEntry = NULL;
          sprintf (s, alerts [ERR_CALCENTRY], mask_spec->mask->calcentry);
          open_alert (s);
        } /* if, else */

      if (mask_spec->mask->calcexit [0] == EOS)
        mask_spec->pCalcExit = NULL;
      else
        if (! LoadCalc (db, table, mask_spec->mask->calcexit, mask_spec->pCalcExit))
        {
          mask_spec->pCalcExit = NULL;
          sprintf (s, alerts [ERR_CALCEXIT], mask_spec->mask->calcexit);
          open_alert (s);
        } /* if, else */

      m_winame (mask_spec);
      mset_info (window);

      ob_height  = 0;
      ob_height += (mask_spec->sm_flags & SM_SHOW_INFO)  ? mask_info.infoheight : 0;
      ob_height += (mask_spec->sm_flags & SM_SHOW_ICONS) ? mask_info.iconheight : 0;

      window->menu = (mask_spec->sm_flags & SM_SHOW_MENU) ? maskmenu : NULL;

      menu_height = (window->menu != NULL) ? gl_hattr : 0;

      window->scroll.y = window->work.y + menu_height + ob_height;
      window->scroll.h = window->work.h - menu_height - ob_height;

      window->doc.x = window->doc.y = 0;
      m_get_doc (mask_spec, &window->doc.w, &window->doc.h);

      err = m_ed_index (mask_spec, 0, 1, NULL);
      if (err != SUCCESS)
      {
        switch (err)
        {
          case MO_NOMEMORY : hndl_alert (ERR_NOMEMORY);
        } /* switch */

        close_window (window);
        return;
      } /* if */

      if (m_sm_init (mask_spec) != SUCCESS)
      {
        hndl_alert (ERR_NOMEMORY);

        close_window (window);
        return;
      } /* if */

      mu_get_graf (mask_spec);
      picobj = mask_spec->dpicobj;
      for (i = 0; i < mask_spec->dpicobjs; i++, picobj++) picobj->flags = PIC_INVALID;

      set_sliders (mask_spec->window, HORIZONTAL + VERTICAL, SLPOS + SLSIZE);
      set_redraw (mask_spec->window, &mask_spec->window->scroll);
    } /* if */
    else
      hndl_alert (ERR_NOMASK);

    arrow_mouse ();
  } /* if */

  set_meminfo ();
} /* mu_change */

/*****************************************************************************/

GLOBAL VOID mu_join (MASK_SPEC *mask_spec)
{
  WORD    ret;
  WINDOWP window;

  if (rtable (mask_spec->table) < NUM_SYSTABLES) return;

  window = search_window (CLASS_DIALOG, SRCH_ANY, JOIN);

  if (window == NULL)
  {
    form_center (join, &ret, &ret, &ret, &ret);
    window = crt_dialog (join, NULL, JOIN, FREETXT (FJOIN), WI_MODAL);

    if (window != NULL) window->click = click_join;
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (join, ROOT, EDITABLE);
    window->edit_inx = NIL;
    window->special  = (LONG)mask_spec;

    set_join (mask_spec);

    if (! open_dialog (JOIN)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mu_join */

/*****************************************************************************/

GLOBAL WORD mu_ed_init (MASK_SPEC *mask_spec, WORD x, WORD y)
{
  WORD       obj, objs, num_lus, pos, i, sub;
  WORD       spicobjs, dpicobjs, calcobjs, buttons;
  WORD       table, field;
  UWORD      flags;
  LONGSTR    s;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  CURSOR     cursor;
  BYTE       *table_name;
  BYTE       *field_name;
  BYTE       *p;
  EDFIELD    *ed_field;
  CALCOBJ    *calcobj;
  BUTTON     *button;
  MFIELD     *mfield;
  MLINE      *mline;
  MTEXT      *mtext;
  MBUTTON    *mbutton;
  MSUBMASK   *msubmask;
  MOBJECT    *mobject;
  SYSLOOKUP  *syslookup;
  SYSMASK    *sysmask;
  SYSCALC    *syscalc;

  sysmask  = mask_spec->mask;
  mobject  = (MOBJECT *)sysmask->mask.buffer;
  ed_field = mask_spec->ed_field;
  button   = mask_spec->button;
  calcobj  = mask_spec->calcobj;
  spicobjs = 0;
  dpicobjs = 0;
  calcobjs = 0;
  buttons  = 0;
  objs     = 0;
  sub      = 0;

  db_tableinfo (mask_spec->db->base, SYS_LOOKUP, &table_info);
  num_lus   = table_info.recs;
  syslookup = mask_spec->db->syslookup;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield = &mobject->mfield;

    if (ed_field != NULL)	/* if memory has been allocated (last call to mu_ed_init), adjust x and y coordinates for submasks */
    {
      if (mfield->class == M_LINE)
      {
        mline = &mobject->mline;

        mline->x1 += x;
        mline->y1 += y;
        mline->x2 += x;
        mline->y2 += y;
      } /* if */
      else
      {
        mfield->x += x;
        mfield->y += y;
      } /* if */
    } /* if */

    if (mfield->class == M_GRAF) spicobjs++;

    if (mfield->class == M_TEXT)
    {
      mtext = &mobject->mtext;
      if (mtext->flags & MF_SYSTEMFONT) mtext->point = gl_point;
    } /* if */

    if (mfield->class == M_BUTTON)
    {
      buttons++;
      mbutton = &mobject->mbutton;
      if (mbutton->flags & MF_SYSTEMFONT) mbutton->point = gl_point;

      if (button != NULL)	/* if memory has been allocated */
      {
        button->obj      = obj;
        button->alt_char = NUL;

        p = &sysmask->mask.buffer [mbutton->text];

        if (strchr (p, ALT_CHAR) != NULL)	/* alternate control char */
        {
          for (i = 0; p [i] != ALT_CHAR; i++);
          pos = i + 1;				/* get position of underbar char */

          button->alt_char = ch_upper (p [pos]);
        } /* if */

        button++;
      } /* if */

      if (mbutton->command == MB_CALC)
      {
        calcobjs++;	/* count all calc buttons */

        if (calcobj != NULL)	/* if memory has been allocated */
        {
          syscalc = (SYSCALC *)mem_alloc ((LONG)sizeof (SYSCALC));
          if (syscalc == NULL)
          {
            hndl_alert (ERR_NOMEMORY);
            return (FAILURE);
          } /* if */

          p = &sysmask->mask.buffer [mbutton->param];
          strcpy (syscalc->tablename, db_tablename (mask_spec->db->base, rtable (mask_spec->table)));
          strcpy (syscalc->name, p);

          if (db_search (mask_spec->db->base, SYS_CALC, 1, ASCENDING, &cursor, syscalc, 0L))
            if (db_read (mask_spec->db->base, SYS_CALC, syscalc, &cursor, 0L, FALSE))
            {
              calcobj->obj  = obj;
              calcobj->code = syscalc->code;
            } /* if */
            else
              calcobj->obj = FAILURE;

          calcobj++;
          mem_free (syscalc);
        } /* if */
      } /* if */
    } /* if */

    if (mfield->class == M_SUBMASK)
    {
      msubmask = &mobject->msubmask;

      if (msubmask->flags & MSM_SHOW_MASK)	/* submasks as mask can be edited */
      {
        objs++;

        if (ed_field != NULL)	/* memory has been allocated */
        {
          ed_field->mfield   = mfield;
          ed_field->obj      = obj;
          ed_field->sub      = sub;		/* index to Submask in MASK_SPEC */
          ed_field->table    = FAILURE;
          ed_field->field    = FAILURE;
          ed_field->lu_table = FAILURE;
          ed_field->lu_field = FAILURE;
          ed_field->type     = FAILURE;
          ed_field->flags    = 0;

          ed_field++;
          sub++;
        } /* if */
      } /* if */
    } /* if */

    if (mfield->class == M_FIELD)
    {
      if (mfield->flags & MF_SYSTEMFONT) mfield->point = gl_point;

      table_name = &sysmask->mask.buffer [mfield->table_name];
      field_name = &sysmask->mask.buffer [mfield->field_name];

      strcpy (table_info.name, table_name);
      strcpy (field_info.name, field_name);

      table = db_tableinfo (mask_spec->db->base, FAILURE, &table_info);
      if (table == FAILURE)
      {
        mask_spec->objs = 0;
        sprintf (s, alerts [ERR_MNOTABLE], table_name);
        open_alert (s);
        return (FAILURE);
      } /* if */

      field = db_fieldinfo (mask_spec->db->base, table, FAILURE, &field_info);
      if (field == FAILURE)
      {
        mask_spec->objs = 0;
        sprintf (s, alerts [ERR_MNOFIELD], table_name, field_name);
        open_alert (s);
        return (FAILURE);
      } /* if */

      if (ed_field != NULL)	/* if memory has been allocated */
      {
        ed_field->mfield   = mfield;
        ed_field->obj      = obj;
        ed_field->sub      = FAILURE;		/* that's no submask */
        ed_field->table    = table;
        ed_field->field    = field;
        ed_field->lu_table = table;
        ed_field->lu_field = field;
        ed_field->type     = field_info.type;

        ed_field->szFilename [0] = EOS;		/* clear Olga filename */

        if (mfield->h == 1) mfield->flags &= ~ MF_WORDBREAK;    /* single line & wordbreak senseless */

        search_lookup (syslookup, num_lus, &ed_field->lu_table, &ed_field->lu_field);

        flags = field_info.flags;
        if ((flags & GRANT_ALL) == GRANT_NOTHING) flags |= COL_HIDDEN;
        if ((flags & GRANT_ALL & ~ GRANT_SELECT) == GRANT_NOTHING) flags |= COL_OUTPUT;
        ed_field->flags = flags;

        if (field_info.type == TYPE_PICTURE) ed_field->pic = dpicobjs++;
        ed_field++;
      } /* if */
      else
        if (field_info.type == TYPE_PICTURE) dpicobjs++;

      objs++;
    } /* if */
  } /* for */

  mask_spec->buttons  = buttons;
  mask_spec->spicobjs = spicobjs;
  mask_spec->dpicobjs = dpicobjs;
  mask_spec->calcobjs = calcobjs;

  return (objs);
} /* mu_ed_init */

/*****************************************************************************/

GLOBAL VOID mu_get_graf (MASK_SPEC *mask_spec)
{
  WORD      obj, pic, result;
  RECT      pos;
  GEMOBJP   gem;
  IMGOBJP   img;
  FULLNAME  path, s;
  FILENAME  name;
  BYTE      *filename;
  PICOBJ    *picobj;
  MGRAF     *mgraf;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;

  sysmask = mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;

  for (obj = pic = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mgraf = &mobject->mgraf;

    if (mgraf->class == M_GRAF)
    {
      m_obj2pos (mask_spec, obj, &pos);
      picobj = &mask_spec->spicobj [pic];

      picobj->type = mgraf->type;
      filename     = &sysmask->mask.buffer [mgraf->filename];
      strcpy (picobj->filename, filename);
      strcpy (s, filename);

      switch (picobj->type)
      {
        case PIC_META  : gem             = &picobj->pic.gem;
                         gem->window     = mask_spec->window;
                         gem->pos        = pos;
                         gem->out_handle = vdi_handle;
                         result          = gem_obj (gem, GEM_INIT, GEM_FILE | GEM_BESTFIT, s);

                         if (result == GEM_FILENOTFOUND)        /* try again on basepath */
                         {
                           file_split (filename, NULL, path, name, NULL);
                           strcpy (s, mask_spec->db->base->basepath);
                           strcat (s, name);
                           result = gem_obj (gem, GEM_INIT, GEM_FILE | GEM_BESTFIT, s);
                         } /* if */

                         switch (result)
                         {
                           case GEM_OK           : pic++;                        break;
                           case GEM_NOMEMORY     : hndl_alert (ERR_NOMEMORY);    break;
                           case GEM_FILENOTFOUND : file_error (ERR_FILEOPEN, s); break;
                         } /* switch */
                         break;
        case PIC_IMAGE : img         = &picobj->pic.img;
                         img->window = mask_spec->window;
                         img->pos    = pos;
                         result      = image_obj (img, IMG_INIT, IMG_FILE, s);

                         if (result == IMG_FILENOTFOUND)        /* try again on basepath */
                         {
                           file_split (filename, NULL, path, name, NULL);
                           strcpy (s, mask_spec->db->base->basepath);
                           strcat (s, name);
                           result = image_obj (img, IMG_INIT, IMG_FILE, s);
                         } /* if */

                         switch (result)
                         {
                           case IMG_OK           : pic++;                        break;
                           case IMG_NOMEMORY     : hndl_alert (ERR_NOMEMORY);    break;
                           case IMG_FILENOTFOUND : file_error (ERR_FILEOPEN, s); break;;
                         } /* switch */
                         break;
        case PIC_IFF   : break;
        case PIC_TIFF  : break;
      } /* switch */
    } /* if */
  } /* for */

  mask_spec->spicobjs = pic;
} /* mu_get_graf */

/*****************************************************************************/

GLOBAL VOID mu_sel_ext (MASK_SPEC *mask_spec)
{
  WORD     msg;
  FULLNAME filename;

  strcpy (filename, ext_name);

  if (! get_open_filename (FGETFILE, NULL, 0L, FFILTER_ALL, NULL, ext_path, FAILURE, filename, ext_name))
    return;

  file_split (filename, NULL, ext_path, ext_name, NULL);
  set_clip (TRUE, &mask_spec->window->scroll);

  msg = edit_obj (&mask_spec->ed, ED_PASTEBUF, TRUE, filename);
  if (msg == ED_BUFFERCHANGED) m_setdirty (mask_spec, TRUE);
} /* mu_sel_ext */

/*****************************************************************************/

GLOBAL VOID mu_grafimp (MASK_SPEC *mask_spec, BYTE *pFilename, WORD act_obj)
{
  WORD       type;
  LONG       size;
  FHANDLE    f;
  FULLNAME   filename, path;
  FILENAME   name;
  EXT        ext;
  LONGSTR    s;
  FIELD_INFO field_info;
  BYTE       *buffer;
  LONG       *lbuffer;
  EDFIELD    *ed_field;

  if (pFilename == NULL)
    strcpy (filename, graf_name);
  else
    strcpy (filename, pFilename);

  if ((pFilename == NULL) && ! get_open_filename (FIMPPIC, NULL, 0L, FFILTER_IMG_GEM, NULL, graf_path, FAILURE, filename, graf_name))
    return;

  str_upper (filename);
  file_split (filename, NULL, graf_path, graf_name, NULL);
  file_split (filename, NULL, path, name, ext);

  type = FAILURE;

  if (stricmp (ext, FREETXT (FGEMSUFF) + 2) == 0) type = PIC_META;
  if (stricmp (ext, FREETXT (FIMGSUFF) + 2) == 0) type = PIC_IMAGE;
  if (stricmp (ext, FREETXT (FIFFSUFF) + 2) == 0) type = PIC_IFF;
  if (stricmp (ext, FREETXT (FTIFSUFF) + 2) == 0) type = PIC_TIFF;

  if (type == FAILURE)
  {
    sprintf (s, alerts [ERR_PICUNKNOWN], ext);
    open_alert (s);
    return;
  } /* if */

  ed_field = &mask_spec->ed_field [act_obj];

  db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

  buffer   = mask_spec->buffer;
  buffer  += field_info.addr;
  lbuffer  = (LONG *)buffer;

  size = file_length (filename);
  if (size > field_info.size - 2 * sizeof (LONG))       /* size & type of picture in first two long words */
  {
    sprintf (s, alerts [ERR_PIC2BIG], size, field_info.size - 2 * sizeof (LONG));
    open_alert (s);
    return;
  } /* if */

  f = file_open (filename, O_RDONLY);
  if (f >= 0)
  {
    lbuffer [0] = size + sizeof (LONG);                 /* add type of picture */
    lbuffer [1] = type;

    if (file_read (f, size, &lbuffer [2]) == size)
      m_setdirty (mask_spec, TRUE);
    else
    {
      file_error (ERR_FILEREAD, filename);
      set_null (field_info.type, lbuffer);
    } /* else */

    file_close (f);

    m_exit_pic (mask_spec, ed_field->pic);              /* remove old picture */
    RedrawObj (mask_spec, ed_field->obj);
  } /* if */
  else
    file_error (ERR_FILEOPEN, filename);
} /* mu_grafimp */

/*****************************************************************************/

GLOBAL VOID mu_grafexp (MASK_SPEC *mask_spec, BYTE *pFilename)
{
  WORD       type, obj, filter;
  LONG       size;
  FHANDLE    f;
  FULLNAME   filename, path;
  FILENAME   name;
  EXT        ext;
  LONGSTR    s;
  FIELD_INFO field_info;
  BYTE       *buffer;
  LONG       *lbuffer;
  EDFIELD    *ed_field;

  ed_field = &mask_spec->ed_field [mask_spec->act_obj];

  db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

  buffer   = mask_spec->buffer;
  buffer  += field_info.addr;
  lbuffer  = (LONG *)buffer;

  size = lbuffer [0] - sizeof (LONG);                   /* subtract type of picture */
  type = lbuffer [1];

  switch (type)
  {
    case PIC_META  : obj    = FGEMSUFF;
                     filter = FFILTER_GEM;
                     break;
    case PIC_IMAGE : obj    = FIMGSUFF;
                     filter = FFILTER_IMG;
                     break;
    case PIC_IFF   : obj    = FIFFSUFF;
                     filter = FFILTER_IFF;
                     break;
    case PIC_TIFF  : obj    = FTIFSUFF;
                     filter = FFILTER_TIF;
                     break;
    default        : obj    = FAILURE;
                     filter = FFILTER_ALL;
                     break;
  } /* switch */

  strcpy (ext, (obj == FAILURE) ? FREETXT (FALLSUFF) + 1 : FREETXT (obj) + 1);

  if (pFilename == NULL)
    strcpy (filename, graf_name);
  else
    strcpy (filename, pFilename);

  if ((pFilename == NULL) && ! get_save_filename (FEXPPIC, NULL, 0L, filter, NULL, graf_path, obj, filename, graf_name))
    return;

  str_upper (filename);
  file_split (filename, NULL, graf_path, graf_name, NULL);
  file_split (filename, NULL, path, name, s);
  sprintf (filename, "%s%s%s", path, name, ext);

  f = file_create (filename);
  if (f >= 0)
  {
    if (file_write (f, size, &lbuffer [2]) != size) file_error (ERR_FILEWRITE, filename);
    file_close (f);
  } /* if */
  else
    file_error (ERR_FILECREATE, filename);
} /* mu_grafexp */

/*****************************************************************************/

GLOBAL VOID mu_blobimp (MASK_SPEC *mask_spec)
{
  WORD       type;
  LONG       size;
  FHANDLE    f;
  FULLNAME   filename, path;
  FILENAME   name;
  EXT        ext;
  LONGSTR    s;
  FIELD_INFO field_info;
  BYTE       *buffer;
  LONG       *lbuffer;
  EDFIELD    *ed_field;

  strcpy (filename, blob_name);

  if (! get_open_filename (FIMPBLOB, NULL, 0L, FFILTER_ALL, NULL, blob_path, FAILURE, filename, blob_name))
    return;

  str_upper (filename);
  file_split (filename, NULL, blob_path, blob_name, NULL);
  file_split (filename, NULL, path, name, ext);

  type = BLOB_UNKNOWN;

  if (stricmp (ext, "SAM") == 0) type = BLOB_SOUND;
  if (stricmp (ext, "MID") == 0) type = BLOB_MIDI;

  ed_field = &mask_spec->ed_field [mask_spec->act_obj];

  db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

  buffer   = mask_spec->buffer;
  buffer  += field_info.addr;
  lbuffer  = (LONG *)buffer;

  size = file_length (filename);
  if (size > field_info.size - 2 * sizeof (LONG))       /* size & type of blob in first two long words */
  {
    sprintf (s, alerts [ERR_BLOB2BIG], size, field_info.size - 2 * sizeof (LONG));
    open_alert (s);
    return;
  } /* if */

  f = file_open (filename, O_RDONLY);
  if (f >= 0)
  {
    lbuffer [0] = size + sizeof (LONG);                 /* add type of picture */
    lbuffer [1] = type;

    if (file_read (f, size, &lbuffer [2]) == size)
      m_setdirty (mask_spec, TRUE);
    else
    {
      file_error (ERR_FILEREAD, filename);
      set_null (field_info.type, lbuffer);
    } /* else */

    file_close (f);

    RedrawObj (mask_spec, ed_field->obj);
  } /* if */
  else
    file_error (ERR_FILEOPEN, filename);
} /* mu_blobimp */

/*****************************************************************************/

GLOBAL VOID mu_blobexp (MASK_SPEC *mask_spec)
{
  WORD       type, obj, filter;
  LONG       size;
  FHANDLE    f;
  FULLNAME   filename;
  EXT        ext;
  FIELD_INFO field_info;
  BYTE       *buffer;
  LONG       *lbuffer;
  EDFIELD    *ed_field;

  ed_field = &mask_spec->ed_field [mask_spec->act_obj];

  db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

  buffer   = mask_spec->buffer;
  buffer  += field_info.addr;
  lbuffer  = (LONG *)buffer;

  size = lbuffer [0] - sizeof (LONG);                   /* subtract type of blob */
  type = lbuffer [1];

  switch (type)
  {
    case BLOB_UNKNOWN : obj    = FAILURE;
                        filter = FFILTER_ALL;
                        break;
    case BLOB_SOUND   : obj    = FSAMSUFF;
                        filter = FFILTER_SAM;
                        break;
    case BLOB_MIDI    : obj    = FAILURE;
                        filter = FFILTER_ALL;
                        break;
    default           : obj    = FAILURE;
                        filter = FFILTER_ALL;
                        break;
  } /* switch */

  strcpy (ext, (obj == FAILURE) ? FREETXT (FALLSUFF) + 1 : FREETXT (obj) + 1);

  strcpy (filename, blob_name);

  if (! get_save_filename (FEXPBLOB, NULL, 0L, filter, NULL, blob_path, obj, filename, blob_name))
    return;

  str_upper (filename);
  file_split (filename, NULL, blob_path, blob_name, NULL);

  f = file_create (filename);
  if (f >= 0)
  {
    if (file_write (f, size, &lbuffer [2]) != size) file_error (ERR_FILEWRITE, filename);
    file_close (f);
  } /* if */
  else
    file_error (ERR_FILECREATE, filename);
} /* mu_blobexp */

/*****************************************************************************/

GLOBAL VOID mu_textimp (MASK_SPEC *mask_spec, BYTE *pFilename, WORD act_obj)
{
  LONG       size;
  LONGSTR    s;
  FHANDLE    f;
  FULLNAME   filename;
  FIELD_INFO field_info;
  BYTE       *buffer;
  EDFIELD    *ed_field;

  if (pFilename == NULL)
    strcpy (filename, text_name);
  else
    strcpy (filename, pFilename);

  if ((pFilename == NULL) && ! get_open_filename (FIMPTEXT, NULL, 0L, FFILTER_TXT, NULL, text_path, FAILURE, filename, text_name))
    return;

  str_upper (filename);
  file_split (filename, NULL, text_path, text_name, NULL);

  ed_field = &mask_spec->ed_field [act_obj];
  buffer   = mask_spec->buffer;

  db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

  switch (field_info.type)
  {
    case TYPE_CHAR   :
    case TYPE_CFLOAT :
    case TYPE_EXTERN : buffer += field_info.addr;
                       break;
    default          : buffer          = s;
                       field_info.size = LONGSTRSIZE;
                       break;
  } /* switch */

  size = file_length (filename);
  if (size > field_info.size - 1)
  {
    sprintf (s, alerts [ERR_TEXT2BIG], size, field_info.size - 1);
    if (open_alert (s) == 2) return;	/* Cancel */
  } /* if */

  size = min (size, field_info.size - 1);

  f = file_open (filename, O_RDONLY);
  if (f >= 0)
  {
    if (file_read (f, size, buffer) == size)
    {
      m_setdirty (mask_spec, TRUE);
      buffer [size]        = EOS;

      switch (field_info.type)
      {
        case TYPE_CHAR   :
        case TYPE_CFLOAT :
        case TYPE_EXTERN : break;
        default          : str2col (mask_spec->db, ed_field->table, mask_spec->buffer, ed_field->field, buffer);
                           break;
      } /* switch */
    } /* if */
    else
    {
      file_error (ERR_FILEREAD, filename);
      set_null (field_info.type, (BYTE *)mask_spec->buffer + field_info.addr);
    } /* else */

    file_close (f);

    RedrawObj (mask_spec, ed_field->obj);
  } /* if */
  else
    file_error (ERR_FILEOPEN, filename);
} /* mu_textimp */

/*****************************************************************************/

GLOBAL VOID mu_textexp (MASK_SPEC *mask_spec, BYTE *pFilename)
{
  LONG       size;
  FHANDLE    f;
  FULLNAME   filename;
  FIELD_INFO field_info;
  BYTE       *buffer;
  EDFIELD    *ed_field;

  ed_field = &mask_spec->ed_field [mask_spec->act_obj];
  buffer   = mask_spec->buffer;

  db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

  switch (field_info.type)
  {
    case TYPE_CHAR   :
    case TYPE_CFLOAT :
    case TYPE_EXTERN : buffer += field_info.addr; break;
    default          : buffer  = mask_spec->text; break;
  } /* switch */

  size = strlen (buffer);

  if (pFilename == NULL)
    strcpy (filename, text_name);
  else
    strcpy (filename, pFilename);

  if ((pFilename == NULL) && ! get_save_filename (FEXPTEXT, NULL, 0L, FFILTER_TXT, NULL, text_path, FAILURE, filename, text_name))
    return;

  str_upper (filename);
  file_split (filename, NULL, text_path, text_name, NULL);

  f = file_create (filename);
  if (f >= 0)
  {
    if (file_write (f, size, buffer) != size) file_error (ERR_FILEWRITE, filename);
    file_close (f);
  } /* if */
  else
    file_error (ERR_FILECREATE, filename);
} /* mu_textexp */

/*****************************************************************************/

LOCAL BOOLEAN search_user (db, cursor, sysmask, username)
DB      *db;
CURSOR  *cursor;
SYSMASK *sysmask;
BYTE    *username;

{
  BOOLEAN ok, found;
  WORD    res;
  KEY     keyval;
  BASE    *base;

  base = db->base;

  if (! db_search (base, SYS_MASK, INX_TABLENAME, ASCENDING, cursor, sysmask, 0L)) return (ERR_NOMASK);

  ok  = db_buildkey (base, SYS_MASK, INX_TABLENAME, sysmask, keyval);
  ok  = db_read (base, SYS_MASK, sysmask, cursor, 0L, FALSE);
  res = db_status (base);
  dbtest (db);
  if (res != SUCCESS) return (res);
  found = ok && (strcmp (username, sysmask->username) == 0);

  while (ok && ! found)
  {
    ok  = ok && db_testcursor (base, cursor, ASCENDING, keyval);
    ok  = ok && db_read (base, SYS_MASK, sysmask, cursor, 0L, FALSE);
    res = db_status (base);
    dbtest (db);
    if (res != SUCCESS) return (res);
    if (ok) found = strcmp (username, sysmask->username) == 0;
  } /* while */

  if (found)
    return (SUCCESS);
  else
    return (ERR_NOUSERMASK);
} /* search_user */

/*****************************************************************************/

LOCAL VOID search_lookup (syslookup, num_lus, table, field)
SYSLOOKUP *syslookup;
WORD      num_lus;
WORD      *table, *field;

{
  WORD i;

  for (i = 0; i < num_lus; i++, syslookup++)
    if ((syslookup->table == *table) && (syslookup->column == *field))
    {
      *table = syslookup->reftable;
      *field = syslookup->refcolumn;
      return;
    } /* if, for */
} /* search_lookup */

/*****************************************************************************/

LOCAL BOOL LoadCalc (DB *db, SHORT sTable, CHAR *pCalcName, CALCCODE *pCalcCode)
{
  BOOL    bOk;
  CURSOR  cursor;
  SYSCALC *syscalc;

  syscalc = (SYSCALC *)mem_alloc ((LONG)sizeof (SYSCALC));
  if (syscalc == NULL) return (FALSE);

  bOk = FALSE;

  strcpy (syscalc->tablename, db_tablename (db->base, rtable (sTable)));
  strcpy (syscalc->name, pCalcName);

  if (db_search (db->base, SYS_CALC, 1, ASCENDING, &cursor, syscalc, 0L))
    if (db_read (db->base, SYS_CALC, syscalc, &cursor, 0L, FALSE))
    {
      *pCalcCode = syscalc->code;
      bOk = TRUE;
    } /* if */

  mem_free (syscalc);

  return (bOk);
} /* LoadCalc */

/*****************************************************************************/

LOCAL VOID RedrawObj (MASK_SPEC *mask_spec, WORD wObj)
{
  RECT    r;
  FATTR   fattr;
  MFIELD  *mfield;
  MOBJECT *mobject;
  SYSMASK *sysmask;

  sysmask = mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;
  mobject = &mobject [wObj];
  mfield  = &mobject->mfield;

  m_get_rect (mask_spec, vdi_handle, mfield->class, mobject, &r, &fattr);
  set_redraw (mask_spec->window, &r);
} /* RedrawObj */

/*****************************************************************************/

LOCAL LONG si_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  MASK_SPEC *mask_spec;
  WORD      src_tbl;
  T_INFO    *st_info;

  switch (msg)
  {
    case LBN_GETITEM    : mask_spec = (MASK_SPEC *)ListBoxGetSpec (tree, obj);
                          src_tbl   = rtable (mask_spec->table);
                          st_info   = &mask_spec->db->t_info [tableinx (mask_spec->db, src_tbl)];
                          return ((LONG)st_info->i_info [index + 1].indexname);
    case LBN_DRAWITEM   : break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* si_callback */

/*****************************************************************************/

LOCAL LONG dt_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  MASK_SPEC *mask_spec;

  switch (msg)
  {
    case LBN_GETITEM    : mask_spec = (MASK_SPEC *)ListBoxGetSpec (tree, obj);
                          return ((LONG)mask_spec->db->t_info [index].tablename);
    case LBN_DRAWITEM   : break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* dt_callback */

/*****************************************************************************/

LOCAL LONG di_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  MASK_SPEC *mask_spec;
  WORD      dst_tbl;
  T_INFO    *dt_info;

  switch (msg)
  {
    case LBN_GETITEM    : mask_spec = (MASK_SPEC *)ListBoxGetSpec (tree, obj);
                          dst_tbl   = mask_spec->db->t_info [ListBoxGetCurSel (join, JDT)].tablenum;
                          dt_info   = &mask_spec->db->t_info [tableinx (mask_spec->db, dst_tbl)];
                          return ((LONG)dt_info->i_info [index + 1].indexname);
    case LBN_DRAWITEM   : break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* di_callback */

/*****************************************************************************/

LOCAL VOID set_join (mask_spec)
MASK_SPEC *mask_spec;

{
  WORD    src_tbl, src_inx;
  WORD    dst_tbl, dst_inx;
  WORD    dt_active, i, j;
  STRING  tablename;
  EDFIELD *ed_field;
  T_INFO  *st_info, *dt_info;
  DB      *db;

  db      = mask_spec->db;
  src_tbl = rtable (mask_spec->table);
  strcpy (get_str (join, JSTABLE), table_name (db, src_tbl, tablename));

  set_rbutton (join, JASCEND, JASCEND, JDESCEND);

  st_info  = &db->t_info [tableinx (db, src_tbl)];
  ed_field = &mask_spec->ed_field [mask_spec->act_obj];

  src_inx = find_index (db->base, src_tbl, ed_field->field);
  if (src_inx == FAILURE) src_inx = mask_spec->inx;

  dt_active = 0;
  dst_tbl   = db->t_info [dt_active].tablenum;

  for (i = 0; i < db->tables; i++)
    if ((dst_inx = find_rel (db, src_tbl, src_inx, db->t_info [i].tablenum)) != FAILURE)
    {
      dt_active = i;
      dst_tbl   = db->t_info [dt_active].tablenum;
      break;
    } /* if, for */

  if (dst_inx == FAILURE)
    for (i = 0; i < db->tables; i++)
      for (j = 1; j < db->t_info [i].indexes; j++)
        if (find_rel (db, db->t_info [i].tablenum, db->t_info [i].i_info [j].indexnum, src_tbl) == src_inx)
        {
          dt_active = i;
          dst_tbl   = db->t_info [dt_active].tablenum;
          dst_inx   = db->t_info [i].i_info [j].indexnum;
          break;
       } /* if, for, for, if */

  if ((dst_tbl == src_tbl) && (db->tables > 1))
  {
    dt_active++;
    dst_tbl = db->t_info [dt_active].tablenum;
  } /* if */

  if (dst_inx == FAILURE) dst_inx = 1;

  dt_info = &db->t_info [tableinx (db, dst_tbl)];

  src_inx = indexinx (db, src_tbl, src_inx);
  dst_inx = indexinx (db, dst_tbl, dst_inx);

  if (src_inx >= st_info->indexes) src_inx = 0;
  if (dst_inx >= dt_info->indexes) dst_inx = 0;

  ListBoxSetCallback (join, JSI, si_callback);
  ListBoxSetStyle (join, JSI, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE | LBS_MANDATORY, TRUE);
  ListBoxSetCount (join, JSI, st_info->indexes - 1, NULL);
  ListBoxSetCurSel (join, JSI, src_inx - 1);
  ListBoxSetTopIndex (join, JSI, src_inx - 1);
  ListBoxSetLeftOffset (join, JSI, gl_wbox / 2);
  ListBoxSetSpec (join, JSI, (LONG)mask_spec);

  ListBoxSetCallback (join, JDT, dt_callback);
  ListBoxSetStyle (join, JDT, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE | LBS_MANDATORY, TRUE);
  ListBoxSetCount (join, JDT, db->tables, NULL);
  ListBoxSetCurSel (join, JDT, dt_active);
  ListBoxSetTopIndex (join, JDT, dt_active);
  ListBoxSetLeftOffset (join, JDT, gl_wbox / 2);
  ListBoxSetSpec (join, JDT, (LONG)mask_spec);

  ListBoxSetCallback (join, JDI, di_callback);
  ListBoxSetStyle (join, JDI, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE | LBS_MANDATORY, TRUE);
  ListBoxSetCount (join, JDI, dt_info->indexes - 1, NULL);
  ListBoxSetCurSel (join, JDI, dst_inx - 1);
  ListBoxSetTopIndex (join, JDI, dst_inx - 1);
  ListBoxSetLeftOffset (join, JDI, gl_wbox / 2);
  ListBoxSetSpec (join, JDI, (LONG)mask_spec);

  if ((st_info->indexes - 1 == 0) ||
      (db->tables == 0) ||
      (dt_info->indexes - 1 == 0))
    do_state (join, JOK, DISABLED);
  else
    undo_state (join, JOK, DISABLED);
} /* set_join */

/*****************************************************************************/

LOCAL VOID click_join (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BOOLEAN    dclick;
  WORD       dir;
  WORD       si_active, dt_active;
  WORD       src_tbl, src_inx, src_type;
  WORD       dst_tbl, dst_inx, dst_type;
  LONG       item;
  INDEX_INFO index_info;
  KEY        keyval;
  T_INFO     *st_info, *dt_info;
  DB         *db;
  MASK_SPEC  *mask_spec;

  ListBoxSetWindowHandle (join, JSI, window->handle);		/* window handle is vaild now */
  ListBoxSetWindowHandle (join, JDT, window->handle);
  ListBoxSetWindowHandle (join, JDI, window->handle);

  mask_spec = (MASK_SPEC *)window->special;
  db        = mask_spec->db;
  dclick    = FALSE;
  si_active = (WORD)ListBoxGetCurSel (join, JSI);
  dt_active = (WORD)ListBoxGetCurSel (join, JDT);

  if ((window->exit_obj == JSI) || (window->exit_obj == JDT) || (window->exit_obj == JDI))
  {
    item   = ListBoxClick (window->object, window->exit_obj, mk);
    dclick = (item != FAILURE) && (mk->breturn == 2);
  } /* if */

  src_tbl = rtable (mask_spec->table);
  st_info = &db->t_info [tableinx (db, src_tbl)];
  dst_tbl = db->t_info [ListBoxGetCurSel (join, JDT)].tablenum;
  src_inx = st_info->i_info [ListBoxGetCurSel (join, JSI) + 1].indexnum;
  dt_info = &db->t_info [tableinx (db, dst_tbl)];

  if (src_inx >= st_info->indexes) src_inx = 0;

  if ((si_active != ListBoxGetCurSel (join, JSI)) || (dt_active != ListBoxGetCurSel (join, JDT)))
  {
    dst_tbl = db->t_info [ListBoxGetCurSel (join, JDT)].tablenum;
    dt_info = &db->t_info [tableinx (db, dst_tbl)];

    dst_inx = find_rel (db, src_tbl, src_inx, dst_tbl);
    if (dst_inx == FAILURE) dst_inx = 1;
    dt_info = &db->t_info [tableinx (db, dst_tbl)];
    dst_inx = indexinx (db, dst_tbl, dst_inx);

    if (dst_inx >= dt_info->indexes) dst_inx = 0;

    ListBoxSetCount (join, JDI, dt_info->indexes - 1, NULL);
    ListBoxSetCurSel (join, JDI, dst_inx - 1);
    ListBoxSetTopIndex (join, JDI, dst_inx - 1);
    ListBoxRedraw (join, JDI);
  } /* if */

  st_info = &db->t_info [tableinx (db, src_tbl)];
  dt_info = &db->t_info [tableinx (db, dst_tbl)];
  dst_tbl = db->t_info [ListBoxGetCurSel (join, JDT)].tablenum;
  src_inx = st_info->i_info [ListBoxGetCurSel (join, JSI) + 1].indexnum;
  dst_inx = dt_info->i_info [ListBoxGetCurSel (join, JDI) + 1].indexnum;

  if (dclick && ! is_state (join, JOK, DISABLED))
  {
    window->exit_obj  = JOK;
    window->flags    |= WI_DLCLOSE;
  } /* if */

  switch (window->exit_obj)
  {
    case JOK     : v_indexinfo (db, src_tbl, src_inx, &index_info);
                   src_type = index_info.type;
                   v_indexinfo (db, dst_tbl, dst_inx, &index_info);
                   dst_type = index_info.type;

                   if (src_type != dst_type)
                   {
                     hndl_alert (ERR_INXTYPE);
                     return;
                   } /* if */

                   dir = (get_rbutton (join, JASCEND) == JASCEND) ? ASCENDING : DESCENDING;
                   db_buildkey (db->base, src_tbl, src_inx, mask_spec->buffer, keyval);
                   open_mask (NIL, db, dst_tbl, dst_inx, dir, "", keyval, 0L, NULL, NULL, FALSE);
                   break;
    case JHELP   : hndl_help (HJOIN);
                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
  } /* switch */
} /* click_join */

/*****************************************************************************/


/*****************************************************************************
 *
 * Module : CLIPBRD.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the clipboard functionality
 *
 * History:
 * 29.06.03: write_to_clipboard, read_from_clipboard added
 * 20.09.94: Handling of M_SUBMASK added
 * 02.05.94: STR128 replaced with FULLNAME
 * 19.07.91: For the present last modification
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "base.h"
#include "bclick.h"
#include "bnfield.h"
#include "butil.h"
#include "desktop.h"
#include "dialog.h"
#include "mask.h"
#include "mclick.h"

#include "export.h"
#include "clipbrd.h"

/****** DEFINES **************************************************************/

#define MAXTYPE     7                   /* max known types */
#define SCRAPSPEC   "SCRAP.*"           /* Scrap specification */
#define SCRAP_DIF   0x0020              /* DIF files */

#if GEMDOS
#define FIRST(path, spec)  (Fsfirst (path, spec) == 0)
#define NEXT               (Fsnext () == 0)
#else
#define FIRST(path, spec)  (Fsfirst (path, spec) > 0)
#define NEXT               (Fsnext () > 0)
#endif

/****** TYPES ****************************************************************/

#if MSDOS | FLEXOS | DR_C | LASER_C | LATTICE_C | MW_C
typedef struct
{
  BYTE  d_reserved [21];
  UBYTE d_attrib;
  UWORD d_time;
  UWORD d_date;
  ULONG d_length;
  BYTE  d_fname [14];
} DTA;
#endif

typedef struct
{
  UWORD type;
  BYTE  *suff;
} SCRAP_TYPE;

typedef struct
{
  BOOLEAN external;     /* TRUE if copy & paste go through clipboard path */
  WORD    wndclass;     /* window class */
  WORD    class;        /* class of objects */
  WORD    objs;         /* number of objects in clipbrd */
  LONG    size;         /* size of allocated memory */
  VOID    *buffer;      /* memory buffer for objects */
} CLIPBRD;

/****** VARIABLES ************************************************************/

LOCAL CLIPBRD clipbrd;  /* buffer for internal clipboard */

#if GEM & (GEM1 | GEM2)
LOCAL SCRAP_TYPE scrap_type [] =
{
  {SCRAP_CSV, "CSV"},
  {SCRAP_TXT, "TXT"},
  {SCRAP_GEM, "GEM"},
  {SCRAP_IMG, "IMG"},
  {SCRAP_DCA, "DCA"},
  {SCRAP_DIF, "DIF"},
  {SCRAP_USR, "USR"}
}; /* scrap_type */
#endif

/****** FUNCTIONS ************************************************************/

LOCAL VOID ins_tables _((WINDOWP window));
LOCAL VOID ins_fields _((WINDOWP window, WORD table));
LOCAL VOID ins_mobjs  _((WINDOWP window, RECT *r));

/*****************************************************************************/
/* initialize module                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN init_clipbrd (external)
BOOLEAN external;

{
  /* wenn external, dann nachchecken, ob Datei da ist */
  clipbrd.buffer   = NULL;
  clipbrd.external = external;

  clipbrd.class    = SEL_NONE;
  clipbrd.objs     = 0;
  clipbrd.size     = 0;

  return (TRUE);
} /* init_clipbrd */

/*****************************************************************************/
/* terminate module                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN term_clipbrd ()

{
  return (TRUE);
} /* term_clipbrd */

/*****************************************************************************/
/* correct SCRAP functions                                                   */
/*****************************************************************************/

GLOBAL WORD scrap_read (pscrap)
BYTE *pscrap;

{
  WORD    result;
#if GEM & (GEM1 | GEM2)
  FULLNAME path;
  BYTE    *p;
  DTA     dta, *old_dta;
  BOOLEAN ok;
  WORD    i;

  scrp_read (pscrap);

  if (*pscrap)
  {
    result = 0;

    old_dta = (DTA *)Fgetdta ();
    Fsetdta (&dta);
    strcpy (path, pscrap);

    i = strlen (path);

    if (path [i - 1] != PATHSEP)
    {
      path [i]     = PATHSEP;
      path [i + 1] = EOS;
    } /* if */

    strcat (path, SCRAPSPEC);

    ok = FIRST (path, 0x00);

    while (ok)
    {
      p = strrchr (dta.d_fname, SUFFSEP);

      if (p != NULL)
        for (i = 0, p++; i < MAXTYPE; i++)
          if (strcmp (p, scrap_type [i].suff) == 0)
            result |= scrap_type [i].type;

      ok = NEXT;
    } /* while */

    Fsetdta (old_dta);
  } /* if */
  else
    result = -1;
#else
  result = scrp_read (pscrap);
#endif

  return (result);
} /* scrap_read */

/*****************************************************************************/

GLOBAL WORD scrap_write (pscrap)
BYTE *pscrap;

{
  return (scrp_write (pscrap));
} /* scrap_write */

/*****************************************************************************/

GLOBAL WORD scrap_clear ()

{
  WORD     result;
  FULLNAME scrap;
#if GEM & (GEM1 | GEM2)
  FULLNAME path, s;
  DTA      dta, *old_dta;
  BOOLEAN  ok;
  WORD     i;
#endif

  result = 0;

  scrp_read (scrap);

  if (*scrap)
  {
#if GEM & (GEM1 | GEM2)
    result = 1;

    old_dta = (DTA *)Fgetdta ();
    Fsetdta (&dta);
    strcpy (path, scrap);

    i = strlen (path);

    if (path [i - 1] != PATHSEP)
    {
      path [i]     = PATHSEP;
      path [i + 1] = EOS;
    } /* if */

    strcat (path, SCRAPSPEC);

    ok = FIRST (path, 0x00);

    while (ok)
    {
      strcpy (s, scrap);
      strcat (s, dta.d_fname);

#if GEMDOS
      if (Fdelete (s) < 0) result = 0;
#else
      if (! Fdelete (s)) result = 0;
#endif

      ok = NEXT;
    } /* while */

    Fsetdta (old_dta);
#else
    result = scrp_clear ();
#endif
  } /* if */

  return (result);
} /* scrap_clear */

/*****************************************************************************/

GLOBAL VOID clear_clipbrd (external)
BOOLEAN external;

{
  if (clipbrd.buffer != NULL) mem_free (clipbrd.buffer);
  if (clipbrd.external) scrap_clear ();

  clipbrd.external = external;
  clipbrd.wndclass = FAILURE;
  clipbrd.class    = SEL_NONE;
  clipbrd.objs     = 0;
  clipbrd.size     = 0;
  clipbrd.buffer   = NULL;

  set_meminfo ();
} /* clear_clipbrd */

/*****************************************************************************/

GLOBAL VOID info_clipbrd (external)
BOOLEAN external;

{
  LONGSTR s;

  if (clipbrd.class == SEL_NONE)
    hndl_alert (ERR_CLIPEMPTY);
  else
  {
    if (external)
    {
      /* check_clip */
    } /* if */

    sprintf (s, alerts [ERR_CLIPINFO], FREETXT (clipbrd.class + FTABLE - 1), clipbrd.objs, clipbrd.size);
    open_alert (s);
  } /* if */
} /* info_clipbrd */

/*****************************************************************************/

GLOBAL BOOLEAN check_clipbrd (external)
BOOLEAN external;

{
  return (TRUE);
}

/*****************************************************************************/

GLOBAL BOOLEAN empty_clipbrd (window, external)
WINDOWP window;
BOOLEAN external;

{
  return (clipbrd.wndclass != window->class);
} /* empty_clipbrd */

/* GS 5.1c Start: */
/*****************************************************************************/
/* Schreibt Text ins Klemmbrett																							 */

GLOBAL VOID write_to_clipboard ( BYTE *buf, LONG len )
{
  FULLNAME scrap;
	WORD	datei;

  scrp_read (scrap);

  if (*scrap)
  {
  	scrap_clear ();										   			/* Erstmal alles l”schen			 */
		
	 	strcat (scrap, "scrap.txt");

	 	if ((datei = (int)Fcreate(scrap, 0)) >= 0)
	 	{
			Fwrite(datei, len, buf);
			Fclose(datei);
	 	}
		
  }
}

/*****************************************************************************/
/* List einen Text aus dem Klemmbrett																				 */

GLOBAL BYTE *read_from_clibboard( VOID )
{
	BYTE *buf;
  FULLNAME scrap;
	WORD	datei;
	LONG len;

  scrp_read (scrap);

  if (*scrap)
  {
		strcat(scrap, "scrap.txt");
		if ((datei = (int)Fopen(scrap, 0)) >= 0)
		{
			len = Fseek ( 0, datei, 2 );
			Fseek ( 0, datei, 0 );
			buf = mem_alloc ( len +1 );
			if ( buf == NULL )
			{
				Fclose ( datei );
				return NULL;
			}
			len = Fread ( datei, len, buf);
			Fclose(datei);
			buf[len] = '\0';
			return buf;
		}
	}
	
	return NULL;
}
/* Ende */

/*****************************************************************************/

GLOBAL BOOLEAN copy2clipbrd (window, class, objs, external)
WINDOWP window;
WORD    class;
SET     objs;
BOOLEAN external;

{
  WORD      num_objs, i, obj;
  WORD      table;
  LONG      size;
  SYSMASK   *srcmask;
  SYSMASK   *dstmask;
  MOBJECT   *srcobject;
  MOBJECT   *dstobject;
  SYSCOLUMN *srccolumn;
  SYSCOLUMN *dstcolumn;
  MASK_SPEC *mask_spec;
  BASE_SPEC *base_spec;

  size     = 0;
  num_objs = setcard (objs);
  table    = sel.table;

if (class == SEL_MOBJ) return (FALSE); /* not yet implemented correctly */

  switch (class)
  {
    case SEL_TABLE : break;
    case SEL_FIELD : size = num_objs * sizeof (SYSCOLUMN);                  break;
    case SEL_KEY   : hndl_alert (ERR_CLIPMULTIKEY);                         break;
    case SEL_MOBJ  : size = num_objs * sizeof (MOBJECT) + sizeof (SYSMASK); break;
  } /* switch */

  if (size == 0) return (FALSE);

  clipbrd.buffer = mem_alloc (size);
  if (clipbrd.buffer == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (FALSE);
  } /* if */

  clipbrd.external = external;
  clipbrd.wndclass = window->class;
  clipbrd.class    = class;
  clipbrd.objs     = setcard (objs);
  clipbrd.size     = size;

  if (class == SEL_MOBJ)        /* create a copy of source mask */
  {
    mask_spec = (MASK_SPEC *)window->special;
    srcmask   = &mask_spec->mask;
    dstmask   = clipbrd.buffer;
    srcobject = (MOBJECT *)srcmask->mask.buffer;
    dstobject = (MOBJECT *)dstmask->mask.buffer;
    *dstmask  = *srcmask;
  } /* if */
  else
  {
    base_spec = (BASE_SPEC *)window->special;
    srccolumn = &base_spec->syscolumn [abscol (base_spec, table, 0)];
    dstcolumn = clipbrd.buffer;
  } /* else */

  for (i = obj = 0; obj < num_objs; i++, srccolumn++, srcobject++)
    if (setin (objs, i))
    {
      switch (class)
      {
        case SEL_TABLE :                            break;
        case SEL_FIELD : *dstcolumn++ = *srccolumn; break;
        case SEL_KEY   :                            break;
        case SEL_MOBJ  : *dstobject++ = *srcobject; break;
      } /* switch */

      obj++;
  } /* if */

  set_meminfo ();

  return (TRUE);
} /* copy2clipbrd */

/*****************************************************************************/

GLOBAL BOOLEAN paste_clipbrd (window, r, external)
WINDOWP window;
RECT    *r;
BOOLEAN external;

{
  SEL_SPEC sel_spec;
  MKINFO   mk;

  if (window->class != clipbrd.wndclass)
  {
    hndl_alert (ERR_NOMATCH);
    return (FALSE);
  } /* if */

  switch (window->class)
  {
    case CLASS_BASE : if (r == NULL)
                        sel_spec = sel;
                      else
                      {
                        mk.mox   = r->x;
                        mk.moy   = r->y;
                        sel_spec = b_find_objs (window, &mk);
                      } /* else */

                      if ((sel_spec.class == SEL_NONE) && (clipbrd.class != SEL_TABLE))
                      {
                        hndl_alert (ERR_FIELDINTBL);
                        return (FALSE);
                      } /* if */

                      if (external)
                      {
                      } /* if */
                      else
                        switch (clipbrd.class)
                        {
                          case SEL_TABLE : ins_tables (window);                 break;
                          case SEL_FIELD : ins_fields (window, sel_spec.table); break;
                        } /* switch, else */
                      break;
    case CLASS_MASK : if (external)
                      {
                      } /* if */
                      else
                        ins_mobjs (window, r);
                      break;
    default         : return (FALSE);
  } /* switch */

  set_redraw (window, &window->scroll);

  return (TRUE);
} /* paste_clipbrd */

/*****************************************************************************/

LOCAL VOID ins_tables (window)
WINDOWP window;

{
} /* ins_tables */

/*****************************************************************************/

LOCAL VOID ins_fields (window, table)
WINDOWP window;
WORD    table;

{
  BOOLEAN   ok;
  WORD      i, field;
  SYSCOLUMN syscolumn;
  SYSCOLUMN *srccolumn;
  SYSCOLUMN *dstcolumn;
  SYSTATTR  *systattr;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;
  srccolumn = clipbrd.buffer;
  dstcolumn = &syscolumn;
  ok        = TRUE;

  for (i = 0; ok && (i < clipbrd.objs); i++, srccolumn++)
  {
    *dstcolumn         = *srccolumn;
    dstcolumn->format  = dstcolumn->type;
    dstcolumn->flags  &= ~ COL_ISINDEX;

    if (is_funique (base_spec, table, dstcolumn->name))
      field = add_field (base_spec, table, dstcolumn, NULL);
    else
    {
      dstcolumn->number  = FAILURE;
      dstcolumn->flags  |= INS_FLAG;

      ok = mnewfield (window, table, dstcolumn, NULL, &field) != NFCANCEL;
    } /* else */

    systattr = &base_spec->systattr [table];
    get_tblwh (base_spec, table, &systattr->width, &systattr->height);
    systattr->flags     |= UPD_FLAG;
    base_spec->modified  = TRUE;
  } /* for */
} /* ins_fields */

/*****************************************************************************/

LOCAL VOID ins_mobjs (window, r)
WINDOWP window;
RECT    *r;

{
  LONGSTR   s;
  WORD      result, obj, i;
  WORD      x, y;
  BYTE      *buffer;
  BYTE      *s1, *s2, *s3, *s4;
  MFIELD    *mfield;
  MLINE     *mline;
  MTEXT     *mtext;
  MGRAF     *mgraf;
  MBUTTON   *mbutton;
  MSUBMASK  *msubmask;
  MOBJECT   *mobject, dst_obj;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  mobject   = clipbrd.buffer;
  buffer    = clipbrd.buffer;
  result    = SUCCESS;

  for (i = 0; (result == SUCCESS) && (i < clipbrd.objs); i++, mobject++)
  {
    dst_obj = *mobject;
    mfield  = &dst_obj.mfield;

    x = r->x /* + diff->w */ - window->scroll.x + window->doc.x * window->xfac;
    y = r->y /* + diff->h */ - window->scroll.y + window->doc.y * window->yfac;

    if (x < 0) x = 0;
    if (y < 0) y = 0;

    mfield->x = x * M_XUNITS / gl_wbox;
    mfield->y = y * M_YUNITS / gl_hbox;

    s1 = s2 = s3 = s4 = NULL;

    switch (mfield->class)
    {
      case M_FIELD   : s1 = &buffer [mfield->table_name];;
                       s2 = &buffer [mfield->field_name];;
                       s3 = &buffer [mfield->label_name];

                       if (IS_CHECKBOX (mfield->type) || IS_RBUTTON (mfield->type))
                         if (mfield->extra >= 0) s4 = &buffer [mfield->extra];
                       break;
      case M_LINE    : mline     = &mobject->mline;
                       mfield->w = mfield->x + mline->x2 - mline->x1;
                       mfield->h = mfield->y + mline->y2 - mline->y1;
                       break;
      case M_BOX     :
      case M_RBOX    : break;
      case M_TEXT    : mtext = &mobject->mtext;
                       s1 = &buffer [mtext->text];
                       break;
      case M_GRAF    : mgraf = &mobject->mgraf;
                       s1 = &buffer [mgraf->filename];
                       break;
      case M_BUTTON  : mbutton = &mobject->mbutton;
                       s1 = &buffer [mbutton->text];
                       s2 = &buffer [mbutton->param];
                       break;
      case M_SUBMASK : msubmask = &mobject->msubmask;
                       s1 = &buffer [msubmask->SourceObject];
                       s2 = &buffer [msubmask->LinkMaster];
                       s3 = &buffer [msubmask->LinkChild];
                       break;
    } /* switch */

    result = add_mobject (mask_spec, &dst_obj, s1, s2, s3, s4, &obj);

    if (result != SUCCESS)
      switch (result)
      {
        case ERR_OBJEXISTS  : sprintf (s, alerts [ERR_OBJEXISTS], s1, s2);
                              open_alert (s);
                              break;
        default             : hndl_alert (result);
                              break;
      } /* switch, if */
  } /* for */
} /* ins_mobjs */

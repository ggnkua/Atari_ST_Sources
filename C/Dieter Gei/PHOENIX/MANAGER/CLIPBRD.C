/*****************************************************************************
 *
 * Module : CLIPBRD.C
 * Author : Jrgen Geiž, Gerhard Stoll
 *
 * Creation date    : 20.03.03
 * Last modification:
 *
 *
 * Description: This module implements the clipboard functionality
 *
 * History:
 * 22.06.03: Alle Cliboardfunktionen aus global.c kopiert
 *           write_to_clipboard, read_from_clipboard eingefgt.
 * 20.03.03: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"

#include "windows.h"

#include "manager.h"

#include "database.h"


#include "root.h"
#include "desktop.h"


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
} CLIPBRD_STRUCT;

/****** VARIABLES ************************************************************/

LOCAL CLIPBRD_STRUCT clipbrd;  /* buffer for internal clipboard */
LOCAL WORD     clip_mode = CM_RAM;
LOCAL LONG     clip_size [CF_FORMATS];
LOCAL VOID     *clip_data [CF_FORMATS];
LOCAL FULLNAME clip_filename;

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
	ClipboardEmpty ();

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
    /*   hndl_alert (ERR_CLIPEMPTY)*/  ;
  else
  {
    if (external)
    {
      /* check_clip */
    } /* if */

/*

    sprintf (s, alerts [ERR_CLIPINFO], FREETXT (clipbrd.class + FTABLE - 1), clipbrd.objs, clipbrd.size);
    open_alert (s);

*/


  } /* if */
} /* info_clipbrd */


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
			buf[len] = EOS;
			return buf;
		}
	}
	
	return NULL;
}

/* [GS] 5.1c Start: */
/*****************************************************************************/

GLOBAL WORD ClipboardGetMode (VOID)
{
  return (clip_mode);
} /* ClipboardGetMode */

/*****************************************************************************/

GLOBAL WORD ClipboardSetMode (WORD wMode)
{
  WORD old_mode;

  old_mode  = clip_mode;
  clip_mode = wMode;

  return (old_mode);
} /* ClipboardSetMode */

/*****************************************************************************/

GLOBAL VOID ClipboardGetName (BYTE *pszFileName)
{
  strcpy (pszFileName, clip_filename);
} /* ClipboardGetName */

/*****************************************************************************/

GLOBAL VOID ClipboardSetName (BYTE *pszFileName)
{
  strcpy (clip_filename, pszFileName);
} /* ClipboardSetName */

/*****************************************************************************/

GLOBAL LONG ClipboardGetSize (WORD wFormat)
{
  return (clip_size [wFormat]);
} /* ClipboardGetSize */

/*****************************************************************************/

GLOBAL VOID ClipboardSetSize (WORD wFormat, LONG lSize)
{
  clip_size [wFormat] = lSize;
} /* ClipboardSetSize */

/*****************************************************************************/

GLOBAL VOID *ClipboardGetData (WORD wFormat)
{
  return (clip_data [wFormat]);
} /* ClipboardGetData */

/*****************************************************************************/

GLOBAL VOID ClipboardSetData (WORD wFormat, VOID *pData)
{
  mem_free (clip_data [wFormat]);
  clip_data [wFormat] = pData;
} /* ClipboardSetMode */

/*****************************************************************************/

GLOBAL VOID ClipboardEmpty (VOID)
{
  WORD i;

  for (i = 0; i < CF_FORMATS; i++)
  {
    mem_free (clip_data [i]);
    clip_data [i] = NULL;
    clip_size [i] = 0;
  } /* for */
} /* ClipboardEmpty */

/* Ende */
/*****************************************************************************
 *
 * Module : PH_LIB.C
 * Author : Gerhard Stoll
 *
 * Creation date    : 27.10.02
 * Last modification: s.u.
 *
 *
 * Description: Allgemeine Funktionen die vom Manager und Designer benutzt werden.
 *
 * History:
 * 25.12.02: get_magic added
 * 02.11.02: malloc_global 
 * 27.10.02: appl_getinfo, get_cookie
 *****************************************************************************/

#include "import.h"

#include "export.h"

/****** TYPES ****************************************************************/

typedef struct
{
    LONG cookie_id;		   /* Identifikations-Code */
    LONG cookie_value;   /* Wert des Cookies     */
} COOKJAR;

/* aus magx.h entnommen */
/* Sconfig(2) -> */

typedef struct
   {
   char      *in_dos;                 /* Adresse der DOS- Semaphore */
   int       *dos_time;               /* Adresse der DOS- Zeit      */
   int       *dos_date;               /* Adresse des DOS- Datums    */
   long      res1;                    /*                            */
   long      res2;                    /*                            */
   long      res3;                    /* ist 0L                     */
   void      *act_pd;                 /* Laufendes Programm         */
   long      res4;                    /*                            */
   int       res5;                    /*                            */
   void      *res6;                   /*                            */
   void      *res7;                   /* interne DOS- Speicherliste */
   void      (*resv_intmem)();        /* DOS- Speicher erweitern    */
   long      (*etv_critic)();         /* etv_critic des GEMDOS      */
   char *    ((*err_to_str)(char e)); /* Umrechnung Code->Klartext  */
   long      res8;                    /*                            */
   long      res9;                    /*                            */
   long      res10;                   /*                            */
   } DOSVARS;

/* os_magic -> */

typedef struct
     {
     long magic;                   /* muû $87654321 sein              */
     void *membot;                 /* Ende der AES- Variablen         */
     void *aes_start;              /* Startadresse                    */
     long magic2;                  /* ist 'MAGX'                      */
     long date;                    /* Erstelldatum ttmmjjjj           */
     void (*chgres)(int res, int txt);  /* Auflîsung Ñndern           */
     long (**shel_vector)(void);   /* residentes Desktop              */
     char *aes_bootdrv;            /* von hieraus wurde gebootet      */
     int  *vdi_device;             /* vom AES benutzter VDI-Treiber   */
     void *reservd1;
     void *reservd2;
     void *reservd3;
     int  version;                 /* z.B. $0201 ist V2.1             */
     int  release;                 /* 0=alpha..3=release              */
     } AESVARS;

/* Cookie MagX --> */

typedef struct
     {
     long    config_status;
     DOSVARS *dosvars;
     AESVARS *aesvars;
     } MAGX_COOKIE;


/* NVDI Cookie */
     typedef struct
     {
        WORD nvdi_version;           /* Version im BCD-Format       */
        ULONG nvdi_datum;            /* Datum im BCD-Format         */
        UWORD nvdi_config;
     } NVDI_STRUC;

/*****************************************************************************/
/* Teste ob appl_getinfo vorhanden ist																			 */

GLOBAL WORD appl_xgetinfo (type, out1, out2, out3, out4)
WORD type;
WORD *out1, *out2;
WORD *out3, *out4;
{

  BOOLEAN has_agi = FALSE;
 
  has_agi = ( /*(_GemParBlk.global[0] == 0x399 && (is_MagiC() >= 0x0200)) */
            /*||*/ (_GemParBlk.global[0] >= 0x400)
            || (appl_find ("?AGI") >= 0));
 
  if (has_agi)
      return (appl_getinfo (type, out1, out2, out3, out4));
 
  else return (0);
 
} /* appl_xgetinfo */

/*****************************************************************************/
/* Fordert Speicher an, wenn mîglich globalen Speicher an										 */

GLOBAL VOID *malloc_global ( LONG size )
{
  if ( Sysconf(-1) != EINVFN )
		return Mxalloc ( size, 0x23);
  else
    return Malloc ( size );
}



/*****************************************************************************/
/* Fragt den Wert eines Cookies ab. Als Parameter werden dabei die ID des zu */
/* suchenden Cookies, sowie ein Zeiger auf den gefundenen Wert Åbergeben. 	 */
/* Die Routine liefert den Wert FALSE falls der angegebene Cookie nicht			 */
/* existiert... 																														 */

GLOBAL WORD get_cookie( LONG cookie, void *value )
{
  static WORD use_ssystem = -1;
  COOKJAR *cookiejar;
  LONG    val = -1l;
  WORD    i=0;
  
  if( use_ssystem < 0 )
    use_ssystem = (Ssystem(S_INQUIRE, 0l, 0)==E_OK);
  
  if(use_ssystem)
  {
    if( Ssystem(S_GETCOOKIE, cookie, (LONG)&val)==E_OK )
    {
      if( value!=NULL )
        *(LONG *)value = val;
      return TRUE;
    }
  }
  else
  {
    /* Zeiger auf Cookie Jar holen */
    cookiejar = (COOKJAR *)(Setexc(0x05A0/4,(const void (*)(void))-1));
    if( cookiejar )
    {
      for( i=0 ; cookiejar[i].cookie_id ; i++ )
        if( cookiejar[i].cookie_id==cookie )
        {
          if( value )
            *(LONG *)value = cookiejar[i].cookie_value;
          return TRUE;
        }
    }
  }
  
  return FALSE;
}

/*****************************************************************************/
/* Liefert die Version von MagiC oder 0 falls nicht vorhanden								 */

GLOBAL WORD get_magic ( void )
{
	LONG			v;
	WORD			version;
	MAGX_COOKIE	*Cook;
	
	if (get_cookie( 'MagX', &v ) )
	{
		Cook = (MAGX_COOKIE *)v;
		version = Cook->aesvars->version;
	} /* if */
	else
		version = 0;

	return version;
}

/*****************************************************************************/
/* Liefert die Version von NVDI oder 0 falls nicht vorhanden								 */

GLOBAL WORD get_nvdi ( void )
{
	LONG			v;
	WORD			version;
	NVDI_STRUC	*Cook;
	
	if (get_cookie( 'NVDI', &v ) )
	{
		Cook = (NVDI_STRUC *)v;
		version = Cook->nvdi_version;
	} /* if */
	else
		version = 0;

	return version;
}

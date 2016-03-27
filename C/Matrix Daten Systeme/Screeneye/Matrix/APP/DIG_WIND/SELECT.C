/* File 	:	select.c
   Author 	:	Borland. Adapted by HG.
   Date		:	19/08/1993
   
   SELECT.C provides an interface to the GEM file selector
   box ( adapted from Turbo C user manual )
*/

# define FIXED_EXTENSION 0

/* ------------- include files ------------ */
# include <stdio.h>
# include <string.h>
# include <errno.h>
# include <tos.h>
# include <aes.h>

# include <global.h>
# include "select.h"
# define MOPEN 0
# define MEXT 1

/* ------------- constants ---------------- */
# define EOS		'\0'
# define BACKSLASH	'\\'
# define DOT		'.'

/* ------------- global variables -------- */
char	Path[16][STPATHLEN] ;
bool	Inipath[16] = {FALSE, FALSE, FALSE, FALSE,
					   FALSE, FALSE, FALSE, FALSE,
					   FALSE, FALSE, FALSE, FALSE,
					   FALSE, FALSE, FALSE, FALSE};
					   
/* ----------------------------------------------- usage ---------- */
int usage( int m )
{
# if 0	
	char	*msg;
	int		button = 0;

	if ( (msg = GetMatGemString (m)) != NULL)
    	button = form_alert (1, msg);
    return (button);
# else
	m = m ;
	return 0 ;
# endif
}


/* ------------------------------------------------- GetDrives --- */
long GetDrives (void)
{
	return (Drvmap());
}


/* ------------------------------------------------- NoPath ------ */
bool NoPath (int drive)
{
	return (!Inipath[drive]);
}


/* ------------------------------------------------- InitPath ---- */
void InitPath (int drive)
{
	char	tmp_path[STPATHLEN];

	if (drive == CURRENT_DRIVE)
	{
		Dgetpath (tmp_path, CURRENT_DRIVE);
		drive = Dgetdrv() + 1;
		strcpy (Path[drive], tmp_path);
	}
	else
		Dgetpath (Path[drive], drive);
		
	if ((Path[drive][0] == BACKSLASH) || (Path[drive][0] == '\0'))
	{
    	strcpy (tmp_path, Path[drive]);
		Path[drive][0] = (char)(drive-1) + 'A';
		Path[drive][1] = ':';
		Path[drive][2] = '\0';
		strcat (Path[drive], tmp_path);
	}
	strcat (Path[drive], "\\*.");
	Inipath[drive] = TRUE;
}


/* ----------------------------------------------- GetDrive ------- */
int GetDrive (void)
{
	return (Dgetdrv() + 1);
}


/* ----------------------------------------------- SetDrive ------- */
void SetDrive (int drive)
{
	Dsetdrv (drive-1);
}


/* ----------------------------------------------- build_fname ---- */

void build_fname( char *dest, char *s1, char *s2 )
{
   char *cptr;

   strcpy( dest, s1 );                 /* Copy path					*/
   cptr = strrchr( dest, (int) BACKSLASH);
   strcpy( ++cptr, s2);                /* Hang the filename	on..	*/
}                                      /* ... the end				*/
	
	
/* ----------------------------------------------- op_fbox -------- */
FILE *op_fbox( char const *mode, char const *ext, char *name)
{
   char x[STPATHLEN + STFILELEN];      /* Buffer fÅr Pfadnamen + Datei- */
                                       /* namen.                        */
   int  b;                             /* EnthÑlt Code des Buttons der  */
                                       /* zum Abbruch der Dateiauswahl  */
                                       /* fÅhrte.                       */
   int  version;                       /* wird GEMDOS-Versionsnummer    */
                                       /* erhalten.                     */
   int  result;
   FILE *f ;						   /* AusgewÑhltes File				*/
   char	*cptr;						   /* Pointer into Path				*/
   int	drive;						   /* Current drive number 			*/
   char tmp_path[STPATHLEN];		   /* temporary path 				*/

   *name = EOS;                        /* Dateinamen lîschen. 		    */
   f = NULL;						   /* Kein File selektiert.			*/
   version = Sversion ( );             /* fsel_exinput steht erst ab	*/
   version >>= 8;                      /* Version 1.40 zur VerfÅgung    */

   drive = Dgetdrv() + 1;
   strcpy (tmp_path, Path[drive]);
   if ((cptr = strrchr (tmp_path, (int)DOT)) != NULL)
	   strcpy (++cptr, ext);

   if ( version <= 20 )                /* Dateiauswahl.                 */
      result = fsel_input (tmp_path, name, &b );
   else if (*mode == 'r')
         result = fsel_exinput (tmp_path, name, &b, "Load File" );
   else if (*mode == 'w')
         result = fsel_exinput (tmp_path, name, &b, "Save File" );

   if ( result == 0 )
      usage( result );                 /* Fehler dabei aufgetreten.     */
   else if ( b != 0)
   {
# if FIXED_EXTENSION
      if (strstr (name, ext) != NULL)
      {
# endif FIXED_EXTENSION
		 drive = (int)tmp_path[0] - 'A' + 1; /* check if drive changed */
		 strcpy (Path[drive], tmp_path);
         build_fname( x, Path[drive], name );    /* Pfad- und Dateinamen konkat.  */
                                          		  /* Datei 'testen'.               */
	     if ((f = fopen (x, mode)) == NULL)
	        usage (MOPEN);
# if FIXED_EXTENSION
	  }
	  else
	  	 usage (MEXT);
# endif FIXED_EXTENSION
   }
   return ( f );
}

/* ----------------------------------------------- op_fbox -------- */
int op_fbox_name ( char const *mode, char const *ext,
				   char *name, int *drive)
{
   char x[STPATHLEN + STFILELEN];      /* Buffer fÅr Pfadnamen + Datei- */
                                       /* namen.                        */
   int  b;                             /* EnthÑlt Code des Buttons der  */
                                       /* zum Abbruch der Dateiauswahl  */
                                       /* fÅhrte.                       */
   int  version;                       /* wird GEMDOS-Versionsnummer    */
                                       /* erhalten.                     */
   int  result;
   char	*cptr;						   /* Pointer into Path				*/
   char tmp_path[STPATHLEN];		   /* temporary path 				*/

   *name = EOS;                        /* Dateinamen lîschen. 		    */
   version = Sversion ( );             /* fsel_exinput steht erst ab	*/
   version >>= 8;                      /* Version 1.40 zur VerfÅgung    */

   *drive = Dgetdrv() + 1;
   strcpy (tmp_path, Path[*drive]);
   if ((cptr = strrchr (tmp_path, (int)DOT)) != NULL)
	   strcpy (++cptr, ext);

   if ( version <= 20 )                /* Dateiauswahl.                 */
      result = fsel_input (tmp_path, name, &b );
   else if (*mode == 'r')
         result = fsel_exinput (tmp_path, name, &b, "Load File" );
   else if (*mode == 'w')
         result = fsel_exinput (tmp_path, name, &b, "Save File" );

   if ( ( result == 0 ) || ( b == 0 ) )
   {
      usage ( result );                /* Fehler dabei aufgetreten. */
      return 0;
   }
   
   *drive = (int)tmp_path[0] - 'A' + 1; /* check if drive changed */
   strcpy (Path[*drive], tmp_path);
   Inipath[*drive] = TRUE;
   build_fname( x, Path[*drive], name );/* Pfad- und Dateinamen konkat.  */
   strcpy ( name, x );                 /* Copy full name & path					*/
   
   return 1 ;
}


/*
 * SvrFlSel.c
 *
 * Purpose:
 * -------- 
 * S‚lecteur de fichiers
 *
 * History:
 * --------
 * 22.01.95: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"GEM_DIRS.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include <string.h>					/* header tt de chaines */
	#include	<stdlib.h>					/* Pour malloc etc.. */
   #include <tos.h>
	#include <time.h>

/*
 * Custom headers:
 */
	#include "OS_DIRS.H"

	#include "SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "DEBUG_PU.H"

/*
 * Variables:
 */
	DTA	DTA_main;

/*
 * ---------------------------------------------------------------------
 */
 
/*
 * Dirs_Init()
 *
 * 23.03.95: Created
 */
void Dirs_Init( void )
{
	TRACE0( "Initializing " THIS_FILE );

	/*
	 * Fixe DTA:
	 */
	Fsetdta( &DTA_main );
}


/*
 * Dir_Read(-)
 *
 * Lecture d'un directory et stockage en RAM
 *
 * 23.03.95: Created
 * 24.03.95: V‚rifie qu'on a un path
 * 25.03.95: utilisation d'un tableau
 * 12.07.95: corrig‚ bug de realloc d'un ptr NULL
 */
int Dir_Read( 									/* Out: Nbre d'elts dans dir */
		char 		  * cpsz_Path,				/* In:  Chemin d'accŠs + masque */
		DIRENTRY	*** pTpDirEnt,				/* Out: Tableau de ptrs sur DIRENT */
		int		  * pnb_TableEntries )	/* Out: Nbre d'entr‚es dans table */
{
#define	DIRTABLE_STEP	10

	DIRENTRY	*	pDirEnt_Current;	
	DTA		*	pDTA;
 	int			FsRes;		
	UINT			u_time;
	UINT			u_date;
 	struct tm	time;
 	time_t		timet;
	int			nb_DirEntries = 0;

	*pTpDirEnt = NULL;
	*pnb_TableEntries = 0;

	/*
	 * V‚rifie adresse DTA:
	 */
	pDTA = Fgetdta();
	if( pDTA != &DTA_main )
	{
		signale( "DTA has moved!!!" );
		return 0;
	} 	

	/*
	 * V‚rifie qu'on a un chemin d'accŠs avec masque de recherche:
	 */
	if( cpsz_Path == NULL )
	{
		return 0;
	}
	
	for( FsRes = Fsfirst( cpsz_Path, FA_SUBDIR ); 	
			FsRes == 0;
			 FsRes = Fsnext() )
	{
 		/* printf("Found: %X %s %ld\n", (int) DTA_main .d_attrib, DTA_main .d_fname, DTA_main .d_length ); */

		if( (DTA_main .d_attrib & FA_SUBDIR) && (DTA_main .d_fname)[0] == '.' )
		{	
			switch( (DTA_main .d_fname)[1] )
			{
				case	'\0':
				case	'.':
					/*
					 * Si nom de dossier "." ou commence par "..":
					 * On ne se pr‚ocuupe pas de cette entr‚e
					 */
					continue;
			}
		}

		/*
		 * Cr‚e une entr‚e de dir:
		 */
		pDirEnt_Current = MALLOC( sizeof( DIRENTRY ) );
		pDirEnt_Current -> uc_attrib = '\0';
		pDirEnt_Current -> sz_fname[0] = '\0';
		pDirEnt_Current -> ul_length = 0;
		pDirEnt_Current -> time_LastChange = 0;
		
		/*
		 * On l'ajoute dans la liste
		 */
		if( nb_DirEntries >= *pnb_TableEntries )
		{	/*
			 * Si la liste est pleine, il faut l'agrandir
			 */
			(*pnb_TableEntries) += DIRTABLE_STEP;
			if( *pTpDirEnt == NULL )
			{
				*pTpDirEnt = MALLOC( sizeof(DIRENTRY*) * (*pnb_TableEntries) );	
			}
			else
			{
	 			*pTpDirEnt = REALLOC( *pTpDirEnt, sizeof(DIRENTRY*) * (*pnb_TableEntries) );	
	 		}
		}
		(*pTpDirEnt)[ nb_DirEntries++ ] = pDirEnt_Current;
		

		/*
		 * Sauve valeurs lues dans l'entr‚ee de DIR:
		 */
		pDirEnt_Current -> uc_attrib = DTA_main .d_attrib;
		strcpy( pDirEnt_Current -> sz_fname, DTA_main .d_fname );
		pDirEnt_Current -> ul_length = DTA_main .d_length;

		/*
		 * Traduction de l'heure en format UNIX:
		 */
		 
		u_time = DTA_main .d_time;
		time .tm_sec  = (u_time & 0x001F) << 1;
      time .tm_min  = (u_time & 0x07E0 ) >> 5;
      time .tm_hour = (u_time & 0xF800 ) >> 11;

		u_date = DTA_main .d_date;
		time .tm_mday = u_date & 0x001F;
      time .tm_mon  = ((u_date & 0x01E0 ) >> 5) -1;	/* (0..11) */
      time .tm_year = 80 + ((u_date & 0xFE00 ) >> 9);	/* (since 1900) */

      time .tm_wday = -1;    /* Wochentag (0..6) -> (So..Sa) */
      time .tm_yday = -1;    /* Tag im Jahr (0..365)         */
      time .tm_isdst = 0;
		
		timet = mktime( &time );
		pDirEnt_Current -> time_LastChange = timet;
		
		/* printf( "date %X-%X     %d:%d:%d %d/%d/%d  %ld  %s\n",
		 *			u_time, u_date,
		 *			time .tm_hour, time .tm_min, time .tm_sec,
		 *			time .tm_mday, time .tm_mon +1, time .tm_year +1900,
		 *			timet,
		 *			ctime( &timet ) );
		 */
 	}

	/*
	 * Retourne la liste:
	 */
	return 	nb_DirEntries;
}



/*
 * Dir_Forget(-)
 *
 * Efface un dir charg‚ en m‚moire
 *
 * 24.03.95: Created
 * 25.03.95: utilisation d'un tableau
 */
void Dir_Forget(
		DIRENTRY	** TpDirEnt, 	/* In: Table de DirEntries */
		int			nb_DirEnt )	/* Ib: Nbre d'entr‚es utilis‚es */
{
	int i;

	if( TpDirEnt == NULL )
	{
		return;
	}

	for( i=0; i<nb_DirEnt; i++ )
	{
		FREE( TpDirEnt[i] );
	}

	FREE( TpDirEnt );
}


/*
 * Dir_Sort_Comp(-)
 *
 * Pour etre appell‚ par Dir_Sort()
 *
 * 25.03.95: Created
 */
int Dir_Sort_Comp( 					
		DIRENTRY	** pDirEnt1, 
		DIRENTRY	** pDirEnt2 )
{
	if( (*pDirEnt1) -> uc_attrib & FA_SUBDIR )
	{
		if( !((*pDirEnt2) -> uc_attrib & FA_SUBDIR) ) 
		{
			return -1;
		}
	}
	else if( (*pDirEnt2) -> uc_attrib & FA_SUBDIR ) 
	{
		return 1;
	}

	return strcmp( (*pDirEnt1) -> sz_fname, (*pDirEnt2) -> sz_fname );
}

/*
 * Dir_Sort(-)
 *
 * 25.03.95: Created
 */
void Dir_Sort( 					
		DIRENTRY	** TpDirEnt,	/* In: Tableau de ptrs sur DIRENT */
		int		 	nb_DirEnt )	/* In: Nbre d'entr‚es utilis‚es dans table */
{
	qsort( TpDirEnt, nb_DirEnt, sizeof( DIRENTRY* ), Dir_Sort_Comp );
}


/*
 * File_Exists(-)
 *
 * Dit si le fichier sp‚cifi‚ existe
 *
 * 25.03.95: Created
 */
BOOL	File_Exists( 						/* Out: True si existe */
			const char * cpsz_Path )	/* In:  Chemin d'accŠs complet */
{
	if( Fsfirst( cpsz_Path, 0 ) == 0 )
	{	/*
		 * Existe
		 */
		return	TRUE_1;
	}

	return FALSE0;		
}			
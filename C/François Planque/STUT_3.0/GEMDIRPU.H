/*
 * Gem_Dir_Public.h
 */

#include "OS_DIRS.H"

	void Dirs_Init( void );

	int Dir_Read( 									/* Out: Nbre d'elts dans dir */
		char 		  * cpsz_Path,				/* In:  Chemin d'accŠs + masque */
		DIRENTRY	*** pTpDirEnt,				/* Out: Tableau de ptrs sur DIRENT */
		int		  * pnb_TableEntries );	/* Out: Nbre d'entr‚es dans table */

	void Dir_Forget(
		DIRENTRY	** TpDirEnt, 		/* In: Table de DirEntries */
		int			nb_DirEnt );	/* Ib: Nbre d'entr‚es utilis‚es */

	void Dir_Sort( 					
		DIRENTRY	** TpDirEnt,		/* In: Tableau de ptrs sur DIRENT */
		int		 	nb_DirEnt );	/* In: Nbre d'entr‚es utilis‚es dans table */

	BOOL	File_Exists( 						/* Out: True si existe */
			const char * cpsz_Path );	/* In:  Chemin d'accŠs complet */


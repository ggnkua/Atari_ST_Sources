/*
 * Special MALLOC library
 * Copyright (c)1995 by Fran‡ois PLANQUE
 *
 * BibliothŠque de fonctions destin‚e … d‚bugguer les
 * erreur de gestion m‚moire avec malloc(), calloc(), free()et strdup()
 * 
 * ATTENTION: Ce module fait des affichages texte sur stdout. (des printf() quoi!)
 *
 * TABS: L'indentation est pr‚vue pour des tabulations de taille 3.
 *
 * 10.07.95: fplanque: Created
 */

/*
 * Headers standard:
 */
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>


/*
 * ---------------------------- VARIABLES -------------------------------
 */

/*
 * Variables globales PRIVEES
 */
	long	M_lnb_mallocs = 0;


/*
 * ---------------------------- FONCTIONS -------------------------------
 */

/*
 * S_Check(-)
 *
 * V‚rifie l'int‚grit‚ d'une zone m‚moire allou‚e par cette librairie
 * Accessoirement: renvoie l'adresse r‚elle du malloc avec ses informations
 * de contr“le.
 * Pr‚vue … priori pourun usage interne, mais peut ˆtre mis … profit 
 * pour v‚rifier periodiquement l'int‚grit‚ d'une zone...
 *
 * 10.07.95: fplanque: Created
 * 27.07.95: fplanque: Chang‚ noms de variables
 */
void * S_Check(				/* Out: adresse de la zone avec head & foot */
			void * p_manip )	/* In:  adresse de manipulation */
{
	char * pc_real = (char*)p_manip - ( 4 + sizeof(size_t) );
	size_t size;

	if(	pc_real[ 0 ] != 'd'
		|| pc_real[ 1 ] != 'e'
		|| pc_real[ 2 ] != 'b'
		|| pc_real[ 3 ] != 'u' )
	{
		printf( "\nERREUR: Zone corrompue au debut!" );
		getchar();
		return NULL;
	}
			
	size = *( (size_t *)(pc_real+4) );		/* Pas g‚gen */
	
	if(	pc_real[ size-4 ] != 'f'
		|| pc_real[ size-3 ] != 'i'
		|| pc_real[ size-2 ] != 'n'
		|| pc_real[ size-1 ] != '!' )
	{
		printf( "\nERREUR: Zone corrompue … la fin!" );
		getchar();
		return NULL;
	}
	
	return (void *) pc_real;
}


/*
 * S_malloc(-)
 *
 * Remplace malloc() et alloue des petits tampons de securit‚
 * de part et d'autre du bloc pour d‚tecter les d‚bordements
 * lors de S_free()
 *
 * 10.07.95: fplanque: Created
 * 27.07.95: fplanque: Chang‚ noms de variables
 */
void * S_malloc( 			/* Out: Ptr sur la zone allou‚e (comme avec malloc()) */
			size_t size )	/* In:  taille dela zone … allouer */
{
	char * pc_real;
	void * p_manip;

	size += 8 + sizeof( size_t );

	pc_real = malloc( size );
	if( pc_real == NULL )
	{	/*
		 * Il peut ˆtre n‚cessaire d'enlever ce Warning si votre programme
		 * effectue et gŠre correctement des mallocs de grande taille par
		 * rapport … la m‚moire disponible.
		 */
		printf( "\nWARNING: Malloc a ‚chou‚!" );
	}
	M_lnb_mallocs ++;
	
	pc_real[0] = 'd';
	pc_real[1] = 'e';
	pc_real[2] = 'b';
	pc_real[3] = 'u';
	
	/*	
	 * Sauve la taille de la zone alou‚e:
	 */
	*( (size_t *)(pc_real+4) ) = size;
	
	pc_real[ size-4 ] = 'f';
	pc_real[ size-3 ] = 'i';
	pc_real[ size-2 ] = 'n';
	pc_real[ size-1 ] = '!';


	/*
	 * D‚termine l'adresse de manipulation.
	 * (Celle du d"but de la zone utilisateur)
	 * Pour faire comme si on avait fait un malloc standard
	 */
	p_manip = pc_real + 4 + sizeof(size_t);
	
	/*
	 * V‚rifie l'int‚grit‚
	 */
	S_Check( p_manip );

	return	p_manip;
}


/*
 * S_strdup(-)
 *
 * Remplace strdup() et alloue des petits tampons de securit‚
 * de part et d'autre de la chaine dupliqu‚e pour d‚tecter les d‚bordements
 * lors de S_free()
 *
 * 10.07.95: fplanque: Created
 * 27.07.95: fplanque: Chang‚ noms de variables
 */
char * S_strdup( 						/* Out: Ptr sur copie de la chaŒne */
			const char * cpsz_src )	/* In:  Ptr sur la chaŒne … dupliquer */
{
	char * pc_real;
	char * psz_dest;

	size_t size = strlen( cpsz_src ) + 1	/* Pour le \0 final */
					 	+ 8 + sizeof( size_t );

	pc_real = malloc( size );
	if( pc_real == NULL )
	{
		printf( "\nWARNING: Malloc dans Strdup impossible!" );
	}
	M_lnb_mallocs ++;
	
	pc_real[0] = 'd';
	pc_real[1] = 'e';
	pc_real[2] = 'b';
	pc_real[3] = 'u';
	
	*( (size_t *)(pc_real+4) ) = size;
	
	pc_real[ size-4 ] = 'f';
	pc_real[ size-3 ] = 'i';
	pc_real[ size-2 ] = 'n';
	pc_real[ size-1 ] = '!';
	
	/*
	 * Copie la chaine:
	 */
	psz_dest = pc_real + 4 + sizeof(size_t);
	strcpy( psz_dest, cpsz_src );
	
	/*
	 * V‚rifie l'int‚grit‚
	 */
	S_Check( psz_dest );

	return psz_dest;
}


/*
 * S_realloc(-)
 *
 * Remplace realloc() et alloue des petits tampons de securit‚
 * de part et d'autre du bloc pour d‚tecter les d‚bordements
 * lors de S_free()
 *
 * 10.07.95: fplanque: Created
 * 27.07.95: fplanque: Il manquait un return NULL en cas de realloc impossible
 * 27.07.95: fplanque: Chang‚ noms de variables
 */
void * S_realloc( 			/* Out: Ptr sur la nouvelle zone allou‚e */
			void * p_manip, 	/* In:  Ptr sur une zone allou‚e */
			size_t size )		/* In:  Nouvelle taille d‚sir‚e pour cette zone */
{
	char * pc_real;
	
	if( p_manip == NULL )
	{	
		printf( "\nWARNING: Trying to realloc() a NULL pointer!" );
		getchar();
		return NULL;
	}

	/*
	 * V‚rifie l'int‚grit‚:
	 */
	pc_real = S_Check( p_manip );
	if( pc_real == NULL )
	{
		printf( "\nREALLOC() impossible!" );
		return NULL;	
	}

	size += 8 + sizeof( size_t );

	pc_real = realloc( pc_real, size );
	if( pc_real == NULL )
	{
		printf( "\nWARNING: realloc impossible!" );
		return NULL;
	}
	
	/*
	 * Note: Ici, on ne re‚crit pas 'd' 'e' 'b' 'u' en d‚but de zone
	 * parce que le realloc … th‚oriquement conserv‚ l'ancien.
	 */
	
	*( (size_t *)(pc_real+4) ) = size;
	
	pc_real[ size-4 ] = 'f';
	pc_real[ size-3 ] = 'i';
	pc_real[ size-2 ] = 'n';
	pc_real[ size-1 ] = '!';
	
	/*
	 * V‚rifie l'int‚grit‚
	 */
	p_manip = pc_real + 4 + sizeof(size_t); 
	S_Check( p_manip );
	
	return	p_manip;
}


/*
 * S_free(-)
 *
 * Remplace free() pour les zones allou‚es avec S_malloc()
 * v‚rifie l'int‚grit‚ des buffers de contr“le.
 *
 * 10.07.95: fplanque: Created
 * 27.07.95: fplanque: Chang‚ noms de variables
 */
void S_free( void * p_manip )	/* In: Ptr sur une zone m‚moire allou‚e */
{
	char	*	pc_real;
	size_t	size;
	
	if( p_manip == NULL )
	{	
		printf( "\nWARNING: On essaye de lib‚rer un pointeur NULL avec free()!" );
		getchar();
		return;
	}

	/*
	 * V‚rifie l'int‚grit‚:
	 */
	pc_real = S_Check( p_manip );
	if( pc_real == NULL )
	{
		printf( "\nFREE() impossible!" );
		return;
	}

	/*
	 * marque la zone comme invalide
	 * (permettra par exemple de d‚tecter un double-free)
	 */
	pc_real[0] = 'l';	/* "libre" */
	pc_real[1] = 'i';
	pc_real[2] = 'b';
	pc_real[3] = 'r';
	
	size = *( (size_t *)(pc_real+4) );
	
	pc_real[ size-4 ] = 'o';	/* "obsolŠte" */
	pc_real[ size-3 ] = 'b';
	pc_real[ size-2 ] = 's';
	pc_real[ size-1 ] = 'o';
	
	/*
	 * Lib‚ration effective:
	 */	
	free( pc_real );
	M_lnb_mallocs --;
}


/*
 * S_MemStat(-)
 * 
 * Statistiques sur l'utilisation de la m‚moire.
 * A appeler en fin de programme, par exemple.
 *
 * 10.07.95: fplanque: created
 */
void S_MemStat( void )
{
	printf( "\nMemory Usage Statistics:" );
	printf( "\nMallocs remaining: %lu ", M_lnb_mallocs );
}


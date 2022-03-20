/*************************************************************************
 *               LIBRAIRIE DE GESTION DES TELECARTES                     *
 *-----------------------------------------------------------------------*
 * F.LEPRETRE                VERSION 1.0                        02/11/94 *
 *************************************************************************/

# ifndef __TELECARTE__
# define __TELECARTE__

/* Strucutre de donn‚e retourn‚es par la fonction AnalyseCarte */
struct InfoCarte {
					char	TypeCarte;  /* nombre d'unit‚es */
					char	Unite;		/* unit‚s restantes */
					char 	Etat;		/* Epuis‚, HS ... */
			 	 };
	
/* Etats de la carte */

# define 	OK				1	/* carte UTILISABLE */
# define 	HS				2	/* carte NON UTILISABLE */
# define	INCONNUE		3	/* carte de type inconnu */
# define	EPUISEE			4	/* plus d'unit‚es */
# define 	ANORMALE		5	/* pb nombre d'unit‚ */

/* Type de la telecarte */

# define 	U40				40
# define 	U50				50
# define	U120			120
# define  	INCONNU			0

/* prototypes des fonction de la librairie */

unsigned int GetVerLibTel(void);
void LectureCarte ( unsigned char *buffer);
struct InfoCarte AnalyseCarte ( unsigned char *buffer );

# endif
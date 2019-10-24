/*
 * special.h
 *
 * Purpose:
 * --------
 * Macros & definitions personnelles a usage general
 *
 * Suggest:
 * --------
 * Verifier repartition des modules                                     
 */

/*
 * V‚rifie si les pr‚sentes d‚finitions ont d‚ja ‚t‚ faites:
 */
#if  !defined( _SPECIAL_H_ )
#define _SPECIAL_H_

#include	<time.h>
#include	<aes.h>

/*
 * ------------------------------ Constantes ------------------------------
 */

	/*
	 * Codes ASCII: 
	 */
	#define	NUL		0x00
	#define	BS			0x08
	#define	TAB		0x09
	#define	LF			0x0A
	#define	CR			0x0D
	#define	ESC		0x1B
	/*
	 * Codes ASCII ‚tendus PC8	
	 */
	#define	PC8_DEMI 			171
	#define	PC8_QUART			172
	#define	PC8_BETA				225
	#define	PC8_PLUSMOINS		241
	#define	PC8_DIVISE			246
	#define	PC8_DEGRE			248
	
	#define	PC8_INVALID			'_'				/* Lorsqu'on a pas pu trouver d'‚quivalent */
	
	/*
	 * Codes ASCII de caractŠres sp‚ciaux: 
	 */
	#define	ALT_SIGN				0x07				/* Repr‚sente touche alt */
	#define	CHECK					0x08
	#define	CEMPTY				178				/* Ensemble vide */


	/* 
	 * Divers:
	 */
	#define	OK1			1
	#define	YES1			1			/* = SELECTED, important dans CONFIG.C */
	#define	FALSE			0
	#define	FALSE0		0
	#define	NO0			0
	#define	IMPOSS0		0
	#define	WRONG0		0
	#define  SUCCESS0		0
	#define	RAS0			0			/* Rien … signaler: SUCCESS0 */
	#define	FAILURE_1	-1
	#define	TRUE			-1
	#define	TRUE_1		-1
	#define	ERROR_1		-1
	#define	CORRUPT_1	-1
	#define	CHANGE_2		-2
	#define	ABORT_2		-2

	#define	ROOT		0
	#define	NIL_1		-1
	#define	NIL		-1

	#define	PARITY	0xFFFFFFFELU	/* Pour fixer une longeur paire */


/*
 * Etat de sauvegarde des donn‚es:
 *
 * 06.08.94: fplanque: Created
 */
typedef
	enum
	{
		SSTATE_EMPTY,
		SSTATE_MODIFIED,
		SSTATE_SAVED
	}
	SSTATE;

/*
 * -------------------------------- Macros -----------------------------
 */
 
#if	ANTI_WARNING
#define	FAKE_USE( x )	(x=x)
#else
#define	FAKE_USE( x )
#endif

#define	MIN( a, b )             ( a<b?a:b )
#define	MAX( a, b )             ( a<b?b:a )

/*
 * ------------------------------ Types ---------------------------
 */

typedef
	union
	{
		int             value;
		struct
		{
			unsigned framecol    :    4;
			unsigned textcol     :    4;
			unsigned textmode    :    1;
			unsigned fillpattern :    3;
			unsigned interiorcol :    4;
		}                       bf;
	}
	TE_COLOR;


/*
 * -------------------- MEMBRES PUBLICS -----------------------------
 */


	extern	char	*	G_empty_string;			/* Chaine vide */
	extern	char	*	G_crlf;						/* Retour … la ligne */
	extern	void	*	G_null;

	extern	char	*	G_tmp_buffer;				/* Peut contenir un texte long de 511 signes + '\0' */
	extern	char	*	G_2nd_buffer;				/* 2Šme buffer */



/*
 * -------------------- METHODES PUBLIQUES -----------------------------
 */
 
void	Special_Init( void );
extern	int	min(			/* Out: Minimum des deux INT */
						int a,	/* In:  INT #1 */
						int b);	/* In:  INT #2 */
extern	long	l_min(		/* Out: Minimum des deux LONG INT */
						long a,	/* In:  LONG INT #1 */
						long b);	/* In:  LONG INT #2 */
extern	int	max(			/* Out: Maximum des deux INT */
						int a,	/* In:  INT #1 */
						int b);	/* In:  INT #2 */
extern	long	l_max(		/* Out: Maximum des deux LONG INT */
						long a,	/* In:  LONG INT #1 */
						long b);	/* In:  LONG INT #2 */
extern	int	rcintersect( 		/* Out: !=0 s'il y a eu intersection */
						int area_x,    /* In: Premier rectangle */
						int area_y, 
						int area_w, 
						int area_h,
						int *box_x, 	/* In/Out: Deuxième rectangle/Rectangle intersection */
						int *box_y, 
						int *box_w, 
						int *box_h );
extern	int	grcintersect(		/* Out: !=0 s'il y a eu intersection */
						GRECT *area,   /* In: Premier rectangle */
						GRECT *box );  /* In/Out: Deuxième rectangle/Rectangle intersection */
extern	void	grecttoarray( 
						GRECT *rect,  	/* In: GRECT à transcrire */
						int *array );	/* Buffer: Tableau dans lequel il faut écrire */
extern	void	ping ( void );
int	Sstrcmp(
			const	char * cpsz_1,
			const	char * cpsz_2,
			char			 c_spec );	/* In: CaractŠre de fin */
extern	char	*strBchr(
						char *string, 	/* In: Chaîne dans laquelle il faut chercher */
						char chr );		/* In: CaractŠre … rechercher */


int	ctrl_IntRange(				/* Out: Valeur ds intervale */
			int	n_Value,			/* In:  Valeur d'origine */
			int	n_Minimum,		/* In:  Valeur Minimale autoris‚e */
			int	n_Maximum );	/* In:  Valeur Maximale autoris‚e */

void	wait( clock_t	delay );

extern	void	replace_extension(
						char * 			pBsz_FileName,		/* In: Buffer contenant Nom sur lequel on opŠre */
						const char *	cpsz_Extension ); /* In: Extension … utiliser */

extern	char * dup_String( 						/* Out: Copie */
						const char * psz_Src );		/* In: Source */
extern	void	free_String(
						char	* pString );	/* In: ptr sur chaine … effacer */
size_t	len_String(
				const char	* pString );	/* In: ptr sur chaine … effacer */
void	copy_String(
				char			* pString_Dest,		/* In: ptr sur buffer destination */
				const char	* cpString_Srce );	/* In: ptr sur chaine … effacer */
extern	void	freeOld_dupString(
						char		* * ppsz_Dest,		/* In/Out: Adr du Ptr destination */
						const char * psz_Srce );	/* In: Chaine … dupliquer */
extern char * realloc_String(				/* Out: Nouvelle chaine */
					const char * pMsz_src,	/* In:  Chaine source */
					size_t		 size_new );	/* In:  Nouvelle longueur */



#endif	/* #if  !defined( _SPECIAL_H_ ) */
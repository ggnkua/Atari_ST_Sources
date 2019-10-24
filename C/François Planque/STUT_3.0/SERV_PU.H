/*
 * Serveur_Public.h
 */
 
#include "SERVEUR.H"
#include "POPUP_PU.H"


/*
 * Mode de fonctionnement du serveur:
 */
enum		{
				SMODE_TEST,				/* Lancer en mode test */
				SMODE_NORMAL			/* Lancer en mode normal */
			};


/*
 * Mode de fonctionnement d'une VOIE:
 */
#define	VMODE_NORMAL		0		/* Voie Normale */
#define	VMODE_OFFLINE		1		/* Voie Off-Line */
#define	VMODE_TEST			2		/* Voie Test local */
#define	NB_VMODES			3		/* ?? */

	/* 
	 * Voies: 
	 */
extern	VOIE		*G_voies;						/* Liste des voies */
extern	int		G_nb_voies;						/* Nombre de voies */
	/* 
	 * Modes de fonctionnement: 
	 */
extern	char		*G_mode[];
extern	long		G_abrev_mode[];
extern	POPUP_ENTRY	G_Popup_Modes[];



	/* 
	 * Serveur: 
	 */
void	init_voies( void );
void	register_action( 
			VOIE *	pVoie_curr, 	/* In: Voie concern‚e */
			int 		action,			/* In: No de l'action */
			int		int1,				/* In: Params int */
			ULONG		ulong1,			/* In: Params ULONG */
			void *	ptr1	 );		/* In: Params PTR */
void	lancer_serv( int mode, int menu_title );
VOIE * Construct_Voie( void );		/* Out: Voie construite */
VOIE	*dup_voies( const VOIE *voie_srce );
void	free_voies( VOIE *curr_voie );
void	voie_phase_init( 
				VOIE *voie, 
				int stable );		/* In: !=0 si on veut que la voie soit stable */
void	affiche_touche( VOIE *pVoie_curr, KEYCODE code_touche );
void	place_csr( VOIE *pVoie_curr );

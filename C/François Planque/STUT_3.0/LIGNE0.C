/*
 * ligne0.c
 *
 * Purpose:
 * --------
 * Gestion des messages et autres en ligne 0
 *
 * History:
 * --------
 * 10.05.94: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"LIGNE0.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
   

/*
 * Custom headers:
 */
 	#include "SPEC_PU.H"
 	#include "SERV_PU.H"
	#include "TERM_PU.H"	

/*
 * ------------------------ PROTOTYPES -------------------------
 */


/*
 * PUBlic INTernal prototypes:
 */
	static	void	aff_msg_l0(
							VOIE *	pVoie_curr,	/* In: Voie vers laquelle envoyer */
							char *	pT_msg );	/* In: Message … envoyer */
				   

/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * aff_msg_l0(-)
 *
 * Purpose:
 * --------
 * Affiche un court message en ligne 0 vers la voie sp‚cifi‚e
 *
 * Suggest:
 * --------
 * Cr‚er une valeur dans la structure VOIE
 * qui serait … jour tout le temps sur le statut d'‚dition
 *
 * History:
 * --------
 * 10.05.94: fplanque: Created
 * 28.03.95: n'eteind/rallume plus le curseur, c'est fait avant
 */
void aff_msg_l0(
			VOIE *	pVoie_curr,	/* In: Voie vers laquelle envoyer */
			char *	pT_msg )		/* In: Message … envoyer */
{
	int n_device = pVoie_curr -> device;

	start_l0( n_device );

	str_conout( n_device, pT_msg );
	
	end_l0( n_device );
}

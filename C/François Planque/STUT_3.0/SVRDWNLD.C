/*
 * SvrDwnLd.c
 *
 * Purpose:
 * -------- 
 * T‚l‚chargement d'un fichier
 *
 * History:
 * --------
 * 22.01.95: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"SVRDWNLD.C v1.00 - 04.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include <string.h>					/* header tt de chaines */
	#include	<stdlib.h>					/* Pour malloc etc.. */

/*
 * Custom headers:
 */
	#include "SPEC_PU.H"

	#include "DEF_ARBO.H"
	#include	"DEBUG_PU.H"	
	#include	"SERV_PU.H"
	#include "USLTP_PU.H"	
	#include "SERCOMPU.H"
	#include "TEXT_PU.H"
	#include "LINE0_PU.H"
		
/*			
 * --------------------------- METHODES -------------------------------
 */


/*
 * DownLoad_ENPG(-)
 *
 * Purpose:
 * --------
 * Traitrement des initialisations ENTER PAGE
 *
 * History:
 * --------
 * 12.04.95: fplanque: Created
 * 14.10.95: affiche nom du fichier a telecharger
 */
BOOL	DownLoad_ENPG(						/* Out: TRUE_1 s'il faut stopper la connexion */
			VOIE	*	pVoie_curr )		/* In:  Voie concern‚e */
{
	USLTP_CTRLBLK * pUCtl;
	
	if( pVoie_curr -> pMsz_VFile == NULL )
	{
		aff_msg_l0( pVoie_curr, "Pas de fichier … envoyer!" );
		add_textinf( pVoie_curr -> wi_params, "  WARNING: Pas de fichier a envoyer!" );
		if( follow_ArboLink( pVoie_curr, FL_NOFILE ) == FALSE )
		{	/*
			 * Pas de page arbo pour prendre le relais:
			 * Il faut stopper la connexion:
			 */
			ping();
			add_textinf( pVoie_curr -> wi_params, "ERREUR: Impossible de continuer" );
			return TRUE_1;
		}
		return FALSE0;
	}

	sprintf( G_tmp_buffer, "  Fichier … envoyer: %s", pVoie_curr -> pMsz_VFile );
	add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
	
	/*
	 * Initialise une session USLTP:
	 */
	pUCtl =	USLTP_Session_Open(
					pVoie_curr -> device,
					pVoie_curr -> device,
					pVoie_curr -> pMsz_VFile,
					pVoie_curr,
					pVoie_curr -> wi_params );
	pVoie_curr -> pUCtl = pUCtl;

	/*
	 * Lance la machine USLTP :)
	 */
	register_action( pVoie_curr, DWLD, 0, 0, NULL );

	return	FALSE0;
}


/*
 * DownLoad_USLTP(-)
 *
 * Purpose:
 * --------
 * Traitement envoi de fichiers par USLTP
 *
 * History:
 * --------
 * 12.04.95: fplanque: Created
 * 13.07.95: fplanque: renvoi d'un falg si deco
 * 14.10.95: stoppe cnx si pas de page arbo suivante
 */
BOOL	DownLoad_USLTP(					/* Out: TRUE_1 si fin_cnx */
			VOIE	*	pVoie_curr )		/* In:  Voie concern‚e */
{
	/*
	 * Passe le controle a USLTP:
	 */
	switch( USLTP_Session_Process( pVoie_curr -> pUCtl ) )
	{
		case	UPROCESS_CONTINUE:
			/*
			 * Changement de tƒche (multitache coop‚ratif):
			 */
			return	FALSE0;

		case	UPROCESS_END:
		{	/*
			 * Si USLTP a fini:
			 */
			USLTP_Session_Close( pVoie_curr -> pUCtl );

			/*
			 * Changement de page:
			 */	
			if( follow_ArboLink( pVoie_curr, FL_NEXT ) == FALSE0 )
			{	/*
				 * Pas de page arbo pour prendre le relais:
				 * Il faut stopper la connexion
				 */
				ping();
				add_textinf( pVoie_curr -> wi_params, "ERREUR: Impossible de continuer" );
				return	TRUE_1;
			}
			return	FALSE0;
		}
			
		case	UPROCESS_LOGICAL_HUP:
			/*
			 * Appui sur cnx fin:
			 */
			USLTP_Session_Close( pVoie_curr -> pUCtl );
		
			return	TRUE_1;
		
		case	UPROCESS_PHYSICAL_HUP:
			/*
			 * D‚co physique:
			 * Signale dans flags: 
			 */
			pVoie_curr -> state .log_modemcnx = FALSE0;	/* Modem d‚connect‚ */
			pVoie_curr -> state .phys_modemcnx = FALSE0;	/* Modem d‚connect‚ */

			USLTP_Session_Close( pVoie_curr -> pUCtl );

			return	TRUE_1;
	}


	signale( "Download ne passe pas ou il faut :-(" );
	return	TRUE_1;
	
}

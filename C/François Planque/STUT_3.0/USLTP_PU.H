/*
 * USLTP_Public.h
 * 
 * Interface publique de gestion de USLTP
 * Universal Serial Link Transfer Protocol
 */

#include "USLTP.H"

	USLTP_CTRLBLK * USLTP_Session_Open( /* Out: Block de controle */
				int			n_InDev,		/* In:  device d'entr‚e */
				int			n_OutDev,	/* In:  device de sotie */
				const char	*	psz_FileName,	/* In:  Path du Fichier … envouyer */
				VOIE		*	pVoie,		/* In:  voie concern‚e */
				WIPARAMS *	pWiParams);	/* In:  Fen de log */
				
	USLTP_PROCESS USLTP_Session_Process(		/* Out: Etat de la session (continue, fin, fin_cnx) */
					USLTP_CTRLBLK * pUCtl );	/* In:  Block de controle session USLTP */
				
	void USLTP_Session_Close(	
			USLTP_CTRLBLK * pUCtl );	/* In:  Block de controle session USLTP */

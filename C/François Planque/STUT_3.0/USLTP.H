/*
 * Universal Serial Link Transfer Protocol
 *
 * Types, Membres et constantes publics
 *
 * 12.04.95: Created
 */
#ifndef _USLTP_H_
#define _USLTP_H_

#include "GEMWDEF.H"


/*
 * Etats d'une session USLTP
 */
typedef
	enum
	{
		USTATE_INIT,
		USTATE_WAIT_LOAD,
		USTATE_SYNC,
		USTATE_CLASS,
		USTATE_FILE,
		USTATE_SIZE,
		USTATE_DATA,
		USTATE_EOF
	}
	USLTP_STATE;

/*
 * R‚ponses de USLTP_Session_Process:
 */
typedef
	enum
	{
		UPROCESS_CONTINUE,
		UPROCESS_END,
		UPROCESS_LOGICAL_HUP,			/* Appui sur Cnx/fin */
		UPROCESS_PHYSICAL_HUP,			/* D‚connexion(Double Appui sur Cnx/fin) */
	}
	USLTP_PROCESS;


/*
 * Block de controle USLTP:
 */
typedef
	struct
	{
		USLTP_STATE	State;			/* Etat courant de la session */
		int			n_InDev;			/* device d'entr‚e */
		int			n_OutDev;		/* device de sotie */
		void		*	pVoie;			/* Voie courante (double emploi avec n_Indev et n_Outdev) */
		char		*	psz_FileName;	/* Nom du fichier … envoyer */
		WIPARAMS *	pWiParams;		/* Fenetre de log */
		TEXTLINE	*	pRcvAcqBuf;		/* Buffer de r‚ception des acquitements */
		clock_t		clock_timeout;	/* Heure du prochain timeout */
	}
	USLTP_CTRLBLK;
	
	
#endif

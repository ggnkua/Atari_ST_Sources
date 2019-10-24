/*
 * USLTP.c
 *
 * Purpose:
 * --------
 * Impl‚mentation multitache coop‚ratif de
 * Universal Serial Link Transfer Protocol
 *
 * History:
 * --------
 * 12.04.95: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"USLTP.C v1.00 - 05.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
	#include <string.h>
	
/*
 * Custom headers:
 */
	#include "USLTP.H"
	#include "SERVEUR.H"
	#include "S_MALLOC.H"
	#include "SPEC_PU.H"
	#include "DEBUG_PU.H"
	#include "TEXT_PU.H"
	#include "TERM_PU.H"
	#include "GETKB_PU.H"	

/*
 * Constantes priv‚es:
 */
typedef
	enum
	{
		USLTP_WAITING,					/* En attente de r‚ponse (n‚cessaire pour multitƒche coop‚ratif) */
		USLTP_OK,						
		USLTP_UNEXPECTED_MSG,		/* La r‚ponse ne correspond pas … ce qu'on attendait */
		USLTP_TIMEOUT,					/* On a attendu trop longtemps sans r‚ponse... */
		USLTP_LINE_ABORT,
		USLTP_LOCAL_ABORT,
		USLTP_EXIT,
		USLTP_LOGICAL_HUP,			/* Logical Hang-Up (Appui sur cnx fin) */
		USLTP_PHYSICAL_HUP			/* Physical Hang-Up (Double-appui) */
	}
	USLTP_RCODE;	


#define	URCV_PRECISELY			0x0001	
#define	URCV_SINGLETRY			0x0002

#define	USLTP_RCV_ACQ_BUF		128

#define	USLTP_RETRY_DELAY		5		/* 5 Secondes */
#define	USLTP_TIMEOUT			30		/* 30 Secondes */

/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * PRIVate INTernal prototypes:
 */
void USLTP_Send_Start(
			USLTP_CTRLBLK * pUCtl );	/* In: Block de controle session USLTP */
USLTP_RCODE USLTP_Send_WaitLoad(
			USLTP_CTRLBLK * pUCtl );	/* In: Block de controle session USLTP */
USLTP_RCODE USLTP_Send_WaitReady(
			USLTP_CTRLBLK * pUCtl );	/* In: Block de controle session USLTP */
USLTP_RCODE USLTP_Send_AcqClass(
			USLTP_CTRLBLK * pUCtl );	/* In: Block de controle session USLTP */

/* ---- */

USLTP_RCODE USLTP_ReceiveCmd(
		USLTP_CTRLBLK	*	pUCtl,		/* In: Block de controle session USLTP */
		const char	 	*	cpsz_what,	/* In: Ce qu'on veut recevoir */
		int					n_timeout,	/* In: Timeout en secondes */
		int					flags );		/* In: Flags de fonctionnement */


/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * USLTP_Init(-)
 *
 * Purpose:
 * --------
 * Initialisation d'une session USLTP
 * (Cr‚e les params n‚cessaires … USLTP)
 *
 * Note:
 * -----
 * Modifie des trucs dans la VOIE courante (sp‚cifique … STUT ONE)
 *
 * History:
 * --------
 * 12.04.95: fplanque: Created
 * 12.07.95: m‚morise la voie concern‚e
 */
USLTP_CTRLBLK * USLTP_Session_Open(			/* Out: Block de controle */
				int				n_InDev,			/* In:  device d'entr‚e */
				int				n_OutDev,		/* In:  device de sotie */
				char			*	psz_FileName,	/* In:  Path du Fichier … envouyer */
				VOIE			*	pVoie,			/* In:  voie concern‚e */
				WIPARAMS 	*	pWiParams)		/* In:  Fen de log */
{
	/*
	 * Cr‚ation d'une zone de contr“le du t‚l‚chargement en cours...
	 */
	USLTP_CTRLBLK * pUCtl = MALLOC( sizeof( USLTP_CTRLBLK ) );	
	pUCtl -> State				= USTATE_INIT;
	pUCtl -> n_InDev			= n_InDev; 
	pUCtl -> n_OutDev			= n_OutDev; 
	pUCtl -> pVoie				= pVoie;
	pUCtl -> psz_FileName	= psz_FileName;
	pUCtl -> pRcvAcqBuf		= TextLine_CreateStandAlone( USLTP_RCV_ACQ_BUF );
	pUCtl -> pWiParams		= pWiParams;
	pUCtl -> clock_timeout	= -1;		/* Pas de Timeout enclench‚ */

	/*
	 * Allocation d'un buffer de r‚ception:
	 */
	TextLine_Clear( pUCtl -> pRcvAcqBuf );
	pVoie -> curr_textline = pUCtl -> pRcvAcqBuf;
	
	return pUCtl;
}


/*
 * USLTP_Session_Process(-)
 *
 * Purpose:
 * --------
 * Dispatche les action de la session
 * en fonction de l'‚tat courant
 *
 * History:
 * --------
 * 12.04.95: fplanque: Created
 * 12.07.95: fplanque: gestion des xx_HUP, renvoi de codes xx_HUP
 */
USLTP_PROCESS USLTP_Session_Process(			/* Out: Etat de la session (continue, fin, fin_cnx) */
							USLTP_CTRLBLK * pUCtl )	/* In:  Block de controle session USLTP */
{
	USLTP_RCODE URCode = USLTP_WAITING;	/* Par d‚faut */

	switch( pUCtl -> State )
	{
		case	USTATE_INIT:
			USLTP_Send_Start( pUCtl );
			break;

		case	USTATE_WAIT_LOAD:
			URCode = USLTP_Send_WaitLoad( pUCtl );
			break;

		case	USTATE_SYNC:
			URCode = USLTP_Send_WaitReady( pUCtl );
			break;

		case	USTATE_CLASS:
			URCode = USLTP_Send_AcqClass( pUCtl );
			break;

	
		default:
			/*
			 * Erreur, on ne sait pas traiter
			 */
			signale( "USLTP error: unknown state" );
			return UPROCESS_END;
	}
	
	switch( URCode )
	{
		case	USLTP_UNEXPECTED_MSG:
			add_textinf( pUCtl -> pWiParams, "  Message USLTP inattendu / Erreur protocole!" );
			return UPROCESS_END;			
			
		case	USLTP_TIMEOUT:
			add_textinf( pUCtl -> pWiParams, "  Timeout USLTP!" );
			return UPROCESS_END;			

		case USLTP_LINE_ABORT:
			add_textinf( pUCtl -> pWiParams, "  Arret utilisateur!" );
			return UPROCESS_END;			

		case USLTP_LOCAL_ABORT:
			add_textinf( pUCtl -> pWiParams, "  Arret serveur!" );
			return UPROCESS_END;			

		case USLTP_EXIT:
			add_textinf( pUCtl -> pWiParams, "  Fin de session USLTP." );
			return UPROCESS_END;			

		case USLTP_LOGICAL_HUP:
			add_textinf( pUCtl -> pWiParams, "  D‚connexion logique (Cnx/Fin)!" );
			return UPROCESS_LOGICAL_HUP;			

		case USLTP_PHYSICAL_HUP:
			add_textinf( pUCtl -> pWiParams, "  D‚connexion physique!" );
			return UPROCESS_PHYSICAL_HUP;			
	}

	return	UPROCESS_CONTINUE;
}



/*
 * USLTP_Session_Close(-)
 *
 * Purpose:
 * --------
 * Ferme une session
 *
 * Note:
 * -----
 * Modifie des trucs dans la VOIE courante (sp‚cifique … STUT ONE)
 *
 * History:
 * --------
 * 12.04.95: fplanque: Created
 * 13.07.95: fplanque: libŠre le tampon de r‚ception
 */
void USLTP_Session_Close(	
			USLTP_CTRLBLK * pUCtl )	/* In:  Block de controle session USLTP */
{
	VOIE * pVoie = (VOIE *)(pUCtl -> pVoie);

	/*
	 * LibŠre tampon de r‚ception:
	 */
	delete_line( pVoie -> curr_textline, NULL );

	/*
	 * LibŠre zone de contr“le du transfert
	 */
	FREE( pUCtl );
	
}


/*
 * ------------------------ Routines Internes ---------------------------
 */


/*
 * USLTP_Send_Start(-)
 *
 * Purpose:
 * --------
 *
 * History:
 * --------
 * 12.04.95: fplanque: Created
 */
void USLTP_Send_Start(
			USLTP_CTRLBLK * pUCtl )	/* In: Block de controle session USLTP */
{
	add_textinf( pUCtl -> pWiParams, "  Activation USLTP (Server)" );
	str_conout( pUCtl -> n_OutDev, "\x0DUSLTP/START\x0D" );

	add_textinf( pUCtl -> pWiParams, "   Attente Loader..." );
	pUCtl -> State = USTATE_WAIT_LOAD;
	str_conout( pUCtl -> n_OutDev, "\x0DUSLTP/SERV\x0D" );
	pUCtl -> clock_timeout	= -1;		/* Pas de Timeout enclench‚ */
}


/*
 * USLTP_Send_WaitLoad(-)
 *
 * Purpose:
 * --------
 * Attend que le loader se manifeste
 *
 * History:
 * --------
 * 12.04.95: fplanque: Created
 * 08.10.95: fplanque: Termin‚
 */
USLTP_RCODE USLTP_Send_WaitLoad(
			USLTP_CTRLBLK * pUCtl )	/* In: Block de controle session USLTP */
{
	USLTP_RCODE URCode;
	
	URCode = USLTP_ReceiveCmd( pUCtl, "USLTP/LOADER", USLTP_RETRY_DELAY, URCV_PRECISELY );

	switch( URCode )
	{
		case	USLTP_OK:
			/*
			 * Le LOADER a signal‚ sa pr‚sence:
			 */
			add_textinf( pUCtl -> pWiParams, "   Synchronisation..." );
			pUCtl -> State = USTATE_SYNC;
			str_conout( pUCtl -> n_OutDev, "\x0DUSLTP/SYNC\x0D" );
			/*
			 * Initialise le buffer de r‚ception:
			 */
			TextLine_Clear( pUCtl -> pRcvAcqBuf );
			pUCtl -> clock_timeout	= -1;		/* Reset TIMEOUT */
			break;
			
		case	USLTP_TIMEOUT:
			/*
			 * On est en phase d'attente du LOADER:
			 * A chaque timeout (c'est le cas ici) on renvoie une
			 * s‚quence d'identification USLTP/SERV et on enclenche
			 * un nouveau TIMEOUT.
			 */
			add_textinf( pUCtl -> pWiParams, "   Recommence attente Loader..." );
			str_conout( pUCtl -> n_OutDev, "\x0DUSLTP/SERV\x0D" );
			pUCtl -> clock_timeout	= -1;		/* Reset TIMEOUT */
			return	USLTP_WAITING;
	}

	return	URCode;
}			



/*
 * USLTP_Send_WaitReady(-)
 *
 * Purpose:
 * --------
 * On a envoy‚ USLTP/SYNC
 * On attend USLTP/READY de la part du loader
 *
 * History:
 * --------
 * 08.10.95: fplanque: Created
 */
USLTP_RCODE USLTP_Send_WaitReady(
			USLTP_CTRLBLK * pUCtl )	/* In: Block de controle session USLTP */
{
	USLTP_RCODE URCode;
	
	URCode = USLTP_ReceiveCmd( pUCtl, "USLTP/READY", USLTP_TIMEOUT, URCV_PRECISELY );

	switch( URCode )
	{
		case	USLTP_OK:
			/*
			 * Le LOADER a signal‚ qu'il ‚tait prˆt … recevoir:
			 */
			add_textinf( pUCtl -> pWiParams, "   N‚gotiation du protocole..." );
			pUCtl -> State = USTATE_CLASS;
			str_conout( pUCtl -> n_OutDev, "?CLASS=BASE\x0D" );
			/*
			 * Initialise le buffer de r‚ception:
			 */
			TextLine_Clear( pUCtl -> pRcvAcqBuf );
			pUCtl -> clock_timeout	= -1;		/* Reset TIMEOUT */
			break;
	}

	return	URCode;
}			



/*
 * USLTP_Send_AcqClass(-)
 *
 * Purpose:
 * --------
 * On a envoy‚ ?CLASS=BASE
 * On attend   !CLASS=BASE:OK de la part du loader
 *
 * History:
 * --------
 * 08.10.95: fplanque: Created
 */
USLTP_RCODE USLTP_Send_AcqClass(
			USLTP_CTRLBLK * pUCtl )	/* In: Block de controle session USLTP */
{
	USLTP_RCODE URCode;
	
	URCode = USLTP_ReceiveCmd( pUCtl, "!CLASS=BASE:OK", USLTP_TIMEOUT, URCV_SINGLETRY | URCV_PRECISELY );

	switch( URCode )
	{
		case	USLTP_OK:
		{	/*
			 * Le loader a accept‚ la classe:
			 */
			char * piBsz_filename;
					
			add_textinf( pUCtl -> pWiParams, "    CLASS: BASE" );
			add_textinf( pUCtl -> pWiParams, "    LEVEL: 0" );
			add_textinf( pUCtl -> pWiParams, "   Envoi du nom de fichier..." );
			pUCtl -> State = USTATE_FILE;
		
			piBsz_filename = strBchr( pUCtl -> psz_FileName, '\\' );
			if( piBsz_filename )
			{
				piBsz_filename++;
			}
			else
			{
				piBsz_filename = pUCtl -> psz_FileName;
			}
			str_conout( pUCtl -> n_OutDev, "!FILE=" );
			str_conout( pUCtl -> n_OutDev, piBsz_filename );
			/*
			 * Initialise le buffer de r‚ception:
			 */
			TextLine_Clear( pUCtl -> pRcvAcqBuf );
			pUCtl -> clock_timeout	= -1;		/* Reset TIMEOUT */
			break;
		}
	}

	return	URCode;
}			


/*
 * ------------------------ Bas niveau ---------------------------
 */

/*
 * USLTP_ReceiveCmd(-)
 *
 * Attente de r‚ception d'une commande USLTP
 * Version sp‚ciale STUT ONE (appelle get_keyboard) 
 *
 * 12.04.95: Created
 * 17.07.95: fplanque: Gestion du timeout
 */
USLTP_RCODE USLTP_ReceiveCmd(
		USLTP_CTRLBLK	*	pUCtl,		/* In: Block de controle session USLTP */
		const char	 	*	cpsz_what,	/* In: Ce qu'on veut recevoir */
		int					n_timeout,	/* In: Timeout en secondes */
		int					flags )		/* In: Flags de fonctionnement */
{

	KEYCODE		curr_keypress;			/* Resultat de la saisie sur voie courante */

	/*
	 * V‚rifie si le timeout est enclench‚:
	 */
	if( pUCtl -> clock_timeout == -1 )
	{	/*
		 * Il faut enclencher le Timeout:
		 */
		pUCtl -> clock_timeout = clock() + n_timeout * CLK_TCK;

		/* printf( "\nWaiting for [%s]", cpsz_what ); */
	}

	/*
	 * Appel de la routine de saisie:
	 */
	curr_keypress = get_keyboard( pUCtl -> pVoie );

	/*
	 * Traite le r‚sultat:
	 */
	switch( curr_keypress )
	{
		case	KEY_CR:
			/*
			 * Recu un carriage return: 
			 * Peut etre la fin d'une commande:
			 */
			/* printf( "\nRe‡u carriage return, msg: [%s]  ", pUCtl -> pRcvAcqBuf -> text ); */

			/*
			 * V‚rifie la commande/l'aquitement re‡u:
			 */
			if( flags & URCV_PRECISELY )
			{
				if( strcmp( cpsz_what, pUCtl -> pRcvAcqBuf -> text ) == 0 )
				{
					return	USLTP_OK;
				}
			}
			else
			{
				if( strncmp( cpsz_what, pUCtl -> pRcvAcqBuf -> text, strlen(cpsz_what) ) == 0 )
				{
					return	USLTP_OK;
				}
			}

			if( flags & URCV_SINGLETRY )
			{	/*
				 * La partie distante n'avait droit qu'… un seul essai
				 * pour envoyer la bonne r‚ponse. 
				 * Et elle n'a pas envoy‚ ce qu'on attendait.
				 */
				return USLTP_UNEXPECTED_MSG;
			}


			/*
			 * Initialise le buffer de r‚ception:
			 */
			TextLine_Clear( pUCtl -> pRcvAcqBuf );
			break;
			
		case	KEY_SOMM:
		case	KEY_ANNUL:
		case	KEY_RETOUR:
			/*
			 * Diverses touches de fonction du Minitel
			 * signalant que l'utilisateur d‚sire int‚rrompre 
			 * le t‚l‚chargement:
			 */
			return USLTP_LINE_ABORT;

		case	KEY_FIN:
			/* 
			 * Connexion/Fin: 
			 */
			return	USLTP_LOGICAL_HUP;

		case	ACT_DISCONNECT:
			/* 
			 * D‚connexion physique:
			 */
			return	USLTP_PHYSICAL_HUP;

	
	}


	/*
	 * Pas re‡u de commande:
	 */
	if( pUCtl -> clock_timeout < clock() )
	{	/*
		 * Si le timeout est ‚coul‚:
		 */
		return USLTP_TIMEOUT;
	}
	
	/*
	 * On continue … attendre
	 * (mais on passe la main / multitƒche coop‚ratif)
	 */
	return USLTP_WAITING;
}
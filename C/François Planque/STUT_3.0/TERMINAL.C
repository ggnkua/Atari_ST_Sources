/*
 * terminal.c
 *
 * Purpose:
 * --------
 * Gestion du terminal de sortie (Minitel, Modem)
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"TERMINAL.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
	#include <string.h>
	#include	<tos.h>					/* Pour les appels au BIOS */
   

/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "SERV_PU.H"				/* Codes touches etc... */
	#include "ACCENTPU.H"
	#include	"POPUP_PU.H"
	#include	"SRIAL_PU.H"
	#include	"DEBUG_PU.H"	
	#include "TERM_PU.H"
	#include "MINITEL.H"				/* Codes minitel */


/*
 * ------------------------ FUNCTIONS -------------------------
 */


/*
 * init_MinitelPort(-)
 *
 * Purpose:
 * --------
 * Init d'un port s‚rie reli‚ … un minitel
 *
 * Algorythm:
 * ----------  
 * Passe par toutes vitesse RS autres ke 4800
 * a chak fois dem au minitel de se mettre en 4800
 * mets 4800 … la fin
 * init ‚cran minitel
 * 
 * History:
 * --------
 * 30.09.94: fplanque: Created
 * 19.11.94: flush RX at end
 */
void	init_MinitelPort(
				int	n_port )			/* In: Port concern‚ */
{
	static const long	l_MinitelRates[] = { 300, 9600, 1200 };
	int		i;

	TRACE1( "Init port %d pour minitel", n_port );

	/*
	 * Utilse toutes les vitesses tour … tour:
	 */
	for( i = 0; i < 3; i++ )
	{
		TRACE1( "  Vitesse test‚e: %ld", l_MinitelRates[i] );

		/*
		 * Fixe vitesse RS:
		 */
		SetPort( n_port, l_MinitelRates[i], 'E', 7, MODE_ASYNC1STOP, HANDSHAKE_NONE ); 

		/*
		 * Passe la prise du minitel en 4800 bps:
		 */
		Bconout( n_port, '-' );

		Bconout( n_port, ESC );
		Bconout( n_port, PRO2 );
		Bconout( n_port, PROG );
		Bconout( n_port, PERI_4800 );
		
		/*
		 * Laise le temps … 20 bytes de partir vers le Minitel:
		 */
		/* wait( 20 * 100 / (l_MinitelRates[i]/10) ); */
		/*
		 * Attend que les codes aient ‚t‚ ‚mis:
		 */
		Serial_WaitTXEmpty( n_port );

	}


	/*
	 * Fixe vitesse RS … 4800:
	 */
	SetPort( n_port, 4800, 'E', 7, MODE_ASYNC1STOP, HANDSHAKE_NONE ); 
	
	/*
	 * initialise l'‚cran:
	 */
	csr_off( n_port );
	full_cls( n_port );	
	str_conout( n_port, STUT_FULLNAME "\r\n" STUT_RELEASEINFO "\r\n" );

	/*
	 * Allume l'‚cran si n‚cessaire:
	 */
	allume_minitel( n_port );

	/*
	 * Vide buffer d'entr‚e:
	 * (Tout ce qui a ‚t‚ re‡u pdt que le minitel et la RS n'‚taient
	 *  pas … la mˆme vitesse n'est pas interpr‚table!! )
	 */
	FlushRXBuffer( n_port );
}

/*
 * MinitelPort_ChgeSpeed(-)
 *
 * Purpose:
 * --------
 * Chge la vitesse d'un port s‚rie reli‚ … un minitel
 *
 * Algo:
 * -----
 * - Demande au minitel de changer de vitesse
 * - Attend que TX soit vide
 * - Chge vitesse de la prise s‚rie
 *
 * History:
 * --------
 * 08.04.95: fplanque: Created
 */
void	MinitelPort_ChgeSpeed(
				int	n_port,			/* In: Port concern‚ */
				long	l_newspeed )	/* In: Code nouvelle vitesse */
{
	int n_SpeedCode;

	if( l_newspeed == 1200 )
	{
		n_SpeedCode = PERI_1200;
	}
	else if( l_newspeed == 4800 )
	{
		n_SpeedCode = PERI_4800;
	}
	else
	{
		signale( "Impossible de passer le minitel … la vitesse demand‚e" );
		return;
	}

	/*
	 * Passe la prise du minitel … la vitesse demand‚e:
	 */
	Bconout( n_port, ESC );
	Bconout( n_port, PRO2 );
	Bconout( n_port, PROG );
	Bconout( n_port, n_SpeedCode );
	
	/*
	 * Attend que les codes aient ‚t‚ ‚mis:
	 */
	Serial_WaitTXEmpty( n_port );

	/*
	 * Fixe vitesse RS:
	 */
	SetPort( n_port, l_newspeed, 'E', 7, MODE_ASYNC1STOP, HANDSHAKE_NONE ); 
	
	/*
	 * Vide buffer d'entr‚e:
	 * (Tout ce qui a ‚t‚ re‡u pdt que le minitel et la RS n'‚taient
	 *  pas … la mˆme vitesse n'est pas interpr‚table!! )
	 */
	FlushRXBuffer( n_port );
}


/*
 * param_local(-)
 *
 * Purpose:
 * --------
 * ParamŠtre Minitel pour connexion locale
 *
 * Algorythm:
 * ----------  
 * Au cas ou on est en mode T‚l‚info, 
 *  il faut en sortir avec un s‚quence sp‚ciale
 * On fait un Reset Vid‚otex      
 * Empeche l'echo local des caractŠres tap‚s
 *
 * Suggest:
 * ------
 * Faire le flush ailleurs pour ‚viter le wait(5)
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 05.12.94: fplanque: Flusx RX a la fin
 */
void	param_local( 
			int device )	/* In: No périf concerné */
{
	/*
	 * Au cas ou on est en mode T‚l‚info, il faut en sortir avec un s‚quence sp‚ciale: 
	 */
	Bconout ( device, ESC );		/* Retour en std T‚l‚tel */
	Bconout ( device, CSI );
	Bconout ( device, 0x3F );
	Bconout ( device, 0x7B );

	/*
	 * On fait un Reset Vid‚otex 
	 */
	Bconout ( device, ESC );		/* Reset du terminal T‚l‚tel */
	Bconout ( device, PRO1 );
	Bconout ( device, RESET );
		
	/*
	 * On doit empecher l'echo local des caractŠres tap‚s: 
	 */
	Bconout ( device, ESC );		/* Blocage Module MODEM */
	Bconout ( device, PRO3 );
	Bconout ( device, AIGUIL_OFF );
	Bconout ( device, RE_MODEM );
	Bconout ( device, EM_MODEM );

	/*
	 * On re‡oit des saloperies en retour, il va falloir les ‚liminer!
	 */
	wait( 5 );
	FlushRXBuffer( device );
}


/*
 * allume_minitel(-)
 *
 * Purpose:
 * --------
 * Sortie du mode veille sur M2:
 *
 * History:
 * --------
 * 08.02.95: fplanque: Created
 */
void	allume_minitel( 
			int device )	/* In: No p‚rif concern‚ */
{
	Bconout ( device, ESC );
	Bconout ( device,	PRO3 );
	Bconout ( device, P_STOP );
	Bconout ( device, RE_ECRAN );	/* 0x58 */
	Bconout ( device, VEILLE );
}

/*
 * eteind_minitel(-)
 *
 * Purpose:
 * --------
 * passe en mode veille sur M2:
 *
 * History:
 * --------
 * 08.02.95: fplanque: Created
 */
void	eteind_minitel( 
			int device )	/* In: No p‚rif concern‚ */
{
	Bconout ( device, ESC );
	Bconout ( device,	PRO3 );
	Bconout ( device, P_START );
	Bconout ( device, RE_ECRAN );	/* 0x58 */
	Bconout ( device, VEILLE );	/* 0x41 */
}


/*
 * envoi_porteuse(-)
 *
 * Purpose:
 * --------
 * Envoi de porteuse sur une voie utilisant un Minitel pour Modem
 *
 * Algorythm:
 * ----------  
 *	Retournement modem puis envoi porteuse
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
#if ACCEPT_REMOTE
void	envoi_porteuse( 
			int device )	/* In: No périf concerné */
{
	/*
	 * Retournement du modem: 
	 */
	Bconout ( device, ESC );
	Bconout ( device, PRO1 );
	Bconout ( device, OPPO );		/* 0x6F */

	/*
	 * Envoi porteuse: 
	 */
	Bconout ( device, ESC );
	Bconout ( device, PRO1 );
	Bconout ( device, CONNEXION );		/* 0x68 */
}
#endif


/*
 * deconnecte_modem(-)
 *
 * Purpose:
 * --------
 * Deconnecte le modem d'un Minitel
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 08.02.95: Lib‚ration de ligne sur le M2
 */
void	deconnecte_modem( 
			int device )
{
	/*
	 * Deconnexion modem: 
	 */
	Bconout ( device, ESC );
	Bconout ( device, PRO1 );
	Bconout ( device, DECONNEXION );		/* 0x67 */

	/*
	 * Lib‚ration de ligne: 
	 * En effet, sur Minitel 2, cette lib‚ration ne se fait pas avec
	 * le PRO1+DECO si le bit RPL vaut 1, et comme c'est le cas 
	 * en phase deconnexion... (vu au cours des tests)
	 * Voir Ý6 p23 dans le STUM2
	 */
	Bconout ( device, ESC );
	Bconout ( device, PRO1 );
	Bconout ( device, LL );					/* 0x57 */
}



/*
 * param_normal(-)
 *
 * Purpose:
 * --------
 * ParamŠtre Minitel(s) pour connexion normale
 *
 * Algorythm:
 * ----------  
 * Bloque aiguillage modem -> ecran
 * Installe aiguillage prise -> ecran
 *  L'écran du Minitel local affiche alors la même chose que
 *  celui du connecté
 * Bloque aiguillage clavier -> modem 
 * Installe aiguillage clavier -> prise
 *  Lorsqu'on tape au clavier du Minitel local, on se fait alors
 *  passer pour le connect‚
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	param_normal( 
			int device )
{
	/*
	 * Bloque aiguillage modem -> ecran: 
	 */
	Bconout ( device, ESC );
	Bconout ( device,	PRO3 );
	Bconout ( device, AIGUIL_OFF );
	Bconout ( device, RE_ECRAN );
	Bconout ( device, EM_MODEM );

	/*
	 * Installe aiguillage prise -> ecran: 
	 */
	Bconout ( device, ESC );
	Bconout ( device,	PRO3 );
	Bconout ( device, AIGUIL_ON );
	Bconout ( device, RE_ECRAN );
	Bconout ( device, EM_PRISE );

	/*
	 * Bloque aiguillage clavier -> modem: 
	 */
	Bconout ( device, ESC );
	Bconout ( device,	PRO3 );
	Bconout ( device, AIGUIL_OFF );
	Bconout ( device, RE_MODEM );
	Bconout ( device, EM_CLAVIER );

	/*
	 * Installe aiguillage clavier -> prise: 
	 */
	Bconout ( device, ESC );
	Bconout ( device,	PRO3 );
	Bconout ( device, AIGUIL_ON );
	Bconout ( device, RE_PRISE );
	Bconout ( device, EM_CLAVIER );
}



/*
 * param_minitel(-)
 *
 * Purpose:
 * --------
 * ParamŠtre Calvier Minitel en d‚but de connexion
 *
 * Suggest:
 * --------
 * Appliquer aussi au minitel distant:
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	param_minitel( 
				int 	device,
				BOOL	b_Connecte )	/* In: TRUE si connect‚ */
{
	/*
	 * Passe clavier en minuscules: 
	 */
	Bconout ( device, ESC );
	Bconout ( device,	PRO2 );
	Bconout ( device, P_START );
	Bconout ( device, MINUSCULES );

	/*
	 * Passe en mode clavier ‚tendu:
	 */
	Bconout ( device, ESC );
	Bconout ( device,	PRO3 );
	Bconout ( device, P_START );
	Bconout ( device, RE_CLAVIER );
	Bconout ( device, ETEN );

	/*
	 * Fait de mˆme pour le clavier du connect‚:
	 */
	if( b_Connecte )
	{
		/*
		 * Transparence protocole pour ce qui va suivre:
		 */	
		Bconout ( device, ESC );
		Bconout ( device,	PRO2 );
		Bconout ( device, TRANSPARENCE );
		Bconout ( device, 9 );
	
		/*
		 * Passe clavier en minuscules: 
		 */
		Bconout ( device, ESC );
		Bconout ( device,	PRO2 );
		Bconout ( device, P_START );
		Bconout ( device, MINUSCULES );

		/*
		 * Passe en mode clavier ‚tendu:
		 */
		Bconout ( device, ESC );
		Bconout ( device,	PRO3 );
		Bconout ( device, P_START );
		Bconout ( device, RE_CLAVIER );
		Bconout ( device, ETEN );
	}
}


/*
 * csr_on(-)
 *
 * Purpose:
 * --------
 * Affiche le curseur du terminal Minitel
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	csr_on( int device )
{
	/*
	 * Allume curseur MINITEL: 
	 */
	Bconout ( device, CSR_ON );
	
}



/*
 * csr_off(-)
 *
 * Purpose:
 * --------
 * Efface le curseur du terminal Minitel
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	csr_off( int device )
{
	/*
	 * Eteind curseur MINITEL: 
	 */
	Bconout ( device, CSR_OFF );
	
}



/*
 * pos(-)
 *
 * Purpose:
 * --------
 * Positionne le curseur du terminal Minitel
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	pos( 
			int device,	/* In: No périf concerné */
			int x, 		/* In: Position horizontale (colomne) */
			int y )		/* In: Position verticale (ligne) */
{
	/*
	 * Positionne curseur sur Minitel: 
	 */
	Bconout ( device, 31 );
	Bconout ( device, 64 + y );
	Bconout ( device, 64 + x );
}



/*
 * start_l0(-)
 *
 * Purpose:
 * --------
 * Se place sur la ligne 0 et l'efface en vue de l'affichage d'un message
 *
 * History:
 * --------
 * 11.05.94: fplanque: Created
 */
void	start_l0(  
			int device )	/* In: No p‚rif concern‚ */
{
	/*
	 * Entre ds la ligne 0: 
	 */
	Bconout ( device, US );		/* Pos en ligne 0 */
	Bconout ( device, 64+0 );
	Bconout ( device, 64+1 );
	Bconout ( device, CAN );	/* CAN */
}



/*
 * end_l0(-)
 *
 * Purpose:
 * --------
 * Sort de la ligne0 et retourne … l'‚cran normal
 *
 * Notes:
 * ------
 *	un LF sur le Minitel sort de la ligne0 et retourne … la position
 * pr‚c‚dente du curseur en restituant les attributs et tout le reste...
 *
 * History:
 * --------
 * 10.05.94: fplanque: Created
 */
void	end_l0(  
			int device )	/* In: No périf concerné */
{
	/*
	 * Sort de la ligne 0: 
	 */
	Bconout ( device, LF );
}



/*
 * full_cls(-)
 *
 * Purpose:
 * --------
 * Efface l'‚cran complet du terminal Minitel
 *
 * Algorythm:
 * ----------  
 * Efface aussi la ligne 0!
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	full_cls( int device )
{
	Bconout ( device, US );		/* Pos en ligne 0 */
	Bconout ( device, 64+0 );
	Bconout ( device, 64+1 );
	Bconout ( device, CAN );	/* CAN */
	Bconout ( device, FF );		/* CLS */
}




/*
 * set_tcolor(-)
 *
 * Purpose:
 * --------
 * Fixe la couleur d'‚criture du Minitel
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	set_tcolor( int device, int color )
{
	Bconout ( device, 27 );				/* Esc */
	Bconout ( device, 64 + color );	/* Code couleur */
}

/*
 * set_tcolor(-)
 *
 * Purpose:
 * --------
 * passe en inverse vid‚o
 *
 * History:
 * --------
 * 13.01.95: fplanque: Created
 */
void	term_setReverse( int device )
{
	Bconout ( device, 27 );				/* Esc */
	Bconout ( device, MNTL_INVERSE_ON );	
}


/*
 * cconout(-)
 *
 * Purpose:
 * --------
 * Envoi d'un caractŠre au terminal
 *
 * Notes:
 * ------
 * L'utilisation de cette fonction n'est franchement pas économique!
 *
 * Suggest:
 * --------
 * Impl‚menter des appels par pointeur en fonction du type de terminal
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 24.05.94: Conversion des car>127
 */
void	cconout ( int device, int code )
{
	if ( code <= 127 )
	{	/*
		 * Si code compatible Minitel: 
		 */
		Bconout( device, code );
	}
	else
	{	/*
		 * Si caractŠre sp‚cial: CONVERSION
		 */
		char *	pS_equiv = convert_Asc2Vdt( code );
		while( *pS_equiv != '\0' )
		{
			Bconout( device, *(pS_equiv++) );
		}
	}

}




/*
 * mconout(-)
 *
 * Purpose:
 * -------- 
 * Multiple conout
 * Affichage d'un caractŠre r‚p‚t‚ plusieurs fois sur terminal Minitel
 *
 * Algorythm:
 * ----------  
 * Utilise proc‚dure de r‚p‚tition <car 18 64+nb-1> du minitel
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	mconout( 
			int device, 
			int code, 
			int nb )			/* In: Nombre d'occurences … afficher */
{
	if ( nb > 0 )
	{
		Bconout( device, code );	/* Affiche 1 fois */
		
		if ( nb == 2 )
		{
			Bconout( device, code );	/* Affiche 1 deuxiŠme fois */
		}
		else if ( nb > 2 )
		{
			Bconout( device, 18 );			/* r‚p‚tition */
			Bconout( device, 64 + nb-1 );	/* nb-1 fois */
		}

	}
}



/*
 * str_conout(-)
 *
 * Purpose:
 * --------
 * Envoi d'une chaine de caractŠres au terminal
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	str_conout( 
			int 				device, 
			const char *	string )
{
	/* 
	 * Variables: 
	 */
	int	code;


	/*
	 * Envoie la page dans le tampon de sortie: 
	 */
	while
	( 
		code = *(string ++),
		code != '\0'
	)
	{
		if ( code <= 127 )
		{	/*
			 * Si code compatible Minitel: 
			 */
			Bconout( device, code );
		}
		else
		{	/*
			 * Si caractŠre sp‚cial: CONVERSION
			 */
			char *	pS_equiv = convert_Asc2Vdt( code );
			while( *pS_equiv != '\0' )
			{
				Bconout( device, *(pS_equiv++) );
			}
		}
	}

}


/*
 * str_nconout(-)
 *
 * Purpose:
 * --------
 * Envoi d'une chaine de caractŠres au terminal
 * avec contr“le d'uin nb de cars maximum
 *
 * History:
 * --------
 * 13.01.95: fplanque: Created base on str_conout
 */
void	str_nconout( 
			int 				device, 
			const char	*	string,
			int				n_maxlen )	/* In: Longueur maximum */
{
	/* 
	 * Variables: 
	 */
	int	code;


	/*
	 * Envoie la page dans le tampon de sortie: 
	 */
	while
	( 
		code = *(string ++),
		code != '\0' && (n_maxlen--) > 0
	)
	{
		if ( code <= 127 )
		{	/*
			 * Si code compatible Minitel: 
			 */
			Bconout( device, code );
		}
		else
		{	/*
			 * Si caractŠre sp‚cial: CONVERSION
			 */
			char *	pS_equiv = convert_Asc2Vdt( code );
			while( *pS_equiv != '\0' )
			{
				Bconout( device, *(pS_equiv++) );
			}
		}
	}

}



/*
 * sconout(-)
 *
 * Purpose:
 * --------
 * Envoi d'une s‚quence au terminal
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	sconout(
			int		device, 
			long		length, 
			char	*	seq )
{
#define	WATCH_SCONOUT	NO0

	/* Variables */
		register	long	offset;				/* Offset dans la chaine */
		int				code;					/* Code … afficher */

#if	WATCH_SCONOUT
	printf( "\x1BY\x20\x62***");
#endif
	
	/* Envoie la page dans le tampon de sortie: */
		for (	offset = 0; offset < length; offset++ )	
		{
			code = seq[offset];		/* Code … traiter */
			if ( code <= 127 )
			{	/* Si code compatible Minitel: */
				Bconout ( device, code );
			}
		}
	
#if	WATCH_SCONOUT
	printf( "\x1BY\x20\x62---");
#endif

	/* Ici, Offset=length ::	printf("Offset=%lu\n",offset); */
	
#undef	WATCH_SCONOUT
}



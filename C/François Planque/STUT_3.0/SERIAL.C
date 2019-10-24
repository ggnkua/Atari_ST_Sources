/*
 * serial.c
 *
 * Purpose:
 * --------
 * Routines de traitement des ports s‚rie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 02.03.95: Adaptation Falcon
 */


 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"SERIAL.C v1.11 - 03.95"


/*
 * System headers:
 */
	#include	<stdio.h>
	#include	<stdlib.h>
	#include	<string.h>					/* strcpy() etc.. */
	#include	<tos.h>						/* Bconmap etc... */
	#include	<aes.h>						/* header AES */
   
/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"					/* Macro MIN */
	#include "S_MALLOC.H"
	#include "STUT_ONE.RSC\STUT_3.H"						/* noms des objets ds le ressource */
	#include "POPUP_PU.H"					/* Listes menu PopUp */
	#include "EXFRM_PU.H"			
	#include	"DEBUG_PU.H"	
	#include	"SRIAL_PU.H"	
	#include	"RTERR_PU.H"	
	#include	"OBJCT_PU.H"	
	#include	"FILES_PU.H"	
	#include	"TERM_PU.H"	

/*
 * ------------------------ PROTOTYPES -------------------------
 */


/*
 * PRIVate INTernal prototypes:
 */
	static	void	param_term_initval(
							int device, 				/* In: No Bconmap du port concern‚ */
							char *ptext_bufin, 		/* In: Ptr sur texte:Taille IN ds tedinfo concern‚e */
							char *ptext_bufout );	/* In: Ptr sur texte:Taille OUT ds tedinfo concern‚e */
	static	void	param_term_saveval( 
				int device, 							/* In: No Bconmap du port concern‚ */
				char *ptext_bufin, 					/* In: Ptr sur texte:Taille IN ds tedinfo concern‚e */
				char *ptext_bufout );				/* In: Ptr sur texte:Taille OUT ds tedinfo concern‚e */
	static	int	device_offset(					/* Out: No d'ordre [0..n-1] du port */
			 				int device );				/* In:  No bconmap du port */
	static	int	find_device_byabrev( 		/* Out: no bconmap du p‚riph‚rique */
							char *abrev_string );	/* In:  abreviation du nom du port */
	static	IOREC	*get_iorec(						/* Out: Ptr sur IOREC demand‚e */
							int device );				/* In:  No bconmap du port dont on veut l'IOREC */
	static	IOREC	*get_defiorec_cpy(			/* Out: Ptr sur IOREC demand‚e */
			 				int device );				/* In:  No bconmap du port dont on veut la copie d'IOREC */
	static	void	install_newbuf( 
							int in_out, 				/* In: 0 pour buffer IN et 1 pour buffer out */
							int device, 				/* In: No bconmap du port concern‚ */
							int newsize );				/* In: Nlle taille … donner au buffer */


   
/*
 * ------------------------ VARIABLES -------------------------
 */
    

/*
 * PUBlic variables: 
 */
	int		G_term_dev = AUX;			/* Port utilis‚ par icone terminal ( Sur un STF sans Bconmap: 1,AUX ) */
	long		*G_inst_abrev;				/* Noms abr‚g‚s en 4 lettres */
	/* 
	 * Menu Pop-Up: 
	 */
	POPUP_ENTRY* G_inst_drv_list;		/* Liste des p‚rifs install‚s pourmenu Popup */

	
/*
 * PRIVate variables: 
 */
	static	OBJECT	*	M_termconf_adr;			/* Boite de config terminal */
	static	BCONMAP	*	M_bconmap = NULL;		/* Bconmap */
	static	MAPTAB	*	M_def_maptab = NULL;	/* Adresse du MAPTAB par d‚faut */
	static	int			M_def_nbserial = 1;		/* Nbre d'‚l‚ments du MAPTAB par d‚faut */
	static	IOREC		*	M_def_iorecs_bak;		/* ParamŠtres par d‚faut */
	static	char		*	M_serial_names[]=		/* Ports s‚rie pouvant exister */
								{
									"  Modem 1",
									"  Modem 2",
									"  Serial 1",
									"  Serial 2",
									"  Extra "
								};		
	static	long			M_serial_abrev[]=			/* Abr‚viations utilis‚es pour les ports s‚rie */
								{
									'MOD1',
									'MOD2',
									'SER1',
									'SER2',
									'EXTR'
								};
	static	char		*	M_bufsize_filefmt = "BSIZIN=%d,BSIZOUT=%d";
	static	long			rsconf_baudrates[] =
								{ 19200, 9600, 4800, 3600, 2400, 2000, 1800, 1200,
				               600, 300, 200, 150, 134, 110, 75, 50, 0 };
	 
/*
 * ------------------------ FUNCTIONS -------------------------
 */


/*
 * init_serial(-)
 *
 * Purpose:
 * --------
 * Init des prises s‚rie et des boŒtes de configuration
 *
 * Suggest:
 * --------
 * La d‚tection de support Bconmap doit ˆtre chang‚e:
 * Detecter le type de BIOS avant d'appeller Bconmap.
 *
 * Notes:
 * ------
 * Sur Falcon, Bconmap retourne 7, mais on ne peut pas adresser le port 7,
 * il faut passer par AUX.
 *
 * History:
 * --------
 * fplanque: Created
 * 11.05.94: fplanque: Ajout‚ test de validit‚ suppl‚mentaire pour le
 *								premier appel Bconmap
 * 02.03.95: Changement lors de la cr‚ation de la liste des ports
 * 14.03.95: utilise toujours AUX si un seul port s‚rie
 */
void	init_serial( void )
{
	/* 
	 * Variables: 
	 */
	long	bconmap;
	int	i;
	IOREC	*iorec, *iorec_ptr;

	TRACE0( "Initializing " THIS_FILE );

	/*
	 * Init RSC: 
	 */
	if ( rsrc_gaddr( R_TREE, TERMCONF, &M_termconf_adr ) == 0 )
	{
		erreur_rsrc();
	}
	rsrc_color( M_termconf_adr );		/* Fixe couleurs */

	/*
	 * Prises s‚rie: 
	 * Demande p‚riph‚rique par d‚faut:
	 */
	bconmap = Bconmap( -1 );			
	TRACE1( "Bconmap returns def port as %ld", bconmap );
	
	if( bconmap >= 6  && bconmap != 44 && bconmap <= 800 )
	{	/* 
		 * Si la fonction est reconnue par le XBIOS: 
		 * Non reconnu devrait normalement se traduire par retour de 44
		 * Mais le STF de fplanque TOS 1.4 renvoie un nombre dans les milliers
		 * D'ou test si - de 800
		 */

		/*
		 * Port utilis‚ par ic“ne terminal = port par d‚faut:
		 */
		G_term_dev = (int) bconmap;	
		
		/*
		 * Demande adresse bconmap: 
		 */
		bconmap = Bconmap( -2 );
		M_bconmap = (BCONMAP *) bconmap;
		M_def_maptab = M_bconmap -> maptab;		/* Tableau des ports */
		M_def_nbserial = M_bconmap -> maptabsize;	/* Nbre d'‚l‚ments */
	
	}		/* Fin d'utilisation de Bconmap */

	TRACE1( " Nb of serial ports: %d", M_def_nbserial );
		
	/* 
	 * Cr‚e une liste des ports s‚rie disponibles: 
	 */
	G_inst_drv_list = (POPUP_ENTRY *)MALLOC( sizeof( POPUP_ENTRY ) * (M_def_nbserial +1) );
	G_inst_abrev	 = (long *)	 MALLOC( sizeof( long )   * M_def_nbserial );

	if( M_def_nbserial == 1 )
	{	/*
		 * 1 seule prise s‚rie (STF,STE,Falcon): 
		 * chged on 02.03.95
		 */
		if( G_term_dev >= MOD1 )
		{	/*
			 * Falcon par exemple, STF/STE avec nouveau TOS (?):
			 * On se force … utiliser AUX plutot qu'un driver sp‚cifique,
			 * c'est plus sur.
			 */
			G_inst_drv_list[ 0 ] .name = M_serial_names[ G_term_dev -6 ];	/* Modem 1 */
			G_inst_abrev[ 0 ] 	= M_serial_abrev[ G_term_dev -6 ];	/* Modem 1 */
			G_term_dev = AUX;
		}
		else
		{	/*
			 * STF,STE:
			 */
			G_inst_drv_list[ 0 ] .name = M_serial_names[ MOD1 -6 ];	/* Modem 1 */
			G_inst_abrev[ 0 ] 	= M_serial_abrev[ MOD1 -6 ];	/* Modem 1 */
		}
		G_inst_drv_list[ 0 ] .value = G_term_dev;		/* AUX */
	}
	else if( M_def_nbserial == 3 )
	{	/*
	 	 * 3 prises s‚rie (M‚ga STE?): 
	 	 */
		G_inst_drv_list[ 0 ] .name = M_serial_names[ MOD1 -6 ];	/* Modem 1 */
		G_inst_drv_list[ 0 ] .value = MOD1;			/* Modem 1 */
		G_inst_abrev[ 0 ] 	= M_serial_abrev[ MOD1 -6 ];	/* Modem 1 */

		G_inst_drv_list[ 1 ] .name  = M_serial_names[ MOD2 -6 ];	/* Modem 2 */
		G_inst_drv_list[ 1 ] .value = MOD2;								/* Modem 2 */
		G_inst_abrev[ 1 ] 	= M_serial_abrev[ MOD2 -6 ];

		G_inst_drv_list[ 2 ]	.name	 = M_serial_names[ SER2 -6 ];	/* Serial 2 */
		G_inst_drv_list[ 2 ]	.value = SERL;								/* Serial 2 Mega STE */
		G_inst_abrev[ 2 ] 	= M_serial_abrev[ SER2 -6 ];
	}
	else
	{	/*
		 * PROVISOIRE: (TT?, Carte?) Plusieurs prises s‚rie: 
		 */
		for( i=0; i<=3; i++ )
		{
			G_inst_drv_list[ i ] .name  = M_serial_names[ i ];		/* Autres prises */
			G_inst_drv_list[ i ]	.value = 6+i;
			G_inst_abrev[ i ] 	= M_serial_abrev[ i ];
		}
		/*
		 * S'il y en a encore: 
		 */
		if ( M_def_nbserial > 4 )
		{	/*
			 * Installation des Extra-Ports 
			 */
			for( ; i<M_def_nbserial; i++ )
			{
				G_inst_drv_list[ i ] .name  = M_serial_names[ 4 ];	/* Extra Ports */				
				G_inst_drv_list[ i ] .value = 6+i;
				G_inst_abrev[ i ] 	= M_serial_abrev[ 4 ];
			}
		}
	}
	/*
	 * Termine la liste par une r‚f‚rence nulle: 
	 */
	G_inst_drv_list[ M_def_nbserial ] .name = NULL;

	/* 
	 * Sauve params BUFFERS par d‚faut: 
	 */
	M_def_iorecs_bak = MALLOC( sizeof( IOREC ) * 2 * M_def_nbserial );
	iorec_ptr = M_def_iorecs_bak;
	for( i = 0; i < M_def_nbserial; i++ )
	{
		/*
		 * Adresse BUFFER IN: 
		 */
		iorec = get_iorec( G_inst_drv_list[ i ] .value );
		/*
		 * Copie des donn‚es: 
		 */
		iorec_ptr -> ibuf		= iorec -> ibuf;
		iorec_ptr -> ibufsiz	= iorec -> ibufsiz;
		iorec_ptr -> ibuflow	= iorec -> ibuflow;
		iorec_ptr -> ibufhi	= iorec -> ibufhi;
		/*
		 * Passe … emplacement de sauvegarde suivant: 
		 */
		iorec_ptr++;

		/*
		 * Adresse BUFFER OUT: 
		 */
		iorec ++;
		/*
		 * Copie des donn‚es: 
		 */
		iorec_ptr -> ibuf		= iorec -> ibuf;
		iorec_ptr -> ibufsiz	= iorec -> ibufsiz;
		iorec_ptr -> ibuflow	= iorec -> ibuflow;
		iorec_ptr -> ibufhi	= iorec -> ibufhi;
		/*
		 * Passe … emplacement de sauvegarde suivant: 
		 */
		iorec_ptr++;

	}

	/*
	 * Maintenant que les ports s‚rie sont recens‚s...
	 *
	 * On initialise les vitesses:
	 * -le port de l'ic“ne TERMINAL est initialis‚ … 4800 bps
	 *  et on suppose qu'il y a un minitel au bout qu'on va initialiser
	 *  par la mˆme occasion
	 */
	init_MinitelPort( G_term_dev );

}



/*
 * SetPort(-)
 *
 * Purpose:
 * --------
 * Configuration d'un port s‚rie
 *
 * History:
 * --------
 * 30.09.94: fplanque: created
 */
void	SetPort(
			int		n_devno,				/* In: Port … utiliser, ex AUX */
			long		l_baud_rate,		/* In: Vitesse: ex: 9600 */
			char		c_parity,			/* In: Parit‚: 'E' 'O' ou 'N' */
			int		n_word_length,		/* In: Longueur de car: 5, 6, 7 ou 8 */
			int		n_mode,				/* In: Mode: ex: MODE_ASYNC1STOP */
			int		n_handshake )		/* In: Handshake: ex: HANDSHAKE_NONE */
{
	int	n_bpsIndex;
	int	n_ctr = 0x00;
	int	n_ucr	= 0x80;
	
	/*
	 * Cherche index correspondant au d‚bit souhait‚:
	 */
	for( n_bpsIndex = 0; rsconf_baudrates[ n_bpsIndex ] != 0; n_bpsIndex++ )
	{	
		if( rsconf_baudrates[ n_bpsIndex ] == l_baud_rate )
		{
			break;
		}
	}


	/*
	 * parit‚:
	 */
	switch( c_parity )
	{
		case	'e':
		case	'E':
			n_ucr |= PARITY_EVEN;
			break;
			
		case	'o':
		case	'O':
			n_ucr |= PARITY_ODD;

		/* Default: NONE */
	}


	/*
	 * Longueur des octets:
	 */
	switch( n_word_length )
	{
		case	7:
			n_ucr |= BITS_7;
			break;
			
		case	6:
			n_ucr |= BITS_6;
			break;
			
		case	5:
			n_ucr |= BITS_5;
			break;
			
		/* default: 8 */
	}
	

	/*
	 * Mode
	 * (sync/ nb of stop bits )
	 */
	n_ucr |= n_mode;


	/*
	 * Handshake:
	 */
	n_ctr = n_handshake;


	/*
	 * S‚lectionne le port … configurer:
	 */
	if( n_devno >= MOD1 )
	{	/*
		 * S'il s'agit d'un port ‚tendu:
		 */
		Bconmap( n_devno );
		if( Bconmap( -1 ) != n_devno )
		{	/*
			 * Si la s‚lection n'a pas ‚t‚ prise en compte:
			 */
			signale( "s‚lection port impossible!" );
			return;
		}
	}

	/*
	 * Configuration effective:
	 */
	Rsconf( n_bpsIndex, n_ctr, n_ucr, -1, -1, -1 );

	/*
	 * 10 centiŠmes de secs de pause:
	 */
	wait( 10 );

}


/*
 * restore_serial(-)
 *
 * Purpose:
 * --------
 * Restauration des buffers s‚rie par d‚faut(:… l'appel de l'appli)
 * lorsque l'on quitte par exemple.
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 02.03.95: modified loop method
 */
void	restore_serial( void )
{
	IOREC	*iorec_cpy;
	int i;
	int	device;
	
	for( i=0; i<M_def_nbserial; i++ )
	{
		device = G_inst_drv_list[ i ] .value;

		/*
		 * Adresse Buffer IN: 
		 */
		iorec_cpy = get_defiorec_cpy( device );
	
		/*
		 * Restore buffers: 
		 */
		install_newbuf( 0, device, iorec_cpy[0] .ibufsiz );	/* Installe nouveau buffer Entr‚e */
		install_newbuf( 1, device, iorec_cpy[1] .ibufsiz );	/* Installe nouveau buffer Sortie */
	}
}


 
/*
 * ---------------- GESTION PORTS SERIE DS FICHIER .INI -----------------
 */



/*
 * save_serial_ini(-)
 *
 * Purpose:
 * --------
 * Sauve paramŠtres des ports s‚rie dans fichier INI
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 02.03.95:
 */
void	save_serial_ini( 
			FILE *fstream )		/* In: Ptr sur fichier dans lequel on doit sauver */
{
	/*
	 * Variables: 
	 */
	int		offset;
	IOREC	*	iorec;			/* Iorec du port courant */

	/*
	 * Signale qu'on s'int‚resse ici aux paramŠtres s‚rie: 
	 */
	fputs( "\r\n[ Ports s‚rie: ]\r\n\r\n", fstream );		/* Commentaire */

	/*
	 * Parcourt les ports: 
	 */
	for( offset=0; offset<M_def_nbserial; offset++ )
	{
		/*
		 * Nom abr‚g‚ du port d‚sign‚: 
		 */
		fputs( "PORT ", fstream );
		fwrite( &G_inst_abrev[ offset ], sizeof( long ), 1, fstream  );
		fputc( ':', fstream );
		
		/*
		 * Taille des buffers: 
		 */
		iorec = get_iorec( G_inst_drv_list[ offset ] .value );		/* Adr zone d'infos (iorec) */
		fprintf( fstream, M_bufsize_filefmt, iorec[0] .ibufsiz, iorec[1] .ibufsiz );

		/*
		 * Commentaire de fin de ligne: 
		 */
		fprintf( fstream, "   !%s\r\n", G_inst_drv_list[ offset ] .name +1 );	/* +1: saute 1 espace */
	}
}


/*
 * serial_ini(-)
 *
 * Purpose:
 * --------
 * Fixe paramŠtres des ports s‚rie 
 * en utilisant les informations lues dans fichier INI
 *
 * Suggest:
 * --------
 * Modifier les messages d'erreurs, ne pas les afficher sur l'‚cran
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 18.05.94: fplanque: Ajout‚ messages d'erreur
 */
void	serial_ini( 
			char *object,			/* In: Objet concern‚ (Tete de Ligne lue ds fichier .INI), ici un poet s‚rie */
			char *data )			/* In: Donn‚es associ‚es … l'objet, ici taille des buffers */
{
	int	device;					/* P‚rif concern‚ */
	int	bsizein, bsizeout;	/* Taille des buffers demand‚e */

	if ( object == NULL )
	{
		signale("Ligne non valide");
	}
	else
	{
		/*
		 * Cherche port concern‚: 
		 */
		device = find_device_byabrev( object );			

		if ( device == NIL )
		{
			signale( "PORT Init: Port n'existe pas!" );
		}
		else
		{	/*
			 * Si on a trouv‚ le p‚rif: 
			 */
		
			/*
			 * D‚termine taille des buffers demand‚s par fichier INI: 
			 */
			sscanf( data, M_bufsize_filefmt, &bsizein, &bsizeout );
			/* printf(" >Tailles IN=%d, OUT=%d\n", bsizein, bsizeout ); */

			/*
			 * Installe nouveaux buffers de la taille demand‚e: 
			 */
			install_newbuf( 0, device, bsizein );	/* Installe nouveau buffer Entr‚e */
			install_newbuf( 1, device, bsizeout );	/* Installe nouveau buffer Sortie */
		}
	}
}



 
/*
 * --------------------- PARAM PAR L'UTILISATEUR ------------------------
 */



/*
 * param_term(-)
 *
 * Purpose:
 * --------
 * Param‚trage par l'utilisateur
 * d'un port s‚rie pour terminal
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void param_term( 
			const GRECT *start_box )	/* In: Rectangle de d‚part de l'effet graphique d'ouverture */
{
	int		exit_obj;					/* Objet de sortie */
	GRECT		form_box;					/* Dimensions du formulaire */
	int		edit = BUFOUT;				/* Objet en cours d'‚dition */
	char		*ptext_bufin = (M_termconf_adr[ BUFIN ] .ob_spec.tedinfo) -> te_ptext;
	char		*ptext_bufout = (M_termconf_adr[ BUFOUT ] .ob_spec.tedinfo) -> te_ptext;
	int		curr_device = G_term_dev;	/* P‚riph courant */

	/*
	 * Initialise les valeurs dans la boŒte: 
	 */
	param_term_initval( curr_device, ptext_bufin, ptext_bufout );

	/*
	 * Gestion boŒte dialogue: 
	 */
	/* App prend en charge souris */
	WIND_UPDATE_BEG_MCTRL
	open_dialog( M_termconf_adr, start_box, &form_box );
	
	do
	{
		exit_obj=ext_form_do( M_termconf_adr, &edit);	/* Gestion de la boŒte */
		switch( exit_obj )
		{
			case	PORT:
			case	PORTUP:
			{	/*
				 * S‚lection du port utilis‚: 
				 */
				int	selected;		/* Ligne s‚lectionn‚e */
				int	new_device;		/* Nouveau port serie s‚lectionn‚ */
				
				/*
				 * Appelle le Pop-Up: 
				 */
				selected = popup_inform( M_termconf_adr, exit_obj, PORT, G_inst_drv_list, curr_device );
			
				/* 
				 * V‚rifie si la s‚lection est valide: 
				 */
				if ( selected != ABORT_2 )
				{	/* 
					 * Si valide: 
					 * Conversion No de ligne -> no de port: 
					 */
					new_device = selected;
					
					/* V‚rifie qu'elle est diff‚rente de l'actuelle: */
					if ( new_device != curr_device )
					{	/*
						 * On a choisi un nouveau port s‚rie: 
						 * Nouveau port s‚lectionn‚: 
						 */
						curr_device = new_device;

						/* Fixe les nlles valeurs des buffers ds le formulaire: */
						param_term_initval( curr_device, ptext_bufin, ptext_bufout );

						/* R‚affiche les zones ayant chang‚: */
						objc_draw( M_termconf_adr, PORT, 1, form_box .g_x,
                              form_box .g_y, form_box .g_w, form_box .g_h );
						objc_draw( M_termconf_adr, BUFIN, 1, form_box .g_x,
                              form_box .g_y, form_box .g_w, form_box .g_h );
						objc_draw( M_termconf_adr, BUFOUT, 1, form_box .g_x,
                              form_box .g_y, form_box .g_w, form_box .g_h );
					}
				}
				
				/*
				 * Change csr souris en flŠche: 
				 */
				graf_mouse( ARROW, NULL );
				break;
			}
		}

	} while ( exit_obj != PTERMVAL && exit_obj != PTERMANN );

	close_dialog( M_termconf_adr, exit_obj, start_box, &form_box );
	/* AES peut reprendre la souris */
	WIND_UPDATE_END_MCTRL

	/*
	 * Teste s'il y a eu confirmation: 
	 */
	if ( exit_obj == PTERMVAL )
	{
		/* Change la taille des buffers en fonctions des valeurs demand‚es: */
		param_term_saveval( curr_device, ptext_bufin, ptext_bufout );

		/* Fixe nouveau port terminal: */
		G_term_dev = curr_device;
	}
}



/*
 * param_term_initval(-)
 *
 * Purpose:
 * --------
 * Init des valeurs concernant UN port dans le dialogue
 * de configuration des ports
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	param_term_initval(
			int device, 				/* In: No Bconmap du port concern‚ */
			char *ptext_bufin, 		/* In: Ptr sur texte:Taille IN ds tedinfo concern‚e */
			char *ptext_bufout )		/* In: Ptr sur texte:Taille OUT ds tedinfo concern‚e */
{
	/*
	 * Variables: 
	 */
	IOREC		*iorec_in;					/* Structure Iorec du tampon IN courant */
	int		bufsize_in;					/* Taille du tampon d'entr‚e */	
	IOREC		*iorec_out;					/* Structure Iorec du tampon OUT courant */
	int		bufsize_out;				/* Taille du tampon de sortie */	

	/*
	 * D‚termine taille des tampons: 
	 */
	iorec_in = get_iorec( device );
	bufsize_in = iorec_in -> ibufsiz;		/* Taille du tampon d'entr‚e */
	iorec_out = &iorec_in[1];
	bufsize_out = iorec_out -> ibufsiz;		/* Taille du tampon de sortie */

	/*
	 * Fixe cette taille dans le formulaire: 
	 */
	itoa( bufsize_in, ptext_bufin, 10 );		/* Conversion base 10 */
	itoa( bufsize_out, ptext_bufout, 10 );		/* Conversion base 10 */

	/* 
	 * Fixe nom du port dans le formulaire: 
	 */
	fix_popup_title( &M_termconf_adr[ PORT ], G_inst_drv_list, device );
}



/*
 * param_term_saveval(-)
 *
 * Purpose:
 * --------
 * Sauve les valeurs entr‚e pour UN port
 * dans le dialogue de configuration des ports s‚rie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	param_term_saveval( 
			int device, 				/* In: No Bconmap du port concern‚ */
			char *ptext_bufin, 		/* In: Ptr sur texte:Taille IN ds tedinfo concern‚e */
			char *ptext_bufout )		/* In: Ptr sur texte:Taille OUT ds tedinfo concern‚e */
{
	/*
	 * Variables: 
	 */
	int		newsize_in;
	int		newsize_out;
	
	/*
	 * R‚cupŠre taille des buffers: 
	 */
	newsize_in = (int) MIN( atol( ptext_bufin ), 32000 );	/* Taille demand‚e en entr‚e */
	newsize_out = (int) MIN( atol( ptext_bufout ), 32000 );	/* Taille demand‚e en sortie */

	/*
	 * Installe nouveaux buffers: 
	 */
	install_newbuf( 0, device, newsize_in );	/* Installe nouveau buffer Entr‚e */
	install_newbuf( 1, device, newsize_out );	/* Installe nouveau buffer Sortie */

}


 
/*
 * ----------- REPRESENTATION DES DIFFERENTS PORTS EN MEMOIRE -----------
 */



/*
 * device_offset(-)
 *
 * Purpose:
 * --------
 * D‚termine offset dans Maptab ou ds G_inst_drv_list 
 * d'un port d'aprŠs son no bconmap
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	device_offset(		/* Out: No d'ordre [0..n-1] du port */
			 int device )	/* In: No bconmap du port */
{
	int	i;
		
	/*
	 * Parcourt la liste des ports disponibles: 
	 */
	for( i=0; i<M_def_nbserial; i++ )
	{
		if( G_inst_drv_list[ i ] .value == device )
		{	/* 
			 * Si on a trouv‚ le port qui nous int‚resse: 
			 */
			return	i;			/* Retourne offset */
		}
	}

	/*
	 * Si on a pas trouv‚: ANORMAL 
	 */
	ping();
	TRACE1( "GetDevOffset: Port s‚rie %d inconnu", device );

	return	0;
}



/*
 * find_device_byabrev(-)
 *
 * Purpose:
 * --------
 * Trouve un no de p‚riph‚rique
 * en fonction de l'abr‚viation de son nom
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 02.03.95: ComplŠtement remodel‚
 */
int	find_device_byabrev( 		/* Out: no bconmap du p‚riph‚rique */
				char *abrev_string )	/* In:  abreviation du nom du port */
{
	long	abrev;		/* Abreviation du p‚riph‚rique */
	int	offset;		/* Offset du port ds liste */

	/*
	 * Cr‚e un Long Int contenant le codename du port: 
	 */
	abrev = ( ((unsigned long)abrev_string[0]) <<24) 
			| ( ((unsigned long)abrev_string[1]) <<16)
			| ( ((unsigned long)abrev_string[2]) <<8)
			| ( (unsigned long)abrev_string[3]);

	/*
	 * Cherche le port concern‚: 
	 */
	for( offset=0; offset<M_def_nbserial; offset++ )
	{
		/*
		 * Compare Nom abr‚g‚ du port d‚sign‚: 
		 */
		if( G_inst_abrev[ offset ] == abrev )
		{	/*
			 * On a trouv‚ le port: 
			 */
			return	G_inst_drv_list[ offset ] .value;
		}
	}
		
	/*
	 * On a pas trouv‚: 
	 */
	return	NIL;
}



/*
 * ----------- MANIPULATION DES BUFFERS IN/OUT DES PORTS SERIE ------------
 */


/*
 * get_iorec(-)
 *
 * Purpose:
 * --------
 * D‚termine adresse de la zone IOREC de n'importe quel port s‚rie
 *
 * Notes:
 * ------
 * La zone gŠre le buffer d'un port
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 02.03.95: calls device_offset()
 */
IOREC	*	get_iorec(			/* Out: Ptr sur IOREC demand‚e */
			 int device )		/* In: No bconmap du port dont on veut l'IOREC */
{
	/*
	 * Selon qu'il s'agit d'un port ‚tendu ou un port standard: 
	 */
	if ( device >= 6  &&  M_def_maptab != NULL )
	{	/* 
		 * S'il existe une table: 
		 */
		return	M_def_maptab[ device_offset(device) ] .iorec;
	}
	else
	{	/*
		 * Par defaut on donne le resultat pour le dev 1(AUX): 
		 */
		return	Iorec( 0 );			/* Donne Iorec RS232 */
	}
}



/*
 * get_defiorec_cpy(-)
 *
 * Purpose:
 * --------
 * D‚termine adresse de la copie d'IOREC d'origine d'un port s‚rie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 02.03.95: calls device_offset()
 */
IOREC	*get_defiorec_cpy(	/* Out: Ptr sur IOREC demand‚e */
			 int device )		/* In: No bconmap du port dont on veut la copie d'IOREC */
{
	/*
	 * Selon qu'il s'agit d'un port ‚tendu ou un port standard: 
	 */
	if ( device >= 6  &&  M_def_maptab != NULL )
	{	/* 
		 * S'il existe une table: 
		 */
		return	&M_def_iorecs_bak[ device_offset(device) *2 ];
	}
	else
	{	/*
		 * Par defaut on donne le resultat pour le dev 1(AUX): 
		 */
		return	M_def_iorecs_bak;			/* Donne Iorec RS232 */
	}
}



/*
 * install_newbuf(-)
 *
 * Purpose:
 * --------
 * Installe un nouveau buffer pour un port s‚rie
 *
 * Algo:
 * ----
 * Attend que le buffer OUT soit vide avant de le modifier
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	install_newbuf( 
			int in_out, 		/* In: 0 pour buffer IN et 1 pour buffer out */
			int device, 		/* In: No bconmap du port concern‚ */
			int newsize )		/* In: Nlle taille … donner au buffer */
{
	IOREC	*	iorec = &(get_iorec( device ))[ in_out ];
	int		oldsize = iorec -> ibufsiz;	/* Ancienne Taille */

	/* printf("%d: %d->%d ",device,oldsize,newsize); */

	/*
	 * Teste si la taille … chang‚: 
	 */
	if ( oldsize != newsize )
	{
		/*
		 * Variables: 
		 */
		void	*old_buffer = iorec -> ibuf;	/* Buffer actuel */
		void	*new_buffer;
		/*
		 * Trouve adresse de la copie d'Iorec par d‚faut: 
		 */
		IOREC	*def_iorec = &(get_defiorec_cpy( device ))[ in_out ];
		/*
		 * Taille par defaut: 
		 */
		int	defsize = def_iorec -> ibufsiz;

		/*
		 * Verifie s'il faut cr‚er un nouveau buffer: 
		 */
		if( newsize > defsize )
		{	/*
			 * Il faut cr‚er un nouveau buffer: 
			 */
			new_buffer = MALLOC( newsize );
			if( new_buffer == NULL )
			{
				alert( NOMEM_NEWBUF );	/* Pas assez de m‚moire pour nouveau buffer */
			}
			TRACE1(" New Buffer:%lX", new_buffer );
		}
		else
		{	/*
			 * Si le buffer standard suffit: 
			 */
			new_buffer = def_iorec -> ibuf;
		}


		/*
		 * S'il s'agit d'un buffer de sortie:
		 */
		if( in_out == 1 )
		{	/*
			 * On attend que ce buffer soit vide:
			 */ 
			/* TRACE0( "Attend que le buffer sortie soit vide" ); */

			while( iorec -> ibuftl != iorec -> ibufhd )
				;

			/* TRACE0( "Buffer vide: r‚allocation" );				*/
		}


		/*
		 * V‚rifie si l'adresse du nouveau buffer est valide: 
		 */
		if ( new_buffer != NULL )
		{
			/*
			 * Reset pointeurs … 0: 
			 */
			iorec -> ibufhd = 0;		/* Dernier car ‚crit en 0 */
			iorec -> ibuftl = 0;		/* Dernier car … lire en 0 */
	
			/*
			 * Fixe nlle adresse: (Ancien buffer) 
			 */
			iorec -> ibuf = new_buffer;
			/* 
			 * Fixe nlle taille: 
			 */
			iorec -> ibufsiz = newsize;
			
			/*
			 * Reset pointeurs … 0: (Nouveau Buffer) 
			 */
			iorec -> ibufhd = 0;		/* Dernier car ‚crit en 0 */
			iorec -> ibuftl = 0;		/* Dernier car … lire en 0 */
	
			/*
			 * V‚rifie s'il faut lib‚rer l'ancien buffer: 
			 */
			if( oldsize > defsize )
			{	/*
				 * Il faut lib‚rer l'ancien buffer: 
				 */
				FREE( old_buffer );
			}
		}	
	}
}



/*
 * FlushRXBuffer(-)
 *
 * Purpose:
 * --------
 * Vide le tampon d'entr‚e d'un port s‚rie
 *
 * Algorythm:
 * ----------
 * Read until buf empty
 *
 * Notes:
 * ------
 * Ne JAMAIS utiliser lorsque le port est en mode connect‚
 * NEVER EVER use this when port is connected with remote terminal
 * Risque de perte d'infos importantes
 * Risk of important loss of information
 *
 * History:
 * --------
 * 19.11.94: fplanque: Created
 */
void	FlushRXBuffer( int n_device )	/* In: Port concern‚ */
{
	while( Bconstat ( n_device ) )
	{
		Bconin( n_device );	/* Lit 1 code/caractŠre */
	}
}


/*
 * Serial_FlushTX(-)
 *
 * Purpose:
 * --------
 * Vide le tampon de sortie d'un port s‚rie
 *
 * Algorythm:
 * ----------
 * 'hard' reset of buffer pointers!  Tail:=Head
 *
 * Notes:
 * ------
 * Use Sparingly!
 *
 * History:
 * --------
 * 29.03.95: fplanque: Created
 */
void	Serial_FlushTX( 
			int n_device )	/* In: Port concern‚ */
{
	IOREC	* pIorec = get_iorec( n_device );
	
	pIorec[ IOREC_OUT ] .ibuftl = pIorec[ IOREC_OUT ] .ibufhd;
}


/*
 * Serial_WaitTXEmpty(-)
 *
 * Purpose:
 * --------
 * Attend que le tampon de sortie d'un port s‚rie soit vide
 *
 * Algorythm:
 * ----------
 * 'hard' test of buffer pointers!  Tail==Head
 *
 * History:
 * --------
 * 08.04.95: fplanque: Created
 */
void	Serial_WaitTXEmpty( 
			int n_device )	/* In: Port concern‚ */
{
	IOREC	* pIorec = get_iorec( n_device );
	
	while( pIorec[ IOREC_OUT ] .ibuftl != pIorec[ IOREC_OUT ] .ibufhd )
		;

	/*
	 * Attend 5 msec suppl‚mentaires:
	 */	
	wait( 5 );	
}


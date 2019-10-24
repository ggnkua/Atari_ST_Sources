/*
 * SerComnd.c
 *
 * Traitement des commandes utilisateur
 *
 * 15.03.95: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"SERCOMND.C v1.00 - 02.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
	#include	<string.h>
	#include	<stdlib.h>

/*
 * Custom headers:
 */
	#include	"MINITEL.H"
	#include	"DEF_ARBO.H" 

	#include "SPEC_PU.H"

	#include "DEBUG_PU.H"
	#include "SERV_PU.H"
	#include	"LECTM_PU.H"
	#include "TEXT_PU.H"
	#include	"IOFLD_PU.H"
	#include "ARBKEYPU.H"
	#include "LINE0_PU.H"
	#include "POPUP_PU.H"
	#include "TERM_PU.H"
	#include "LISTD_PU.H"	
	#include	"SRIAL_PU.H"
	#include "SERCOMPU.H"
	#include "LISTS_PU.H"

	static	int	M_key_link[]=
		{
		/*	KEY_NONE,	*/	NIL,			/* Aucune touche n'a ‚t‚ press‚e */ 
		/*	KEY_SOMM,	*/	FL_SOMM,
		/*	KEY_GUIDE,	*/	FL_GUIDE,
		/*	KEY_ANNUL,	*/	FL_ANNUL,
		/*	KEY_CORREC,	*/	FL_CORREC,
		/*	KEY_RETOUR,	*/	FL_RETOUR,
		/*	KEY_SUITE,	*/	FL_SUITE,
		/*	KEY_REPET,	*/	FL_REPET,
		/*	KEY_ENVOI,	*/	FL_ENVOI
		};
	 

/*
 * ----------------------------- METHODES ----------------------------
 */

/*
 * extract_number(-)
 *
 * Extrait un nombre en debut de chaine de caractŠres:
 *
 * 15.03.95: created
 */
BOOL	extract_number(				/* Out: TRUE si OK */
			const char * cpsz,		/* In:  chaine de caractŠres */
			long		  * pl_number )/* Out: nombre trouv‚ */
{
	char	car;
	int	i;
	
	if( cpsz == NULL )
	{
		return	FALSE0;
	}
	
	for( i=0;
			(car = cpsz[i]) != '\0';
			  i++ )
	{
		if( car>='0' && car <='9' )
		{
			*pl_number = atol( cpsz );
			return	TRUE_1;
		}
		
		if( car != ' ' )
		{
			return	FALSE0;
		}
		
	}
	
	return	FALSE0;
}


/*
 * Command_DelRecord(-)
 *
 * Purpose:
 * --------
 * Commande Delete d‚terminant l'effacement
 *
 * History:
 * --------
 * 15.03.95: fplanque: Created
 */
BOOL	Command_DelRecord(				/* Out: !FALSE si succŠs */
			VOIE	*	pVoie_curr,			/* In:  Voie concern‚e */
			char	*	piBsz_Arguments )	/* In:  Arguments pass‚s derriŠre la commande */
{
	switch( (pVoie_curr -> arboparams) -> fnct_no )
	{	/*
		 * Selon la fonction de la page arbo: 
		 */
		case	FA_LECT_MSG:
			/*
			 * Effacement du message courament affich‚ … l'‚cran:
			 */
			return	LectMsg_EraseCurrRec( pVoie_curr );		
	
		case	FA_LIST:
		case	FA_DIRECTORY:
			/*
			 * Effacement du record donn‚ en paramŠtre:
			 */
			return	ListDB_CmdDelRec( pVoie_curr, piBsz_Arguments );	
				
		default:
			add_textinf( pVoie_curr -> wi_params, "WARNING: Action appell‚e hors-contexte!" );
	}


	/*
	 * On a ps pu ‚x‚cuter:
	 */
	return	FALSE0;
}


/*
 * Serv_DoAction()
 *
 * Execute une action
 *
 * 31.03.95: fplanque: Created
 */
BOOL Serv_DoAction(
			VOIE	*	pVoie_curr,		/* In:  Voie concern‚e */
			int		n_Action,
			char	*	psz_more,		/* In:  Plus d'arguments */
			BOOL	*	b_CsrMoved )
{
	BOOL					b_ActionSuccess = TRUE_1;	/* Par d‚faut */

	if( n_Action != ACTION_NONE ) 
	{ 
		sprintf( G_tmp_buffer, "   Action: %s", get_popup_name( G_Popup_ActionMenu, n_Action ) );
		add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
	
		switch( n_Action )
		{
			case	ACTION_CLS:
				cconout( pVoie_curr -> device, FF );
				*b_CsrMoved = TRUE_1;
				break;
				
			case	ACTION_FULLCLS:
				Serial_FlushTX( pVoie_curr -> device );
				full_cls( pVoie_curr -> device );
				*b_CsrMoved = TRUE_1;
				break;
				
			case	ACTION_2BOMBES:
			{	/*
				 * Provoque un plantage g‚n‚ral volontaire !!! (2 Bombes)
				 */
				char * ptr = NULL;
				*ptr = *ptr;
				break;
			}
			
			case	ACTION_DEL_RECORD:
				/*
				 * Effacement d'un enregistrement:
				 */
				b_ActionSuccess = Command_DelRecord( pVoie_curr, psz_more );
				break;
				
			default:
				signale( "Ne sait pas traiter l'action demand‚e" );
		}
	}

	return b_ActionSuccess;
}

/*
 * Serv_ExecuteCommand(-)
 *
 * Appell‚ par mot clef ou ‚vŠnement
 * D‚clenche les actions associ‚es
 *
 * 31.03.95: fplanque: Created
 * 12.07.95: fplanque: renvoie un bool‚un indiquant si on a fait un JUMP ou non
 * 14.10.95: fplanque: ne fait pas de JUMP si la page destination est une chaine vide
 */
BOOL	Serv_ExecuteCommand(						/* Out: TRUE_1 si on a fait un JUMP */
			VOIE				*	pVoie_curr,		/* In:  Voie concern‚e */
			KEYWORD_LIST 	*	p_Command,		/* In:  Commande … traiter */
			char				*	psz_more )		/* In:  Plus d'arguments */
{
	BOOL			b_CsrMoved = FALSE0;

	/*
	 * Action 1 associ‚e … la touche/mot clef:
	 */
	if( Serv_DoAction( pVoie_curr, p_Command -> n_Action1, psz_more, &b_CsrMoved ) == TRUE_1 )
	{	/*
		 * Nlle page arbo associ‚e … la touche:
		 */
		char	*	new_page = p_Command -> psz_DestPage;	
	
		if( new_page != NULL && new_page != G_empty_string && new_page[0] != '\0' )
		{	/*
			 * Si une page est associ‚e au mot clef:
			 * Action 2 associ‚e … la touche/mot clef:
			 */
			if( Serv_DoAction( pVoie_curr, p_Command -> n_Action2, psz_more, &b_CsrMoved ) == TRUE_1 )
			{	/*
				 * Passe en phase de changement de page:
				 */
				register_action( pVoie_curr, JUMP, 0, 0, new_page );	
				return TRUE_1;
			}
		}
	}
	
	if( b_CsrMoved == TRUE_1 )
	{	/*
		 * Pas de saut de page
		 * MAIS on a boug‚ le curseur:
		 * il faut le remettre en place:
		 */
		place_csr( pVoie_curr );
	}

	return	FALSE0;
}



/*
 * serv_handleKeyword(-)
 *
 * Purpose:
 * --------
 * Analyse ligne de commande et d‚termine s'il s'agit d'un mot clef
 * execute l'action voulue
 * et demande de se rendre … l'endroit voulu
 *
 * Algorythm:
 * ----------  
 * - cherche si on connait le MC
 * - exec action
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 * 27.11.94: ne fait rien si on est pas en cours d'‚dition
 * 05.12.94: introduced c_KeywordIdentifier
 * 30.01.95: coupe params derriŠre le mot clef
 * 15.03.95: traite commandes; corrig‚ bug detection pas de destination
 * 28.03.95: gestion position curseur am‚lior‚e
 * 12.07.95: fplanque: la gestion de csr ci-dessus entrainait des actions en trop (et des bugs) si l'action produisait un JUMP: rajout‚ le test n‚cessaire
 */
BOOL	serv_handleKeyword(							/* Out: FALSE0 si pas de mot clef … traiter */
				VOIE	*	pVoie_curr,					/* In: Voie concern‚e */
				char		c_KeywordIdentifier )	/* In: car obligatoire en d‚but de champ pour indiquer que c'est un mot clef ou bien '\0' */
{
	PAGEARBO			*	pPgArbo_curr;
	KEYWORD_LIST	*	pDTL_MotsClefs;
	KEYWORD_LIST 	*	pDTL_MotClef;
	const char		*	cpBsz_CmdLine;
	char				*	pisz_Separator;
	
	if( GetEditMode( pVoie_curr ) != FIELDEDIT )
	{	/*
		 * S'il n'y a pas de champ d'‚dition, 
		 * il n'y a aucune chance qu'on ait tap‚ un mot clef! :
		 */
		return	FALSE0;
	}

	/*
	 * Obtient ligne de commande:	(NE PAS MODIFIER la ligne de commande!)
	 */
	cpBsz_CmdLine = aim_CurrField( pVoie_curr );
	
	if( cpBsz_CmdLine[0] == '\0' )
	{	/*
		 * Si la ligne est vide:
		 */
		return	FALSE0;
	}

	if( c_KeywordIdentifier && cpBsz_CmdLine[0] != c_KeywordIdentifier )
	{	/*
		 * La ligne ne commence pas par le car exig‚ pour Mot clef
		 * donc on considŠre que c'est pas un mot clef!
		 */
		return	FALSE0;
	}

	/*
	 * Recopie ligne de commande dans le tmp buffer:
	 */
	strncpy( G_2nd_buffer, cpBsz_CmdLine, SECOND_BUFFER_SIZE );
	G_2nd_buffer[ SECOND_BUFFER_SIZE ] = '\0';
	/* printf("\nCommand line: %s\n", G_2nd_buffer );*/
	
	pisz_Separator = strchr( G_2nd_buffer, ' ' );
	if( pisz_Separator != NULL )
	{	/*
		 * Coupe les params derriŠre le mot clef:
		 */
		*(pisz_Separator++) = '\0';
		/* printf( "Params= %s\n", pisz_Separator ); */
	}

	/*
	 * S'il y a un mot clef sur la ligne:
	 * ParamŠtres de la page arbo courante 
	 */
	pPgArbo_curr = pVoie_curr -> arboparams;
	pDTL_MotsClefs = pPgArbo_curr -> p_MotsClefs;		/* Ptr sur liste de Mots clefs */
	
	/*
	 * Cherche mot clef:
	 */
	pDTL_MotClef = findElt_KWLst_by1stName( pDTL_MotsClefs, G_2nd_buffer );

	if( pDTL_MotClef == NULL )
	{	/*
	 	 * Mot clef non reconnu:
	 	 */
		aff_msg_l0( pVoie_curr, "Commande invalide!" );
		
		/*
	 	 * Note: on considŠre que l'action a ‚t‚ correctement trait‚e!:
	 	 */
		return	TRUE_1;
	}
	
	/*
	 * Affiche Mot clef sur moniteur:
	 */
	sprintf( G_tmp_buffer, "  Commande: %s", cpBsz_CmdLine );
	add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );

	/*
	 * Ex‚cute commande associ‚e au mot clef:
	 */
	if( Serv_ExecuteCommand( pVoie_curr, pDTL_MotClef, pisz_Separator ) == FALSE0 )
	{	/*
	 	 * La commande a ‚t‚ prise en compte mais n'a pas entraŒn‚ de JUMP:
		 * on efface le champ de saisie et on attend la prochaine:
		 */
		register_action( pVoie_curr, CLRF, 0, 0, pVoie_curr -> pIOField_CurrIn );		
		register_action( pVoie_curr, WAIT, 0, 0, NULL );		/* Repasse en mode d'attente d'action */
	}
	
	return	TRUE_1;
}


/*
 * keyaction_std(-)
 *
 * Purpose:
 * --------
 * R‚agit … la touche press‚ sur une page standard
 *
 * History:
 * --------
 * fplanque: Created
 * 24.05.94: Gestion desmots clefs
 */
void	keyaction_std(
			KEYCODE 	curr_keypress, 
			VOIE *	pVoie_curr )
{

	switch( curr_keypress )
	{
		case	KEY_ENVOI:	
			if( ! serv_handleKeyword( pVoie_curr, '\0' ) )
			{	/*
				 * Si pas de mot clef:
				 * Action par d‚faut de la touche envoi:
				 */
				affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */
		
				/*
				 * Demande Changement de page:
				 */
				follow_KeyArboLink( pVoie_curr, curr_keypress );
			}
			break;
					
		case	KEY_RETOUR:
		case	KEY_REPET:
		case	KEY_GUIDE:
		case	KEY_ANNUL:
		case	KEY_SOMM:
		case	KEY_CORREC:
		case	KEY_SUITE:
			affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */
			/*
			 * Demande Changement de page:
			 */
			follow_KeyArboLink( pVoie_curr, curr_keypress );
			break;

	}

}




/*
 * follow_KeyArboLink(-)
 *
 * Purpose:
 * --------
 * Provoque un JUMP correspondant au lien arbo
 * associ‚ … la touche donn‚e
 *
 * Algorythm:
 * ----------  
 *	-Cherche paramŠtres de la touche
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 * 30.01.95: appel de follow_ArboLink()
 */
void	follow_KeyArboLink(
				VOIE *	pVoie_curr,			/* In: Voie en cours de traitement */
				KEYCODE	curr_keypress )	/* In: Code touche … suivre */
{
	/* 
	 * Num‚ro de fonction du lien associ‚ … cette touche:
	 */
	int	currlink_fnctno = M_key_link[ curr_keypress ];	

	follow_ArboLink( pVoie_curr, currlink_fnctno );
}				




/*
 * follow_ArboLink(-)
 *
 * Purpose:
 * --------
 * Provoque un JUMP correspondant au lien arbo de fonction demand‚e
 *
 * History:
 * --------
 * 30.01.95: fplanque: Created based on follow_KeyArboLink()
 * 29.03.95: quickchanged to use KEYWORD_LIST
 * 31.03.95: appel de Serv_ExecuteCommand()
 * 14.10.95: renvoie TRUE_1 uniquement s'il y a eu un JUMP
 */
BOOL	follow_ArboLink(					/* In: TRUE_1 si on a fait un JUMP */
				VOIE *	pVoie_curr,		/* In: Voie en cours de traitement */
				int		n_FnctLink )	/* In: Fonction lien demand‚e */
{
	/*
	 *	Trouve les paramŠtres de la touche:
	 */
	DATAPAGE		 *	curr_page = pVoie_curr -> arbopage;
	PAGEARBO		 *	curr_arbopar = curr_page -> data.pagearbo;
	KEYWORD_LIST *	key_params = Lookup_SingleLinkList( curr_arbopar -> p_Events, n_FnctLink );

	if( key_params != NULL )
	{	/*
		 * Si une commande est associ‚e … la fonction lien demand‚e:
		 * Ex‚cute commande associ‚e … l'‚vŠnement:
		 */
		if( Serv_ExecuteCommand( pVoie_curr, key_params, NULL ) )
		{
			return TRUE_1;
		}
	}

	return	FALSE0;
}				



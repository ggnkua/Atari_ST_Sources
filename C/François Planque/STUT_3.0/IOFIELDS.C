/*
 * IoFields.c
 *
 * Purpose:
 * -------- 
 * Routines de traitement des champs de saisie/sortie
 *
 * History:
 * --------
 * 09.12.94: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"IOFIELDS.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include <string.h>					/* header tt de chaines */
   

/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "S_MALLOC.H"
	#include	"SERV_PU.H"
	#include	"LINE0_PU.H"
	#include	"DBINT_PU.H"		/* DB Interface */
	#include	"DEBUG_PU.H"	
	#include "DBSYS_PU.H"
	#include "TEXT_PU.H"
	#include "TERM_PU.H"
	#include "MAIN_PU.H"
	#include "DEF_ARBO.H"
	#include "IOFLD_PU.H"
	
/*
 * ---------------------------- METHODES --------------------------
 */


/*
 * GetEditMode(-)
 *
 * Purpose:
 * --------
 * D‚termine le mode d'‚dition de la voie en question
 *
 * History:
 * --------
 * 10.05.94: fplanque: Created
 * 21.08.94: fplanque: se base maintenant sur pIOField_CurrIn
 * 12.07.95: fplanque: chang‚ de IsEditing() en GetEditMode()
 */
EDIT_MODE	GetEditMode(				/* Out: Mode d'‚dition courant de la voie concern‚e */
					VOIE *pVoie_curr )	/* In:  Ptr sur voie courante */
{
	if( pVoie_curr -> curr_textline == NULL )
	{	/*
		 * On ne peut mˆme pas stocker les donn‚es re‡ues,
		 * donc interaction de base:
		 */
		return	BASIC;
	}

	if( pVoie_curr -> pIOField_CurrIn == NULL )
	{	/*
		 * Pas de descripteur de champ,
		 * donc on ne peut que stocker sans edition avanc‚e:
		 */
		return 	BUFFERING;
	}
	
	/*
	 * Edition complŠte:
	 */
	return	FIELDEDIT;
}


/*
 * get_InFieldPars(-)
 *
 * Purpose:
 * --------
 * Cherche champ demand‚ dans la voie courante 
 * et renvoie ptr sur ses paramŠtres
 *
 * History:
 * --------
 * 24.11.94: fplanque: Created
 */
FLD_STATUS get_InFieldPars( 				/* Out: FLD_NOT_FOUND, FLD_DISABLED ou FLD_READY */
				VOIE 		*	pVoie_curr,		/* In:  Voie concern‚e */
				int			n_fnct,			/* In:  Fonction recherch‚e */
				IOFIELD **	ppInField )		/* Out: ptr sur params ou NULL si pas trouv‚ */
{
	/* 
	 * Variables: 
	 */
	IOFIELD	*	pIOField_CurrIn;
	int 			index;

	/*
	 * Cherche le champ d‚sir‚: 
	 */
	for( pIOField_CurrIn = pVoie_curr -> pIOField_ListIn, index=1 ;
			pIOField_CurrIn != NULL; pIOField_CurrIn = pIOField_CurrIn -> p_next, index++ )
	{
		if( pIOField_CurrIn -> FPar.Input -> fnct_no == n_fnct )
		{	/*
			 * Si trouv‚ champ de fonction demand‚e:
			 */
			*ppInField = pIOField_CurrIn;
			if( pIOField_CurrIn -> FPar.Input -> InFieldFlags .b_enabled )
			{
				return	FLD_READY;
			}
			
			return	FLD_DISABLED;
		}
	}
	
	*ppInField = NULL;
	return		FLD_NOT_FOUND;
}




/*
 * Create_ArboPageInFieldList(-)
 *
 * Purpose:
 * --------
 * Init des champs d'‚dition de la page courante sur la voie d‚sir‚e
 *
 * Algorythm:
 * ----------  
 * - Cr‚ation d'une liste chain‚e des champs de saisie avec ptrs sur
 *   PARAMS d'affichage ET BUFFERS de saisie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 21.08.94: cr‚ation de la liste de INFIELDs
 * 27.11.94: plus d'affichage des champs cr‚‚s
 * 05.12.94: ne m‚morise que les champs activ‚s; DOUBLE CHAINAGE!
 * 17.12.94: gestion champ scrollable
 */
void	Create_ArboPageInFieldList( 
			VOIE *	pVoie_curr )		/* In: Voie concern‚e */
{
	IOFIELD			**	ppInFields_prevnext = &(pVoie_curr -> pIOField_ListIn); 
	IOFIELD			*	pIOField_CurrIn;		
	IOFIELD			*	pInField_Previous	= NULL;
	PAGEARBO 		*	curr_arboparams	= pVoie_curr -> arboparams;
	ARBO_FIELDPARS	*	pFieldPars_Curr 	= curr_arboparams -> input_fields;	

	/*
	 * V‚rifie que la liste des champs d'entr‚e est vide:
	 */
	if( pVoie_curr -> pIOField_ListIn != NULL )
	{
		signale( "Liste des champs d'entr‚e non initialis‚e!" );
	}

	/*
	 * Parcourt les champs: 
	 */
	while( pFieldPars_Curr != NULL )
	{
		if( pFieldPars_Curr -> data.input .InFieldFlags.b_enabled == TRUE_1 )
		{	/*
			 * Si champ est activ‚:
			 * Cr‚e un bloc de paramŠtres pour ce champ de saisie:
			 */
			pIOField_CurrIn = (IOFIELD *) MALLOC( sizeof( IOFIELD ) );

			/*
			 * linkage PARAMS d'affichage: 
			 */
			pIOField_CurrIn -> FPar.Input = &(pFieldPars_Curr -> data.input);

			/*
			 * CREATION et linkage d'une ZONE m‚moire pour l'‚dition: 
			 */
			pIOField_CurrIn -> pTextInfo = create_textedit_zone( );

			/*
			 * M‚morise ligne au top de la zone d'affichage:
			 */
			pIOField_CurrIn -> pTextLine_Top = pIOField_CurrIn -> pTextInfo -> firstline -> next;
			pIOField_CurrIn -> l_TopLine		 = 1;		/* On est sur la ligne no 1 */

			/* 
			 * Chainage de la liste:
			 */
			*ppInFields_prevnext = pIOField_CurrIn;
			pIOField_CurrIn -> p_prev = pInField_Previous;
			
			/*
			 * Pour le linkage du champ suivant:
			 */
			pInField_Previous = pIOField_CurrIn;
			ppInFields_prevnext = &( pInField_Previous -> p_next );
	
		}

		/*
		 * Passe au champ suivant: 
		 */
		pFieldPars_Curr = pFieldPars_Curr -> next;
	}

	/*
	 * Fin de liste chaŒn‚e:
	 */
	*ppInFields_prevnext = NULL;
}


/*
 * display_field(-)
 *
 * Purpose:
 * --------
 * Affiche un champ d'‚dition sur le minitel
 * texte + car d'appel … la SAISIE
 * limites top et bottom
 *
 * History:
 * --------
 * 21.08.94: fplanque: Created
 * 22.08.94: IntŠgre maintenant un clipping vertical
 * 17.12.94: gestion champ scrollable
 * 18.12.94: Correction du bug de placement des caractŠres d'info sur continuit‚ des Ý
 * 08.01.95: affiche les champs crypt‚s; corrig‚ bug fill pour champ … 1 seul car
 */
void	display_field(
			int			device,	
			IOFIELD	*	pIOField_In,	/* In: ptr sur champ … afficher */
			int			n_ClipTop,	/* In: Limite sup‚rieure pour l'affichage */
			int			n_ClipBot )	/* In: Limite inf‚ieure pour l'affichage */
{
	/*
	 * ParamŠtres d'affichage:
	 */
	INPUT_FPAR		*	pInputFPar_Curr = pIOField_In -> FPar.Input;
	TEXTLINE			*	pTextLine	 	 = pIOField_In -> pTextLine_Top;

	int	x, y;			
	int	fill;			/* Support d'‚criture */
	int	text_length;
	int	n_line_length = pInputFPar_Curr -> w;
	BOOL	b_MultiParagraph = pInputFPar_Curr -> InFieldFlags.b_MultiParagraph;
	int	n_AscCache = pInputFPar_Curr -> asc_cach;

	/*
	 * Init Variables: 
	 */
	x		= pInputFPar_Curr -> x;				/* Position x */
	fill	= pInputFPar_Curr -> asc_fill;		/* Support */

	for ( y = pInputFPar_Curr -> y; 
			y < (pInputFPar_Curr -> y + pInputFPar_Curr -> h)
			&& y <= n_ClipBot;
			y++ )
	{
		if( y >= n_ClipTop )
		{	/*
			 * S'il faut afficher:
			 * Positionne le curseur: 
			 */
			pos( device, x, y );
	
			text_length = 0;
	
			/*
			 * Affiche texte:
			 */
			if( pTextLine != NULL )
			{
				text_length = pTextLine -> length;
				if( text_length > 0 )
				{
					set_tcolor( device, pInputFPar_Curr -> col_text );	/* Couleur texte */
					if( n_AscCache )
					{
						mconout( device, n_AscCache, text_length );
					}
					else
					{
						str_conout( device, pTextLine -> text );
					}
				}
			}
	
			/*
			 * Affiche Fin de ligne & support: 
			 */
			if( text_length < n_line_length )
			{
				set_tcolor( device, pInputFPar_Curr -> col_fill );	/* Couleur support */
	
				if( pTextLine == NULL )
				{
					cconout( device, fill );
				}
				else if( pTextLine -> info1.continued )
				{	/*
					 * Le paragraphe continue sur la ligne suivante:
					 */
					cconout( device, PARAGRAPH_CONT );	
				}
				else if( b_MultiParagraph )
				{	/*
					 * Cette ligne marque la fin d'un paragraphe:
					 * On affiche une marque uniquement en mode multi paragrapphes:
					 */
					cconout( device, PARAGRAPH_STOP );	
				}
				else
				{	/*
					 * Mode mono paragraphe:
					 */
					cconout( device, fill );
				}
				
				if( fill >= ' ' )
				{	/*
					 * S'il y a un support: 
					 */
					mconout( device, fill, n_line_length - text_length -1 );		/* Affiche support */
				}
			}
		}
		
		if( pTextLine != NULL )
		{	/*
			 * Passe … la ligne suivante:
			 */
			pTextLine = pTextLine -> next;
		}
	}
}



/*
 * start_fieldedit(-)
 *
 * Purpose:
 * --------
 * D‚but de l'‚dition d'un champ pour la voie d‚sir‚e
 *
 * Algorythm:
 * ----------  
 * - Si ptr sur champ == NULL : Cherche champ demand‚
 * - initialise edition pour ce champ
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 21.08.94: fplanque: utilise d‚sormais la liste de INFIELDs
 * 13.11.94: cherche le champ de fonction demand‚e
 * 16.11.94: d‚tection fonction inconnue
 * 24.11.94: mini modif
 * 27.11.94: affichage du champ lorsqu'on s'y place
 * 05.12.94: don't care about the 'field index' any longer
 * 17.12.94: gestion champ scrollable
 * 05.01.94: recoit le champ demand‚ en paramŠtre
 */
int	start_fieldedit( 							/* Out:	FALSE si OK */
				VOIE	 	*	pVoie_curr,			/* In:	Voie concern‚e */
				int			n_fnct,				/* In:	Fonction de champ recherch‚e si pas de ptr direct sur champ */
				IOFIELD	*	pIOField_CurrIn )	/* In:	Ptr sur champ voulu si connu, NULL sinon: ds ce cas on cherche avec le no de fnct */
{
	if( pIOField_CurrIn == NULL )
	{	/*
	    * Cherche le champ d‚sir‚: 
	 	 */
		for( pIOField_CurrIn = pVoie_curr -> pIOField_ListIn;
				pIOField_CurrIn != NULL;
				 pIOField_CurrIn = pIOField_CurrIn -> p_next )
		{
			if( pIOField_CurrIn -> FPar.Input -> fnct_no == n_fnct )
			{	/*
				 * Si trouv‚ champ de fonction demand‚e:
				 */
				break;
			}
		}
		
		if( pIOField_CurrIn == NULL )
		{	/*
			 * PROBLEME: Champ introuvable:
			 */
			ping();
			add_textinf( pVoie_curr -> wi_params, "BUG: Fonction INPUT inconnue!" );
		
			return	ERROR_1;		/* Break! */
		
		}
	}
	
	/*
	 * M‚morise nouveau champ de saisie courant: 
	 */
	pVoie_curr -> pIOField_CurrIn = pIOField_CurrIn;

	/*
	 * Affichage du champ sur le Minitel:
	 */
	display_field( pVoie_curr -> device, pIOField_CurrIn, 0, 1000 );

	/*
	 * Ligne en cours d'‚dition
	 * (ligne actuellement affich‚e au top de la zone d'‚dition)
	 */
	pVoie_curr -> curr_textline = pIOField_CurrIn -> pTextLine_Top;
	pVoie_curr -> l_CurrLine	 = pIOField_CurrIn -> l_TopLine;
	
	pVoie_curr -> csr_x = pIOField_CurrIn -> FPar.Input -> x +	pVoie_curr -> curr_textline -> length;
	pVoie_curr -> csr_y = pIOField_CurrIn -> FPar.Input -> y;

	return	FALSE0;
	
}



/*
 * Move_FocusToFirstInField(-)
 *
 * Purpose:
 * --------
 * Se d‚place vers le PREMIER champ de saisie activ‚ de la page
 * en affichant la page vid‚otex associ‚e au passage
 *
 * Suggest:
 * --------
 * Am‚liorer le systŠme register_acrion: ajouter des paramŠtres
 *
 * History:
 * --------
 * 05.12.94: fplanque: Created
 */
void	Move_FocusToFirstInField(
				VOIE 	*	pVoie_curr )	/* In: Voie concern‚e */
{
	if( pVoie_curr -> pIOField_ListIn != NULL )
	{	/*
		 * S'il y a un champ, on demande l'entr‚e ds ce champ:
		 */
		register_action( pVoie_curr, DISP, pVoie_curr -> pIOField_ListIn -> FPar.Input -> fnct_no, 0, NULL );		
		register_action( pVoie_curr, EFLD, 0, 0, pVoie_curr -> pIOField_ListIn );		
	}

	/*
	 * Repasse en mode d'attente d'action:
	 */
	register_action( pVoie_curr, WAIT, 0, 0, NULL );
}



/*
 * Move_FocusToNextInField(-)
 *
 * Purpose:
 * --------
 * Se d‚place vers le PROCHAIN champ de saisie activ‚ de la page
 * en affichant la page vid‚otex associ‚e au passage
 *
 * Suggest:
 * --------
 * Am‚liorer le systŠme register_acrion: ajouter des paramŠtres
 *
 * History:
 * --------
 * 05.12.94: fplanque: Created
 * 05.01.94: profite du des params ACTION
 */
void	Move_FocusToNextInField(
				VOIE 	*	pVoie_curr )	/* In: Voie concern‚e */
{
	if( pVoie_curr -> pIOField_CurrIn != NULL )
	{	/*
		 * S'il y a au moins un champ d'‚dition:
		 */
		IOFIELD	*	pInField_Target = pVoie_curr -> pIOField_CurrIn -> p_next;

		if( pInField_Target != NULL )
		{	/*
			 * S'il y a un autre champ aprŠs, 
			 * on demande d'afficher la page vdt correspondante et d'y aller:
			 */
			register_action( pVoie_curr, DISP, pInField_Target -> FPar.Input -> fnct_no, 0, NULL );		
			register_action( pVoie_curr, EFLD, 0, 0, pInField_Target );		
		}
		else
		{	/*
			 * On est sur le dernier champ:
			 * On le signale:
			 */
			aff_msg_l0( pVoie_curr, "Dernier champ de saisie!" );
		}
	}

	/*
	 * Repasse en mode d'attente d'action:
	 */
	register_action( pVoie_curr, WAIT, 0, 0, NULL );
}


/*
 * Move_FocusToPrevInField(-)
 *
 * Purpose:
 * --------
 * Se d‚place vers le PRECEDENT champ de saisie activ‚ de la page
 * en affichant la page vid‚otex associ‚e au passage
 *
 * Suggest:
 * --------
 * Am‚liorer le systŠme register_action: ajouter des paramŠtres
 *
 * History:
 * --------
 * 05.12.94: fplanque: Created
 * 05.01.94: profite des params ACTION
 */
void	Move_FocusToPrevInField(
				VOIE 	*	pVoie_curr )	/* In: Voie concern‚e */
{
	if( pVoie_curr -> pIOField_CurrIn != NULL )
	{	/*
		 * S'il y a au moins un champ d'‚dition:
		 */
		IOFIELD	*	pInField_Target = pVoie_curr -> pIOField_CurrIn -> p_prev;

		if( pInField_Target != NULL )
		{	/*
			 * S'il y a un autre champ avant, 
			 * on demande d'afficher la page vdt correspondante et d'y aller:
			 */
			register_action( pVoie_curr, DISP, pInField_Target -> FPar.Input -> fnct_no, 0, NULL );		
			register_action( pVoie_curr, EFLD, 0, 0, pInField_Target );		
		}
		else
		{	/*
			 * On est sur le Premier champ:
			 * On le signale:
			 */
			aff_msg_l0( pVoie_curr, "Premier champ de saisie!" );
		}
	}

	/*
	 * Repasse en mode d'attente d'action:
	 */
	register_action( pVoie_curr, WAIT, 0, 0, NULL );
}



/*
 * Move_FocusToInField(-)
 *
 * Purpose:
 * --------
 * Se d‚place vers le champ de saisie donn‚ en paramŠtre
 * en affichant la page vid‚otex associ‚e au passage
 *
 * History:
 * --------
 * 13.12.94: fplanque: Created
 * 05.01.95: profite des params ACTION
 */
void	Move_FocusToInField(
				VOIE 		*	pVoie_curr,	/* In: Voie concern‚e */
				IOFIELD	*	pIOField_In )	/* In: Champ de saisie d‚sir‚ */
{
	if( pIOField_In != NULL )
	{	/*
		 * Si champ valide, on demande l'entr‚e ds ce champ:
		 */
		register_action( pVoie_curr, DISP, pIOField_In -> FPar.Input -> fnct_no, 0, NULL );		
		register_action( pVoie_curr, EFLD, 0, 0, pIOField_In );		
	}

	/*
	 * Repasse en mode d'attente d'action:
	 */
	register_action( pVoie_curr, WAIT, 0, 0, NULL );
}



/*
 * Move_FocusToInField_byFnct(-)
 *
 * Purpose:
 * --------
 * Se d‚place vers le champ de saisie dont la fonction est donn‚e en param
 * en affichant la page vid‚otex associ‚e au passage
 *
 * History:
 * --------
 * 13.12.94: fplanque: Created
 * 13.02.95: prend fnct diff‚rente pour ‚cran
 */
void	Move_FocusToInField_byFnct(
				VOIE 		*	pVoie_curr,		/* In: Voie concern‚e */
				int			n_FnctInput,	/* In: Fonction du champ de saisie d‚sir‚ */
				int			n_FnctEcran )	/* In: Fonction ‚cran d‚sir‚e avant edition du champ */
{
	/*
	 * On demande l'entr‚e ds ce champ:
	 */
	register_action( pVoie_curr, DISP, n_FnctEcran, 0, NULL );		
	register_action( pVoie_curr, EFLD, n_FnctInput, 0, NULL );		

	/*
	 * Repasse en mode d'attente d'action:
	 */
	register_action( pVoie_curr, WAIT, 0, 0, NULL );
}


/*
 * aim_CurrField(-)
 *
 * Purpose:
 * --------
 * Obtient ptr sur le texte du champ de saisie courant
 * sur la voie demand‚e
 *
 * SUGGEST:
 * ------
 * What about multiline fields!?
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 * 22.08.94: renvoie chaine vide si pas de ligne de commande
 * 05.12.94: returns CONST char *
 */
const char *	aim_CurrField(				/* Out: Ptr sur texte du Champ courant */
						VOIE *pVoie_curr )	/* In:  Ptr sur voie courante */
{
	/*
	 *	Utilise la ligne d'‚dition courante:
	 */
	TEXTLINE	*	pTextLine = pVoie_curr -> curr_textline;
	
	if( pTextLine -> text != NULL )
	{
		return	pTextLine -> text;
	}
	
	return	G_empty_string;
}



/*
 * aim_InField(-)
 *
 * Purpose:
 * --------
 * Obtient ptr sur le texte d'un champ de saisie sur la voie demand‚e
 *
 * SUGGEST:
 * ------
 * What about multiline fields!?
 *
 * History:
 * --------
 * 05.12.94: fplanque: Derived from aim_CurrField()
 */
const char * aim_InField(					/* Out: Ptr sur texte du Champ demand‚ */
					VOIE *	pVoie_curr,		/* In:  Ptr sur voie courante */
					int		n_Fnct )			/* In:  Fonction du champ qui nous int‚resse */
{
	IOFIELD	*	pIOField_In;
	char		*	psz_Text;

	if( get_InFieldPars( pVoie_curr, n_Fnct, &pIOField_In ) != FLD_READY )
	{	
		return	NULL;
	}

	/*
	 * Le champ existe et est activ‚:
	 */
	psz_Text = pIOField_In -> pTextInfo -> firstline -> next -> text;
	
	if( psz_Text != NULL )
	{
		return	psz_Text;
	}
	
	return	G_empty_string;
}




/*
 * validate_InFields(-)
 *
 * Purpose:
 * --------
 * V‚rifie que le cotnenu des champs de saisie est correct
 * 
 * History:
 * --------
 * 09.12.94: fplanque: Created
 */
BOOL	validate_InFields( 		/* Out: TRUE si les champ sont correctement remplis */
			VOIE * pVoie_curr )	/* In:  Voie concern‚e */
{
	IOFIELD			*	pIOField_CurrIn = pVoie_curr -> pIOField_ListIn;

	while( pIOField_CurrIn != NULL )
	{
		if( pIOField_CurrIn -> FPar.Input -> InFieldFlags.b_Mandatory )
		{	/*
			 * Si saisie obligatoire:
			 * on contr“le que quelque chose a ‚t‚ saisi ds ce champ:
			 */
			if( ! text_IsFilled( pIOField_CurrIn -> pTextInfo ) )
			{	/*
				 * Le champ est vide ou ne contient que des cars <=32
				 */
				aff_msg_l0( pVoie_curr, "Saisie icomplŠte!" );
				Move_FocusToInField( pVoie_curr, pIOField_CurrIn );
				return	FALSE0;				
			}
		}	
	
		/*
		 * Passe au champ de saisie suivant:
		 */
		pIOField_CurrIn = pIOField_CurrIn -> p_next;
	}
	
	return	TRUE_1;
}


/*
 * IOFieldList_Destruct(-)
 *
 * Purpose:
 * --------
 * Detruit une liste de IOFields
 * ainsi que les textes formatt‚s qu'elle r‚f‚rence
 *
 * History:
 * --------
 * 18.12.94: fplanque: Created
 */
void	IOFieldList_Destruct(
			IOFIELD	*	pIOField )	/* In: 1er elt de la Liste … effacer */
{
	IOFIELD	* pIOField_next;

	while( pIOField != NULL )
	{	/*
		 * Tant qu'il y a des champs de saisie … effacer:
		 */
		pIOField_next = pIOField -> p_next;
		
		/*
		 * LibŠre zone d'‚dition propre … la voie:
		 */
		free_formatext( pIOField -> pTextInfo );
		
		pIOField	= pIOField_next;
	}
}


/*
 * OutField_Display(-)
 *
 * Purpose:
 * --------
 * Affiche un champ d'informations
 *
 * History:
 * --------
 * 18.12.94: fplanque: Created
 * 13.01.95: gŠre l'inverse vid‚o
 * 25.01.95: gŠre offsets
 */
void	OutField_Display(
			VOIE 		*	pVoie_curr,		/* In: Voie concern‚e */
			IOFIELD	*	pIOField,		/* In: Champ … afficher */
			int			n_XOffset,		/* In: Offsets … appliquer aux coordonn‚es des champs */			
			int			n_YOffset )
{
	int				device = pVoie_curr -> device;		/* Port utilis‚ */
	OUTPUT_FPAR	*	pOutput_FPar	= pIOField -> FPar.Output;
	TEXTLINE 	*	curr_textline	= pIOField -> pTextLine_Top;	/* 1Šre ligne … afficher */
	/*
	 * Init Variables: 
	 */
	int	x			= pOutput_FPar -> x + n_XOffset;				/* Position x */
	int	y;
	int	col_text = pOutput_FPar -> col_text;	/* Couleur texte */
	OUTFIELD_FLAGS OutFieldFlags = pOutput_FPar -> OutFieldFlags;

	/*
	 * Affiche le texte: 
	 */
	for ( y = pOutput_FPar -> y + n_YOffset; 
			curr_textline != NULL
			&&	y < pOutput_FPar -> y + n_YOffset + pOutput_FPar -> h;
			y++ )
	{	/*
	 	 * Positionne le curseur: 
	 	 */
		pos( device, x, y );
		/*
		 * Couleur texte: 
		 */
		set_tcolor( device, col_text );	
		/*
		 * Inverse vid‚o:
		 */
		if( OutFieldFlags .b_ReverseText )
		{
			term_setReverse( device );	
		}
		/*
		 * Affiche ligne: 
		 */
		if ( curr_textline -> text != NULL )
		{	/*
			 * S'il y a du texte sur cette ligne: 
			 */
			str_conout ( device, curr_textline -> text );
		}
		
		/*
		 * Passe … la ligne suivante: 
		 */
		curr_textline = curr_textline -> next;
	}
}




/*
 * IOField_MoveTopLine(-)
 *
 * Purpose:
 * --------
 * D‚place la TOpLine d'un champ de saisie/sortie
 * du nombre de lignes d‚sir‚:
 *
 * History:
 * --------
 * 19.12.94: fplanque: Created
 * 06.01.95: retourne nbre de lignes dont on s'est effectivement d‚plac‚
 * 06.01.95: empˆche de s'arrˆter sur la ligne 0
 */
long	IOField_MoveTopLine(				/* Out: Nbre de lignes dont on s'est effectivement d‚plac‚ */
			IOFIELD	*	pIOField,		/* In:  Champ ds lequel on se d‚place */
			long			l_LineOffset )	/* In:  Nbre de lignes duquel on veut se d‚placer */
{
	long			i;
	TEXTLINE	*	pTextLine_Top = pIOField -> pTextLine_Top;

	if( l_LineOffset < 0 )
	{
		for( i=0; pTextLine_Top -> prev != NULL && i>l_LineOffset; i-- )
		{
			pTextLine_Top = pTextLine_Top -> prev;
		}
		
		if( pTextLine_Top -> prev == NULL )
		{	/*
			 * On ne veut pas s'arrˆter sur la ligne 0!!
			 */
			pTextLine_Top = pTextLine_Top -> next;
			i++;
		}
	}
	else
	{
		for( i=0; pTextLine_Top -> next != NULL && i<l_LineOffset; i++ )
		{
			pTextLine_Top = pTextLine_Top -> next;
		}
	}

	/*
	 * R‚catualise ptr sur ligne au top:
	 */
	pIOField -> pTextLine_Top = pTextLine_Top;
	pIOField -> l_TopLine 	+= i;

	return	i;
}


/*
 * IOField_DisplayText(-)
 *
 * Purpose:
 * --------
 * Affiche un texte dans un champ de sortie
 * (le texte est formatt‚)
 * Mais ne garde aucune trace aprŠs
 *
 * History:
 * --------
 * 10.01.95: fplanque: Created
 */
void	IOField_DisplayText(
			VOIE 			*	pVoie_curr,		/* In: Voie concern‚e */
			OUTPUT_FPAR	*	pOutputFPar,	/* In: ParamŠtres du champ de sortie concern‚ */
			int				n_XOffset,		/* In: Offsets … appliquer aux coordonn‚es des champs */			
			int				n_YOffset,
			char			*	pText,			/* In: Texte (compact) … afficher */
			size_t			size_Text )		/* In: Longueur de ce texte */
{
	IOFIELD	IOField;

	if( pOutputFPar == NULL || pText == NULL )
	{
		return;
	}

	IOField .p_next = NULL;
	IOField .p_prev = NULL;

	/*
	 * linkage PARAMS d'affichage: 
	 */
	IOField .FPar.Output = pOutputFPar;

 	/*
 	 * D‚compose texte en lignes:
 	 */
	IOField .pTextInfo = create_justified_text( pText, size_Text, pOutputFPar -> w );

	/*
	 * M‚morise ligne au top de la zone d'affichage:
	 */
	IOField .pTextLine_Top	= IOField .pTextInfo -> firstline -> next;
	IOField .l_TopLine		= 1;		/* On est sur la ligne no 1 */

	/*
	 * Affiche le champ:
	 */
	OutField_Display( pVoie_curr, &IOField, n_XOffset, n_YOffset );
 
	/*
	 * Efface le texte formatt‚ de la m‚moire: 
	 */
	IOFieldList_Destruct( &IOField );

}



/*
 * IOField_PrepareText(-)
 *
 * Purpose:
 * --------
 * pr‚pare un texte pour son affichge ds un outfield 
 *
 * History:
 * --------
 * 24.01.95: fplanque: Created
 */
IOFIELD *	IOField_PrepareText(
					OUTPUT_FPAR	*	pOutputFPar,	/* In: ParamŠtres du champ de sortie concern‚ */
					char			*	pText,			/* In: Texte (compact) … afficher */
					size_t			size_Text )		/* In: Longueur de ce texte */
{
	IOFIELD *	pIOField;

	if( pOutputFPar == NULL || pText == NULL )
	{
		return	NULL;
	}

	pIOField = MALLOC( sizeof( IOFIELD ) );

	pIOField -> p_next = NULL;
	pIOField -> p_prev = NULL;

	/*
	 * linkage PARAMS d'affichage: 
	 */
	pIOField -> FPar.Output = pOutputFPar;

 	/*
 	 * D‚compose texte en lignes:
 	 */
	pIOField -> pTextInfo = create_justified_text( pText, size_Text, pOutputFPar -> w );

	/*
	 * M‚morise ligne au top de la zone d'affichage:
	 */
	pIOField -> pTextLine_Top	= pIOField -> pTextInfo -> firstline -> next;
	pIOField -> l_TopLine		= 1;		/* On est sur la ligne no 1 */


	return	pIOField;

}



/*
 * IOField_DisplayString(-)
 *
 * Purpose:
 * --------
 * Affiche une chaine dans un champ de sortie
 * (pas de formattage, 1 ligne maximum)
 * Mais ne garde aucune trace aprŠs
 *
 * History:
 * --------
 * 13.01.95: fplanque: Created
 * 25.01.95: gŠre offsets
 */
void	IOField_DisplayString(
			VOIE 			*	pVoie_curr,		/* In: Voie concern‚e */
			OUTPUT_FPAR	*	pOutputFPar,	/* In: ParamŠtres du champ de sortie concern‚ */
			int				n_XOffset,		/* In: Offsets … appliquer aux coordonn‚es des champs */			
			int				n_YOffset,
			const char	*	cpsz_String )	/* In: Chaine … afficher */
{
	int	device = pVoie_curr -> device;		/* Port utilis‚ */

	if( pOutputFPar == NULL || cpsz_String == NULL )
	{
		return;
	}

	/* 
	 * Positionne le curseur: 
	 */
	pos( device, pOutputFPar -> x + n_XOffset, pOutputFPar -> y + n_YOffset );
	/*
	 * Couleur texte: 
	 */
	set_tcolor( device, pOutputFPar -> col_text );	
	/*
	 * Inverse vid‚o:
	 */
	if( pOutputFPar -> OutFieldFlags .b_ReverseText )
	{
		term_setReverse( device );	
	}
	/*
	 * Affiche ChaŒne: 
	 */
	str_nconout( device, cpsz_String, pOutputFPar -> w );

}




/*
 * OutField_Clear(-)
 *
 * Purpose:
 * --------
 * Efface un champ d'informations de l'‚cran
 * avec ses attributs par d‚faut
 *
 * Notes:
 * ------
 *
 * History:
 * --------
 * 13.01.95: fplanque: Created based on OutField_Display()
 * 25.01.95: gŠre offsets
 */
void	OutField_Clear(
			VOIE 			*	pVoie_curr,			/* In: Voie concern‚e */
			OUTPUT_FPAR	*	pOutput_FPar,	/* In: Param Champ … effacer */
			int				n_XOffset,			/* In: Offsets … appliquer aux coordonn‚es des champs */			
			int				n_YOffset )
{
	OUTFIELD_FLAGS OutField_Flags = pOutput_FPar -> OutFieldFlags;

	if( pOutput_FPar != NULL && OutField_Flags.b_enabled  &&  OutField_Flags.b_Clear )
	{
		int				device = pVoie_curr -> device;		/* Port utilis‚ */
		/*
		 * Init Variables: 
		 */
		int	x			= pOutput_FPar -> x + n_XOffset;		/* Position x */
		int	w			= pOutput_FPar -> w;					/* largeur */
		int	y;
		int	col_text = pOutput_FPar -> col_text;	/* Couleur texte */
		OUTFIELD_FLAGS OutFieldFlags = pOutput_FPar -> OutFieldFlags;
	
		/*
		 * Affiche le texte: 
		 */
		for ( y = pOutput_FPar -> y + n_YOffset; 
				y < pOutput_FPar -> y + n_YOffset + pOutput_FPar -> h;
				y++ )
		{	/*
		 	 * Positionne le curseur: 
		 	 */
			pos( device, x, y );
			/*
			 * Couleur texte: 
			 * on doit la fixer pour:
			 * -inverse vid‚o
			 * -s'il y a un soulignement pour que sa couleur soit celle du texte, la ou il n'y a pas de texte!
			 */
			set_tcolor( device, col_text );	
			/*
			 * Inverse vid‚o:
			 */
			if( OutFieldFlags .b_ReverseText )
			{	/*
				 * Inverse vid‚o:
				 */
				term_setReverse( device );	
			}
	
			/*
			 * Efface ligne: 
			 */
			mconout( device, ' ', w );
		}
	}
}


/*
 * InField_Clear(-)
 *
 * Efface le contenu d'un champ de saisie
 * et r‚percute … l'‚cran
 *
 * 14.05.95: fplanque: Created
 */
void InField_Clear(
			VOIE	 	*	pVoie_curr,			/* In:	Voie concern‚e */
			IOFIELD	*	pIOField_CurrIn )	/* In:	Ptr sur champ … effacer */
{
	TEXTINFO	*	pTextInfo = pIOField_CurrIn -> pTextInfo;
	TEXTLINE	*	pTextLine_Top = pTextInfo -> firstline -> next;

	/*
	 * Ligne au top de la zone d'affichage = 1Šre ligne du champ:
	 */
	pIOField_CurrIn -> pTextLine_Top  = pTextLine_Top;
	pIOField_CurrIn -> l_TopLine		 = 1;		/* On est sur la ligne no 1 */

	/*
	 * Vide le contenu de la 1Šre ligne:
	 */
	pTextLine_Top -> length = 0;				/* Fixe longueur de la ligne */
	if( pTextLine_Top -> text != NULL )
	{
		pTextLine_Top -> text[ 0 ] = '\0';		/* Fin de la ligne! */
	}
	
	/*
	 * Efface les lignes suivantes de la m‚moire:
	 */
	while( pTextInfo -> lastline != pTextLine_Top )
	{
		delete_line( pTextInfo -> lastline, pTextInfo );
	}
	
	/*
	 * -------------------------------------------------
	 * R‚affichage:
	 */
	display_field( pVoie_curr -> device, pIOField_CurrIn, 0, 1000 );

	/*
	 * Ligne en cours d'‚dition
	 * (ligne actuellement affich‚e au top de la zone d'‚dition)
	 */
	pVoie_curr -> curr_textline = pIOField_CurrIn -> pTextLine_Top;
	pVoie_curr -> l_CurrLine	 = pIOField_CurrIn -> l_TopLine;
	
	pVoie_curr -> csr_x = pIOField_CurrIn -> FPar.Input -> x +	pVoie_curr -> curr_textline -> length;
	pVoie_curr -> csr_y = pIOField_CurrIn -> FPar.Input -> y;

	/*
	 * Place curseur: 
	 */
	place_csr( pVoie_curr );
}


/*
 * Find_OutField(-)
 *
 * Purpose:
 * --------
 * Cherche un champ d'affichage dans la page courante 
 * en fonction de son no de fonction
 * et renvoie ses paramŠtres
 *
 * History:
 * --------
 * 24.01.95: fplanque: Created
 */
OUTPUT_FPAR	*	Find_OutField( 			/* Out: Champ de sortie trouv‚ */
						VOIE	*	pVoie_curr,	/* In:  Voie concern‚e */
						int		n_fnct )		/* In:  No de fonction demand‚e */
{
	PAGEARBO 		*	pPageArbo = pVoie_curr -> arboparams;
	ARBO_FIELDPARS	* 	pFieldPars_output = pPageArbo -> output_fields;
	OUTPUT_FPAR		*	pOutput_FPar;

	while( pFieldPars_output != NULL )
	{	/*
		 * En fonction du type de champ:
		 */
		pOutput_FPar = &(pFieldPars_output -> data.output);
		 
		if( pFieldPars_output -> data.fnct_no == n_fnct )
		{
			return	pOutput_FPar;
		}
	
		/*
		 * Passe au champ suivant:
		 */
		pFieldPars_output = pFieldPars_output -> next;
	}
	
	return	NULL;
}



/*
 * textes.c
 *
 * Purpose:
 * --------
 * Manipulation de textes
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"TEXT.C v1.10 - 07.95"

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include	<stdlib.h>					/* header librairie de fnct std */
	#include <string.h>					/* header tt de chaines */
	#include	<aes.h>						/* header AES */
	#include	<vdi.h>						/* VDI */
   

/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "S_MALLOC.H"
	#include	"STUT_ONE.RSC\STUT_3.H"						/* Cnstes fichier RSC */
	#include "AESDEF.H"
	#include "EXFRM_PU.H"
	#include "STKEYMAP.H"	
	#include	"MAIN_PU.H"
	#include "MMENU_PU.H"	
	#include	"TEXT_PU.H"
	#include	"DEBUG_PU.H"	
	#include	"OBJCT_PU.H"	
	#include "FILES_PU.H"
	#include "WIN_PU.H"
	#include "WINDR_PU.H"
	#include "OBJCT_PU.H"
	#include "RTERR_PU.H"
	#include "DATPG_PU.H"
	#include	"VDI_PU.H"	

/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * PRIVate INTernal prototypes:
 */
	/* -- edition -- */
	static	void	winEdit_MoveCsr(
							WIPARAMS *	pWiParams,	
							int			n_YMove,
							int			n_XMove );
	static	void	winEdit_TypeCar(
							WIPARAMS *	pWiParams,	
							char			c_car );
	static	void	winEdit_DelCar(
							WIPARAMS *	pWiParams,
							int			b_backspace );	/* In: True si backspace */
	static	void	winEdit_BreakLine(
							WIPARAMS *	pWiParams );


/*
 * ------------------------ VARIABLES -------------------------
 */


/*
 * Public variables: 
 */
	int	G_def_text_width	=	DEF_TEXT_WIDTH;	/* Largeur par d‚faut d'une ligne texte en caractŠres */


	
/*
 * Private variables: 
 */
	/*
	 * Ptr sur boite de r‚glage Params Texte
	 */
	OBJECT	*	M_pObj_FormParamsAffText;	
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * init_text(-)
 *
 * Init de ce module
 *
 * 01.12.94: fplanque: Created
 */
void	init_text( void )
{
	TRACE0( "Initializing " THIS_FILE );

	if (rsrc_gaddr( R_TREE, AFFICTXT, &M_pObj_FormParamsAffText) == 0)
		erreur_rsrc();
	rsrc_color( M_pObj_FormParamsAffText );		/* Fixe couleurs */

}


/*
 * text_optimal(-)
 *
 * Purpose:
 * --------
 * D‚termine fenˆtre optimale (full) pour un texte
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void text_optimal( 
		int wi_ckind, 
		int *border_x, 
		int *border_y, 
		int *border_w, 
		int *border_h)
{
	int	work_x, work_y, work_w, work_h;	/* Coordonn‚es zone de travail */

		work_x = G_std_text .cell_w -4;			/* Texte sera align‚ sur col 2 */
		work_y = 50;								/* Arbitraire */
		work_w = G_def_text_width * G_std_text .cell_w + 8;	/* Largeur max */
					/* On rajoute +8 car il y a 4 pix … gauche et … droite */
		work_h = 100;								/* Arbitraire */

	/* Calcule les coordonn‚es totales de la fenˆtre: */
		wind_calc( WC_BORDER, wi_ckind, work_x, work_y, work_w, work_h,
						border_x, border_y, border_w, border_h );

	/* Contr“le que ‡a rentre... en largeur */
		if ( (*border_x + *border_w) > G_w_maxi )
			*border_w = G_w_maxi - *border_x;

	/* Hauteur max: */
		*border_y = G_y_mini;
		*border_h = G_h_maxi - G_std_text .cell_h;		
}
                     
                     
                       
/*
 * create_textedit_zone(-)
 *
 * Purpose:
 * --------
 * Cr‚ation d'une zone d'‚dition vide
 * limit‚e … une ligne (mais ‡a peut grandir dynamiquement...)
 *
 * Suggest:
 * --------
 * PROVISOIRE: Contient une boŒte d'alerte pouvant bloquer le serveur
 *
 * History:
 * --------
 * 1993: fplanque: Created 
 * 29.04.94: fplanque: changé header texte
 * 25.05.94: utilise nouveau create_TextInfo()
 * 22.08.94: Consid‚rablement simplifi‚, ne cr‚e plus qu'une zone restreinte … UNE seule ligne VIDE!
 */
TEXTINFO	* create_textedit_zone( void )	/* Out: Infos sur zone d'‚dition cr‚e */
{
	TEXTINFO * pTextInfo;

	if( (pTextInfo = create_TextInfo()) == NULL )
	{
		return	NULL;		 	/* ProblŠme */
	}
	
	/*
	 * Ajoute la ligne vide au buffer texte: 
	 * Ce sera la premiŠre ligne du texte, elle portera le curseur
	 */
	insert_line( pTextInfo -> firstline, NULL, NIL_1, pTextInfo );

	return	pTextInfo;

}



/*
 * access_text(-)
 *
 * Purpose:
 * --------
 * Acc‚der … un texte en m‚moire (ds groupe TEXTES)
 * pour l'afficher
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: fplanque: utilise le nouveau create_TextInfo()
 * 06.08.94: extraction du code de controle du nbre de fenˆtre ouverte sur DATAPAGE (limite: 1)
 */
int	access_text( 
			DATAPAGE 	 *		datapage, 
			WORK_CONTENT *		content_ptr, 
			TEXT_DRAWPAR * *	ppTextDrawPar_retour )		/* Out: */
{
	DATABLOCK *	pDataBlock = datapage -> data.dataBlock;
	/*
	 * Adresse des infos sur le nouveau texte 
	 * Cr‚e le header du texte en mem: 
	 */
	TEXTINFO		 *	pTextInfo = create_TextInfo();
	TEXT_DRAWPAR * pTextDrawPar = create_TextDrawPar( pTextInfo, 10 /* bidon */ );
	
	/*
	 * Fixe adr de la page courante! (qui contient celle du texte:) 
	 */
	content_ptr -> datapage = datapage;

	if( pTextInfo == NULL )
	{
		return	0;		/* Ouverture Impossible */
	}

	if( pTextDrawPar == NULL )
	{
		free_formatext( pTextInfo );
	}

	/*
	 * Formatte le texte (BLOC->lignes) pour son affichage: 
	 */
	format_text( pTextInfo, pTextInfo -> lastline,
					 pDataBlock -> p_block, pDataBlock -> ul_length, 
					 FMTMODE_NEARBINARY, G_def_text_width ); 

	/*
	 * Sauve adr des infos sur le texte: 
	 */
	pTextDrawPar -> pTextInfo = pTextInfo;
	*ppTextDrawPar_retour = pTextDrawPar;

	return	1;
}



/*
 * text_addLineToEnd(-)
 *
 * Purpose:
 * --------
 * Ajoute une ligne … la fin d'un texte
 *
 * History:
 * --------
 * 25.09.94: fplanque: Created
 */
void	text_addLineToEnd(
			TEXTINFO		*	pTextInfo,	/* In: Texte concern‚ */
			const char	*	cpsz_Text )	/* In: Ligne … dupliker et ins‚rer */
{
	/*
	 * Adr derniŠre ligne: 
	 */
	TEXTLINE	*last_line = pTextInfo -> lastline;

	/*
	 * Ajoute une ligne: 
	 */
	char	*	texte = NULL;
	
	if( cpsz_Text != NULL )
	{
		texte	= STRDUP( cpsz_Text );
	}

	insert_line( last_line, texte, NIL, pTextInfo );
	
}


/*
 * insert_line(-)
 *
 * Purpose:
 * --------
 * Insertion d'une ligne dans un texte quelquonque
 *
 * History:
 * --------
 *     1993: fplanque: Created
 * 28.08.94: fplanque: force bufsize … 0 si l'argument p_TextBuf==NULL
 */
TEXTLINE	* insert_line( 
				TEXTLINE	*	prev_line,		/* In: after this one */  
				char 		*	p_TextBuf,		/* In: texte de la ligne … ins‚rer */ 			
				int 			bufsize,			/* In: Taille buffer point‚ par texte: mettre NIL si on veut la taille exacte */ 
				TEXTINFO *	info_ptr )
{
	TEXTLINE	*	ligne;									/* Ligne de texte complŠte */
	TEXTLINE	*	next_line = prev_line -> next;	/* Ligne suivante */

	/*
	 * Cr‚ation d'une ligne en m‚moire: 
	 */	
	ligne = (TEXTLINE *)	MALLOC( sizeof( TEXTLINE ) );
	ligne -> prev = prev_line;			/* Pointeur sur ligne pr‚c‚dente */
	ligne -> next = next_line;			/* Pointeur sur ligne suivante */

	ligne -> text = p_TextBuf;				/* Pointeur sur le texte */

	if( p_TextBuf != NULL )		/* Si texte il y a... */
	{
		ligne	-> length = (int) strlen( p_TextBuf );
		/*
		 * Taille du buffer?: 
		 */
		if ( bufsize == NIL )
		{	/*
			 * Le buffer fait exactement la taille de la ligne (\0 non compris ) 
			 */
			ligne -> info1.bufsize = ligne -> length;	/* Taille du buffer d'‚dition */
		}
		else
		{	/*
			 * Le buffer est plus grand: 
			 */
			ligne -> info1.bufsize = bufsize;
		}
	}
	else							/* Sinon: ligne vide: */
	{
		ligne	-> length = 0;		/* Longueur nulle */
		ligne -> info1.bufsize = 0;
		if( bufsize > 0 )
		{
			signale( "\n Erreur ds param bufsize lors de l'appel … insert_line" );
		}
	}

		
	/*
	 * Cette ligne ne continue pas sur la suivante:
	 * (Cette ligne est suivie d'un CR LF)
	 */
	ligne -> info1.continued = FALSE;


	/*
	 * Lien avec la ligne pr‚c‚dente: 
	 */
	prev_line -> next = ligne;
					
	/*
	 * Lien avec la ligne suivante: 
	 */
	if ( next_line !=NULL )		/* S'il y en a une... */
	{
		next_line -> prev = ligne;
	}
	else								/* Si on vient d'ajouter la derniŠre ligne */
	{
		info_ptr -> lastline = ligne;		/* On sauve son adresse */
	}
	
	/*
	 * Une ligne de plus: 
	 */
	(info_ptr -> nb_lignes) ++;
			
	return	ligne;			/* Renvoi le ptr sur la nlle ligne */
}



/*
 * delete_line(-)
 *
 * Purpose:
 * --------
 * Suppression d'une ligne dans un texte quelconque
 * (peut aussi supprimer des lignes stand-alone)
 *
 * History:
 * --------
 * 04.07.94: fplanque: Created
 * 13.07.95: fplanque: gestion des stand-alone
 */
void	delete_line( 
			TEXTLINE *	pTextLine, 	/* In: Ligne … supprimer */
			TEXTINFO	*	pTextInfo )	/* In: Texte ds lequel on efface */
{
	TEXTLINE	* pTextLine_prev = pTextLine -> prev;	/* Ligne pr‚c‚dante */
	TEXTLINE	* pTextLine_next = pTextLine -> next;	/* Ligne suivante */

	/*
	 * Lien ligne pr‚c‚dente -> suivante:
	 */
	if( pTextLine_prev != NULL )		/* S'il y en a une... */
	{
		pTextLine_prev -> next = pTextLine_next;
	}
	else if( pTextInfo != NULL )
	{	/*
		 * Si la ligne n'est pas stand-alone:
		 */
		pTextInfo -> firstline = pTextLine_next;
	}
	
	/*
	 * Lien ligne suivante -> pr‚c‚dente: 
	 */
	if ( pTextLine_next != NULL )		/* S'il y en a une... */
	{
		pTextLine_next -> prev = pTextLine_prev;
	}
	else if( pTextInfo != NULL )
	{	/*
		 * Si la ligne n'est pas stand-alone:
		 */
		pTextInfo -> lastline = pTextLine_prev;
	}
	
	/*
	 * Une ligne de moins: 
	 */
	if( pTextInfo != NULL )
	{	/*
		 * Si la ligne n'est pas stand-alone:
		 */
		(pTextInfo -> nb_lignes) --;
	}
			

	/*
	 * D‚truit r‚ellement la ligne:
	 */
	free_String( pTextLine -> text );
	FREE( pTextLine );
}


/*
 * free_formatext(-)
 *
 * Purpose:
 * --------
 * Efface un texte formatt‚ de la m‚moire
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	free_formatext( 
			TEXTINFO *textinfo )
{	
	/*
	 * On commence par effacer la derniŠre ligne: 
	 * (pour mieux lib‚rer la m‚moire...)
	 */
	TEXTLINE	*current	= textinfo -> lastline;
	TEXTLINE	*prev;

	/*
	 * Efface le texte: 
	 */	
	while ( current !=NULL )	/* Efface ligne par ligne... */
	{
		prev = current -> prev;		/* Pointe sur ligne pr‚c‚dente */
		if( current -> text != NULL )
		{
			FREE( current -> text );	/* Efface le texte associ‚ */
		}
		FREE( current );				/* Efface ligne courante */
		current = prev;				/* Nlle ligne courante */
	}
	
	/*
	 * Efface les infos sur le texte: 
	 */
	FREE( textinfo );
}



/*
 * params_texte(-)
 *
 * Purpose:
 * --------
 * Dialogue user
 * Change paramŠtres du texte d'une fenˆtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: fplanque: adaptation au nouveau sch‚ma de TEXT_DRAWPAR
 * 07.01.95: fplanque: gŠre nb lignes max dans les logs
 */
void	params_texte( 
			const GRECT *start_box )
{
	int		exit_obj;					/* Objet de sortie */
	GRECT		form_box;					/* Dimensions du formulaire */
	/* Adr champs de saisie */
	char	*	textsize = (M_pObj_FormParamsAffText[TEXTSIZE] .ob_spec.tedinfo) -> te_ptext;
	char	*	piBsz_nbMaxLines = (M_pObj_FormParamsAffText[AFFLGMAX] .ob_spec.tedinfo) -> te_ptext;
	int		edit_obj = TEXTSIZE;

	TEXT_DRAWPAR *	pTextDrawPar = G_wi_list_adr -> draw_ptr.pTextDrawPar;

	/*
	 * Fixe valeurs courantes ds formulaire: 
	 */
	itoa( pTextDrawPar -> n_points, textsize, 10 );					/* Conversion d‚cimale */
	ltoa( pTextDrawPar -> l_nbLinesMax, piBsz_nbMaxLines, 10 );	/* Conversion d‚cimale */

	/*
	 * Affiche/gŠre/efface formulaire: 
	 */
	/* App prend en charge souris */
	WIND_UPDATE_BEG_MCTRL
	open_dialog( M_pObj_FormParamsAffText, start_box, &form_box );

	exit_obj=ext_form_do( M_pObj_FormParamsAffText, &edit_obj );	/* Gestion de la boŒte */

	close_dialog( M_pObj_FormParamsAffText, exit_obj, start_box, &form_box );
	/* AES peut reprendre la souris */
	WIND_UPDATE_END_MCTRL

	/*
	 * Si confirmation: 
	 */
	if ( exit_obj == AFTXTCNF )
	{
		int		old_cell_h = pTextDrawPar -> n_cell_h;

		/*
		 * Cherche nlle taille demand‚e: 
		 */
		int		new_height = atoi( textsize );	/* Conversion */
		int		char_w, char_h, cell_w, cell_h;

		/*
		 * Fixe nlle taille: 
		 */
		vst_point( G_ws_handle, new_height, &char_w, &char_h, &cell_w, &cell_h );
		/*	printf("New text format: chw=%d chh=%d clw=%d clh=%d\r", char_w, char_h, cell_w, cell_h); */

		/*
		 * Fixe nouveaux paramŠtres fenˆtre: 
		 */
		pTextDrawPar -> n_points = new_height;		/* Haut en "points" */
		pTextDrawPar -> n_char_h = char_h;
		pTextDrawPar -> n_cell_w = cell_w;
		pTextDrawPar -> n_cell_h = cell_h;

		pTextDrawPar -> l_nbLinesMax = atol( piBsz_nbMaxLines );	/* Conversion */
	
		/*
		 * Calcule nouvelle largeur & hauteur totale: 
		 */
		calc_textSizeW( G_wi_list_adr );
		calc_textSizeH( G_wi_list_adr );

		/*
		 * Calcule la nlle position: 
		 */			
		/*	printf("Ancienne position: %lu, %d\n", G_wi_list_adr -> seen_y, old_cell_h); */

		G_wi_list_adr -> seen_y /= old_cell_h;	/* no de la ligne */
		/*	printf("No de la ligne: %lu\n", G_wi_list_adr -> seen_y);	*/

		G_wi_list_adr -> seen_y *= cell_h;			/* nlle psition en pixels */
		/*	printf("Nlle position: %lu, %d\n", G_wi_list_adr -> seen_y, cell_h); */
		

		/*
		 * Demande redraw: 
		 */
		wi_resize( G_wi_list_adr );				/* New ascenseurs et repositionnement contenu si n‚cessaire */
		send_fullredraw( G_wi_list_adr );		/* New contenu */
	}
}



/*
 * -------- RESPRESENTATION D'UNE LIGNE DE TEXTE EN MEMOIRE ---------
 */


/*
 * TextLine_CreateStandAlone(-)
 *
 * Cr‚ation d'une TEXTLINE seule 
 * (pas rattach‚e … un texte quelconque)
 * Sert par exemple pour un BUFFER de reception ds GetKeyboard en mode BUFFERING
 *
 * 13.07.95: fplanque: Created
 */
TEXTLINE * TextLine_CreateStandAlone(	/* Out: TEXTLINE cr‚‚e */
					int 	bufsize )			/* In:  Taille buffer  */ 
{
	TEXTLINE	*	pTextLine;

	/*
	 * Cr‚ation d'une ligne en m‚moire: 
	 */	
	pTextLine = (TEXTLINE *)	MALLOC( sizeof( TEXTLINE ) );
	pTextLine -> prev = NULL;		/* Pointeur sur pTextLine pr‚c‚dente */
	pTextLine -> next = NULL;		/* Pointeur sur pTextLine suivante */

	pTextLine -> text = (char*)MALLOC( bufsize );		/* Pointeur sur le texte */
	pTextLine -> length = 0;
	pTextLine -> info1.bufsize = bufsize;	/* Taille du buffer d'‚dition */
		
	/*
	 * Cette ligne ne continue pas sur la suivante:
	 */
	pTextLine -> info1.continued = FALSE;

	return	pTextLine;			/* Renvoi le ptr sur la nlle ligne */
}


/*
 * TextLine_Clear(-)
 *
 * Vide le buffer d'une ligne de texte
 *
 * 08.10.95: fplanque: Created
 */
void TextLine_Clear(
			TEXTLINE	*	pTextLine ) /* In: Ligne … vider */
{
	pTextLine -> text[ 0 ] = '\0';
	pTextLine -> length = 0;
}


/*
 * -------------- RESPRESENTATION D'UN TEXTE EN MEMOIRE ------------------
 */


/*
 * create_newText(-)
 *
 * Purpose:
 * --------
 * Cr‚er un nouveau texte dans 
 * le DATAGROUP des textes
 * qui doit ˆtre visible dans la top window
 *
 * Notes:
 * ------
 * Le texte cr‚‚ est on ne peut plus vide: longueur 0
 *
 * History:
 * --------
 * 18.06.94: created based on creer_rubrique()
 * 19.06.94: le texte est maintenant cr‚‚ avec longueur 0 et pas 1
 * 19.06.94: Mise en service DATABLOCK
 * 22.11.94: am‚lioration des tests avant action
 */
void	create_newText( 
			GRECT *start_box )
{
	DATAGROUP * datagroup;
	
	if(	G_wi_list_adr == NULL
		|| G_wi_list_adr -> class != CLASS_DIR )
	{
		ping();
		return;
	}

	datagroup = G_wi_list_adr -> datagroup;

	/* 	
	 * V‚rifie que la fenˆtre sup‚rieure peut recevoir
	 * un nouveau texte:  
	 */
	if( datagroup -> DataType != DTYP_TEXTS )
	{
		ping();
		return;
	}
	else
	{	/* 
		 * Oui, la fenˆtre peut recevoir un texte: 
		 * Demande nouveau nom et cr‚e datapage: 
		 */

		DATAPAGE	* pDataPage = create_newDataPage( 
											"NOUVEAU TEXTE",
											datagroup,
											start_box );

		if( pDataPage != NULL )
		{	/*
			 * Si cr‚ation OK:
			 * Assigne un texte vide … la datapage:
			 */
			DATABLOCK * pDataBlock = create_stdDataBlock();

			pDataPage -> data.dataBlock = pDataBlock;
		}
	}
}



/*
 * charge_texte(-)
 *
 * Purpose:
 * --------
 * Charge un texte en m‚moire
 * Le texte est charg‚ sous forme formatt‚e et non compacte
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: fplanque: utilise nouveau create_TextInfo()
 */
int	charge_texte( 
			TEXT_DRAWPAR  * * ppTextDrawPar )
{
	int			ouverture_ok=0;	/* Va t'on r‚ussir … charger le texte ? */
	FTA			fta;					/* File transfer area */

	TEXTINFO 	 *	p_TextInfo = create_TextInfo( );
	
	*ppTextDrawPar = create_TextDrawPar( p_TextInfo, 10 /* bidon */ );

	if ( *ppTextDrawPar != NULL )
	{
		/*
		 * Chargement du texte: 
		 */
		fta .textinfo = p_TextInfo;
		ouverture_ok = load_file( "Voir un texte (ASCII)",
										F_TEXTE_ASCII, &fta ); /* Charge un texte */
	}

	if( ouverture_ok == 0)
	{
		free_formatext( p_TextInfo );
		if ( *ppTextDrawPar != NULL )
			FREE( *ppTextDrawPar );
	}
	
	return	ouverture_ok;
}



/*
 * sauve_texte(-)
 *
 * Purpose:
 * --------
 * Sauve un texte r‚sident en m‚moire
 * sur disque
 * sous forme formatt‚e et non compacte
 *
 * History:
 * --------
 * 31.05.94: fplanque: Created
 */
void	sauve_texte( 
			TEXTINFO *	pTextInfo )	/* In: Ptr sur texte … sauver */
{
	FTA			fta;					/* File transfer area */

	/*
	 * Sauvegarde du texte: 
	 */
	fta .textinfo = pTextInfo;
	save_file( "Sauver un texte (ASCII)", F_TEXTE_ASCII, &fta );
}


/*
 * save_text2datapage(-)
 *
 * Purpose:
 * --------
 * Sauve un texte r‚sident en m‚moire
 * sous forme compact‚e dans une datapage
 *
 * Suggest:
 * --------
 * on pourrait directement transmettre le datablock
 *
 * History:
 * --------
 * 19.06.94: fplanque: Created
 * 28.08.94: fplanque: appelle maintenant save_text2datapage
 */
int	save_text2datapage( 			/* In: FALSE0 si ‚chec sauvegarde */
			TEXTINFO *	pTextInfo,	/* In: Ptr sur texte … sauver */
			DATAPAGE	*	pDataPage )	/* In: Datapage ds laquelle il faut sauver */
{
	DATABLOCK * pDataBlock = pDataPage -> data.dataBlock;

	/*
	 * Compacte le texte:
	 */
	pDataBlock -> ul_length =	compact_text(
											pTextInfo -> firstline -> next,
											FMTMODE_NEARBINARY,
											&( pDataBlock -> p_block ) );

	return	TRUE_1;			
}



/*
 * create_TextInfo(-)
 *
 * Purpose:
 * --------
 * Cr‚ation de l'en-tˆte (ligne 0 - vide) d'un texte formatt‚
 * pour son stockage en m‚moire
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: fplanque: ajout des inits curseur
 */
TEXTINFO * create_TextInfo( void )	/* out: Ptr sur TEXTINFO cr‚e */
{
	TEXTLINE	*	pTextLine;
	TEXTINFO *	pTextInfo;

	/* 
	 * Cr‚e une ligne bidon (vide): 
	 */
	pTextLine = (TEXTLINE *) MALLOC( sizeof( TEXTLINE ) );
	if ( pTextLine == NULL )		/* Si pas assez de m‚moire */
	{
		alert( NOMEM_OPENDOC );		/* Pas assez de mem pour ouvrir doc */
		return	NULL;					/* Ouverture … ‚chou‚ */
	}		

	pTextLine -> prev = NULL;			/* Pas de ligne pr‚c‚dente */
	pTextLine -> next = NULL;			/* Pas de ligne suivante */
	pTextLine -> length = 0;			/* Longueur nulle */
	pTextLine -> text = NULL;			/* Pas de texte */


	/*
	 * Cr‚e une zone d'infos: 
	 */
	pTextInfo = (TEXTINFO *) MALLOC( sizeof( TEXTINFO ) );
	if( pTextInfo == NULL )				/* Si pas assez de m‚moire */
	{
		alert( NOMEM_OPENDOC );			/* Pas assez de mem pour ouvrir doc */
		FREE( pTextLine );				/* Supprime head d‚j… cr‚‚ */
		return	NULL;						/* Ouverture … ‚chou‚ */
	}		
	
	pTextInfo -> firstline	= pTextLine;		/* 1Šre ligne */
	pTextInfo -> lastline	= pTextLine;		/* derniŠre ligne */
	pTextInfo -> nb_lignes 	= 0;					/* Pas de lignes */

	return	pTextInfo;
}



/*
 * create_justified_text(-)
 *
 * Purpose:
 * --------
 * Cr‚e une structure texte en m‚moire et y place un texte
 * que l'on formatte pour l'occasion
 * Le texte a formatter doit ˆtre au format REZO
 *
 * Suggest:
 * --------
 * PROVISOIRE: Contient une boite d'alerte pouvant bloquer le serveur...
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: fplanque: Use new create_TextInfo()
 */
TEXTINFO *	create_justified_text( 
					char		*	p_text,			/* In: ptr sur bloc m‚moire contenant le texte compact‚ */
					size_t 		size_text,		/* In: Longueur du texte compact */
					int			max_line_len )	/* In: Longueur de ligne maximale */
{
	/*
	 * Adresse des infos sur le nouveau texte 
	 */
	TEXTINFO	* pTextInfo = create_TextInfo();

	/*
	 * Cr‚e le header du texte en mem: 
	 */
	if ( pTextInfo != NULL )
	{	/*
		 * Formatte le texte (BLOC->lignes) pour son affichage: 
		 */
		format_text( pTextInfo, pTextInfo -> lastline,
						 p_text, size_text, FMTMODE_REZO, max_line_len ); 
	}

	return	pTextInfo;
}



/*
 * format_text(-)
 *
 * Purpose:
 * --------
 * Formatte un texte compact sous forme de bloc
 * en texte formatt‚ (suite de lignes)
 * et insere ce texte formatt‚ dans un autre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: Ajoute eventuellement une ligne vide … la fin
 * 28.08.94: Gestion du mode d'interpr‚tation des caractŠres
 */
void format_text( 
		TEXTINFO *	textinfo, 			/* In: Zone d'infos pour texte formatt‚ */
		TEXTLINE *	start_line,			/* In: Ligne … laquelle il faut ins‚rer le texte qu'on va formatter */
		char		*	text_adr,			/* Ptr sur texte compact en m‚moire */
		size_t 		text_length,		/* Longueur de ce texte compact */
		int			mode, 				/* In: FMTMODE_NEARBINARY, FNTMODE_REZO */
		int			max_line_len )		/* In: Longueur maximale d'une ligne */
{
	#define	WATCH_FORMATEXT	NO0

	/* 
	 * Variables Source: 
	 */
	char		*text_ptr = text_adr;	/* Pointeur sur caractŠre en cours */
	char		*text_end = text_adr + text_length -1;
	char		*space_ptr;				/* Pointeur sur espace */
	int		last_space;				/* Position du dernier espace */
	char		car;						/* CaractŠre en cours! */
	BOOL		B_carriageReturn;		/* On a d‚tect‚ un CR ou CR/LF */
	char		prec_car;				/* CaractŠre pr‚c‚dent */
			
	/*
	 * Buffer interm‚diaire: 
	 */
	char		*buffer_ptr;			/* Pointeur ds buffer interm‚diaire */
	int		line_length;			/* Longueur de la ligne en cours */

	/*
	 * Variables Destination 
	 */
	char			*new_line;						/* Adr nlle ligne */
	TEXTLINE		*curr_line = start_line;	/* Adr new infos-ligne */

	/*
	 * Mode d'extraction: 
	 */
	BOOL	cr_lf;
	BOOL	filter;

	if( mode == FMTMODE_REZO )
	{	/*
		 * Format REZO:
		 */
		cr_lf = FALSE0;		/* Fin de Ý indiqu‚e par CR */
		filter = TRUE_1;		/* Filtrage des codes <32 */
	}
	else		
	{	/*
	 	 * Format FMTMODE_NEARBINARY:
	 	 */
		cr_lf = TRUE_1;		/* Fin de Ý indiqu‚e par CR/LF */
		filter = FALSE0;		/* Tous les codes sauf 0 sont affich‚s */
	}

	#if	 WATCH_FORMATEXT
		printf("\nTexte avec justification:\n\033p");
	#endif

	if( text_ptr != NULL )
	{
		/*
		 * --------------------
		 * D‚coupage en lignes: 
		 * --------------------
		 */
		while ( text_ptr <= text_end )
		{	/*
			 * D‚coupe une ligne: 
			 */
			buffer_ptr = G_tmp_buffer;
			last_space= 0;				/* Position du dernier espace */
			prec_car = 0;				/* CaractŠre pr‚c‚dent */
			line_length = 0;
	
			while( line_length < max_line_len && text_ptr <= text_end )
			{	/*
				 * Tant que pas long max ligne ou fin de texte atteinte:
				 */
				car = *(text_ptr ++);				/* Prend 1 caractŠre */
				B_carriageReturn = FALSE0;			/* Pour l'instant on est pas sur un cr(lf) */
	
				/*
				 * Contr“le fin de ligne ‚ventuelle: 
				 */
				if ( cr_lf && car == LF && prec_car == CR )
				{	/*
					 * Si on attend des fins de lignes CR LF et qu'on en a une: 
					 */
					B_carriageReturn = TRUE_1;
					if( !filter )
					{	/*
						 * Si on a pas filtr‚ le LF: 
						 */
						buffer_ptr--;
						line_length--;
					}
			 		break;
				}
				else if( !cr_lf && car == CR)
				{	/*
					 * Si un CR indique une fin de ligne/Ý
					 */
					B_carriageReturn = TRUE_1;
					break;
				}
	
				/*
				 * Recopie caractŠre dans buffer: 
				 */
				if( car >= ' ' || (!filter && car > '\0') )
				{	/*
					 * Si on accepte le caractŠre: 
					 */
					*(buffer_ptr++) = car;		/* Sauve caractŠre */
					line_length ++;				/* 1 car de + */
	
					if ( car==' ' )					/* si espace */
					{
						space_ptr = text_ptr;		/* Position a laquelle on peut reprendre si on coupe … cet espace */
						last_space = line_length;	/* m‚morise sa position */
					}
				}
	
				/*
				 * On va passer au car suivant: 
				 */
				prec_car = car;
			}
			
			/*
			 * ------------------------------------
			 * Ajustement pour ne pas couper de mot: 
			 * ------------------------------------
			 */	
			if ( line_length == max_line_len )
			{	/*
			 	 * Si on est sorti parce que fin de
			 	 * ligne sur p‚riph‚rique de sortie: 
			 	 */
				if ( car > ' ' )
				{	/*
					 * Si le dernier code est un caractŠre 
					 */
					if ( last_space > 0 )
					{	/*
						 * s'il y a au moins 1 espace dans la ligne:
						 */
						line_length = last_space;
						buffer_ptr = G_tmp_buffer + last_space;
						text_ptr = space_ptr;		/* On continuera ici */
					}
				}
			}
	
			/*
			 * Termine ligne par \0 : 
			 */
			*buffer_ptr = '\0';
			
			/*
			 * ------------------------------------
			 * On va maintenant extraire la ligne:
			 * ------------------------------------
			 */
			if ( line_length )
			{	/*
				 * Si la ligne n'est pas vide: 
				 */
				new_line = STRDUP( G_tmp_buffer );		/* Cr‚e ligne d‚finitive */
				#if	 WATCH_FORMATEXT
					printf(">%s\n",new_line);
				#endif
			}
			else
			{	/*
			 	 * Ligne vide: 
			 	 */
				new_line = NULL;
				#if	 WATCH_FORMATEXT
					printf("(vide)>\n");
				#endif
			}
	
			/*
			 * Ajoute la ligne au texte: 
			 */
			curr_line = insert_line( curr_line, new_line, NIL, textinfo );	
		}
	}

	/*
	 * Contr“le s'il faut ajouter une ligne vide … la fin:
	 */
	if( B_carriageReturn == TRUE_1 || textinfo -> nb_lignes == 0 )
	{	/*
		 * Si le texte source se termine par un CR/(LF)
		 * ou si le texte dest ne contient aucune ligne -> impossible d'afficher un eventuel curseur
		 * Ajoute une ligne vide: 
		 */
		curr_line = insert_line( curr_line, NULL, NIL, textinfo );	
	}

	#if	 WATCH_FORMATEXT
		printf("\033q");			/* Stop inverse vid‚o */
	#endif

}



/*
 * text_IsFilled(-)
 *
 * Purpose:
 * --------
 * D‚termine si un texte contient des informations utiles
 * ou juste du garbage junk!
 *
 * Algorythm:
 * ----------  
 * Renvoie TRUE dŠs qu'on trouve un car >32
 *
 * History:
 * --------
 * 09.12.94: fplanque: Created
 */
BOOL	text_IsFilled(
			TEXTINFO	* pTextInfo )
{
	/*
	 * Ligne courante
	 * (la1Šre est tjs vide mais bon on la teste qd mˆme...)
	 */
	TEXTLINE	*	pTextLine_Curr = pTextInfo -> firstline;
	char 		*	psz_text;
	int			i;

	while( pTextLine_Curr != NULL )
	{
		psz_text = pTextLine_Curr -> text;
	
		if( psz_text != NULL )
		{
			for( i = 0; i < pTextLine_Curr -> length; i++ )
			{
				if( psz_text[ i ] > ' ' )
				{
					return	TRUE_1;
				}
			}
		}
	
		pTextLine_Curr = pTextLine_Curr -> next;
	}
	
	return	FALSE0;	/* rien trouv‚ */
}


/*
 * compact_text(-)
 *
 * Purpose:
 * --------
 * Transforme un texte r‚sident en m‚moire
 * en une forme compact‚e
 *
 * Algorythm:
 * ----------  
 * - Calcule taille que ‡a va prendre
 * - Cr‚e bloc de sauvegarde
 * - Ecrit le nouveau texte dans le bloc
 * - r‚ajuste taille bloc
 *
 * History:
 * --------
 * 28.08.94: fplanque: Created by extraction from fill_textfield() & 
 * 24.08.94: tient compte pour caractŠre entre 2 ligne dans calcul longueur
 * 24.08.94: GESTION DU FLAG CONTINUED.
 * 01.12.94: retourne un bloc de longueur paire si FMTMODE_REZO
 * 15.12.94: pas de saut de ligne sur derniere ligne en mode FMTMODE_NEARBINARY
 */
size_t	compact_text(					/* Out: Longueur du texte compact */
		TEXTLINE	*	pTextLine_First,	/* In: 1Šre ligne … compacter */
		int			mode,					/* In: FMTMODE_REZO ou FMTMODE_NEARBINARY */
		char		**	ppBuf_compact )	/* In: adr Buffer contenant texte compact */
{
	char 	* 	pBuf;
	char	*	piBuf;
	size_t	s_RealLength;

	/*
	 * -------------------------------------------------
	 * Calcul d'une MAJORATION de la longueur totale qu'occupera le message: 
	 * Pour ensuite r‚server la m‚moire
	 * -------------------------------------------------
	 */
	size_t		s_length	 = 0;
	TEXTLINE *	pTextLine = pTextLine_First;		/* Commence … la premiŠre ligne: */

	while( pTextLine != NULL )
	{	/*
		 * Tant qu'on est pas sur la derniŠre ligne: 
		 *
		 * Ajoute long de la ligne courante 
		 * +2 pour mettre soit un espace, soit un CR soit un CR/LF en fonction de continued
		 */
		s_length += pTextLine -> length +2;
		pTextLine = pTextLine -> next;				/* Passe … la ligne suivante */
	}
	s_length ++;				 /* Place pour \0 FINAL */
	s_length ++;				 /* Place pour un eventuel \0 suppl‚mentaire si besoin d'ajuster la parit‚ (FMTMODE_REZO) */

	/*
	 * R‚serve zone m‚moire: 
	 */
	pBuf = (char *) MALLOC( s_length );		/* R‚serve m‚moire */

	/*
	 * -------------------------------------------------
	 * Recopie les lignes: 
	 * -------------------------------------------------
	 */		
	pTextLine = pTextLine_First;		/* Commence … la premiŠre ligne: */
	piBuf = pBuf;							/* Commence … ‚crire au d‚but de la chaine */
	while( pTextLine != NULL )
	{	/*
	 	 * Tant qu'on est pas sur la derniŠre ligne: 
	 	 */
		memcpy( piBuf, pTextLine -> text, pTextLine -> length );	/* Recopie la ligne */
		piBuf += pTextLine -> length;			/* Avance le pointeur */

		if( pTextLine -> info1.continued )
		{	/*
			 * Le paragraphe continue sur la ligne suivante:
			 * Note: si les mots sont plus longs que la ligne on riske de se
			 * retrouver avec des espaces en trop. Ptet qu'on pourrait tester
			 * si la ligne est pleine et si oui: pas d'espace ins‚r‚!
			 */
			*(piBuf++) = ' ';	/* InsŠre espace */
		}
		else
		{	/*
			 * Fin de paragraphe:
			 */
			if( mode == FMTMODE_REZO )
			{
				*(piBuf++) = CR;	/* InsŠre fin de Ý */
			}
			else if( mode == FMTMODE_NEARBINARY )
			{
				if( pTextLine -> next != NULL )
				{	/*
					 * Si on est pas sur la derniŠre ligne (15.12.94)
					 */
					*(piBuf++) = CR;	/* InsŠre fin de ligne */
					*(piBuf++) = LF;
				}
			}
			else
			{	/*
				 * Mode FMTMODE_SGLETEXTLINE:
				 * Normalement, le cas d'un saut de paragraphe en mode
				 * FMTMODE_SGLETEXTLINE n'arrive que sur la derniŠre ligne-‚cran
				 * auquel cas on ignore.
				 * Cependant: si ‡a arrivait ailleurs: on remplace par un espace
				 * car on a pas de droit de mettre plusieurs paragraphes!
				 */
				if( pTextLine -> next != NULL )
				{	/*
					 * Si on est (anormalement) pas sur la derniŠre ligne!
					 */
					*(piBuf++) = ' ';	/* InsŠre Espace */
				}
			}
		}

		/*
		 * Passe … la ligne suivante:
		 */
		pTextLine = pTextLine -> next;				
	}
	
	/*
	 * S'occupe des \0 … la fin: 
	 */
	*(piBuf++) = '\0';									/* Fin de la chaŒne */

	/*
	 * R‚ajuste taille du bloc:
	 */
	s_RealLength = piBuf - pBuf;

	/*
	 * Un bloc en mode FMTMODE_REZO ou FMTMODE_SGLETEXTLINE
	 * doit OBLIGATOIREMENT avoir une longueur paire:
	 */
	if( mode == FMTMODE_REZO || mode == FMTMODE_SGLETEXTLINE)
	{
		s_RealLength = (s_RealLength+1) & PARITY;
		pBuf[ s_RealLength-1 ] = '\0';		/* Bouche trou ‚ventuel du … la parit‚ */
	}
	/* printf( "Real length: %lu   Max: %lu\n", s_RealLength, s_length ); */

	if( s_RealLength < s_length )
	{
		pBuf = (char *) REALLOC( pBuf, s_RealLength );
	}

	/*
	 * Retourne bloc:
	 */
	*ppBuf_compact = pBuf;

	return	s_RealLength;	
}



/*
 * -------------------- EDITION D'UN TEXTE EN MEMOIRE --------------------
 */


/*
 * textEdit_addChar(-)
 *
 * Purpose:
 * --------
 * Ajoute un caractŠre dans une ligne de texte
 *
 * History:
 * --------
 * 20.08.94: fplanque: Extracted form winEdit_...
 * 21.08.94: fplanque: tient compte longueur max ligne 
 * 08.10.95: v‚rifie qu'on insŠre pas aprŠs la fin de la ligne
 */
void	textEdit_addChar( 
			TEXTLINE *	pTextLine,		/* In: Ligne a ‚diter */
			int			n_col,			/* In: O— ajouter le car [0..] */
			char			c_car,			/* In: CaractŠre … ins‚rer */
			int			n_maxlen )		/* In: Longueur maximale d'une ligne */
{
	int		n_BufSize	= pTextLine -> info1.bufsize;
	char	*	psz_text		= pTextLine -> text;
	char	*	spsz_CarPos;			/* static pointer */

	/*
	 * V‚rifie qu'on est ds le champ du possible:
	 */
	if( n_col >= n_maxlen )
	{
		return;
	}
	if( n_col > pTextLine -> length )
	{
		signale( "BUG: Impossible d'ins‚rer un car aprŠs la fin de la ligne!" );
		return;
	}
	
	/*
	 * Ajuste ‚ventuellement la taille du buffer:
	 */
	if( n_BufSize <= pTextLine -> length )
	{	/*
	 	 * Normalement le cas < ne devrait JAMAIS arriver!
	 	 * Si le buffer ne peut pas accueillir de caractŠres suppl‚mentaires:
	 	 * On le rallonge:
	 	 */
	 	n_BufSize = min( n_BufSize + BUFFER_INCREASE_STEP, n_maxlen );
	 	pTextLine -> info1.bufsize = n_BufSize;
	 	
		if( psz_text != NULL )
		{
			psz_text = (char *) REALLOC( psz_text, n_BufSize + 1 );	/* +1 pour \0 final */
		}
		else
		{
			psz_text = (char *) MALLOC( n_BufSize + 1 );		/* +1 pour \0 final */
			psz_text[ 0 ] = '\0';			/* ChaŒne vide */
		}
		pTextLine -> text = psz_text;

		/* printf( "New buf: [%s]  ", pS_text ); */
	}

	
	/*
	 * InsŠre le caractŠre:
	 */
	spsz_CarPos = &( psz_text[ n_col ] );

	memcpy( spsz_CarPos +1, spsz_CarPos, pTextLine -> length - n_col + 1 );	/* D‚cale fin de la ligne  (+1 pour le \0) */
	(pTextLine -> length) ++; 		/* Nouvelle longueur de ligne */

	*spsz_CarPos = c_car;		/* Ecrit caractŠre ds buffer */
}



/*
 * textEdit_delChar(-)
 *
 * Purpose:
 * --------
 * Efface un caractŠre dans une ligne de texte
 *
 * History:
 * --------
 * 20.08.94: fplanque: Extracted form winEdit_...
 * 20.08.94: correction d'un +1 inutile
 */
void	textEdit_delChar( 
			TEXTLINE *	pTextLine,		/* In: Ligne a ‚diter */
			int			n_col )			/* In: Car … effacer [0..] */
{
	if( n_col < (pTextLine -> length) )
	{	/*
		 *	On ne va effacer que si on se trouve effectivement
		 * … _l'int‚rieur_ d'une ligne
		 */
	
		char	* pS_CarPos = &( (pTextLine -> text)[ n_col ] );
	
		/*
		 * Efface le caractŠre:
		 */
		memcpy( pS_CarPos, pS_CarPos+1, (pTextLine -> length) - n_col );	/* D‚cale fin de la ligne */
		/*
		 * Fixe nouvelle longueur de la ligne!
		 */
		(pTextLine -> length)--; 

	}
}


/*
 * -------------- AFFICHAGE D'UN TEXTE DANS UNE FENETRE ------------------
 */



/*
 * create_TextDrawPar(-)
 *
 * Purpose:
 * --------
 * Cr‚ation de paramŠtres d'affichage 
 * pour le texte formatt‚ fourni en paramŠtre
 *
 * Algorythm:
 * ----------  
 * Agit uniquement si pTextInfo != NULL
 *
 * History:
 * --------
 * 25.05.94: fplanque: Created
 * 07.01.95: Fixe nb lignes max … garder en m‚moirepour les logs
 */
TEXT_DRAWPAR *	create_TextDrawPar( 				/* Out: Ptr sur infos d'affichage g‚n‚r‚es */
						TEXTINFO *	pTextInfo,		/* In:  Ptr sur texte … afficher */
						long			l_nbLinesMax )	/* In:  Nbre max de lignes qu'on veut garder en m‚moire (pour les logs, pas pour les ‚ditables) */
{
	TEXT_DRAWPAR * pTextDrawPar;

	if( pTextInfo == NULL )
	{
		return	NULL;
	}

	/*
	 * Cr‚e une zone d'infos: 
	 */
	pTextDrawPar = (TEXT_DRAWPAR *) MALLOC( sizeof( TEXT_DRAWPAR ) );
	if ( pTextDrawPar == NULL )		/* Si pas assez de m‚moire */
	{
		alert( NOMEM_OPENDOC );			/* Pas assez de mem pour ouvrir doc */
		return	NULL;						/* Ouverture … ‚chou‚ */
	}		

	pTextDrawPar -> pTextInfo	= pTextInfo;					/* Texte … afficher */
	pTextDrawPar -> pTextLine_top	= pTextInfo -> firstline;	/* 1Šre ligne fenˆtre (Ligne 0) */
	pTextDrawPar -> l_topline	= 0;							/* Ligne no 0 */

	pTextDrawPar -> n_points	= G_std_text .points;	/* Haut en "pts" */
	pTextDrawPar -> n_char_h	= G_std_text .char_h;	/* Haut car */
	pTextDrawPar -> n_cell_w	= G_std_text .cell_w;	/* Larg. emplacement */
	pTextDrawPar -> n_cell_h	= G_std_text .cell_h;	/* Haut emplacement */

	/*
	 * Nombre de lignes qu'on s'autorise … garder en m‚moire
	 * (les textes ‚ditables n'ont pas de limite)
	 */
	pTextDrawPar -> l_nbLinesMax	= l_nbLinesMax;                        

	/*
	 * Par d‚faut le texte n'est pas ‚ditable et n'a donc pas de curseur:
	 */
	pTextDrawPar -> pTextLine_edit = NULL;		/* Pas de ligne en cours d'‚dition */
	pTextDrawPar -> l_LigneCsr		 = 0;			/* Ligne 0 */
	pTextDrawPar -> n_ColCsr		 = 0;			/* Colonne 0 */
		
	return	pTextDrawPar;
}




/*
 * open_text(-)
 *
 * Purpose:
 * --------
 * Param‚trage d'une fenˆtre texte en vue de son ouverture
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: fplanque: retrait du param TEXTLINE *text_ptr
 * 25.05.94: adaptation au nouveau sch‚ma de TEXT_DRAWPAR
 * 26.09.94: gestion des TYP_ERRORS extraite en proc ind‚pendante
 */
void open_text( 
		WIPARAMS 	 *	pWiParams, 
		TEXT_DRAWPAR *	pTextDrawPar )
{
	TEXTINFO *	pTextInfo = pTextDrawPar -> pTextInfo;

	/*
	 * Param‚trage de la fenˆtre: 
	 */

	/* 
	 * Pointe sur infos texte: 
	 */
	pWiParams -> content_ptr.textInfo= pTextInfo;	

	/* 
	 * Pointe sur informations texte en RAM: 
	 */
	pWiParams -> draw_ptr.pTextDrawPar	= pTextDrawPar;	

	calc_textSizeW( pWiParams );
	calc_textSizeH( pWiParams );
	pWiParams -> h_step = (pTextDrawPar -> n_cell_w) *8;	/* Saut par 8 car */
	pWiParams -> v_step = pTextDrawPar -> n_cell_h;		/* Saut par ligne */

	/*
	 * Options menu: 
	 */
	pWiParams -> menu_options.savedisk	= TRUE_1;	/* On peut sauver le contenu de la fenˆtre */
	pWiParams -> menu_options.compile	= TRUE_1;	/* On peut compiler le texte */
	pWiParams -> menu_options.affichage = PARAFF_TEXT;	/* On peut r‚gler la taille du texte */

	/*
	 * Autres: 
	 */
	if ( pWiParams -> type == TYP_DEBUG )
	{	/*
		 * Si on a affaire … la fenˆtre d'infos debug 
		 */
		G_debug_window = pWiParams; 	/* Adr de la fenˆtre de debug */
		menu_ienable( G_menu_adr, SYSTEMST, 1);	/* Enable System status */
	}
	
	/*
	 * Edition/curseur:
	 */
 	if ( pWiParams -> type == TYP_TEXT )
	{	/*
		 * Si on a affaire … la fenˆtre contenant un texte: 
		 * Ligne en cours d'‚dition: juste aprŠs la topline (:ligne0:vide)
		 * (la topline n'est pas tjs visible entiŠrement
		 */
		pTextDrawPar -> pTextLine_edit = pTextDrawPar -> pTextLine_top -> next;
		pTextDrawPar -> l_LigneCsr		 = 1;			/* Ligne 1 */
		pTextDrawPar -> n_ColCsr 		 = 0;			/* Colonne 0 */
	}
}





/*
 * calc_textSizeW(-)
 *
 * Purpose:
 * --------
 * Calcule et fixe largeur totale du texte
 *
 * Algorythm:
 * ----------  
 * On rajoute +8 car il y a 4 pix … gauche et … droite
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: utilise maintenant un TEXT_DRAWPAR en paramŠtre
 * 13.06.94: s‚par‚ calcul de W et de H, TEXT_DRAWPAR maintenant extrait de pTextDrawPar
 */
void	calc_textSizeW( 
				WIPARAMS	 *	pWiParams  )
{
	TEXT_DRAWPAR * pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;

	pWiParams -> total_w	= 
		G_def_text_width * pTextDrawPar -> n_cell_w + 8;		/* Largeur max */
}


/*
 * calc_textSizeH(-)
 *
 * Purpose:
 * --------
 * Calcule et fixe hauteur totale du texte
 *
 * Algorythm:
 * ----------  
 * Rajoute TEXT_VBOTTOM_COMPENSATE parce qu'un emplacement standard a en
 *	g‚n‚ral des lignes vides au dessus des caractŠres et
 *	pas au dessous. Cette ligne suppl‚mentaire est donc 
 *	destin‚e … compenser (un ptit peu) en fin de fenˆtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: utilise maintenant un TEXT_DRAWPAR en paramŠtre
 * 13.06.94: s‚par‚ calcul de W et de H, TEXT_DRAWPAR maintenant extrait de pTextDrawPar
 */
void	calc_textSizeH( 
			WIPARAMS 	 *	pWiParams )
{
	TEXT_DRAWPAR * pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;
	TEXTINFO		 * pTextInfo = pTextDrawPar -> pTextInfo;

	pWiParams -> total_h			= 
			(pTextInfo -> nb_lignes) 			/* Nombre de lignes */
		*	(pTextDrawPar -> n_cell_h )		/* Hauteur d'une ligne */
		+	(pTextDrawPar -> n_cell_h /TEXT_VMARGINS_LINERATIO * 2 )			/* parce qu'un 1/3 de ligne au dessus et au dessous */
		+	TEXT_VBOTTOM_COMPENSATE;
}



/*
 * textLine_OffsetY(-)
 *
 * Purpose:
 * --------
 * Fournit la position verticale d'une ligne
 * en pixels par rapport au d‚but du document texte [0...]
 *
 * Notes:
 * --------
 * Inutilis‚ pour l'instant...
 *
 * History:
 * --------
 * 26.05.94: fplanque: Created
 */
unsigned	long	textLine_OffsetY(						/* Out: Offset de la ligne par rapport au d‚but du document */
						TEXT_DRAWPAR *	pTextDrawPar,	/* In:  ParamŠtres d'affichage du texte	*/
						long				l_line )			/* In:  Ligne dont on veut connaitre l'offset [1...] (ne pas demander la ligne0: negatif) */
{
	int	n_line_h = pTextDrawPar -> n_cell_h;

	return	(	l_line * n_line_h
					- n_line_h + (n_line_h /3) 	);	/* Laisse un peu d'espace blanc */

}



/*
 * vmove_text(-)
 *
 * Purpose:
 * --------
 * Mouvement vertical sur une fenˆtre texte
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	vmove_text(
			WIPARAMS *pWiParams, 
			unsigned long new_pos )
{
	long	curr_pos;
	TEXT_DRAWPAR * pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;
	TEXTINFO		 * pTextInfo	 = pTextDrawPar -> pTextInfo;
		
	/*
	 * On se place sur la top-line actuelle: 
	 */
	TEXTLINE	*	pTextLine_top	= pTextDrawPar -> pTextLine_top;
	long			l_topline		= pTextDrawPar -> l_topline; 

	/*
	 * Hauteur d'une ligne en pixels: 
	 */
	int		line_h = pTextDrawPar -> n_cell_h;

	/*
	 * Position actuelle de la fenetre par rapport au texte: 
	 */
	unsigned long	start_pos = pWiParams -> seen_y;

	/*
	 * Recherche quelle est la NOUVELLE ligne du haut de la fenˆtre: 
	 */
	if	( new_pos > start_pos )			/* Si on avance ds le texte: */
	{
		curr_pos = ( start_pos / line_h + 1) * line_h ;  /* Commence sur ligne actuelle */
		while( curr_pos <= new_pos )
		{	/*
			 * Tant qu'on a pas d‚pass‚ la position demand‚e: 
			 */
			curr_pos += line_h;
			l_topline ++;										/* Ligne suivante */
			pTextLine_top = pTextLine_top -> next;		/* on passe sur ligne suivante */
		}

		/*
		 * Contr“le validit‚ Top-Line
		 */
		if( l_topline > (pTextInfo -> nb_lignes) )
		{
			ping();											/* ANORMAL */
			l_topline = pTextInfo -> nb_lignes;
		}
	}
	else										/* Si on recule dans le texte: */
	{
		curr_pos = ( start_pos / line_h ) * line_h ;  /* Commence sur ligne actuelle */
		while( curr_pos > new_pos )
		{	/*
			 * Tant qu'on a pas d‚pass‚ la position demand‚e: 
			 */
			curr_pos -= line_h;
			l_topline --;										/* Ligne Pr‚c‚dente */
			pTextLine_top = pTextLine_top -> prev;		/* on passe sur ligne suivante */
		}

		/*
		 * Contr“le validit‚ Top-Line
		 */
		if( l_topline < 0 )
		{
			ping();											/* ANORMAL */
			l_topline = 0;
		}
	}

	/*
	 * M‚morise nlle top-line: 
	 */
	pTextDrawPar -> pTextLine_top = pTextLine_top;
	pTextDrawPar -> l_topline = l_topline;
	
	/* printf( "\r Top Line = %ld ", l_topline ); */
}



/*
 * move_TextView_vert(-)
 *
 * Purpose:
 * --------
 * D‚place la vue d'une fenˆtre texte vers la position indiqu‚e
 * cel… met … jour les pointeurs sur topline etc... 
 * et effectue le redraw
 *
 * History:
 * --------
 * 26.05.94: fplanque: Created
 */
void	move_TextView_vert(
			WIPARAMS		*	pWiParams, 
			unsigned long	ul_new_VertTextPos )
{
	unsigned long	ul_old_VertTextPos = pWiParams -> seen_y;

	/*
	 * Fixe nouvelle topline:
	 */
	vmove_text( pWiParams, ul_new_VertTextPos );
	
	/*
	 * Sauve nouvelle position:
	 */
	pWiParams -> seen_y = ul_new_VertTextPos;

	/*
	 * R‚affiche l'ascenseur:
	 */
	set_slider_y( pWiParams );

	/*
	 * Fait scroller le contenu de la fenˆtre vers la nouvelle position: 
	 */
	vscroll_window( pWiParams, ul_old_VertTextPos, ul_new_VertTextPos );

}


/*
 * move_TextView_horiz(-)
 *
 * Purpose:
 * --------
 * D‚place la vue d'une fenˆtre texte vers la position indiqu‚e
 * cel… met … jour certaines variables... et effectue le redraw
 *
 * History:
 * --------
 * 30.05.94: fplanque: Created based on move_TextView_vert
 */
void	move_TextView_horiz(
			WIPARAMS		*	pWiParams, 
			unsigned long	ul_new_HorizTextPos )
{
	unsigned long	ul_old_HorizTextPos = pWiParams -> seen_x;

	/*
	 * Sauve nouvelle position:
	 */
	pWiParams -> seen_x = ul_new_HorizTextPos;

	/*
	 * R‚affiche l'ascenseur:
	 */
	set_slider_x( pWiParams );

	/*
	 * Fait scroller le contenu de la fenˆtre vers la nouvelle position: 
	 */
	hscroll_window( pWiParams, ul_old_HorizTextPos, ul_new_HorizTextPos );

}

/*
 * move_TextViewToPos(-)
 *
 * Purpose:
 * --------
 * D‚place la vue d'une fenˆtre texte 
 * de maniŠre … ce que la position demand‚e soit visible … l'‚cran
 * cel… met … jour certaines variables... 
 * et demande le redraw
 * 
 * History:
 * --------
 * 04.07.94: fplanque: Created
 */
void	move_TextViewToPos(
			WIPARAMS	*	pWiParams,
			long			l_ligne,		/* In: No de la ligne qu'n veut rendre visible */
			int			nb_lignes,	/* In: Nbre de lignes devant ˆtre visibles imp‚rativement, normalement 1 */
			int			n_col,		/* In: Colonne … rendre visible */
			int			nb_cols )	/* In: Nbre de colonnes devant ˆtre vues imp‚rativement, normalement 1 */
{
	TEXT_DRAWPAR *	pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;
	/*
	 * Coordonn‚es de la zone texte:
	 */
	int	n_workXGauche = pWiParams -> work_x;
	int	n_workXDroit  = get_workXDroit( pWiParams );
	int	n_workYHaut	  = pWiParams -> work_y;
	int	n_workYBas	  = get_workYBas( pWiParams );
	/*
	 * Calcule coord pix Y sup‚rieure 
	 * de la premiŠre ligne affich‚e (topline): 
	 */
	int	line_h = pTextDrawPar -> n_cell_h;						/* Hauteur d'une ligne en pixels */
	int	line_y = n_workYHaut 										/* Pos Y sup de la ligne en cours d'affichage (init pourla topline) */
						- line_h + (line_h /TEXT_VMARGINS_LINERATIO) /* Laisse un peu d'espace blanc */
						- (int)((pWiParams -> seen_y) % line_h);		/* Tient compte du fait que la ligne peut ˆtre d‚cal‚e par rapport … son alignement vertical initial */
	int	cell_w = pTextDrawPar -> n_cell_w;			/* Largeur d'un emplacement caractŠre en pixels */
	int	first_col = ((int)(pWiParams -> seen_x) - TEXT_HMARGINS_WIDTH) / cell_w;
	int	line_x = n_workXGauche									/* Position en pixels pour l'affichage des lignes de texte */
							- ((int)(pWiParams -> seen_x) - TEXT_HMARGINS_WIDTH) % cell_w;	/* Laisse une marge de 4 pixels sur la gauche */

	/*
	 * Coordonn‚es de la position demand‚e:
	 */
	int	n_PosYHaut	= line_y + (int)(l_ligne - pTextDrawPar->l_topline) * line_h;					
	int	n_PosYBas	= n_PosYHaut + nb_lignes * line_h -1;
	int	n_PosX		= line_x + (n_col - first_col) * cell_w;

	/*
	 * Contr“le de la position verticale:
	 */
	if( n_PosYHaut < n_workYHaut )
	{	/* 
		 * La position demand‚e est au dessus de la partie visible
		 * ou seulement partiellement affich‚e:
		 */
		unsigned long	ul_new_VertTextPos = l_max ( 0,
													(l_ligne - 1) * line_h );
		/*
		 * D‚place la vue: 
		 */
		move_TextView_vert( pWiParams, ul_new_VertTextPos );
	}
	else if( n_PosYBas > n_workYBas )
	{	/* 
		 * La position demand‚e est au dessous de la partie visible,
		 * seulement partiellement affich‚e:
		 */
		unsigned long	ul_new_VertTextPos = l_min ( 
								pWiParams -> total_h 
								 - pWiParams -> seen_h + line_h,
								(l_ligne + nb_lignes) * line_h 
								 - pWiParams -> seen_h
								 - (line_h/TEXT_VMARGINS_LINERATIO + TEXT_VBOTTOM_COMPENSATE) );
		/*
		 * D‚place la vue: 
		 */
		move_TextView_vert( pWiParams, ul_new_VertTextPos );
	}


	/*
	 * Contr“le de la position horizontale:
	 */
	if( n_PosX < n_workXGauche )
	{	/* 
		 * La pos demand‚e est … gauche de la partie visible
		 * ou seulement partiellement affich‚e:
		 */
		unsigned long	ul_new_HorizTextPos =
								l_max ( 0, n_col * cell_w );
		/*
		 * D‚place la vue: 
		 */
		move_TextView_horiz( pWiParams, ul_new_HorizTextPos );
	}
	else if( n_PosX + (nb_cols) * cell_w > n_workXDroit )
	{	/* 
		 * En fait c'est n_PosX + ()*cell_w -1 mais bon...
		 * Le car sous curseur est … droite de la partie visible
		 * ou seulement partiellement affich‚:
		 */
		unsigned long	ul_new_HorizTextPos = 
							l_min ( pWiParams -> total_w - pWiParams -> seen_w,
							 TEXT_HMARGINS_WIDTH + (n_col + nb_cols) * cell_w 
							 - pWiParams -> seen_w );
		/*
		 * D‚place la vue: 
		 */
		move_TextView_horiz( pWiParams, ul_new_HorizTextPos );
	}

}



/*
 * add_textinf(-)
 *
 * Purpose:
 * --------
 * Ajoute une ligne de texte au bas d'une fenˆtre d'infos
 *
 * Suggest:
 * --------
 * Optimize redraw
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: adaptation au nouveau format TEXT_DRAWPAR
 * 30.05.94: appelle maintenant aussi redraw_textline()
 * 13.06.94: update ascenseur simplifi‚e: pas besoin de contr“ler si la fenˆtre d‚passe la fin du document
 * 25.09.94: fait maintenant appel … text_addLineToEnd()
 * 07.01.95: contr“le du nbre de lignes maximum; optimisation du calcul taille totale
 */
void	add_textinf( 
			WIPARAMS 	* pWiParams, 	/* In: Fenˆtre vis‚e */
			const char	* inf )			/* In: ModŠle de texte … dupliker puis ins‚rer */
{
	unsigned long	old_pos;			/* Ancienne position Y */
	signed long		new_pos;
	TEXT_DRAWPAR * pTextDrawPar;
	TEXTINFO		 *	textinfo;
	int				n_cell_h;

	if ( pWiParams == NULL )
	{ 	/*
	 	 * Si la fenˆtre demand‚e a ‚t‚ referm‚e entre temps:
		 */
		 return;
	}
		 

	/* 
	 * Infos sur le texte: 
	 */
	pTextDrawPar	= pWiParams -> draw_ptr.pTextDrawPar;
	textinfo			= pTextDrawPar -> pTextInfo;
	n_cell_h			= pTextDrawPar -> n_cell_h;

	/*
	 * Ajoute la ligne ds le texte en RAM:
	 */
	text_addLineToEnd( textinfo, inf );

	/*
	 * Calcule nlle taille du texte: 
	 */
	(pWiParams -> total_h) += n_cell_h;

	/*
	 * On se place sur la fin du texte: 
	 */
	new_pos = l_max( 0, pWiParams->total_h - pWiParams->seen_h);
	vmove_text( pWiParams, new_pos );		/* Fixe nlle position */
	old_pos = pWiParams -> seen_y;			/* Sauve ancienne position */
	pWiParams -> seen_y = new_pos;

	/*
	 * V‚rifie si le texte ne devient pas trop long:
	 */
	while( textinfo -> nb_lignes > pTextDrawPar -> l_nbLinesMax )
	{	/*
		 * On a atteint le nbre maximum de lignes autoris‚:
		 */
		TEXTLINE * pTextLine_ToErase = textinfo -> firstline -> next;

		if( (pTextDrawPar -> l_topline) <= 1 )
		{	/*
			 * On rique d'effacer une ligne partiellement visible:
			 */
			break;
		}
		 
		/*
		 * M‚morise nlle top-line: 
		 */
		(pTextDrawPar -> l_topline) --;

		(pWiParams -> seen_y) -= n_cell_h;
	
		/*
		 * Efface la plus acienne ligne (no 1):
		 */
		delete_line( pTextLine_ToErase, textinfo );

		/*
		 * Calcule nlle taille du texte: 
		 */
		(pWiParams -> total_h) -= n_cell_h;
	}


	/*
	 * Fixe nlle taille et position ascenseur: 
	 */
	set_slider_h( pWiParams );			/* Fix taille slider vertical */
	set_slider_y( pWiParams );			/* Fix position slider vertical */

	/*
	 * -------
	 * Redraw:
	 * -------
	 */
	{
	/* Variables: */
	int				szone_x, szone_y, szone_w, szone_h;
	int				line_h	= pTextDrawPar -> n_cell_h;		/* Hauteur d'une ligne */
	unsigned long	text_lastpixline = (textinfo -> nb_lignes) * line_h + line_h /3;	/* Avec les pixels blancs du haut */

	/*
	 * Bloque ‚cran: 
	 */
	int	noOverlap = start_WINDRAW( pWiParams );

	/*
	 * Coordonn‚es de la zone de travail: 
	 */
	szone_x	= pWiParams -> work_x;
	szone_y	= pWiParams -> work_y;
	szone_w	= pWiParams -> seen_w;
	szone_h	= pWiParams -> seen_h;

	/*
	 * R‚duit … la partie qui se trouve vraiment sur l'‚cran: 
	 */
	rcintersect(	G_x_mini, G_y_mini, G_w_maxi, G_h_maxi,
				  		&szone_x, &szone_y, &szone_w, &szone_h );


	/*
	 * Teste s'il faut scroller ou pas: 
	 */
	if ( new_pos > old_pos )
	{	/* 
		 * Il faut scroller car la derniŠre ligne ne pouvait ˆtre 
		 * affich‚e entiŠrement: 
		 */
		if( noOverlap == FALSE0 )
		{	/*
			 * La fenˆtre n'est pas en 1 seul bloc:
			 * impossible de scroller: 
			 * Effectue un redraw imm‚diat: 
			 */
			redraw( pWiParams, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, CTRL_OK );	/* Redraw complet */
		}
		else
		{	/* 
			 * Si la fenˆtre est au top: on peut la faire scroller: 
			 */

			/* Variables: */
			long	deplacement = new_pos - old_pos;
			long	text_h = text_lastpixline - old_pos - line_h;
			long	used_h = l_min( text_h, szone_h );

			/*
			 * Teste si on peut scroller un bout d'‚cran ou si le saut est trop grand 
			 */
			if ( deplacement < used_h )
			{	/*
				 * On peut scroller un morceau: 
				 */
				int	bloc_size = (int)(used_h - deplacement);
				
				graf_mouse( M_OFF, NULL);			/* Efface le ptr souris */

				/* Coordonn‚es source, destination: */
				G_pxyarray[0]=szone_x; 			/* Coord source */
				G_pxyarray[1]=szone_y + (int)deplacement;
				G_pxyarray[2]=szone_x + szone_w -1;
				G_pxyarray[3]=G_pxyarray[1] + bloc_size -1;
				G_pxyarray[4]=szone_x;			/* Coord destination */
				G_pxyarray[5]=szone_y;
				G_pxyarray[6]=G_pxyarray[2];
				G_pxyarray[7]=szone_y + bloc_size -1;
				/* D‚placement d'un bloc vers le haut sur l'‚cran logique: */
				vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray,
							  &G_plogMFDB, &G_plogMFDB);
			
				graf_mouse( M_ON, 0);				/* Affiche le ptr souris */

				/*
				 * Que reste-t-il … afficher: 
				 */
				szone_y += bloc_size;
				szone_h -= bloc_size;
				
			}
		
			/*
			 * Affiche ce qui n'a pas encore ‚t‚ trait‚ par scroll: 
			 */
			redraw( pWiParams, szone_x, szone_y, szone_w, szone_h , CTRL_OK );
		}
	}
	else
	{	/*
		 * Pas besoin de scroller, il y a assez de place: 
		 * Affiche ligne: 
		 */
		redraw_textline( pWiParams, textinfo -> lastline, textinfo -> nb_lignes, 0, NIL_1 );
	}

	/*
	 * rend le contr“le de l'‚cran: 
	 */
	end_WINDRAW();

	}

}




/*
 * complete_textinf(-)
 *
 * Purpose:
 * --------
 * ComplŠte une ligne de texte au bas d'une fenˆtre d'infos
 * Cette ligne est suppos‚e visible: pas de scroll n‚cessaire
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: introduced TEXT_DRAWPAR
 * 30.05.94: appelle maintenant aussi redraw_textline()
 * 30.05.94: Mise … jour de la longueur de la ligne
 */
void	complete_textinf(
			WIPARAMS * pWiParams, 
			const char * inf )
{
	if ( pWiParams != NULL )
	{ /*
		* Si la fenˆtre demande n'a pas ‚t‚ referm‚e entre temps 
		* Infos sur le texte: 
		*/
		TEXT_DRAWPAR * pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;
		TEXTINFO	*textinfo = pTextDrawPar -> pTextInfo;
		TEXTLINE	*lastline = textinfo -> lastline;
		/*
		 * Adr derniŠre ligne: 
		 */
		char		*last_text = lastline -> text;
		char		*new_text;
		/* 
		 * Variables: 
		 */
		int		old_len;			/* Ancienne longueur */
		int		new_len;			/* Nouvelle longueur (totale) */
	
		/*
		 * Longueur de la derniŠre ligne, avant modif: 
		 */
		old_len = (int) strlen ( last_text );
		/*
		 * Longueur qu'on va y ajouter: 
		 */
		new_len = old_len + (int) strlen ( inf );
	
		/* 
		 * ComplŠte la derniŠre ligne: 
		 */
		new_text = (char *) REALLOC( last_text, new_len +1 );	/* +1 pour '\0' final */
		strcat( new_text, inf );
		lastline -> text = new_text;

		/*
		 * Fixe nouvelle longueur de la derniŠre ligne:
		 */
		lastline -> length = new_len;
		
		/*
		 * On ne Calcule pas nlle taille du texte 
		 * parce qu'on considŠre que ‡a rentre en largeur! 
		 */

		/* 
		 * R‚serve ‚cran: 
		 */
		start_WINDRAW( NULL );

		/*
		 * Affiche morceau de ligne: 
		 */
		/*	redraw( pWiParams,
						pWiParams -> work_x + old_len * car_w +4,
						(int) (pWiParams -> work_y + text_lastpixline - pWiParams -> seen_y - line_h),
						inf_len * car_w,
						line_h,
						TAKE_CTRL ); */
		redraw_textline( pWiParams, lastline, textinfo -> nb_lignes, old_len, NIL_1 );

		/*
		 * rend le contr“le de l'‚cran: 
		 */
		end_WINDRAW();
	}
}




/*
 * ------------------ EDITION D'UN TEXTE DS UNE FENETRE -----------------
 */


/*
 * winEdit_ProcessKey(-)
 *
 * Purpose:
 * --------
 * Traite une touche tap‚e dans une fenˆtre d'‚dition texte
 *
 * History:
 * --------
 * 25.05.94: fplanque: Created
 * 26.05.94: extension des possibilit‚s
 */
void	winEdit_ProcessKey(
			WIPARAMS *	pWiParams,		/* In: fenˆtre concern‚e */ 
			unsigned		u_kbd_state,	/* In: Etat des touches sp‚ciales */
			int			n_ScanCode,		/* In: ScanCode touche press‚e */
			char			c_car )			/* In: CaractŠre correspondant */
{
	/* printf( "\r ScanCode=%X ", n_ScanCode ); */

	if( u_kbd_state & (K_LSHIFT | K_RSHIFT) )
	{	/*
		 * Si touche SHIFT press‚e:
		 */
		TEXT_DRAWPAR *	pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;

		switch( n_ScanCode )
		{
			case	STSCAN_LEFT:
				/*
				 * D‚but de ligne:
				 */
				winEdit_MoveCsr( pWiParams, 0, -(pTextDrawPar -> n_ColCsr) );
				break;
	
			case	STSCAN_RIGHT:
				/*
				 * Fin de ligne:
				 */
				winEdit_MoveCsr( pWiParams, 0, 
					(pTextDrawPar -> pTextLine_edit -> length)-(pTextDrawPar -> n_ColCsr)  );
				break;
	
			case	STSCAN_UP:
			case	STSCAN_DOWN:
			{	/*
				 * Page vers le haut:
				 * Page vers le bas:
				 */
				int	n_line_h	= pTextDrawPar -> n_cell_h;
				int	nb_LignesEcran = max( 1, (pWiParams -> seen_h) / n_line_h - 1);
				int	nb_LignesDeplacement;
				long	l_new_VertTextPos;
				
				/*
				 * D‚termine d‚placement & nouvelle position:
				 */
				if( n_ScanCode == STSCAN_UP )
				{
					nb_LignesDeplacement  = - nb_LignesEcran;
				 	l_new_VertTextPos = l_max( 0, 
				 		pWiParams -> seen_y + nb_LignesDeplacement * n_line_h );
				}
				else
				{
					nb_LignesDeplacement  =  nb_LignesEcran;
				 	l_new_VertTextPos = l_min( pWiParams -> total_h - pWiParams -> seen_h, 
				 		pWiParams -> seen_y + nb_LignesDeplacement * n_line_h );
				 	l_new_VertTextPos = MAX( l_new_VertTextPos, 0 );				
				}

			
				/*
				 * D‚place la vue: 
				 */
				move_TextView_vert( pWiParams, l_new_VertTextPos );

				/*
				 * D‚place le curseur: 
				 */
				winEdit_MoveCsr( pWiParams, nb_LignesDeplacement, 0 );

			}
				break;
	
			default:
				if( c_car >= ' ' )
				{
					winEdit_TypeCar( pWiParams, c_car );
				}
	
		}
	}
	else if( u_kbd_state == 0 )
	{	/*
		 * Pas de touche sp‚ciale press‚e:
		 */
		switch( n_ScanCode )
		{
			case	STSCAN_BS:
				/*
				 * Backspace:
				 */
				winEdit_DelCar( pWiParams, TRUE );
				break;

			case	STSCAN_UP:
				winEdit_MoveCsr( pWiParams, -1, 0 );
				break;
			
			case	STSCAN_LEFT:
				winEdit_MoveCsr( pWiParams, 0, -1 );
				break;
	
			case	STSCAN_RIGHT:
				winEdit_MoveCsr( pWiParams, 0, +1 );
				break;
	
			case	STSCAN_DOWN:
				winEdit_MoveCsr( pWiParams, +1, 0 );
				break;

			case	STSCAN_DEL:
				/*
				 * Delete:
				 */
				winEdit_DelCar( pWiParams, FALSE );
				break;
		
			default:
				switch( c_car )
				{
					case	CR:
						winEdit_BreakLine( pWiParams );
						break;

					default:
						if( c_car >= ' ' )
						{
							winEdit_TypeCar( pWiParams, c_car );
						}
				}
		}
	}
	else if( c_car >= ' ' )
	{
		winEdit_TypeCar( pWiParams, c_car );
	}

}



/*
 * winEdit_MoveCsr(-)
 *
 * Purpose:
 * --------
 * D‚place le curseur
 * dans une fenˆtre d'‚dition texte
 *
 * Suggest:
 * --------
 * Ne pas tenter d'afficher le curseur s'il est trop loin de la 
 * partie visible de la fenˆtre (conversion pourrait le ramener o— il ne faut pas)
 * OPTIMIZE!
 *
 * History:
 * --------
 * 25.05.94: fplanque: Created
 * 26.05.94: extension des possibilit‚s
 * 30.05.94: la fenˆtre sepositionne avant d'afficher le nouveau curseur
 * 30.05.94: la fenˆtre se positionne aussi horizontalement
 * 01.06.94: R‚serve ‚cran avant de faire les op‚rations graphiques!!
 */
void	winEdit_MoveCsr(
			WIPARAMS *	pWiParams,	
			int			n_YMove,
			int			n_XMove )
{
	/*
	 * Infos sur le texte … ‚diter:
	 */
	TEXT_DRAWPAR * pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;
	long			nb_lignes	= pTextDrawPar -> pTextInfo -> nb_lignes;
	long			l_topline	= pTextDrawPar -> l_topline;
	TEXTLINE	*	pTextLine_edit = pTextDrawPar -> pTextLine_edit;	/* Ligne en cours d'‚dition; porte le curseur */
	long			l_LigneCsr	= pTextDrawPar -> l_LigneCsr;				/* Ligne ou se trouve le curseur [1...] (La ligne 0 n'est pas ‚ditable) */
	long			l_CurrLine	= l_LigneCsr;
	int			n_ColCsr		= pTextDrawPar -> n_ColCsr;				/* Colonne ou se trouve le curseur [0...nb_cars] si nb_cars:apres dernier caractŠre  */
	long			l_NewLigneCsr = l_LigneCsr + n_YMove;					/* Nouvelle ligne curseur */
	int			n_NewColCsr = n_ColCsr + n_XMove;					/* Nouvelle colonne curseur */

	/*
	 * ---------------------
	 * D‚placement vertical:
	 * ---------------------
	 */
	if( n_YMove )
	{
		/*
		 * Contr“le si la nouvelle position Y est autoris‚e:
		 */
		if( l_NewLigneCsr < 1)
		{
			l_NewLigneCsr = 1;	
		}
		else if( l_NewLigneCsr > nb_lignes )
		{
			l_NewLigneCsr = nb_lignes;
		}
	
		/*
		 * D‚place la ligne courante:
		 */
		while( l_CurrLine < nb_lignes )
		{
			l_CurrLine ++;
			pTextLine_edit = pTextLine_edit -> next;
		}
		while( l_CurrLine > l_NewLigneCsr )
		{
			l_CurrLine --;
			pTextLine_edit = pTextLine_edit -> prev;
		}

		/*
		 * Contr“le si le curseur n'est pas sorti de la nouvelle ligne
		 * par la droite:
		 */
		if( n_NewColCsr > pTextLine_edit -> length )
		{	/*
			 * SI on d‚borde … droite du texte:
			 */
			n_NewColCsr = pTextLine_edit -> length;
		}		
	}	


	/*
	 * -----------------------
	 * D‚placement horizontal:
	 * -----------------------
	 */
	if( n_XMove )
	{
		/*
		 * Contr“le si la position X est autoris‚e:
		 */
		if( n_NewColCsr < 0)
		{	/*
			 * SI on d‚borde … gauche du texte:
			 */
			if( l_LigneCsr > 1 )
			{	/*
				 * remonte d'une ligne:
				 */
				l_NewLigneCsr --;								   /* Curseur sur ligne pr‚c‚dente */
				pTextLine_edit = pTextLine_edit -> prev;	/* Nouvelle ligne … ‚diter */
				n_NewColCsr = pTextLine_edit -> length;	/* Curseur en fin de ligne */
			}
			else
			{
				n_NewColCsr = 0;	
			}
		}
		else if( n_NewColCsr > pTextLine_edit -> length )
		{	/*
			 * SI on d‚borde … droite du texte:
			 */
			if( l_LigneCsr < nb_lignes )
			{	/*
				 * descend d'une ligne:
				 */
				l_NewLigneCsr ++;								   /* Curseur sur ligne suivante< */
				pTextLine_edit = pTextLine_edit -> next;	/* Nouvelle ligne … ‚diter */
				n_NewColCsr = 0;									/* Curseur en d‚but de ligne */
			}
			else
			{
				n_NewColCsr = pTextLine_edit -> length;
			}
		}
	}


	/*
	 * Contr“le si la position … chang‚:
	 */
	if( l_NewLigneCsr != l_LigneCsr || n_NewColCsr != n_ColCsr)
	{	/*
	    * ==================
		 * Position … chang‚:
	    * ==================
		 */
		int	n_workYHaut	  = pWiParams -> work_y;
		int	n_workYBas	  = get_workYBas( pWiParams );
		int	n_workXGauche = pWiParams -> work_x;
		int	n_workXDroit  = get_workXDroit( pWiParams );
		/*
		 * Calcule coord pix Y sup‚rieure 
		 * de la premiŠre ligne affich‚e (topline): 
		 */
		int	line_h = pTextDrawPar -> n_cell_h;						/* Hauteur d'une ligne en pixels */
		int	line_y = n_workYHaut 										/* Pos Y sup de la ligne en cours d'affichage (init pourla topline) */
							- line_h + (line_h /TEXT_VMARGINS_LINERATIO) /* Laisse un peu d'espace blanc */
							- (int)((pWiParams -> seen_y) % line_h);		/* Tient compte du fait que la ligne peut ˆtre d‚cal‚e par rapport … son alignement vertical initial */
		/*
		 * Calcule le 1er car … afficher … partir de la gauche
		 * et sa coord pix X:
		 */
		int	cell_w 	 = pTextDrawPar -> n_cell_w;					/* Largeur d'un emplacement caractŠre en pixels */
		int	first_col = ((int)(pWiParams -> seen_x) - TEXT_HMARGINS_WIDTH) / cell_w;
		int	line_x	 = n_workXGauche									/* Position en pixels pour l'affichage des lignes de texte */
								- ((int)(pWiParams -> seen_x) - TEXT_HMARGINS_WIDTH) % cell_w;	/* Laisse une marge de 4 pixels sur la gauche */
		/*
		 * Nlles Coordonn‚es du curseur
		 */
		int	n_CsrYHaut	= line_y + (int)(l_NewLigneCsr - l_topline) * line_h;					
		int	n_CsrYBas	= n_CsrYHaut + line_h -1;
		int	n_CsrX		= line_x + (n_NewColCsr - first_col) * cell_w;

		/*
		 * -----------------------------------------------
		 * Effacement du curseur de son ancienne position:
		 * -----------------------------------------------
		 * Op‚rations graphiques sur le curseur:
		 * vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		 * R‚serve ‚cran: 
		 */
		start_WINDRAW( NULL );
	
		/*
		 * Clipping sur la zone de travail:
		 */
		G_pxyarray[0] = n_workXGauche;
		G_pxyarray[1] = n_workYHaut;
		G_pxyarray[2] = n_workXDroit;
		G_pxyarray[3] = n_workYBas;
		vs_clip( G_ws_handle, YES1, G_pxyarray );	/* Clipping pour text */
	
		/*
		 * Fixe attributs de remplissage:
		 */
		vsf_interior( G_ws_handle, FIS_SOLID );		/* remplissage: PLEIN(couleur courante) */
		vswr_mode( G_ws_handle, MD_XOR );
	
		/*
		 * Efface le curseur de l'ancienne position:
		 */
		G_pxyarray[0] = line_x + (n_ColCsr - first_col) * cell_w;	/* Coord X du curseur */
		G_pxyarray[1] = line_y + (int)(l_LigneCsr - l_topline) * line_h;	/* Coord Y de la ligne */
		G_pxyarray[2] = G_pxyarray[0] + CURSOR_WIDTH -1;				/* Coord X droite du curseur */
		G_pxyarray[3] = G_pxyarray[1] + line_h -1;	/* Coord Y basse du curseur */
		vr_recfl( G_ws_handle, G_pxyarray );	 
	
		/*
		 * Remet les attributs de remplissage … leurs valeurs par d‚faut:
		 */
		vswr_mode( G_ws_handle, MD_REPLACE );
		vsf_interior( G_ws_handle, FIS_HOLLOW );		/* remplissage: VIDE(blanc) */
	
		/*
		 * Supprime rectangle de clipping:
		 */
	 	vs_clip( G_ws_handle, NO0, G_pxyarray );		/* Clipping OFF! */
		
		/*
		 * ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		 * rend le contr“le de l'‚cran: 
		 */
		end_WINDRAW();
		
		/*
		 * Il n'y a TEMPORAIREMENT plus de curseur:
		 * C'est important pour les routines de redraw invoqu‚es lors
		 * du d‚pacement de la fenˆtre vers le curseur
		 */
		pTextDrawPar -> pTextLine_edit = NULL;


		/*
		 * ------------------------------------------------------------
		 * D‚placement de la fenˆtre vers la nouvelle position curseur:
		 * ------------------------------------------------------------
		 * Contr“le de la position verticale:
		 */
		if( n_CsrYHaut < n_workYHaut )
		{	/* 
			 * Le curseur est au dessus de la partie visible
			 * ou seulement partiellement affich‚:
			 */
			unsigned long	ul_new_VertTextPos = l_max ( 0,
														(l_NewLigneCsr - 1) * line_h );
			/*
			 * D‚place la vue: 
			 */
			move_TextView_vert( pWiParams, ul_new_VertTextPos );
		}
		else if( n_CsrYBas > n_workYBas )
		{	/* 
			 * Le curseur est au dessous de la partie visible
			 * ou seulement partiellement affich‚:
			 */
			unsigned long	ul_new_VertTextPos = l_min ( pWiParams -> total_h - pWiParams -> seen_h,
								 (l_NewLigneCsr + 1) * line_h 
								 - pWiParams -> seen_h
								 - (line_h/TEXT_VMARGINS_LINERATIO + TEXT_VBOTTOM_COMPENSATE) );
			/*
			 * D‚place la vue: 
			 */
			move_TextView_vert( pWiParams, ul_new_VertTextPos );
		}


		/*
		 * Contr“le de la position horizontale:
		 */
		if( n_CsrX < n_workXGauche )
		{	/* 
			 * Le car concern‚ par le curseur est … gauche de la partie visible
			 * ou seulement partiellement affich‚:
			 */
			unsigned long	ul_new_HorizTextPos =
									l_max ( 0, n_NewColCsr * cell_w );
			/*
			 * D‚place la vue: 
			 */
			move_TextView_horiz( pWiParams, ul_new_HorizTextPos );
		}
		else if( n_CsrX + cell_w > n_workXDroit )
		{	/* 
			 * En fait c'est n_CsrX + cell_w -1 mais bon...
			 * Le car sous curseur est … droite de la partie visible
			 * ou seulement partiellement affich‚:
			 */
			unsigned long	ul_new_HorizTextPos = 
								l_min ( pWiParams -> total_w - pWiParams -> seen_w,
								 TEXT_HMARGINS_WIDTH + (n_NewColCsr + 1) * cell_w 
								 - pWiParams -> seen_w );
			/*
			 * D‚place la vue: 
			 */
			move_TextView_horiz( pWiParams, ul_new_HorizTextPos );
		}


		/*
		 * Mise … jour des variables qui auraient pu changer
		 * lors du d‚placement de la fenˆtre sur le texte
		 */
		l_topline	= pTextDrawPar -> l_topline;
		line_y 		= n_workYHaut 										/* Pos Y sup de la ligne en cours d'affichage (init pourla topline) */
							- line_h + (line_h /TEXT_VMARGINS_LINERATIO) /* Laisse un peu d'espace blanc */
							- (int)((pWiParams -> seen_y) % line_h);		/* Tient compte du fait que la ligne peut ˆtre d‚cal‚e par rapport … son alignement vertical initial */
		first_col	= ((int)(pWiParams -> seen_x) - TEXT_HMARGINS_WIDTH) / cell_w;
		line_x		= n_workXGauche									/* Position en pixels pour l'affichage des lignes de texte */
								- ((int)(pWiParams -> seen_x) - TEXT_HMARGINS_WIDTH) % cell_w;	/* Laisse une marge de 4 pixels sur la gauche */
		n_CsrYHaut	= line_y + (int)(l_NewLigneCsr - l_topline) * line_h;	/* Coord Y de la ligne */
		n_CsrYBas	= n_CsrYHaut + line_h -1;
		n_CsrX		= line_x + (n_NewColCsr - first_col) * cell_w;


		/* 
		 * --------------------------------------------
		 * R‚affiche le curseur … sa nouvelle position:
		 * --------------------------------------------
		 * Op‚rations graphiques sur le curseur:
		 * vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		 * R‚serve ‚cran: 
		 */
		start_WINDRAW( NULL );

		/* 
		 * Clipping sur la zone de travail:
		 */
		G_pxyarray[0] = n_workXGauche;
		G_pxyarray[1] = n_workYHaut;
		G_pxyarray[2] = n_workXDroit;
		G_pxyarray[3] = n_workYBas;
		vs_clip( G_ws_handle, YES1, G_pxyarray );	/* Clipping pour text */
	
		/*
		 * Fixe attributs de remplissage:
		 */
		vsf_interior( G_ws_handle, FIS_SOLID );		/* remplissage: PLEIN(couleur courante) */
		vswr_mode( G_ws_handle, MD_XOR );
	
		/*
		 * R‚affiche le curseur … la nouvelle position:
		 */
		G_pxyarray[0] = n_CsrX;					/* Coord X du curseur */
		G_pxyarray[1] = n_CsrYHaut;			/* Coord Y de la ligne */
		G_pxyarray[2] = n_CsrX + CURSOR_WIDTH - 1;			/* Coord X droite du curseur */
		G_pxyarray[3] = n_CsrYBas;				/* Coord Y basse du curseur */
		vr_recfl( G_ws_handle, G_pxyarray );	 
	
		/*
		 * Remet les attributs de remplissage … leurs valeurs par d‚faut:
		 */
		vswr_mode( G_ws_handle, MD_REPLACE );
		vsf_interior( G_ws_handle, FIS_HOLLOW );		/* remplissage: VIDE(blanc) */
	
		/*
		 * Supprime rectangle de clipping:
		 */
	 	vs_clip( G_ws_handle, NO0, G_pxyarray );		/* Clipping OFF! */

		/*
		 * ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		 * rend le contr“le de l'‚cran: 
		 */
		end_WINDRAW();

		/*
		 * -----------------------------------
		 * Sauve nouvelle position du curseur:
		 * -----------------------------------
		 */ 
		pTextDrawPar -> pTextLine_edit = pTextLine_edit;
		pTextDrawPar -> l_LigneCsr = l_NewLigneCsr;
		pTextDrawPar -> n_ColCsr = n_NewColCsr;
	}
}




/*
 * winEdit_TypeCar(-)
 *
 * Purpose:
 * --------
 * Ajoute un caractŠre dans une fenˆtre d'‚dition texte.
 *
 * Suggest:
 * --------
 * ATTENTION … ne pas d‚passer la limite en largeur!
 *
 * History:
 * --------
 * 30.05.94: fplanque: Created
 * 31.05.94: Correction bug sur r‚allocation du buffer
 * 04.07.94: Impossible de taper plus que longueur maximale autoris‚e
 * 05.07.94: D‚place vue vers curseur avant d'‚crire
 */
void	winEdit_TypeCar(
			WIPARAMS *	pWiParams,	
			char			c_car )
{
	TEXT_DRAWPAR *	pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;
	/*
	 * Colonne du curseur;
	 */
	int				n_Pos = pTextDrawPar -> n_ColCsr;
	/* 
	 * Ligne en cours d'‚dition; porte le curseur:
	 */
	TEXTLINE		 *	pTextLine_edit = pTextDrawPar -> pTextLine_edit;
	/*
	 * Longueur de cette ligne (\0 non compris):
	 */
	int				n_length = pTextLine_edit -> length;		

	/*
	 * ---------------------------------------
	 * D‚place la vue courante sur le curseur:
	 * ---------------------------------------
	 */
	move_TextViewToPos( pWiParams, pTextDrawPar -> l_LigneCsr, 1, n_Pos, 8 );
	

	/*
	 * Contr“le longueur ligne:
	 */
	if( n_length >= G_def_text_width )
	{	/*
		 * Si longueur ligne max atteinte:
		 * ( '>' ne devrait JAMAIS se produire)
		 */
		ping();
		return;
	}

	/*
	 * Ajoute caractŠre ds texte:
	 */
	textEdit_addChar( pTextLine_edit, n_Pos, c_car, G_def_text_width );


	/*
	 * Curseur avance:
	 */
	pTextDrawPar -> n_ColCsr = n_Pos + 1;
	 
	/*
	 * R‚affiche la fin de ligne:
	 * Cel… … pour effet secondaire d'‚craser le curseur actuel
	 * et de le r‚afficher … sa nouvelle position:
	 */
	start_WINDRAW( NULL );
	redraw_textline( pWiParams, pTextLine_edit, pTextDrawPar -> l_LigneCsr, n_Pos, NIL_1 );
	end_WINDRAW();
	
	/*
	 * Signale … la fenˆtre que son contenu a ‚t‚ modifi‚:
	 */
	Wnd_SetModified( pWiParams );
	
}



/*
 * winEdit_DelCar(-)
 *
 * Purpose:
 * --------
 * Efface un caractŠre dans une fenˆtre d'‚dition texte.
 * aprŠs apui sur backspace ou delete
 *
 * Algorythm:
 * ----------  
 * Backspace est trait‚ comme delete sauf que le curseur est d‚plac‚ en
 * arriŠre au pr‚alable.
 *
 * Suggest:
 * --------
 * Groupper tous les bouts de codes de scrolling en une seule proc‚dure
 *
 * History:
 * --------
 * 01.06.94: fplanque: Created base on _TypeCar()
 * 01.07.94: D‚but gestion backspace
 * 04.07.94: Possibilit‚ de regroupper 2 lignes avec Delete
 * 05.07.94: Backspace peut regroupper lignes
 * 05.07.94: Correction bug d'effacement derniŠre ligne lors d'un regrouppement sur derniŠre ligne
 * 01.08.94: Ajout‚ 1 pixel en hauteur au scroll... ‡a marche mais je sais pas pourkoi!?
 * 03.08.94: En fait, la correction du 01.08 ‚tait mauvaise: enlev‚: il fallait v‚rifier que la zone de scroll ‚tait suffisament haute pour le d‚placement envisag‚!
 * 20.08.94: Modifi‚ m‚thode de redraw de la ligne:
 * 24.08.94; ajout‚ traitement du flag continued
 */
void	winEdit_DelCar(					/* Out: rien */
			WIPARAMS *	pWiParams,		/* In: ParamŠtres fenˆtre */
			int			b_backspace )	/* In: True si backspace */
{
	TEXT_DRAWPAR *	pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;
	TEXTINFO		 * pTextInfo = pTextDrawPar -> pTextInfo;

	/*
	 * Colonne du curseur;
	 */
	int				n_Pos = pTextDrawPar -> n_ColCsr;
	/* 
	 * Ligne en cours d'‚dition; porte le curseur:
	 */
	long				l_editLine = pTextDrawPar -> l_LigneCsr;
	TEXTLINE		 *	pTextLine_edit = pTextDrawPar -> pTextLine_edit;
	/*
	 * Texte & Longueur de cette ligne (\0 non compris):
	 */
	char			 *	pS_text;	
	int				n_length;		

	/*
	 * ---------------------------------
	 * Contr“le si on fait un backspace:
	 * ---------------------------------
	 */
	if( b_backspace )
	{	/*
		 * D‚place le curseur avant de proc‚der … un DELETE normal:
		 */
		if( n_Pos > 0 )
		{	/*
			 * On va vers la gauche:
			 */
			pTextDrawPar -> n_ColCsr = --n_Pos;
		}
		else
		{	/*
			 * Il faut passer … la ligne pr‚c‚dente:
			 */
			if( l_editLine == 1 )
			{	/*
				 * Si on ‚tait au d‚but du texte:
				 * IMPOSSIBLE de faire un backspace:
				 */
				ping();
				return;
			}

			/*
			 * Passe … la ligne pr‚c‚dente:
			 */
			pTextDrawPar -> l_LigneCsr		 = --l_editLine;
			pTextDrawPar -> pTextLine_edit =	pTextLine_edit = pTextLine_edit -> prev;
			pTextDrawPar -> n_ColCsr		 = n_Pos 			= pTextLine_edit -> length;
		}
	}	/* fin if backspace */


	/*
	 * ---------------------------------------
	 * D‚place la vue courante sur le curseur:
	 * ---------------------------------------
	 */
	move_TextViewToPos( pWiParams, l_editLine, 1, n_Pos, 8 );
	
	/*
	 * Texte & Longueur de cette ligne (\0 non compris):
	 */
	pS_text = pTextLine_edit -> text;	
	n_length = pTextLine_edit -> length;

	/*
	 * Contr“le s'il y a quelque chose … effacer:
	 */
	if( n_Pos < n_length && n_length > 0 )
	{	/*
		 * =================================
		 * Si on peut effacer DANS la ligne:
		 * =================================
		 * Efface le caractŠre:
		 */
		textEdit_delChar( pTextLine_edit, n_Pos );

		/*
		 * R‚affiche la fin de ligne:
		 * Cel… … pour effet secondaire d'‚craser le curseur actuel
		 * et de le r‚afficher … sa nouvelle position:
		 */
		start_WINDRAW( NULL );
		redraw_textline(	pWiParams,
								pTextLine_edit, 
								pTextDrawPar -> l_LigneCsr, 
								n_Pos,
								( (pTextLine_edit -> length) +1 - n_Pos) * (pTextDrawPar -> n_cell_w) + CURSOR_WIDTH );
		end_WINDRAW();

	}	
	else
	{	/*
		 * ========================================================= 
		 * On est en fin de ligne:
		 * On va devoir regroupper cette ligne avec la suivante:
		 * ========================================================= 
		 * Variables Ligne suivante:
		 */
		TEXTLINE	*	pTextLine_next = pTextLine_edit -> next;
		
		if( pTextLine_next == NULL )
		{	/*
			 * Pas de ligne suivante:
			 * IMPOSSIBLE de faire un DELETE:
			 */
			ping();
			return;
		}

		{
		int			n_length_next = pTextLine_next -> length;
		/*
		 * Longueur l qu'on va utiliser: 
		 * 0 < l < Place_Libre
		 */
		int	n_usedLength_next	= 0;
	
		/*
		 * Coordonn‚es de la zone texte:
		 */
		int	n_workXGauche = pWiParams -> work_x;
		int	n_workXDroit  = get_workXDroit( pWiParams );
		int	n_workYHaut	  = pWiParams -> work_y;
		int	n_workYBas	  = get_workYBas( pWiParams );
		/*
		 * Calcule coord pix Y sup‚rieure 
		 * de la premiŠre ligne affich‚e (topline): 
		 */
		int	line_h = pTextDrawPar -> n_cell_h;						/* Hauteur d'une ligne en pixels */
		int	line_y = n_workYHaut 										/* Pos Y sup de la ligne en cours d'affichage (init pourla topline) */
							- line_h + (line_h /TEXT_VMARGINS_LINERATIO) /* Laisse un peu d'espace blanc */
							- (int)((pWiParams -> seen_y) % line_h);		/* Tient compte du fait que la ligne peut ˆtre d‚cal‚e par rapport … son alignement vertical initial */
		/*
		 * Nlles Coordonn‚es du curseur
		 */
		int	n_YHautNextLine; /*	= line_y + (int)(l_editLine - pTextDrawPar->l_topline) * line_h;					
										/*	int	n_CsrYBas	= n_CsrYHaut + line_h -1; */

		BOOL	b_noOverlap;		/* Indique si fenˆtre est overlapp‚e lors du redraw */
	
		if( n_length_next > 0 )
		{	/*
			 * Si la ligne suivante n'est pas vide:
			 */
			int			n_newBufSize;
			
			/*
			 * Longueur l qu'on va utiliser: 
			 * 0 < l < Place_Libre
			 */
			n_usedLength_next	= min( G_def_text_width - n_length, n_length_next );
			
			/*
			 * Nouvelle ligne:
			 */
			n_newBufSize = n_length + n_usedLength_next;

			/*
		 	 * Cr‚e nouvelle ligne:
		 	 */
			pS_text = realloc_String( pS_text, n_newBufSize + 1 );
			memcpy( &(pS_text[ n_length ]), pTextLine_next -> text, n_usedLength_next );
			pS_text[ n_newBufSize ] = '\0';			
			
			/*
			 * IntŠgre nouvelle ligne au texte:
			 */
			pTextLine_edit -> info1.bufsize	= n_newBufSize;
			pTextLine_edit -> length	= n_newBufSize;
			pTextLine_edit -> text		= pS_text;

			/*
			 * V‚rifie si l'ancienne ligne peut ˆtre ‚ffac‚e:
			 */
			if( n_usedLength_next >= n_length_next )
			{
				/*
				 * Si l'ancienne ligne ‚tat une fin de paragraphe: idem
				 * sinon continued...
				 */
				pTextLine_edit -> info1.continued = pTextLine_next -> info1.continued;

				/* 
				 * Toute la ligne a ‚t‚ transf‚r‚e vers le haut:
				 * Efface l'ancienne ligne:
				 */
				delete_line( pTextLine_next, pTextInfo );
				/*
				 * Calcule nlle taille du texte: 
				 */
				calc_textSizeH( pWiParams );

			}
			else
			{
				/* PROVISOIRE: Sinon, elle reste en place... */
	
				/*
				 * La ligne courante se prolonge...
				 */
				pTextLine_edit -> info1.continued = TRUE_1;

			}
		}
		else
		{	/*
			 * La ligne suivante est vide:
			 * Tout ce qu'on a … faire, c'est l'effacer:
			 */
			delete_line( pTextLine_next, pTextInfo );
			/*
			 * Calcule nlle taille du texte: 
			 */
			calc_textSizeH( pWiParams );
		}
			
		/*
		 * D‚but des op‚rations graphiques:
		 * vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		 * R‚serve ‚cran: 
		 */
		b_noOverlap = start_WINDRAW( pWiParams );
	
		/* 
		 * --------------------------
		 * R‚affiche la fin de la ligne en ‚dition:
		 * --------------------------
		 */
		redraw_textline(	pWiParams, pTextLine_edit, 
								l_editLine, n_Pos, 
								n_usedLength_next * ( pTextDrawPar -> n_cell_w ) );
		
		/*
		 * -------------------------------
		 * D‚place les lignes qui suivent:
		 * -------------------------------
		 */
		n_YHautNextLine = line_y + 
					(int)(l_editLine - pTextDrawPar->l_topline + 1) * line_h;
	
		if( b_noOverlap == FALSE0 
			|| n_workYBas - n_YHautNextLine <= line_h
			|| pTextLine_edit == pTextInfo -> lastline )
		{	/*
			 * - La fenˆtre n'est pas en un seul bloc
			 *     ou
			 * - L'espace de scroll est plus petit qu'une ligne!
			 *   -> comme on deplace de la
			 *      hauteur d'une ligne: on n'a rien a scroller!
			 *		 ou
			 * - On vient de supprimer la derniŠre ligne
			 *
			 * => impossible de scroller: 
			 * Affiche toutes les lignes suivant celle qu'on coupe: 
			 */
			redraw( pWiParams, n_workXGauche, n_YHautNextLine,
						 pWiParams -> seen_w, n_workYBas - n_YHautNextLine + 1 , CTRL_OK );
		}
		else
		{	/* 
			 * Si la fenˆtre est au top:
			 * et qu'on est pas sur la derniŠre ligne:
			 * on peut faire scroller la suite du texte:
			 */
			
			graf_mouse( M_OFF, NULL);			/* Efface le ptr souris */

			/* 
			 * Coordonn‚es source, destination: 
			 */
			G_pxyarray[0] = n_workXGauche; 			/* Coord source */
			G_pxyarray[1] = n_YHautNextLine + line_h;
			G_pxyarray[2] = n_workXDroit;
			G_pxyarray[3] = n_workYBas;

			G_pxyarray[4] = n_workXGauche;			/* Coord destination */
			G_pxyarray[5] = n_YHautNextLine;
			G_pxyarray[6] = n_workXDroit;
			G_pxyarray[7] = n_workYBas - line_h;

			/* 
			 * D‚placement d'un bloc vers le HAUT sur l'‚cran logique: 
			 */
			vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray,
						  &G_plogMFDB, &G_plogMFDB);
		
		
			graf_mouse( M_ON, 0);				/* Affiche le ptr souris */


			/*
			 * Affiche ce qui n'a pas encore ‚t‚ trait‚ par scroll: 
			 */
			redraw( pWiParams, 
						n_workXGauche, 
						n_workYBas - line_h + 1 ,
						pWiParams -> seen_w, 
						line_h ,
						CTRL_OK );

		}
	
	
		/*
		 * Fin des op‚rations graphiques:
		 * LibŠre l'‚cran:
		 */
		end_WINDRAW();

		/*
		 * ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		 */
		
		/*
		 * Fixe nlle taille et position ascenseur: 
		 */
		set_slider_h( pWiParams );			/* Fix taille slider vertical */
		set_slider_y( pWiParams );			/* Fix position slider vertical */
		}
	}		
	
	/*
	 * Signale … la fenˆtre que son contenu a ‚t‚ modifi‚:
	 */
	Wnd_SetModified( pWiParams );
}



/*
 * winEdit_BreakLine(-)
 *
 * Purpose:
 * --------
 * Coupe une ligne … l'endroit du curseur suite … pression sur return.
 *
 * Suggest:
 * --------
 * ComplŠtement inachev‚, plein de bugs!
 * scroll du bas de la fenˆtre
 *
 * History:
 * --------
 * 13.06.94: fplanque: Created base on _DelCar()
 * 14.06.94: fplanque: D‚place fenˆtre sur curseur avant d'agir.
 * 14.06.94: aprŠs insertion: maj ascenseur vert & redraw lignes suivantes
 * 17.06.94: impl‚mentation scrolling
 * 18.06.94: optimisation graphique + gestion des effacements/redraws curseur
 * 08.01.95: corrig‚ bug lorsqu'on breake en bas de la fenˆtre
 */
void	winEdit_BreakLine(
			WIPARAMS *	pWiParams )
{
	TEXT_DRAWPAR *	pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;
	TEXTINFO		 * pTextInfo = pTextDrawPar -> pTextInfo;
	/*
	 * Colonne du curseur:
	 */
	int				n_Pos = pTextDrawPar -> n_ColCsr;
	/* 
	 * Ligne en cours d'‚dition; porte le curseur:
	 */
	long				l_editLine = pTextDrawPar -> l_LigneCsr;
	TEXTLINE		 *	pTextLine_edit = pTextDrawPar -> pTextLine_edit;
	char			 *	pS_text = pTextLine_edit -> text;	
	char			 * pS_CarPos = &( pS_text[ n_Pos ] );
	/*
	 * Nouvelle ligne:
	 */
	TEXTLINE		* pTextLine_new;
	char			* pS_newText;

	/*
	 * Coordonn‚es de la zone texte:
	 */
	int	n_workXGauche = pWiParams -> work_x;
	int	n_workXDroit  = get_workXDroit( pWiParams );
	int	n_workYHaut	  = pWiParams -> work_y;
	int	n_workYBas	  = get_workYBas( pWiParams );
	/*
	 * Calcule coord pix Y sup‚rieure 
	 * de la premiŠre ligne affich‚e (topline): 
	 */
	int	line_h = pTextDrawPar -> n_cell_h;						/* Hauteur d'une ligne en pixels */
	int	line_y;
	
	int	n_CsrYHaut;

	/*
	 * Affichages:
	 */	
	int	n_eraseLength;		/* Longueur de ligne … effacer */
	BOOL	b_noOverlap;		/* Indique si fenˆtre est overlapp‚e lors du redraw */
	

	/*
	 * -----------------------------------------
	 * Place la fenˆtre sur l'endroit du curseur
	 * Note: le curseur va descendre d'une ligne au cours du break.
	 *       il ne doit donc pas ˆtre sur la ligne du bas de la fenˆtre
	 *       sinon il faudrait RE-SCROLLER!
	 * -----------------------------------------
	 */
	move_TextViewToPos( pWiParams, l_editLine, 2, 0, 1 );

	/*
	 * ------------------------------------
	 * Contr“le si la ligne n'est pas vide:
	 * ------------------------------------
	 */
	if( pS_text != NULL )
	{	/*
		 * S'il y a du texte … casser:
		 */		
		pS_newText = STRDUP( pS_CarPos );	/* Duplique fin de ligne */
		*pS_CarPos = '\0';						/* Coupe la ligne d'origine */
		n_eraseLength = pTextLine_edit -> length - n_Pos;	/* Longueur … effacer */
		pTextLine_edit -> length = n_Pos; 	/* Nouvelle longueur de ligne */
	}	
	else
	{	/*
		 * Rien … couper!
		 * On cr‚e donc simplement une ligne vide.
		 */
		pS_newText = NULL;
		n_eraseLength = 0;		/* Longueur … effacer */
	}

	
	/*
	 * Cr‚ation/Insertion d'une nouvelle ligne;
	 */
	pTextLine_new = insert_line( pTextLine_edit, pS_newText, NIL, pTextInfo );
	/*
	 * Calcule nlle taille du texte: 
	 */
	calc_textSizeH( pWiParams );


	/*
	 * ----------------
	 * D‚place curseur:
	 * ----------------
	 */
	pTextDrawPar -> pTextLine_edit = pTextLine_new;
	pTextDrawPar -> l_LigneCsr = ++l_editLine;
	pTextDrawPar -> n_ColCsr = 0;


	/*
	 * D‚but des op‚rations graphiques:
	 * vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	 * R‚serve ‚cran: 
	 */
	b_noOverlap = start_WINDRAW( pWiParams );

	/* 
	 * --------------------------
	 * Efface la fin de l'ancienne ligne en ‚dition:
	 * --------------------------
	 * R‚affiche la fin de ligne:
	 * Cela a pour effet secondaire d'‚craser le curseur actuel
	 * et de le r‚afficher … sa nouvelle position:
	 */
	redraw_textline(	pWiParams, pTextLine_edit, 
							l_editLine - 1, n_Pos,
							n_eraseLength * ( pTextDrawPar -> n_cell_w )  );
	

	/*
	 * -------------------------------
	 * D‚place les lignes qui suivent:
	 * -------------------------------
	 * Nouvelles Positions texte & curseur:
	 */
	line_y = n_workYHaut 										/* Pos Y sup de la ligne en cours d'affichage (init pourla topline) */
						- line_h + (line_h /TEXT_VMARGINS_LINERATIO) /* Laisse un peu d'espace blanc */
						- (int)((pWiParams -> seen_y) % line_h);		/* Tient compte du fait que la ligne peut ˆtre d‚cal‚e par rapport … son alignement vertical initial */
	n_CsrYHaut	= line_y + 
						(int)(l_editLine - pTextDrawPar->l_topline) * line_h;

	if( b_noOverlap == FALSE0 )
	{	/*
		 * La fenˆtre n'est pas en un seul bloc: 
		 * impossible de scroller: 
		 * Affiche toutes les lignes suivant celle qu'on coupe: 
		 */
		redraw( pWiParams, n_workXGauche, n_CsrYHaut,
					 pWiParams -> seen_w, n_workYBas - n_CsrYHaut + 1 , CTRL_OK );
	}
	else
	{	/* 
		 * Si la fenˆtre est au top: on peut la faire scroller: 
		 */
		int	n_min_length = 0;		/* Par d‚faut: il n'y a rien … ‚craser en dessous... */
		 
		/* 
		 * Teste s'il y a quelque chose … scroller:
		 */
		if( pTextLine_new != pTextInfo -> lastline )
		{	/*
			 * On ne vient pas de cr‚er la derniŠre ligne,
			 * donc il y a d'autres lignes en dessous, qu'il faut 
			 * maintenant scroller: 
			 */
			if( n_CsrYHaut + line_h <= n_workYBas ) 
			{	/*
				 * En plus, il y a de la place pour scroller:
				 */
				
				graf_mouse( M_OFF, NULL);			/* Efface le ptr souris */
	
				/* 
				 * Coordonn‚es source, destination: 
				 */
				G_pxyarray[0] = n_workXGauche; 			/* Coord source */
				G_pxyarray[1] = n_CsrYHaut;
				G_pxyarray[2] = n_workXDroit;
				G_pxyarray[3] = n_workYBas - line_h;
	
				G_pxyarray[4] = n_workXGauche;			/* Coord destination */
				G_pxyarray[5] = n_CsrYHaut + line_h;
				G_pxyarray[6] = n_workXDroit;
				G_pxyarray[7] = n_workYBas;
	
				/* 
				 * D‚placement d'un bloc vers le bas sur l'‚cran logique: 
				 */
				vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray,
							  &G_plogMFDB, &G_plogMFDB);
			
				graf_mouse( M_ON, 0);				/* Affiche le ptr souris */
			}
			
			/*
			 * Longueur de la ligne suivante
			 * = longueur qu'on va devoir ‚craser
			 */
			n_min_length = pTextLine_new -> next -> length; 
		}
	
		/*
		 * Affiche la nouvelle ligne:
		 * Prendre contr“le de l'‚cran!
		 */
		redraw_textline(	pWiParams, pTextLine_new, 
								l_editLine, 0, 
								n_min_length * ( pTextDrawPar -> n_cell_w ) );
	}


	/*
	 * Fin des op‚rations graphiques:
	 * LibŠre l'‚cran:
	 */
	end_WINDRAW();
	/*
	 * ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	 */


	/*
	 * Fixe nlle taille et position ascenseur: 
	 */
	set_slider_h( pWiParams );			/* Fix taille slider vertical */
	set_slider_y( pWiParams );			/* Fix position slider vertical */

	/*
	 * Signale … la fenˆtre que son contenu a ‚t‚ modifi‚:
	 */
	Wnd_SetModified( pWiParams );
}

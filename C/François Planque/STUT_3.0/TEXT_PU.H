/*
 * text_Public.h
 *
 * Purpose:
 * --------
 * Structures et constantes necessaires au stockage
 * ainsi qu'… l'‚dition et l'affichage de textes
 * sous GDOS/VDI
 *
 * Suggest:
 * --------
 * Separer en deux modules distincts
 *
 * History:
 * --------
 * 1993: Created by fplanque
 */
  
/*
 * V‚rifie si les pr‚sentes d‚finitions ont d‚ja ‚t‚ faites:
 */
#ifndef TEXT_PU_H
#define TEXT_PU_H


#include "DFSTRUCT.H"
#include "GEMWDEF.H"


/*
 * Buffer INT_IN:                  
 *
 * Purpose:
 * --------
 * Voir dans AES.H   ??
 */
#define	INT_IN_SIZE				128				

/*
 * Largeur par d‚faut d'une fenˆtre d'‚dition de texte:
 */
#define	DEF_TEXT_WIDTH			60

/*
 * Largeur du curseur ds une fenˆtre texte:
 */
#define	CURSOR_WIDTH			2

/*
 * Nombre de caractŠres qu'on ajoute au buffer d'‚dition d'une ligne …
 * chaque fois que c'est n‚cessaire:
 */
#define	BUFFER_INCREASE_STEP	40

/*
 * Modes de formattage d'un texte compact:
 */
enum
	{
		FMTMODE_NEARBINARY,		/* Cars <32 affich‚s sauf 0, Ý:CR/LF */
		FMTMODE_REZO,				/* N'accŠpte que les cars l‚gaux. Ý:CR */
		FMTMODE_SGLETEXTLINE		/* N'accŠpte que les cars l‚gaux. PAS DE CHANGEMENT DE PARAGRAPHE; tous cars >= 32 */
	};

/*
 * Alignements du texte ds une fenˆtre GEM:
 */
	#define	TEXT_VMARGINS_LINERATIO		3		/* 1/3 de ligne de blanc au dessus et en dessous du texte */
	#define	TEXT_VBOTTOM_COMPENSATE		1		/* 1 pixel de plus ds la marge du bas */
	#define	TEXT_HMARGINS_WIDTH			4		/* 4 pixels de blanc …gauche et … droite du texte */

/* 
 * Tailles des polices de caractŠres:
 */
#define	DEFNB_TEXTSIZES	20		/* 20 Tailles au max par d‚faut */
#define	DEF_MAXSIZE			40		/* Taille max pard‚faut */
                                    

/*
 * D‚finit une taille de texte
 */                                    
typedef
	struct		
	{
		int		points;			/* Taille en "points" */
		int		char_h;			/* Hauteur du caractŠre */
		int		cell_w;			/* Largeur de l'emplacement */
		int		cell_h;			/* Hauteur de l'emplacement */
	}
	TEXTSIZE_DEF;
	
/* 
 * Vdi array(s) definition:
 *
 * Purpose:
 * --------
 * ???
 */
typedef
	struct
	{
		int	font;							/* No de la fonte */
		int	color;						/* Couleur du texte */
		int	angle;						/* Angle d'ecriture */
		int	justify;						/* Justification horizontale */
		int	ref_line;					/* Ligne de r‚f‚rence */
		int	mode;							/* Mode d'‚criture? */
		int	char_w;						/* Largeur caractŠre */
		int	char_h;						/* Hauteur caractŠre */
		int	cell_w;						/* Largeur emplacement */
		int	cell_h;						/* Hauteur emplacement */
	/* Suppl‚mentaire: */
		int	points;						/* Taille en points... */
	}
	VDI_TEXT_PARAMS;

/*
 * ---------------------- MEMBRES PUBLICS --------------------------
 */

	extern	VDI_TEXT_PARAMS	G_std_text;	/* ParamŠtres du texte standard */	


/*
 * ----------------------- Functions ---------------------------
 */


	void init_text( void );

	int	save_text2datapage( 			/* In: FALSE0 si ‚chec sauvegarde */
					TEXTINFO *	pTextInfo,		/* In: Ptr sur texte … sauver */
					DATAPAGE	*	pDataPage );	/* In: Datapage ds laquelle il faut sauver */


	TEXTINFO *	create_TextInfo( void );	/* out: Ptr sur TEXTINFO cr‚e */
	TEXTLINE * TextLine_CreateStandAlone(	/* Out: TEXTLINE cr‚‚e */
					int 	bufsize );			/* In:  Taille buffer  */ 
	void TextLine_Clear(
			TEXTLINE	*	pTextLine ); /* In: Ligne … vider */
	TEXTLINE	*	insert_line( 
								TEXTLINE *prev_line, 
								char *texte, 
								int bufsize, 
								TEXTINFO *info_ptr );

	TEXT_DRAWPAR *	create_TextDrawPar( 				/* Out: Ptr sur infos d'affichage g‚n‚r‚es */
						TEXTINFO *	pTextInfo,		/* In:  Ptr sur texte … afficher */
						long			l_nbLinesMax );/* In:  Nbre max de lignes qu'on veut garder en m‚moire (pour les logs, pas pour les ‚ditables) */
	void	add_textinf( 
			WIPARAMS * pWiParams, 
			const char * inf );
	void	text_addLineToEnd(
			TEXTINFO		*	pTextInfo,		/* In: Texte concern‚ */
			const char	*	cpsz_Text );	/* In: Ligne … dupliker et ins‚rer */



	extern	TEXTINFO *	create_justified_text( 
									char		*	p_text,
									size_t 		size_text,
									int			max_line_len );
	extern	TEXTINFO	* create_textedit_zone( void );	/* Out: B */
	extern	void	free_formatext( TEXTINFO *textinfo );
	extern	void	add_textinf( WIPARAMS * wi_params_adr, const char * inf );
	extern	void	complete_textinf( WIPARAMS * wi_params_adr, const char * inf );

	void	params_texte( 
			const GRECT *start_box );

	/* affichage */
	void	calc_textSizeW( 
							WIPARAMS  *	pWiParams );
	void	calc_textSizeH( 
							WIPARAMS  *	pWiParams );



	void	free_formatext( 
							TEXTINFO *textinfo );

	int	create_debugtext( 
							TEXT_DRAWPAR * *	ppTextDrawPar );
	int	charge_texte( 
							TEXT_DRAWPAR  * * ppTextDrawPar );
	int	access_text( 
							DATAPAGE *datapage, 
							WORK_CONTENT *content_ptr, 
							TEXT_DRAWPAR * *ppTextDrawPar_retour );		/* Out: */
	void	format_text( 
							TEXTINFO *	textinfo, 			/* In: Zone d'infos pour texte formatt‚ */
							TEXTLINE *	start_line,			/* In: Ligne … laquelle il faut ins‚rer le texte qu'on va formatter */
							char		*	text_adr,			/* Ptr sur texte compact en m‚moire */
							size_t 		text_length,		/* Longueur de ce texte compact */
							int			mode, 				/* In: mode de reconnaissance */
							int			max_line_len );	/* In: Longueur maximale d'une ligne */
	void	delete_line( 
							TEXTLINE *	pTextLine, 		/* In: Ligne … supprimer */
							TEXTINFO	*	pTextInfo );	/* In: Texte ds lequel on efface */

	/* -- representation ram -- */
	void	create_newText( 
			GRECT *start_box );

	void	sauve_texte( 
							TEXTINFO *	pTextInfo );	/* In: Ptr sur texte … sauver */

	BOOL	text_IsFilled(
			TEXTINFO	* pTextInfo );

	size_t	compact_text(							/* Out: Longueur du texte compact */
				TEXTLINE	*	pTextLine_First,	/* In: 1Šre ligne … compacter */
				int			mode,					/* In: FNTMODE_REZO ou FMTMODE_NEARBINARY */
				char		**	ppBuf_compact );	/* In: adr Buffer contenant texte compact */
	void	textEdit_addChar( 
							TEXTLINE *	pTextLine,		/* In: Ligne a ‚diter */
							int			n_col,			/* In: Car … effacer [0..] */
							char			c_car,			/* In: CaractŠre … ins‚rer */
							int			n_maxlen );		/* In: Longueur maximale d'une ligne */
	void	textEdit_delChar( 
							TEXTLINE *	pTextLine,		/* In: Ligne a ‚diter */
							int			n_col );			/* In: Car … effacer [0..] */

	/* -- affichage -- */
	void open_text( 
						WIPARAMS 	 *	pWiParams, 
						TEXT_DRAWPAR *	pTextDrawPar );
	void	vmove_text(
							WIPARAMS *pWiParams, 
							unsigned long new_pos );

	/* -- edition -- */
	void	winEdit_ProcessKey(
							WIPARAMS *	pWiParams,		/* In: fenˆtre concern‚e */ 
							unsigned		u_kbd_state,	/* In: Etat des touches sp‚ciales */
							int			n_ScanCode,		/* In: ScanCode touche press‚e */
							char			c_car );			/* In: CaractŠre correspondant */

	void text_optimal( 
		int wi_ckind, 
		int *border_x, 
		int *border_y, 
		int *border_w, 
		int *border_h);


/*
 * Fin du test anti red‚finition:
 */
#endif

/*
 * ramselec.c
 *
 * Purpose:
 * --------
 * Gestion de S‚lecteurs d'objets 
 * - op‚rant sur des objets en m‚moire vive (non pas sur disque)
 *		- 
 * - op‚rant sur une/deux liste(s) textuelle(s) avec boutons d'action
 * 	- select_in_list()
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"RAMSELEC.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
	#include	<string.h>					/* strcpy() etc.. */
	#include	<aes.h>						/* header AES */
   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "STUT_ONE.RSC\STUT_3.H"					/* noms des objets ds le ressource */
	#include	"TEXT_PU.H"						/* Params texte */
	#include	"RAMSL_PU.H"		/* ListHandles */

/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * EXTernal prototypes:
 */
	/* 
	 * Datas: 
	 */
	extern	int	count_pages( DATADIR *datadir );
	/* 
	 * Traitement des objets AES: 
	 */
	extern	void	rsrc_color( OBJECT *tree );
	extern	GRECT	* objc_xywh ( OBJECT *tree, int objc, GRECT *frame );
	extern	char	*strBchr( char *string, char chr );  /* Sp‚cial FP */
	extern	char	*extract_fmtFtext( OBJECT *tree, int obj );
	extern	void	fix_fmtFtext( OBJECT *tree, int obj, const char	*ftext );
	extern	void	maptree( OBJECT *tree, int this, int last, int (*routine)( OBJECT *tree, int tmp1 ) );
	extern	void	objc_dsel( OBJECT *tree, int obj );
	extern	void	objc_clrsel(  OBJECT *tree, int obj );
	extern	void	objc_setsel(  OBJECT *tree, int obj );
	extern	void	open_dialog( OBJECT *dialog, const GRECT *little_box, GRECT *big_box );
	extern	void	close_dialog( OBJECT *dialog, int exit_obj, const GRECT *little_box, const GRECT *big_box );
	extern	GRECT	* objc_xywh ( OBJECT *tree, int objc, GRECT *frame );
	extern	dlink_teptext ( OBJECT *objc_adr, const char *texte );
	extern	rlink_teptext ( OBJECT *objc_adr, const char *texte );
	/* 
	 * Form_do: 
	 */
	extern	int	ext_form_do( OBJECT *tree, int *startfield );
	extern	void	extform_lastmpos( int *mx, int *my );
	/* 
	 * Sp‚cial: 
	 */
	extern	void	ping ( void );
	extern	int	min( int a, int b );
	extern	int	max( int a, int b );
	/* 
	 * G‚n‚ral: 
	 */
	extern	void erreur_rsrc( void );



/*
 * PRIVate INTernal prototypes:
 */
	static int	ramselect_actions( LISTHANDLES *list_handles, int	obj );
	static void	ramsel_fixstate_act(					/* Out: Rien */
				LISTHANDLES *list_handles );	/* In: Ptr sur infos sur la liste & le dialogue affich‚s */

	static void	fix_pos_asc( LISTHANDLES *list_handles, long scsr_range, int top_item, int top_range );
	static void	redraw_list( LISTHANDLES *list_handles );
	static int	reperes_sel( OBJECT *form_tree, int obj );
	static void	fixe_liste( LISTHANDLES *list_handles, int first_page, int first_line, int nb_lines );
	static void	enable_list( LISTHANDLES *list_handles, int used_lines );
	static void move_selected_line( 					/* Out: Rien */
			LISTHANDLES *list_handles,		/* In: Ptr sur infos sur la liste & le dialogue affich‚s */
			int	move );						/* In: D‚placement en nbre de lignes */



/*
 * ------------------------ VARIABLES -------------------------
 */
    
/*
 * Private variables: 
 */
	static	OBJECT		*M_ramselect_adr;	/* Ptr sur s‚lecteur des fichiers en RAM */
	static	LISTHANDLES	M_maptree_vars;	/* Variables globales pour MAPTREE */
	static	int			M_init_text;		/* Initialisation du texte en cours? */
	 
/*
 * ------------------------ FUNCTIONS -------------------------
 */


/*
 * --------------- SELECTION D'OBJETS EN RAM ---------------
 */



/*
 * init_ramselect(-)
 *
 * Purpose:
 * --------
 * Init du selecteur d'objets en RAM
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	init_ramselect( void )
{
	if (rsrc_gaddr( R_TREE, RAMSELEC, &M_ramselect_adr) == 0)
		erreur_rsrc();

	rsrc_color( M_ramselect_adr );		/* Fixe couleurs */

}

/*
 * ramselect_fromForm(-)
 *
 * Purpose:
 * --------
 * S‚lection d'un "OBJET" en RAM
 * depuis un autre formulaire
 *
 * Algorythm:
 * ----------  
 * s'occupe en particulier de r‚afficher le formulaire du dessous
 *
 * History:
 * --------
 * 01.09.94: fplanque: Created
 */
RAMSEL ramselect_fromForm( 		/* Out:	r‚sultat de la s‚lection: RAMSEL_ABORT, RAMSEL_PATH ou RAMSEL_FILE */
			char 		 *	sel_titre, 	/* In: 	S‚lection du titre */
			DATAGROUP *	datagroup, 	/* In: 	DataGroup dans lequel on effectue la s‚lection */
			char 		**	sel_page, 	/* Out:	Adresse du TAMPON ds lequel se trouve le path du fichier s‚lectionn‚ */
			OBJECT 	 *	arbre_fond, /* In:	Dialogue depuis lequel on appelle le s‚lecteur de fichiers */
			int			call_obj )	/* In:	No de l'objet qui a appell‚ le s‚lecteur depuis le dialogue de fond */
{
	GRECT		start_box, form_box;
	RAMSEL	resultat;
	
	/*
	 * Coord de d‚part du grow_box= 
	 */
	objc_xywh( arbre_fond, call_obj, &start_box );

	/*
	 * Appel s‚lecteur:
	 */
	resultat = ramselect( sel_titre, datagroup -> root_dir , sel_page, &start_box, &form_box );
	
	/* 
	 *	Red‚ssinne le fond: 
	 */
	objc_draw( arbre_fond, 0, 5, form_box .g_x, form_box .g_y, form_box .g_w, form_box .g_h );

	/*
	 * Retourne info sur s‚lection 
	 */
	return 	resultat;			/* =0 si on a annul‚ */
	
}



/*
 * ramselect(-)
 *
 * Purpose:
 * --------
 * S‚lection d'un "OBJET" en RAM
 * Un peu … la maniŠre de STUT ONE version 2
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 04.01.94: nouveau format d'appel de select_in_list()
 * 01.09.94: introduction des constantes RAMSEL_...
 * 02.09.94: la s‚lection se fait maintenant dans un DATADIR!
 */
RAMSEL ramselect( 						/* Out:	r‚sultat de la s‚lection: RAMSEL_ABORT, RAMSEL_PATH ou RAMSEL_FILE */
			char 		 *	sel_titre, 		/* In: 	S‚lection du titre */
			DATADIR	 * pDataDir,		/* In:	Datadir ds lequel on effectue la s‚lection */
			char 		**	sel_page, 		/* Out:	Adresse du TAMPON ds lequel se trouve le path du fichier s‚lectionn‚ */
			GRECT		 * pGRect_start,	/* In: 	D‚but ouverture */
			GRECT		 * pGRect_form)	/* Out:	copie ds ce GRect les coords du s‚lecteur */
{
	/*
	 * DataGroup dans lequel on effectue la s‚lection 
	 */
	DATAGROUP *	pDataGroup = pDataDir -> pDataGroup;

	int			i,nb_pages;
	char			* *name_array;		/* Tableau contenant les noms des pages */
	DATAPAGE		*page_ptr;
		
	/*
	 * Variables d'‚dition: 
	 */
	static int	esc_objs[]={ RSELVALI, RSELANNU, NIL };
	char		*sel_sel = (M_ramselect_adr[ RSELSEL ] .ob_spec.tedinfo) -> te_ptext;
	int		exit_obj;
	/*
	 * Pas de s‚lection pour l'instant:
	 */
	RAMSEL	resultat = RAMSEL_ABORT;	
	/*
	 * Tampon de path, dont l'adresse sera aussi renvoy‚e … l'appellant: 
	 */
	static char		sel_path[ RAMPATH_MAXLEN ];	/* Longueur pour 10 dossiers + nom de fichier */
	
	/*
	 * Init titre: 
	 */
	dlink_teptext( &M_ramselect_adr[ RSELTITR ], sel_titre );	/* Titre du s‚lecteur */
	/*
	 * Init s‚lection: 
	 */
	*sel_sel = '\0';
	/*
	 * Init path de s‚lection: 
	 */
	strcpy( sel_path, pDataGroup -> data_device );	/* Copie par exemple "ARB:" */
	strcat( sel_path, "\\*.*" );							/* Rajoute masque de s‚lection */
	rlink_teptext ( &M_ramselect_adr[ RSELPATH ], sel_path );	/* Place ds formulaire */
	*sel_page = sel_path;	/* La fonction appellante aura ainsi accŠs … ce tampon */		

	/*
	 * Cr‚ation de la liste (fonctions & chemins d'accŠs): 
	 * Compte pages: 
	 */
	nb_pages = count_pages( pDataDir );
	/*
	 * Cr‚e zones de stockage: 
	 */
	if ( nb_pages )
	{	/*
	 	 * S'il y a des pages: 
		 * Cr‚e zone: 
		 */
		name_array = (char * *) MALLOC( sizeof( char* ) * nb_pages );
		/*
		 * Remplit tableau: 
		 */
		page_ptr = pDataDir -> data_start;	/* Adr 1Šre page */
		for ( i=0; i<nb_pages; i++ )
		{
			name_array[ i ] = page_ptr -> nom;
			page_ptr = page_ptr -> next;	/* Passe sur la page suivante */
		}
	}
	else
	{	/*
		 * Si aucune page: 
		 */
		name_array = NULL;
	}
	
	/* 
	 * Gestion formulaire: 
	 */
	exit_obj = select_in_list( 
						M_ramselect_adr, 
						pGRect_start, 
						pGRect_form,
						&name_array, 
						&nb_pages,
						esc_objs, 
						ramselect_actions, 
						ramsel_fixstate_act,
						RSELSEL);
						
	/*
	 * LibŠre listes: 
	 */
	if( name_array != NULL );
	{
		FREE( name_array );
	}
		
	if ( exit_obj == RSELVALI )
	{	/*
		 * Si on a valid‚: 
		 * Il faut copier le nom du fichier s‚lectionn‚ … la fin du path: 
		 */
		char	*path_end = strBchr( sel_path, '\\' );	/* Cherche dernier Backslash */
		char	*file_name = extract_fmtFtext( M_ramselect_adr, RSELSEL ); /* Nom du fichier */

		strcpy( path_end +1, file_name );	/* Ecrase fin du path (style "*.*") par le nom du fichier s‚lectionn‚ */

		/*
		 * Teste si on a s‚lectionn‚ un fichier: 
		 */
		if( strlen( file_name ) )
		{
			resultat = RAMSEL_FILE;		/* Oui */
		}
		else
		{
			resultat	= RAMSEL_PATH;		/* Non, mais on a qd mˆme s‚lectionn‚ un chemin d'accŠs */
		}
		FREE( file_name );				/* C'‚tait une chaine temporaire */
							
	}

	/*
	 * Retourne info sur s‚lection 
	 */
	return 	resultat;			/* =0 si on a annul‚ */
}


/*
 * ramselect_actions(-)
 *
 * Purpose:
 * --------
 * Traitement des objets exit du formulaire-s‚lecteur d'objets pr‚c‚dent
 *
 * Suggest:**
 * --------
 * Au niveau de l'int‚grit‚ fonctionnelle: il serait judicieux
 * de mettre le traitement du clic sur un elt de la liste dans une
 * fonctions appell‚e directement par select_in_list()
 * ici on traite avant tout les boutons d'ACTION
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	ramselect_actions( 
			LISTHANDLES *	list_handles, 
			int 				obj )
{
	if( obj & SEL_LINE )
	{	/*
		 * Si on a cliqu‚ sur un nom 
		 */
		GRECT		box;
		unsigned	u_DblClick = obj & DBLE_CLICLK;
		obj &= SEL_OBJC_NO;		/* EnlŠve bits 14 et 15 */

		/*
		 * Copie chaine: 
		 */
		fix_fmtFtext( M_ramselect_adr, RSELSEL, (M_ramselect_adr[ obj ] .ob_spec.tedinfo) -> te_ptext );

		/*
		 * R‚affiche: 
		 */
		objc_xywh( M_ramselect_adr, RSELSEL, &box );
		objc_draw( M_ramselect_adr, RSELSEL, 1, box .g_x, box .g_y, box .g_w, box .g_h );

		if( u_DblClick )
		{	/*
		    * Si on a double cliqu‚ sur un nom:
			 * Il faut signaler que c'est une confirmation
			 */
			return	RSELVALI;	/* met fin au dialogue: confirmation */
		}
	}
	else
	{
		switch( obj )
		{
			case	RSELVALI:
			case	RSELANNU:
				return	obj;	/* Met fin au dialogue */
				
			default:
			
				FAKE_USE( list_handles );
			
				ping();
		}
	}
	
	
	return	TRUE_1;			/* Continue le dialogue */
}


/*
 * ramsel_fixstate_act(-)
 *
 * Purpose:
 * --------
 * Ne fait rien, mais il nous faut l'adresse de cette func 
 * lors du transfert de paramŠtres vers select_in_list()
 * Cette fonction POURRAIT servir … allumer/eteindre les boutons d'action
 * du selecteur RAM s'il y en avait (genre "INFO sur l'objet s‚lectionn‚)
 *
 * History:
 * --------
 * 04.01.94: fplanque: Created
 */
void	ramsel_fixstate_act(					/* Out: Rien */
			LISTHANDLES *list_handles )	/* In: Ptr sur infos sur la liste & le dialogue affich‚s */
{
	FAKE_USE( list_handles -> form_tree );	 
}


/*
 * --------------- SELECTION D'OBJETS DANS UNE LISTE ---------------
 */



/*
 * select_in_list(-)
 *
 * Purpose:
 * --------
 * Gestion d'un formulaire de s‚lection/action
 * pr‚sentant une liste textuelle dot‚e d'un ascensceur de d‚filement
 *
 * Notes:
 * ------
 * Il y a deux listes parallŠles:
 *  - "fnct": non s‚lectionnables (juste informatifs)
 *  - "path": s‚lectionnables -> activant les boutons d'action
 *
 * Suggest:
 * --------
 * -esc_objs: ces objets pourraient ˆtre trouv‚s automatiquement par un
 * walk tree de la mˆme maniŠre que les elements constituants et
 * manipulateurs de la liste.
 * 04.01.94: v‚rifier si la variables selected_line en LOCAL duplicata
 * de la var ds list_handles est bien utile... et rentable.
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 04.01.94: Modif des actions … effectuer lors du click sur une ligne de la liste
 * 04.01.94: M‚mo d'un ptr sur fixstat_act() afin de pouvoir ‚teindre les boutons d'actions depuis move_selected_line()
 * 05.01.94: nb_items est d‚sormais re‡u par adresse: on renvoie ainsi le nouveau nbre de lignes de la liste si elle a ‚t‚ modifi‚e
 * 04.12.94: ne gŠre plus qu'une seule liste
 * 07.01.95: gŠre les doubles clicks; allumage des boutons d'action aprŠs changement liste
 */
int	select_in_list( 
			OBJECT 		*	form_tree, 		/* In: Arbre d'obj: boite de dialogue … afficher */
			const GRECT *	start_box, 		/* In: Coord d‚part de l'effet graphique d'ouverture/fermeture */
			GRECT 		*	form_box, 		/* Out: Coord boite de dialog … l'‚cran */
			char 		* * *	path_array, 	/* In/Out: Adr d'un ptr sur table "path" */
			int 			*	nb_items,		/* In: Nbre d'‚l‚ments de la liste */
			int 			*	esc_objs, 		/* In: Ptr sur tableau contenant la
													 * liste des bouton d'action: ttmnt sp‚cial 
													 */
			int (*actions)(LISTHANDLES *list_handles, int obj),
													/* In: Ptr sur fonction … appeler 
													 * pour traiter les boutons d'action
													 */
			void (*fixstate_act)(LISTHANDLES *list_handles),
													/* In: Ptr sur fonction … appeler
													 * pour allumer/eteindre les boutons d'action
													 */
			int edit_obj )						/* In: Obj sur leql se situe le csr en d‚but d'‚dition */
{
	/* 
	 * Variables concernant le dialogue: 
	 */
	LISTHANDLES	list_handles;			/* Objets de manipulation de la liste */
	int		nb_elts = *nb_items;		/* Nbre d'‚lements total de la liste */
	int		nb_lines;					/* Nombre de lignes du s‚lecteur */
	int		used_lines;					/* Nombre de lignes utilis‚es */
	int		exit_obj;					/* Objet de sortie */
	int		continuer = TRUE_1;			/* A priori, on continue le dialogue */
	int		i, obj;						/* Objet trait‚ */
	int		selected_line = NIL;		/* Ligne s‚lectionn‚e en ce moment */
	int		sbar_height;				/* Taille cage d'ascenseur */
	int		scsr_height;				/* Taille curseur d'acscenseur */
	long		scsr_range;					/* Latitude de mouvement de l'asc */
												/* Long pour forcer les calculs sans perte */
	int		top_item = 0;				/* Element du haut */
	int		top_range;					/* Latitude de mouvement de l'objet du haut */
	unsigned	u_DblClick;

	/* 
	 * Initialisation de l'arbre: 
	 */
	M_init_text = FALSE0;			/* On est pas en train d'initialiser */
	maptree( form_tree, ROOT, NIL, reperes_sel );


	/* 
	 * Sauve variables globales en locales pour autoriser la r‚cursivit‚: 
	 */
	list_handles = M_maptree_vars;
	/* 
	 * Les variables suivantes sont ajout‚es pour r‚duire 
	 * le nombre de paramŠtres … transmettre aux fonctions 
	 */
	list_handles .form_tree = form_tree;	/* Ajoute adr de l'arbre d'objets */
	list_handles .pTpsz_array = path_array;	/* Ajoute adr du ptr sur tabl noms */
	list_handles .nb_items = nb_elts;		/* Nbre d'elts de la liste */
	list_handles .fixstate_act = fixstate_act;	/* Ptr sur func qui fixe ‚tat des boutons d'actions */

	/* 
	 * Calculs: 
	 */
	nb_lines = list_handles .last_name - list_handles .first_name +1;	/* Nbre de lignes dispo ds le s‚lecteur */
	used_lines = min(	nb_lines, nb_elts );	/* Nre de lignes r‚ellement utilis‚es */
	top_range = nb_elts - used_lines;			/* Lattitude de mvt du haut de la liste */


	/*
	 * Init liste: 
	 */
	fixe_liste( &list_handles, top_item, 0, used_lines );
	enable_list( &list_handles, used_lines );		/* Disable des lignes vides */

		
 	/* 
 	 * Taille ascenseur: 
 	 */
	sbar_height = form_tree[ list_handles .slide_bar ] .ob_height;
	if	( nb_elts > nb_lines )		/* Si tous les elts ne peuvent ˆtre affich‚s simultan‚ment */
	{	/* 
		 * Calcule dimension asc en imposant une hauteur minimale de 1 caractŠre 
		 */
		scsr_height = max( G_std_text .cell_h, sbar_height * nb_lines / nb_elts);
	}
	else
	{	/* Si moins d'elts que de lignes: */
		scsr_height = sbar_height;
	}
	form_tree[ list_handles .slide_csr ] .ob_height = scsr_height;	/* Fix taille asc */
	/*
	 * Latitude de mouvement de l'ascenseur: 
	 */
	scsr_range = sbar_height - scsr_height;
	/*
	 * Position ascenseur: 
	 */
	fix_pos_asc( &list_handles, scsr_range, top_item, top_range );
	
	
	/*
	 * Gestion formulaire: 
	 * vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	 */
	open_dialog( form_tree, start_box, form_box );
	graf_mouse( ARROW, 0);					/* souris: FlŠche */

	for( ; ; )
	{	/*
		 * Mise … jour de certaines variables dans la liste des paramŠtres: 
		 */
		list_handles .top_item		 = top_item;		/* No de la 1Šre ligne affich‚e */
		list_handles .selected_line = selected_line;	/* No de la ligne s‚lectionn‚e */

		/*
		 * Gestion form jusqu'… un clic sur objet exit 
		 */
		exit_obj	=	ext_form_do( form_tree, &edit_obj );	/* Gestion de la boŒte */

		u_DblClick = exit_obj & 0x8000;
		exit_obj 	&= 0x7FFF;		/* Masque bit 15 (Double-clic) */

		/*
		 * Gestion des boutons sp‚cifiques: 
		 */
		if( exit_obj == list_handles .arrow_up )
		{	/*************/
			/* Arrow UP: */
			/*************/
			if ( top_item > 0 )
			{	/*
				 * Si on est pas encore au plus haut! 
				 * Monte d'un cran et fix ascenseur: 
				 */
				fix_pos_asc( &list_handles, scsr_range, (--top_item), top_range );
				/*
				 * Descend la ligne s‚lectionn‚e: 
				 */
				move_selected_line( &list_handles, +1 );
				selected_line = list_handles .selected_line;
				/*
				 * Fixe nlle liste 
				 */
				fixe_liste( &list_handles, top_item, 0, used_lines );
				/*
				 * Red‚ssine zone: 
				 */
				redraw_list( &list_handles );
			}
		}
		else if( exit_obj == list_handles .arrow_down )
		{	/***************/
			/* Arrow DOWN: */
			/***************/
			if ( top_item < top_range )
			{	/*
				 * Si on est pas encore au plus bas! 
				 * Descend d'un cran et fix ascenseur: 
				 */
				fix_pos_asc( &list_handles, scsr_range, (++top_item), top_range );
				/*
				 * Monte la ligne s‚lectionn‚e: 
				 */
				move_selected_line( &list_handles, -1 );
				selected_line = list_handles .selected_line;
				/*
				 * Fixe nlle liste 
				 */
				fixe_liste( &list_handles, top_item, 0, used_lines );
				/*
				 * Red‚ssine zone: 
				 */
				redraw_list( &list_handles );
			}
		}
		else if( exit_obj == list_handles .slide_bar )
		{	/*****************/
			/* Page UP/DOWN: */
			/*****************/
			int	click_x, click_y;
			int	slide_x, slide_y;
			int	new_top_item;
		
			/* Trouve coordonn‚es: */
			extform_lastmpos( &click_x, &click_y );	/* Click */
			objc_offset( form_tree, list_handles .slide_csr, &slide_x, &slide_y );	/* Ascenseur */
			/*
			 * Selon qu'on a cliqu‚ au dessus ou au dessous de l'asc: 
			 */
			if ( click_y < slide_y )
			{	/************/
				/* Page UP: */
				/************/
				if ( top_item > 0 )
				{	/* Si on est pas encore au plus haut! */
				/* Monte d'un cran et fix ascenseur: */
					new_top_item = max( 0, top_item - nb_lines );
					fix_pos_asc( &list_handles, scsr_range, new_top_item, top_range );
				/* Descend la ligne s‚lectionn‚e: */
					move_selected_line( &list_handles, top_item - new_top_item );
					selected_line = list_handles .selected_line;
				/* Fixe nlle liste */
					top_item = new_top_item;
					fixe_liste( &list_handles, top_item, 0, used_lines );
				/* Red‚ssine zone: */
					redraw_list( &list_handles );
				}
			}
			else
			{	/**************/
				/* Page DOWN: */
				/**************/
				if ( top_item < top_range )
				{	/* Si on est pas encore au plus bas: */
				/* Monte d'un cran et fix ascenseur: */
					new_top_item = min( top_range, top_item + nb_lines );
					fix_pos_asc( &list_handles, scsr_range, new_top_item, top_range );
				/* Monte la ligne s‚lectionn‚e: */
					move_selected_line( &list_handles, top_item - new_top_item );
					selected_line = list_handles .selected_line;
				/* Fixe nlle liste */
					top_item = new_top_item;
					fixe_liste( &list_handles, top_item, 0, used_lines );
				/* Red‚ssine zone: */
					redraw_list( &list_handles );
				}
			}
		}
		else if( exit_obj == list_handles .slide_csr )
		{	/***********/
			/* SLIDER: */
			/***********/
			int	new_pos;
		
			/* Mouvement fant“me: */
			new_pos = graf_slidebox( form_tree, list_handles .slide_bar,
                               list_handles .slide_csr, 1 );

			/* Calcule position demand‚e: */
			/*	printf("Pos dem=%d ",new_pos); */
			new_pos = (int)( (long)new_pos * top_range /1000 );
			/* printf("Pos calc=%d \r",new_pos); */

			/* Contr“le si position a chang‚: */
			if ( new_pos != top_item )
			{	/*
				 * Si pos … chang‚: 
				 */

				/* Fixe ascenseur: */
				fix_pos_asc( &list_handles, scsr_range, new_pos, top_range );
				/* Monte ou Descend la ligne s‚lectionn‚e: */
				move_selected_line( &list_handles, top_item - new_pos );
				selected_line = list_handles .selected_line;
				/* Fixe nlle liste */
				top_item = new_pos;
				fixe_liste( &list_handles, top_item, 0, used_lines );
				/* Red‚ssine zone: */
				redraw_list( &list_handles );
			}
      }
		else
		{
			if( exit_obj >= list_handles .first_name && exit_obj <= list_handles .last_name )
			{	/*
				 ****************************
				 * Si on a cliqu‚ sur un nom:
				 ****************************
				 * Contr“le que le nom n'est pas DISABLED: 
				 */
				if ( !(form_tree[ exit_obj ] .ob_state & DISABLED) )
				{	/* 
					 * Fixe nlle ligne s‚lectionn‚e 
					 * en local et ds la structure list_handles afin d'informer 
					 * l'ext‚rieur (utile lors de l'appell … fixstate_act() )
					 */
					selected_line = exit_obj;			
					list_handles .selected_line = selected_line;	

					/*
					 * 04.01.94: S'occupe d'allumer les boutons d'actions:
					 */
					fixstate_act( &list_handles );	

					/* 
					 * On remet le bit 15 si double click
					 * On met le bit 14 pour signaler qu'on a cliqu‚ sur un nom
					 */
					continuer = actions( &list_handles, exit_obj | u_DblClick | 0x4000 ); /* Routine de traitement */
					if( continuer < FALSE0 )
					{						
						graf_mouse( ARROW, 0);			/* souris: FlŠche */
						continue;	/* Retourne directement en gestion formulaire! */
					}
				}
				else
				{	/* Si l'objet est DISABLED: */
					continue;	/* On ignore le clic */
				}
			}
			else
			{	/*
				 * On a pas cliqu‚ sur un nom:
				 * Teste si l'action doit ˆtre trait‚e par une routine sp‚ciale: 
				 */
				i=0;
				do
				{	/*
					 * Parcourt la liste des boutons n‚cessitant un traitement sp‚cial: 
					 */
					obj = esc_objs[ i++ ];
					if( exit_obj == obj )
					{	/*
						 * Si l'action doit ˆtre trait‚e par rout sp‚ciale: 
						 */
						continuer = actions( &list_handles, obj ); /* Routine de traitement */
					
						/*
						 * Teste si on a modifi‚ la liste: 
						 */
						if ( continuer == CHANGE_2 )
						{	/*
						 	 * ---------------------- 
							 * On a modifi‚ la liste:
							 * ----------------------
							 * Calculs: 
							 */		
							nb_elts = list_handles .nb_items;			/* Nbre d'elts ds la liste */
							used_lines = min(	nb_lines, nb_elts );		/* Nre de lignes r‚ellement utilis‚es */
							top_range = nb_elts - used_lines;			/* Lattitude de mvt du haut de la liste */

							/*
							 * Init liste: 
							 */
							top_item = list_handles .top_item;			/* Nlle ligne du haut */
							fixe_liste( &list_handles, top_item, 0, used_lines );
							enable_list( &list_handles, used_lines );		/* Disable des lignes vides */

							/*
							 * Ligne s‚lectionn‚e: 
							 */
							selected_line = list_handles .selected_line;
							if ( selected_line != NIL )
							{	/*
								 * S'il y a une ligne s‚lectionn‚e 
								 */
								objc_setsel( form_tree, selected_line );	/* S‚lectionne nouvelle ligne */
							}

							/*
							 * Taille ascenseur: 
							 */
							if	( nb_elts > nb_lines )		/* Si tous les elts ne peuvent ˆtre affich‚s simultan‚ment */
							{	/* Calcule dimension asc en imposant une hauteur minimale de 1 caractŠre */
								scsr_height = max( G_std_text .cell_h, sbar_height * nb_lines / nb_elts);
							}
							else
							{	/* Si moins d'elts que de lignes: */
								scsr_height = sbar_height;
							}
							form_tree[ list_handles .slide_csr ] .ob_height = scsr_height;	/* Fix taille asc */
							/*
							 * Latitude de mouvement de l'ascenseur: 
							 */
							scsr_range = sbar_height - scsr_height;
							/*
							 * Position ascenseur: 
							 */
							fix_pos_asc( &list_handles, scsr_range, top_item, top_range );
						
							/*
							 * Red‚ssine zone liste + ascensceur: 
							 */
							redraw_list( &list_handles );
													
							/*
							 * Allume les boutons d'action si n‚cessaire:
							 */
							fixstate_act( &list_handles );	

						}

						graf_mouse( ARROW, 0);			/* souris: FlŠche */
						break;								/* Pas besoin de tester les autres objs */
					}
				} while( obj != 0 );
			}
		}
			
		/*
		 * Sortie si n‚cessaire: 
		 */
		if( continuer >= FALSE0 )
		{	/* Si on abandonne le formulaire: */
			break;
		}
							
		/*
		 * D‚s‚lection du bouton s‚lectionn‚: 
		 */
		objc_dsel( form_tree, exit_obj );
	}

	graf_mouse( BUSYBEE, 0);				/* souris: Abeille */
	close_dialog( form_tree, exit_obj, start_box, form_box );
	/* 
	 * ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	 */

	/* 
	 * D‚s‚lectionne les objets: 
	 */
	objc_clrsel( form_tree, exit_obj );	/* D‚s‚lectionne bouton de sortie */
	if( selected_line != NIL )
	{
		objc_clrsel( form_tree, selected_line );	/* D‚s‚lectionne ligne courament s‚lectionn‚e */
	}

	/*
	 *	Retourne … l'appellant le nouveau nbre d'elts de la liste
	 * au cas o— la liste a chang‚ de taille
	 */
	*nb_items = nb_elts;

	/* 
	 * Retourne le num‚ro de l'objet qui a fait quitter: 
	 */
	if( continuer > 0 )
	{
		return	continuer;
	}
	
	return	exit_obj;

}


/*
 * fix_pos_asc(-)
 *
 * Purpose:
 * --------
 * Fixe la position de l'ascenseur 
 * d'un s‚lecteur trait‚ par select_in_list()
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	fix_pos_asc( 
			LISTHANDLES *list_handles, 
			long scsr_range, 
			int top_item, 
			int top_range )
{
	OBJECT	*form_tree = list_handles -> form_tree;
	int		slide_csr  = list_handles -> slide_csr;

	if ( top_range )
	{	/* Si l'ascenseur peut bouger!: */
		form_tree[ slide_csr ] .ob_y = (int)(scsr_range * top_item / top_range);
	}
	else
		form_tree[ slide_csr ] .ob_y = 0;
}



/*
 * move_selected_line(-)
 *
 * Purpose:
 * --------
 * D‚place la ligne courament s‚lectionn‚e
 * dans une liste trait‚e par select_in_list()
 *
 * Algorythm:
 * ----------  
 * - V‚rifie qu'il y avait d‚j… un ligne s‚lectionn‚e (sinon ya rien … faire)
 * - D‚s‚lectionne ligne physique
 * - Calcule nouvelle pos de la ligne
 * - Si elle sort de l'‚cran: eteinds les actions qui s'y report‚e
 *   Sinon: r‚affiche … nouvelle pos
 * - M‚morise new ligne s‚lect ou NIL si sortie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 04.01.94: Extinction des actions devenues invalides suite … sortie de la ligne s‚lectionn‚ des limites de l'‚cran
 */
void	move_selected_line( 					/* Out: Rien */
			LISTHANDLES *list_handles,		/* In: Ptr sur infos sur la liste & le dialogue affich‚s */
			int	move )						/* In: D‚placement en nbre de lignes */
{
	OBJECT	*form_tree = list_handles -> form_tree;

	if ( list_handles -> selected_line != NIL )
	{	/*	
		 * S'il y avait d‚j… une ligne de s‚lectionn‚e:
		 */
	
		/* 
		 * D‚s‚lectionne ligne courament s‚lectionn‚e:
		 */
		objc_clrsel( form_tree, list_handles -> selected_line );	

		list_handles -> selected_line += move;
		if ( 		list_handles -> selected_line < list_handles -> first_name 
				|| list_handles -> selected_line > list_handles -> last_name )
		{	/* 
			 * Si d‚placement trop grand: 
			 * la ligne sort de l'affichage:
			 * Il n'y a plus de ligne s‚lectionn‚e:
			 */
			list_handles -> selected_line = NIL;

			/*
			 * Appelle fonction qui: 
			 * "Eteinds" les actions qui ne sont plus valides
			 * du fait que plus aucune ligne n'est s‚lectionn‚e
			 */
		 	(list_handles -> fixstate_act)( list_handles ); 
		}
		else
		{	/* 
			 * Si la ligne ne sort pas de l'affichage:
			 * S‚lectionne nouvelle ligne:
			 */
			objc_setsel( form_tree, list_handles -> selected_line );	
		}
	}

}



/*
 * fixe_liste(-)
 *
 * Purpose:
 * --------
 * Fixe une s‚rie de lignes
 * dans une boŒte de dialogue trait‚e par select_in_list()
 *
 * Algorythm:
 * ----------  
 * - V‚rifie qu'il y a des lignes … fixer
 * - Fixe objets s‚lectionnables, s'il y en a
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 18.05.94: Prise en compte du fait qu'il peut ne pas y avoir les deux colonnes de textes ds la liste
 * 04.12.94: ne traite plus qu'une seule liste!
 * 07.01.95: efface les lignes inoccup‚es … la fin
 */
void	fixe_liste( 
			LISTHANDLES *	list_handles, 
			int 				first_page, 
			int 				first_line, 
			int 				nb_lines )
{
	/* 
	 * Pointeurs: 
	 */
	char 		* *path_array;
	OBJECT	*form_tree = list_handles -> form_tree;
	int		i;
	/* 
	 * Objets de d‚part: 
	 */
	int	obj = list_handles -> first_name + first_line;
	
	/* 
	 * Teste s'il y a des lignes … fixer: 
	 */
	if ( nb_lines )
	{
		/* 
		 * Teste s'il faut fixer les lignes ‚ditables:
		 */
		if ( list_handles -> pTpsz_array != NULL
				&& (path_array = *( list_handles -> pTpsz_array ) ) != NULL )
		{
	
			/* 
			 * Pointeurs de d‚part: 
			 */		
			path_array = &path_array[ first_page ];	/* Pointeur sur chemin */
		
	
			/* 
			 * Fixe chemin d'accŠs/nom: objets s‚lectionnables 
			 */
			for ( i=1; i<=nb_lines; i++ )
			{	
				rlink_teptext( &form_tree[ obj++ ], *(path_array++) );
			}
		}
	}
	
	/*
	 * Finit de remplir avec des lignes vides:
	 */
	while( obj <= list_handles -> last_name )
	{
		dlink_teptext( &form_tree[ obj++ ], "" );
	}

}



/*
 * enable_list(-)
 *
 * Purpose:
 * --------
 * - Disable des lignes non utilis‚es lorsque la liste est plus courte que
 * le nbre de lignes physiquement affich‚es … l'‚cran
 * - Enable des ligne lorsqu'on allonge la liste/ on qu'affiche pour la
 * premiŠre fois
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	enable_list( 
			LISTHANDLES *list_handles, 
			int used_lines )
{
	/* 
	 * Pointeurs: 
	 */
	OBJECT	*form_tree = list_handles -> form_tree;

	/* 
	 * Variables: 
	 */
	int	limit = list_handles -> first_name + used_lines;
	int	i;

	/*
	 * Parcourt liste: 
	 */
	for ( i = list_handles -> first_name; i <= list_handles -> last_name; i++ )
	{	/* 
		 * D‚s‚lectionne slots inutilis‚s: 
		 */

		if ( i < limit )
		{	/* 
		    * Si le slot doit ˆtre actif: 
		    */
			form_tree[ i ] .ob_state &= !DISABLED;
		}
		else
		{	/* 
		 	 * Si le slot est vide => inactif: 
		 	 */
			form_tree[ i ] .ob_state |= DISABLED;
		}
	}

}


/*
 * redraw_list(-)
 *
 * Purpose:
 * --------
 * R‚affiche une liste de s‚lection 
 * trait‚e par select_in_list()
 * lorsqu'on change son contenu ou lorsqu'elle scrolle … l'‚cran
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	redraw_list( 
			LISTHANDLES *list_handles 
			)
{
	OBJECT	*form_tree = list_handles -> form_tree;
	GRECT		form_box;
	int 		i;
	
	objc_xywh( form_tree, ROOT, &form_box );
	
	for ( i=list_handles -> first_name; i<=list_handles -> last_name; i++ )
	{
		objc_draw( form_tree, i, 1, form_box .g_x, form_box .g_y, form_box .g_w, form_box .g_h );
	}

	objc_draw( form_tree, list_handles -> slide_bar, 1, form_box .g_x, form_box .g_y, form_box .g_w, form_box .g_h );
	
}


/*
 * list_fix1name(-)
 *
 * Purpose:
 * --------
 * Modifie un nom dans une liste de s‚lection
 * trait‚e par select_in_list()
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	list_fix1name( 
			OBJECT *form_tree, 
			int selected_line, 
			char *new_name )
{
	GRECT		name_box;
	
	/* 
	 * Modifie nom dans le formulaire: 
	 */
	rlink_teptext( &form_tree[ selected_line ], new_name );
		
	/* 
	 * Redessine nom: 
	 */
	objc_xywh( form_tree, selected_line, &name_box );
	objc_draw( form_tree, selected_line, 1,
				  name_box .g_x, name_box .g_y, name_box .g_w, name_box .g_h );
	
}


/*
 * get_no_selitem(-)
 *
 * Purpose:
 * --------
 * Fournit le No d'ordre de l'elt s‚lectionn‚
 * ds la liste textuelle actuellement g‚r‚e par select_in_list()
 *
 * Algorythm:
 * ----------  
 * no d'ordre =  no d'ordre de l'elt sur objet du haut 
 * 				+ no d'objet selectionn‚
 *					- no d'objet du haut
 *
 * Notes:
 * ------
 * Le no renvoy‚ est dans l'int 0..nb_elts-1
 * Cette func serait incluse dans la classe LISTHANDLES en C++
 *
 * History:
 * --------
 * 05.01.93: fplanque: Created
 */
int get_no_selitem(						/* Out: No d'ordre ds liste textuelle de l'elt s‚lectionn‚ */
		LISTHANDLES *list_handles )	/* In: Infos sur la liste textuelle actuellement affich‚e */
{
	return	list_handles -> top_item + list_handles -> selected_line - list_handles -> first_name;
}


/*
 * reperes_sel(-)
 *
 * Purpose:
 * --------
 * Prise de repŠres et initialisations dans un arbre d'obj s‚lecteur
 * Cette func est appell‚e pour chaque objet de la boite de dialogue
 * select_in_list() -> maptree() -> reperes_sel()
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 07.01.95: n'init plus les lignes en ""
 */
int	reperes_sel( 
			OBJECT *	tree, 
			int 		obj )
{
	/* printf("%d ",obj); */
	int	ext_type = tree[ obj ] .ob_type >>8;
	
	/* 
	 * Prise de repŠres: 
	 */
	switch( ext_type )
	{
		case	3:
			/* printf("First name: %d\n", obj);*/
			M_maptree_vars .first_name = obj;
			M_init_text = TRUE_1;			/* On commence … initialiser les champs */
			break;
	
		case	4:
			/* printf("Last name: %d\n", obj);*/
			M_maptree_vars .last_name = obj;
			M_init_text = ESC;			/* On va s'arrˆter d'initialiser */
			break;
	
		case	11:
			/* printf("Arrow UP: %d\n", obj);*/
			M_maptree_vars .arrow_up = obj;
			break;
	
		case	12:
			/*	printf("Arrow DOWN: %d\n", obj);*/
			M_maptree_vars .arrow_down = obj;
			break;
	
		case	13:
			/*	printf("Cage: %d\n", obj); */
			M_maptree_vars .slide_bar = obj;
			break;
	
		case	14:
			/* printf("Ascenseur: %d\n", obj);*/
			M_maptree_vars .slide_csr = obj;
			break;
	}


	return	TRUE_1;
}


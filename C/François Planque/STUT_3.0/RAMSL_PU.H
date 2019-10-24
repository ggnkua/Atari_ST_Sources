/*
 * RamSelector_Public.h
 *           
 * History:
 * --------
 * Created by fplanque
 * 04.01.94: ajout d'un ptr sur func fixstat_act(): cette fonction fixe l'‚tat des boutons d'action selon le fait qu'un elt de liste est s‚lectionn‚ ou non
 */

typedef
	struct	listhandles
	{
		OBJECT   *form_tree;			/* Arbre d'objets */

		char		* * *pTpsz_array;	/* Ptr sur liste des chemins-noms */

		int		first_name,			/* 1er nom/chemin */
					last_name,			/* dernier */
					arrow_up,			/* FlŠche haut */
					arrow_down,			/* FlŠche bas */
					slide_bar,			/* Cage ascenseur */
					slide_csr;			/* Ascenseur */
		int		nb_items;			/* Nbre d'elts de la liste */
		int		top_item;			/* 1Šre ligne affich‚e */

		int		selected_line;		/* Ligne s‚lectionn‚e 
											 * = NIL si aucune 
											 */

		void		(*fixstate_act)(struct listhandles *list_handles);
											/* In: Ptr sur fonction … appeler pour
											 * allumer/eteindre les boutons d'action
											 */

	}
	LISTHANDLES;


/*
 * R‚sultat RAMSELECT:
 */
typedef
	enum
	{
		RAMSEL_ABORT,
		RAMSEL_PATH,
		RAMSEL_FILE
	}
	RAMSEL;



#define	DBLE_CLICLK		0x8000
#define	SEL_LINE			0x4000
#define	SEL_OBJC_NO		0x3FFF


	/*
	 * S‚lecteur d'objets en RAM: 
	 */

void	init_ramselect( void );

RAMSEL ramselect( 						/* Out:	r‚sultat de la s‚lection: RAMSEL_ABORT, RAMSEL_PATH ou RAMSEL_FILE */
			char 		 *	sel_titre, 		/* In: 	S‚lection du titre */
			DATADIR	 * pDataDir,		/* In:	Datadir ds lequel on effectue la s‚lection */
			char 		**	sel_page, 		/* Out:	Adresse du TAMPON ds lequel se trouve le path du fichier s‚lectionn‚ */
			GRECT		 * pGRect_start,	/* In: 	D‚but ouverture */
			GRECT		 * pGRect_form);	/* Out:	copie ds ce GRect les coords du s‚lecteur */

	RAMSEL ramselect_fromForm( 		/* Out:	r‚sultat de la s‚lection: RAMSEL_ABORT, RAMSEL_PATH ou RAMSEL_FILE */
			char 		 *	sel_titre, 	/* In: 	S‚lection du titre */
			DATAGROUP *	datagroup, 	/* In: 	DataGroup dans lequel on effectue la s‚lection */
			char 		**	sel_page, 	/* Out:	Adresse du TAMPON ds lequel se trouve le path du fichier s‚lectionn‚ */
			OBJECT 	 *	arbre_fond, /* In:	Dialogue depuis lequel on appelle le s‚lecteur de fichiers */
			int			call_obj );	/* In:	No de l'objet qui a appell‚ le s‚lecteur depuis le dialogue de fond */

	extern int select_in_list( 
			OBJECT *form_tree, 				/* In: Arbre d'obj: boite de dialogue … afficher */
			const GRECT *start_box, 		/* In: Coord d‚part de l'effet graphique d'ouverture/fermeture */
			GRECT *form_box, 					/* Out: Coord boite de dialog … l'‚cran */
			char * * *path_array, 			/* In/Out: Adr d'un ptr sur table "path" */
			int *nb_items,						/* In: Nbre d'‚l‚ments de la liste */
			int *esc_objs, 					/* In: Ptr sur tableau contenant la
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
			int edit_obj );					/* In: Obj sur leql se situe le csr en d‚but d'‚dition */

	extern int get_no_selitem(				/* Out: No d'ordre ds liste textuelle de l'elt s‚lectionn‚ */
			LISTHANDLES *list_handles );	/* In: Infos sur la liste textuelle actuellement affich‚e */
	extern	void	list_fix1name( 
					OBJECT *form_tree, 
					int selected_line, 
					char *new_name );

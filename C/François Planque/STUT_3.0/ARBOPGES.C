/*
 * arboedit.c
 *
 * Purpose:
 * --------
 * Fonctions permettant l'edition des pages arborescence:
 *
 * History:
 * --------
 * 1993: Created by flanque
 * 18.05.94: sorti l'edition de l'arbre vers TREEEDIT.C
 */

	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"ARBOPGES.C v1.32 - 07.95"
          
/*
 * System headers:
 */
	#include	<stdio.h>
	#include <stdlib.h>
	#include	<string.h>						/* Memcpy etc... */
	#include	<aes.h>							/* header AES */  
	#include <tos.h>
		
/*
 * Custom headers:
 */
	#include	"ARB_OUT.H"
	#include "SPEC_PU.H"						/* Listes... */	
	#include "S_MALLOC.H"
	#include "STUT_ONE.RSC\STUT_3.H"		/* noms des objets ds le ressource */
	#include	"DESK_PU.H"
	#include	"RAMSL_PU.H"
	#include	"POPUP_PU.H"					/* Pour gestion Pop-Up */
	#include "AESDEF.H"
	#include "EXFRM_PU.H"
	#include "FILES_PU.H"
	#include	"MAIN_PU.H"	
	#include	"DEBUG_PU.H"	
	#include	"DATPG_PU.H"	
	#include	"DTDIR_PU.H"	
	#include	"OBJCT_PU.H"	
	#include "ARBPG_PU.H"					/* this! */
	#include	"ARPAR_PU.H"
	#include "LISTS_PU.H"
	#include "PGECR_PU.H"
	#include	"SRIAL_PU.H"	
	#include "TERM_PU.H"
	#include "MINITEL.H"
	#include	"VDI_PU.H"	
	#include "WIN_PU.H"						/* Gestion des fenˆtres */
	#include "WINDR_PU.H"					/* Gestion des fenˆtres */
	#include "ARBKEYPU.H"
	#include	"ARBGENPU.H"

/*
 * ------------------------- TYPES --------------------------
 */
typedef
	struct
	{
		BOOL	b_EnableAdd	 :	1;
		BOOL	b_EnableDel	 :	1;
		BOOL	b_EnableList : 1;
	}
	PARPAGE_FLAGS;


/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * PRIVate internal prototypes:
 */
	static	void edit_ArboParList(				/* Ne renvoie rien */
						int			edit_type, 
						WIPARAMS *	pWiParams );
	static	ARBO_FIELDPARS *	fix_arbo_OutFields( 	/* Out: Params cr‚‚s */
											int fnct );			/* In:  Fnct page arbo */
	static	ARBO_LISTPARS *	fix_arbo_ListPars( 	/* Out: Params cr‚‚s */
											int fnct );			/* In:  Fnct page arbo */
	static	ARBO_FIELDPARS *	fix_arbo_InFields( 	/* Out: Params cr‚‚s */
											int fnct );			/* In:  Fnct page arbo */
	static	ARBO_TEXTPAR *	fix_arbo_PEcrans( 	/* Out: Params cr‚‚s */
										int fnct );			/* In:  Fnct page arbo */
	static	ARBO_TEXTPAR * fix_arbo_databases( 
										int fnct );
	static	AFNCTSPEC	*afnct_spec( int fnct );
	static	void	edit_in_liens( WIPARAMS *wi_params_adr );
	static	int	Create_TextParPszList( 
							int edit_type, 
							ARBO_TEXTPAR *first_pecr_link, 
							char * * *textes );
	static	int	Create_FieldPszList( 
							int type, 
							ARBO_FIELDPARS *first_field, 
							char * * *textes );
	static	void	Delete_PszList(
							char * * Tpsz_List,	/* In: tableau de psz */
							int		nb_lines );	/* In: Nbre de lignes ds tableau */
	static	char	*	Create_1OutFieldPsz( ARBO_FIELDPARS *field_params );
	static	char	*	Create_1InFieldPsz( ARBO_FIELDPARS *field_params );
	static	char	*	Create_1PathnamePsz( 
								ARBO_TEXTPAR *	pTextPar,		/* In: param texte */
								int				n_type );		/* In: Type de param */
	static	void	edpgecr_callselect( LISTHANDLES *list_handles, int obj );
	static	void	parapg_parasortie( LISTHANDLES *list_handles, OBJECT *arbre_fond, int call_obj );
	static	void	parapg_parasaisie( LISTHANDLES *list_handles, OBJECT *arbre_fond, int call_obj );
	static	void	parapg_paralist( 
							ARBO_LISTPARS	*	pArboListPars,	/* In: ParamŠtres … modifier */
							OBJECT 			*	arbre_fond, 
							int 					call_obj );
	static	void	replace_tmp_paramstring( char * *paramstring, char *new_content, int selection );
	static	ARBO_FIELDPARS *	cree_OutFieldPars( 
											OUTPUT_FPAR *	pOutputFPars );
	static	ARBO_FIELDPARS *	cree_InFieldPars( 					/* Out: Liste cr‚e */
											INPUT_FPAR *	pInputFPars );	/* In:  Tableau de valeurs par d‚faut */
	static	void	DataPage_AutoParam(
					DATAPAGE	*	pDataPage );		/* In: Page concern‚e */

	/*
	 *	ParamŠtrages divers:
	 */
	static 	void	edit_arbopar_divers( int edit_type, WIPARAMS *wi_params_adr );
	static	int	parpage_general( 
					PARPAGE_FLAGS * flags,
					GRECT *	start_box, 		/* In: Rect de d‚part effet graphique */
					int	*	esc_objs,		/* In: Tableau des boutons … traiter en exit */
					char * * *path_array, 
					int nb_pecr_link );		/* In: Nbre de lignes dans le s‚lecteur */
	static	int	parapage_actions( LISTHANDLES *list_handles, int	obj );
	static	void	parpg_fixstate_act( 					/* Out: Rien */
							LISTHANDLES *list_handles );	/* In: Ptr sur infos sur la liste & le dialogue affich‚s */
	/*
	 * Params sp‚cifiques:
	 */
	static	void	edit_arbopar_params( 
							WIPARAMS *pWiParams );	/* In: Fen contenant le menu arbo depuis lequel on appelle */
	/*
	 * Mots-clefs:
	 */
	static	BOOL	ajoute_MotClef( 						/* Out: TRUE_1 si on a valid‚ */
							LISTHANDLES *	p_ListHandles,	/* In: Params de la liste des mots clefs */
							OBJECT 		*	pForm_fond, 	/* In: Formulaire qui a appel‚ */
							int 				n_callObj );	/* In: Obj aui a appell‚ sur ce formulaire */
	static	BOOL	supprime_MotClef( 						/* Out: TRUE_1 si on a valid‚ */
							LISTHANDLES *	p_ListHandles );	/* In: Params de la liste des mots clefs */
	static	void	fixe_MotClef( 
							LISTHANDLES *	p_ListHandles,
							BOOL				b_Command,		/* In: TRUE_1 si on traite une commande, sinon on triate un event */
							OBJECT 		*	pForm_fond, 
							int 				n_callObj );
	static	BOOL	edit_MotClef(												/* Out: TRUE_1 si valid‚ */
							KEYWORD_LIST  *	pDblText_paramsMotClef,		/* In:  Mot clef … ‚diter */
							BOOL					b_MotClef,						/* In:  TRUE si mot clef, sinon: event */
							OBJECT 			*	pForm_fond, 
							int 					n_callObj );
							


/*
 * ------------------------ VARIABLES -------------------------
 */

/*
 * Internal variables: 
 */
	/* 
	 * Arbres: 
	 */
	static	OBJECT *	M_arbosomm_adr;				/* Ptr sur boite pple d'une page arbo */
	static	OBJECT *	M_pForm_EditInFields;		/* Ptr sur boite de params champ de saisie */
	static	OBJECT *	M_pForm_EditOutFields;		/* Ptr sur boite de params champ de sortie */
	static	OBJECT *	M_pForm_EditParamsLect;		/* Formulaire d'edition des Params lecture */
	static	OBJECT *	M_pForm_EditArboKeyWords;	/* Ptr sur boite d'edition des mots clefs */
	static	int		M_KeyWords_EscObjs[]={ EDLISTE, EDAPFIX, EDAPSPEC, EDAPADD, EDAPSUPP, ADAPVAL, EDAPANN, NIL };
	static	OBJECT *	M_pForm_EditMotClef;			/* Ptr sur boite d'edition d'un mot-clef */
	static	OBJECT *	M_pForm_EditListPars;		/* ParamŠtres d'affichage d'une liste */
	static	OBJECT *	M_pForm_EditParFileSel;		/* Formulaire d'edition des Params FileSel */

	/*
	 * Params pages ‚cran par d‚faut:
	 */
#include "FN_VDT.C"

	/*
	 * Params champs de SORTIE par d‚faut:
	 */
#include "FN_OUTPT.C"

	/*
	 * Params champs de SAISIE par d‚faut:
	 */
#include "FN_INPUT.C"

	/*
	 * Params Liens par d‚faut:
	 */
#include "FN_LINKS.C"

	/*
	 * Params Bases de donn‚es:
	 */
#include "FN_DBASE.C"

	/* 
	 * Variables servant lors du param‚trage d'une page arbo: 
	 */
	static int					M_edit_pecr_type;		/* Type d'‚dition: pages-ecran ou liens arbo */
	static ARBO_TEXTPAR *	M_TextPar_copies;		/* Ptr sur Copies des paramŠtres des champs pdt la phase d'‚dition */
	static ARBO_FIELDPARS *	M_fieldpar_copies;	/* Ptr sur Copies des paramŠtres des champs pdt la phase d'‚dition */
	static ARBO_LISTPARS		M_ListPars_copy;		/* Copie des paramŠtres liste pour leur ‚dition */
	/*
	 * Menus PopUps utilis‚s pour l'‚dition:
	 */
	static POPUP_ENTRY		M_fill_menu[]=
				{											/* Popup de choix d'un fond */
					"  Espace vide",	' ',
					"  Points",			'.',
					"  Tirets",			'-',
					"  Tirets bas",	'_',
					"  Transparent",	NIL,
					NULL,					0xFFFF
				};
	static POPUP_ENTRY	M_cach_menu[]=
				{											/* Popup de choix d'un CACHE */
					"  Sans cache",	NUL,
					"  Espace vide",	' ',
					"  Points",			'.',
					"  Tirets",			'-',
					"  Tirets bas",	'_',
					"  Etoiles",		'*',
					"  Transparent",	NIL,
					NULL,					0xFFFF
				};
	static POPUP_ENTRY	M_color_menu[]=
				{											/* Popup de choix d'une couleur */
					"  #0 Noir",		MNOIR,
					"  #1 Bleu",		MBLEU,
					"  #2 Rouge",		MROUGE,
					"  #3 Magenta",	MMAGENTA,
					"  #4 Vert",		MVERT,
					"  #5 Cyan",		MCYAN,
					"  #6 Jaune",		MJAUNE,
					"  #7 Blanc",		MBLANC,
					NULL,					0xFFFF
				};
	static POPUP_ENTRY	M_Popup_FilterMenu[]=
				{											/* Popup de choix d'une couleur */
					"  Aucun",			FILTER_NONE,
					"  Num‚rique",		FILTER_NUMERIC,
					"  Nom sans SPC",	FILTER_NAME_NOSPC,
					"  Nom avec SPC",	FILTER_NAME_SPACE,
					"  UserName",		FILTER_USERNAME,
					"  Mot de Passe",	FILTER_PASSWORD,
					"  Adresse User",	FILTER_ADDRESS,
					"  No T‚l‚phone",	FILTER_PHONE,
					NULL,					0xFFFF
				};

	/*
	 * Edition des mots clefs:
	 */
	KEYWORD_LIST * M_pKeyWordList_Copy;		/* Copie de la liste de mots clefs en cours d'‚dition */


/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * init_arbo(-)
 *
 * Purpose:
 * --------
 * Init des pages arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 18.05.94: divis‚
 * 07.11.94: params INFIELDs par d‚faut
 * 16.11.94: init INFIELDs ecriture
 * 03.12.94: NEW_ACCOUNT: pecran & infields
 * 02.02.95: linkage des ic“nes du bureau vers arbosomm
 */
void	init_arbo( void )
{
	
	TRACE0( "Initializing " THIS_FILE );
	
	/*
	 * Trouve adresses des arbres d'objets 
	 */
	if (rsrc_gaddr( R_TREE, ARBOSOMM, &M_arbosomm_adr ) == 0)
		erreur_rsrc();
	/*
	 * Fixe les bitmaps d'ic“nes:
	 */
	Icon_CopyICONIMGtoIBLK(	&(G_icon_images .datas), 		M_arbosomm_adr[ ARBDATAS ] .ob_spec.iconblk );
	Icon_CopyICONIMGtoIBLK(	&(G_icon_images .minitel), 	M_arbosomm_adr[ PGESECRA ] .ob_spec.iconblk );
	Icon_CopyICONIMGtoIBLK(	&(G_icon_images .affichages), M_arbosomm_adr[ AFFICHGS ] .ob_spec.iconblk );
	Icon_CopyICONIMGtoIBLK(	&(G_icon_images .saisies),		M_arbosomm_adr[ SAISIES ] 	.ob_spec.iconblk );
	Icon_CopyICONIMGtoIBLK(	&(G_icon_images .params),		M_arbosomm_adr[ PARAMS ] 	.ob_spec.iconblk );
	Icon_CopyICONIMGtoIBLK(	&(G_icon_images .liens), 		M_arbosomm_adr[ LIENSARB ] .ob_spec.iconblk );
	Icon_CopyICONIMGtoIBLK(	&(G_icon_images .erreurs), 	M_arbosomm_adr[ ERREURS ] 	.ob_spec.iconblk );
	Icon_CopyICONIMGtoIBLK(	&(G_icon_images .motsclef),	M_arbosomm_adr[ MOTSCLEF ] .ob_spec.iconblk );

	/*
	 * Fixe couleurs et positions d'ic“nes:
	 */
	rsrc_color( M_arbosomm_adr );

	if (rsrc_gaddr( R_TREE, EDT_EDIT, &M_pForm_EditInFields ) == 0)
		erreur_rsrc();
	rsrc_color( M_pForm_EditInFields );		/* Fixe couleurs */

	if (rsrc_gaddr( R_TREE, EDT_AFFZ, &M_pForm_EditOutFields ) == 0)
		erreur_rsrc();
	rsrc_color( M_pForm_EditOutFields );		/* Fixe couleurs */

	if (rsrc_gaddr( R_TREE, EDTKEYWD, &M_pForm_EditArboKeyWords ) == 0)
		erreur_rsrc();
	rsrc_color( M_pForm_EditArboKeyWords );	/* Fixe couleurs */

	if (rsrc_gaddr( R_TREE, EDT_KEY, &M_pForm_EditMotClef ) == 0)
		erreur_rsrc();
	rsrc_color( M_pForm_EditMotClef );	/* Fixe couleurs */

	if (rsrc_gaddr( R_TREE, EDT_LIST, &M_pForm_EditListPars ) == 0)
		erreur_rsrc();
	rsrc_color( M_pForm_EditListPars );	/* Fixe couleurs */
	
	if (rsrc_gaddr( R_TREE, PARALECT, &M_pForm_EditParamsLect ) == 0)
		erreur_rsrc();
	rsrc_color( M_pForm_EditParamsLect );		/* Fixe couleurs */

	if (rsrc_gaddr( R_TREE, PARAFSEL, &M_pForm_EditParFileSel ) == 0)
		erreur_rsrc();
	rsrc_color( M_pForm_EditParFileSel );		/* Fixe couleurs */


	/*
	 * ------------------------------
	 * Cr‚e modŠles de pages ‚cran:
	 * ------------------------------
	 */
	M_std_pecran	 		= cree_textpars2( M_stdpecran );
	M_lect_pecran	 		= cree_textpars2( M_lectpecran );
	M_ecri_pecran	 		= cree_textpars2( M_ecripecran );
	M_DispText_PEcrans	= cree_textpars2( M_DispText_PEcrDefs );
	M_Id_pecran		 		= cree_textpars2( M_IdPEcran );
	M_NewAcc_pecran		= cree_textpars2( M_NewAccPEcran );
	M_List_pecran		 	= cree_textpars2( M_ListPEcran );
	M_Dir_pecran		 	= cree_textpars2( M_DirPEcran );
	M_FileSel_PEcran		= cree_textpars2( M_FileSelPEcran );
	M_DownLoad_PEcran		= cree_textpars2( M_DownLoadPEcran );


	/*
	 * -----------------------------------
	 * Cr‚e modŠles de champs d'affichage:
	 * -----------------------------------
	 */
	M_ecri_OutFields 		= cree_OutFieldPars( M_Ecri_OutDefs );
	M_lect_OutFields 		= cree_OutFieldPars( M_Lect_OutDefs );
	M_DispText_OutFields	= cree_OutFieldPars( M_DispText_OutDefs );
	M_List_OutFields		= cree_OutFieldPars( M_List_OutDefs );
	M_Dir_OutFields		= cree_OutFieldPars( M_Dir_OutDefs );
	M_FileSel_OutFields  = cree_OutFieldPars( M_FileSel_OutDefs );
	
	/*
	 * ---------------------------------
	 * Cr‚e modŠles de champs de saisie:
	 * ---------------------------------
	 */
	M_Std_InFields		= cree_InFieldPars( M_Std_InDefs );
	M_Ecri_InFields	= cree_InFieldPars( M_Ecri_InDefs );
	M_Id_InFields		= cree_InFieldPars( M_Id_InDefs );
	M_NewAcc_InFields	= cree_InFieldPars( M_NewAcc_InDefs );

	/*
	 * -----------------------------
	 * Cr‚e modŠles de liens-arbo:
	 * -----------------------------
	 */
	M_def_arbolinks  = CmdList_Create( M_stdlinks );
	M_Ecri_Links 	  = CmdList_Create( M_Ecri_LinkDefs );
	M_List_Links	  = CmdList_Create( M_List_LinkDefs );
	M_FileSel_Links  = CmdList_Create( M_FileSel_LinkDefs );
	M_DownLoad_Links = CmdList_Create( M_DownLoad_LinkDefs );
	
	/*
	 * ---------------------------------
	 * Cr‚e modŠles de Bases de donn‚es:
	 * ---------------------------------
	 */
	M_Ecri_DBs 		= cree_textpars2( M_Ecri_DBDefs );
	M_Lect_DBs 		= cree_textpars2( M_Lect_DBDefs );
	M_DispText_DBs	= cree_textpars2( M_DispText_DBDefs );
	M_Id_DBs 		= cree_textpars2( M_Id_DBDefs );

}
   
   
  
   
/*
 * ouverture_page_arbo(-)
 *
 * Purpose:
 * --------
 * Gestion du menu d'une page arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	ouverture_page_arbo( 
			WIPARAMS	*	selection_adr )
{
	/*
	 * Donn‚es concern‚es: 
	 */
	int			selected_object =	selection_adr -> selected_icon;
	DATADIR	*	curr_datadir	 = selection_adr -> datadir;
	OBJECT	*	obj = &((selection_adr -> draw_ptr.tree)[ selected_object ]);
	int			ext_type = (obj -> ob_type ) >> 8;

	switch ( ext_type )
	{
		case FS_IN:
		/* Element "IN": */
			edit_in_liens( selection_adr );
			break;

		default:
		{	/*
			 * Page arbo: 
			 */
			DATAGROUP	*	curr_datagroup = selection_adr -> datagroup;
			char			*	data_name		 = ((selection_adr -> draw_ptr.tree)[selected_object] .ob_spec.iconblk) -> ib_ptext;
			DATAPAGE		*	curr_datapage	 = page_adr_byname( curr_datadir, data_name ); 

			if( curr_datapage == NULL )
			{	/* Si page non trouv‚e */
				signale("Page introuvable");
			}
			else
			{
				/*	printf( data_name ); */
		  		ouvre_fenetre( CLASS_DATAPAGE, TYP_ARBO,
									curr_datagroup, curr_datadir, curr_datapage,
		  							" Page Arborescence " );
			}
		}
	}

}



/*
 * access_arbo(-)
 *
 * Purpose:
 * --------
 * Essaie d'acc‚der … un page arbo en m‚moire pour l'ouvrir
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 06.08.94: extraction du code de controle du nbre de fenˆtre ouverte sur DATAPAGE (limite: 1)
 */
int	access_arbo( 
			DATAPAGE *datapage, 
			WORK_CONTENT *content_ptr )
{
	/*
	 * Fixe adr de la page courante! (qui contient celle de l'image:) 
	 */
	content_ptr -> datapage = datapage;

	return	1;		/* On peut ouvrir */
}




/*
 * open_arbosomm(-)
 *
 * Purpose:
 * --------
 *	Affichage du sommaire d'‚dition d'une page arbo
 *
 * History:
 * --------
 *     1993: fplanque: Created
 * 17.05.94: fplanque: Ouvre la fenˆtre avec dimensions OPTIMALES
 */
void open_arbosomm( 
			WIPARAMS *	pWiParams, 
			DATAPAGE *	datapage )
{
	/*	
	 * Pointeurs: 
	 */
	PAGEARBO		*	pagearbo = datapage -> data.pagearbo;
	AFNCTSPEC	*	M_fnctarbo = pagearbo -> fnct_spec;
	OBJECT 		*	form_adr;
	
	/*
	 * Donne … la fenˆtre ses dimensions optimales:
	 */
	wind_get( pWiParams -> handle, WF_FULLXYWH,  
					&(pWiParams -> curr_x), &(pWiParams -> curr_y), 
					&(pWiParams -> curr_w), &(pWiParams -> curr_h) );
	wind_calc( WC_WORK, pWiParams -> wi_ckind,  
					pWiParams -> curr_x, pWiParams -> curr_y, 
					pWiParams -> curr_w, pWiParams -> curr_h,
					&(int)(pWiParams -> work_x), &(int)(pWiParams -> work_y), 
					&(int)(pWiParams -> seen_w), &(int)(pWiParams -> seen_h) );

	/*
	 * Duplique arbre d'objets: 
	 */
	form_adr = formdup( M_arbosomm_adr );
	/*
	 * Positionne arbre d'objets: 
	 */
 	form_adr[0].ob_x = pWiParams -> work_x +2;
	form_adr[0].ob_y = pWiParams -> work_y +2;

	/*
	 * Fixe le nom de la page: 
	 */
	rlink_teptext ( &form_adr[ NOMARBO ], pagearbo -> chemin );
	/*
	 * Fixe la fonction de la page: 
	 */
	rlink_teptext ( &form_adr[ FNCTARBO ], M_fnctarbo -> fnct_name );
	/* 
	 * Fixe le commentaire de la page: 
	 */
	if ( datapage -> comment != NULL )
	{
		rlink_teptext( &form_adr[ COMENTAR ], datapage -> comment );
	}
	else
	{
		dlink_teptext( &form_adr[ COMENTAR ], G_empty_string );
	}
	
	/*
	 * Enable/Disable des ic“nes actives: 
	 */
	objc_fixable( form_adr, PGESECRA,	YES1 );
	objc_fixable( form_adr, AFFICHGS,	pagearbo -> output_fields !=NULL ? YES1 : NO0 );
	objc_fixable( form_adr, SAISIES,		pagearbo -> fnct_no==FA_DOWNLOAD ? NO0 : YES1 );
	objc_fixable( form_adr, ARBDATAS,	pagearbo -> databases!=NULL ? YES1 : NO0 );
	objc_fixable( form_adr, ERREURS,		NO0  );
	objc_fixable( form_adr, LIENSARB,	YES1 );
	objc_fixable( form_adr, PARAMS,		pagearbo -> special_par.data!=NULL ? YES1 : NO0 );
	objc_fixable( form_adr, MOTSCLEF,	pagearbo -> fnct_no==FA_DOWNLOAD ? NO0 : YES1 );
	
	/*
	 * Param‚trage de la fenˆtre: 
	 */
	pWiParams -> content_ptr.datapage = datapage;		/* Pointeur sur contenu */
	pWiParams -> draw_ptr.tree = form_adr;		/* Pointeur sur arbre d'objets */
	pWiParams -> total_w			= form_adr[0] .ob_width +2*OUTLINE_INWIN;
	pWiParams -> total_h			= form_adr[0] .ob_height +2*OUTLINE_INWIN;
	pWiParams -> h_step			= 16;				/* Saut par 16 pix */
	pWiParams -> v_step 			= 16;				/* Saut par 16 pix */

}




/*
 * free_arbosomm(-)
 *
 * Purpose:
 * --------
 * LibŠre arbre d'objet ARBOSOMM de la m‚moire
 *
 * History:
 * --------
 *     1993: fplanque: Created
 * 11.07.95: fplanque: Enlev‚ le free du nom qui ‚tait superflu (ce bug existait depuis TRES TRES longtemps!)
 */
void free_arbosomm( OBJECT *form_adr )
{
	/*
	 * Efface l'arbre (qui avait ‚t‚ dupliqu‚ lors de l'ouverture de la fenetre)
	 */
	free_form( form_adr );
}



/*
 * edit_in_liens(-)
 *
 * Purpose:
 * --------
 * Edition des liens partant de l'objet "IN"
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 04.12.94: ne gŠre plus qu'une seule liste de paramŠtres; fonctionne en utilisant une copie des params pour l'‚dition
 * 17.12.94: signale que datagroup a ‚t‚ modifi‚
 * 29.03.95: liens >-> evenements
 */
void edit_in_liens( 
		WIPARAMS *pWiParams )
{
	DATADIR	*	datadir	= pWiParams -> datadir;	/* Dossier concern‚ */
	DIRSPEC	*	dir_spec	= datadir -> dir_spec;			/* Sp‚cifications compl‚mentaires */	

	KEYWORD_LIST * p_1stEvent = dir_spec -> liens_in;	/* Ptr sur Liens … ‚diter */
	int				nb_lignes;		/* Nbre de lignes de la liste */
	char			**	textes;		/* textes des lignes */

	/* Var d'‚dition */
	PARPAGE_FLAGS flags = { 0, 0, 0 };
	GRECT			start_box;
	int			modif;			/* A t'on modifi‚? */

	/*
	 * Fixe le nom de la page: 
	 */
	rlink_teptext ( &M_pForm_EditArboKeyWords[ EDKEYPAG ], "." );		/* . signifie: dossier courant */
	/*
	 * Fixe la fonction de la page: 
	 */
	rlink_teptext ( &M_pForm_EditArboKeyWords[ EDKEYFNC ], "Entr‚e" );	/* Entr‚e dans le dossier courant */
	/*
	 * Fixe le "titre" de la fenˆtre fille: 
	 */
	dlink_teptext( &M_pForm_EditArboKeyWords[ EDKEYTIT ], " EvŠnements G‚n‚raux " );

	/* 
	 * Duplique les params: 
	 */
	M_pKeyWordList_Copy = dup_KeyWordList( p_1stEvent );

	/* 
	 * Cr‚ation liste psz: 
	 */
	nb_lignes = cree_liste_KeyWord( M_pKeyWordList_Copy, FALSE0, &textes );

	/*******************************************************************/

	objc_xywh ( pWiParams -> draw_ptr.tree, pWiParams -> selected_icon, &start_box );

	M_edit_pecr_type = EDIT_LIENS;			/* Var globale */

	modif = parpage_general( &flags, &start_box, M_KeyWords_EscObjs, &textes, nb_lignes );

	/*******************************************************************/

	/*
	 * Efface tableau de lignes de la m‚moire:
	 */
	Delete_PszList( textes, nb_lignes );

	/*
	 * Teste  s'il faut sauver les modifs: 
	 */
	if ( modif == YES1 )
	{	/*
		 * Si on a valid‚: 
		 * Efface les anciennes donn‚es: 
		 */
		free_KeyWordList( p_1stEvent );

		/*
		 * Lie la copie modifi‚e, donc les nouvelles donn‚es … la page arbo: 
		 */
		dir_spec -> liens_in = M_pKeyWordList_Copy;

		/*
		 * Signale que le dossier ARBO a ‚t‚ modifi‚:
		 */
		dataDir_setSavState( datadir, SSTATE_MODIFIED, TRUE_1 );
	}
	else
	{	/*
	 	 * On a annul‚: 
		 * Efface la copie des donn‚es: 
		 */
		free_KeyWordList( M_pKeyWordList_Copy );

	}

	/*
	 * On ne doit plus utiliser la copie: 
	 */
	M_TextPar_copies = NULL;

	
}



/*
 * ouverture_menu_arbo(-)
 *
 * Purpose:
 * --------
 * Gestion d'un double clic sur une page arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 14.12.94: signale lorsque la page a ‚t‚ modifi‚e
 * 04.01.94: les Dbases sont trait‚es comme les autres listes de params
 * 22.03.95: correction petit bug sur COMMENTAR
 */
void	ouverture_menu_arbo( 
			WIPARAMS	*	pWiParams )	/* In: fenˆtre menu arbo concern‚e */
{

	switch( pWiParams -> selected_icon )
	{
		case	COMENTAR:
		{
			OBJECT	*	menu_tree = pWiParams -> draw_ptr.tree;
			GRECT			start_box;
			DATAPAGE	*	datapage = pWiParams -> datapage;
							
			/*
			 * (1st func)D‚part de l'effet graphique: 
			 */
			objc_xywh( menu_tree, pWiParams -> selected_icon, &start_box );

			/* 
			 * Edition du commentaire: 
			 */
			if( edit_datapage_comment( datapage, &start_box ) )
			{	/* 
				 * Si on a modifi‚ le commentaire:
				 * Fixe nouveau commentaire: 
				 */
				if ( datapage -> comment != NULL )
				{
					rlink_teptext( &menu_tree[ COMENTAR ], datapage -> comment );
				}
				else
				{
					dlink_teptext( &menu_tree[ COMENTAR ], G_empty_string );
				}
				/*
				 * Signale que la page a ‚t‚ modifi‚e:
				 */
				dataPage_chgSavState( datapage, SSTATE_MODIFIED, TRUE_1, TRUE_1 );
			}
			break;
		}
		
		case	PGESECRA:
			edit_ArboParList( EDIT_PECRAN, pWiParams );
			break;

		case	AFFICHGS:
			edit_ArboParList( EDIT_OUTPUTS, pWiParams );
			break;

		case	SAISIES:
			edit_ArboParList( EDIT_SAISIES, pWiParams );
			break;

		case	ARBDATAS:
			edit_ArboParList( EDIT_DATA, pWiParams );
			break;
		
		case	LIENSARB:
			edit_ArboParList( EDIT_LIENS, pWiParams );
			break;

		case	PARAMS:
			edit_arbopar_params( pWiParams );
			break;
		
		case	MOTSCLEF:
			edit_ArboParList( EDIT_KEYWORDS, pWiParams );
			break;
			
		default:
			ping();

	}
}

                      
      
/*
 * Create_TextParPszList(-)
 *
 * Purpose:
 * --------
 * Cr‚ation des listes pour param‚trage des champs saisie/sortie
 *
 * History:
 * --------
 * 04.12.94: fplanque: Created based on cree_listes_champs()
 */
int Create_TextParPszList( 
			int 					type, 
			ARBO_TEXTPAR  *	pTextPar_First, 	/* In: Ptr sur 1er champ de la liste chain‚e */
			char 			* * *	textes )
{
	/*
	 * Adresses pages ‚cran/liens: 
	 */
	ARBO_TEXTPAR *	pTextPar_Curr;			/* Champ courant */
	int				i;
	int				nb_lignes = 0;			/* Pour l'instant: pas de ligne */
	/*
	 * Variables n‚cessaires … la cr‚ation des lignes: 
	 */
	char	* *	param_array;		/* Tableau contenant les params associ‚s */

	/*
	 * Compte pages: 
	 */
	pTextPar_Curr = pTextPar_First;		/* 1er champ */
	while( pTextPar_Curr != NULL )
	{
		nb_lignes ++;						/* 1 ligne de plus */
		pTextPar_Curr = pTextPar_Curr -> next;
	}
	/*	printf( "Nbre de lignes=%d \n", nb_lignes ); */

	/*
	 * Cr‚e zone de stockage du tableau qui
	 * va contenir les ptrs sur chaque ligne de la liste cr‚e: 
	 */
	param_array = (char * *) MALLOC( sizeof( char* ) * nb_lignes );

	/*
	 * Boucle de remplissage du tableau-LISTE: 
	 */
	pTextPar_Curr = pTextPar_First;		/* 1er champ */
	for( i=0; i<nb_lignes; i++ )
	{
		/*
		 * Page ‚cran ou
		 * Lien arbo ou 
		 * Data (:: base de donn‚es ou texte ) :
		 */
		param_array[ i ] = Create_1PathnamePsz( pTextPar_Curr, type );

		/*	printf( "Ligne: [%s]\n", param_array[ i ] ); */
		
		/*
		 * Page suivante: 
		 */
		pTextPar_Curr = pTextPar_Curr -> next;
	}


	/*
	 * Valeurs en retour: 
	 */
	*textes	= param_array;
	
	return	nb_lignes;

}
      
      
/*
 * Create_FieldPszList(-)
 *
 * Purpose:
 * --------
 * Cr‚ation des listes pour param‚trage des champs saisie/sortie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 04.12.94: Ne cr‚e plus qu'un seul tableau-LISTE
 * 04.12.94: fplanque: renamed from cree_listes_champs()
 */
int Create_FieldPszList( 
			int 					type, 
			ARBO_FIELDPARS  *	first_field, 	/* In: Ptr sur 1er champ de la liste chain‚e */
			char 			* * *	textes )
{
	/*
	 * Adresses pages ‚cran/liens: 
	 */
	ARBO_FIELDPARS	*field_params;			/* Champ courant */
	int				i;
	int				nb_lignes = 0;			/* Pour l'instant: pas de ligne */
	/*
	 * Variables n‚cessaires … la cr‚ation des lignes: 
	 */
	char	* *	param_array;		/* Tableau contenant les params associ‚s */

	/*
	 * Compte pages: 
	 */
	field_params = first_field;		/* 1er champ */
	while( field_params != NULL )
	{
		nb_lignes ++;						/* 1 ligne de plus */
		field_params = field_params -> next;
	}
	/*	printf( "Nbre de lignes=%d \n", nb_lignes ); */

	/*
	 * Cr‚e zone de stockage du tableau qui
	 * va contenir les ptrs sur chaque ligne de la liste cr‚e: 
	 */
	param_array = (char * *) MALLOC( sizeof( char* ) * nb_lignes );

	/*
	 * Boucle de remplissage du tableau-LISTE: 
	 */
	field_params = first_field;		/* 1er champ */
	for( i=0; i<nb_lignes; i++ )
	{
		if ( type == EDIT_OUTPUTS )
		{	/*
			 * Champ de sortie: 
			 */
			param_array[ i ] = Create_1OutFieldPsz( field_params );
		}
		else
		{	/*
			 * Champ de saisie: 
			 */
			param_array[ i ] = Create_1InFieldPsz( field_params );
		}

		/*	printf( "Ligne: [%s]\n", param_array[ i ] ); */
		
		/*
		 * Page suivante: 
		 */
		field_params = field_params -> next;
	}


	/*
	 * Valeurs en retour: 
	 */
	*textes	= param_array;
	
	return	nb_lignes;

}
   
   
/*
 * Create_1PathnamePsz(-)
 *
 * Purpose:
 * --------
 * Cr‚e une ligne de liste pour un chemin d'accŠs
 *
 * History:
 * --------
 * 04.12.94: fplanque: Dervied from Create_1OutFieldPsz()
 * 04.01.94: gŠre EDIT_DATA
 * 05.01.94: ds EDIT_DATA fait la diff‚rence entre DB et TEXT
 */
char	*	Create_1PathnamePsz( 
				ARBO_TEXTPAR *	pTextPar,		/* In: param texte */
				int				n_type )			/* In: Type de param */
{
	const	char	*	cpsz_Fnct = G_empty_string;
	const	char	*	cpsz_GroupName = G_empty_string;
	char			*	pMsz_Ligne = (char *) MALLOC( 45 );		/* R‚serve zone pour string */


	switch( n_type )
	{
		case	EDIT_PECRAN:
			cpsz_Fnct = fnct_spec( M_fnctVdtInput, pTextPar -> fnct_no ) -> fnct_name,
			cpsz_GroupName = find_datagroup_byType( DTYP_PAGES ) -> data_device;
			break;

		case	EDIT_LIENS:
			cpsz_Fnct = fnct_spec( G_fnctlink, pTextPar -> fnct_no ) -> fnct_name;
			cpsz_GroupName = find_datagroup_byType( DTYP_ARBO ) -> data_device;
			break;
			
		case	EDIT_DATA:
			cpsz_Fnct = fnct_spec( M_fnctData, pTextPar -> fnct_no ) -> fnct_name;
			if( pTextPar -> fnct_no < FT_FIRST )
			{	/*
			 	 * Il s'agit d'une fonction DB
			 	 */
				cpsz_GroupName = find_datagroup_byType( DTYP_DATAS ) -> data_device;
				break;
			}
			/*
			 * Il s'agit d'une fonction TEXT
			 */
 			cpsz_GroupName = find_datagroup_byType( DTYP_TEXTS ) -> data_device;
			break;
			
		default:
			ping();
	}


	/*
	 * Cr‚e une chaine r‚sumant les paramŠtres principaux 
	 */
	if( pTextPar -> nom != NULL && pTextPar -> nom != G_empty_string )
	{
		sprintf( pMsz_Ligne, "%14s: %s\\%s",
					cpsz_Fnct, cpsz_GroupName, pTextPar -> nom );
	}
	else
	{
		sprintf( pMsz_Ligne, "%14s: -", cpsz_Fnct );
	}
	
	
	/*
	 * Retourne adresse de la chaine cr‚e: 
	 */
	return	pMsz_Ligne;
}

   
/*
 * Create_1OutFieldPsz(-)
 *
 * Purpose:
 * --------
 * Cr‚e un champ de sortie dans liste
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 24.11.94: gestion enabled
 * 04.12.94: champ inclut sa fonction; changed name from cree_1output_liste
 */
char	*	Create_1OutFieldPsz( 
				ARBO_FIELDPARS *field_params )
{
	char	*champ = (char *) MALLOC( 40 );		/* R‚serve zone pour string */

	/*
	 * Cr‚e une chaine r‚sumant les paramŠtres principaux 
	 */
	if( field_params -> data.output .OutFieldFlags .b_enabled )
	{
		sprintf( champ, "%14s: X=%03d Y=%03d L=%03d H=%03d\0",
					fnct_spec( M_fnctsortie, field_params -> data.fnct_no ) -> fnct_name,
					field_params -> data.output.x, field_params -> data.output.y,
					field_params -> data.output.w, field_params -> data.output.h );
	}
	else
	{
		sprintf( champ, "%14s: D‚sactiv‚...",
					fnct_spec( M_fnctsortie, field_params -> data.fnct_no ) -> fnct_name );
	}
	
	
	/*
	 * Retourne adresse de la chaine cr‚e: 
	 */
	return	champ;
}



/*
 * Delete_PszList(-)
 *
 * Efface tableau-liste de psz de la m‚moire
 *
 * History:
 * --------
 * 04.12.94: fplanque: Created
 */
void	Delete_PszList(
			char * * Tpsz_List,	/* In: tableau de psz */
			int		nb_lines )	/* In: Nbre de lignes ds tableau */
{
	int i;

	for( i=0; i<nb_lines; i++ )
	{	/* 
		 * libŠre la m‚moire: 
		 */
		free_String( Tpsz_List[ i ] );
	}
	
	/*
	 * LibŠre le tableau lui mˆme:
	 */
	FREE( Tpsz_List );	 
}


/*
 * Create_1InFieldPsz(-)
 *
 * Purpose:
 * --------
 * Cree un champ de saisie de liste 
 *
 * Notes:
 * ------
 * format:
 * Fnct X=___ Y=___ W=___ H=___ X. #1 #7 
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 24.11.94: gestion enabled
 * 04.12.94: champ inclut sa fonction; changed name from cree_1champ_liste()
 */
char	*	Create_1InFieldPsz ( 
				ARBO_FIELDPARS *field_params )
{
	char	*champ = (char *) MALLOC( 45 );		/* R‚serve zone pour string */

	if( field_params -> data.input .InFieldFlags .b_enabled )
	{
		char	car1	= 'T';				/* Exemple */
		char	car2	= 't';				/* Exemple */
		char	fill	= CEMPTY;			/* Remplissage */
		int	cache	= field_params -> data.input.asc_cach;	/* cache */

		/* Traitement du cache: */
		/* (sans cache <=> NUL) */
		if ( cache == NIL )
		{	/* Transparent */
			car1 = CEMPTY;
			car2 = CEMPTY;
		}
		else if ( cache >= ' ' )
		{	/* Il y a un cache */
			car1 = cache;
			car2 = cache;
		}

		/*
		 * Traitement du fill 
		 */
		if ( field_params -> data.input.asc_fill >= ' ' )
		{	/* S'il y a un caractŠre de support: */
			fill = field_params -> data.input.asc_fill;
		}
		
		/*
		 * Cr‚e une chaine r‚sumant les paramŠtres principaux 
		 */
		sprintf( champ, "%14s: X=%03d Y=%03d L=%03d H=%03d %c%c%c%c\0",
					fnct_spec( M_fnctVdtInput, field_params -> data.fnct_no ) -> fnct_name,
					field_params -> data.input.x, field_params -> data.input.y,
					field_params -> data.input.w, field_params -> data.input.h,
					car1, car2, fill, fill );
	}
	else
	{
		sprintf( champ, "%14s: D‚sactiv‚...",
					fnct_spec( M_fnctVdtInput, field_params -> data.fnct_no ) -> fnct_name );
	}

	/*
	 * Retourne adresse de la chaine cr‚e: 
	 */
	return	champ;
}


/*
 * edpgecr_callselect(-)
 *
 * Purpose:
 * --------
 * Appel d'un s‚lecteur d'objet lors du traitement de params en liste
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 05.01.94: D‚termine la ligne concern‚e avec get_no_selitem()
 * 04.12.94: travaille d‚sormais sur une r‚elle copie des paramŠtres en m‚moire
 * 04.01.95: traite les EDIT_DATA
 * 05.01.94: dans EDIT_DATA, fait la diff‚rence entre DB et TEXT
 */
void	edpgecr_callselect( 
			LISTHANDLES *	list_handles, 
			int 				call_obj )
{
	char			*	sel_titre;		/* Titre que le s‚lecteur devra afficher */
	DATAGROUP	*	sel_datagr;		/* Datagroup dans lequel on va choisir une page */
	RAMSEL			selection;
	char			*	sel_page = NULL;	/* Va recevoir s‚lection */
	/*
	 * Trouve les paramŠtres concern‚s:
	 */
	int				concerned_line = get_no_selitem( list_handles );
	ARBO_TEXTPAR * pTextPar = Get_ithTextParInList( M_TextPar_copies, concerned_line );
	
	/*
	 * Pointeur sur le DATAGROUP concern‚: 
	 */
	switch( M_edit_pecr_type )
	{
		case	EDIT_PECRAN:
			/*
		 	 * Si on veut s‚lectionner une page ‚cran: 
		 	 */
			sel_titre = "S‚lection d'une Page Ecran:";
			sel_datagr = find_datagroup_byType( DTYP_PAGES );
			break;

		case	EDIT_LIENS:
			/*
		 	 * Si on veut s‚lectionner une page ARBO: 
		 	 */
			sel_titre = "S‚lection d'une Page Arbo:";
			sel_datagr = find_datagroup_byType( DTYP_ARBO );
			break;
			
		case	EDIT_DATA:
			/*
		 	 * Si on veut s‚lectionner une donn‚e: 
		 	 */
			if( pTextPar -> fnct_no < FT_FIRST )
			{	/*
				 * Il s'agit d'une DB:
				 */
				sel_titre = "S‚lection d'une Base de Donn‚es:";
				sel_datagr = find_datagroup_byType( DTYP_DATAS );
				break;
			}
			/*
			 * Il s'agit d'un TEXT:
			 */
			sel_titre = "S‚lection d'un Texte:";
			sel_datagr = find_datagroup_byType( DTYP_TEXTS );
			break;

		default:
			ping();
	}
					
	/*
	 * S‚lecteur RAM: 
	 */
	selection = ramselect_fromForm( sel_titre, sel_datagr, &sel_page,
									M_pForm_EditArboKeyWords, call_obj );

	if( selection != RAMSEL_ABORT )
	{	/*
		 * On a valid‚: 
		 * Tableau contenant les chemins d'accŠs 
		 */
		char	* *path_array = *(list_handles -> pTpsz_array);
		char	* *resume = &path_array[ concerned_line ];

		/*
		 * Remplace nom de la page ds param:
		 */
		if( selection == RAMSEL_FILE )
		{	/*
			 * Nouveau nom 
			 */
			free_String( pTextPar -> nom );
			pTextPar -> nom = dup_String( &sel_page[5] );
		}
		else
		{	/*
			 * Pas de nom s‚lectionn‚ 
			 */
			free_String( pTextPar -> nom );
			pTextPar -> nom = NULL;
		}
		 
	
		/*
		 * LibŠre ancienne ligne:
		 */
		free_String( *resume );

		/*
		 * Cr‚e nouvelle ligne:
		 */
		*resume = Create_1PathnamePsz( pTextPar, M_edit_pecr_type );

		/*
		 * Modifie la ligne dans le formulaire: 
		 */
		list_fix1name( M_pForm_EditArboKeyWords, list_handles -> selected_line, *resume );

	}
}


/*
 * Select_TermPosWithMouse(-)
 *
 * S‚lection d'un emplacement sur le Termial 
 * avec la souris de l'ordinateur
 *
 * Notes:
 * ------
 * -On considŠre que les op‚rations:
 *		wind_update( BEG_UPDATE );			
 *		wind_update( BEG_MCTRL );		
 * 	ont d‚j… ‚t‚ effectu‚es et qu'on possŠde la souris en toute tranquilit‚
 *
 * -Suppose que le term … moins de caractŠres que l'‚cran n'a de pixels!
 *
 * History:
 * --------
 * 01.12.94: fplanque: Created
 */
void	Select_TermPosWithMouse( 
			OBJECT	*	pObj_FeedbackForm,	/* In: Formulaire de feedaback */
			int			n_IdxXField,			/* In: Onjet pour valeur X */
			int			n_IdxYField, 			/* In: Objet pour valeur Y */
			int			n_XOrigin,				/* In: Point … consid‚rer comme l'origine */
			int			n_YOrigin )
{
	/* Taille terminal: */
	int	n_TermW = 40;
	int	n_TermH = 25;
	/* Taille Equivalente Ecran d'un caractŠre terminal */
	int	n_VirtualScreenCellW = G_n_ScreenW / n_TermW;
	int	n_VirtualScreenCellH = G_n_ScreenH / n_TermH;
	/* EvŠnement qui s'est d‚clench‚: */
	int	n_drag_evt;
	/* Coordonn‚es sur ‚cran: */
	int	n_ScreenX = 0;
	int	n_ScreenY = 0;
	/* Coordonn‚es su Minitel */
	int	n_TermX, n_TermY;
	/* Non utilis‚s */
	int	n_new_bstate, n_kbd_state, n_kbd_return, n_mouse_nbc;	

	char	Tsz_buf[ 10 ];

	/*
	 * Forme souris: 
	 */
	graf_mouse( POINT_HAND, NULL );	

	/*
	 * Attend relachement du bouton souris:
	 * Pas variment n‚cessaire
	 * PAR CONTRE: on en profite pour r‚cup‚rer les coordonn‚es actuelles de la souris:
	 */
	evnt_button( 0, 0x01, 0x00, 
  					&n_ScreenX, &n_ScreenY, &n_new_bstate, &n_kbd_state );

	/*
	 * Allume curseur sur minitel:
	 */
	csr_on( G_term_dev );

	/*
	 * Boucle de mouvement: 
	 */
	do
	{	
		/*
		 * calcule ‚quivalent minitel des coordonn‚es de la souris:
		 */
		n_TermX = n_ScreenX * n_TermW / G_n_ScreenW;
		n_TermY = n_ScreenY * n_TermH / G_n_ScreenH;

		/*
		 * Positionne curseur sur minitel:
		 */
		pos( G_term_dev, n_TermX + 1, n_TermY );

		/*
		 * Feedback de la position ds forumulaire:
		 */
		itoa( n_TermX-n_XOrigin +1, Tsz_buf, 10 );
		fix_ftext( pObj_FeedbackForm, n_IdxXField, Tsz_buf );
		objc_draw( pObj_FeedbackForm, n_IdxXField, 1, 
							pObj_FeedbackForm -> ob_x,
							pObj_FeedbackForm -> ob_y,
							pObj_FeedbackForm -> ob_width,
							pObj_FeedbackForm -> ob_height );

		itoa( n_TermY-n_YOrigin, Tsz_buf, 10 );
		fix_ftext( pObj_FeedbackForm, n_IdxYField, Tsz_buf );
		objc_draw( pObj_FeedbackForm, n_IdxYField, 1, 
							pObj_FeedbackForm -> ob_x,
							pObj_FeedbackForm -> ob_y,
							pObj_FeedbackForm -> ob_width,
							pObj_FeedbackForm -> ob_height );

		/*
		 * Attend qu'il se passe qque chose: 
		 */
		n_drag_evt = evnt_multi( MU_BUTTON | MU_M1,
								1, 0x01, 0x01,									/* Observe la pression du bouton gauche */
                        1, n_TermX * n_VirtualScreenCellW, n_TermY * n_VirtualScreenCellH, n_VirtualScreenCellW, n_VirtualScreenCellH,	/* Observe tout d‚placement de la souris */ 
                        0, 0, 0, 0, 0,
                        0L, 
                        0, 0,
                        &n_ScreenX, &n_ScreenY, &n_new_bstate,
                        &n_kbd_state, &n_kbd_return,
                        &n_mouse_nbc);

		/* ping(); */
		
	} while( n_drag_evt != MU_BUTTON );

	/*
	 * Attend relachement du bouton souris:
	 */
	evnt_button( 0, 0x01, 0x00, 
  					&n_ScreenX, &n_ScreenY, &n_new_bstate, &n_kbd_state );


	/*
	 * Remet ds ‚tat normal:
	 */
	csr_off( G_term_dev );

	graf_mouse( ARROW, NULL );	
}



/*
 * parapg_parasaisie(-)
 *
 * Purpose:
 * --------
 * ParamŠtres d'un champ de saisie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 05.01.94: obtient no ligne concernee avec get_no_selitem()
 * 24.11.94: gestion enabled
 * 03.12.94: control ranges
 * 08.12.94: multiparagraph
 * 03.12.94: b_Mandatory
 * 16.12.94: nouveaux params
 * 12.01.95: flags reverse
 * 23.01.95: gestion du champ CodeChamp
 */
void	parapg_parasaisie( 
			LISTHANDLES *	list_handles, 
			OBJECT 		*	arbre_fond, 
			int 				call_obj )
{

	/* 
	 * Ligne/Champ concern‚: 
	 */
	int		concerned_line = get_no_selitem( list_handles );

	ARBO_FIELDPARS	*	field_params = Get_ithEltInSingleLinkList( M_fieldpar_copies, concerned_line );
	FNCTSPEC			*	field_fnspec;		/* Sp‚cifications de la fnct du champ */

	/*
	 * Objets: 
	 */
	char	*	field_x = (M_pForm_EditInFields[ CHAMP_X ] .ob_spec.tedinfo) -> te_ptext;
	char	*	field_y = (M_pForm_EditInFields[ CHAMP_Y ] .ob_spec.tedinfo) -> te_ptext;
	char	*	field_w = (M_pForm_EditInFields[ CHAMP_L ] .ob_spec.tedinfo) -> te_ptext;
	char	*	field_h = (M_pForm_EditInFields[ CHAMP_H ] .ob_spec.tedinfo) -> te_ptext;

	/*
	 * Variables: 
	 */
	int	edit_obj = CHAMP_X;	/* Objet en cours d'‚dition */
	int	exit_obj;				/* Bouton Exit cliqu‚ */
	GRECT	start_box, form_box;


	INFIELD_FLAGS	InFieldFlags = field_params -> data.input .InFieldFlags;
	
	/*
	 * Fixe les valeurs dans le formulaire: 
 	 * Enabled:
	 */
	objc_fixsel( M_pForm_EditInFields, EN_EDIT, InFieldFlags.b_enabled );

	objc_fixsel( M_pForm_EditInFields, INVSUP, InFieldFlags.b_ReverseSupp );
	objc_fixsel( M_pForm_EditInFields, INVTEXT, InFieldFlags.b_ReverseText );


	/*
	 * Nom du champ: 
	 */
	field_fnspec = fnct_spec( M_fnctVdtInput, field_params -> data.fnct_no );
	M_pForm_EditInFields[ EDEDIT_C ] .ob_spec.free_string = field_fnspec -> fnct_name;
	/*
	 * Emplacement: 
	 */
	itoa( field_params -> data.input.x, field_x, 10 );	/* Conversion d‚cimale */
	itoa( field_params -> data.input.y, field_y, 10 );
	itoa( field_params -> data.input.w, field_w, 10 );
	itoa( field_params -> data.input.h, field_h, 10 );
	/*
	 * ParamŠtres:
	 */
	objc_fixsel( M_pForm_EditInFields, EDMULTIP, InFieldFlags .b_MultiParagraph );
	objc_fixsel( M_pForm_EditInFields, EDOBLIGA, InFieldFlags .b_Mandatory );
	objc_fixsel( M_pForm_EditInFields, EDAFFIMM, InFieldFlags .b_DisplayImm );
	objc_fixsel( M_pForm_EditInFields, EDAFFENT, InFieldFlags .b_DisplayEnt );
	objc_fixsel( M_pForm_EditInFields, EDAFFTJS, InFieldFlags .b_DisplayTjs );
	/*
	 * Pop_ups: 
	 */
	fix_popup_title( &M_pForm_EditInFields[ EDITSUP ], M_fill_menu,  field_params -> data.input.asc_fill );
	fix_popup_title( &M_pForm_EditInFields[ EDITCACH ], M_cach_menu, field_params -> data.input.asc_cach );
	fix_popup_title( &M_pForm_EditInFields[ COLSUP ],  M_color_menu, field_params -> data.input.col_fill );
	fix_popup_title( &M_pForm_EditInFields[ COLTEXT ], M_color_menu, field_params -> data.input.col_text );
	fix_popup_title( &M_pForm_EditInFields[ EDFILTER ], M_Popup_FilterMenu, field_params -> data.input.n_Filter );

	/*
	 * Champs de saisie:
	 */
	ltoa( field_params -> data.input .l_MaxNbLines, G_tmp_buffer, 10 );
	fix_ftext( M_pForm_EditInFields, EDMAXLIN, G_tmp_buffer );
	strncpy( G_tmp_buffer, (char*) &(field_params -> data.input .ul_CodeChamp), 4 );
	G_tmp_buffer[4]= '\0';
	fix_ftext( M_pForm_EditInFields, INFLCODE, G_tmp_buffer );
	fix_ftext( M_pForm_EditInFields, EDEFAULT, field_params -> data.input .psz_DefText );
	/*
	 * Coord de d‚part du grow_box= 
	 */
	objc_xywh( arbre_fond, call_obj, &start_box );

	/*
	 * Gestion formulaire: 
	 * vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	 */
	open_dialog( M_pForm_EditInFields, &start_box, &form_box );

	for( ; ; )
	{
		/*
		 * Gestion form jusqu'… un clic sur objet exit:
		 */
		exit_obj=ext_form_do( M_pForm_EditInFields, &edit_obj);	/* Gestion de la boŒte */
		/*	exit_obj &= 0x7FFF;		/* Masque bit 15 (Double-clic) */
		/*
		 * Teste si on cherche … sortir: 
		 */
		if ( exit_obj == EDEDTVAL  ||  exit_obj == EDEDTANN )
		{
			break;
		}

		/*
		 * Traitement des autres boutons: 
		 */
		switch( exit_obj )
		{
			case	POS_CHAM:
				/*
				 * Positionnement Souris/Minitel:
				 */
				Select_TermPosWithMouse( M_pForm_EditInFields, CHAMP_X, CHAMP_Y, 0, 0 );
				objc_dsel( M_pForm_EditInFields, exit_obj );
				break;
				
			case	TAIL_CHA:
				/*
				 * Positionnement Souris/Minitel:
				 */
				Select_TermPosWithMouse( M_pForm_EditInFields, CHAMP_L, CHAMP_H, atoi( field_x )-1, atoi( field_y )-1 );
				objc_dsel( M_pForm_EditInFields, exit_obj );
				break;
				
			case	EDITSUP:
			case	EDITCACH:
			case	COLSUP:
			case	COLTEXT:
			case	EDFILTER:
			{	/*
			 	 * S‚lection du motif de fond: 
			 	 */
				int			selected;		/* Ligne s‚lectionn‚e */
				POPUP_ENTRY	*entries;		/* Liste pour menu: */
				
				/* Fix Ptr sur liste appropri‚e: */
				switch( exit_obj )
				{
					case	EDITSUP:
						entries = M_fill_menu;
						break;
						
					case	EDITCACH:
						entries = M_cach_menu;
						break;
					
					case	EDFILTER:
						entries = M_Popup_FilterMenu;
						break;
						
					default:
						entries = M_color_menu;
				}								
					
				/*
				 * Appelle le Pop-Up: 
				 */
				selected = popup_inform( M_pForm_EditInFields, exit_obj, exit_obj, entries,
								 Popup_GetCurrVal( &M_pForm_EditInFields[ exit_obj ] ) );
				if ( selected != ABORT_2 )
				{
					fix_popup_title( &M_pForm_EditInFields[ exit_obj ], entries, selected );
					objc_draw( M_pForm_EditInFields, exit_obj, 1, form_box .g_x,
	                       form_box .g_y, form_box .g_w, form_box .g_h );
				}
				break;
			}
			
			default:
				ping();
		}
	
		graf_mouse( ARROW, 0);					/* souris: FlŠche */
	}

	graf_mouse( BUSYBEE, 0);				/* souris: Abeille */
	close_dialog( M_pForm_EditInFields, exit_obj, &start_box, &form_box );
	/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	/* D‚s‚lectionne bouton de sortie: */
	objc_clrsel( M_pForm_EditInFields, exit_obj );

	/* Red‚ssinne le fond: */
	objc_draw( arbre_fond, 0, 5, form_box .g_x, form_box .g_y, form_box .g_w, form_box .g_h );

	/*
	 * Sauvegarde des valeurs ‚dit‚es: 
	 */
	if ( exit_obj == EDEDTVAL )
	{	/*
		 * Si on a confirm‚: 
		 * Variables: 
		 */
		char	* *path_array = *(list_handles -> pTpsz_array);
		char	* *resume = &path_array[ concerned_line ];	/* R‚sum‚ des paramŠtres */

		/*
		 * Sauvegarde: 
		 * Enabled:
		 */
		InFieldFlags .b_enabled = objc_testsel( M_pForm_EditInFields, EN_EDIT );
		InFieldFlags .b_MultiParagraph = objc_testsel( M_pForm_EditInFields, EDMULTIP );
		InFieldFlags .b_Mandatory = objc_testsel( M_pForm_EditInFields, EDOBLIGA );
		InFieldFlags .b_DisplayImm = objc_testsel( M_pForm_EditInFields, EDAFFIMM );
		InFieldFlags .b_DisplayEnt = objc_testsel( M_pForm_EditInFields, EDAFFENT );
		InFieldFlags .b_DisplayTjs = objc_testsel( M_pForm_EditInFields, EDAFFTJS );
		InFieldFlags .b_ReverseSupp = objc_testsel( M_pForm_EditInFields, INVSUP );
		InFieldFlags .b_ReverseText = objc_testsel( M_pForm_EditInFields, INVTEXT );
		field_params -> data.input .InFieldFlags = InFieldFlags;

		/*
		 * Emplacement: 
		 */
		field_params -> data.input.x = ctrl_IntRange( atoi( field_x ), 1, 40 );
		field_params -> data.input.y = ctrl_IntRange( atoi( field_y ), 1, 24 );
		field_params -> data.input.w = ctrl_IntRange( atoi( field_w ), 1, 41 - field_params -> data.output.x );
		field_params -> data.input.h = ctrl_IntRange( atoi( field_h ), 1, 25 - field_params -> data.output.y );
		/*
		 * Pop-Ups: 
		 */
		field_params -> data.input.asc_fill = Popup_GetCurrVal( &M_pForm_EditInFields[ EDITSUP ]   );
		field_params -> data.input.asc_cach = Popup_GetCurrVal( &M_pForm_EditInFields[ EDITCACH ]  );
		field_params -> data.input.col_fill = Popup_GetCurrVal( &M_pForm_EditInFields[ COLSUP ] 	 );
		field_params -> data.input.col_text = Popup_GetCurrVal( &M_pForm_EditInFields[ COLTEXT ]   );
		field_params -> data.input.n_Filter = Popup_GetCurrVal( &M_pForm_EditInFields[ EDFILTER ]  );
		/*
		 * Champs de saisie:
		 */
		field_params -> data.input .l_MaxNbLines = atol( M_pForm_EditInFields[ EDMAXLIN ] .ob_spec.tedinfo -> te_ptext );

		free_String( field_params -> data.input .psz_DefText ); /* LibŠre ancien texte par d‚faut */
		field_params -> data.input .psz_DefText = extract_ftext( M_pForm_EditInFields, EDEFAULT );

		memset( &(field_params -> data.input .ul_CodeChamp), '\0', 4 );
		strncpy( (char *) &(field_params -> data.input .ul_CodeChamp), M_pForm_EditInFields[ INFLCODE ] .ob_spec.tedinfo -> te_ptext, 4 );

		/* 
		 * Modifie la ligne dans le formulaire: 
		 * Efface ancienne ligne: 
		 */
		free_String( *resume );		/* LibŠre ancien contenu */

		/*
		 * Cr‚e nouvelle ligne et place ptr dans tableau: 
		 */
		*resume = Create_1InFieldPsz( field_params );
		
		/*
		 * Fixe nlle ligne:
		 */
		list_fix1name( M_pForm_EditArboKeyWords, list_handles -> selected_line, *resume );

	}

}





/*
 * parapg_parasortie(-)
 *
 * Purpose:
 * --------
 * ParamŠtres d'un champ de sortie/affichage
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 05.01.94: obtient no ligne concernee avec get_no_selitem()
 * 24.11.94: gestion enabled
 * 03.12.94: control ranges
 * 12.01.95: flags reverse
 * 13.01.95: flag CLEAR
 * 23.01.95: gestion du champ CodeChamp, GroupId
 * 25.03.95: gestion popup format date
 * 26.03.95: formats suppl‚mentaires
 */
void	parapg_parasortie( 
			LISTHANDLES *	list_handles, 
			OBJECT 		*	arbre_fond, 
			int 				call_obj )
{
	/*
	 * Ligne/Champ concern‚: 
	 */
	int		concerned_line = get_no_selitem( list_handles );
	ARBO_FIELDPARS	*field_params = Get_ithEltInSingleLinkList( M_fieldpar_copies, concerned_line );
	FNCTSPEC	*field_fnspec;				/* Sp‚cifications de la fnct du champ */

	char	*	field_x = (M_pForm_EditOutFields[ AFFZ_X ] .ob_spec.tedinfo) -> te_ptext;
	char	*	field_y = (M_pForm_EditOutFields[ AFFZ_Y ] .ob_spec.tedinfo) -> te_ptext;
	char	*	field_w = (M_pForm_EditOutFields[ AFFZ_W ] .ob_spec.tedinfo) -> te_ptext;
	char	*	field_h = (M_pForm_EditOutFields[ AFFZ_H ] .ob_spec.tedinfo) -> te_ptext;
	char	*	pBsz_GroupID = (M_pForm_EditOutFields[ OUTGRPID ] .ob_spec.tedinfo) -> te_ptext;
	POPUP_ENTRY	* pPopUp;		/* Liste pour menu Format */

	int	edit_obj = AFFZ_X;	/* Objet en cours d'‚dition */
	int	exit_obj;				/* Bouton Exit cliqu‚ */
	GRECT	start_box, form_box;

	OUTFIELD_FLAGS	OutFieldFlags = field_params -> data.output .OutFieldFlags;

	/*
	 * Fixe les valeurs dans le formulaire:
	 * Enabled:
	 */
	objc_fixsel( M_pForm_EditOutFields, EN_DISP,  OutFieldFlags.b_enabled );
	objc_fixsel( M_pForm_EditOutFields, AFFZINVT, OutFieldFlags.b_ReverseText );
	objc_fixsel( M_pForm_EditOutFields, AFFZINVI, OutFieldFlags.b_ReverseInfo );
	objc_fixsel( M_pForm_EditOutFields, AFFCLEAR, OutFieldFlags.b_Clear );
	/*
	 * Nom du champ: 
	 */
	field_fnspec = fnct_spec( M_fnctsortie, field_params -> data.fnct_no );
	M_pForm_EditOutFields[ AFFZ_FLD ] .ob_spec.free_string = field_fnspec -> fnct_name;
	/*
	 * Pop_ups:
	 * D‚termine d'abord quel menu format il faut utiliser:
	 */
	switch( field_params -> data.fnct_no )
	{
		case	FO_RECNUMBER:
		case	FO_PAGENUMBER:
		case	FO_NBFILES:
			pPopUp = M_FmtNumber_menu;
			break;

		case	FO_CREATEDATE:
		case	FO_FILEDATE:
			pPopUp = M_FmtDate_menu;
			break;

		case	FO_FILESIZE:
			pPopUp = M_FmtFileSize_menu;
			break;
	
		default:
			pPopUp = M_Format_menu;
	}
	fix_popup_title( &M_pForm_EditOutFields[ AFFZTCOL ], M_color_menu, field_params -> data.output.col_text );
	fix_popup_title( &M_pForm_EditOutFields[ AFFZICOL ], M_color_menu, field_params -> data.output.col_info ); 
	fix_popup_title( &M_pForm_EditOutFields[ AFFZFMT ], pPopUp, field_params -> data.output.n_Format ); 
	/*
	 * Emplacement: 
	 */
	itoa( field_params -> data.output.x, field_x, 10 );	/* Conversion d‚cimale */
	itoa( field_params -> data.output.y, field_y, 10 );
	itoa( field_params -> data.output.w, field_w, 10 );
	itoa( field_params -> data.output.h, field_h, 10 );
	/*
	 * Champs ‚ditables:
	 */
	strncpy( G_tmp_buffer, (char*) &(field_params -> data.output .ul_CodeChamp), 4 );
	G_tmp_buffer[4]= '\0';
	fix_ftext( M_pForm_EditOutFields, OUTFCODE, G_tmp_buffer );

	itoa( OutFieldFlags.u_GroupId, pBsz_GroupID, 10 );

	/*
	 * Coord de d‚part du grow_box:
	 */
	objc_xywh( arbre_fond, call_obj, &start_box );

	/* Gestion formulaire: */
	/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
	open_dialog( M_pForm_EditOutFields, &start_box, &form_box );

	for( ; ; )
	{	/* 
		 * Gestion form jusqu'… un clic sur objet exit 
		 */
		exit_obj=ext_form_do( M_pForm_EditOutFields, &edit_obj);	/* Gestion de la boŒte */
		/*	exit_obj &= 0x7FFF;		/* Masque bit 15 (Double-clic) */

		/* 
		 * Teste si on cherche … sortir: 
		 */
		if ( exit_obj == AFFZ_VAL  ||  exit_obj == AFFZ_ANN )
			break;

		/* 
		 * Traitement des autres boutons: 
		 */
		switch( exit_obj )
		{
			case	AFFZ_POS:
				/*
				 * Positionnement Souris/Minitel:
				 */
				Select_TermPosWithMouse( M_pForm_EditOutFields, AFFZ_X, AFFZ_Y, 0, 0 );
				objc_dsel( M_pForm_EditOutFields, exit_obj );
				break;
				
			case	AFFZSIZE:
				/*
				 * Positionnement Souris/Minitel:
				 */
				Select_TermPosWithMouse( M_pForm_EditOutFields, AFFZ_W, AFFZ_H, atoi( field_x )-1, atoi( field_y )-1 );
				objc_dsel( M_pForm_EditOutFields, exit_obj );
				break;
				
			case	AFFZTCOL:
			case	AFFZICOL:
			case	AFFZFMT:
			{	/* 
				 * S‚lection du motif de fond: 
				 */
				int			selected;		/* Ligne s‚lectionn‚e */
				POPUP_ENTRY	*entries;		/* Liste pour menu: */
				
				/* 
				 * Fix Ptr sur liste appropri‚e: 
				 */
				if( exit_obj == AFFZFMT )
				{
					entries = pPopUp;
				}
				else
				{
					entries = M_color_menu;
				}
					
				/*
				 * Appelle le Pop-Up: 
				 */
				selected = popup_inform( M_pForm_EditOutFields, exit_obj, exit_obj, entries,
								 Popup_GetCurrVal( &M_pForm_EditOutFields[ exit_obj ] ) );
				if( selected != ABORT_2 )
				{
					fix_popup_title( &M_pForm_EditOutFields[ exit_obj ], entries, selected );
					objc_draw( M_pForm_EditOutFields, exit_obj, 1, form_box .g_x,
	                       form_box .g_y, form_box .g_w, form_box .g_h );
				}
				break;
			}
			
			default:
				ping();
		}
		
		graf_mouse( ARROW, 0);					/* souris: FlŠche */
	}

	graf_mouse( BUSYBEE, 0);				/* souris: Abeille */
	close_dialog( M_pForm_EditOutFields, exit_obj, &start_box, &form_box );
	/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	/* D‚s‚lectionne bouton de sortie: */
	objc_clrsel( M_pForm_EditOutFields, exit_obj );

	/* Red‚ssinne le fond: */
	objc_draw( arbre_fond, 0, 5, form_box .g_x, form_box .g_y, form_box .g_w, form_box .g_h );

	/*
	 * Sauvegarde des valeurs ‚dit‚es: 
	 */
	if ( exit_obj == AFFZ_VAL )
	{	/*
		 * Si on a confirm‚: 
		 * Variables: 
		 */
		char	* *path_array = *(list_handles -> pTpsz_array);
		char	* *resume = &path_array[ concerned_line ];	/* R‚sum‚ des paramŠtres */

		/* 
		 * Sauvegarde: 
		 * Enabled:
		 */
		OutFieldFlags .b_enabled = objc_testsel( M_pForm_EditOutFields, EN_DISP );
		OutFieldFlags .b_ReverseText = objc_testsel( M_pForm_EditOutFields, AFFZINVT );
		OutFieldFlags .b_ReverseInfo = objc_testsel( M_pForm_EditOutFields, AFFZINVI );
		OutFieldFlags .b_Clear = objc_testsel( M_pForm_EditOutFields, AFFCLEAR );
		/*
		 * Pop-Ups: 
		 */
		field_params -> data.output.col_text = Popup_GetCurrVal( &M_pForm_EditOutFields[ AFFZTCOL ] );
		field_params -> data.output.col_info = Popup_GetCurrVal( &M_pForm_EditOutFields[ AFFZICOL ] );
		field_params -> data.output.n_Format = Popup_GetCurrVal( &M_pForm_EditOutFields[ AFFZFMT ] );
		/*
		 * Emplacement: 
		 */
		field_params -> data.output.x = ctrl_IntRange( atoi( field_x ), 1, 40);
		field_params -> data.output.y = ctrl_IntRange( atoi( field_y ), 1, 24);
		field_params -> data.output.w = ctrl_IntRange( atoi( field_w ), 1, 41 - field_params -> data.output.x );
		field_params -> data.output.h = ctrl_IntRange( atoi( field_h ), 1, 25 - field_params -> data.output.y );
		/*
		 * Champs de saisie:
		 */
		memset( &(field_params -> data.output .ul_CodeChamp), '\0', 4 );
		strncpy( (char *) &(field_params -> data.output .ul_CodeChamp), M_pForm_EditOutFields[ OUTFCODE ] .ob_spec.tedinfo -> te_ptext, 4 );

		OutFieldFlags.u_GroupId = ctrl_IntRange( atoi( pBsz_GroupID ), 0, 7);


		field_params -> data.output .OutFieldFlags = OutFieldFlags;


		/* 
		 * Modifie la ligne dans le formulaire: 
		 * Efface ancienne ligne: 
		 */
		free_String( *resume );	

		/* 
		 * Cr‚e nouvelle ligne et place ptr dans tableau: 
		 */
		*resume = Create_1OutFieldPsz( field_params );
		
		/* 
		 * Fixe nlle ligne:
		 */
		list_fix1name( M_pForm_EditArboKeyWords, list_handles -> selected_line, *resume );
	}

}





/*
 * parapg_paralist(-)
 *
 * Purpose:
 * --------
 * ParamŠtrage d'une liste
 *
 * History:
 * --------
 * 26.01.95: fplanque: Created based on parapg_parasortie()
 */
void	parapg_paralist( 
			ARBO_LISTPARS	*	pArboListPars,	/* In: ParamŠtres … modifier */
			OBJECT 			*	arbre_fond, 
			int 					call_obj )
{
	/*
	 * Objets: 
	 */
	char	*	field_nbl = (M_pForm_EditListPars[ LISTNBL ] .ob_spec.tedinfo) -> te_ptext;
	char	*	field_nbc = (M_pForm_EditListPars[ LISTNBC ] .ob_spec.tedinfo) -> te_ptext;
	char	*	field_intl = (M_pForm_EditListPars[ LISTINTL ] .ob_spec.tedinfo) -> te_ptext;
	char	*	field_intc = (M_pForm_EditListPars[ LISTINTC ] .ob_spec.tedinfo) -> te_ptext;

	int	edit_obj = LISTNBL;	/* Objet en cours d'‚dition */
	int	exit_obj;				/* Bouton Exit cliqu‚ */
	GRECT	start_box, form_box;

	/*
	 * Fixe les valeurs dans le formulaire:
	 */
	itoa( pArboListPars -> nb_Lines, field_nbl, 10 );	/* Conversion d‚cimale */
	itoa( pArboListPars -> nb_Cols, field_nbc, 10 );
	itoa( pArboListPars -> n_InterLine, field_intl, 10 );
	itoa( pArboListPars -> n_InterCol, field_intc, 10 );

	/*
	 * Coord de d‚part du grow_box:
	 */
	objc_xywh( arbre_fond, call_obj, &start_box );

	/*
	 * Gestion formulaire: 
	 *vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	 */
	open_dialog( M_pForm_EditListPars, &start_box, &form_box );

	for( ; ; )
	{	/* 
		 * Gestion form jusqu'… un clic sur objet exit 
		 */
		exit_obj=ext_form_do( M_pForm_EditListPars, &edit_obj);	/* Gestion de la boŒte */
		/*	exit_obj &= 0x7FFF;		/* Masque bit 15 (Double-clic) */

		/* 
		 * Teste si on cherche … sortir: 
		 */
		if( exit_obj == LISTVAL || exit_obj == LISTANNU )
		{
			break;
		}
		
		graf_mouse( ARROW, 0);					/* souris: FlŠche */
	}

	graf_mouse( BUSYBEE, 0);				/* souris: Abeille */
	close_dialog( M_pForm_EditListPars, exit_obj, &start_box, &form_box );
	/*
	 *^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	 */

	/*
	 * D‚s‚lectionne bouton de sortie: 
	 */
	objc_clrsel( M_pForm_EditListPars, exit_obj );

	/*
	 * Red‚ssinne le fond: 
	 */
	objc_draw( arbre_fond, 0, 5, form_box .g_x, form_box .g_y, form_box .g_w, form_box .g_h );

	/*
	 * Sauvegarde des valeurs ‚dit‚es: 
	 */
	if( exit_obj == LISTVAL )
	{	/*
		 * Si on a confirm‚: 
		 */
		pArboListPars -> nb_Lines		= ctrl_IntRange( atoi( field_nbl ), 1, 24);
		pArboListPars -> nb_Cols		= ctrl_IntRange( atoi( field_nbc ), 1, 40);
		pArboListPars -> n_InterLine = ctrl_IntRange( atoi( field_intl ), 1, 24);
		pArboListPars -> n_InterCol	= ctrl_IntRange( atoi( field_intc ), 1, 40);
	}

}



/*
 * replace_tmp_paramstring(-)
 *
 * Purpose:
 * --------
 * Remplace chaine de stockage temporaire d'un paramŠtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 24.05.94: utilisation de free_String()
 */
void	replace_tmp_paramstring( char * *paramstring, char *new_content, int selection )
{
	if ( selection == RAMSEL_FILE )
	{	/* Nouveau nom */
		free_String( *paramstring );				/* LibŠre ancien nom */

		*paramstring = STRDUP( new_content );	/* Cr‚e nouveau nom */
	}
	else
	{
		free_String( *paramstring );				/* LibŠre ancien nom */
		*paramstring = G_empty_string;			/* Ptr sur chaine vide */
	}
}



/*
 * cree_textpars(-)
 *
 * Purpose:
 * --------
 * Cr‚e liste de params texte
 * (utilis‚ pour cr‚ation des listes par d‚faut)
 *
 * History:
 * --------
 * 29.08.94: fplanque: Created
 */
ARBO_TEXTPAR *	cree_textpars( 
						int *item_list )
{
	ARBO_TEXTPAR	*textpar_list;			/* Ptr sur 1er ‚l‚ment de la liste */
	ARBO_TEXTPAR	* *pred_next = &(textpar_list);	/* Adresse o— on va devoir stocker le d‚but de la liste */
	ARBO_TEXTPAR	*textpar;				/* Ptr sur 1 ‚l‚ment de la liste */
	int				fnct_no;

	while(	fnct_no = *(item_list++),
				fnct_no != NIL  )
	{
		textpar = ( ARBO_TEXTPAR * ) MALLOC( sizeof( ARBO_TEXTPAR ) );
		textpar -> fnct_no = fnct_no;
		textpar -> nom = NULL;
		*pred_next = textpar;
		pred_next = &(textpar -> next);	/* Sauve adresse du nouveau parametre */
	}
	*pred_next = NULL;		/* Le dernier lien n'a pas de suivant */

	return	textpar_list;
}




/*
 * cree_textpars(-)
 *
 * Purpose:
 * --------
 * Cr‚e liste de params texte
 * (utilis‚ pour cr‚ation des listes par d‚faut)
 *
 * History:
 * --------
 * 29.08.94: fplanque: Created
 * 19.01.95: prend tableau de ARBO_TEXTPAR en argument
 */
ARBO_TEXTPAR *	cree_textpars2( 
						ARBO_TEXTPAR * TTextPar_Origin )	/* In: Tableau de valeurs par d‚faut */
{
	ARBO_TEXTPAR	*	textpar_list;			/* Ptr sur 1er ‚l‚ment de la liste */
	ARBO_TEXTPAR 	**	pred_next = &(textpar_list);	/* Adresse o— on va devoir stocker le d‚but de la liste */
	ARBO_TEXTPAR	*	textpar;				/* Ptr sur 1 ‚l‚ment de la liste */
	int				i;

	for( i=0; TTextPar_Origin[i] .fnct_no != NIL; i++ )
	{
		textpar = ( ARBO_TEXTPAR * ) MALLOC( sizeof( ARBO_TEXTPAR ) );
		textpar -> fnct_no = TTextPar_Origin[i] .fnct_no;
		textpar -> nom = dup_String( TTextPar_Origin[i] .nom );
		*pred_next = textpar;
		pred_next = &(textpar -> next);	/* Sauve adresse du nouveau parametre */
	}
	*pred_next = NULL;		/* Le dernier lien n'a pas de suivant */

	return	textpar_list;
}


/*
 * cree_OutFieldPars(-)
 *
 * Purpose:
 * --------
 * Cr‚e liste de params sur champs de sortie
 * (utilis‚ pour cr‚ation des listes par d‚faut)
 *
 * History:
 * --------
 * 29.08.94: fplanque: Created
 */
ARBO_FIELDPARS *	cree_OutFieldPars( 
							OUTPUT_FPAR *	pOutputFPars )
{
	int				fnct_no;
	ARBO_FIELDPARS *	pFieldPars_list;			/* Ptr sur 1er ‚l‚ment de la liste */
	ARBO_FIELDPARS	**	pred_next = &(pFieldPars_list);	/* Adresse o— on va devoir stocker le d‚but de la liste */
	ARBO_FIELDPARS	*	pFieldPars;					/* Ptr sur 1 ‚l‚ment de la liste */

	while(	fnct_no = pOutputFPars -> fnct_no,
				fnct_no != NIL  )
	{
		pFieldPars = ( ARBO_FIELDPARS * ) MALLOC( sizeof( void* ) + sizeof( OUTPUT_FPAR ) );
		/*
		 * Fixe params par d‚faut:
		 */
		pFieldPars -> data.output = *pOutputFPars;

		*pred_next = pFieldPars;

		pred_next = &(pFieldPars -> next);	

		pOutputFPars ++;
	}
	*pred_next = NULL;		/* Le dernier lien n'a pas de suivant */

	return	pFieldPars_list;
}


/*
 * cree_InFieldPars(-)
 *
 * Purpose:
 * --------
 * Cr‚e liste de params sur champs de SAISIE
 * (utilis‚ pour cr‚ation des listes par d‚faut)
 *
 * History:
 * --------
 * 29.08.94: fplanque: Created
 */
ARBO_FIELDPARS *	cree_InFieldPars( 					/* Out: Liste cr‚e */
							INPUT_FPAR *	pInputFPars )	/* In:  Tableau de valeurs par d‚faut */
{
	int					fnct_no;
	ARBO_FIELDPARS *	pFieldPars_list;			/* Ptr sur 1er ‚l‚ment de la liste */
	ARBO_FIELDPARS	**	pred_next = &(pFieldPars_list);	/* Adresse o— on va devoir stocker le d‚but de la liste */
	ARBO_FIELDPARS	*	pFieldPars;					/* Ptr sur 1 ‚l‚ment de la liste */

	while(	fnct_no = pInputFPars -> fnct_no,
				fnct_no != NIL  )
	{
		pFieldPars = ( ARBO_FIELDPARS * ) MALLOC( sizeof( void* ) + sizeof( INPUT_FPAR ) );
		/*
		 * Fixe params par d‚faut:
		 */
		pFieldPars -> data.input = *pInputFPars;

		*pred_next = pFieldPars;

		pred_next = &(pFieldPars -> next);	

		pInputFPars ++;
	}
	*pred_next = NULL;		/* Le dernier lien n'a pas de suivant */

	return	pFieldPars_list;
}



/*
 * DataPage_AutoParam(-)
 *
 * Purpose:
 * --------
 * AutoParam‚trage d'une page arbo
 *
 * History:
 * --------
 * 17.12.94: fplanque: Created
 * 11.07.95: fplanque: ne paramŠtre la page de fond QUE s'il n'y a pas de val par d‚faut
 */
void	DataPage_AutoParam(
			DATAPAGE	*	pDataPage )		/* In: Page concern‚e */
{
	PAGEARBO 	 *	pPageArbo = pDataPage -> data.pagearbo;
	ARBO_TEXTPAR *	pTextPar_Found;

	/*
	 * Cherche parametre 'page ‚cran de fond':
	 */
	pTextPar_Found = Lookup_SingleLinkList( pPageArbo -> pages_ecran, FE_FOND );
	if( pTextPar_Found != NULL )
	{	/*
		 * On a trouv‚ la param page de fond:
		 */
		if( pTextPar_Found -> nom == NULL )
		{	/*
			 * S'il n'est pas encore assign‚:
			 * On lui assigne le nom de cette page ARBO suivi de .VDT
			 */
			strcpy( G_tmp_buffer, pDataPage -> nom );
			replace_extensionInBuf( G_tmp_buffer, ".VDT" );
			pTextPar_Found -> nom = STRDUP( G_tmp_buffer );
		}
	}

}


/*
 * cree_pagearbo(-)
 *
 * Purpose:
 * --------
 * Cr‚ation d'une nouvelle page arbo
 *
 * Notes:
 * ------
 **********************************************
 * ATTENTION: Tous les sous groupes cr‚‚s ici
 * doivent ‚galement ˆtre trait‚s par
 * dataPg_resetdata(), load_pagesarbo() et save_arbo()
 **********************************************
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 10.05.94: fplanque: Ajout‚ ttmt ParamŠtres Sp‚cifiques Page Arbo
 * 06.08.94: vir‚ param DATAGROUP et cr‚ation de la DATAPAGE par appel a fonction
 * 29.08.94: cr‚ation des champs de sortie par proc‚dure sp‚cialis‚e
 * 07.11.94: Prise en compte pages FA_ID; Plis de listes par d‚faut
 * 16.11.94: champs saisie sp‚ciaux pour ecri
 * 03.12.94: page NEW_ACCOUNT
 * 17.12.94: ne met plus le flag modified! (on le mettra plus tard, avec update d'icone au passage)
 * 17.12.94: autoparam
 * 04.01.94: gestion FA_DISP_TEXT
 * 26.01.95: gestion des params de liste
 * 27.03.95: params filesel
 * 29.03.95: liens-in >>> evenements
 */
DATAPAGE	*	cree_pagearbo( 
					DATADIR	*	curr_datadir, 
					int 			fnct, 
					char		*	form_name, 
					int 			pos_x, 
					int 			pos_y )
{
	PAGEARBO	*	pagearbo = MALLOC( sizeof( PAGEARBO ) );
	DATAPAGE	*	datapage;

	/*
	 * -----------------
	 * Fixe pages-‚cran:
	 * -----------------
	 */
	pagearbo -> pages_ecran = fix_arbo_PEcrans( fnct );

	/*
	 * ---------------------------------------------
	 * Fixe paramŠtres champs d'affichage/de sortie: 
	 * ---------------------------------------------
	 */
	pagearbo -> output_fields = fix_arbo_OutFields( fnct );
	/*
	 * -------------------------
	 * Fixe paramŠtres de liste: 
	 * -------------------------
	 */
	pagearbo -> pArboListPars = fix_arbo_ListPars( fnct );

	/*
	 * -----------------------------------
	 * Fixe paramŠtres champs de saisie:
	 * -----------------------------------
	 */
	pagearbo -> input_fields = fix_arbo_InFields( fnct );

	/*
	 * --------------------------------------------
	 * Fixe paramŠtres bases de donn‚es concern‚es:
	 * --------------------------------------------
	 */
	pagearbo -> databases = fix_arbo_databases( fnct );

	/*
	 * ----------------
	 * Fixe liens arbo: 
	 * ----------------
	 */
	switch ( fnct )
	{
		case	FA_ECRI_MSG:
		case	FA_ID:
		case	FA_NEW_ACCOUNT:
			pagearbo -> p_Events = dup_KeyWordList( M_Ecri_Links );
			break;
		
		case	FA_LIST:
			pagearbo -> p_Events = dup_KeyWordList( M_List_Links );
			break;
			
		case	FA_FILESEL:
			pagearbo -> p_Events = dup_KeyWordList( M_FileSel_Links );
			break;
			
		case	FA_DOWNLOAD:
			pagearbo -> p_Events = dup_KeyWordList( M_DownLoad_Links );
			break;

		default:
			pagearbo -> p_Events = dup_KeyWordList( M_def_arbolinks );
	}
	
	
	/*
	 * --------------------------------------------
	 * Fixe paramŠtres sp‚cifiques au type de page:
	 * --------------------------------------------
	 */
	switch ( fnct )
	{
		case	FA_LECT_MSG:
			pagearbo -> special_par.lecture = (LECTURE_PAR*) MALLOC( sizeof( LECTURE_PAR ) );
			/*
			 * Par d‚faut: un appui sur annulation n'efface pas le message
			 * courant:
			 */
			pagearbo -> special_par.lecture -> n_Annule_Efface = NO0;
			break;

		case	FA_FILESEL:
			pagearbo -> special_par.filesel = MALLOC( sizeof(FILESEL_PAR) );
			/*
			 * Params par d‚faut:
			 */
			pagearbo -> special_par.filesel -> pMsz_RootPath = STRDUP( "C:\\" );
			pagearbo -> special_par.filesel -> n_flags = FA_SUBDIR;
			break;
			
		/* case	FA_MENU: */
		/* case	FA_ECRI_MSG: */
		/* case	FA_ID: */
		/* case	FA_DISP_TEXT: */
		default:
			pagearbo -> special_par.data = NULL;
	}

	/*
	 * --------------------------
	 * Fixe paramŠtres mots clef:
	 * --------------------------
	 */
	pagearbo -> p_MotsClefs = NULL;

	
	/*
	 *----------------------
	 * Fixe infos page Arbo:
	 *----------------------
	 */
	pagearbo -> fnct_no = fnct;						/* Fonction de la page */
	/*
	 * Donn‚es non sauvegard‚es: 
	 * Cr‚e le chemin d'accŠs complet … la page :
	 */
	pagearbo -> chemin	 = page_fullpath( curr_datadir, form_name );
	/* 
	 * Sp‚cifs associ‚es … la fonction:
	 */
	pagearbo	-> fnct_spec = afnct_spec( fnct );	

	pagearbo -> map_pos_x	= pos_x;			/* Coordonn‚es dans le tableau */
	pagearbo -> map_pos_y	= pos_y;			/* repr‚sentatif */


	/*
	 * --------------------
	 * Fixe infos DATAPAGE:
	 * --------------------
	 */
	datapage = create_std_datapage( DTYP_ARBO, form_name );

	/* 
	 * Lie les infos ARBO aux infos PAGE standard: 
	 */
	datapage -> data.pagearbo = pagearbo;

	/* 
	 * Lie la nlle page aux pr‚c‚dentes: 
	 */
	attach_new_data( curr_datadir, datapage );


	/*
	 * Autoparametrage:
	 */
	DataPage_AutoParam( datapage );

	return	datapage;
}


/*
 * fix_arbo_PEcrans(-)
 *
 * Purpose:
 * --------
 * Cr‚ation des params pages ‚crans
 * lors de la cr‚ation d'1 pg arbo
 *
 * History:
 * --------
 * 04.01.94: fplanque: Extracted
 */
ARBO_TEXTPAR *	fix_arbo_PEcrans( 	/* Out: Params cr‚‚s */
						int fnct )			/* In:  Fnct page arbo */
{
	ARBO_TEXTPAR	*	p_TextPars;

	switch ( fnct )
	{
		case	FA_ECRI_MSG:
			p_TextPars = M_ecri_pecran;
			break;
		
		case	FA_LECT_MSG:
			p_TextPars = M_lect_pecran;
			break;
		
		case	FA_DISP_TEXT:
			p_TextPars = M_DispText_PEcrans;
			break;
		
		case	FA_ID:
			p_TextPars = M_Id_pecran;
			break;

		case	FA_LIST:
			p_TextPars = M_List_pecran;
			break;

		case	FA_DIRECTORY:
			p_TextPars = M_Dir_pecran;
			break;
			
		case	FA_FILESEL:
			p_TextPars = M_FileSel_PEcran;
			break;

		case	FA_DOWNLOAD:
			p_TextPars = M_DownLoad_PEcran;
			break;
			
		/* case	FA_MENU: */
		default:
			p_TextPars = M_std_pecran;
	}

	return	Duplicate_TextParList( p_TextPars );
}


/*
 * fix_arbo_OutFields(-)
 *
 * Purpose:
 * --------
 * Cr‚ation des params champs d'affichage
 * lors de la cr‚ation d'1 pg arbo
 *
 * History:
 * --------
 * 24.01.95: fplanque: Created
 */
ARBO_FIELDPARS *	fix_arbo_OutFields( 	/* Out: Params cr‚‚s */
							int fnct )			/* In:  Fnct page arbo */
{
	ARBO_FIELDPARS	*	p_FieldPars;

	switch ( fnct )
	{
		case	FA_ECRI_MSG:
			p_FieldPars = M_ecri_OutFields;
			break;
		
		case	FA_LECT_MSG:
			p_FieldPars = M_lect_OutFields;
			break;
			
		case	FA_DISP_TEXT:
			p_FieldPars = M_DispText_OutFields;
			break;

		case	FA_LIST:
			p_FieldPars = M_List_OutFields;
			break;

		case	FA_DIRECTORY:
			p_FieldPars = M_Dir_OutFields;
			break;
			
		case	FA_FILESEL:
			p_FieldPars = M_FileSel_OutFields;
			break;
			
		/* case	FA_MENU: */
		/* case	FA_ID: */
		default:
			p_FieldPars = NULL;				/* Pas de champ de sortie */
	}

	return Duplicate_SingleLinkList( p_FieldPars, sizeof( void * ) +sizeof( OUTPUT_FPAR ) );

}



/*
 * fix_arbo_ListPars(-)
 *
 * Purpose:
 * --------
 * Cr‚ation des params liste d'affichage
 * lors de la cr‚ation d'1 pg arbo
 *
 * History:
 * --------
 * 26.01.95: fplanque: Created
 */
ARBO_LISTPARS *	fix_arbo_ListPars( 	/* Out: Params cr‚‚s */
							int fnct )			/* In:  Fnct page arbo */
{
	ARBO_LISTPARS	*	pArboListPars;	

	switch ( fnct )
	{
		case	FA_LIST:
		case	FA_DIRECTORY:
			pArboListPars = MALLOC( sizeof( ARBO_LISTPARS ) );
			*pArboListPars = M_AListPars_Def;
			break;

		case	FA_FILESEL:
			pArboListPars = MALLOC( sizeof( ARBO_LISTPARS ) );
			*pArboListPars = M_AListPars_FSelDef;
			break;

		default:
			pArboListPars = NULL;				/* Pas de liste */
	}

	return	pArboListPars;
}


/*
 * fix_arbo_InFields(-)
 *
 * Purpose:
 * --------
 * Cr‚ation des params champs de saisie
 * lors de la cr‚ation d'1 pg arbo
 *
 * History:
 * --------
 * 24.01.95: fplanque: Created
 */
ARBO_FIELDPARS *	fix_arbo_InFields( 	/* Out: Params cr‚‚s */
							int fnct )			/* In:  Fnct page arbo */
{
	ARBO_FIELDPARS	*	p_FieldPars;

	switch ( fnct )
	{
		case	FA_ECRI_MSG:
			p_FieldPars = M_Ecri_InFields;
			break;
		
		case	FA_ID:
			p_FieldPars = M_Id_InFields;
			break;
			
		case	FA_NEW_ACCOUNT:
			p_FieldPars = M_NewAcc_InFields;
			break;
			
		case	FA_DOWNLOAD:
			p_FieldPars = NULL;
			break;
			
		/* case	FA_MENU: */
		/* case	FA_LECT_MSG: */
		/* case	FA_DISP_TEXT: */
		/* case	FA_LIST: */
		/* case	FA_DIRECTORY: */
		default:
			p_FieldPars = M_Std_InFields;
	}

	return	Duplicate_SingleLinkList( p_FieldPars, sizeof( void * ) +sizeof( INPUT_FPAR ) );

}


/*
 * fix_arbo_databases(-)
 *
 * Purpose:
 * --------
 * Cr‚ation des params bases de donn‚es
 * lors de la cr‚ation d'1 pg arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 03.12.94: cr‚ation bases pour ID et NEW_ACCOUNT; insertion de noms par d‚faut!
 */
ARBO_TEXTPAR *	fix_arbo_databases( 
						int fnct )
{
	ARBO_TEXTPAR	*	pTextPar_DBs;

	/*
	 * ------------------
	 * Fixe pages-‚cran 
	 * ------------------
	 */
	switch ( fnct )
	{
		case	FA_ECRI_MSG:
			pTextPar_DBs = M_Ecri_DBs;
			break;
		
		case	FA_LECT_MSG:
		case	FA_LIST:
			pTextPar_DBs = M_Lect_DBs;
			break;
		
		case	FA_DISP_TEXT:
			pTextPar_DBs = M_DispText_DBs;
			break;
		
		case	FA_ID:
		case	FA_NEW_ACCOUNT:
		case	FA_DIRECTORY:
			pTextPar_DBs = M_Id_DBs;
			break;
			
		/* case	FA_MENU: */
		default:
			pTextPar_DBs = NULL;
	}

	return	Duplicate_TextParList( pTextPar_DBs );
}


/*
 * arboedit_optimal(-)
 *
 * Purpose:
 * --------
 * Appele lors de la creation d'une fenetre
 * contenant une boite d'edition de page arbo.
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	arboedit_optimal( int wi_ckind, int *border_x, int *border_y, int *border_w, int *border_h)
{
	int	work_x, work_y, work_w, work_h;	/* Coordonn‚es zone de travail */
	int	wx_mini, wy_mini, ww_maxi, wh_maxi; /* Dimensions maximales */
	int	wx_maxi, wy_maxi;						/* Limites sup‚rieures */

	/*
	 * Essaye de centrer (par AES) la boŒte sur l'‚cran: 
	 */
	form_center( M_arbosomm_adr, &work_x, &work_y, &work_w, &work_h );
	work_x ++;
	work_y ++;
	work_w -= 2;							/* EnlŠve bordure ext‚rieure */
	work_h -= 2;

	/*
	 * Calcule la taille max que peut occuper la boŒte: 
	 */
	wind_calc( WC_WORK, wi_ckind, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi,
					&wx_mini, &wy_mini, &ww_maxi, &wh_maxi );

	/*
	 * Contr“le l'inclusion: 
	 */
	if ( work_w > ww_maxi ) /* Si trop large */
	{
		work_w = ww_maxi;
	}
	wx_maxi = wx_mini + ww_maxi;		/* Limite X sup‚rieure */
	if ( (work_x + work_w) > wx_maxi )	 /* Si on d‚passe */
	{
		work_x = wx_maxi - work_w;
	}
	else if ( work_x < wx_mini )
	{
		work_x = wx_mini;
	}

	if ( work_h > wh_maxi )
	{	/* Si trop haut */
		work_h = wh_maxi;
	}
	wy_maxi = wy_mini + wh_maxi;		/* Limite Y sup‚rieure */

	if ( (work_y + work_h) > wy_maxi )
	{	/* Si on d‚passe */
		work_y = wy_maxi - work_h;
	}
	else if ( work_y < wy_mini )
	{
		work_y = wy_mini;
	}

	/*
	 * Calcule les coordonn‚es totales de la fenˆtre: 
	 */
	wind_calc( WC_BORDER, wi_ckind, work_x, work_y, work_w, work_h,
					border_x, border_y, border_w, border_h );

}


/*
 * -------------- EDITION DE PARAMS DIVERS D'UNE PAGE ARBO --------------
 */

                      
/*
 * edit_ArboParList(-)
 *
 * Purpose:
 * --------
 * Edition de paramŠtres d'une page arbo sous forme de liste
 * (Pages Ecran, Champs de saisie, Liens arbo, etc...)	
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 04.12.94: ne gere plus qu'une seule liste
 * 14.12.94: signale que la page arbo a ‚t‚ modifi‚e
 * 04.01.95: gŠre les DATAs
 * 24.03.95: gestion de liste our toute page qui en disposerait
 * 29.03.95: liens >-> evenements
 */
void edit_ArboParList(				/* Ne renvoie rien */
			int			edit_type, 
			WIPARAMS *	pWiParams )
{
	DATAPAGE		*	datapage = pWiParams -> datapage;		/* Page ARBO concern‚e */
	PAGEARBO		*	pPageArbo = datapage -> data.pagearbo;
	/* 
	 * Adresse des sp‚cifications: 
	 */
	AFNCTSPEC	*	AFnctSpec = pPageArbo -> fnct_spec;
	/* 
	 * Adresses actuelles pages ‚cran/liens, champs: 
	 */
	ARBO_TEXTPAR	* *	ppTextPar_First;
	ARBO_FIELDPARS	* *	ppFieldPar_First;			/* Adr du Ptr sur 1er champ input ou output */
	KEYWORD_LIST	* *	ppKWLst_FirstKeyW;
	/* 
	 * Variables repr‚sentant les donn‚es … ‚diter: 
	 */
	int				nb_lignes;		/* Nbre de lignes de la liste */
	char		* *	textes;			/* textes des lignes */
	/* 
	 * Var d'‚dition:
	 */
	PARPAGE_FLAGS  flags = { 0, 0, 0 };
	GRECT				start_box;
	int				modif;			/* A t'on modifi‚? */
	

	/* 
	 * Fixe le nom de la page: 
	 */
	rlink_teptext( &M_pForm_EditArboKeyWords[ EDKEYPAG ], pPageArbo -> chemin );
	/* 
	 * Fixe la fonction de la page: 
	 */
	rlink_teptext( &M_pForm_EditArboKeyWords[ EDKEYFNC ], AFnctSpec -> fnct_name );
	/* 
	 * Fixe le "titre" de la fenˆtre fille: 
	 * Fixe les pointeurs sur la liste d‚sir‚e: 
	 */
	switch( edit_type )
	{

		case	EDIT_PECRAN:
			dlink_teptext( &M_pForm_EditArboKeyWords[ EDKEYTIT ], " Pages ‚cran " );

			/* 
			 * Duplique les params: 
			 */
			ppTextPar_First = &(pPageArbo -> pages_ecran);	/* Pointe sur 1Šre page ‚cran */
			M_TextPar_copies = Duplicate_TextParList( *ppTextPar_First );

			/* 
			 * Cr‚ation liste psz: 
			 */
			nb_lignes = Create_TextParPszList( edit_type, M_TextPar_copies, &textes );

			break;
				

		case	EDIT_OUTPUTS:
			dlink_teptext( &M_pForm_EditArboKeyWords[ EDKEYTIT ], " Champs de sortie " );

			/* 
			 * Duplique les params des champs de saisie: 
			 */
			ppFieldPar_First = &(pPageArbo -> output_fields);
			M_fieldpar_copies = Duplicate_SingleLinkList( *ppFieldPar_First, sizeof( void * ) +sizeof( OUTPUT_FPAR ) );	
			/* 
			 * Cr‚ation liste psz: 
			 */
			nb_lignes = Create_FieldPszList( EDIT_OUTPUTS, M_fieldpar_copies, &textes );

			/*
			 * Copie les params de la liste si n‚cessaire:
			 */
			if( pPageArbo -> pArboListPars != NULL )
			{	/*
				 * Copie les paramŠtres:
				 */
				M_ListPars_copy = *( pPageArbo -> pArboListPars );
				flags .b_EnableList = TRUE_1;
			}
			break;
			

		case	EDIT_SAISIES:
			dlink_teptext( &M_pForm_EditArboKeyWords[ EDKEYTIT ], " Champs de saisie " );

			/*
			 * Duplique les params des champs d'‚dition: 
			 */
			ppFieldPar_First = &(pPageArbo -> input_fields);
			M_fieldpar_copies = Duplicate_SingleLinkList( *ppFieldPar_First, sizeof( void * ) + sizeof( INPUT_FPAR ) );	

			/* 
			 * Cr‚ation liste psz: 
			 */
			nb_lignes = Create_FieldPszList( EDIT_SAISIES, M_fieldpar_copies, &textes );

			break;


		case	EDIT_DATA:
			dlink_teptext( &M_pForm_EditArboKeyWords[ EDKEYTIT ], " Donn‚es " );

			/* 
			 * Duplique les params: 
			 */
			ppTextPar_First = &(pPageArbo -> databases);	/* Pointe sur 1Šre donn‚e */
			M_TextPar_copies = Duplicate_TextParList( *ppTextPar_First );

			/* 
			 * Cr‚ation liste psz: 
			 */
			nb_lignes = Create_TextParPszList( edit_type, M_TextPar_copies, &textes );

			break;
				
		case	EDIT_LIENS:
			dlink_teptext( &M_pForm_EditArboKeyWords[ EDKEYTIT ], " EvŠnements " );

			/* 
			 * Duplique les params: 
			 */
			ppKWLst_FirstKeyW = &(pPageArbo -> p_Events);	/* Pointe sur 1Šre donn‚e */
			M_pKeyWordList_Copy = dup_KeyWordList( *ppKWLst_FirstKeyW );

			/* 
			 * Cr‚ation liste psz: 
			 */
			nb_lignes = cree_liste_KeyWord( M_pKeyWordList_Copy, FALSE, &textes );

			break;

		case	EDIT_KEYWORDS:
			dlink_teptext( &M_pForm_EditArboKeyWords[ EDKEYTIT ], " Commandes / Mots Clefs " );

			/* 
			 * Duplique les params: 
			 */
			ppKWLst_FirstKeyW = &(pPageArbo -> p_MotsClefs);	/* Pointe sur 1Šre donn‚e */
			M_pKeyWordList_Copy = dup_KeyWordList( *ppKWLst_FirstKeyW );

			/* 
			 * Cr‚ation liste psz: 
			 */
			nb_lignes = cree_liste_KeyWord( M_pKeyWordList_Copy, TRUE_1, &textes );

			flags .b_EnableAdd = TRUE_1;

			break;

		default:
			ping();
	}

	/******************************************************************/

	objc_xywh ( pWiParams -> draw_ptr.tree, pWiParams -> selected_icon, &start_box );

	M_edit_pecr_type = edit_type;			/* Var globale */

	modif = parpage_general( &flags, &start_box, M_KeyWords_EscObjs, &textes, nb_lignes );

	/******************************************************************/

	/*
	 * Efface tableau de lignes/Liste de la m‚moire:
	 */
	Delete_PszList( textes, nb_lignes );


	/*
	 * Teste  s'il faut sauver les modifs: 
	 */
	switch( edit_type )
	{
		case	EDIT_PECRAN:
		case	EDIT_DATA:
			if ( modif == YES1 )
			{	/*
				 * Si on a valid‚: 
				 * Efface les anciennes donn‚es: 
				 */
				Delete_TextParList( *ppTextPar_First );

				/*
				 * Lie la copie modifi‚e, donc les nouvelles donn‚es … la page arbo: 
				 */
				*ppTextPar_First = M_TextPar_copies;

			}
			else
			{	/*
			 	 * On a annul‚: 
				 * Efface la copie des donn‚es: 
				 */
				Delete_TextParList( M_TextPar_copies );

			}

			/*
			 * On ne doit plus utiliser la copie: 
			 */
			M_TextPar_copies = NULL;
			break;


		case	EDIT_OUTPUTS:
		case	EDIT_SAISIES:
			if ( modif == YES1 )
			{	/*
				 * Si on a valid‚: 
				 * Efface les anciennes donn‚es: 
				 */
				Delete_SingleLinkList( *ppFieldPar_First );

				/*
				 * Lie la copie modifi‚e, donc les nouvelles donn‚es … la page arbo: 
				 */
				*ppFieldPar_First = M_fieldpar_copies;


				/*
				 * Sauve les params de la liste si n‚cessaire:
				 */
				if( flags .b_EnableList )
				{
					*( pPageArbo -> pArboListPars ) = M_ListPars_copy;
				}

			}
			else
			{	/*
			 	 * On a annul‚: 
				 * Efface la copie des donn‚es: 
				 */
				Delete_SingleLinkList( M_fieldpar_copies );

			}

			/*
			 * On ne doit plus utiliser la copie: 
			 */
			M_fieldpar_copies = NULL;
			break;


		case	EDIT_LIENS:
		case	EDIT_KEYWORDS:
			if ( modif == YES1 )
			{	/*
				 * Si on a valid‚: 
				 * Efface les anciennes donn‚es: 
				 */
				free_KeyWordList( *ppKWLst_FirstKeyW );

				/*
				 * Lie la copie modifi‚e, donc les nouvelles donn‚es … la page arbo: 
				 */
				*ppKWLst_FirstKeyW = M_pKeyWordList_Copy;

			}
			else
			{	/*
			 	 * On a annul‚: 
				 * Efface la copie des donn‚es: 
				 */
				free_KeyWordList( M_pKeyWordList_Copy );

			}

			/*
			 * On ne doit plus utiliser la copie: 
			 */
			M_pKeyWordList_Copy = NULL;
			break;
			
		default:
			ping();
	}

	if( modif == YES1 )
	{	/*
		 * Si on a valid‚: 
		 * Signale que la page ARBO a ‚t‚ modifi‚e:
		 */
		dataPage_chgSavState( datapage, SSTATE_MODIFIED, TRUE_1, TRUE_1 );
	}	
}



/*
 * parpage_general(-)
 *
 * Purpose:
 * --------
 * Gestion form g‚n‚ral contenant une liste de parametres 
 * d'une page arbo
 * Cette proc‚dure sert aussi pour les LIENS_IN
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 02.01.94: fplanque: ajout des () manquantes ds free() des chaines
 * 04.01.94: nouveau format d'appel de select_in_list()
 * 18.05.94: Chang‚ params d'appel et sorti disables des boutons vers l'appellant
 * 04.12.94: ne gŠre plus qu'une seule liste; utilise nlle boite de dialogue
 * 04.12.94: toute lib‚ration de m‚moire liste se fait … l'‚xt‚rieur (comme pour la cr‚ation!)
 * 07.01.94: allume bouton add si n‚cessaire
 * 24.03.95: gestion de flags
 */
int	parpage_general( 
			PARPAGE_FLAGS * flags,
			GRECT *	start_box, 			/* In: Rect de d‚part effet graphique */
			int	*	esc_objs,			/* In: Tableau des boutons … traiter en exit */
			char ***	path_array, 		/* In: Tableau de lignes psz */
			int		nb_pecr_link )		/* In: Nbre de lignes dans le s‚lecteur */
{
	GRECT				form_box;
	int				exit_obj;				/* Objet de sortie */

	/* 
	 * "Eteind" fonctions non (encore) disponibles: 
	 */
	objc_setdisable( M_pForm_EditArboKeyWords, EDAPFIX );
	objc_setdisable( M_pForm_EditArboKeyWords, EDAPSUPP);
	/*
	 * Allume fonctions evt disponibles
	 */
	objc_fixable( M_pForm_EditArboKeyWords, EDAPADD, flags -> b_EnableAdd );
	objc_fixable( M_pForm_EditArboKeyWords, EDLISTE, flags -> b_EnableList ); 

	/*vvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
	/* App prend en charge souris */
	WIND_UPDATE_BEG_MCTRL
	/***  Entr‚e dans un MODE:  ***/

	/*
	 * Gestion formulaire: 
	 */
	exit_obj = select_in_list( 
					M_pForm_EditArboKeyWords, 
					start_box, 
					&form_box,
					path_array, 
					&nb_pecr_link,
					esc_objs, 
					parapage_actions, 
					parpg_fixstate_act,
					0 );

	/***  Sortie du MODE:  ***/
	/* AES peut reprendre la souris */
	WIND_UPDATE_END_MCTRL
	/*^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	if ( exit_obj == ADAPVAL )
	{ 	/* 
		 * Si on a valid‚: 
		 */
		return	YES1;		/* Signale qu'il faut prendre en compte les modifs */

	}

	return NO0;	 /* Signale qu'il n'y a pas de modifs … prendre en compte */
}




/*
 * parapage_actions(-)
 *
 * Purpose:
 * --------
 * Traitement des objets exit du formulaire pr‚c‚dent
 *
 * Notes:
 * ------
 * On ne fait RIEN lorsque l'on clique sur un elt ds la liste...
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 04.01.94: l'allumage des bout d'actions lors de la sel d'un elt se fait d‚sormais hors-d'ici
 * 07.01.95: gestion double click; mots clefs
 */
int	parapage_actions( LISTHANDLES *list_handles, int	obj )
{
	if( obj & SEL_LINE )
	{
		if( obj & DBLE_CLICLK )
		{	/*
		    * Si on a double cliqu‚ sur un nom:
			 * simule appui sur fixer
			 */
			goto	parapage_fix;
		}
	}
	else
		switch( obj )
		{
			case	ADAPVAL:
			case	EDAPANN:
				return	FALSE0;		/* Met fin au dialogue */
				
			case	EDAPFIX:
parapage_fix:
				switch( M_edit_pecr_type )
				{
					case	EDIT_PECRAN:
					case	EDIT_DATA:
						/*
						 * Appel du s‚lecteur d'objets: 
						 */
						edpgecr_callselect( list_handles, EDAPFIX );
						break;

					case	EDIT_OUTPUTS:
						/*
						 * Appel boŒte de param‚trage d'un champ d'affichage: 
						 */
						parapg_parasortie( list_handles, M_pForm_EditArboKeyWords, EDAPFIX );
						break;
						
					case	EDIT_SAISIES:
						/*
						 * Appel boŒte de param‚trage d'un champ de saisie: 
						 */
						parapg_parasaisie( list_handles, M_pForm_EditArboKeyWords, EDAPFIX );
						break;

					case	EDIT_KEYWORDS:
						/*
						 * ParamŠtrage d'une commande:
						 */ 
						fixe_MotClef( list_handles, TRUE_1, M_pForm_EditArboKeyWords, EDAPFIX );
						break;

					case	EDIT_LIENS:
						/*
						 * ParamŠtrage d'un ‚vŠnement:
						 */ 
						fixe_MotClef( list_handles, FALSE0, M_pForm_EditArboKeyWords, EDAPFIX );
						break;

					default:
						ping();						
				}
				break;
		
			case	EDAPSPEC:
				/*
				 * Visualisation d'une page ‚cran:
				 */
				watch_PageEcran( M_pForm_EditArboKeyWords, EDAPSPEC );
				
				break;

			case	EDAPADD:
				/*
				 * Ajoute un mot clef:
				 */
				if( ajoute_MotClef( list_handles, M_pForm_EditArboKeyWords, EDAPFIX ) )
				{	/*
					 * On a chang‚ la liste:
					 * il va falloir r‚afficher et initialiser variables 
					 */
					return	CHANGE_2;		
				}
				break;

			case	EDAPSUPP:
				/*
				 * Supprime un mot clef:
				 */
				if( supprime_MotClef( list_handles ) )
				{	/*
					 * On a chang‚ la liste:
					 * il va falloir r‚afficher et initialiser variables 
					 */
					return	CHANGE_2;		
				}
				break;
	
			case	EDLISTE:
				switch( M_edit_pecr_type )
				{
					case	EDIT_OUTPUTS:
						/*
						 * Appel boŒte de param‚trage de la liste: 
						 */
						parapg_paralist( &M_ListPars_copy, M_pForm_EditArboKeyWords, EDLISTE );
						break;
						
					default:
						ping();						
				}
				break;

			default:
				ping();
		}
	
	return	TRUE_1;			/* Continue dialogue */
}


/*
 * parpg_fixstate_act(-)
 *
 * Purpose:
 * --------
 * Selon qu'un elt est courament selectionn‚ ds la liste textuelle:
 * Allume ou eteind en direct les boutons d'action associ‚s.
 *
 * Algorythm:
 * ----------
 * - D‚termine si une ligne est s‚lectionn‚e...
 * - Allume/Eteind les boutons...
 *
 * History:
 * --------
 * 04.01.94: fplanque: Created
 * 07.01.95: fplanque: gŠre bouton SUPPRESSION
 */
void	parpg_fixstate_act( 					/* Out: Rien */
			LISTHANDLES *list_handles )	/* In: Ptr sur infos sur la liste & le dialogue affich‚s */
{

	if( list_handles -> selected_line != NIL )
	{	/*
		 * S'il y a une ligne s‚lectionn‚e: il faut ALLUMER:
		 */
		objc_enable( M_pForm_EditArboKeyWords, EDAPFIX );

		if ( M_edit_pecr_type == EDIT_KEYWORDS )
		{
			objc_enable( M_pForm_EditArboKeyWords, EDAPSUPP );
		}
	}
	else
	{	/*
		 * S'il n'y a PAS de ligne s‚lectionn‚e: il faut ETEINDRE:
		 */
		objc_disable( M_pForm_EditArboKeyWords, EDAPFIX );
		objc_disable( M_pForm_EditArboKeyWords, EDAPSUPP );
	}
}



/*
 * -------------- EDITION DES PARAMS SPECIFIQUES D'UNE PAGE --------------
 */


/*
 * edit_SpecPar_LectMsg(-)
 *
 * Purpose:
 * --------
 * Edition de paramŠtres sp‚cifiques 
 * … la page arbo lecture message
 *
 * History:
 * --------
 * 28.03.95: fplanque: Created based on edit_arbopar_params()
 */ 
BOOL	edit_SpecPar_LectMsg(
			LECTURE_PAR	*	pLECP_ParamsLecture,
			GRECT			*	pStartBox )	
{
	/*
	 * Variables Edition: 
	 */
	GRECT				form_box;
	int				edit = 0;			/* Bidon */
	int				exit_obj;

	/* 
	 * Fixe flags des boutons: 
	 */
	objc_fixsel( M_pForm_EditParamsLect, ANNUEFFA,
					 pLECP_ParamsLecture -> n_Annule_Efface );


	/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

	WIND_UPDATE_BEG_MCTRL
	open_dialog( M_pForm_EditParamsLect, pStartBox, &form_box );

	/* 
	 * Gestion dialogue: 
	 */
	exit_obj=ext_form_do( M_pForm_EditParamsLect, &edit);	/* Gestion de la boŒte */
	
	close_dialog( M_pForm_EditParamsLect, exit_obj, pStartBox, &form_box );
	WIND_UPDATE_END_MCTRL

	/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	/* 
	 * Sauvegarde des modifs: 
	 */
	if( exit_obj == PLECTVAL )
	{	/*
	 	 * Si on a valid‚:
	 	 */
		pLECP_ParamsLecture -> n_Annule_Efface = objc_testsel( M_pForm_EditParamsLect, ANNUEFFA );

		return	TRUE_1;
	}

	return	FALSE0;
}			



/*
 * edit_SpecPar_FileSel(-)
 *
 * Purpose:
 * --------
 * Edition de paramŠtres sp‚cifiques 
 * … la page arbo s‚lecteur de fichier
 *
 * History:
 * --------
 * 28.03.95: fplanque: Created based on edit_arbopar_params()
 */ 
BOOL	edit_SpecPar_FileSel(
			FILESEL_PAR	*	pFileSelPars,
			GRECT			*	pStartBox )	
{
	/*
	 * Variables Edition: 
	 */
	GRECT				form_box;
	int				edit = 0;			/* Bidon */
	int				exit_obj;

	/* 
	 * Fixe flags des boutons: 
	 */
	int	n_flags = pFileSelPars -> n_flags;
	objc_fixsel( M_pForm_EditParFileSel, FSELIHID, n_flags & FA_HIDDEN );
	objc_fixsel( M_pForm_EditParFileSel, FSELISYS, n_flags & FA_SYSTEM );
	objc_fixsel( M_pForm_EditParFileSel, FSELISUB, n_flags & FA_SUBDIR );

	fix_ftext( M_pForm_EditParFileSel, FSELROOT, pFileSelPars -> pMsz_RootPath );

	/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

	WIND_UPDATE_BEG_MCTRL
	open_dialog( M_pForm_EditParFileSel, pStartBox, &form_box );

	/* 
	 * Gestion dialogue: 
	 */
	exit_obj=ext_form_do( M_pForm_EditParFileSel, &edit);	/* Gestion de la boŒte */
	
	close_dialog( M_pForm_EditParFileSel, exit_obj, pStartBox, &form_box );
	WIND_UPDATE_END_MCTRL

	/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	/* 
	 * Sauvegarde des modifs: 
	 */
	if( exit_obj == FSELVAL )
	{	/*
	 	 * Si on a valid‚:
	 	 */
		n_flags = 0;
		if( objc_testsel( M_pForm_EditParFileSel, FSELIHID ) )
		{
			n_flags |= FA_HIDDEN;
		}
		if( objc_testsel( M_pForm_EditParFileSel, FSELISYS ) )
		{
			n_flags |= FA_SYSTEM;
		}
		if( objc_testsel( M_pForm_EditParFileSel, FSELISUB ) )
		{
			n_flags |= FA_SUBDIR;
		}
		pFileSelPars -> n_flags = n_flags;

		/*
		 * Path:
		 */
		free_String( pFileSelPars -> pMsz_RootPath );
		pFileSelPars -> pMsz_RootPath = extract_ftext( M_pForm_EditParFileSel, FSELROOT );
		
		return	TRUE_1;
	}

	return	FALSE0;
}			

                      
/*
 * edit_arbopar_params(-)
 *
 * Purpose:
 * --------
 * Edition de paramŠtres sp‚cifiques d'une page arbo 
 *
 * History:
 * --------
 * 10.05.94: fplanque: Created based on edit_arbopar_datas()
 * 14.12.94: signale que la page arbo a ‚t‚ modifi‚e
 * 27.06.95: extracted FA_LECT_MSG specific code
 */
void edit_arbopar_params( 
			WIPARAMS *	pWiParams )	/* In: Fen contenant le menu arbo depuis lequel on appelle */
{
	/*	
	 * Adresse page arbo: 
	 */
	DATAPAGE		*	datapage = pWiParams -> datapage;		/* Page ARBO concern‚e */
	PAGEARBO		*	pagearbo = datapage -> data.pagearbo;
	/* 
	 * Adresses params: 
	 */
	ARBO_SPECIALPAR SpecPars = pagearbo -> special_par;

	GRECT	start_box;
	BOOL	res;
	

	/* 
	 * D‚part de l'effet graphique: 
	 */
	objc_xywh ( pWiParams -> draw_ptr.tree, 
					pWiParams -> selected_icon, &start_box );

	switch( pagearbo -> fnct_no )
	{
		case	FA_LECT_MSG:
			res = edit_SpecPar_LectMsg( SpecPars.lecture, &start_box );
			break;
			
		case	FA_FILESEL:
			res = edit_SpecPar_FileSel( SpecPars.filesel, &start_box );
			break;
	
		default:
			signale("Ne sait pas editer les params pour cette page" );
			res = FALSE0;
	}


	if( res == TRUE_1 )
	{	/*
		 * Signale que la page a ‚t‚ modifi‚e:
		 */
		dataPage_chgSavState( datapage, SSTATE_MODIFIED, TRUE_1, TRUE_1 );
	}
}

                      

/*
 * ----------------- EDITION DES MOTS CLEFS D'UNE PAGE ------------------
 */


/*
 * ajoute_MotClef(-)
 *
 * Purpose:
 * --------
 * Ajoute 1 mot clef … la liste courament ‚dit‚e
 *
 * Suggest:
 * ------
 * sortir le test de ligne s‚lectionn‚e qui est identique ds ajoute_voie()
 *
 * History:
 * --------
 * 18.05.94: fplanque: Created bases on ajoute_voie()
 * 07.01.95: new params, edition avant d'entrer le MC dans la liste
 * 15.03.95: appel de KeyWordLElt_Create()
 */
BOOL	ajoute_MotClef( 						/* Out: TRUE_1 si on a valid‚ */
			LISTHANDLES *	p_ListHandles,	/* In: Params de la liste des mots clefs */
			OBJECT 		*	pForm_fond, 	/* In: Formulaire qui a appel‚ */
			int 				n_callObj )		/* In: Obj aui a appell‚ sur ce formulaire */
{
	KEYWORD_LIST *	pDblText_elt = M_pKeyWordList_Copy;	/* mot-clef en cours de traitement */
	KEYWORD_LIST * *	last_ptr_tonext = &M_pKeyWordList_Copy;
	KEYWORD_LIST *	new_KeyWord;
	char			  * *	param_array;
	
	int	nb_items;
	int	n_NewItem_index = 0;
	int	selected_line;


	/* 
	 * -----------------------
	 * Alloue nouveau mot clef 
	 * -----------------------
	 */
	new_KeyWord = KeyWordLElt_Create( FL_ENVOI,
									ACTION_NONE, ACTION_FULLCLS,
									G_empty_string, G_empty_string );

	/*
	 * Edition des paramŠtres:
	 */
	if( ! edit_MotClef( new_KeyWord, TRUE_1, pForm_fond, n_callObj ) )
	{
		KeyWordLElt_Destroy( new_KeyWord );
		return	FALSE0;
	}	

	/*
	 * Trouve la fin de la liste:
	 */
	while( pDblText_elt != NULL )
	{
		last_ptr_tonext = &( pDblText_elt -> next );
		pDblText_elt = pDblText_elt -> next;
		n_NewItem_index ++;
	}

	/* 
	 * Liaison avec le reste: 
	 */
	*last_ptr_tonext = new_KeyWord;

	/* 
	 * -------------------------------------------------------
	 * Une ligne de plus dans la liste de s‚lection textuelle: 
	 * -------------------------------------------------------
	 */
	(p_ListHandles -> nb_items) ++;		/* 1 elt de plus */
	nb_items = p_ListHandles -> nb_items;

	/*
	 * Agrandi la liste: 
	 */
	param_array = (char * *) REALLOC( *(p_ListHandles -> pTpsz_array), nb_items * sizeof( char * ) );
	*(p_ListHandles -> pTpsz_array) = param_array;

	/*
	 * Ajoute une nouvelle ligne … la fin de la liste: 
	 */
	param_array[ n_NewItem_index ] = cree_ligne_KeyWord( new_KeyWord, TRUE_1 );

	/* 
	 * Nouvelle ligne s‚lectionn‚e: 
	 */
	selected_line = n_NewItem_index - p_ListHandles -> top_item + p_ListHandles -> first_name;

	/*
	 * V‚rifie qu'on est dans la partie visible: 
	 */
	if ( selected_line > p_ListHandles -> last_name )
	{	/* 
		 * Si on est trop haut: 
		 * On va d‚scendre l'affichage dans la liste: 
		 */
		p_ListHandles -> top_item += selected_line - p_ListHandles -> last_name;
		selected_line = p_ListHandles -> last_name;
	}
	else if( selected_line < p_ListHandles -> first_name ) 
	{	/* 
		 * Si on est trop bas: 
		 * On va monter l'affichage dans la liste: 
		 */
		p_ListHandles -> top_item -= p_ListHandles -> first_name - selected_line;
		selected_line = p_ListHandles -> first_name;
	}

	p_ListHandles -> selected_line = selected_line;

	return	TRUE_1;
}



/*
 * supprime_MotClef(-)
 *
 * Purpose:
 * --------
 * Supprime le mot clef courament s‚lection‚
 *
 * History:
 * --------
 * 07.01.95: fplanque: Created
 * 22.13.95: d‚truit mot clef supprim‚ (apparemment ce n'‚tait pas fait!)
 */
BOOL	supprime_MotClef( 						/* Out: TRUE_1 si on a valid‚ */
			LISTHANDLES *	p_ListHandles )	/* In: Params de la liste des mots clefs */
{

	KEYWORD_LIST *	pDblText_paramsMotClef;
	int				 	n_indexMotClef;
	int					nb_items;
	int					nb_Lines;
	char			  * *	param_array;

	/*
	 * Demande confirmation:
	 */
	if( form_alert( 2, "[3][|"
									"Voulez-vous vraiment|"
									"supprimer ce mot clef?]"
									"[Oui|Non]" ) != 1 )
	{
		return	FALSE0;
	}

	/* 
	 * No d'ordre mot clef concern‚ ds liste: 
	 */
 	n_indexMotClef = get_no_selitem( p_ListHandles );

	/*
	 * Trouve les parametres du champ concern‚: 
	 */
	pDblText_paramsMotClef = findElt_KWLst_byIndex( M_pKeyWordList_Copy, n_indexMotClef );

	/*
	 * Change les liens de la liste
	 * pour ne pus passer par le mot clef … supprimer:
	 */
	if( M_pKeyWordList_Copy == pDblText_paramsMotClef )
	{	/*
		 * Il s'agit du premier mot clef:
		 * On change le d‚but de la liste pour pointer vers la ligne suivante:
		 */
		M_pKeyWordList_Copy = pDblText_paramsMotClef -> next;
	}
	else
	{	/*
		 * On fait pointer le pr‚c‚dent vers le suivant:
		 */
		KEYWORD_LIST *	pDblText_prevMotClef = findElt_KWLst_byIndex( M_pKeyWordList_Copy, n_indexMotClef -1 );
		pDblText_prevMotClef -> next = pDblText_paramsMotClef -> next;
	}
	
	/*
	 * D‚truit mot clef:
	 */
	KeyWordLElt_Destroy( pDblText_paramsMotClef );

	/* 
	 * -------------------------------------------------------
	 * Une ligne de moins dans la liste de s‚lection textuelle: 
	 * -------------------------------------------------------
	 */
	(p_ListHandles -> nb_items) --;		/* 1 elt de moins */
	nb_items = p_ListHandles -> nb_items;

	/*
	 * Supprime ligne dans la liste textuelle: 
	 */
	param_array = (char * *) REALLOC( *(p_ListHandles -> pTpsz_array), nb_items * sizeof( char * ) );
	free_String( param_array[ n_indexMotClef ] );
	/*
	 * D‚cale la suite
	 */
	memcpy( &param_array[ n_indexMotClef ], &param_array[ n_indexMotClef + 1 ], sizeof( char * ) * (nb_items - n_indexMotClef) );

	/* 
	 * Plus de ligne s‚lectionn‚e: 
	 */
	p_ListHandles -> selected_line = NIL_1;

	/*
	 * V‚rifie qu'on ne laisse pas de lignes vides
	 * alors que tout n'est pas visible: 
	 */
	nb_Lines = p_ListHandles -> last_name - p_ListHandles -> first_name + 1;

	if( p_ListHandles -> top_item + nb_Lines > nb_items )
	{
		p_ListHandles -> top_item = max( 0, nb_items - nb_Lines );
	} 

	return	TRUE_1;	
}


/*
 * fixe_MotClef(-)
 *
 * Purpose:
 * --------
 * Permet de modifier (fixer) les paramŠtres du mot clef s‚lectionn‚
 * dans la liste courament ‚dit‚e
 *
 * History:
 * --------
 * 18.05.94: fplanque: Created bases on ajoute_voie()
 * 07.01.95: appelle edit_MotClef()
 * 12.04.95: b_Command
 */
void	fixe_MotClef( 
			LISTHANDLES *	p_ListHandles,	/* In: Params de la liste des mots clefs */
			BOOL				b_Command,		/* In: TRUE_1 si on traite une commande, sinon on triate un event */
			OBJECT 		*	pForm_fond, 	/* In: Formulaire qui a appel‚ */
			int 				n_callObj )		/* In: Obj aui a appell‚ sur ce formulaire */
{

	KEYWORD_LIST *	pDblText_paramsMotClef;
	
	/* 
	 * No d'ordre mot clef concern‚ ds liste: 
	 */
	int 	n_indexMotClef = get_no_selitem( p_ListHandles );

	/*
	 * Trouve les parametres du champ concern‚: 
	 */
	pDblText_paramsMotClef = findElt_KWLst_byIndex( M_pKeyWordList_Copy, n_indexMotClef );
		

	/*
	 * Edition des paramŠtres:
	 */
	if( edit_MotClef( pDblText_paramsMotClef, b_Command, pForm_fond, n_callObj ) )
	{	/*
		 * Si on a confirm‚: 
		 * Variables: 
		 */
		char	* *path_array = *(p_ListHandles -> pTpsz_array);
		char	* *resume = &path_array[ n_indexMotClef ];	/* R‚sum‚ des paramŠtres */

		/* 
		 * Modifie la ligne dans le formulaire: 
		 * Efface ancienne ligne: 
		 */
		free_String( *resume );							/* LibŠre ancien contenu */

		/*
		 * Cr‚e nouvelle ligne et place ptr dans tableau: 
		 */
		*resume = cree_ligne_KeyWord( pDblText_paramsMotClef, b_Command );
		
		/*
		 * Fixe nlle ligne:
		 */
		list_fix1name( pForm_fond, p_ListHandles -> selected_line, *resume );
	}
}




/*
 * edit_MotClef(-)
 *
 * Purpose:
 * --------
 * Edite les paramŠtres d'un mot clef
 * pass‚ en paramŠtre
 *
 * Suggest:
 * --------
 * Compl‚ter la gestion des entˆtes de nom: 'ARB:\'
 *
 * History:
 * --------
 * 07.01.95: fplanque: Extracted from fixe_MotClef()
 * 14.03.95: fplanque: gestion popup actions
 * 22.03.95: fplanque: petites optimisations
 * 29.03.95: fplanque: debugged when NULL pointers; gestion des Evenements, extended
 * 12.04.95: fplanque: param b_MotClef
 * 11.07.95: fplanque: corrig‚ dup_String de la page destination
 */
BOOL	edit_MotClef(											/* Out: TRUE_1 si valid‚ */
			KEYWORD_LIST *	pDblText_paramsMotClef,		/* In:  Mot clef … ‚diter */
			BOOL				b_MotClef,						/* In:  TRUE si mot clef, sinon: event */
			OBJECT 		 *	pForm_fond, 					/* In:  Formulaire qui a appel‚ */
			int 				n_callObj )						/* In:  Obj aui a appell‚ sur ce formulaire */
{
	int			exit_obj;
	int			edit = MOTCLEF;
	GRECT			GRect_start;
	GRECT			GRect_form;
	char		*	piBsz_PgArboDest;
	char 		*	pMsz_PgArboDest;
	char 		*	cpsz_Event;
	const char* cpsz_title;

	OBJECT *	pObj_PageArbo = &(M_pForm_EditMotClef[ MCARBOD ]);

	/*
	 * Fixe les valeurs dans le formulaire: 
	 */
	if( b_MotClef )
	{
		cpsz_title = "Edition d'une Commande";
		objc_setenable( M_pForm_EditMotClef, MOTCLEF );
	}
	else
	{
		cpsz_title = "Edition d'un EvŠnement";
		objc_setdisable( M_pForm_EditMotClef, MOTCLEF );
	}
	
	dlink_teptext( &M_pForm_EditMotClef[ EVKEYTIT ], cpsz_title );

	cpsz_Event = fnct_spec( G_fnctlink, pDblText_paramsMotClef -> n_Event ) -> fnct_name;
	dlink_teptext( &M_pForm_EditMotClef[ NOMEVENT ], cpsz_Event );

	fix_ftext( M_pForm_EditMotClef, MOTCLEF, pDblText_paramsMotClef -> psz_KeyWord );

	pMsz_PgArboDest = dup_String( pDblText_paramsMotClef -> psz_DestPage );
	rlink_teptext( pObj_PageArbo, pMsz_PgArboDest );

	/* 
	 * Fixe noms actions dans le formulaire: 
	 */
	fix_popup_title( &M_pForm_EditMotClef[ MCACTION ], G_Popup_ActionMenu, pDblText_paramsMotClef -> n_Action1 );
	fix_popup_title( &M_pForm_EditMotClef[ CACTION2 ], G_Popup_ActionMenu, pDblText_paramsMotClef -> n_Action2 );

	/* 
	 * D‚part de l'effet graphique: 
	 */
	objc_xywh( pForm_fond, n_callObj, &GRect_start );
	open_dialog( M_pForm_EditMotClef, &GRect_start, &GRect_form );
	
	do
	{	/*
		 * Gestion dialogue: 
		 */
		exit_obj = ext_form_do( M_pForm_EditMotClef, &edit);	/* Gestion de la boŒte */

		switch( exit_obj )
		{
			case	MCACTION:
			case	MCACTBUT:
			{	/*
				 * Changement action:
				 * Appelle le Pop-Up: 
				 */
				int	selected = popup_inform( M_pForm_EditMotClef, exit_obj, MCACTION, G_Popup_ActionMenu, 
											 Popup_GetCurrVal( &M_pForm_EditMotClef[ exit_obj ] ) );	
				if( selected != ABORT_2 )
				{
					fix_popup_title( &M_pForm_EditMotClef[ MCACTION ], G_Popup_ActionMenu, selected );
					objc_draw( M_pForm_EditMotClef, MCACTION, 1, GRect_form .g_x,
	                       GRect_form .g_y, GRect_form .g_w, GRect_form .g_h );
				}

				graf_mouse( ARROW, 0);					/* souris: FlŠche */

				break;
			}
			
			case	CACTION2:
			case	CACTBUT2:
			{	/*
				 * Changement action:
				 * Appelle le Pop-Up: 
				 */
				int	selected = popup_inform( M_pForm_EditMotClef, exit_obj, CACTION2, G_Popup_ActionMenu, 
											 Popup_GetCurrVal( &M_pForm_EditMotClef[ exit_obj ] ) );
				if( selected != ABORT_2 )
				{
					fix_popup_title( &M_pForm_EditMotClef[ CACTION2 ], G_Popup_ActionMenu, selected );
					objc_draw( M_pForm_EditMotClef, CACTION2, 1, GRect_form .g_x,
	                       GRect_form .g_y, GRect_form .g_w, GRect_form .g_h );
				}

				graf_mouse( ARROW, 0);					/* souris: FlŠche */

				break;
			}

			case	BTARBODE:
			{	/*
				 * Si on veut fixer la destination:
				 * S‚lecteur RAM: 
				 */
				RAMSEL  selection = ramselect_fromForm( "S‚lection d'une page arbo:",
														find_datagroup_byType( DTYP_ARBO ), 
														&piBsz_PgArboDest,
														M_pForm_EditMotClef,
														exit_obj );
				if( selection != RAMSEL_ABORT )
				{
					GRECT	name_box;
	
					/*
					 * Oublie l'ancien et Sauve nom de page:
					 */
					freeOld_dupString( &pMsz_PgArboDest, &(piBsz_PgArboDest[5]) );	
	
					/*
					 * Change nom de la page dans le formulaire: 
					 */
					rlink_teptext( pObj_PageArbo, pMsz_PgArboDest );
					/*
					 * Redessine nom: 
					 */
					objc_xywh( M_pForm_EditMotClef, MCARBOD, &name_box );
					objc_draw( M_pForm_EditMotClef, MCARBOD, 1,
								  name_box .g_x, name_box .g_y, name_box .g_w, name_box .g_h );
				}
	
				graf_mouse( ARROW, 0);					/* souris: FlŠche */
		
				/* 
				 * D‚s‚lectionne bouton d'appel: 
				 */
				objc_dsel( M_pForm_EditMotClef, exit_obj );
			}
		}

	}while ( exit_obj != MOTCLVAL  &&  exit_obj != MOTCLANN );
	
	close_dialog( M_pForm_EditMotClef, exit_obj, &GRect_start, &GRect_form );

	/*
	 * Redessine le fond: 
	 */
	objc_draw( pForm_fond, 0, 5, GRect_form .g_x, GRect_form .g_y, GRect_form .g_w, GRect_form .g_h );

	if ( exit_obj == MOTCLVAL )
	{	/*
		 * Sauvegarde: 
		 */
		if( b_MotClef )
		{
			freeOld_dupString( &pDblText_paramsMotClef -> psz_KeyWord,
									 extract_ftext( M_pForm_EditMotClef, MOTCLEF ) );
		}

		/*
		 * Utilise la var locale:
		 */
		free_String( pDblText_paramsMotClef -> psz_DestPage );
		pDblText_paramsMotClef -> psz_DestPage = pMsz_PgArboDest;
	
		/*
		 * Action (Popup):
		 */
		pDblText_paramsMotClef -> n_Action1 = Popup_GetCurrVal( &M_pForm_EditMotClef[ MCACTION ] );
		pDblText_paramsMotClef -> n_Action2 = Popup_GetCurrVal( &M_pForm_EditMotClef[ CACTION2 ] );

		return	TRUE_1;
	}

	/*
 	 * Efface variables temporaires.
 	 */ 
	free_String( pMsz_PgArboDest );
	
	return	FALSE0;
}

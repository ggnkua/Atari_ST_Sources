/*
 * exformdo.c
 *
 * Purpose:
 * --------
 * Form_Do GEM ‚tendu
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"EXFORMDO.C v1.00 - 03.95"
           

/*
 * System headers:
 */
	#include <aes.h>
	#include <vdi.h>
	#include <stdio.h>
	#include <string.h>
   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include	"TEXT_PU.H"
	#include	"STKEYMAP.H"	
	#include	"VDI_PU.H"	
	#include "OBJCT_PU.H"
	#include "EXFRM_PU.H"

/*
 * ------------------------ PROTOTYPES -------------------------
 */


/*
 * PRIVate INTernal prototypes:
 */
	/* 
	 * Hot Spots: 
	 */
	int	form_dohot( OBJECT *tree, int hotobj, int mouse_x, int mouse_y, GRECT *rect, int *mode );
	int	breakobj( OBJECT *tree, int obj );
	int	breakx( int *pxy );
	int	breaky( int *pxy );
	int	inside( int x, int y, GRECT *pt );
	/* 
	 * Clavier: 
	 */
	int	form_dokeybd( OBJECT *tree, int editobj, int kr, int keystate, int *outobj, int *okr );
	int	finddef( OBJECT *tree, int obj );
	void	move_csr( OBJECT *tree, int editobj, int *okr, int *outobj );
	int	findtab( OBJECT *tree, int obj );
	/* 
	 * Souris: 
	 */
	int	form_dobutton( OBJECT *tree, int obj, int mouse_x, int clicks, int *nextobj, int *hotobj, int *ob_neweditx );
	void	doradio( OBJECT *tree, int obj );

   
   
/*
 * ------------------------ CONSTANTES -------------------------
 */
	#define	M1ENTER	0
	#define	M1EXIT	1



/*
 * ------------------------ VARIABLES -------------------------
 */

/*
 * External variables: 
 */
	/*
	 * Config: 
	 */
	extern	int		G_cnf_gest_form_std;	/* Gestion de formulaires Standard */


/*
 * Private variables: 
 */
	/*
	 * Pour rectangle d'attente sans hotspot: 
	 */
	static	GRECT	M_brrect;
	static	int	M_brmx, M_brmy, M_brtogl;					/* Maptree */
	/*
	 * Pour objet ‚ditable: 
	 */
	static	int	M_fnobj, M_fnlast, M_fnprev, M_fndir;		/* Maptree */
	/* 
	 * DerniŠre position souris: 
	 */
	static	int	M_mouse_x, M_mouse_y;
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * ext_form_do(-)
 *
 * Purpose:
 * --------
 * Appelle gestion standard ou ‚tendue selon config
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	ext_form_do( OBJECT *tree, int *startfield )
{	/*
	 * Si pas d'objet ‚ditable, *startfield devrait ˆtre nul 
	 */
	/* 
	 * Teste si on veut une gestion standard ou ‚tendue: 
	 */
	if ( G_cnf_gest_form_std )
	{	/*
		 * Gestion de formulaires Standard: 
		 */
		int	exit_obj;
		int	m_button;		/* Place holder */
		
		exit_obj = form_do( tree, *startfield );
		
		/*
		 * D‚termine coordonn‚es de la souris 
		 * lorsqu'on quitte le formulaire: 
		 */
		vq_mouse( G_ws_handle, &m_button, &M_mouse_x, &M_mouse_y );
		
		return	exit_obj;
	}
	else
	{	/*
		 * Gestion ‚tendue: 
		 */
		return	ext_form_gest( tree, startfield, FALSE0 );
	}
}


/*
 * ext_form_gest(-)
 *
 * Purpose:
 * --------
 * Gestion de Form_do ‚tendue
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	ext_form_gest(
			OBJECT *	tree, 
			int 	 *	startfield, 
			int 		allow_outside )
{

	/*
	 * Variables locales: 
	 */
	/* Edition: */
	int	editobj;		/* No de l'objet sur lequel est plac‚ le curseur */
							/* Donc celui auquel s'adresse le clavier */
	int	nextobj;		/* Objet sur lequel on a cliqu‚ avec la souris */
							/* Pourrait devenir le editobj si ‚ditable */
	int	ob_editx;	/* Position du curseur dans champ d'‚dition */
	int	ob_neweditx=-1;	/* Prochaine position */
	/* Hotspot: */
	int	hotmode;		/* =M1ENTER: la souris est hors du formulaire */
							/* =M1EXIT:  la souris est dedans */
	int	hotobj;		/* No de l'objet "HOT" actif ou -1 */
	GRECT	hotrect;		/* Rectangle d'attente souris courant */
	/* Gestion des ‚venements: */
	int	which;		/* Evenement produit */
	int	cont;			/* =-1 tant qu'on a pas d‚cid‚ de quitter */
	int	mb, ks, kr, br;
	/*	int	(*valid)(); */
		
	/* Initialisation ‚dition: */
	nextobj = *startfield;
	editobj = 0;
	
	/* Conditions de hotspot initiales: */
	hotobj = -1;
	hotmode = M1ENTER;
	objc_xywh( tree, 0, &hotrect );

	/* Boucle pple: */
	cont = TRUE_1;
	while( cont )
	{
		/*
		 * Positionne curseur sur le champ s‚lectionn‚: 
		 */
		if ( editobj != nextobj && nextobj != 0 )
		{
			editobj = nextobj;	/* Nouvel objet ‚ditable */
			nextobj = 0;			/* Pas encore d'autre demande! */
			objc_edit( tree, editobj, 0, &ob_editx, ED_INIT );
		}

		/*
		 * S'il faut modifier la position du curseur: 
		 */
		if ( ob_neweditx != -1 )
		{
			if ( ob_editx != ob_neweditx )
			{
				objc_edit( tree, editobj, 0, &ob_editx, ED_END );	/* Efface csr */
				ob_editx = ob_neweditx;		/* Nouvelle position */
				objc_edit( tree, editobj, 0, &ob_editx, ED_CHAR ); /* Positionne csr */
				objc_edit( tree, editobj, 0, &ob_editx, ED_END ); /* Affiche csr */
			}
			ob_neweditx = -1;
		}
		
		/*
		 * Attend ‚venement 
		 */
		which = evnt_multi( MU_KEYBD | MU_BUTTON | MU_M1,
							2, 1, 1,
							hotmode, hotrect .g_x, hotrect .g_y, hotrect .g_w, hotrect .g_h,
							0, 0, 0, 0, 0,
							NULL,
							0, 0,
							&M_mouse_x, &M_mouse_y, &mb,
							&ks, &kr,
							&br );
	
		/*
		 * Hotspot: 
		 */
		if ( which & MU_M1 )
			hotobj = form_dohot( tree, hotobj, M_mouse_x, M_mouse_y, &hotrect, &hotmode);

		/*
		 * Clavier: 
		 */
		if ( which & MU_KEYBD )
		{
			/*
			 * Filtrage des touches sp‚ciales: 
			 */
			cont = form_dokeybd( tree, editobj, kr, ks, &nextobj, &kr );
			/*
			 * Traite autres caractŠres normalement: 
			 */
			if( kr && editobj )
			{
				objc_edit( tree, editobj, kr, &ob_editx, ED_CHAR );
			}
		}
		
		/*
		 * Clics souris: 
		 */
		if( which & MU_BUTTON )
		{
			/*
			 * Trouve l'objet sur lequel on a cliqu‚: 
			 */
			nextobj = objc_find( tree, 0, 5, M_mouse_x, M_mouse_y );
			if ( nextobj == -1 )
			{	/*
				 * On a cliqu‚ hors du formulaire: 
				 * Teste s'il faut en tenir compte: 
				 */
				if( allow_outside )
				{	/*
					 * Si on doit prendre en compte un clic … l'ext‚rieur: 
					 */
					cont = FALSE0;		/* On interprŠte ‡a comme une Annulation */
				}
				else
				{	/*
					 * Si on doit ignorer les clics … l'ext‚rieur:
					 */
					nextobj = 0;
				}
			}
			else
			{	/*
				 * Traite le clic: 
				 */
				cont = form_dobutton( tree, nextobj, M_mouse_x, br, &nextobj, &hotobj, &ob_neweditx );
			}
		}

		/*
		 * Teste s'il faut effacer le curseur: 
		 */
		if ( 	!cont 
			||	(	nextobj != editobj
				&&	nextobj	!= 0
				)
			)
		{
			objc_edit( tree, editobj, 0, &ob_editx, ED_END );
		}
	}

	/*
	 * Teste s'il faut enlever HOTSPOT (en cas de pression sur Return ) 
	 */
	if ( hotobj != (nextobj & 0x7FFF) )
	{
		if ( hotobj != -1 )
			objc_toggle( tree, hotobj );
	}
					
	/*
	 * Fin 
	 */
	*startfield = editobj;		/* Objet en cours d'‚dition */
	return	nextobj;				/* Objet cliqu‚ */
}

  
/*
 * ------------------ GESTION DES HOT-SPOTS -----------------
 */                                   
 
  
/*
 * form_dohot(-)
 *
 * Purpose:
 * --------
 * Traitement des Hot Spots
 *
 * History:
 * --------
 * fplanque: Created
 */
int	form_dohot( OBJECT *tree, int hotobj, int M_mouse_x, int M_mouse_y, GRECT *rect, int *mode )
{
	GRECT	root;
	int	state;

	/*
	 * Trouve coordonn‚es de la boite pple: 
	 */
	objc_xywh( tree, 0, &root );
	
	/*
	 * S'il y a d‚j… un objet "allum‚", on l'‚teind: 
	 */
	if ( hotobj != -1 )
	{
		objc_toggle( tree, hotobj );
	}
			
	/*
	 * Si la souris est sortie du form: 
	 */
	if ( !(inside( M_mouse_x, M_mouse_y, &root ) ) )
	{
		*mode = M1ENTER;
		*rect = root;
		return -1;
	}
		
	/*
	 * Sinon, sur quel objet se trouve-t-on?: 
	 */
	hotobj = objc_find( tree, 0, 6, M_mouse_x, M_mouse_y );
	/* printf("Object: %d \n", hotobj); */
		
	/*
	 * S'agit-il d'un hotspot?: 
	 */
	state = tree[ hotobj ] .ob_state;
	/* printf("Obj flags=%X (selectable=%X) -> %X    \n", tree[ hotobj ] .ob_flags, SELECTABLE, ( tree[ hotobj ] .ob_flags & SELECTABLE ) ); */
	if ( tree[ hotobj ] .ob_flags & SELECTABLE )
	{
		if ( !(state & DISABLED) )
		{	/* Oui, c'est un hot spot... … allumer! */
			*mode = M1EXIT;	/* On le changera qd on ressortira */
			objc_xywh( tree, hotobj, rect );
			/*
			 * On va le mettre en inverse vid‚o 
			 * s'il n'est pas d‚j… s‚lectionn‚: 
			 */
			if ( state & SELECTED )
			{	/*
				 * Si d‚j… s‚lectionn‚, on ne fait rien: 
				 */
				return -1;
			}
			else
			{
				objc_toggle( tree, hotobj );
				return hotobj;
			}
		}
	}
	
	/* 
	 * Pas d'objet hotspot ss le curseur, alors calcule rectangle
	 *	qui nous int‚resse pour en trouver: 
	 */
	M_brrect = root;
	M_brmx = M_mouse_x;		/* Sauve coordonn‚es de la souris */
	M_brmy = M_mouse_y;
	M_brtogl = 0;
	maptree( tree, 0, -1, breakobj );
	*rect = M_brrect;
	*mode = M1EXIT;
	return -1;
}



/*
 * breakobj(-)
 *
 * Purpose:
 * --------
 * utilisé par form_dohot
 *
 * History:
 * --------
 * fplanque: Created
 */
int	breakobj( OBJECT *tree, int obj )
{
	GRECT	s;
	int	flags, broken, pxy[4];
	
	objc_xywh( tree, obj, &s );
	grecttoarray( &s, pxy );
	if ( !grcintersect(&M_brrect, &s) )
	{	/*
		 * Si l'objet test‚ est hors du rectangle de mouvement actuel: 
		 */
		return	0;			/* On l'ignore et ses enfants avec... */
	}
		
	/* 
	 * Teste les flags de l'objt pour voir s'il peut etre selectionne,
	 * Donc s'il peut passer au hot-spot, Dans le cas contraire, on va
	 * l'ignorer car il ne constituera pas la frontiŠre de la zone libre
	 * sans hot spots...
	 */
	flags = tree[ obj ] .ob_flags;
		
	if ( flags & HIDETREE )
	{	/*
		 * Si l'objet test‚ … ‚t‚ cach‚: 
		 */
		return	0;			/* On l'ignore et ses enfants avec... */
	}
	
	if ( !(flags & SELECTABLE) )
	{	/*
		 * Si l'objet test‚ n'est pas s‚lectionnable (-> ps de Hot-Spot): 
		 */
		return	-1;			/* On l'ignore mais pas ses enfants */
	}
	
	if ( tree[ obj ] .ob_state & DISABLED )
	{	/*
		 * Si l'objet test‚ est DISABLED: 
		 */
		return	-1;			/* On l'ignore mais pas ses enfants */
	}

	/*
	 * Arriv‚ ici, il y a un objet s‚lectionnable dans le rectangle
	 * de d‚limitation de la zone sans hot-spots; il va donc falloir 
	 * la r‚duire: BREAK
	 */
	if (M_brtogl)
	{
		broken = breakx( pxy );
		if ( !broken )
		{
			broken = breaky( pxy );
		}
	}
	else
	{
		broken = breaky(pxy);
		if ( !broken )
		{
			broken = breakx( pxy );
		}
	}

	M_brtogl = !M_brtogl;			/* Permet d'alterner les coupures verticales/horizontales */
	
	/* Emergency TEST:
	 * Si jamais le pointeur de la souris se rentrouve dans le rectangle
	 * de l'objet … exclure du rect de mvt de la souris!
	 * Ceci peut se produire dans 2 cas:
	 * - Il y a un objet non selectionnable inclus dans un s‚lectionnable
	 * - On tourne sous AES 4.0 pour lequel OBJC_FIND merdouille un peu!
	 */
	if ( !broken )
	{	/* 
		 * Si on n'a pas pu couper en X ni en Y: 
		 */
		/*	ping(); */
		M_brrect .g_x = M_brmx;		/* R‚duit zone de mvt … un seul point */
		M_brrect .g_y = M_brmy;
		M_brrect .g_w	= M_brrect .g_h = 1;
	}
	
	return TRUE_1;
}



/*
 * breakx(-)
 *
 * Purpose:
 * --------
 * Essaye de couper le rectangle d'attente verticalement
 *
 * History:
 * --------
 * fplanque: Created
 */
int	breakx( int *pxy )
{
	if ( M_brmx < pxy[ 0 ] )
	{	/*
		 * Si l'objet est … droite de la souris: 
		 */
		M_brrect .g_w = pxy[ 0 ] - M_brrect .g_x;	/* Coupe … droite */
		return	TRUE_1;		/* OK, c'est coup‚ */
	}
	
	if ( M_brmx > pxy[ 2 ] )
	{	/*
		 * Si l'objet est … gauche de la souris: 
		 */
		M_brrect .g_w += M_brrect .g_x - pxy[ 2 ] -1;	/* Coupe … gauche */
		M_brrect .g_x = pxy[ 2 ] +1;
		return	TRUE_1;		/* OK, c'est coup‚ */
	}
		
	return	FALSE0;	/* On n'a PAS pu couper! */
}



/*
 * breaky(-)
 *
 * Purpose:
 * --------
 * Essaye de couper le rectangle d'attente horizontalement
 *
 * History:
 * --------
 * fplanque: Created
 */
int	breaky( int *pxy )
{
	if ( M_brmy < pxy[ 1 ] )
	{	/*
		 * Si l'objet est au dessous de la souris: 
		 */
		M_brrect .g_h = pxy[ 1 ] - M_brrect .g_y;	/* Coupe en bas */
		return	TRUE_1;		/* OK, c'est coup‚ */
	}
	
	if ( M_brmy > pxy[ 3 ] )
	{	/*
		 * Si l'objet est au dessus de la souris: 
		 */
		M_brrect .g_h += M_brrect .g_y - pxy[ 3 ] -1;	/* Coupe en haut */
		M_brrect .g_y = pxy[ 3 ] +1;
		return	TRUE_1;		/* OK, c'est coup‚ */
	}
	
	return  FALSE0;	/* On n'a pas pu couper */
}


/*
 * inside(-)
 *
 * Purpose:
 * --------
 * D‚termine si un point est … l'int‚rieur d'un rectangle ou non
 *
 * History:
 * --------
 * fplanque: Created
 */
int inside( int x, int y, GRECT *pt )
{
	if ( 	( x >= pt -> g_x ) && ( y >= pt -> g_y )
		&&	( x < pt -> g_x + pt -> g_w ) && ( y < pt -> g_y + pt -> g_h ) )
	{
		return -1;
	}
	else
	{
		return 0;
	}
}


   
/*
 * ------------------------ CLAVIER -------------------------
 */


/*
 * form_dokeybd(-)
 *
 * Purpose:
 * --------
 * Form_Keybd
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 14.12.94: correction bug chp prec/chp suivant
 */
int	form_dokeybd( 
			OBJECT *	tree, 
			int 		editobj, 
			int 		kr, 
			int 		keystate, 
			int 	*	outobj, 
			int 	*	okr )
{
	char	low	= (char) kr;		/* Low byte */

	M_fndir = 1;			/* Direction TAB par d‚faut: AVANCE */

	/* printf("\r %X %X ", kr, keystate); */

	if( low )
	{	/*
		 * Si valide 
		 * On ne s'int‚resse plus k'… ‡a:
		 */
		kr = low;
		
		switch( kr )
		{
			case	CR:
				*okr = 0;
				M_fnobj = -1;
				maptree( tree, 0, -1, finddef );
				if (M_fnobj != -1 )
				{
					objc_sel( tree, M_fnobj );
					*outobj = M_fnobj;
					return 0;
				}
				/* Si pas d'objet default */
				move_csr( tree, editobj, okr, outobj );	/* Cherche champ suivant*/
				break;		
			
			case	TAB:
				if ( keystate & 0x0003 )
				{	/* Si touche Shift press‚e */
					M_fndir = 0;					/* Direction dir: ARRIERE */
				}
				move_csr( tree, editobj, okr, outobj );	/* Cherche champ suivant/pr‚c‚dent */
				break;
		}

		return	-1;
	}				

	/*
	 * On doit interpr‚ter le SCAN CODE
	 */
	switch( kr >> 8 )
	{
		case	STSCAN_UP:
			M_fndir	= 0;						/* Direction dir: ARRIERE */
		case	STSCAN_DOWN:
			move_csr( tree, editobj, okr, outobj );	/* Cherche champ */
			break;
	}

	return -1;
}



/*
 * finddef(-)
 *
 * Purpose:
 * --------
 * Finddef appel‚ par form_dokeybd()
 *
 * History:
 * --------
 * fplanque: Created
 */
int	finddef( OBJECT *tree, int obj )
{
	int	ob_flags = tree[ obj ] .ob_flags;

	if ( ob_flags & HIDETREE )
		return 0;
		
	if ( ob_flags & DEFAULT )
		if( !( tree[ obj ] .ob_state & DISABLED ) )
			M_fnobj = obj;

	return	-1;

}
 
 
 
/*
 * move_csr(-)
 *
 * Purpose:
 * --------
 * Provoque la recherche du champ ‚ditable suivant/pr‚c‚dent
 *
 * History:
 * --------
 * fplanque: Created
 */
void	move_csr( OBJECT *tree, int editobj, int *okr, int *outobj )
{
	*okr = 0;						/* La touche press‚e est une touche de contr“le */

	M_fnlast = editobj;				/* Initialise recherche */
	M_fnprev = M_fnobj = -1;

	maptree( tree, 0, -1, findtab);	/* Troube le champ recherch‚ */

	if ( M_fnobj == -1 )			/* Try to wrap around */
		maptree( tree, 0, -1, findtab );

	if ( M_fnobj != -1 )			/* Si on a trouv‚ un nouvel objet */
		*outobj = M_fnobj;				/* On s'y place */
}



/*
 * findtab(-)
 *
 * Purpose:
 * --------
 * description
 *
 * History:
 * --------
 * fplanque: Created
 */
int	findtab( OBJECT *tree, int obj )
{
	int	ob_flags = tree[ obj ] .ob_flags;

	if ( ob_flags & HIDETREE )
		return 0;
		
	if ( !(ob_flags & EDITABLE) )
		return 1;
		
	if ( M_fndir && M_fnprev == M_fnlast )
		M_fnobj = obj;
		
	if ( !M_fndir && obj == M_fnlast )
		M_fnobj = M_fnprev;
		
	M_fnprev = obj;
	
	return	-1;
}

 
 
   
/*
 * --------------------- CLICKS SOURIS ---------------------
 */



/*
 * form_dobutton(-)
 *
 * Purpose:
 * --------
 * Form_button
 *
 * History:
 * --------
 * fplanque: Created
 */
int	form_dobutton( OBJECT *tree, int obj, int M_mouse_x, int clicks, int *nextobj, int *hotobj, int *ob_neweditx )
{
	int	flags = tree[ obj ] .ob_flags;
	int	state = tree[ obj ] .ob_state;
	int	texit = flags & TOUCHEXIT;
	int	sble	= flags & SELECTABLE;
	int	dsbld	= state & DISABLED;
	int	edit	= flags & EDITABLE;
	int	hibit = 0;						/* Par d‚faut */
	int	instate;

	/* printf("Click! "); */

	if ( !texit && (!sble || dsbld) && !edit )
	{
		/* printf("Ya cant't click here!\n"); */
		/* ping(); */
		*nextobj = 0;
		return	-1;
	}
	
	if ( texit && clicks == 2 )
	{
		hibit = 0x8000;
	}
	
	if ( sble && !dsbld )
	{
		if ( flags & RBUTTON )
			doradio( tree, obj );
		else if ( !texit )
		{
			instate = ( obj == *hotobj)? state: state^SELECTED;
			if ( !graf_watchbox(tree, obj, instate, instate^SELECTED ) )
			{	/* Si l'utilisateur … abandonn‚ */
				ping();
				*nextobj = 0;
				*hotobj	= NIL;
				return	TRUE_1;
			}
		}
		else	/* if (texit) */
				if (obj != *hotobj )
					objc_toggle( tree, obj );
	}
	
	if ( obj == *hotobj )
		*hotobj = -1;
		
	if ( texit || (flags & EXIT) )
	{ 	/* Si le bouton conduit … abandonner le formulaire: */
		/* printf("****\rEXIT\r"); */
		*nextobj = obj | hibit;
		return FALSE0;
	}
	else
	{
		if ( edit )
		{	/* Si on a cliqu‚ sur un objet ‚ditable: */
			TEDINFO	*tedinfo	= tree[ obj ] .ob_spec.tedinfo;	/* Ptr sur TEDINFO */
			char		*ptext	= tedinfo -> te_ptext;				/* Ptr sur TEXTE */
			char		*ptemp	= tedinfo -> te_ptmplt;				/* Ptr sur MASQUE */
			int		temp_length;				/* Longueur du masque */
			int		temp_width;					/* Largeur du masque en pixels */
			int		ob_x, ob_y;					/* Coordonn‚es de l'objet */
			int		temp_offset;
			int		click_offset;
			int		new_pos = -1;
			int		i = 0;
			
			/* ping(); */

			/*
			 * Coordonn‚es absolues de l'objet: 
			 */
			objc_offset( tree, obj, &ob_x, &ob_y );
		
			/*
			 * Longueur du masque: 
			 */
			temp_length = (int) strlen( ptemp );
			temp_width	= temp_length * G_std_text .cell_w;
			/*
			 * Diff‚rence de largeur 
			 */
			temp_offset = tree[ obj ] .ob_width - temp_width;

			/*
			 * Offset X du click dans l'objet 
			 */
			click_offset = M_mouse_x - ob_x;
			/* 
			 * A modifier en fonction du "centrage" du texte: 
			 */
			switch( tedinfo -> te_just )
			{
				case	1:		/* Justifi‚ … droite: */
					click_offset -= temp_offset;
					break;
					
				case	2:		/* Centr‚: */
					click_offset -= temp_offset/2;
					break;
			}
			/*	printf("W=%d Click=%d/%d ",temp_width, click_offset, G_std_text.cell_w); */

			/*
			 * Cherche position dans le texte: 
			 */
			while( i <= temp_length )
			{	/*
				 * Parcourt le masque jusqu'… la position du click 
				 */
				if ( i * G_std_text .cell_w > click_offset )
				{	/* Si on a d‚pass‚ le click */
					break;
				}

				if ( ptemp[ i ] == '_' )
				{	/* Si on a pass‚ un emplacement texte: */
					new_pos++;
				}

				i++;
			}

			/*
			 * Masque la position demand‚e sur l'intervalle des possibles 
			 */
			*ob_neweditx = max( 0, min( (int)strlen( ptext ), new_pos ) );
			/*	printf("New x=%d\r",*ob_neweditx); */
		}
		else
		{	/*
			 * On a pas cliqu‚ sur un ‚ditable 
			 */
			*nextobj = 0;
		}
	}	

	/* printf("\r"); */
	return -1;
}



/*
 * doradio(-)
 *
 * Purpose:
 * --------
 * Pour les radio-buttons
 *
 * History:
 * --------
 * fplanque: Created
 */
void	doradio( OBJECT *tree, int obj )
{
	GRECT	root;
	int	pobj, sobj;

	objc_xywh( tree, 0, &root );
	pobj = objc_parent( tree, obj );
	for ( sobj = tree[ pobj ] .ob_head;		/* D‚but: 1er enfant */
			sobj != pobj;							/* Jusqu'… ce qu'on revienne au pŠre */
			sobj = tree[ sobj ] .ob_next )	/* Passe … l'obj suivant */
	{
		if ( sobj != obj )
		{	/* Si pas l'objet sur lequel on … cliqu‚: */
			objc_dsel( tree, sobj );
		}
	}
	objc_sel( tree, obj );	/* Sel objet cliqu‚ au cas ou pas encore fait */
}


   
   
/*
 * ------------------------ DIVERS -------------------------
 */



/*
 * extform_lastmpos(-)
 *
 * Purpose:
 * --------
 * DerniŠre position de la souris
 *
 * History:
 * --------
 * fplanque: Created
 */
void	extform_lastmpos( int *mx, int *my )
{
	*mx = M_mouse_x;
	*my = M_mouse_y;
}
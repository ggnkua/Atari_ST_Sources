/*
 * vdi.c
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"VDI.C v1.00 - 02.95"

/*
 * System headers:
 */
	#include	<stdio.h>
	#include <string.h>					/* header tt de chaines */
	#include	<aes.h>							/* Qques infos sont tjs n‚cessaires! */
	#include	<vdi.h>
/*	#include	<stdlib.h>						/* malloc */
   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "STUT_ONE.RSC\STUT_3.H"					/* noms des objets ds le ressource */
	#include	"DESK_PU.H"	
	#include "WIN_PU.H"	
	#include "TEXT_PU.H"
	#include	"DEBUG_PU.H"	
	#include	"RTERR_PU.H"	
	#include	"VDI_PU.H"	

/*
 * ------------------------ VARIABLES -------------------------
 */
    
    
/*
 * External variables: 
 */
	/* 
	 * Ic“nes: 
	 */
	extern 	int	G_arbocell_w;					/* Larg d'une ic“ne arbo */
	extern	int	G_arbocell_h;					/* Hauteur... */

/*
 * Public variables: 
 */
	/* 
	 * G‚n‚ral VDI: 
	 */
	int		G_aesws_handle;			/* Handle WStation AES */
	int		G_ws_handle;				/* Handle virtual WorkStation VDI */
	int		G_work_in[11];				/* VDI G_work_in */
	int		G_work_out[57];			/* VDI work out */
	int   	G_pxyarray[18];			/* Liste de coord X,Y pour le VDI */
	int		G_pxyarray2[10];	
	int		G_cliparray[ 4 ];
	MFDB		G_plogMFDB;					/* MFDB pour l'‚cran */
	/* 
	 * ParamŠtres supp: 
	 */
	int		G_nb_bitplanes;			/* Nbre de plans graphiques */
	int		G_nb_colors;				/* Nbre de couleurs simultan‚es */
	/* 
	 * Tampon AES: 
	 */
	char		*G_tampon_aes;				/* Adr tampon */
	size_t	G_long_tampon;				/* Longueur de ce tampn */
	MFDB		G_tamponMFDB;				/* MFDB pour le tampon AES */

	VDI_TEXT_PARAMS	G_aes_text;			/* ParamŠtres texte AES */
	VDI_TEXT_PARAMS	G_std_text;			/* ParamŠtres du texte standard */	
	int					G_cell_size_prop;	/* Rapport Hauteur/Largeur d'un emplacement caractŠre standard */
	TEXTSIZE_DEF	*	G_textsize_map;		/* Tableau des tailles de caractŠres */
	int					G_nb_textsizes=0;	/* Nbre de tailles de texte */
	/* 
	 * Userdefs: 
	 */
	USERBLK	G_bcroix_ublk = { bouton_croix, 0L };	/* Adr routine , Ob SPEC */	

	
/*
 * Private variables: 
 */
	/* 
	 * Motif de ligne pour fantômes d'icône: 
	 */
	static	int	M_motif[]={ 0x5555, 0xAAAA, 0xAAAA, 0x5555 };
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * init_vdi(-)
 *
 * Purpose:
 * --------
 * Initialisation VDI
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: fplanque: initialisation des paramŠtres de remplissage VDI
 * 17.10.94: corrig‚ bug des tailles de cars en COULEUR qui durait depuis plus d'un an! ouf :))
 */
void	init_vdi( void )
{
	TEXTSIZE_DEF	*textsize_ptr;
	int	point=4;									/* Arbitraire */
	int	char_w, char_h, cell_w, cell_h;
	int	i, foo;

	/*
	 * Tampon AES: 
	 */
	unsigned	int	adr_low, adr_high, len_low, len_high;

	TRACE0( "Initializing " THIS_FILE );

	/*
	 * Handle WorkStation VDI utilis‚e par l'AES: 
	 */
	G_aesws_handle = graf_handle( &(G_aes_text .cell_w), &(G_aes_text .cell_h),
               	             &foo, &foo );
	if( G_aesws_handle == 0 )
	{
		erreur( "[3][|"
						"L'interface graphique AES|"
						"ne peut pas ˆtre utilis‚e!]"
						"[ Quitter ]");
	}
	/* TRACE2( "Texte AES: W=%d H=%d", G_aes_text .cell_w, G_aes_text .cell_h ); */
						
	/*
	 * Ouverture de la station de travail ‚cran: 
	 */
	G_ws_handle = G_aesws_handle;		/* Je crois que CA c'est inutile! */

	for( i=0; i<10; G_work_in[ i++ ] = 1 )	/* Initialise tableau de variables */
		;
		
	G_work_in[ 7 ]	= 0;		/* Type de remplissage: vide */
	G_work_in[ 10 ] = 2;		/* Coordonn‚es RC */
	v_opnvwk( G_work_in, &G_ws_handle, G_work_out );
	if( G_ws_handle == 0 )
	{
		erreur( "[3][|"
						"L'interface graphique VDI|"
						"ne peut pas ˆtre utilis‚e!]"
						"[ Quitter ]");
	}

	/*
	 * R‚colte paramŠtres: 
	 */
	G_nb_colors = G_work_out[ 13 ];		/* Nombre de couleurs simultan‚es */
	/* TRACE0( "V_OPNVWK; Informations retourn‚es:" ); */
	/* TRACE1( "  Nb tailles de caractŠres=%d", G_work_out[5] ); */
	/* TRACE1( "  + Petite taille=%d", G_work_out[46] ); */
	/* TRACE1( "  + Grande taille=%d", G_work_out[48] ); */


	/*
	 * --------------------------------
	 * Fixe paramŠtres compl‚mentaires: 
	 * --------------------------------
	 * vsf_perimeter: Par d‚faut, les formes dessin‚es n'ont pas
	 * de contour (perimetre). Cet attribut devra toujours etre remis
	 * … NO0 aprŠs utilisation.
	 */
	vsf_perimeter( G_ws_handle, NO0 );

	/*
	 * vsf_interior: Par d‚faut, les formes dessin‚es le sont en couleur
	 * de fond/vide/0/blanc. Cet attribut devra tjs etre remis …
	 * FIS_HOLLOW aprŠs utilisation.
	 */
	vsf_interior( G_ws_handle, FIS_HOLLOW );	/* remplissage: VIDE(blanc) */

	/*
	 * vswr_mode: Par d‚faut, les formes sont dessin‚es en mode REPLACE
	 * Cet attribut devra tjs etre remis … MD_REPLACE aprŠs utilisation.
	 */
	vswr_mode( G_ws_handle, MD_REPLACE );

	/*
	 * Sauvegarde des paramŠtres texte standards: 
	 */
	vqt_attributes( G_ws_handle, (int *) &G_std_text );
	/* TRACE2( "Std text: Font:%d  Color:%d", G_std_text.font, G_std_text.color ); */
	/* TRACE2( "Std text: W:%d  H:%d",  G_std_text.cell_w, G_std_text.cell_h ); */

	/*
	 * Calcul la ratio hauteur/largeur des caractŠres:
	 */
	G_cell_size_prop = G_std_text .cell_h / G_std_text .cell_w;
	/* printf( "\nh:%d w:%d ratio:%d", G_std_text .cell_h, G_std_text .cell_w, G_cell_size_prop ); */

#if ! ACCEPT_SMALLFONTS
	if( G_std_text .cell_h != 16 )
	{
		erreur( "[3][Cette version de Stut One ne|"
						"peut adresser GEM-AES que dans|"
						"les r‚solutions o— les caractŠres|"
						"font 16 lignes de haut. Exemple|"
						"de problŠme: Moyenne ST 640*200.]"
						"[ Quitter ]");
	}
#endif

	/*
	 * Cr‚ation du tableau des tailles de caractŠres: 
	 */
	G_textsize_map = (TEXTSIZE_DEF *) MALLOC( sizeof( TEXTSIZE_DEF ) * DEFNB_TEXTSIZES );
	textsize_ptr = G_textsize_map;
	
	/*
	 * Recherche la premiŠre taille:
	 */
	vst_point( G_ws_handle, point, &char_w, &char_h, &cell_w, &cell_h);
	do
	{

		textsize_ptr -> points 	= point;
		textsize_ptr -> char_h	= char_h;
		textsize_ptr -> cell_w	= cell_w;
		textsize_ptr -> cell_h	= cell_h;

		point ++ ;

		vst_point( G_ws_handle, point, &char_w, &char_h, &cell_w, &cell_h);

	} while(	(cell_w == textsize_ptr -> cell_w) && (cell_h == textsize_ptr -> cell_h) );
	G_nb_textsizes++;		/* 1 taille de plus! */

	/*
	 * Corrige taille courante de maniŠre … reflŠter la 1ere taille ds point
	 */
	point --;

	/*
	 * Test des tailles suivantes disponibles 
	 */
	while	( G_nb_textsizes < DEFNB_TEXTSIZES )
	{
		do
		{
			point++;

			/* TRACE1( "  Going over: %d points", point ); */
			vst_point( G_ws_handle, point, &char_w, &char_h, &cell_w, &cell_h);
		} while( point < DEF_MAXSIZE && cell_w == textsize_ptr -> cell_w && cell_h == textsize_ptr -> cell_h);

		if ( point >= DEF_MAXSIZE )
		{
			break;
		}
		else
		{	/*
			 * On sauve la taille courante: 
			 */
			/* TRACE1( "  Saving %d points", point ); */
			textsize_ptr++;			/* Passe … l'emplacement suivant */
			textsize_ptr -> points 	= point;
			textsize_ptr -> char_h	= char_h;
			textsize_ptr -> cell_w	= cell_w;
			textsize_ptr -> cell_h	= cell_h;
			G_nb_textsizes++;		/* 1 taille de plus! */
		}
	}

	/*
	 * R‚duit la zone de stockage au strict n‚cessaire 
	 */
	G_textsize_map = (TEXTSIZE_DEF *) REALLOC( G_textsize_map, sizeof( TEXTSIZE_DEF ) * G_nb_textsizes );

	/*
	 * Affiche les tailles trouv‚es: 
	 */
	/*for ( i=0; i < G_nb_textsizes; i++ )
	  {
	 	TRACE3( "   Pts:%d  Char_h:%d  Cell_h:%d", G_textsize_map[i].points, G_textsize_map[i].char_h, G_textsize_map[i].cell_h);
	  }
	 */ 
	
	/*
	 * Trouve taille du texte par d‚faut: 
	 */
	for ( i=0; i<G_nb_textsizes; i++ )
	{
		if	( 	G_std_text .cell_w == G_textsize_map[ i ] .cell_w
			&& G_std_text .cell_h == G_textsize_map[ i ] .cell_h )
			break;
	}

	if( i == G_nb_textsizes )
	{
		signale( "ERR: Pas trouv‚ taille texte par d‚faut!" );
	}

	G_std_text.points =	G_textsize_map[ i ] .points;
	/* TRACE1( "Taille texte standard: %d points.", G_std_text.points ); */

	/*
	 * Memory Form Definition Block pour l'‚cran logique 
	 */
	G_plogMFDB.fd_addr=0;
	G_plogMFDB.fd_w=0;				/* Largeur en pixels */
	G_plogMFDB.fd_h=0;				/* Hauteur en pixels */
	G_plogMFDB.fd_wdwidth=0;		/* Blockbreite in Integern  */
   G_plogMFDB.fd_stand=0;			/* 0 = ger„teabh„ngiges Format
	                             	1 = Standardformat       */
	G_plogMFDB.fd_nplanes=0;		/* Nb plans */
	G_plogMFDB.fd_r1=0;				/* R‚serv‚ */
	G_plogMFDB.fd_r2=0;				/* R‚serv‚ */
	G_plogMFDB.fd_r3=0;				/* R‚serv‚ */

	/*
	 * Demande paramŠtres 
	 */
	vq_extnd( G_ws_handle, 1, G_work_out );
	G_nb_bitplanes = G_work_out[ 4 ];	/* Nombre de plans graphiques */
	/* printf("Nbre de plans:%d \n",G_work_out[4]); */

	/*
	 * Demande zone tampon aes: 
	 */
	wind_get( 0, WF_SCREEN, &adr_high, &adr_low, &len_high, &len_low);
	G_tampon_aes = (char *) (( (unsigned long)adr_high <<16) | adr_low);
	G_long_tampon= ( (unsigned long)len_high <<16) | len_low;
	/*	printf("Tampon AES: %lu %lu\n",G_tampon_aes,G_long_tampon); */

	/*
	 * Memory Form Definition Block pour le tampon AES: 
	 */
	G_tamponMFDB.fd_addr=G_tampon_aes;
	G_tamponMFDB.fd_w=0;				/* Largeur en pixels (set by RUNTIME) */
	G_tamponMFDB.fd_h=0;				/* Hauteur en pixels (set by RUNTIME) */
	G_tamponMFDB.fd_wdwidth=0;		/* Taille en mots d'un seul plan d'une seule ligne (set by RUNTIME)  */
   G_tamponMFDB.fd_stand=1;		/* 0 = ger„teabh„ngiges Format
		                             	1 = Standardformat       */
	G_tamponMFDB.fd_nplanes=G_nb_bitplanes;	/* Nb plans */
	G_tamponMFDB.fd_r1=0;				/* R‚serv‚ */
	G_tamponMFDB.fd_r2=0;				/* R‚serv‚ */
	G_tamponMFDB.fd_r3=0;				/* R‚serv‚ */

	/*	getchar(); */
}



/*
 * draw_fantom(-)
 *
 * Purpose:
 * --------
 * Dessine le fant“me d'une ic“ne
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	draw_fantom( int x, int y )
{
	int		i;
	
	/*		printf("%d %d \r", x,y ); */

	/*
	 * D‚finit le M_motif de Horizontal 
	 */
	vsl_udsty( G_ws_handle, M_motif[ y%2 ] );

	graf_mouse( M_OFF, 0L );

	/*
	 * Traits horizontaux: 
	 */
	for( i=0; i<=14 ; i +=4)
	{
		v_pline( G_ws_handle, 2, &G_pxyarray[i] );
	}
		
	/*
	 * D‚finit le M_motif de Vertical 
	 */
	vsl_udsty( G_ws_handle, M_motif[ (x%2)*2 + y%2 ] );

	/*
	 * Traits verticaux: 
	 */
	for( i=2; i<=16 ; i +=4)
	{
		v_pline( G_ws_handle, 2, &G_pxyarray[i] );
	}

	graf_mouse( M_ON, 0L );

}

/*
 * rig_draw_fantom(-)
 *
 * Purpose:
 * --------
 * Dessine le fant“me d'une ic“ne avec rigueur!
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	rig_draw_fantom( void )
{
	int		i;

	graf_mouse( M_OFF, 0L );
	
	/* Traits horizontaux: */
	for( i=0; i<=4 ; i +=4)
	{
		/* D‚finit le M_motif de Horizontal */
		vsl_udsty( G_ws_handle, M_motif[ G_pxyarray[i+1] %2 ] );
		/* Traits: */
		v_pline( G_ws_handle, 2, &G_pxyarray[i] );
	}
		

	/* Traits verticaux: */
	for( i=2; i<=6 ; i +=4)
	{
		/* D‚finit le M_motif de Vertical */
		vsl_udsty( G_ws_handle, M_motif[ (G_pxyarray[i]%2)*2 + G_pxyarray[i+1]%2 ] );
		/* Taits: */
		v_pline( G_ws_handle, 2, &G_pxyarray[i] );
	}
		
	graf_mouse( M_ON, 0L );

}




/*
 * draw_proposition(-)
 *
 * Purpose:
 * --------
 * Dessine une proposition de placement
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	draw_proposition( void )
{

	graf_mouse( M_OFF, 0L );

	/* Traits: */
	v_pline( G_ws_handle, 5, G_pxyarray2 );

	graf_mouse( M_ON, 0L );

}



/*
 * bouton_croix(-)
 *
 * Purpose:
 * --------
 * Objet USERDEF: Bouton-croix
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int cdecl bouton_croix(
				PARMBLK *parmblock)
{
	/* State: */
	int		ob_prevstate = parmblock -> pb_prevstate;
	int		ob_state 	 = parmblock -> pb_currstate;

	/* Fixe clipping */
	G_cliparray[0] = parmblock -> pb_xc ;
	G_cliparray[1] = parmblock -> pb_yc ;
	G_cliparray[2] = G_cliparray[0] + parmblock -> pb_wc ;
	G_cliparray[3] = G_cliparray[1] + parmblock -> pb_hc ;
	vs_clip( G_ws_handle, 1, G_cliparray );	/*  clipping ON    */

	/* Teste s'il faut dessiner le fond de la boŒte: */
	if ( ob_prevstate == ob_state )
	{ /* On est en objc draw: */
		/* Params dessin: */
		vsf_color( G_ws_handle, BLACK );		/* Couleur cadre */
		vsf_perimeter( G_ws_handle, 1 );		/* Encadre boŒte */
	
		/* Dessine cadre: */
		G_pxyarray[0] = parmblock->pb_x +1;
		G_pxyarray[1] = parmblock->pb_y +1;
		G_pxyarray[2] = parmblock->pb_w + G_pxyarray[0] -2;
		G_pxyarray[3] = parmblock->pb_h + G_pxyarray[1] -2;
		v_bar( G_ws_handle, G_pxyarray );			/* trace le rectangle */	

		vsf_perimeter( G_ws_handle, 0 );		/* N'encadre plus les boites */
	}

	/* Trace la croix dedans: */
	/* Params dessin: */
	vsl_type( G_ws_handle, 1 );				/* Trait continu */
	vsl_color( G_ws_handle, (ob_state & SELECTED)?1:0 );	/* Couleur ligne */

	/* Dessine croix: */
	G_pxyarray[0] = parmblock->pb_x +2;
	G_pxyarray[1] = parmblock->pb_y +2;
	G_pxyarray[2] = G_pxyarray[0] + parmblock->pb_w -4;
	G_pxyarray[3] = G_pxyarray[1] + parmblock->pb_h -4;
	v_pline( G_ws_handle, 2, G_pxyarray );
	G_pxyarray[4] = G_pxyarray[0];
	G_pxyarray[5] = G_pxyarray[3];
	G_pxyarray[6] = G_pxyarray[2];
	G_pxyarray[7] = G_pxyarray[1];
	v_pline( G_ws_handle, 2, &G_pxyarray[4] );

	ob_state &= (!SELECTED);		/* Selected trait‚ */
		

	/* Fin de l'affichage */
	vs_clip( G_ws_handle, 0, G_cliparray );	/* clipping OFF */

	return ob_state;
}




/*
 * draw_grid(-)
 *
 * Purpose:
 * --------
 * Objet USERDEF: Grille arborescence
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int cdecl draw_grid(
				PARMBLK *parmblock)
{
	/* Flags de l'objet: */
	/*	unsigned		ob_flags= parmblock->pb_tree[ parmblock->pb_obj ] .ob_flags; */
	/* State: */
		int		ob_state 	= parmblock -> pb_currstate;
	/* Ob_spec: */ 
		OBSPEC	*ob_spec		= (OBSPEC *) &(parmblock -> pb_parm);
		int		framesize	= (ob_spec -> obspec) .framesize;
		unsigned	framecol		= (ob_spec -> obspec) .framecol;

		int		min_pos_x, min_pos_y;
		int		max_pos_x, max_pos_y;
	
	/* Fixe clipping */
		G_cliparray[0] = parmblock->pb_xc ;
		G_cliparray[1] = parmblock->pb_yc ;
		G_cliparray[2] = G_cliparray[0] + parmblock->pb_wc -1;
		G_cliparray[3] = G_cliparray[1] + parmblock->pb_hc -1;
		vs_clip( G_ws_handle, 1, G_cliparray );	/*  clipping ON  */

	/* Dessine boite de fond */
		G_pxyarray[0] = parmblock->pb_x;
		G_pxyarray[1] = parmblock->pb_y;
		G_pxyarray[2] = G_pxyarray[0] + parmblock->pb_w -1;
		G_pxyarray[3] = G_pxyarray[1] + parmblock->pb_h -1;
		/* Prend en compte l'attribut OUTLINED */
			if ( ob_state & OUTLINED )	
			{	/* Si outlined*/
				G_pxyarray[ 0 ] -= 2;
				G_pxyarray[ 1 ] -= 2;
				G_pxyarray[ 2 ] += 2;
				G_pxyarray[ 3 ] += 2;
				ob_state &= (!OUTLINED);	/* Outlined trait‚ */
			}
		v_bar(G_ws_handle,G_pxyarray);			/*  trace le fond */	

	/* Frame */
		if ( framesize )
		{	/* Ne gŠre que les cadres int‚rieurs! */
			int	i;
			
			vsl_color( G_ws_handle, framecol );	/* Couleur cadre */
			vsl_type( G_ws_handle, 1 );				/* Trait continu */

			G_pxyarray[0] = parmblock->pb_x;
			G_pxyarray[1] = parmblock->pb_y;
		
			G_pxyarray[2] = G_pxyarray[0] + parmblock->pb_w -1;
			G_pxyarray[3] = G_pxyarray[1];		/* Y Haut droit */

			G_pxyarray[4] = G_pxyarray[2];		/* X Bas droit */
			G_pxyarray[5] = G_pxyarray[1] + parmblock->pb_h -1;

			G_pxyarray[6] = G_pxyarray[0];		/* X Bas gauche */
			G_pxyarray[7] = G_pxyarray[5];		/* Y Bas gauche */
			
			G_pxyarray[8] = G_pxyarray[0];		/* X Haut gauche */
			G_pxyarray[9] = G_pxyarray[1];		/* Y Haut gauche */

			v_pline( G_ws_handle, 5, G_pxyarray );	/* Trace cadre std */

			for ( i=1; i<framesize; i++ )	/* Passe aux positions suivantes */
			{
				G_pxyarray[ 0 ] ++;
				G_pxyarray[ 1 ] ++;

				G_pxyarray[ 2 ] --;
				G_pxyarray[ 3 ] ++;

				G_pxyarray[ 4 ] --;
				G_pxyarray[ 5 ] --;

				G_pxyarray[ 6 ] ++;
				G_pxyarray[ 7 ] --;

				G_pxyarray[ 8 ] ++;
				G_pxyarray[ 9 ] ++;

				v_pline( G_ws_handle, 5, G_pxyarray );	/* Trace cadre */
			}
		}

	/* Quadrillage: */
		vsl_type( G_ws_handle, 1 );				/* Trait Continu */

		min_pos_x = parmblock->pb_x +framesize				/* On se place juste aprŠs le bord */
					+	(parmblock->pb_xc-parmblock->pb_x) 	/* Tient compte du d‚calage occasionn‚ par le clipping */
						/ G_arbocell_w * G_arbocell_w;		/* Place sur 1ere colonne affich‚e */
		min_pos_y = parmblock->pb_y +framesize-2
					+	(parmblock->pb_yc-parmblock->pb_y)	/* Tient compte du d‚calage occasionn‚ par clipping */
						/ G_arbocell_h * G_arbocell_h;

		max_pos_x = parmblock->pb_xc +parmblock->pb_wc;
		max_pos_y = parmblock->pb_yc +parmblock->pb_hc;
		
		G_pxyarray[ 0 ] = min_pos_x;
		G_pxyarray[ 2 ] = min_pos_x;

		G_pxyarray[ 4 ] = min_pos_x -2;
		G_pxyarray[ 6 ] = G_pxyarray[ 4 ] +4;

		while( G_pxyarray[ 0 ] <= max_pos_x )
		{
			G_pxyarray[ 1 ] = min_pos_y;
			G_pxyarray[ 3 ] = min_pos_y +4;

			G_pxyarray[ 5 ] = min_pos_y +2;
			G_pxyarray[ 7 ] = G_pxyarray[ 5 ]; 

			while ( G_pxyarray[ 1 ] <= max_pos_y )
			{
				v_pline( G_ws_handle, 2, G_pxyarray );	/* Trace ligne */
				G_pxyarray[ 1 ] += G_arbocell_h;
				G_pxyarray[ 3 ] += G_arbocell_h;

				v_pline( G_ws_handle, 2, &G_pxyarray[4] );	/* Trace ligne */
				G_pxyarray[ 5 ] += G_arbocell_h;
				G_pxyarray[ 7 ] += G_arbocell_h;
			}

			G_pxyarray[ 0 ] += G_arbocell_w;
			G_pxyarray[ 2 ] += G_arbocell_w;

			G_pxyarray[ 4 ] += G_arbocell_w;
			G_pxyarray[ 6 ] += G_arbocell_w;
		}
		
	/* Fin de l'affichage */
		vs_clip( G_ws_handle, 0, G_cliparray );	/* clipping OFF */

	return ob_state;
}
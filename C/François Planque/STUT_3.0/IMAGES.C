/*
 * images.c
 *
 * Purpose:
 * --------
 * Gestion d'images
 *
 * History:
 * --------
 * fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"IMAGES.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
	#include	<aes.h>						/* header AES */
   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "S_MALLOC.H"
	#include	"WIN_PU.H"
	

/*
 * ------------------------ PROTOTYPES -------------------------
 */
/*
 * EXTernal prototypes:
 */
	/* 
	 * G‚n‚ral: 
	 */
	extern	void	ping( void );
	extern	void	signale( const char * inf );
	/*
	 * fenˆtres: 
	 */
	extern	WIPARAMS *find_datawindow2( unsigned long adr_contenu, WIPARAMS *start );
	extern	void	put_wi_on_top( WIPARAMS *wi_params_adr );


/*
 * PRIVate INTernal prototypes:
 */
	static	void	set_MFDB_pi3( MFDB *picMFDB, DEGASPIX *pointeur );

/*
 * ------------------------ VARIABLES -------------------------
 */

    
/*
 * External variables: 
 */
	/* 
	 * G‚n‚ral: 
	 */
	extern	int	G_x_mini, G_y_mini;			/* Coord sup gauche de l'‚cran */
	extern	int	G_w_maxi, G_h_maxi;			/* Taille de l'‚cran de travail */
	/*
	 * Fenˆtres
	 */
	extern	WIPARAMS		*G_wi_list_adr;		/* Adresse de l'arbre de paramŠtres */


/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * pi3_optimal(-)
 *
 * Purpose:
 * --------
 * D‚termine fenˆtre optimale (full) pour une image Degas
 *
 * History:
 * --------
 * fplanque: Created
 */
void pi3_optimal( int wi_ckind, int *border_x, int *border_y, int *border_w, int *border_h)
{
	int	work_x, work_y, work_w, work_h;	/* Coordonn‚es zone de travail */

	work_x = 50;								/* Arbitraire */
	work_y = 50;
	work_w = 640;								/* Taille image */
	work_h = 400;

	/*
	 * Calcule les coordonn‚es totales de la fenˆtre: 
	 */
	wind_calc( WC_BORDER, wi_ckind, work_x, work_y, work_w, work_h,
					border_x, border_y, border_w, border_h );

	/*
	 * Contr“le que ‡a rentre... 
	 */
	if ( *border_w > G_w_maxi )
		*border_w = G_w_maxi;
	if ( *border_h > G_h_maxi )
		*border_h = G_h_maxi;

	/*
	 * Centrage: 
	 */		
	*border_x = G_x_mini + ( G_w_maxi - *border_w ) / 2;
	*border_y = G_y_mini + ( G_h_maxi - *border_h ) / 2;
		
}



/*
 * access_image(-)
 *
 * Purpose:
 * --------
 * Essaie d'acc‚der … une image en m‚moire pour l'afficher
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 06.08.94: extraction du code de controle du nbre de fenˆtre ouverte sur DATAPAGE (limite: 1)
 */
int	access_image( 
			DATAPAGE *datapage, 
			WORK_CONTENT *content_ptr, 
			WORK_DRAW *draw_ptr )
{
	/*
	 * Fixe adr de la page courante! (qui contient celle de l'image:) 
	 */
	content_ptr -> datapage = datapage;

	/*
	 * Cr‚e et fixe un MFDB appropri‚ pour l'affichage de l'image: 
	 */
	draw_ptr -> psrcMFDB = (MFDB *) MALLOC( sizeof( MFDB ) ); 
	set_MFDB_pi3( draw_ptr -> psrcMFDB, (content_ptr -> datapage) -> data.degaspix );

	return	1;		/* On peut ouvrir */
}



/*
 * set_MFDB_pi3(-)
 *
 * Purpose:
 * --------
 * Initialisation MFDB pour une image PI3
 *
 * History:
 * --------
 * fplanque: Created
 */
void	set_MFDB_pi3( MFDB *picMFDB, DEGASPIX *pointeur )
{
	picMFDB -> fd_addr= pointeur -> bitmap;
	picMFDB -> fd_w=640;			/* Largeur en pixels */
	picMFDB -> fd_h=400;			/* Hauteur en pixels */
	picMFDB -> fd_wdwidth=(80 / (int)sizeof(int));	/* Blockbreite in Integern  */
											/* CAST integer n‚cessaire!)
   picMFDB -> fd_stand=0;			/* 0 = ger„teabh„ngiges Format
	                             	1 = Standardformat       */
	picMFDB -> fd_nplanes=1;		/* Nb plans */
	picMFDB -> fd_r1=0;				/* R‚serv‚ */
	picMFDB -> fd_r2=0;				/* R‚serv‚ */
	picMFDB -> fd_r3=0;				/* R‚serv‚ */
}


/*
 * open_pi3(-)
 *
 * Purpose:
 * --------
 * Ouverture d'une fenˆtre contenant une PI3
 *
 * History:
 * --------
 * fplanque: Created
 */
void	open_pi3( WIPARAMS *wi_params_adr, DATAPAGE *content_ptr, MFDB *draw_ptr )
{
	wi_params_adr -> content_ptr.datapage = content_ptr;	/* Pointeur sur contenu */
	wi_params_adr -> draw_ptr.psrcMFDB	= draw_ptr;			/* Pointeur sur struct MFDB */
	wi_params_adr -> total_w	= 640;		/* Taille totale */
	wi_params_adr -> total_h	= 400;
	wi_params_adr -> h_step		= 16;			/* Saut par 16 pix */
	wi_params_adr -> v_step 	= 16;			/* Saut par 16 pix */
}


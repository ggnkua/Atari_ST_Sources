/*
 * Main_Public.h
 */

#ifndef	MAIN_PU_H
#define	MAIN_PU_H

#include "WIN_PU.H"

/*
 * ----- MEMBRES ----
 */

	extern	int		G_ap_id;						/* Identification par l'AES */
	extern	unsigned	G_version_aes;				/* Version AES */
	extern	int		G_x_mini, G_y_mini;		/* Coord sup gauche de l'‚cran */
	extern	int		G_w_maxi, G_h_maxi;		/* Taille de l'‚cran de travail */
	extern	int		G_wx_mini, G_wy_mini;	/* Dimensions maximales d'une */
	extern	int		G_ww_maxi, G_wh_maxi;	/* fenˆtre complŠte */
	extern	int		G_n_ScreenW, G_n_ScreenH;		/* Taille ‚cran */

	extern	WIPARAMS	*G_wi_list_adr;			/* Adresse de l'arbre de paramŠtres */
	extern	int		G_top_wi_handle;			/* Fenˆtre g‚r‚e par le programme
																la plus en haut, mais pouvant ˆtre
																surpass‚e par un accessoire */

	/*
	 * ParamŠtres de la "Fenˆtre" dans laquelle 
	 * se trouve la s‚lection actuelle:
 	 */
	extern	WIPARAMS	*G_selection_adr;	

	extern	int		G_ev_mgpbuff[32];			/* Buffer d'‚venements GEM (normalement, ‡a ne fait que 8 mais bon, ‡a pourrait monter ds prochainesversions AES) */
	extern	int		G_mouse_x,G_mouse_y;		/* Coordonn‚es souris (Evt_multi) */
	extern	int		G_mouse_button;			/* Etat des boutons (Evt_multi) */			
	extern	int		G_kbd_state;				/* Etat des touches sp‚ciales... */
	extern	int		G_kbd_return;				/* Scan code touche... */
	extern	int		G_mouse_nbc;				/* Nombre de cliks ... */
	
	extern	int		G_fin;						/* Non nul si G_fin du prg demand‚e */

/*
 * ----- METHODES ----
 */
	extern	WIPARAMS	* wi_params ( int handle );

	extern	void	graf_beginmove( OBJECT *srce_tree, OBJECT *srce_adr, int destination, OBJECT *dest_adr );

	extern	void	no_selection( void );
	extern	void	erreur( const char *texte_erreur );
	extern	void	erreur_rsrc( void );
	extern	int	alert( int type, ... );


	extern	void	apropos( const GRECT *start_box );
	extern	void	ouverture( void );
	extern	BOOL	main_quitter( void );	/* Out: TRUE si on autorise … quitter */
	extern	void	sauver( void );
	extern	void	parametrage ( const GRECT *start_box );

#endif
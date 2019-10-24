/*
 * VDI_Public.h
 *
 * Definitions supplementaires pour le VDI
 *
 * History:
 * --------
 * Created by fplanque
 */

/*
 * V‚rifie si les pr‚sentes d‚finitions ont d‚ja ‚t‚ faites:
 */
#ifndef VDIDEF_H
#define VDIDEF_H	0

#include "TEXT_PU.H"


/*
 * VDI text definitions:
 */
#define	HALIGN_LEFT			0		/* Texte justifi‚ … gauche */
#define	HALIGN_CENTER		1		/* Texte centr‚ */
#define	HALIGN_RIGHT		2		/* Texte justifi‚ … droite */

#define	VALIGN_BASE			0
#define	VALIGN_HALF			1
#define	VALIGN_ASCENT		2
#define	VALIGN_BOTTOM		3
#define	VALIGN_DESCENT		4
#define	VALIGN_TOP			5


/*
 * -------- membres publics -------------
 */

	/* 
	 * G‚n‚ral VDI: 
	 */
	extern 	int		G_aesws_handle;			/* Handle WStation AES */
	extern	int		G_ws_handle;				/* Handle virtual WorkStation VDI */
	extern	int		G_work_in[];				/* VDI G_work_in */
	extern	int		G_work_out[];			/* VDI work out */
	extern	int   	G_pxyarray[];			/* Liste de coord X,Y pour le VDI */
	extern	int		G_pxyarray2[];	
	extern	int		G_cliparray[];
	extern	MFDB		G_plogMFDB;					/* MFDB pour l'‚cran */

	extern	VDI_TEXT_PARAMS	G_std_text;	/* ParamŠtres du texte standard */	

	extern	int					G_cell_size_prop;	/* Rapport Hauteur/Largeur d'un emplacement caractŠre standard */

	extern	USERBLK	G_bcroix_ublk;			/* Pour bouton-croix */


	/* 
	 * VDI: 
	 */
	extern	void	init_vdi( void );
	extern	void	draw_fantom( int x, int y );	/* Dessine le fant“me d'une ic“ne */

	extern	void	rig_draw_fantom( void );	/* Dessine le fant“me d'une ic“ne */
	extern	void	draw_proposition( void );	/* Dessine proposition de placement */
	extern	int	cdecl draw_grid(PARMBLK *parmblock);	/* USERDEF Grille */
	int cdecl bouton_croix(PARMBLK *parmblock);


/*
 * Fin du test anti red‚finition:
 */
#endif

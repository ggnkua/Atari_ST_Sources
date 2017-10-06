/* screen.h */

#ifndef _SCRNLDG_H
#define _SCRNLDG_H

typedef struct
{
	short firstcolor;
	short nbcolors;
	char firstred;
} screen_paletteRGB;

typedef struct
{
	void *add_RGB;       /* adresse du buffer image au format natif RGB 8bits 
															par couleur ou au format natif de l'‚cran si on utilise
															les fonctions direct_xxx() */
	unsigned WORD largeur_RGB;   /* largeur de l'image RGB */
	unsigned WORD hauteur_RGB;   /* hauteur de l'image RGB */
	void *add_ECRAN;     /* adresse ‚cran ou m‚moire  */
	unsigned WORD largeur_ECRAN; /* largeur de l'‚cran en pixels */
	unsigned WORD hauteur_ECRAN; /* hauteur de l'‚cran en pixels */
	LONG octets;  /* nombres d'octets de d‚calage en fin de ligne sur la plupart des 
								cartes = 0*/
	unsigned WORD  position_X;   /* position sur l'‚cran en pixels selon X de d‚part de recopie */
	unsigned WORD position_Y;	   /* position sur l'‚cran en pixels selon Y de d‚part de recopie */
	unsigned WORD X_voulu;       /* position dans l'image en pixels selon X de d‚part de recopie */
	unsigned WORD Y_voulu;       /* position dans l'image en pixels selon Y de d‚part de recopie */
	unsigned WORD largeur_voulue;/* largeur en pixel de recopie */
	unsigned WORD hauteur_voulue;/* hauteur en pixels de recopie */
  void *add_palette_SP;/* adresse d'un tableau de char 255 valeurs des correspondances
  																de couleur pour le cas sans palette hard */
} videoinf;

typedef struct
{
	unsigned char *chainepix;  /* adresse de la chaine de caractŠre d‚crivant un pixel */
	unsigned char retour1;    /* 0 oK, 0xFF ‚cran non support‚ */ 
	unsigned char retour2;    /* 0xFF routine g‚n‚rale lente */
	unsigned WORD version;    /* num‚ro de version */
	unsigned char *palettecouleur; /* adresse palette couleur */
	unsigned char *palettegris;    /* adresse palette grise */
} sortievideo;

#endif
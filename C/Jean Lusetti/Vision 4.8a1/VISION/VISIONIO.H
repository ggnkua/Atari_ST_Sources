#ifndef __VISIONIO
#define __VISIONIO

#if !defined( __STDIO )
#include <stdio.h>
#endif

#if !defined(__IMAGE_IO_H)
#include "..\tools\image_io.h"
#endif

/************************/
/* Header de VISIONIO.C */
/************************/
extern char last_path[PATH_MAX] ; /* Chemin pr‚c‚dent */


/*************************************************/
/* Chargement d'une image IMG dans un ‚l‚ment du */
/* Tableau img et dans une fenetre               */
/*************************************************/
void load_wpicture(char *name, long lformat) ;

/******************************************************/
/* Demande d'ouverture d'une fenetre li‚e … une image */
/* Si flag=1, le fichier est ouvert au format         */
/* Sp‚cifi‚ par l'utilisateur.                        */
/******************************************************/
void traite_ouvre(int flag) ;

/***************************************************/
/* Sauvegarde avec s‚curit‚ (flag = 1) ou remplace */
/* Le fichier image de la fenetre courante.        */
/***************************************************/
void traite_sauves(GEM_WINDOW* wnd, int flag) ;

/******************************************************************/
/* Renvoit les les coordonn‚es d'ouverture d'une nouvelle fenˆtre */
/******************************************************************/
void open_where(int wkind, int w, int h, int *xout, int *yout, int *wout, int *hout) ;


int tiff_options(INFO_IMAGE *inf) ;
int targa_options(INFO_IMAGE *inf) ;
int jpeg_options(INFO_IMAGE *inf) ;

void traite_slideshow(char *name) ;
void log_event(int type, char *file_name) ;

#define VIMG_CLASSNAME  "CN_VIMG"
GEM_WINDOW* VImgCreateWindow(void) ;
void AttachPictureToWindow(GEM_WINDOW* gwnd) ;

#endif

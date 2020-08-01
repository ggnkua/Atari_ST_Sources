/****************************/
/*-------- IMG_IO.H --------*/
/* Header de IMG_IO.C       */
/* Chargement et sauvegarde */
/* D'images au format IMG   */
/****************************/
#if !defined(__IMG)
#define __IMG

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif


typedef struct
{
  int version ;       /* Version du format IMG           */
  int header_length ; /* Taille du header en mots        */
  int nb_plane ;      /* Nombre de plans de l'image      */
  int pattern_run ;   /* Taille du pattern_run en octets */
  int widthm ;        /* Largeur d'un pixel en microns   */
  int heigthm ;       /* Hauteur du pixel en microns     */
  int pixel_line ;    /* Nombre de pixels par ligne      */
  int nb_line ;       /* Nombre de lignes de l'image     */
} IMG_HEADER ;


/********************************************************/
/* Chargement d'une image au format IMG                 */
/* Dans un MFDB qui sera initialis‚ par cette fonction  */
/* En retour :  0 : OK                                  */
/*             -1 : Le fichier name n'existe pas        */
/*             -2 : Le num‚ro de la version est inconnu */
/*             -3 : M‚moire insuffisante                */
/********************************************************/
int img_load(INFO_IMAGE* inf) ;

/****************************************************************/
/* Sauve un MFDB au format IMG                                  */
/* wm et wh sont la largeur et la hauteur en microns d'un pixel */
/* En retour :  0 : OK                                          */
/*             -1 : Impossible de cr‚er le fichier sp‚cifi‚     */
/****************************************************************/
int img_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog) ;

/***********************************/
/* Identification d'un fichier IMG */
/***********************************/
int img_identify(char *nom, INFO_IMAGE *inf) ;

void img_getdrvcaps(INFO_IMAGE_DRIVER *caps) ;

#endif

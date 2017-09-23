/*******************************/
/* Header de NEO_IO.C          */
/* Gestion du format Neochrome */
/*******************************/
#if !defined(__NEO)
#define __NEO

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif


typedef struct
{
  int  zero ;     /* Toujours nul */
  int  resol ;    /* 0 : basse, 1 : Moyenne, 2 : Haute */
  int  pal[16] ;  /* Palette RVB 3 bits */
  char anim[12] ;
  int  v_anim ;
  int  nb_pas ;
  int  off_x ;    /* Toujours 0 */
  int  off_y ;    /* Toujours 0 */
  int  largeur ;  /* Toujours 320 */
  int  hauteur ;  /* Toujours 200 */
  int  reserved[34] ;
}
NEO_HEADER ;


int  neo_load(char *name, MFDB *out, GEM_WINDOW *wprog) ;
int  neo_identify(char *nom, INFO_IMAGE *inf) ;
int  neo_sauve(char *name, MFDB *img, INFO_IMAGE *inf, GEM_WINDOW *wprog) ;
void neo_getdrvcaps(INFO_IMAGE_DRIVER *caps) ;

#endif

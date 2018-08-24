/**********************************/
/* Header du module ART_IO.C      */
/* Gestion du format Art Director */
/**********************************/
#if !defined(__ART)
#define __ART

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif

int  art_load(char *name, MFDB *out, GEM_WINDOW *wprog) ;
int  art_sauve(char *name, MFDB *img, INFO_IMAGE *inf, GEM_WINDOW *wprog) ;
int  art_identify(char *nom, INFO_IMAGE *inf) ;
void art_getdrvcaps(INFO_IMAGE_DRIVER *caps) ;

#endif

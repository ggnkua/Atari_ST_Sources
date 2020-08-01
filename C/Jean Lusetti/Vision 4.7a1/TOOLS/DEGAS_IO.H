/********************************************/
/* Gestion du standard DEGAS et DEGAS-ELITE */
/********************************************/
#if !defined(__DEGAS)
#define __DEGAS

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif

typedef struct
{
  int resolution ;  /* 0 : Basse ST   320x200  16 couleurs      */
                    /* 1 : Moyenne ST 640x200   4 couleurs      */
                    /* 2 : Haute ST   640x400   2 couleurs      */
                    /* Si resolution < 0, l'image est compact‚e */
  int palette[16] ; /* Le mot est cod‚ ainsi :                  */
                    /* Bits FEDCBA9876543210                    */
                    /*      00000RRR0VVV0BBB                    */
}
DEGAS_HEADER ;



int  degas_load(INFO_IMAGE* inf) ;
int  degas_sauve(char *name, MFDB *img, INFO_IMAGE *inf, GEM_WINDOW *wprog) ;
int  degas_identify(char *nom, INFO_IMAGE *inf) ;
void degas_getdrvcaps(INFO_IMAGE_DRIVER *caps) ;

#endif
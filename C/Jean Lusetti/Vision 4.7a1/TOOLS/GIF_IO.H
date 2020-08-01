/**********************/
/* Header de GIF_IO.C */
/**********************/
#if !defined(__GIF)
#define __GIF

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif


#define ID_DECRIPTOR   ','
#define GIF_TERMINATOR ';'


typedef struct
{
  char          signature[6] ;
  unsigned int  width ;
  unsigned int  height ;
  unsigned char color_inf ;
  unsigned char background ;
  unsigned char map ;
}
GIF_HEADER ;

typedef struct
{
  unsigned int  deltax ;
  unsigned int  deltay ;
  unsigned int  width ;
  unsigned int  height ;
  unsigned char color_inf ;
}
GIF_DESCRIPTOR ;


int  gif_load(INFO_IMAGE* inf) ;
int  gif_identify(char *nom, INFO_IMAGE *inf) ;
int  gif_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog) ;
void gif_getdrvcaps(INFO_IMAGE_DRIVER *caps) ;


#endif

#if !defined(__MACPAINT)
#define __MACPAINT

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif

typedef struct
{
  long version ;
  char pattern[304] ;
  char reserved[204] ;
}
MACPAINT_HEADER ;


int  mac_load(INFO_IMAGE* inf) ;
int  mac_identify(char *nom, INFO_IMAGE *inf) ;
void mac_getdrvcaps(INFO_IMAGE_DRIVER *caps) ;

#endif
/*********************/
/* Header de ALBUM.C */
/*********************/
#if !defined(__ALBUM)
#define __ALBUM

#if  !defined( __AES__ )
#include <xaes.h>
#endif

#if !defined(__CATALOG)
#include "..\tools\catalog.h"
#endif

extern CATALOG_FILTER cfilter ;


OBJECT *make_category_popup(GEM_WINDOW *wnd) ;
void traite_album(char *name) ;


#endif
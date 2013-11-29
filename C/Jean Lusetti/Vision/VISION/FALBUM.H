/*********************/
/* Header de ALBUM.C */
/*********************/
#if !defined(__ALBUM)
#define __ALBUM

#if  !defined( __AES__ )
#include <aes.h>
#endif

#if !defined(__CATALOG)
#include "..\tools\catalog.h"
#endif

extern int            nb_categories ;
extern CATALOG_FILTER cfilter ;
extern char           img_comment[SIZE_COMMENT] ;


OBJECT *make_category_popup(void) ;
void traite_album(char *name) ;


#endif
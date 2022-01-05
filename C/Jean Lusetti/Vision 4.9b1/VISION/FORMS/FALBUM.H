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

#define MSG_ALB_REFRESH (WM_USER_FIRST+0)

OBJECT *make_category_popup(GEM_WINDOW* wnd) ;
void traite_album(char* name) ;
int ObjectNotifyAlb(void *w, int obj, void* external_call) ;
HCAT GethCatFromAlbumWindow(GEM_WINDOW* wnd) ;

#endif
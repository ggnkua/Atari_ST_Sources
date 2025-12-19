#if !defined(__ALBUM_H)
#define __ALBUM_H

#if  !defined( __AES__ )
#include <xaes.h>
#endif

#if !defined(__CATALOG_H)
#include "..\tools\catalog.h"
#endif

#define MSG_ALB_REFRESH (WM_USER_FIRST+0)

OBJECT* make_category_popup(GEM_WINDOW* wnd) ;
void    traite_album(char* name) ;
int     ObjectNotifyAlb(void* w, int obj, void* external_call) ;
HCAT    GethCatFromAlbumWindow(GEM_WINDOW* wnd) ;

#endif
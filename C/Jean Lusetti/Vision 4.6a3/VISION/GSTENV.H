#ifndef __GSTENV
#define __GSTENV

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

/**********************/
/* Header de GSTENV.C */
/**********************/
int  GetRVBForVIMG(GEM_WINDOW *wnd, int mx, int my, int rvb[3]) ;
int  ztool(int num) ;
void update_tools(int *msg, char *flags) ;
int  OnAppKeyPressed(int key) ;
int  OnAppMenuSelected(int t_id, int m_id) ;
void OnAppUpdateGUI(void) ;
void update_view(GEM_WINDOW *gw) ;
void update_zview(GEM_WINDOW *gw) ;
void set_goodmouse(void) ;
void vshow_dialog(OBJECT *obj, char *title) ;
void vhide_dialog(void) ;
void traite_snapshot_key(int key) ;

void param_icon(int mx, int my) ;
void select_icon(int mx, int my) ;

void iconify_picture(GEM_WINDOW *wnd) ;
void select_zoom(GEM_WINDOW *gwnd, int mzoom) ;
void traite_espace(GEM_WINDOW *gwnd) ;
int  traite_thickness(int key) ;

int  OnVImgClose(void *wnd) ;
int  OnVImgTopped(void *wnd) ;
void OnVImgDraw(void *wnd, int xycoords[4]) ;
int  OnVImgKeyPressed(void *wnd, int key) ;
int  OnVImgMenuSelected(void *wnd, int t_id, int m_id) ;
void OnVImgArrow(void *wnd, int action);
void OnVImgHSlider(void *wnd, int pos);
void OnVImgVSlider(void *wnd, int pos);
void OnVImgSize(void *wnd, int xywh[4]) ;
int  OnVImgFulled(void *wnd) ;
int  OnVImgRestoreFulled(void *wnd) ;
int  OnVImgMouseMove(void *wnd, int button, int kstate, int mx, int my) ;
int  OnVImgIconify(void *wnd, int xywh[4]) ;
int  OnVImgUnIconify(void *wnd, int xywh[4]) ;
int  OnVImgLButtonDown(void *wnd, int mk_state, int x, int y) ;
int  OnVImgDLButtonDown(void *wnd, int mk_state, int x, int y) ;
int  OnVImgRButtonDown(void *wnd, int mk_state, int x, int y) ;
int  OnVImgDRButtonDown(void *wnd, int mk_state, int x, int y) ;
int  OnVImgProgRange(void *wnd, long val, long max, char *txt) ;

#endif
#include <windom.h>

void w_v_gtext( WINDOW *win, int x, int y, char *txt) {
	if(vq_vgdos() == '_FSM')
		v_ftext( win->graf.handle, x, y, txt);
	else
		v_gtext( win->graf.handle, x, y, txt);
}


void w_vqt_extent( WINDOW *win, char *txt, int *pxy) {
	if(vq_vgdos() == '_FSM')
		vqt_f_extent( win->graf.handle, txt, pxy);
	else
		vqt_extent( win->graf.handle, txt, pxy);
}

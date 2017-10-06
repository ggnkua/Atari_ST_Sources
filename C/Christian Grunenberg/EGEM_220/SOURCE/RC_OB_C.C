
#define __RC_OBJ_C__
#include "e_gem.h"

#ifdef __GNUC__
int rc_inside(int x, int y, GRECT *rec)
{
	return (x >= rec->g_x && x < rec->g_x + rec->g_w &&
			y >= rec->g_y && y < rec->g_y + rec->g_h);
}
#endif	/* __GNUC__ */

#ifdef LATTICE
void rc_grect_to_array(GRECT *rec,int *pxy)
{
	pxy[0] = rec->g_x;
	pxy[1] = rec->g_y;
	pxy[2] = rec->g_x + rec->g_w - 1;
	pxy[3] = rec->g_y + rec->g_h - 1;
}
#endif	/* LATTICE */

void rc_array_to_grect(int *pxy,GRECT *rec)
{
	rec->g_x = pxy[0];
	rec->g_y = pxy[1];
	rec->g_w = pxy[2] - pxy[0] + 1;
	rec->g_h = pxy[3] - pxy[1] + 1;
}

int EvntMulti(EVENT *evnt_struct)
{
	return (evnt_struct->ev_mwich = evnt_multi(evnt_struct->ev_mflags,
		evnt_struct->ev_mbclicks,
		evnt_struct->ev_bmask,
		evnt_struct->ev_mbstate,
		evnt_struct->ev_mm1flags,
		evnt_struct->ev_mm1x,
		evnt_struct->ev_mm1y,
		evnt_struct->ev_mm1width,
		evnt_struct->ev_mm1height,
		evnt_struct->ev_mm2flags,
		evnt_struct->ev_mm2x,
		evnt_struct->ev_mm2y,
		evnt_struct->ev_mm2width,
		evnt_struct->ev_mm2height,
		evnt_struct->ev_mmgpbuf,
		((unsigned long)evnt_struct->ev_mthicount << 16) + evnt_struct->ev_mtlocount,
		&evnt_struct->ev_mmox,
		&evnt_struct->ev_mmoy,
		&evnt_struct->ev_mmobutton,
		&evnt_struct->ev_mmokstate,
		&evnt_struct->ev_mkreturn,
		&evnt_struct->ev_mbreturn));
}

/*
 * Aes object library extension of MagiC
 *
 */
#include "gemx.h"


void objc_wchange(OBJECT *tree, int obj, int new_state, GRECT *clip,  int whandle)
{
#ifndef __MSHORT__
	short	srect[4];
	srect[0] = clip->g_x;
	srect[1] = clip->g_y;
	srect[2] = clip->g_w;
	srect[3] = clip->g_h;
	aes_addrin[1] = (long)srect;
#else
	aes_addrin[1] = (long)clip;
#endif
	aes_intin[0] = obj;
	aes_intin[1] = new_state;
	aes_intin[2] = whandle;
	aes_addrin[0] = (long)tree;
   aes_control[0] = 61;
   aes_control[1] = 3;
   aes_control[2] = 0;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
}

void objc_wdraw(OBJECT *tree, int start, int depth, GRECT *clip,  int whandle)
{
#ifndef __MSHORT__
	short	srect[4];
	srect[0] = clip->g_x;
	srect[1] = clip->g_y;
	srect[2] = clip->g_w;
	srect[3] = clip->g_h;
	aes_addrin[1] = (long)srect;
#else
	aes_addrin[1] = (long)clip;
#endif
	aes_intin[0] = start;
	aes_intin[1] = depth;
	aes_intin[2] = whandle;
	aes_addrin[0] = (long)tree;
   aes_control[0] = 60;
   aes_control[1] = 3;
   aes_control[2] = 0;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
}

int objc_wedit(OBJECT *tree, int obj, int key, int *idx, int kind, int whandle)
{
	aes_intin[0] = obj;
	aes_intin[1] = key;
	aes_intin[2] = *idx;
	aes_intin[3] = kind;
	aes_intin[4] = whandle;
	aes_addrin[0] = (long)tree;
   aes_control[0] = 65;
   aes_control[1] = 5;
   aes_control[2] = 2;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	*idx = aes_intout[1];
	return aes_intout[0];
}

int objc_xedit(OBJECT *tree, int obj, int key, int *xpos, int subfn, GRECT *r)
{
#ifndef __MSHORT__
	short	srect[4];
	srect[0] = r->g_x;
	srect[1] = r->g_y;
	srect[2] = r->g_w;
	srect[3] = r->g_h;
	aes_addrin[1] = (long)srect;
#else
	aes_addrin[1] = (long)r;
#endif
	aes_intin[0] = obj;
	aes_intin[1] = key;
	aes_intin[2] = *xpos;
	aes_intin[3] = subfn;
	aes_addrin[0] = (long)tree;
   aes_control[0] = 46;
   aes_control[1] = 4;
   aes_control[2] = 2;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
	*xpos = aes_intout[1];
	return aes_intout[0];
}

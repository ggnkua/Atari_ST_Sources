/*
 * Aes object library extension of MagiC
 *
 */

#include <aes.h>
#include <vdi.h>
#include "pcgemx.h"

void objc_wchange(OBJECT *tree, int obj, int new_state, GRECT *clip,  int whandle)
{
#ifndef __MSHORT__
	short	srect[4];
	srect[0] = clip->g_x;
	srect[1] = clip->g_y;
	srect[2] = clip->g_w;
	srect[3] = clip->g_h;
	aespb.addrin[1] = (long)srect;
#else
	aespb.addrin[1] = (long)clip;
#endif
	aespb.intin[0] = obj;
	aespb.intin[1] = new_state;
	aespb.intin[2] = whandle;
	aespb.addrin[0] = (long)tree;
   aespb.contrl[0] = 61;
   aespb.contrl[1] = 3;
   aespb.contrl[2] = 0;
   aespb.contrl[3] = 2;
   aespb.contrl[4] = 0;
   aes( &aespb);
}

void objc_wdraw(OBJECT *tree, int start, int depth, GRECT *clip,  int whandle)
{
#ifndef __MSHORT__
	short	srect[4];
	srect[0] = clip->g_x;
	srect[1] = clip->g_y;
	srect[2] = clip->g_w;
	srect[3] = clip->g_h;
	aespb.addrin[1] = (long)srect;
#else
	aespb.addrin[1] = (long)clip;
#endif
	aespb.intin[0] = start;
	aespb.intin[1] = depth;
	aespb.intin[2] = whandle;
	aespb.addrin[0] = (long)tree;
   aespb.contrl[0] = 60;
   aespb.contrl[1] = 3;
   aespb.contrl[2] = 0;
   aespb.contrl[3] = 2;
   aespb.contrl[4] = 0;
   aes( &aespb);
}

int objc_wedit(OBJECT *tree, int obj, int key, int *idx, int kind, int whandle)
{
	aespb.intin[0] = obj;
	aespb.intin[1] = key;
	aespb.intin[2] = *idx;
	aespb.intin[3] = kind;
	aespb.intin[4] = whandle;
	aespb.addrin[0] = (long)tree;
   aespb.contrl[0] = 65;
   aespb.contrl[1] = 5;
   aespb.contrl[2] = 2;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes( &aespb);
	*idx = aespb.intout[1];
	return aespb.intout[0];
}

int objc_xedit(OBJECT *tree, int obj, int key, int *xpos, int subfn, GRECT *r)
{
#ifndef __MSHORT__
	short	srect[4];
	srect[0] = r->g_x;
	srect[1] = r->g_y;
	srect[2] = r->g_w;
	srect[3] = r->g_h;
	aespb.addrin[1] = (long)srect;
#else
	aespb.addrin[1] = (long)r;
#endif
	aespb.intin[0] = obj;
	aespb.intin[1] = key;
	aespb.intin[2] = *xpos;
	aespb.intin[3] = subfn;
	aespb.addrin[0] = (long)tree;
   aespb.contrl[0] = 46;
   aespb.contrl[1] = 4;
   aespb.contrl[2] = 2;
   aespb.contrl[3] = 2;
   aespb.contrl[4] = 0;
   aes( &aespb);
	*xpos = aespb.intout[1];
	return aespb.intout[0];
}

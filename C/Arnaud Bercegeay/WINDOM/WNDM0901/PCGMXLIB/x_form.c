/*
 * Aes form library extension of MagiC
 *
 */
#include <aes.h>
#include <vdi.h>
#include "pcgemx.h"

int form_popup(OBJECT *tree, int x, int y)
{
	aespb.intin[0] = x;
	aespb.intin[1] = y;
	aespb.addrin[0] = (long)tree;
   aespb.contrl[0] = 135;
   aespb.contrl[1] = 2;
   aespb.contrl[2] = 1;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes(&aespb);
	return aespb.intout[0];
}

int form_wbutton(OBJECT *fo_btree, int fo_bobject, int fo_bclicks, int *fo_bnxtobj, int whandle)
{
	aespb.intin[0] = fo_bobject;
	aespb.intin[1] = fo_bclicks;
	aespb.intin[2] = whandle;
	aespb.addrin[0] = (long)fo_btree;
   aespb.contrl[0] = 63;
   aespb.contrl[1] = 3;
   aespb.contrl[2] = 2;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes(&aespb);
	*fo_bnxtobj = aespb.intout[1];
	return aespb.intout[0];
}

int form_wkeybd(OBJECT *fo_ktree, int fo_kobject, int fo_kobnext, int fo_kchar, 
					int *fo_knxtobject, int *fo_knxtchar, int whandle)
{
	aespb.intin[0] = fo_kobject;
	aespb.intin[1] = fo_kchar;
	aespb.intin[2] = fo_kobnext;
	aespb.intin[3] = whandle;
	aespb.addrin[0] =(long)fo_ktree;
   aespb.contrl[0] = 64;
   aespb.contrl[1] = 4;
   aespb.contrl[2] = 3;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes(&aespb);
	*fo_knxtobject = aespb.intout[1];
	*fo_knxtchar = aespb.intout[2];
	return aespb.intout[0];
}

int form_xdial(int fo_diflag, int fo_dilittlx, int fo_dilittly, int fo_dilittlw, 
					int fo_dilittlh, int fo_dibigx, int fo_dibigy, int fo_dibigw, 
					int fo_dibigh, void **flydial)
{
	aespb.intin[0] = fo_diflag;
	aespb.intin[1] = fo_dilittlx;
	aespb.intin[2] = fo_dilittly;
	aespb.intin[3] = fo_dilittlw;
	aespb.intin[4] = fo_dilittlh;
	aespb.intin[5] = fo_dibigx;
	aespb.intin[6] = fo_dibigy;
	aespb.intin[7] = fo_dibigw;
	aespb.intin[8] = fo_dibigh;
	aespb.addrin[0] = (long)flydial;
   aespb.contrl[0] = 51;
   aespb.contrl[1] = 9;
   aespb.contrl[2] = 1;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes(&aespb);
	return aespb.intout[0];
}

int form_xdo(OBJECT *tree, int startob, int *lastcrsr, XDO_INF *tabs, void *flydial)
{
	aespb.intin[0] = startob;
	aespb.addrin[0] = (long)tree;
	aespb.addrin[1] = (long)tabs;
	aespb.addrin[2] = (long)flydial;
   aespb.contrl[0] = 50;
   aespb.contrl[1] = 1;
   aespb.contrl[2] = 2;
   aespb.contrl[3] = 3;
   aespb.contrl[4] = 0;
   aes(&aespb);
	*lastcrsr = aespb.intout[1];
	return aespb.intout[0];
}

int form_xerr(long errcode, char *errfile)
{
	unsigned short *i = (unsigned short *)&errcode;

	aespb.intin[0] = i[1];
	aespb.intin[1] = i[0];
	aespb.addrin[0] = (long)errfile;
   aespb.contrl[0] = 136;
   aespb.contrl[1] = 2;
   aespb.contrl[2] = 1;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes(&aespb);
	return aespb.intout[0];
}

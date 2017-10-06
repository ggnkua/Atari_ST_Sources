/*
 * Aes form library extension of MagiC
 *
 */
#include "gemx.h"


int form_popup(OBJECT *tree, int x, int y)
{
	aes_intin[0] = x;
	aes_intin[1] = y;
	aes_addrin[0] = (long)tree;
   aes_control[0] = 135;
   aes_control[1] = 2;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}

int form_wbutton(OBJECT *fo_btree, int fo_bobject, int fo_bclicks, int *fo_bnxtobj, int whandle)
{
	aes_intin[0] = fo_bobject;
	aes_intin[1] = fo_bclicks;
	aes_intin[2] = whandle;
	aes_addrin[0] = (long)fo_btree;
   aes_control[0] = 63;
   aes_control[1] = 3;
   aes_control[2] = 2;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	*fo_bnxtobj = aes_intout[1];
	return aes_intout[0];
}

int form_wkeybd(OBJECT *fo_ktree, int fo_kobject, int fo_kobnext, int fo_kchar, 
					int *fo_knxtobject, int *fo_knxtchar, int whandle)
{
	aes_intin[0] = fo_kobject;
	aes_intin[1] = fo_kchar;
	aes_intin[2] = fo_kobnext;
	aes_intin[3] = whandle;
	aes_addrin[0] =(long)fo_ktree;
   aes_control[0] = 64;
   aes_control[1] = 4;
   aes_control[2] = 3;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	*fo_knxtobject = aes_intout[1];
	*fo_knxtchar = aes_intout[2];
	return aes_intout[0];
}

int form_xdial(int fo_diflag, int fo_dilittlx, int fo_dilittly, int fo_dilittlw, 
					int fo_dilittlh, int fo_dibigx, int fo_dibigy, int fo_dibigw, 
					int fo_dibigh, void **flydial)
{
	aes_intin[0] = fo_diflag;
	aes_intin[1] = fo_dilittlx;
	aes_intin[2] = fo_dilittly;
	aes_intin[3] = fo_dilittlw;
	aes_intin[4] = fo_dilittlh;
	aes_intin[5] = fo_dibigx;
	aes_intin[6] = fo_dibigy;
	aes_intin[7] = fo_dibigw;
	aes_intin[8] = fo_dibigh;
	aes_addrin[0] = (long)flydial;
   aes_control[0] = 51;
   aes_control[1] = 9;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}

int form_xdo(OBJECT *tree, int startob, int *lastcrsr, XDO_INF *tabs, void *flydial)
{
	aes_intin[0] = startob;
	aes_addrin[0] = (long)tree;
	aes_addrin[1] = (long)tabs;
	aes_addrin[2] = (long)flydial;
   aes_control[0] = 50;
   aes_control[1] = 1;
   aes_control[2] = 2;
   aes_control[3] = 3;
   aes_control[4] = 0;
   aes(&aes_params);
	*lastcrsr = aes_intout[1];
	return aes_intout[0];
}

int form_xerr(long errcode, char *errfile)
{
	unsigned short *i = (unsigned short *)&errcode;

	aes_intin[0] = i[1];
	aes_intin[1] = i[0];
	aes_addrin[0] = (long)errfile;
   aes_control[0] = 136;
   aes_control[1] = 2;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}

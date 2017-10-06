/*
 * Aes forms library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cg -- d2cg@dtek.chalmers.se
 * modified: cf -- felsch@tu-harburg.de
 */
#include "gem.h"


int form_alert(int DefButton, char *Str)
{
	aes_intin[0] = DefButton;
	aes_addrin[0] = (long)Str;
	aes_control[0] = 52;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int form_button(void *Btree, int Bobject, int Bclicks, int *Bnxtobj)
{
	aes_addrin[0] = (long)Btree;
	aes_intin[0] = Bobject;
	aes_intin[1] = Bclicks;
	aes_control[0] = 56;
	aes_control[1] = 2;
	aes_control[2] = 2;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	*Bnxtobj = aes_intout[1];
	return aes_intout[0];
}


int form_center(void *Tree, int *Cx, int *Cy, int *Cw, int *Ch)
{
	aes_addrin[0] = (long)Tree;
	aes_control[0] = 54;
	aes_control[1] = 0;
	aes_control[2] = 5;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	*Cx = aes_intout[1];
	*Cy = aes_intout[2];
	*Cw = aes_intout[3];
	*Ch = aes_intout[4];
 	return aes_intout[0];
}


int form_dial(int Flag,	int Sx, int Sy, int Sw, int Sh, int Bx, int By, int Bw, int Bh)
{
	aes_intin[0] = Flag;
	aes_intin[1] = Sx;
	aes_intin[2] = Sy;
	aes_intin[3] = Sw;
	aes_intin[4] = Sh;
	aes_intin[5] = Bx;
	aes_intin[6] = By;
	aes_intin[7] = Bw;
	aes_intin[8] = Bh;
	aes_control[0] = 51;
	aes_control[1] = 9;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int form_do(void *Tree, int StartObj)
{
	aes_intin[0] = StartObj;
	aes_addrin[0] = (long)Tree;
	aes_control[0] = 50;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int form_error(int ErrorCode)
{
	aes_intin[0] = ErrorCode;
	aes_control[0] = 53;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int form_keybd(void *Ktree, int Kobject, int Kobnext, int Kchar, int *Knxtobject, int *Knxtchar)
{
	aes_addrin[0] =(long) Ktree;
	aes_intin[0] = Kobject;
	aes_intin[1] = Kchar;
	aes_intin[2] = Kobnext;
	aes_control[0] = 55;
	aes_control[1] = 3;
	aes_control[2] = 3;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	*Knxtobject = aes_intout[1];
	*Knxtchar = aes_intout[2];
	return aes_intout[0];
}

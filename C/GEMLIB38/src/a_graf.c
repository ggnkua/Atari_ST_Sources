/*
 * Aes graphics library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch@tu-harburg.de
 */
#include "gem.h"


int graf_dragbox(int Sw, int Sh, int Sx, int Sy, int Bx, int By, int Bw, int Bh, int *Fw, int *Fh)
{
	aes_intin[0] = Sw;
	aes_intin[1] = Sh;
	aes_intin[2] = Sx;
	aes_intin[3] = Sy;
	aes_intin[4] = Bx;
	aes_intin[5] = By;
	aes_intin[6] = Bw;
	aes_intin[7] = Bh;
	aes_control[0] = 71;
	aes_control[1] = 8;
	aes_control[2] = 3;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	*Fw = aes_intout[1];
	*Fh = aes_intout[2];
	return aes_intout[0];
}


int graf_growbox(int Sx, int Sy, int Sw, int Sh, int Fx, int Fy, int Fw, int Fh)
{
	aes_intin[0] = Sx;
	aes_intin[1] = Sy;
	aes_intin[2] = Sw;
	aes_intin[3] = Sh;
	aes_intin[4] = Fx;
	aes_intin[5] = Fy;
	aes_intin[6] = Fw;
	aes_intin[7] = Fh;
	aes_control[0] = 73;
	aes_control[1] = 8;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}
	
	
int graf_handle(int *Wchar, int *Hchar, int *Wbox, int *Hbox)
{
	aes_control[0] = 77;
	aes_control[1] = 0;
	aes_control[2] = 5;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	*Wchar = aes_intout[1];
	*Hchar = aes_intout[2];
	*Wbox  = aes_intout[3];
	*Hbox  = aes_intout[4];
	return aes_intout[0];
}
	
	
int graf_mbox(int Sw, int Sh, int Sx, int Sy, int Dx, int Dy)
{
	aes_intin[0] = Sw;
	aes_intin[1] = Sh;
	aes_intin[2] = Sx;
	aes_intin[3] = Sy;
	aes_intin[4] = Dx;
	aes_intin[5] = Dy;
	aes_control[0] = 72;
	aes_control[1] = 6;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}
	
	
int graf_mkstate(int *Mx, int *My, int *ButtonState, int *KeyState)
{
	aes_control[0] = 79;
	aes_control[1] = 0;
	aes_control[2] = 5;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	*Mx = aes_intout[1];
	*My = aes_intout[2];
	*ButtonState = aes_intout[3];
	*KeyState = aes_intout[4];
	return aes_intout[0];
}
	
	
int graf_mouse(int Form, void *FormAddress)
{
	aes_intin[0]  = Form;
	aes_addrin[0] = (long)FormAddress;
	aes_control[0] = 78;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}
	
	
int graf_rubbbox(int Ix,  int Iy, int Iw, int Ih, int *Fw, int *Fh)
{
	aes_intin[0] = Ix;
	aes_intin[1] = Iy;
	aes_intin[2] = Iw;
	aes_intin[3] = Ih;
	aes_control[0] = 70;
	aes_control[1] = 4;
	aes_control[2] = 3;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	*Fw = aes_intout[1];
	*Fh = aes_intout[2];
	return aes_intout[0];
}
	
	
int graf_shrinkbox(int Fx, int Fy, int Fw, int Fh, int Sx, int Sy, int Sw, int Sh)
{
	aes_intin[0] = Fx;
	aes_intin[1] = Fy;
	aes_intin[2] = Fw;
	aes_intin[3] = Fh;
	aes_intin[4] = Sx;
	aes_intin[5] = Sy;
	aes_intin[6] = Sw;
	aes_intin[7] = Sh;
	aes_control[0] = 74;
	aes_control[1] = 8;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}
	
	
int graf_slidebox(void *Tree, int Parent, int Object, int Direction)
{
	aes_addrin[0] = (long)Tree;
	aes_intin[0]  = Parent;
	aes_intin[1]  = Object;
	aes_intin[2]  = Direction;
	aes_control[0] = 76;
	aes_control[1] = 3;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}
	
	
int graf_watchbox(void *Tree, int Object, int InState, int OutState)
{
	aes_addrin[0] = (long)Tree;
	aes_intin[0]  = 0;
	aes_intin[1]  = Object;
	aes_intin[2]  = InState;
	aes_intin[3]  = OutState;
	aes_control[0] = 75;
	aes_control[1] = 4;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

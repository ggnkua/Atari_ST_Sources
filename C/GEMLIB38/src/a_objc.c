/*
 * Aes object library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cg -- d2cg@dtek.chalmers.se
 * modified: cf -- felsch@tu-harburg.de
 */
#include "gem.h"


int objc_add(void *Tree, int Parent, int Child)
{
	aes_intin[0] = Parent;
	aes_intin[1] = Child;
	aes_addrin[0] = (long)Tree;
   aes_control[0] = 40;
   aes_control[1] = 2;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int objc_change(void *Tree, int Object, int Res, int Cx, int Cy, int Cw, int Ch,  int NewState, int Redraw)
{
	aes_intin[0] = Object;
	aes_intin[1] = Res;
	aes_intin[2] = Cx;
	aes_intin[3] = Cy;
	aes_intin[4] = Cw;
	aes_intin[5] = Ch;
	aes_intin[6] = NewState;
	aes_intin[7] = Redraw;
	aes_addrin[0] = (long)Tree;
   aes_control[0] = 47;
   aes_control[1] = 8;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int objc_delete(void *Tree, int Object)
{
	aes_addrin[0] = (long)Tree;
	aes_intin[0]  = Object;
   aes_control[0] = 41;
   aes_control[1] = 1;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int objc_draw(void *Tree, int Start, int Depth, int Cx, int Cy, int Cw, int Ch)
{
	aes_intin[0] = Start;
	aes_intin[1] = Depth;
	aes_intin[2] = Cx;
	aes_intin[3] = Cy;
	aes_intin[4] = Cw;
	aes_intin[5] = Ch;
	aes_addrin[0] = (long)Tree;
   aes_control[0] = 42;
   aes_control[1] = 6;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int objc_edit(void *Tree, int Object, int Char, int *Index, int Kind)
{
	aes_intin[0] = Object;
	aes_intin[1] = Char;
	aes_intin[2] = *Index;
	aes_intin[3] = Kind;
	aes_addrin[0] = (long)Tree;
   aes_control[0] = 46;
   aes_control[1] = 4;
   aes_control[2] = 2;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	*Index = aes_intout[1];
	return aes_intout[0];
}


int objc_find(void *Tree, int Start, int Depth, int Mx, int My)
{
	aes_intin[0] = Start;
	aes_intin[1] = Depth;
	aes_intin[2] = Mx;
	aes_intin[3] = My;
	aes_addrin[0] = (long)Tree;
   aes_control[0] = 43;
   aes_control[1] = 4;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int objc_offset(void *Tree, int Object, int  *X, int *Y)
{
	aes_addrin[0] = (long)Tree;
	aes_intin[0] = Object;
   aes_control[0] = 44;
   aes_control[1] = 1;
   aes_control[2] = 3;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	*X = aes_intout[1];
	*Y = aes_intout[2];
	return aes_intout[0];
}


int objc_order(void *Tree, int Object, int NewPos)
{
	aes_intin[0] = Object;
	aes_intin[1] = NewPos;
	aes_addrin[0] = (long)Tree;
   aes_control[0] = 45;
   aes_control[1] = 2;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int objc_sysvar(int mode, int which, int in1, int in2, int *out1, int *out2)
{
	aes_intin[0] = mode;
	aes_intin[1] = which;
	aes_intin[2] = in1;
	aes_intin[3] = in2;
   aes_control[0] = 48;
   aes_control[1] = 4;
   aes_control[2] = 3;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
   *out1 = aes_intout[1];
   *out2 = aes_intout[2];
   return aes_intout[0];
}

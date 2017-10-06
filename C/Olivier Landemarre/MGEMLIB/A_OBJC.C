/*
 * Aes object library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cg -- d2cg@dtek.chalmers.se
 * modified: cf -- felsch@tu-harburg.de
 * modified: ol -- olivier.landemarre.free.f
 */
#include "mgem.h"


int mt_objc_add(void *Tree, int Parent, int Child, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={40,2,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = Parent;
	aes_intin[1] = Child;
	aes_addrin[0] = (long)Tree;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef objc_add
#undef objc_add
#endif
int objc_add(void *Tree, int Parent, int Child)
{
	return(mt_objc_add(Tree,Parent,Child,aes_global));
}


int mt_objc_change(void *Tree, int Object, int Res, int Cx, int Cy, int Cw, int Ch,  int NewState, int Redraw, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={47,8,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = Object;
	aes_intin[1] = Res;
	aes_intin[2] = Cx;
	aes_intin[3] = Cy;
	aes_intin[4] = Cw;
	aes_intin[5] = Ch;
	aes_intin[6] = NewState;
	aes_intin[7] = Redraw;
	aes_addrin[0] = (long)Tree;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef objc_change
#undef objc_change
#endif
int objc_change(void *Tree, int Object, int Res, int Cx, int Cy, int Cw, int Ch,  int NewState, int Redraw)
{
	return(mt_objc_change(Tree, Object, Res, Cx, Cy, Cw, Ch, NewState, Redraw, aes_global));
}


int mt_objc_delete(void *Tree, int Object, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={41,1,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_addrin[0] = (long)Tree;
	aes_intin[0]  = Object;

	aes(&aes_params);
	return aes_intout[0];
}

#ifdef objc_delete
#undef objc_delete
#endif
int objc_delete(void *Tree, int Object)
{
	return(mt_objc_delete(Tree, Object,aes_global));
}


int mt_objc_draw(void *Tree, int Start, int Depth, int Cx, int Cy, int Cw, int Ch, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={42,6,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = Start;
	aes_intin[1] = Depth;
	aes_intin[2] = Cx;
	aes_intin[3] = Cy;
	aes_intin[4] = Cw;
	aes_intin[5] = Ch;
	aes_addrin[0] = (long)Tree;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef objc_draw
#undef objc_draw
#endif
int objc_draw(void *Tree, int Start, int Depth, int Cx, int Cy, int Cw, int Ch)
{
	return(mt_objc_draw(Tree, Start, Depth, Cx, Cy, Cw, Ch, aes_global));
}


int mt_objc_edit(void *Tree, int Object, int Char, INT16 *Index, int Kind, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={46,4,2,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = Object;
	aes_intin[1] = Char;
	aes_intin[2] = *Index;
	aes_intin[3] = Kind;
	aes_addrin[0] = (long)Tree;

	aes(&aes_params);

	*Index = aes_intout[1];
	return aes_intout[0];
}

#ifdef objc_edit
#undef objc_edit
#endif
int objc_edit(void *Tree, int Object, int Char, INT16 *Index, int Kind)
{
	return(mt_objc_edit(Tree, Object, Char, Index, Kind, aes_global));
}


int mt_objc_find(void *Tree, int Start, int Depth, int Mx, int My, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={43,4,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = Start;
	aes_intin[1] = Depth;
	aes_intin[2] = Mx;
	aes_intin[3] = My;
	aes_addrin[0] = (long)Tree;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef objc_find
#undef objc_find
#endif
int objc_find(void *Tree, int Start, int Depth, int Mx, int My)
{
	return(mt_objc_find(Tree, Start, Depth, Mx, My, aes_global));
}


int mt_objc_offset(void *Tree, int Object, INT16 *X, INT16 *Y, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={44,1,3,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */
                    
	aes_addrin[0] = (long)Tree;
	aes_intin[0] = Object;

	aes(&aes_params);

	*X = aes_intout[1];
	*Y = aes_intout[2];
	return aes_intout[0];
}

#ifdef objc_offset
#undef objc_offset
#endif
int objc_offset(void *Tree, int Object, INT16 *X, INT16 *Y)
{
	return(mt_objc_offset(Tree, Object, X, Y, aes_global));
}


int mt_objc_order(void *Tree, int Object, int NewPos, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={45,2,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = Object;
	aes_intin[1] = NewPos;
	aes_addrin[0] = (long)Tree;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef objc_order
#undef objc_order
#endif
int objc_order(void *Tree, int Object, int NewPos)
{
	return(mt_objc_order(Tree, Object, NewPos, aes_global));
}

int mt_objc_sysvar(int mode, int which, int in1, int in2, INT16 *out1, INT16 *out2, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={48,4,3,0,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = mode;
	aes_intin[1] = which;
	aes_intin[2] = in1;
	aes_intin[3] = in2;

	aes(&aes_params);

	*out1 = aes_intout[1];
	*out2 = aes_intout[2];
	return aes_intout[0];
}

#ifdef objc_sysvar
#undef objc_sysvar
#endif
int objc_sysvar(int mode, int which, int in1, int in2, INT16 *out1, INT16 *out2)
{
	return(mt_objc_sysvar(mode, which, in1, in2, out1, out2, aes_global));
}

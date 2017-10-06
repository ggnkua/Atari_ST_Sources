/*
 * Aes graphics library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch@tu-harburg.de
 * modified: ol -- olivier.landemarre.free.fr
 * modified: er -- ers@free.fr:
 *					little speed & size optimisations for mt_graf_handle (), mt_graf_mkstate (),
 *					mt_graf_mouse ();
 */
#include "mgem.h"


int mt_graf_dragbox(int Sw, int Sh, int Sx, int Sy, int Bx, int By, int Bw, int Bh, INT16 *Fw, INT16 *Fh, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={71,8,3,0,0};
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

	aes_intin[0] = Sw;
	aes_intin[1] = Sh;
	aes_intin[2] = Sx;
	aes_intin[3] = Sy;
	aes_intin[4] = Bx;
	aes_intin[5] = By;
	aes_intin[6] = Bw;
	aes_intin[7] = Bh;
	
	aes(&aes_params);

	*Fw = aes_intout[1];
	*Fh = aes_intout[2];
	return aes_intout[0];
}

#ifdef graf_dragbox
#undef graf_dragbox
#endif
int graf_dragbox(int Sw, int Sh, int Sx, int Sy, int Bx, int By, int Bw, int Bh, INT16 *Fw, INT16 *Fh)
{
	return(mt_graf_dragbox(Sw, Sh, Sx, Sy, Bx, By, Bw, Bh, Fw, Fh, aes_global));
}


int mt_graf_growbox(int Sx, int Sy, int Sw, int Sh, int Fx, int Fy, int Fw, int Fh, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={73,8,1,0,0};
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

                    
	aes_intin[0] = Sx;
	aes_intin[1] = Sy;
	aes_intin[2] = Sw;
	aes_intin[3] = Sh;
	aes_intin[4] = Fx;
	aes_intin[5] = Fy;
	aes_intin[6] = Fw;
	aes_intin[7] = Fh;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef graf_growbox
#undef graf_growbox
#endif
int graf_growbox(int Sx, int Sy, int Sw, int Sh, int Fx, int Fy, int Fw, int Fh)
{
	return(mt_graf_growbox( Sx, Sy, Sw, Sh, Fx, Fy, Fw, Fh, aes_global));
}


int mt_graf_handle (INT16 *Wchar, INT16 *Hchar, INT16 *Wbox, INT16 *Hbox, INT16 *global_aes)
{
	INT16 *ptr;
	static INT16 aes_control[AES_CTRLMAX]={77,0,5,0,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	aes (&aes_params);

	ptr = &aes_intout[1];
	*Wchar = *(ptr ++);									/* [1] */
	*Hchar = *(ptr ++);									/* [2] */
	*Wbox  = *(ptr ++);									/* [3] */
	*Hbox  = *(ptr);									/* [4] */

	return (aes_intout[0]);
}

#ifdef graf_handle
#undef graf_handle
#endif
int graf_handle(INT16 *Wchar, INT16 *Hchar, INT16 *Wbox, INT16 *Hbox)
{
	return(mt_graf_handle(Wchar, Hchar, Wbox, Hbox, aes_global));
}


int mt_graf_mbox(int Sw, int Sh, int Sx, int Sy, int Dx, int Dy, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={72,6,1,0,0};
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

	aes_intin[0] = Sw;
	aes_intin[1] = Sh;
	aes_intin[2] = Sx;
	aes_intin[3] = Sy;
	aes_intin[4] = Dx;
	aes_intin[5] = Dy;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef graf_mbox
#undef graf_mbox
#endif
int graf_mbox(int Sw, int Sh, int Sx, int Sy, int Dx, int Dy)
{
	return(mt_graf_mbox( Sw, Sh, Sx, Sy, Dx, Dy, aes_global));
}


int mt_graf_mkstate (INT16 *Mx, INT16 *My, INT16 *ButtonState, INT16 *KeyState, INT16 *global_aes)
{
	INT16 *ptr;
	static INT16 aes_control[AES_CTRLMAX]={79,0,5,0,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	aes (&aes_params);

	ptr = &aes_intout[1];
	*Mx = *(ptr ++);									/* [1] */
	*My = *(ptr ++);									/* [2] */
	*ButtonState = *(ptr ++);							/* [3] */
	*KeyState = *(ptr);									/* [4] */

	return (aes_intout[0]);
}

#ifdef graf_mkstate
#undef graf_mkstate
#endif
int graf_mkstate(INT16 *Mx, INT16 *My, INT16 *ButtonState, INT16 *KeyState)
{
	return(mt_graf_mkstate(Mx, My, ButtonState, KeyState, aes_global));
}

	
int mt_graf_mouse (int Form, void *FormAddress, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={78,1,1,1,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	aes_intin[0] = Form;

	aes_addrin[0] = (long)FormAddress;

	aes (&aes_params);

	return (aes_intout[0]);
}

#ifdef graf_mouse
#undef graf_mouse
#endif
int graf_mouse(int Form, void *FormAddress)
{
	return(mt_graf_mouse( Form, FormAddress, aes_global));
}
	
int mt_graf_rubberbox(int Ix,  int Iy, int Iw, int Ih, INT16 *Fw, INT16 *Fh, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={70,4,3,0,0};
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

	aes_intin[0] = Ix;
	aes_intin[1] = Iy;
	aes_intin[2] = Iw;
	aes_intin[3] = Ih;

	aes(&aes_params);

	*Fw = aes_intout[1];
	*Fh = aes_intout[2];
	return aes_intout[0];
}

#ifdef graf_rubberbox
#undef graf_rubberbox
#endif
int graf_rubberbox(int Ix,  int Iy, int Iw, int Ih, INT16 *Fw, INT16 *Fh)
{
	return(mt_graf_rubberbox( Ix,  Iy, Iw, Ih, Fw, Fh, aes_global));
}
	
int mt_graf_shrinkbox(int Fx, int Fy, int Fw, int Fh, int Sx, int Sy, int Sw, int Sh, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={74,8,1,0,0};
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

	aes_intin[0] = Fx;
	aes_intin[1] = Fy;
	aes_intin[2] = Fw;
	aes_intin[3] = Fh;
	aes_intin[4] = Sx;
	aes_intin[5] = Sy;
	aes_intin[6] = Sw;
	aes_intin[7] = Sh;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef graf_shrinkbox
#undef graf_shrinkbox
#endif
int graf_shrinkbox(int Fx, int Fy, int Fw, int Fh, int Sx, int Sy, int Sw, int Sh)
{
	return(mt_graf_shrinkbox( Fx, Fy, Fw, Fh, Sx, Sy, Sw, Sh, aes_global));
}
	
int mt_graf_slidebox(void *Tree, int Parent, int Object, int Direction, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={76,3,1,1,0};
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
	aes_intin[0]  = Parent;
	aes_intin[1]  = Object;
	aes_intin[2]  = Direction;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef graf_slidebox
#undef graf_slidebox
#endif
int graf_slidebox(void *Tree, int Parent, int Object, int Direction)
{
	return(mt_graf_slidebox(Tree, Parent, Object, Direction, aes_global));
}

	
int mt_graf_watchbox(void *Tree, int Object, int InState, int OutState, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={75,4,1,1,0};
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
	aes_intin[0]  = 0;
	aes_intin[1]  = Object;
	aes_intin[2]  = InState;
	aes_intin[3]  = OutState;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef graf_watchbox
#undef graf_watchbox
#endif
int graf_watchbox(void *Tree, int Object, int InState, int OutState)
{
	return(mt_graf_watchbox(Tree, Object, InState, OutState, aes_global));
}

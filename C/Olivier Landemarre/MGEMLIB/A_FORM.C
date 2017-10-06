/*
 * Aes forms library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cg -- d2cg@dtek.chalmers.se
 * modified: cf -- felsch@tu-harburg.de
 * modified: ol -- olivier.landemarre.free.fr
 */
#include "mgem.h"


int mt_form_alert(int DefButton, char *Str, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={52,1,1,1,0};
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

                    
	aes_intin[0] = DefButton;
	aes_addrin[0] = (long)Str;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef form_alert
#undef form_alert
#endif
int form_alert(int DefButton, char *Str)
{
	return (mt_form_alert(DefButton,Str, aes_global));
}

int mt_form_button(void *Btree, int Bobject, int Bclicks, INT16 *Bnxtobj, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={56,2,2,1,0};
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

                    
	aes_addrin[0] = (long)Btree;
	aes_intin[0] = Bobject;
	aes_intin[1] = Bclicks;

	aes(&aes_params);

	*Bnxtobj = aes_intout[1];
	return aes_intout[0];
}


#ifdef form_button
#undef form_button
#endif
int form_button(void *Btree, int Bobject, int Bclicks, INT16 *Bnxtobj)
{
	return(mt_form_button(Btree, Bobject, Bclicks, Bnxtobj, aes_global));
}


int mt_form_center(void *Tree, INT16 *Cx, INT16 *Cy, INT16 *Cw, INT16 *Ch, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={54,0,5,1,0};
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

	aes(&aes_params);

	*Cx = aes_intout[1];
	*Cy = aes_intout[2];
	*Cw = aes_intout[3];
	*Ch = aes_intout[4];
 	return aes_intout[0];
}

#ifdef form_center
#undef form_center
#endif
int form_center(void *Tree, INT16 *Cx, INT16 *Cy, INT16 *Cw, INT16 *Ch)
{
	return(mt_form_center(Tree, Cx, Cy, Cw, Ch, aes_global));
}


int mt_form_dial(int Flag,	int Sx, int Sy, int Sw, int Sh, int Bx, int By, int Bw, int Bh, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={51,9,1,0,0};
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

                    
	aes_intin[0] = Flag;
	aes_intin[1] = Sx;
	aes_intin[2] = Sy;
	aes_intin[3] = Sw;
	aes_intin[4] = Sh;
	aes_intin[5] = Bx;
	aes_intin[6] = By;
	aes_intin[7] = Bw;
	aes_intin[8] = Bh;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef form_dial
#undef form_dial
#endif
int form_dial(int Flag,	int Sx, int Sy, int Sw, int Sh, int Bx, int By, int Bw, int Bh)
{
	return(mt_form_dial( Flag, Sx, Sy, Sw, Sh, Bx, By, Bw, Bh, aes_global));
}


int mt_form_do(void *Tree, int StartObj, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={50,1,1,1,0};
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

                    
	aes_intin[0] = StartObj;
	aes_addrin[0] = (long)Tree;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef form_do
#undef form_do
#endif
int form_do(void *Tree, int StartObj)
{
	return(mt_form_do(Tree, StartObj, aes_global));
}


int mt_form_error(int ErrorCode, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={53,1,1,0,0};
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
                    
	aes_intin[0] = ErrorCode;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef form_error
#undef form_error
#endif
int form_error(int ErrorCode)
{
	return(mt_form_error(ErrorCode, aes_global));
}


int mt_form_keybd(void *Ktree, int Kobject, int Kobnext, int Kchar, INT16 *Knxtobject, INT16 *Knxtchar, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={55,3,3,1,0};
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

                    
	aes_addrin[0] =(long) Ktree;
	aes_intin[0] = Kobject;
	aes_intin[1] = Kchar;
	aes_intin[2] = Kobnext;

	aes(&aes_params);

	*Knxtobject = aes_intout[1];
	*Knxtchar = aes_intout[2];
	return aes_intout[0];
}

#ifdef form_keybd
#undef form_keybd
#endif
int form_keybd(void *Ktree, int Kobject, int Kobnext, int Kchar, INT16 *Knxtobject, INT16 *Knxtchar)
{
	return(mt_form_keybd(Ktree, Kobject, Kobnext, Kchar, Knxtobject, Knxtchar,aes_global));
}

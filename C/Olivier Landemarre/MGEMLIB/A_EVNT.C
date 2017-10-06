/*
 * Aes event library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch.tu-harburg.de
 * modified: ol -- olivier.landemarre.free.fr
 * modified: er -- ers@free.fr
 */

#include "mgem.h"


int mt_evnt_button(int Clicks, int WhichButton, int WhichState, INT16 *Mx, INT16 *My, INT16 *ButtonState, INT16 *KeyState, INT16 *global_aes)
{	
	static INT16 	aes_control[AES_CTRLMAX]={21,3,5,0,0};
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

 
	aes_intin[0] = Clicks;
	aes_intin[1] = WhichButton;
	aes_intin[2] = WhichState;

	aes(&aes_params);

	*Mx = aes_intout[1];
	*My = aes_intout[2];
	*ButtonState = aes_intout[3];
	*KeyState = aes_intout[4];
	return aes_intout[0];
}

#ifdef evnt_button
#undef evnt_button
#endif
int evnt_button(int Clicks, int WhichButton, int WhichState, INT16 *Mx, INT16 *My, INT16 *ButtonState, INT16 *KeyState)
{
	return(mt_evnt_button(Clicks, WhichButton, WhichState, Mx, My, ButtonState, KeyState, aes_global));
}


int mt_evnt_dclick(int ToSet, int SetGet, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={26,2,1,0,0};
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
                    
	aes_intin[0] = ToSet;
	aes_intin[1] = SetGet;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef evnt_dclick
#undef evnt_dclick
#endif
int evnt_dclick(int ToSet, int SetGet)
{
	return(mt_evnt_dclick(ToSet, SetGet, aes_global));
}


int mt_evnt_keybd(INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={20,0,1,0,0};
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

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef evnt_keybd
#undef evnt_keybd
#endif
int evnt_keybd(void)
{
	return(mt_evnt_keybd(aes_global));
}


int mt_evnt_mesag (INT16 MesagBuf[], INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={23,0,1,1,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	aes_addrin[0] = (long)MesagBuf;

	aes (&aes_params);

	return (aes_intout[0]);
}


#ifdef evnt_mesag
#undef evnt_mesag
#endif
int evnt_mesag(INT16 MesagBuf[])
{
	return(mt_evnt_mesag(MesagBuf, aes_global));
}


int mt_evnt_mouse(int EnterExit, int InX, int InY, int InW, int InH,
			 		INT16 *OutX, INT16 *OutY, INT16 *ButtonState, INT16 *KeyState, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={22,5,5,0,0};
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

                    
	aes_intin[0] = EnterExit;
	aes_intin[1] = InX;
	aes_intin[2] = InY;
	aes_intin[3] = InW;
	aes_intin[4] = InH;

	aes(&aes_params);

	*OutX = aes_intout[1];
	*OutY = aes_intout[2];
	*ButtonState = aes_intout[3];
	*KeyState = aes_intout[4];
	return aes_intout[0];
}

#ifdef evnt_mouse
#undef evnt_mouse
#endif
int evnt_mouse(int EnterExit, int InX, int InY, int InW, int InH,
			 		INT16 *OutX, INT16 *OutY, INT16 *ButtonState, INT16 *KeyState)
{
	return(mt_evnt_mouse(EnterExit, InX, InY, InW, InH,OutX, OutY, ButtonState, KeyState, aes_global));
}


int mt_evnt_multi (int Type, int Clicks, int WhichButton, int WhichState, int EnterExit1, int In1X, int In1Y, int In1W,
 int In1H, int EnterExit2, int In2X, int In2Y, int In2W, int In2H, INT16 MesagBuf[], unsigned long Interval, INT16 *OutX,
  INT16 *OutY, INT16 *ButtonState, INT16 *KeyState, INT16 *Key, INT16 *ReturnCount, INT16 *global_aes)
{
	INT16 *ptr;
	unsigned INT16 *i = (unsigned INT16 *)&Interval;
	static INT16 aes_control[AES_CTRLMAX]={25,16,7,1,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	ptr = aes_intin;
	*(ptr ++) = Type;									/* [0] */
	*(ptr ++) = Clicks;
	*(ptr ++) = WhichButton;
	*(ptr ++) = WhichState;
	*(ptr ++) = EnterExit1;
	*(ptr ++) = In1X;
	*(ptr ++) = In1Y;
	*(ptr ++) = In1W;
	*(ptr ++) = In1H;
	*(ptr ++) = EnterExit2;
	*(ptr ++) = In2X;
	*(ptr ++) = In2Y;
	*(ptr ++) = In2W;
	*(ptr ++) = In2H;
	*(ptr ++) = i[1];
	*(ptr) = i[0];										/* [15] */

	aes_addrin[0] = (long)MesagBuf;

	aes(&aes_params);

	ptr = &aes_intout[1];
	*OutX = *(ptr ++);									/* [1] */
	*OutY = *(ptr ++);									/* [2] */
	*ButtonState = *(ptr ++);							/* [3] */
	*KeyState = *(ptr ++);								/* [4] */
	*Key = *(ptr ++);									/* [5] */
	*ReturnCount = *(ptr);								/* [6] */

	return (aes_intout[0]);
}


#ifdef evnt_multi
#undef evnt_multi
#endif
int evnt_multi(int Type, int Clicks, int WhichButton, int WhichState,
			 int EnterExit1, int In1X, int In1Y, int In1W, int In1H,
			 int EnterExit2, int In2X, int In2Y, int In2W, int In2H,
			 INT16 MesagBuf[], unsigned long Interval,
			 INT16 *OutX, INT16 *OutY, INT16 *ButtonState, INT16 *KeyState, INT16 *Key,
			 INT16 *ReturnCount)
{
	return(mt_evnt_multi(Type, Clicks, WhichButton, WhichState, EnterExit1, In1X, In1Y, In1W, In1H, EnterExit2, In2X, In2Y, In2W, In2H, MesagBuf, Interval, OutX, OutY, ButtonState, KeyState, Key, ReturnCount, aes_global));
}


int mt_evnt_timer (unsigned long Interval, INT16 *global_aes)
{
	unsigned INT16 *i = (unsigned INT16 *)&Interval;
	static INT16 aes_control[AES_CTRLMAX]={24,2,1,0,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	aes_intin[0] = i[1];
	aes_intin[1] = i[0];

	aes (&aes_params);

	return (aes_intout[0]);
}

#ifdef evnt_timer
#undef evnt_timer
#endif
int evnt_timer(unsigned long Interval)
{
	return(mt_evnt_timer(Interval, aes_global));
}

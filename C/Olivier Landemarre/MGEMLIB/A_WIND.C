/*
 * Aes window library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch@tu-harburg.de
 * modified: ol -- olivier.landemarre@utbm.fr
 * modified: er -- ers@free.fr
 *
 */

#include "mgem.h"


int mt_wind_calc (int Type, int Parts, int InX,  int InY, int InW, int InH, INT16 *OutX, INT16 *OutY, INT16 *OutW,
 INT16 *OutH, INT16 *global_aes)
{
	INT16 *ptr;
	static INT16 aes_control[AES_CTRLMAX]={108,6,5,0,0};
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
	*(ptr ++) = Parts;									/* [1] */
	*(ptr ++) = InX;									/* [2] */
	*(ptr ++) = InY;									/* [3] */
	*(ptr ++) = InW;									/* [4] */
	*(ptr) = InH;										/* [5] */
	
	aes (&aes_params);

	ptr = &aes_intout[1];
	*OutX = *(ptr ++);									/* [1] */
	*OutY = *(ptr ++);									/* [2] */
	*OutW = *(ptr ++);									/* [3] */
	*OutH = *(ptr);										/* [4] */

	return (aes_intout[0]);
}


#ifdef wind_calc
#undef wind_calc
#endif
int wind_calc(int Type, int Parts, int InX,  int InY, int InW, int InH, INT16 *OutX, INT16 *OutY, INT16 *OutW, INT16 *OutH)
{
	return(mt_wind_calc( Type, Parts, InX, InY, InW, InH, OutX, OutY, OutW, OutH, aes_global));
}


int mt_wind_close (int WindowHandle, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={102,1,1,0,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	aes_intin[0] = WindowHandle;

	aes (&aes_params);

	return (aes_intout[0]);
}

#ifdef wind_close
#undef wind_close
#endif
int wind_close(int WindowHandle)
{
	return(mt_wind_close(WindowHandle, aes_global));
}


int mt_wind_create (int Parts, int Wx, int Wy, int Ww, int Wh, INT16 *global_aes)
{
	INT16 *ptr;
	static INT16 aes_control[AES_CTRLMAX]={100,5,1,0,0};
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
	*(ptr ++) = Parts;									/* [0] */
	*(ptr ++) = Wx;										/* [1] */
	*(ptr ++) = Wy;										/* [2] */
	*(ptr ++) = Ww;										/* [3] */
	*(ptr) = Wh;										/* [4] */

	aes (&aes_params);

	return (aes_intout[0]);
}

#ifdef wind_create
#undef wind_create
#endif
int wind_create(int Parts, int Wx, int Wy, int Ww, int Wh)
{
	return(mt_wind_create(Parts, Wx, Wy, Ww, Wh, aes_global));
}


int mt_wind_delete (int WindowHandle, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={103,1,1,0,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	aes_intin[0] = WindowHandle;

	aes (&aes_params);

	return (aes_intout[0]);
}

#ifdef wind_delete
#undef wind_delete
#endif
int wind_delete(int WindowHandle)
{
	return(mt_wind_delete(WindowHandle, aes_global));
}


int mt_wind_find (int X, int Y, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={106,2,1,0,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array  */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */
                    
	aes_intin[0] = X;
	aes_intin[1] = Y;

	aes (&aes_params);

	return (aes_intout[0]);
}


#ifdef wind_find
#undef wind_find
#endif
int wind_find(int X, int Y)
{
	return(mt_wind_find( X, Y, aes_global));
}


int mt_wind_get (int WindowHandle, int What, INT16 *W1, INT16 *W2, INT16 *W3, INT16 *W4, INT16 *global_aes)
{
	INT16 *ptr;
	INT16 aes_control[AES_CTRLMAX], aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	aes_intin[0] = WindowHandle;
	aes_intin[1] = What;

	ptr = aes_control;
	*(ptr ++) = 104;									/* [0] */

	if (What == WF_DCOLOR || What == WF_COLOR)
	{
		aes_intin[2] = *W1;
		*(ptr ++) = 3;									/* [1] */
	}
	else
		*(ptr ++) = 2;									/* [1] */

	*(ptr ++) = 5;										/* [2] */
	*(ptr ++) = *(ptr ++) = 0;							/* [3,4] */

		/* ol: this line is required for WF_FIRSTXYWH and WF_NEXTXYWH because lot of programmers doesn't verify the return value and espect W or H will be 0 it's not true for NAES */
	aes_intout[3] = aes_intout[4] = 0;

	aes (&aes_params);

	ptr = &aes_intout[1];
	*W1 = *(ptr ++);									/* [1] */
	*W2 = *(ptr ++);									/* [2] */
	*W3 = *(ptr ++);									/* [3] */
	*W4 = *(ptr);										/* [4] */

	return (aes_intout[0]);
}


#ifdef wind_get
#undef wind_get
#endif
int wind_get(int WindowHandle, int What, INT16 *W1, INT16 *W2, INT16 *W3, INT16 *W4)
{
	return(mt_wind_get(WindowHandle, What, W1, W2, W3, W4, aes_global));
}


int mt_wind_new (INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={109,0,0,0,0};
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

	return (1);
}	

#ifdef wind_new
#undef wind_new
#endif
int wind_new()
{
	return(mt_wind_new(aes_global));
}


int mt_wind_open (int WindowHandle, int Wx, int Wy, int Ww, int Wh, INT16 *global_aes)
{
	INT16 *ptr;
	static INT16 aes_control[AES_CTRLMAX]={101,5,1,0,0};
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
	*(ptr ++) = WindowHandle;							/* [0] */
	*(ptr ++) = Wx;										/* [1] */
	*(ptr ++) = Wy;										/* [2] */
	*(ptr ++) = Ww;										/* [3] */
	*(ptr) = Wh;										/* [4] */

	aes (&aes_params);

	return (aes_intout[0]);
}

#ifdef wind_open
#undef wind_open
#endif
int wind_open(int WindowHandle, int Wx, int Wy, int Ww, int Wh)
{
	return(mt_wind_open(WindowHandle, Wx, Wy, Ww, Wh, aes_global));
}


int mt_wind_set (int WindowHandle, int What, int W1, int W2, int W3, int W4, INT16 *global_aes)
{
	INT16 *ptr;
	static INT16 aes_control[AES_CTRLMAX]={105,6,1,0,0};
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
	*(ptr ++) = WindowHandle;							/* aes_intin[0] */
	*(ptr ++) = What;									/* aes_intin[1] */

#ifdef __PUREC__
#pragma warn -rch
#endif
	if (sizeof (int) == 2)								/* entiers 16 bits simple */
	{
		*(ptr ++) = W1;									/* aes_intin[2] */
		*(ptr ++) = W2;									/* aes_intin[3] */
		*(ptr ++) = W3;									/* aes_intin[4] */
		*(ptr ++) = W4;									/* aes_intin[5] */
	}
	else												/* entiers 32 bits */
	{
			/* for 32 bit ints stuff the address into aes_intin[2] and [3] */
		switch (What)
		{
			case WF_NAME: 
			case WF_INFO: 
			case WF_NEWDESK:
			{ 
				unsigned INT16 *s = (unsigned INT16 *)&W1;
				*(ptr ++) = s[0];						/* aes_intin[2] */
				*(ptr ++) = s[1];						/* aes_intin[3] */
				if (What == WF_NEWDESK)
					*(ptr ++) = W2;						/* aes_intin[4] */
			}
			break;
			default:
				*(ptr ++) = W1;							/* aes_intin[2] */
				*(ptr ++) = W2;							/* aes_intin[3] */
				*(ptr ++) = W3;							/* aes_intin[4] */
				*(ptr ++) = W4;							/* aes_intin[5] */
		}
	}
#ifdef __PUREC__
#pragma warn .rch
#endif
               
	aes (&aes_params);

	return (aes_intout[0]);
}

#ifdef wind_set
#undef wind_set
#endif
int wind_set(int WindowHandle, int What, int W1, int W2, int W3, int W4)
{
	return(mt_wind_set( WindowHandle, What, W1, W2, W3, W4, aes_global));
}


int mt_wind_update (int Code, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={107,1,1,0,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	aes_intin[0] = Code;

	aes (&aes_params);

	return (aes_intout[0]);
}

#ifdef wind_update
#undef wind_update
#endif
int wind_update(int Code)
{
	return(mt_wind_update(Code, aes_global));
}

/*
 * Some usefull extensions.
*/
int mt_wind_calc_grect(int Type, int Parts, GRECT *In, GRECT *Out, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={108,6,5,0,0};
	INT16		aes_intin[AES_INTINMAX],
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

                    
	aes_intin[0] = Type;
	aes_intin[1] = Parts;
	aes_intin[2] = In->g_x;
	aes_intin[3] = In->g_y;
	aes_intin[4] = In->g_w;
	aes_intin[5] = In->g_h;

	aes(&aes_params);

	Out->g_x = aes_intout[1];
	Out->g_y = aes_intout[2];
	Out->g_w = aes_intout[3];
	Out->g_h = aes_intout[4];
	return aes_intout[0];
}

#ifdef wind_calc_grect
#undef wind_calc_grect
#endif
int wind_calc_grect(int Type, int Parts, GRECT *In, GRECT *Out)
{
	return(mt_wind_calc_grect(Type, Parts, In, Out, aes_global));
}

int mt_wind_create_grect(int Parts, GRECT *r, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={100,5,1,0,0};
	INT16		aes_intin[AES_INTINMAX],
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

                    
	aes_intin[0] = Parts;
	aes_intin[1] = r->g_x;
	aes_intin[2] = r->g_y;
	aes_intin[3] = r->g_w;
	aes_intin[4] = r->g_h;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef wind_create_grect
#undef wind_create_grect
#endif
int wind_create_grect(int Parts, GRECT *r)
{
	return(mt_wind_create_grect( Parts, r, aes_global));
}

int mt_wind_get_grect(int WindowHandle, int What, GRECT *r, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={104,2,5,0,0};
	INT16		aes_intin[AES_INTINMAX],
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

                    
	aes_intin[0] = WindowHandle;
	aes_intin[1] = What;
	
	aes(&aes_params);

	r->g_x = aes_intout[1];
	r->g_y = aes_intout[2];
	r->g_w = aes_intout[3];
	r->g_h = aes_intout[4];
	return (aes_intout[0]);
}

#ifdef wind_get_grect
#undef wind_get_grect
#endif
int wind_get_grect(int WindowHandle, int What, GRECT *r)
{
	return(mt_wind_get_grect(WindowHandle, What, r, aes_global));
}


int mt_wind_open_grect(int WindowHandle, GRECT *r, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={101,5,1,0,0};
	INT16		aes_intin[AES_INTINMAX],
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

                    
	aes_intin[0] = WindowHandle;
	aes_intin[1] = r->g_x;
	aes_intin[2] = r->g_y;
	aes_intin[3] = r->g_w;
	aes_intin[4] = r->g_h;
	
	aes(&aes_params);

	return aes_intout[0];
}

#ifdef wind_open_grect
#undef wind_open_grect
#endif
int wind_open_grect(int WindowHandle, GRECT *r)
{
	return(mt_wind_open_grect(WindowHandle, r, aes_global));
}

int mt_wind_set_grect(int WindowHandle, int What, GRECT *r, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={105,6,1,0,0};
	INT16		aes_intin[AES_INTINMAX],
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

                    
	aes_intin[0] = WindowHandle;
	aes_intin[1] = What;
	aes_intin[2] = r->g_x;
	aes_intin[3] = r->g_y;
	aes_intin[4] = r->g_w;
	aes_intin[5] = r->g_h;
	
	aes(&aes_params);
	
	return (aes_intout[0]);

}

#ifdef wind_set_grect
#undef wind_set_grect
#endif
int wind_set_grect(int WindowHandle, int What, GRECT *r)
{
	return(mt_wind_set_grect(WindowHandle, What, r, aes_global));
}


int mt_wind_set_str (int WindowHandle, int What, char *str, INT16 *global_aes)
{
	unsigned INT16 *s = (unsigned INT16 *)&str;
	INT16 *ptr;
	static INT16 aes_control[AES_CTRLMAX]={105,6,1,0,0};
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
	*(ptr ++) = WindowHandle;							/* [0] */
	*(ptr ++) = What;									/* [1] */
	*(ptr ++) = s[0];									/* [2] */
	*(ptr) = s[1];										/* [3] */

	aes (&aes_params);

	return (aes_intout[0]);
}

#ifdef wind_set_str
#undef wind_set_str
#endif
int wind_set_str(int WindowHandle, int What, char *str)
{
	return(mt_wind_set_str(WindowHandle, What, str, aes_global));
}

/*
	XaAES Extended Call Interface Library
*/

#include "XAAESLIB.H"

static short global[15];
static short intin[300];
static short intout[300];
static void *addrin[300];
static void *addrout[300];

AESPB pb={NULL,global,intin,intout,addrin,addrout};

const short CT_evnt_multi[]={25,16,7,1,0};

/*
	Non-blocking evnt_multi call.
*/
short XAevnt_multi(short events, short bclicks, short bmask, short bstate,
					short m1flag, short m1x, short m1y, short m1w, short m1h, 
					short m2flag, short m2x, short m2y, short m2w, short m2h, 
					short *msg, short lo_count, short hi_count, short *mx, short *my, 
					short *ks, short *kc, short *mc)
{
	pb.contrl=CT_evnt_multi;
/*	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;*/
	intin[0]=events;
	intin[1]=bclicks;
	intin[2]=bmask;
	intin[3]=bstate;
	intin[4]=m1flag;
	intin[5]=m1x;
	intin[6]=m1y;
	intin[7]=m1w;
	intin[8]=m1h;
	intin[9]=m2flag;
	intin[10]=m2x;
	intin[11]=m2y;
	intin[12]=m2w;
	intin[13]=m2h;
	intin[14]=lo_count;
	intin[15]=hi_count;
	
	addrin[0]=msg;
	
	call_aes(AESCMD_NOBLOCK,&pb);
	
	return 0;
}

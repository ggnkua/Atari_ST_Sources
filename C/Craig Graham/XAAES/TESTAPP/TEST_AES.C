#include "TEST_AES.H"
#include "../KERNAL.H"
#include "../K_DEFS.H"

AESPB pb;
short intin[300];
short intout[300];
void *addrin[300];
void *addrout[300];

short Pappl_init[]={10,0,1,0,0};
short Pappl_exit[]={19,0,1,0,0};
short Pevnt_button[]={21,3,5,0,0};
short Pevnt_mesag[]={23,0,1,1,0};
short Pgraf_handle[]={77,0,5,0,0};
short Pgraf_mouse[]={78,1,1,1,0};
short Pgraf_mkstate[]={79,0,5,0,0};
short Pwind_create[]={100,5,1,0,0};
short Pwind_open[]={101,5,1,0,0};
short Pwind_close[]={102,1,1,0,0};
short Pwind_set[]={105,6,1,0,0};

short Tappl_init(void)
{
	pb.contrl=Pappl_init;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	call_aes(AESCMD_STD,&pb);
	
	return intout[0];
}

short Tappl_exit(void)
{
	pb.contrl=Pappl_exit;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	call_aes(AESCMD_STD,&pb);
	
	return intout[0];
}

short Twind_create(short kind,short x, short y, short w, short h)
{
	pb.contrl=Pwind_create;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	intin[0]=kind;
	intin[1]=x;
	intin[2]=y;
	intin[3]=w;
	intin[4]=h;

	call_aes(AESCMD_STD,&pb);
	
	return intout[0];
}

short Twind_set(short handle, short request, short x, short y, short w, short h)
{
	pb.contrl=Pwind_set;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	intin[0]=handle;
	intin[1]=request;
	intin[2]=x;
	intin[3]=y;
	intin[4]=w;
	intin[5]=h;

	call_aes(AESCMD_STD,&pb);
	
	return intout[0];
}

short Twind_open(short handle,short x, short y, short w, short h)
{
	pb.contrl=Pwind_open;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	intin[0]=handle;
	intin[1]=x;
	intin[2]=y;
	intin[3]=w;
	intin[4]=h;
	
	call_aes(AESCMD_STD,&pb);
	
	return intout[0];
}

short Twind_close(short handle)
{
	pb.contrl=Pwind_close;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	intin[0]=handle;
	
	call_aes(AESCMD_STD,&pb);
	
	return intout[0];
}

short Tevnt_button(short mc, short mask, short state, short *x, short *y, short *button, short *kstate)
{
	pb.contrl=Pevnt_button;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	intin[0]=mc;
	intin[1]=mask;
	intin[2]=state;
	
	call_aes(AESCMD_STD,&pb);
	
	*x=intout[1];
	*y=intout[2];
	*button=intout[3];
	*kstate=intout[4];
	
	return intout[0];
}

short Tevnt_mesag(short *msg)
{
	pb.contrl=Pevnt_mesag;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	addrin[0]=msg;
	
	call_aes(AESCMD_STD,&pb);
	
	return intout[0];
}

short Tgraf_mouse(short number, void *addr)
{
	pb.contrl=Pgraf_mouse;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	intin[0]=number;
	addrin[0]=addr;
	
	call_aes(AESCMD_STD,&pb);
	
	return intout[0];
}

short Tgraf_handle(short *wchar, short *hchar, short *wbox, short *hbox)
{
	pb.contrl=Pgraf_handle;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	call_aes(AESCMD_STD,&pb);
	
	*wchar=intout[1];
	*hchar=intout[2];
	*wbox=intout[3];
	*hbox=intout[4];

	return intout[0];
}

short Tgraf_mkstate(short *x, short *y, short *button, short *kstate)
{
	pb.contrl=Pgraf_mkstate;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	call_aes(AESCMD_STD,&pb);

	*x=intout[1];
	*y=intout[2];
	*button=intout[3];
	*kstate=intout[4];
	
	return intout[0];
}

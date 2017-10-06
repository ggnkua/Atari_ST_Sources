#include <aes.h>

typedef struct {
	int *control;
	int *global;
	int *intin;
	int *intout;
	void *addrin;
	void *addrout;
} AESPB;
void call_aes(AESPB *gpb);

int appl_getinfo(int typ,int *out1,int *out2,int *out3,int *out4)
{
AESPB pb;

	pb.control=_GemParBlk.contrl;
	pb.global=_GemParBlk.global;
	pb.intin=_GemParBlk.intin;
	pb.intout=_GemParBlk.intout;
	pb.addrin=_GemParBlk.addrin;
	pb.addrout=_GemParBlk.addrout;
	
	_GemParBlk.contrl[0]=130;
	_GemParBlk.contrl[1]=1;
	_GemParBlk.contrl[2]=5;
	_GemParBlk.contrl[3]=0;
	_GemParBlk.contrl[4]=0;
	_GemParBlk.intin[0]=typ;
	call_aes(&pb);
	*out1=_GemParBlk.intout[1];
	*out2=_GemParBlk.intout[2];
	*out3=_GemParBlk.intout[3];
	*out4=_GemParBlk.intout[4];
	return _GemParBlk.intout[0];
}

int my_wind_get(int handle,int typ,int *out1,int *out2,int *out3,int *out4)
{
AESPB pb;

	pb.control=_GemParBlk.contrl;
	pb.global=_GemParBlk.global;
	pb.intin=_GemParBlk.intin;
	pb.intout=_GemParBlk.intout;
	pb.addrin=_GemParBlk.addrin;
	pb.addrout=_GemParBlk.addrout;
	
	_GemParBlk.contrl[0]=104;
	_GemParBlk.contrl[1]=2;
	_GemParBlk.contrl[2]=5;
	_GemParBlk.contrl[3]=0;
	_GemParBlk.contrl[4]=0;
	_GemParBlk.intin[0]=handle;
	_GemParBlk.intin[1]=typ;
	call_aes(&pb);
	*out1=_GemParBlk.intout[1];
	*out2=_GemParBlk.intout[2];
	*out3=_GemParBlk.intout[3];
	*out4=_GemParBlk.intout[4];
	return _GemParBlk.intout[0];
}

int my_wind_set(int handle,int typ,int in1,int in2,int in3,int in4)
{
AESPB pb;

	pb.control=_GemParBlk.contrl;
	pb.global=_GemParBlk.global;
	pb.intin=_GemParBlk.intin;
	pb.intout=_GemParBlk.intout;
	pb.addrin=_GemParBlk.addrin;
	pb.addrout=_GemParBlk.addrout;
	
	_GemParBlk.contrl[0]=105;
	_GemParBlk.contrl[1]=6;
	_GemParBlk.contrl[2]=1;
	_GemParBlk.contrl[3]=0;
	_GemParBlk.contrl[4]=0;
	_GemParBlk.intin[0]=handle;
	_GemParBlk.intin[1]=typ;
	_GemParBlk.intin[2]=in1;
	_GemParBlk.intin[3]=in2;
	_GemParBlk.intin[4]=in3;
	_GemParBlk.intin[5]=in4;
	call_aes(&pb);
	return _GemParBlk.intout[0];
}



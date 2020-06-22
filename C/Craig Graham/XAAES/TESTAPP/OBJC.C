#include <AES.H>
#include "t1.h"

typedef struct {
	short *contrl;
	short *globl;
	short *intin;
	short *intout;
	void  **addrin;
	void  **addrout;
} AESPB;

short call_aes(short,void*);
#if USE_DEBUG_VECTOR
#pragma inline d0=call_aes(d0,d1) {"4E43";}
#else
#pragma inline d0=call_aes(d0,d1) {"4E42";}
#endif

void main(void)
{
	short Pappl_init[]={10,0,1,0,0};
	AESPB pb;
	short intin[300];
	short intout[300];
	void *addrin[300];
	void *addrout[300];
	short global[15];
	short ap_id,t1,t2,mx,my,mb,s,ob,wx,wy,ww,wh;
	OBJECT *form1;

	printf("XaAES Object Tree Test 1\n");

	pb.contrl=Pappl_init;
	pb.globl=global;
	pb.intin=intin;
	pb.intout=intout;
	pb.addrin=addrin;
	pb.addrout=addrout;
	
	call_aes(0xc8,&pb);

	ap_id=pb.intout[0];

//	ap_id=appl_init();

	t1=rsrc_load("t1.rsc");
	t2=rsrc_gaddr(R_TREE, FORM1, &form1);
	
	wind_calc(0,0,0,0,200,200,&wx,&wy,&ww,&wh);
	
	t1=wind_create(0, wx,wy,ww,wh);

	wind_open(t1,0,0,ww,wh);
	
	if (form1)
		objc_draw(form1,0,5,0,0,800,600);

	while(1)
	{
		evnt_button(1,1,1,&mx,&my,&mb,&s);
		ob=objc_find(form1,0,5,mx,my);
		if (ob>0)
		{
			t1=form_button(form1,ob,1,&t2);
			printf("form_button(%d)=%d,newobj=%d\n",ob,t1,t2);
		}
	}

	printf("rsrc_free()=%d\n",rsrc_free());

	appl_exit();

}
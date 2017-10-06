#include <aesbind.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <vdibind.h>

typedef short WORD;
typedef long  LONG;

extern	WORD	datatestdialib0[];

void test_evnt(void) {
	WORD ant_klick;
	WORD buffert[16];
	WORD happ;
	WORD knapplage;
	WORD tangent,tanglage;
	WORD x,y;
	WORD	xoff,yoff,woff,hoff;
	
	WORD	wid;
	
	
	wid = wind_create(NAME|MOVER|FULLER|SIZER|CLOSER,0,0,640,480);
			
	wind_set(wid,WF_NAME,"hej");

	wind_get(0,WF_WORKXYWH,&xoff,&yoff,&woff,&hoff);

	wind_open(wid,xoff,yoff,woff,hoff);


	while(1) {
		fprintf(stderr,"evnt_multi\r\n");
		happ = evnt_multi(MU_KEYBD | MU_BUTTON,0x102,3,0
				,0,0,0,0,0,0
				,0,0,0,0,buffert,0,&x,&y,&knapplage,&tanglage
				,&tangent,&ant_klick);
		
		fprintf(stderr,"/evnt_multi\r\n");

		if(happ & MU_KEYBD) {
			break;
		};
		
		if(happ & MU_BUTTON) {
			fprintf(stderr,"mc=%d mb=%x\r\n",ant_klick,knapplage);
		};
	};
	
	wind_delete(wid);
}

void	main(void) {
	appl_init();

	test_evnt();
	
	appl_exit();
}

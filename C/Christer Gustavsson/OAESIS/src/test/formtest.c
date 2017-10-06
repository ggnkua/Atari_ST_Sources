#include <aesbind.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <vdibind.h>

#include	"test2rsc.h"

typedef short WORD;
typedef long  LONG;

extern	WORD	datatestdialib0[];

WORD own_form_do(OBJECT *tree,WORD editobj) {
	WORD ant_klick;
	WORD buffert[16];
	WORD happ;
	WORD knapplage;
	WORD tangent,tanglage;
	WORD x,y;
	WORD newobj;

	while(1) {
		happ = evnt_multi(MU_KEYBD | MU_BUTTON,2,LEFT_BUTTON,LEFT_BUTTON
				,0,0,0,0,0,0
				,0,0,0,0,buffert,0,&x,&y,&knapplage,&tanglage
				,&tangent,&ant_klick);
				
		if((happ & MU_KEYBD) && (tangent == 0x1071)) {
			break;
		};
		
		if(happ & MU_KEYBD) {
			fprintf(stderr,"kc=%04x\r\n",tangent);
		};
		
		if(happ & MU_BUTTON) {
			WORD object = objc_find(tree,0,9,x,y);
			
			if(object != -1) {
				fprintf(stderr,"form_button()=%d",
					form_button(tree,object,ant_klick,&newobj));
				fprintf(stderr," newobj=%d\r\n",newobj);
			};
		};
	};
	
	return 0;
}

void	main(void) {
	WORD	x,y,w,h;
	
	WORD	vid;

	WORD	work_in[] = {1,7,1,1,1,1,1,1,1,1,2};
	WORD	work_out[57];
	OBJECT	*dial;
	
	appl_init();

	vid = graf_handle(&vid,&vid,&vid,&vid);

	v_opnvwk(work_in,&vid,work_out);
	
	if(rsrc_load("test2rsc.rsc")) {
		rsrc_gaddr(R_TREE,TESTDIAL,&dial);

		form_center(dial,&x,&y,&w,&h);
		form_dial(FMD_START,0,0,0,0,x,y,w,h);

		objc_draw(dial,0,9,x,y,w,h);

		own_form_do(dial,0);

		form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);

		rsrc_free();
	}
	else {
		form_alert(1,"[1][Couldn't load resource file!][Bummer!]");
	};
	
	v_clsvwk(vid);
	
	appl_exit();
}

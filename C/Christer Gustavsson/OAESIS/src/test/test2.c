#include <aesbind.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <vdibind.h>

#include	"test2rsc.h"

typedef short WORD;
typedef long  LONG;

extern	WORD	datatestdialib0[];

void	main(void) {
	WORD	x,y,w,h;
	
	WORD	mx,my,button,kstate,clicks;
	
	MFDB	mfdbs,mfdbd;
	
	WORD	xyarray[8],vid;

	WORD	work_in[] = {1,7,1,1,1,1,1,1,1,1,2};
	WORD	work_out[57];
	OBJECT	*dial;
	
	char	path[200],file[30];
	
	appl_init();

	strcpy(path,"C:\\*");
	strcpy(file,"noname.inf");

	vid = graf_handle(&vid,&vid,&vid,&vid);

	v_opnvwk(work_in,&vid,work_out);


/*	for(x = 0; x < 25; x++)
		form_error(x);
*/
/*	fsel_input(path,file,&button);
*/
	form_alert(3,"[2][Test av|form_alert.|Windoze rulez...|...___NOOOT!___][Ja|Kanske|Nej]");
	
	if(rsrc_load("test2rsc.rsc")) {
		int co;
		int i;
		
		rsrc_gaddr(R_TREE,TESTDIAL,&dial);

		form_center(dial,&x,&y,&w,&h);
		form_dial(FMD_START,0,0,0,0,x,y,w,h);

		objc_draw(dial,0,9,x,y,w,h);

		form_do(dial,0);

		form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);

		i = 0;
		
		objc_delete(dial,11);
		
		while(1) {
			fprintf(stderr,"%3d next=%3d head=%3d tail=%3d\r\n",
				i,dial[i].ob_next,dial[i].ob_head,dial[i].ob_tail);
			
			if(dial[i].ob_flags & LASTOB) {
				break;
			};
			
			i++;
		};
		
		getchar();

		rsrc_free();
	}
	else {
		form_alert(1,"[1][Couldn't load resource file!][Bummer!]");
	};
	
	v_clsvwk(vid);

	fprintf(stderr,"environ size=%d",shel_write(SWM_ENVIRON,ENVIRON_SIZE,0,NULL,NULL));
	
	appl_exit();
}

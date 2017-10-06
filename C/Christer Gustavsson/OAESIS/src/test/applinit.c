#include <aesbind.h>
#include <stdio.h>
#include <string.h>

void	main(void) {
	short	apid;
	short owner,open,above,below;
	short id;
	short p1,p2,p3,p4,ret;
	short i;
	char  file[200],path[200];
	short button;

	apid = appl_init();

	fprintf(stderr,"graf_handle=%d",graf_handle(&p1,&p2,&p3,&p4));
	
	ret = wind_get(0,WF_FULLXYWH,&p1,&p2,&p3,&p4);
	fprintf(stderr,"full: x=%d y=%d w=%d h=%d\r\n",
									p1,p2,p3,p4);

	getchar();

	ret = wind_get(0,WF_OWNER,&owner,&open,&above,&below);
	
	fprintf(stderr,"ret=%d owner=%d open=%d above=%d below=%d\r\n",
									ret,owner,open,above,below);
	
	id = wind_create(NAME|MOVER,0,0,10,10);
	
	ret = wind_get(id,WF_OWNER,&owner,&open,&above,&below);
	
	fprintf(stderr,"ret=%d owner=%d open=%d above=%d below=%d\r\n",
									ret,owner,open,above,below);

	wind_open(id,0,0,10,10);

	for(i = 0; i <= W_SMALLER; i++) {
		OBJC_COLORWORD nontop,top;
		p1 = i;
		ret = wind_get(id,WF_DCOLOR,&p1,(short *)&nontop,(short *)&top,&p4);
		
		fprintf(stderr,"ret=%d Widget nr: %3d\r\n",ret,i);
		fprintf(stderr,"\tnontop borderc=%d textc=%d opaque=%d pattern=%d fillc=%d\r\n",
						nontop.borderc,nontop.textc,nontop.opaque,nontop.pattern); 

		fprintf(stderr,"\ttop borderc=%d textc=%d opaque=%d pattern=%d fillc=%d\r\n",
						top.borderc,top.textc,top.opaque,top.pattern); 
	};

	ret = wind_get(id,WF_OWNER,&owner,&open,&above,&below);
	
	fprintf(stderr,"ret=%d owner=%d open=%d above=%d below=%d\r\n",
									ret,owner,open,above,below);

	wind_delete(id);

	ret = wind_get(0,0x5758,&p1,&p2,&p3,&p4);
	fprintf(stderr,"ret=%d p1=%d p2=%d p3=%d p4=%d\r\n",ret,p1,p2,p3,p4);
	
	strcpy(path,"u:\\c\\*");
	strcpy(file,"");
	
	fsel_exinput(path,file,&button,"Testelitest");
	
	fprintf(stderr,"|%s| |%s| |%d|\r\n",path,file,button);


	for(i = 0; i < 15; i ++) {
		fprintf(stderr,"global[%2d]=%5d  0x%04x\r\n",i,_global[i],_global[i]);
	};

	getchar();	

	appl_exit();
}
